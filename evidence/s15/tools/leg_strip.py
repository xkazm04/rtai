"""n15 hero it16: a before-over-after strip of one leg of two k16 films, cropped to the figure.
usage: py -3 -I leg_strip.py <out.png> <leg> <first> <n> <crop x0,y0,x1,y1> <prefix>... (one row a prefix)"""
import sys
from PIL import Image

out, leg, first, n = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), int(sys.argv[4])
box = tuple(int(v) for v in sys.argv[5].split(","))
pre = sys.argv[6:]
w, h = box[2] - box[0], box[3] - box[1]
im = Image.new("RGB", (w * n, h * len(pre)), (90, 90, 96))
for r, p in enumerate(pre):
    for c in range(n):
        fr = Image.open(f"{p}_{leg}_{first + c:02d}.png").convert("RGB").crop(box)
        im.paste(fr, (c * w, r * h))
im.save(out)
print(out, im.size)
