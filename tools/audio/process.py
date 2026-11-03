"""Trim / normalise / QC the raw ElevenLabs takes (ffmpeg + numpy). Writes the repo-side finals and a report.
Usage: python tools/audio/process.py <raw_dir> <voice_raw_dir> <out_assets_audio_dir> <report.json>
SFX -> mono 44.1k 16-bit WAV (<=3 s, AST-07) or Ogg for longer loops; peak target -3 dBFS (loops: -6 dBFS).
Voice -> mono Ogg Vorbis, loudnorm to -18 LUFS / -2 dBTP. Rejects: silent, too short, clipped source, wrong length."""
import json, pathlib, subprocess, sys
import numpy as np

SR = 44100
IMPULSIVE = ("pistol_shot", "rifle_shot", "nailgun_shot", "impact_")
GUNS = ("pistol_shot", "rifle_shot", "nailgun_shot")
FF = "ffmpeg"


def flat_run(a: np.ndarray) -> int:
    """Longest run of consecutive samples within 0.5% of the file's peak: flat tops = hard clipping at the source.
    (MP3 decode overshoots 0 dBFS on hot sources; that is not clipping and normalising down removes it.)"""
    if len(a) == 0:
        return 0
    hot = np.abs(a) >= 0.995 * float(np.abs(a).max())
    best = run = 0
    for h in hot:
        run = run + 1 if h else 0
        best = max(best, run)
    return best


