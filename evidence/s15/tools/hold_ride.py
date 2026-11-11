"""n15 hero it16: how far a drawn ghost's held frame rides over the ground (the in-frame sawtooth),
measured on a stride_film leg at the play zoom: the pose changes where the figure box's pixels change
by more than <thr> % between ticks; the ground shift per tick comes from cv2.phaseCorrelate on a band
clear of the figure. usage: py -3 -I hold_ride.py <prefix> <leg> <n> <band y0,y1> <fig x0,y0,x1,y1>"""
import sys
import cv2
import numpy as np
from PIL import Image

pre, leg, n = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
by0, by1 = (int(v) for v in sys.argv[4].split(","))
fx0, fy0, fx1, fy1 = (int(v) for v in sys.argv[5].split(","))
fr = [np.asarray(Image.open(f"{pre}_{leg}_{f:02d}.png").convert("RGB")).astype(np.int16) for f in range(n)]
g = [cv2.cvtColor(f.astype(np.uint8), cv2.COLOR_RGB2GRAY).astype(np.float32) for f in fr]
win = cv2.createHanningWindow((g[0].shape[1], by1 - by0), cv2.CV_32F)
shift = [float(np.hypot(*cv2.phaseCorrelate(a[by0:by1], b[by0:by1], win)[0])) for a, b in zip(g, g[1:])]
change = []
for a, b in zip(fr, fr[1:]):
    d = np.abs(a[fy0:fy1, fx0:fx1] - b[fy0:fy1, fx0:fx1]).max(axis=2) > 40
    change.append(100.0 * d.mean())
holds, run, ride, rides = [], 1, 0.0, []
for s, c in zip(shift, change):
    if c > 6.0:
        holds.append(run)
        rides.append(ride)
        run, ride = 1, 0.0
    else:
        run += 1
        ride += s
print(f"ground px/tick mean {np.mean(shift):.2f}; pose changes {len(holds)} in {n} ticks")
print("holds (ticks):", holds)
print("ride inside each hold (crop px):", " ".join(f"{r:.1f}" for r in rides))
if rides:
    print(f"ride mean {np.mean(rides):.1f}, max {max(rides):.1f} crop px")
