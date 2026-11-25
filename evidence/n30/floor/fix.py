"""Recolour blast_1's amber->ink blends. python -I fix.py <in.png> <out.png> <mode: opaque|half>"""
import sys
import numpy as np
from PIL import Image
A = np.array([232, 159, 42.0]); I = np.array([27, 21, 23.0])
def fix(src, dst, mode):
    a = np.asarray(Image.open(src).convert('RGBA')).astype(np.float64)
    rgb, al = a[..., :3], a[..., 3]
    d = I - A
    t = ((rgb - A) * d).sum(-1) / (d * d).sum()
    # distance from the A-I line: only texels on it (amber/ink blends) move; cream and its blends keep
    off = np.linalg.norm(rgb - (A + t[..., None] * d), axis=-1)
    blend = (al >= 191) & (off < 18) & (t > 0.08) & (t < 0.8)
    inkish = (al >= 191) & (off < 18) & (t >= 0.8)
    amber = (al >= 191) & (off < 18) & (t <= 0.08)
    def near(m):
        p = np.pad(m, 1)
        return sum(p[1 + dy:1 + dy + m.shape[0], 1 + dx:1 + dx + m.shape[1]] for dy in (-1, 0, 1) for dx in (-1, 0, 1)) > 0
    edge = (blend & near(inkish)) | (amber & near(inkish)) | (blend & near(blend & near(inkish)))
    speck = blend & ~edge
    out = a.copy()
    out[speck, :3] = A
    if mode == 'opaque':
        out[edge, :3] = (120, 110, 105)
    else:
        out[edge, :3] = (128, 118, 118); out[edge, 3] = 128
    Image.fromarray(np.clip(np.rint(out), 0, 255).astype(np.uint8), 'RGBA').save(dst)
    print(dst, 'specks->amber', int(speck.sum()), 'edge->soot', int(edge.sum()), 'unchanged ink-ish', int(inkish.sum()))
fix(sys.argv[1], sys.argv[2], sys.argv[3])
