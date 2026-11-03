"""Envelope sanity for impulsive SFX (no listening device in the day run): the peak must land early, the energy must
decay, and the file must not be mostly silence. Prints one row per file and flags outliers."""
import pathlib, subprocess, sys
import numpy as np

SR = 44100
IMPULSIVE = ("pistol_shot", "rifle_shot", "nailgun_shot", "impact_", "shock_crackle", "crash", "horn")
for f in sorted(pathlib.Path("project/assets/audio/sfx").glob("*.*")):
    if f.suffix == ".import" or not f.name.startswith(IMPULSIVE): continue
    raw = subprocess.run(["ffmpeg", "-v", "error", "-i", str(f), "-ac", "1", "-ar", str(SR), "-f", "f32le", "-"], capture_output=True).stdout
    a = np.frombuffer(raw, dtype=np.float32)
    pk = int(np.abs(a).argmax()); t_pk = pk / SR
    env = np.convolve(np.abs(a), np.ones(441) / 441, mode="same")
    half = len(a) // 2
    early, late = float(np.sqrt((a[:half] ** 2).mean())), float(np.sqrt((a[half:] ** 2).mean()))
    spec = np.abs(np.fft.rfft(a)); freqs = np.fft.rfftfreq(len(a), 1 / SR)
    cent = float((spec * freqs).sum() / max(spec.sum(), 1e-9))
    quiet = float((env < 0.02 * env.max()).mean())
    flag = []
    if t_pk > 0.12 and not f.name.startswith(("crash", "horn", "shock")): flag.append("late peak")
    if late > early: flag.append("energy grows")
    if quiet > 0.7: flag.append("mostly silent")
    print(f"{f.name:28s} dur {len(a)/SR:4.2f}s peak@{t_pk*1000:5.0f}ms centroid {cent:6.0f}Hz decay {20*np.log10(max(late,1e-9)/max(early,1e-9)):6.1f}dB quiet {quiet:4.2f} {'FLAG ' + ','.join(flag) if flag else ''}")
