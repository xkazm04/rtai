"""Reads the stereo wav recorded from dev/audio/audio_pan.tscn and prints the L/R balance and level of each shot.
Usage: python tools/audio/pan_check.py <pan_audio.wav>"""
import subprocess, sys
import numpy as np

POS = [(-14, 0), (14, 0), (-4, 0), (4, 0), (0, -10), (0, 10), (5, 0), (25, 0), (45, 0)]
raw = subprocess.run(["ffmpeg", "-v", "error", "-i", sys.argv[1], "-f", "f32le", "-"], capture_output=True).stdout
a = np.frombuffer(raw, dtype=np.float32).reshape(-1, 2)
sr = 48000
for k, p in enumerate(POS):
    x = a[int((k + 0.5) * sr): int((k + 1.0) * sr)]
    l = np.sqrt((x[:, 0] ** 2).mean()) + 1e-9
    r = np.sqrt((x[:, 1] ** 2).mean()) + 1e-9
    spec = np.abs(np.fft.rfft(x.mean(axis=1))) ** 2
    hf = spec[int(4000 / (sr / 2) * len(spec)):].sum() / (spec.sum() + 1e-12)
    print(f"HF>4k {10*np.log10(hf+1e-12):6.1f} dB of total  ", end="")
    print(f"shot at {p} m: L {20*np.log10(l):6.1f} dB  R {20*np.log10(r):6.1f} dB  L-R {20*np.log10(l/r):5.1f} dB  total {20*np.log10(np.sqrt(l*l+r*r)):6.1f} dB")
