"""Cut a chroma-green weapon sheet into flat-fill parts (weapon-art lane, 2026-11-04).

A Codex sheet holds N props in a cols x rows grid on #00B140. This keys the green (tolerance,
the backend drifts +-5 per channel), despills the rim, groups every opaque blob into its grid
cell by centroid, crops each cell to its alpha with a margin and writes `<id>.png`.

    python tools/art/weapon_cut.py <sheet.png> <cols> <rows> <out_dir> <id1,id2,...> [--icon]

`--icon` also writes `<id>_icon.png`: the silhouette as a cream fill in a bold ink ring (the HUD).
Prints one JSON line per part: id, size_px, bbox in the sheet.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter
from scipy import ndimage

INK = (27, 21, 23)
PAPER = (242, 232, 213)
MARGIN = 6


def key(rgb):
    r, g, b = (rgb[..., i].astype(np.int32) for i in range(3))
    green = (g > 90) & (g - np.maximum(r, b) > 55)
    alpha = np.where(green, 0, 255).astype(np.uint8)
    # soften one px and despill: pull g down to max(r, b) on the rim
    a = np.array(Image.fromarray(alpha).filter(ImageFilter.MinFilter(3)))
    out = rgb.copy()
    spill = g > np.maximum(r, b)
    out[..., 1] = np.where(spill, np.maximum(r, b), g).astype(np.uint8)
    return out, a


def cells(alpha, cols, rows):
    h, w = alpha.shape
    lab, n = ndimage.label(alpha > 0)
    cell_of = np.zeros(n + 1, dtype=np.int32) - 1
    sizes = ndimage.sum(alpha > 0, lab, range(1, n + 1))
    cents = ndimage.center_of_mass(alpha > 0, lab, range(1, n + 1))
    for i, ((cy, cx), sz) in enumerate(zip(cents, sizes), start=1):
        if sz < 40:
            continue
        c = min(cols - 1, int(cx / (w / cols)))
        r = min(rows - 1, int(cy / (h / rows)))
        cell_of[i] = r * cols + c
    return lab, cell_of


def icon(rgba):
    a = _fill_small_holes(rgba[..., 3] > 0, 900).astype(np.uint8) * 255
    big = np.array(Image.fromarray(a).filter(ImageFilter.MaxFilter(9)))
    out = np.zeros_like(rgba)
    out[big > 0] = INK + (255,)
    inner = np.array(Image.fromarray(a).filter(ImageFilter.MinFilter(5)))
    out[inner > 0] = PAPER + (255,)
    return out


def _fill_small_holes(solid, max_px):
    holes = ndimage.binary_fill_holes(solid) & ~solid
    lab, n = ndimage.label(holes)
    if n == 0:
        return solid
    sizes = ndimage.sum(holes, lab, range(1, n + 1))
    small = np.isin(lab, [i + 1 for i, sz in enumerate(sizes) if sz < max_px])
    return solid | small


def main(argv):
    sheet, cols, rows, dst, ids = argv[0], int(argv[1]), int(argv[2]), Path(argv[3]), argv[4].split(",")
    make_icon = "--icon" in argv
    rgb = np.array(Image.open(sheet).convert("RGB"))
    rgb, alpha = key(rgb)
    lab, cell_of = cells(alpha, cols, rows)
    dst.mkdir(parents=True, exist_ok=True)
    for idx, pid in enumerate(ids):
        if pid == "-":
            continue
        keep = np.isin(lab, np.nonzero(cell_of == idx)[0]) & (alpha > 0)
        ys, xs = np.nonzero(keep)
        y0, y1 = max(0, ys.min() - MARGIN), min(rgb.shape[0], ys.max() + MARGIN + 1)
        x0, x1 = max(0, xs.min() - MARGIN), min(rgb.shape[1], xs.max() + MARGIN + 1)
        rgba = np.dstack([rgb, np.where(keep, alpha, 0)])[y0:y1, x0:x1].astype(np.uint8)
        Image.fromarray(rgba, "RGBA").save(dst / f"{pid}.png")
        if make_icon:
            pad = np.pad(rgba, ((8, 8), (8, 8), (0, 0)))
            Image.fromarray(icon(pad), "RGBA").save(dst / f"{pid}_icon.png")
        print(json.dumps({"id": pid, "size_px": [int(x1 - x0), int(y1 - y0)], "bbox": [int(x0), int(y0), int(x1), int(y1)]}))


if __name__ == "__main__":
    main(sys.argv[1:])
