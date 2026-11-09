# n10 it9: classify the frames that differ in the A/B (main32 vs head32) and in neither A/A (head32 vs head32b, main32 vs main32b).
# Needs the raw .avi from film.sh / aa.sh in the cwd (deleted after the run: rerun those scripts to regenerate). Writes ab_only_frames.json.
# ffmpeg's psnr stats count from n:1, select's n counts from 0: the extraction subtracts 1.
import json
import re
import subprocess

import numpy as np
from PIL import Image

E = "C:/Users/kazda/kiro/gtai-wt/n10-perf/evidence/perf/n10-film/"


def load(name):
    out = {}
    for line in open(E + name):
        m = re.search(r"n:(\d+) mse_avg:([\d.]+)", line)
        if m and float(m[2]) > 0:
            out[int(m[1])] = float(m[2])
    return out


def cream(c):
    return (c[..., 0] > 205) & (c[..., 1] > 195) & (c[..., 2] > 165)


ab, h, m = load("psnr32.log"), load("psnr_aa_head32b.log"), load("psnr_aa_main32b.log")
frames = sorted(k for k in ab if k not in h and k not in m)
sel = "+".join("eq(n\\,%d)" % (n - 1) for n in frames)
for arm in ("main32", "head32"):
    subprocess.run(
        ["ffmpeg", "-loglevel", "error", "-y", "-i", f"{arm}.avi", "-vf", f"select={sel}", "-vsync", "0", f"cmp/{arm}_%03d.png"],
        check=True,
    )
rows = []
for i, n in enumerate(frames, 1):
    a = np.array(Image.open(f"cmp/main32_{i:03d}.png").convert("RGB")).astype(int)
    b = np.array(Image.open(f"cmp/head32_{i:03d}.png").convert("RGB")).astype(int)
    d = np.abs(a - b).max(axis=2)
    mask = d > 24
    ys, xs = np.where(mask)
    rows.append(
        {
            "psnr_log_n": n,
            "video_n": n - 1,
            "log_mse": ab[n],
            "png_mse": round(float(((a - b) ** 2).mean()), 3),
            "changed_gt24": int(mask.sum()),
            "changed_gt0": int((d > 0).sum()),
            "bbox": [int(xs.min()), int(ys.min()), int(xs.max()), int(ys.max())] if mask.any() else None,
            "cream_main": int((mask & cream(a)).sum()),
            "cream_head": int((mask & cream(b)).sum()),
        }
    )
json.dump(rows, open(E + "ab_only_frames.json", "w"), indent=0)
