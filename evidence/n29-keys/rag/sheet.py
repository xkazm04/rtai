"""Before | after 4x crop sheet of the flame cells. python -I sheet.py <after_dir_or_none> <out.png> <scale> <strip relpath>:<x0,y0,x1,y1> ..."""
import sys
sys.path.insert(0, "evidence/n29-keys/rag")
import numpy as np
from PIL import Image
import _ref as R
def comp(a):
    im = Image.fromarray(a, "RGBA"); b = Image.new("RGBA", im.size, (60, 60, 70, 255)); b.alpha_composite(im); return b
def sheet(pairs, out, s):
    rows = []
    for before, after, box in pairs:
        x0, y0, x1, y1 = box
        rows.append(np.concatenate([np.array(comp(before[y0:y1, x0:x1])), np.full((y1 - y0, 4, 4), 255, np.uint8), np.array(comp(after[y0:y1, x0:x1]))], axis=1))
    w = max(r.shape[1] for r in rows)
    rows = [np.pad(r, ((0, 4), (0, w - r.shape[1]), (0, 0)), constant_values=255) for r in rows]
    im = Image.fromarray(np.concatenate(rows, axis=0), "RGBA")
    im.resize((im.width * s, im.height * s), Image.NEAREST).save(out)
