"""n15 hero it16: a ground-stabilised feet trace of one stride_film leg (crops follow the rig).
Each tick's ground shift against the previous tick comes from cv2.phaseCorrelate on a band of the
crop clear of the figure; the frames are then placed in ground coordinates and the feet band of every
tick is stacked top to bottom: a planted foot draws a vertical column, a sliding foot a slant.
usage: py -3 -I feet_trace.py <prefix> <leg> <n> <band y0,y1> <feet y0,y1> <out.png> [<scale>]
prints the per-tick ground shift (crop px) and writes the trace (x<scale>, nearest)."""
import sys
import cv2
import numpy as np
from PIL import Image, ImageDraw

pre, leg, n = sys.argv[1], int(sys.argv[2]), int(sys.argv[3])
by0, by1 = (int(v) for v in sys.argv[4].split(","))
fy0, fy1 = (int(v) for v in sys.argv[5].split(","))
out, k = sys.argv[6], int(sys.argv[7]) if len(sys.argv) > 7 else 2
fr = [np.asarray(Image.open(f"{pre}_{leg}_{f:02d}.png").convert("RGB")) for f in range(n)]
gray = [cv2.cvtColor(f, cv2.COLOR_RGB2GRAY).astype(np.float32) for f in fr]
win = cv2.createHanningWindow((fr[0].shape[1], by1 - by0), cv2.CV_32F)
pos = [np.zeros(2)]
for a, b in zip(gray, gray[1:]):
    (dx, dy), resp = cv2.phaseCorrelate(a[by0:by1], b[by0:by1], win)
    pos.append(pos[-1] - np.array([dx, dy]))  # the rig's travel = minus the ground's shift in the crop
print("ground shift per tick (crop px):", " ".join(f"{-(p1 - p0)[0]:+.1f}" for p0, p1 in zip(pos, pos[1:])))
xs = [p[0] for p in pos]
w = fr[0].shape[1]
x0 = int(np.floor(min(xs)))
W = int(np.ceil(max(xs))) - x0 + w
rows = []
for f, p in zip(fr, pos):
    canvas = Image.new("RGB", (W, fy1 - fy0), (40, 40, 44))
    canvas.paste(Image.fromarray(f[fy0:fy1]), (int(round(p[0])) - x0, 0))
    rows.append(canvas)
img = Image.new("RGB", (W, (fy1 - fy0) * n), (40, 40, 44))
for i, r in enumerate(rows):
    img.paste(r, (0, i * (fy1 - fy0)))
img = img.resize((W * k, img.height * k), Image.NEAREST)
d = ImageDraw.Draw(img)
for x in range(0, img.width, 16 * k):
    d.line([(x, 0), (x, img.height)], fill=(255, 0, 255) if x % (64 * k) == 0 else (120, 60, 120))
img.save(out)
print(out, img.size)
