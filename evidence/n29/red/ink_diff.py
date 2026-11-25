"""Pixels whose printed colour changed between two renders of the same frame, inside and outside the fire
box. python -I evidence/n29/red/ink_diff.py <a dir> <b dir>  (build/n29red/after and build/n29red/after2)"""
import sys, os
import numpy as np
from PIL import Image
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from stills import SHOTS


def diff(a_path, b_path, box):
    a = np.array(Image.open(a_path).convert("RGB")).astype(int)
    b = np.array(Image.open(b_path).convert("RGB")).astype(int)
    ch = np.abs(a - b).max(axis=2) > 24
    inside = np.zeros_like(ch)
    x0, y0, x1, y1 = box
    inside[y0:y1, x0:x1] = True
    out = ch & ~inside
    cols = {}
    for c in map(tuple, b[out] // 32 * 32):
        cols[c] = cols.get(c, 0) + 1
    top = sorted(cols.items(), key=lambda kv: -kv[1])[:4]
    return int((ch & inside).sum()), int(out.sum()), top, np.argwhere(out)


if __name__ == "__main__":
    a_root, b_root = sys.argv[1], sys.argv[2]
    for name, (frame, box) in SHOTS.items():
        rel = frame.split("{side}/")[1]
        a, b = os.path.join(a_root, rel), os.path.join(b_root, rel)
        if not (os.path.exists(a) and os.path.exists(b)):
            continue
        n_in, n_out, top, where = diff(a, b, box)
        span = "" if not n_out else " outside bbox x%d-%d y%d-%d" % (where[:, 1].min(), where[:, 1].max(),
                                                                       where[:, 0].min(), where[:, 0].max())
        print("%s: changed inside box %d, outside %d%s; outside colours %s" % (name, n_in, n_out, span, top))
