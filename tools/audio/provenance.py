"""Appends steam/ai-provenance lines for every shipped audio file (LEG-05). Idempotent: skips a file whose
current sha256 is already logged. Usage: python tools/audio/provenance.py <masters_audio_dir>"""
import hashlib, json, pathlib, sys, datetime

masters = pathlib.Path(sys.argv[1])
log = pathlib.Path("steam/ai-provenance/2026-11.jsonl")
seen = set()
for l in log.read_text(encoding="utf-8").splitlines():
    if l.strip():
        r = json.loads(l); seen.add((r["file"].replace("\\", "/"), r["sha256"]))
sfx_src = json.loads(pathlib.Path("evidence/sfx_map.json").read_text())["src"]
gen = {}
for l in (masters / "raw" / "gen_log.jsonl").read_text().splitlines():
    r = json.loads(l)
    if "file" in r: gen[r["file"].rsplit(".", 1)[0]] = r
voice = {}
for l in (masters / "voice" / "voice_log.jsonl").read_text().splitlines():
    r = json.loads(l); voice[r["line"]] = r
extra = {}
ex = masters / "music" / "music_log.jsonl"
if ex.exists():
    for l in ex.read_text().splitlines():
        r = json.loads(l); extra[r["name"]] = r
out = []
for f in sorted(pathlib.Path("project/assets/audio").rglob("*")):
    if f.suffix not in (".wav", ".ogg"): continue
    rel = f.as_posix(); sha = hashlib.sha256(f.read_bytes()).hexdigest()
    if (rel, sha) in seen: continue
    stem = f.stem
    base = dict(file=rel, sha256=sha, date=datetime.date.today().isoformat(), references=[], seed=None,
                accepted_by="agent:audio-lane (owner review pending)", ships_in="core.pck")
    if "/voice/" in rel:
        v = voice[stem]
        base.update(tool="elevenlabs-tts (direct API; PoF has no tts, POF-GAP 2)", model="eleven_multilingual_v2",
                    prompt_ref=f"project/quests/collect-call/quest.json#lines/{stem} (text); voice '{v['voice']}' (stock premade, tools/audio/casting.json)",
                    human_edits="loudnorm -18 LUFS / -2 dBTP, mono Ogg Vorbis q4" + ("; telephone band-pass (highpass 320 Hz, lowpass 3.4 kHz, compressor)" if stem == "patch-collect-call" else ""))
    elif "/music/" in rel:
        m = extra[stem]
        base.update(tool=m["tool"], model=m["model"], prompt_ref=m["prompt_ref"], human_edits=m["human_edits"] + ("; fade-out tail cut back so the loop seam is music into music" if stem == "radio_loop_2" else ""))
    else:
        g = gen[sfx_src.get(stem, stem)]
        base.update(tool="elevenlabs-sound-generation (direct API; PoF audio-gen refused every request, POF-GAP 1)", model="elevenlabs sound-generation v2",
                    prompt_ref=f"masters:day-d5/audio/raw/gen_log.jsonl#{g['file']}: {g['prompt']}",
                    human_edits="trimmed silence, 12 ms fades, downmixed mono 44.1 kHz, peak-normalised (-3 dBFS; loops -6 dBFS, 0.3 s crossfaded seam)")
    out.append(base)
with log.open("a", encoding="utf-8", newline="\n") as fh:
    for r in out: fh.write(json.dumps(r, sort_keys=True, ensure_ascii=False) + "\n")
print("appended", len(out))
