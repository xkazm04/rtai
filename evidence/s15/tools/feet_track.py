"""n15 hero it16: the drawn feet's ground x per tick on a stride_film leg (crops follow the rig): the
ground shift comes from cv2.phaseCorrelate on a band clear of the figure, the feet are the dark
clusters (max channel < <dark>) of >= 3 px in the feet band; each cluster's centre + the rig's ground
travel = its ground x. A planted foot keeps its ground x over ticks; a ground mark never moves (check).
usage: py -3 -I feet_track.py <prefix> <leg> <n> <band y0,y1> <feet y0,y1> [<dark>]"""
import sys
import cv2
import numpy as np
from PIL import Image

pre, leg, n = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
by0, by1 = (int(v) for v in sys.argv[4].split(","))
fy0, fy1 = (int(v) for v in sys.argv[5].split(","))
dark_at = int(sys.argv[6]) if len(sys.argv) > 6 else 70
fr = [np.asarray(Image.open(f"{pre}_{leg}_{f:02d}.png").convert("RGB")) for f in range(n)]
g = [cv2.cvtColor(f, cv2.COLOR_RGB2GRAY).astype(np.float32) for f in fr]
win = cv2.createHanningWindow((g[0].shape[1], by1 - by0), cv2.CV_32F)
pos = [0.0]
for a, b in zip(g, g[1:]):
    pos.append(pos[-1] - cv2.phaseCorrelate(a[by0:by1], b[by0:by1], win)[0][0])
print("tick  travel  dark clusters' ground x (crop px)")
for t, (f, p) in enumerate(zip(fr, pos)):
    dark = f[fy0:fy1].astype(int).max(axis=2) < dark_at
    cols = np.where(dark.sum(axis=0) >= 3)[0]
    runs, start, prev = [], None, None
    for c in cols:
        if prev is None or c > prev + 2:
            if start is not None:
                runs.append((start, prev))
            start = c
        prev = c
    if start is not None:
        runs.append((start, prev))
    xs = " ".join(f"{(a + b) / 2 + p:6.1f}" for a, b in runs if b - a >= 3)
    print(f"{t:4d} {p:7.1f}  {xs}")
