"""Sheet-level palette and fringe measure for a cast card, with Mulroney's sheets as the baseline.

Fringe: each cell is resampled to the drawn size at 64 px/m (premultiplied, bilinear). A fringe
pixel has alpha in (0, 0.5) and an unpremultiplied colour below 64. Reported per cell, mean.
This is a sheet proxy: the live-frame rim of cast_mulroney_edge.py needs frozen street frames.
Palette: blue = b > r + 30 and b > g + 10 on solid pixels; blood = r > 120, g < 60, b < 60.
usage: python tools/art/cast_warden_edge.py [prefix ...]  (default appliance_warden sergeant_mulroney)
"""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

VIEW = Path("project/features/characters/art/view")
ROWS = {"walk": 4, "attack": 4, "hit": 1, "fall": 5, "planted8_armed_walk": 8}
HEIGHT = {"p70": 1.0, "p55": 1.0}
CELL = 192.0
PPM = 64.0


def rows_of(name):
    stem = name[:-4]
    for key in ("planted8_armed_walk", "fall", "hit", "attack"):
        if stem.endswith(key):
            return ROWS[key]
    return 4


def cells(path):
    im = Image.open(path).convert("RGBA")
    rows = rows_of(path.name)
    w, h = im.width // 5, im.height // rows
    for r in range(rows):
        for c in range(5):
            yield im.crop((c * w, r * h, (c + 1) * w, (r + 1) * h))


def measure(path, scale):
    fringe, blue, blood, solid, n = 0, 0, 0, 0, 0
    for tile in cells(path):
        a = np.asarray(tile, dtype=np.float32)
        if a[..., 3].max() == 0:
            continue
        n += 1
        pm = a.copy()
        pm[..., :3] *= pm[..., 3:] / 255.0
        small = Image.fromarray(pm.astype(np.uint8), "RGBA").resize(
            (max(1, round(tile.width * scale)), max(1, round(tile.height * scale))), Image.BILINEAR)
        s = np.asarray(small, dtype=np.float32)
        alpha = s[..., 3] / 255.0
        rgb = np.where(alpha[..., None] > 0, s[..., :3] / np.maximum(alpha[..., None], 1e-3), 0)
        edge = (alpha > 0) & (alpha < 0.5) & (rgb.max(2) < 64)
        fringe += int(edge.sum())
        full = np.asarray(tile, dtype=int)
        m = full[..., 3] >= 128
        r, g, b = full[..., 0], full[..., 1], full[..., 2]
        solid += int(m.sum())
        blue += int((m & (b > r + 30) & (b > g + 10)).sum())
        blood += int((m & (r > 120) & (g < 60) & (b < 60)).sum())
    return n, fringe / max(n, 1), blue, blood, solid


def main(prefixes):
    for prefix in prefixes:
        for pitch in ("p70", "p55"):
            for path in sorted((VIEW / pitch).glob(f"{prefix}_*.png")):
                scale = PPM * 1.6 / CELL * (1.0 if "planted8" not in path.name else 0.75)
                n, fringe, blue, blood, solid = measure(path, scale)
                print(f"{pitch} {path.name:46s} cells {n:3d} fringe/cell {fringe:7.2f} "
                      f"blue {blue:6d} ({100*blue/max(solid,1):5.2f}%) blood {blood:6d} ({100*blood/max(solid,1):5.3f}%)")


if __name__ == "__main__":
    main(sys.argv[1:] or ["appliance_warden", "sergeant_mulroney"])
