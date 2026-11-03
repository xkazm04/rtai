"""Cuts the two generated footstep runs (footsteps_01 = a walk, 4 steps; footsteps_02 = a faster gait, 7 steps) into single
steps, so the game plays one step per stride instead of replaying a 2 s run. Writes footstep_01..08.wav next to them and
removes the run files. Peak-normalised to -3 dBFS like every SFX. Run from the repo root.
Usage: python -I tools/audio/split_steps.py project/assets/audio/sfx"""
import pathlib, sys, wave
import numpy as np

SR = 44100


def read(p: pathlib.Path) -> np.ndarray:
    w = wave.open(str(p))
    return np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float32) / 32768


def onsets(a: np.ndarray, min_gap: float = 0.2) -> list:
    win = int(0.01 * SR)
    env = np.array([np.sqrt((a[i:i + win] ** 2).mean()) for i in range(0, len(a) - win, win // 2)])
    out, prev, last = [], False, -9.0
    for i, e in enumerate(env):
        t = i * 0.005
        if e > env.max() * 0.25 and not prev and t - last > min_gap:
            out.append(max(t - 0.006, 0.0))
            last = t
        prev = e > env.max() * 0.25
    return out


def cut(a: np.ndarray, t0: float, t1: float) -> np.ndarray:
    s = a[int(t0 * SR): int(t1 * SR)].copy()
    n = min(int(0.025 * SR), len(s) // 2)
    s[-n:] *= np.linspace(1, 0, n, dtype=np.float32)
    s *= 10 ** (-3 / 20) / max(float(np.abs(s).max()), 1e-6)
    return s


def write(p: pathlib.Path, a: np.ndarray) -> None:
    w = wave.open(str(p), "wb")
    w.setnchannels(1)
    w.setsampwidth(2)
    w.setframerate(SR)
    w.writeframes((np.clip(a, -1, 1) * 32767).astype(np.int16).tobytes())
    w.close()


def main(d: pathlib.Path) -> None:
    steps = []
    for name, keep in (("footsteps_01.wav", 4), ("footsteps_02.wav", 4)):
        a = read(d / name)
        on = onsets(a) + [len(a) / SR]
        for k in range(min(keep, len(on) - 1)):
            steps.append(cut(a, on[k], min(on[k + 1] - 0.01, on[k] + 0.4)))
    for i, s in enumerate(steps):
        write(d / f"footstep_{i + 1:02d}.wav", s)
        print(f"footstep_{i + 1:02d}.wav {len(s) / SR:.3f}s peak {20 * np.log10(np.abs(s).max()):.1f} dB")
    for name in ("footsteps_01", "footsteps_02"):
        for ext in (".wav", ".wav.import"):
            (d / (name + ext)).unlink(missing_ok=True)


if __name__ == "__main__":
    main(pathlib.Path(sys.argv[1]))
