"""Reddish = R>170, G<110, B<90 (alpha > 0). Counts per PNG under project/features/combat and per fx_atlas cell.
Run from the repo root: python -I evidence/n28/red/count_red.py [--json]"""
import sys, glob, json
import numpy as np
from PIL import Image

def red(a):
    return int(((a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90) & (a[..., 3] > 0)).sum())

def rows():
    out = []
    for p in sorted(glob.glob("project/features/combat/**/*.png", recursive=True)):
        a = np.array(Image.open(p).convert("RGBA"))
        n = red(a)
        if n:
            out.append((p.replace("\\", "/"), n, a.shape[1], a.shape[0]))
    atlas = np.array(Image.open("project/features/fx/art/fx_atlas.png").convert("RGBA"))
    for i in range(32):
        r, c = divmod(i, 8)
        n = red(atlas[r * 256:(r + 1) * 256, c * 256:(c + 1) * 256])
        if n:
            out.append(("project/features/fx/art/fx_atlas.png#cell%d" % i, n, 256, 256))
    return out

if __name__ == "__main__":
    for r in sorted(rows(), key=lambda x: -x[1]):
        print(r[1], r[0], "%dx%d" % (r[2], r[3]))