def decode(path: pathlib.Path) -> np.ndarray:
    p = subprocess.run([FF, "-v", "error", "-i", str(path), "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True, check=True)
    return np.frombuffer(p.stdout, dtype=np.float32).copy()


def db(x: float) -> float:
    return 20 * np.log10(max(x, 1e-9))


def trim(a: np.ndarray, floor_db: float = -45.0) -> np.ndarray:
    thr = 10 ** (floor_db / 20)
    idx = np.where(np.abs(a) > thr)[0]
    if len(idx) == 0:
        return a[:0]
    return a[max(idx[0] - int(0.004 * SR), 0): min(idx[-1] + int(0.03 * SR), len(a))]


def decay_db(a: np.ndarray) -> float:
    half = len(a) // 2
    return 20 * np.log10(max(float(np.sqrt((a[half:] ** 2).mean())), 1e-9) / max(float(np.sqrt((a[:half] ** 2).mean())), 1e-9))


def fade(a: np.ndarray, ms: float = 12.0) -> np.ndarray:
    n = min(int(ms / 1000 * SR), len(a) // 2)
    if n > 0:
        a[-n:] *= np.linspace(1, 0, n, dtype=np.float32)
        a[:n] *= np.linspace(0, 1, n, dtype=np.float32)
    return a


def loopify(a: np.ndarray, sec: float = 0.3) -> np.ndarray:
    """Seamless loop: equal-power crossfade of the tail into the head (the file shortens by `sec`)."""
    n = int(sec * SR)
    t = np.linspace(0, np.pi / 2, n, dtype=np.float32)
    head = a[:n] * np.sin(t) + a[-n:] * np.cos(t)
    return np.concatenate([head, a[n:-n]]).astype(np.float32)


def write_wav(path: pathlib.Path, a: np.ndarray) -> None:
    pcm = (np.clip(a, -1, 1) * 32767).astype("<i2").tobytes()
    subprocess.run([FF, "-y", "-v", "error", "-f", "s16le", "-ar", str(SR), "-ac", "1", "-i", "-", str(path)], input=pcm, check=True)


def write_ogg(path: pathlib.Path, a: np.ndarray, q: int = 4) -> None:
    subprocess.run([FF, "-y", "-v", "error", "-f", "f32le", "-ar", str(SR), "-ac", "1", "-i", "-", "-c:a", "libvorbis", "-q:a", str(q), str(path)],
                   input=a.astype("<f4").tobytes(), check=True)


def sfx(raw: pathlib.Path, out: pathlib.Path, log: list) -> None:
    count: dict = {}
    srcmap: dict = {}
    for f in sorted(raw.glob("*.mp3")):
        key = f.stem.rsplit("_", 1)[0]
        loop = key.endswith("_loop") or key == "city_ambience"
        a = decode(f)
        rec = {"file": f.name, "src_dur": round(len(a) / SR, 2), "src_peak_db": round(db(float(np.abs(a).max())), 1) if len(a) else None}
        full_scale = flat_run(a)
        if loop:
            b = loopify(a.copy())
        else:
            b = fade(trim(a).copy())
        if len(b) < 0.08 * SR:
            rec.update(status="REJECT", why="empty or silent after trim"); log.append(rec); continue
        if not loop and key.startswith(IMPULSIVE) and int(np.abs(b).argmax()) > 0.12 * SR:
            rec.update(status="REJECT", why=f"impulsive sound peaks late ({int(np.abs(b).argmax()) * 1000 // SR} ms)"); log.append(rec); continue
        if not loop and key.startswith(GUNS) and decay_db(b) > -18.0:
            rec.update(status="REJECT", why=f"no decay ({decay_db(b):.1f} dB second half vs first): a sustained noise burst, not a shot"); log.append(rec); continue
        if not loop and float(np.abs(b[-int(0.05 * SR):]).max()) > 0.1 * float(np.abs(b).max()):
            b = fade(b, 80.0)  # cut off while still loud (the generator stopped at its length): a longer fade hides the cut
        if full_scale >= 6:
            rec.update(status="REJECT", why=f"source hard-clipped (flat top of {full_scale} samples)"); log.append(rec); continue
        peak = float(np.abs(b).max())
        target = -6.0 if loop else -3.0
        b = b * (10 ** (target / 20) / peak)
        rms = float(np.sqrt((b ** 2).mean()))
        dur = len(b) / SR
        count[key] = count.get(key, 0) + 1
        stem = f"{key}_{count[key]:02d}"
        srcmap[stem] = f.stem
        name = f"{stem}.{'ogg' if dur > 3.0 else 'wav'}"
        (write_ogg if dur > 3.0 else write_wav)(out / "sfx" / name, b)
        rec.update(status="OK", out=name, dur=round(dur, 2), peak_db=round(db(float(np.abs(b).max())), 1), rms_db=round(db(rms), 1), loop=loop)
        log.append(rec)
    (out.parent.parent.parent / "evidence").mkdir(exist_ok=True)
    (out.parent.parent.parent / "evidence" / "sfx_map.json").write_text(json.dumps({"takes": count, "src": srcmap}, indent=1, sort_keys=True))


def voice(raw: pathlib.Path, out: pathlib.Path, log: list) -> None:
    for f in sorted(raw.glob("*.mp3")):
        dst = out / "voice" / (f.stem + ".ogg")
        a = decode(f)
        if len(a) < 0.3 * SR or float(np.abs(a).max()) < 0.02:
            log.append({"file": f.name, "status": "REJECT", "why": "empty/silent"}); continue
        flt = "loudnorm=I=-18:TP=-2:LRA=11"
        if f.stem == "patch-collect-call":  # a payphone-router voice: band-limit it
            flt = "highpass=f=320,lowpass=f=3400,acompressor=threshold=-20dB:ratio=3," + flt
        subprocess.run([FF, "-y", "-v", "error", "-i", str(f), "-ac", "1", "-ar", str(SR), "-af", flt, "-c:a", "libvorbis", "-q:a", "4", str(dst)], check=True)
        n = decode(dst)
        meas = subprocess.run([FF, "-hide_banner", "-nostats", "-i", str(dst), "-af", "ebur128=peak=true", "-f", "null", "-"], capture_output=True, text=True).stderr
        lufs = meas.rsplit("I:", 1)[-1].split("LUFS")[0].strip() if "I:" in meas else "?"
        log.append({"file": f.name, "status": "OK", "out": dst.name, "dur": round(len(n) / SR, 2), "lufs": lufs, "peak_db": round(db(float(np.abs(n).max())), 1)})


def music(raw: pathlib.Path, out: pathlib.Path, log: list) -> None:
    (out / "music").mkdir(parents=True, exist_ok=True)
    for f in sorted(raw.glob("*.mp3")):
        a = decode(f)
        stinger = "stinger" in f.stem
        b = fade(trim(a, -50.0).copy(), 20.0) if stinger else loopify(a.copy(), 0.5)
        peak = float(np.abs(b).max())
        b = b * (10 ** ((-3.0 if stinger else -6.0) / 20) / peak)
        # stereo is not kept: mono keeps the radio in the same positional chain as everything else
        write_ogg(out / "music" / (f.stem + ".ogg"), b)
        log.append({"file": f.name, "status": "OK", "out": f.stem + ".ogg", "dur": round(len(b) / SR, 2), "peak_db": round(db(float(np.abs(b).max())), 1), "rms_db": round(db(float(np.sqrt((b ** 2).mean()))), 1)})


def main() -> None:
    raw, vraw, out, report = map(pathlib.Path, sys.argv[1:5])
    (out / "sfx").mkdir(parents=True, exist_ok=True); (out / "voice").mkdir(parents=True, exist_ok=True)
    s: list = []; v: list = []; m: list = []
    sfx(raw, out, s); voice(vraw, out, v)
    mraw = raw.parent / "music"
    if mraw.exists(): music(mraw, out, m)
    report.write_text(json.dumps({"sfx": s, "voice": v, "music": m, "targets": {"sfx_peak_db": -3, "loop_peak_db": -6, "voice_lufs": -18, "voice_tp_db": -2}}, indent=1))
    print("sfx ok", sum(r["status"] == "OK" for r in s), "rejected", sum(r["status"] == "REJECT" for r in s))
    print("voice ok", sum(r["status"] == "OK" for r in v), "rejected", sum(r["status"] == "REJECT" for r in v))
    for r in s + v:
        if r["status"] != "OK": print("REJECT", r)

main()
