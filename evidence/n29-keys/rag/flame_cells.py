"""n29 keys rag2: per-cell flame detection for Rivet's molotov strips. A cell = a run of alpha columns (gap > 3 px) or a
fixed grid; the flame = small reddish blob (loose mask, 8-connected, 25..500 px) that has a yellow-white core next to it
and is not the biggest blob (collar/rust). Imported by recolour_strips.py."""
import numpy as np
from scipy import ndimage
import _ref as R

V = "project/features/characters/art/view/"


def hsv(a):
    h, s, v = R._hsv(a)
    return h, s, v


def cells(a, gap=3):
    al = (a[..., 3] > 0).any(axis=0)
    cols = np.nonzero(al)[0]
    runs, s, p = [], cols[0], cols[0]
    for c in cols[1:]:
        if c - p > gap:
            runs.append((s, p + 1))
            s = c
        p = c
    runs.append((s, p + 1))
    return runs


def flame_blobs(a, x0, x1, y0=0, y1=None):
    y1 = y1 or a.shape[0]
    sub = a[y0:y1, x0:x1]
    m = R.mask(sub)
    h, s, v = hsv(sub)
    core = (h >= 38) & (h <= 62) & (s > 0.3) & (v > 0.85) & (sub[..., 3] > 0)
    lab, n = ndimage.label(m, structure=np.ones((3, 3)))
    out = []
    for i in range(1, n + 1):
        b = lab == i
        z = int(b.sum())
        if z < 25 or z > 500:
            continue
        ys, xs = np.nonzero(b)
        d = ndimage.binary_dilation(b, structure=np.ones((3, 3)), iterations=3)
        out.append(dict(i=i, n=z, core=int((d & core).sum()), box=(int(ys.min()) + y0, int(ys.max()) + 1 + y0, int(xs.min()) + x0, int(xs.max()) + 1 + x0)))
    return out
