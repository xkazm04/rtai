"""Copy of evidence/n28/red/count_red.py with a crop mode. Reddish = R>170, G<110, B<90 (alpha > 0).
Run from the repo root:
  python -I evidence/n29/red/count_red.py                      the n28 table (every combat PNG + atlas cells)
  python -I evidence/n29/red/count_red.py --crop <png> x0 y0 x1 y1   reddish px inside that box"""
import sys, glob
import numpy as np
from PIL import Image


def red(a):
    if a.shape[2] == 3:
        a = np.dstack([a, np.full(a.shape[:2], 255, a.dtype)])
    return int(((a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90) & (a[..., 3] > 0)).sum())


def crop_count(path, box):
    a = np.array(Image.open(path).convert("RGBA"))
    x0, y0, x1, y1 = box
    return red(a[y0:y1, x0:x1])


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
    if len(sys.argv) == 7 and sys.argv[1] == "--crop":
        print(crop_count(sys.argv[2], tuple(int(v) for v in sys.argv[3:7])))
    else:
        for r in sorted(rows(), key=lambda x: -x[1]):
            print(r[1], r[0], "%dx%d" % (r[2], r[3]))
