"""Cut N figures from a chroma-green sheet into a strip: the background is the green CONNECTED
to the sheet border (an enclosed green, e.g. an emerald, is kept), despilled only on the edge.
usage: python -I cut_flood.py <sheet.png> <out.png> <frames> <cell_h> [tol]"""
import sys
import numpy as np
from PIL import Image
from scipy.ndimage import label, binary_dilation

KEY = np.array([0, 177, 64], dtype=np.float32)
src, dst, n, cell_h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
tol = float(sys.argv[5]) if len(sys.argv) > 5 else 70.0
a = np.asarray(Image.open(src).convert("RGB"), dtype=np.float32)
dist = np.sqrt(((a - KEY) ** 2).sum(axis=2))
lead = a[:, :, 1] - np.maximum(a[:, :, 0], a[:, :, 2])
near = (dist < tol + 30) | (lead > 60)
lab, _ = label(near)
border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
bg = np.isin(lab, list(border))
alpha = np.where(bg, np.clip((dist - tol) / 30.0, 0.0, 1.0), 1.0)
alpha[bg & (lead > 60)] = 0.0
edge = binary_dilation(bg, iterations=2) & ~bg | (bg & (alpha > 0))
rgb = a.copy()
sp = np.minimum(rgb[:, :, 1], np.maximum(rgb[:, :, 0], rgb[:, :, 2]) + 8)
rgb[:, :, 1] = np.where(edge, sp, rgb[:, :, 1])
rgba = np.dstack([rgb, alpha * 255.0]).astype(np.uint8)
solid = rgba[:, :, 3] > 128
cols = solid.sum(axis=0) > 2
spans, s0 = [], None
for x, on in enumerate(cols):
    if on and s0 is None:
        s0 = x
    elif not on and s0 is not None:
        spans.append((s0, x)); s0 = None
if s0 is not None:
    spans.append((s0, len(cols)))
spans = sorted(sorted(spans, key=lambda s: s[1] - s[0], reverse=True)[:n])
assert len(spans) == n, spans
crops = []
for x0, x1 in spans:
    rows = np.where(solid[:, x0:x1].sum(axis=1) > 0)[0]
    crops.append(rgba[rows[0]: rows[-1] + 1, x0:x1])
cw = max(c.shape[1] for c in crops) + 4
ch = max(c.shape[0] for c in crops) + 4
w = round(cw * cell_h / ch)
strip = Image.new("RGBA", (w * n, cell_h), (0, 0, 0, 0))
for i, c in enumerate(crops):
    cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    cell.paste(Image.fromarray(c), ((cw - c.shape[1]) // 2, ch - 2 - c.shape[0]))
    strip.paste(cell.resize((w, cell_h), Image.LANCZOS), (i * w, 0))
strip.save(dst)
print(f"{dst}: {n} frames of {w}x{cell_h}")
