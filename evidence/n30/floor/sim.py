"""Simulates the FX print of a cell: bilinear x k over a grey ground, the item print's nearest ink."""
import sys
import numpy as np
from PIL import Image
import os; sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from snap import C, NAMES
def sim(path, k, out=None):
    im = Image.open(path).convert('RGBA')
    big = np.asarray(im.resize((int(im.width * k), int(im.height * k)), Image.BILINEAR)).astype(float) / 255
    rgb, al = big[..., :3], big[..., 3]
    d = ((rgb[..., None, :] - C) ** 2).sum(-1); s = d.argmin(-1)
    ground = np.array([0.45, 0.43, 0.42])
    col = C[s]
    tint = al[..., None] * 0.62
    shadow = ground * (1 - tint) + C[2] * tint
    o = np.where((al >= 0.75)[..., None], col, np.where((al >= 0.02)[..., None], shadow, ground))
    v = ((al >= 0.75) & (s == 3)).sum()
    if out:
        Image.fromarray((o * 255).astype(np.uint8)).save(out)
    return int(v)
for p in sys.argv[1:]:
    print(p, {k: sim(p, k) for k in (0.5, 1.0, 3.8)})
