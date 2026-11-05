"""Cut a ghost form's Codex part sheet (3 x 2 cells on chroma green #00B140) into RGBA parts.

    python tools/art/ghost_parts.py <sheet.png> <out_dir> <name1,name2,...,name6>

Each cell's largest connected component (plus anything touching it) is one part; green keyed to
alpha with a soft edge, the green spill pulled out of the fringe, trimmed to its bbox + 2 px.
Names go in reading order (top-left first); an empty name skips the cell.
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage as ndi


def key(rgb):
    r, g, b = (rgb[..., i].astype(float) for i in range(3))
    green = g - np.maximum(r, b)
    alpha = np.clip(1.0 - (green - 30.0) / 50.0, 0.0, 1.0)
    spill = green > 0
    out = rgb.astype(float)
    out[..., 1] = np.where(spill, np.maximum(r, b), g)
    return out, alpha


def cut(sheet, out_dir, names):
    img = np.array(Image.open(sheet).convert("RGB"))
    h, w = img.shape[:2]
    rgb, alpha = key(img)
    out_dir.mkdir(parents=True, exist_ok=True)
    for idx, name in enumerate(names):
        if not name:
            continue
        r, c = divmod(idx, 3)
        y0, y1, x0, x1 = r * h // 2, (r + 1) * h // 2, c * w // 3, (c + 1) * w // 3
        a = alpha[y0:y1, x0:x1]
        lab, n = ndi.label(ndi.binary_dilation(a > 0.5, iterations=3))
        sizes = ndi.sum(a > 0.5, lab, range(1, n + 1))
        keep = lab == (int(np.argmax(sizes)) + 1)
        a = np.where(keep, a, 0.0)
        ys, xs = np.nonzero(a > 0.02)
        sy, sx = slice(max(0, ys.min() - 2), ys.max() + 3), slice(max(0, xs.min() - 2), xs.max() + 3)
        rgba = np.dstack([rgb[y0:y1, x0:x1][sy, sx], a[sy, sx] * 255.0]).clip(0, 255)
        Image.fromarray(rgba.astype(np.uint8), "RGBA").save(out_dir / f"{name}.png")
        print(name, rgba.shape[1], "x", rgba.shape[0])


if __name__ == "__main__":
    cut(sys.argv[1], Path(sys.argv[2]), sys.argv[3].split(","))
