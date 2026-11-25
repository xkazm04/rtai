"""Independent proof against HEAD: per file reddish before -> after, changed px, and for every strip cell the biggest
loose reddish blob (collar + body) strict-reddish count and a byte compare. python -I verify.py (repo root)."""
import subprocess, sys, io
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
from scipy import ndimage
import _ref as R, recolour_strips as X

def head(f):
    p = subprocess.run("git show HEAD:%s | git lfs smudge" % f, shell=True, capture_output=True).stdout
    return np.array(Image.open(io.BytesIO(p)).convert("RGBA"))

for f in [A for A in X.BOXES if "held_55" not in A] + X.EQ + [X.WALK]:
    b, a = head(f), R.load(f)
    ch = (a != b).any(axis=2)
    line = "%s: reddish %d -> %d, changed px %d, alpha changed %d" % (f.split("art/")[-1], R.reddish(b).sum(), R.reddish(a).sum(), ch.sum(), (a[..., 3] != b[..., 3]).sum())
    if f in X.BOXES:
        y0, y1, x0, x1 = X.BOXES[f]; box = np.zeros(ch.shape, bool); box[y0:y1, x0:x1] = True
        line += ", changed outside box %d" % (ch & ~box).sum()
    else:
        cells = X.col_cells(b) if f in X.EQ else X.grid_cells(b)
        # the changed px form one small blob per flame; a collar stripe is never part of one (the collar is a >2000 px
        # striped band; every changed blob is <= 700 px and <= 60 x 75 px)
        lab, n = ndimage.label(ndimage.binary_dilation(ch, np.ones((3, 3)), iterations=2), structure=np.ones((3, 3)))
        sz = [int((ch & (lab == i)).sum()) for i in range(1, n + 1)]
        bb = [ndimage.find_objects((lab == i).astype(int))[0] for i in range(1, n + 1)]
        wh = [(s_[1].stop - s_[1].start, s_[0].stop - s_[0].start) for s_ in bb]
        line += ", %d changed blobs, largest %d px, widest %d, tallest %d" % (n, max(sz), max(w for w, h in wh), max(h for w, h in wh))
    print(line)
