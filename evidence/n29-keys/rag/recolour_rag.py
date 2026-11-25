"""n29 keys: the molotov's lit rag flame, red -> amber #EDAB42, via the combat lane's hue remap (_ref.py is a copy of
n23-street evidence/n29/red/recolour.py), restricted to a per-file rag box. Run from the repo root:
python -I evidence/n29-keys/rag/recolour_rag.py [--dry]. Prints reddish before->after, changed px, changed outside box."""
import sys
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
import _ref as R

A = "project/features/combat/weapons/art/"
V = "project/features/characters/art/view/"
# file -> list of (y0, y1, x0, x1) boxes of the lit rag / flame
JOBS = {A + "held_55/molotov.png": [(0, 263, 440, 647)]}


def run(dry):
    for f, boxes in JOBS.items():
        a = R.load(f)
        box = np.zeros(a.shape[:2], bool)
        for y0, y1, x0, x1 in boxes:
            box[y0:y1, x0:x1] = True
        full, _ = R.remap(a)
        out = a.copy()
        out[box] = full[box]
        changed = (out != a).any(axis=2)
        outside = int((changed & ~box).sum())
        print("%s reddish(strict) %d -> %d, changed %d px, changed outside box %d"
              % (f, int(R.reddish(a).sum()), int(R.reddish(out).sum()), int(changed.sum()), outside))
        assert outside == 0
        if not dry:
            Image.fromarray(out, "RGBA").save(f, optimize=True)


run("--dry" in sys.argv)
