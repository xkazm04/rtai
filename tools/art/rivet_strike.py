"""n11 hero: pack the library's bare-claw strike cells into Rivet's strike grid (RivetStrike).

usage: py -3 -I tools/art/rivet_strike.py <library keyed/rivet dir> <art key 70|55> <out.png> [--scale=1.0]

Cells `{row}_{phase}.png` (tight, transparent) in rivet_claw_strike_<art>_cells (5 right facings:
toward, 3/4 toward, profile, 3/4 away, away) and ..._left_cells (3: 3/4 toward left, left profile,
3/4 away left); phases wind-up, strike, follow-through. The grid has 8 rows in RivetFrames' base
cell order (right 0-4, left 5-7) and 3 columns. An arm flung out moves the bounding box, so a cell
registers on his collar (the hazard band: the only saturated orange on him): the collar's x on the
cell's centre, the collar's height above the foot line as the walk grid's on that facing (the walk's
median over the row), at the walk grid's scale (fig_h 110). A foot line above the cell's bottom
leaves room for a claw struck below the feet. Prints the cell, foot_px. Deterministic.
"""

import argparse
import colorsys
import statistics
import sys
from pathlib import Path

from PIL import Image

FIG_H = 110.0
ROWS_R = 5
ROWS_L = 3
PHASES = 3
WALK_COLS = 8


def collar(im):
    px = im.load()
    pts = []
    for y in range(im.height):
        for x in range(im.width):
            r, g, b, a = px[x, y]
            if a < 128:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
            if h * 360 < 28 and s > 0.72 and v > 0.72:
                pts.append((x, y))
    if len(pts) < 60:
        sys.exit(f"no collar found ({len(pts)} px)")
    return statistics.median(p[0] for p in pts), statistics.median(p[1] for p in pts)


def load(path):
    im = Image.open(path).convert("RGBA")
    return im.crop(im.getbbox())


def walk_ref(lib, art):
    """Scale and per-row collar height above the feet, from the walk8 cells (right, then left)."""
    out = []
    for suffix, rows in (("", ROWS_R), ("_left", ROWS_L)):
        cells = [
            [load(lib / f"rivet_walk8_{art}{suffix}_cells" / f"{r}_{c}.png") for c in range(1, WALK_COLS + 1)]
            for r in range(1, rows + 1)
        ]
        k = FIG_H / statistics.median(c.height for row in cells for c in row)
        for row in cells:
            out.append((k, statistics.median(c.height - collar(c)[1] for c in row) * k))
    return out


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("lib", type=Path)
    parser.add_argument("art", choices=("70", "55"))
    parser.add_argument("out", type=Path)
    parser.add_argument("--scale", type=float, default=1.0)
    args = parser.parse_args()
    lib, art, out, scale = args.lib, args.art, args.out, args.scale
    ref = walk_ref(lib, art)
    placed = []
    dirs = [(f"rivet_claw_strike_{art}_cells", ROWS_R, 0), (f"rivet_claw_strike_{art}_left_cells", ROWS_L, ROWS_R)]
    for folder, rows, base in dirs:
        for r in range(1, rows + 1):
            k, foot = ref[base + r - 1]
            for ph in range(1, PHASES + 1):
                im = load(lib / folder / f"{r}_{ph}.png")
                cx, cy = collar(im)
                placed.append((base + r - 1, ph - 1, im, k, cx * k, cy * k, foot))
    # Measure the original rounded canvas in 110-space, keeping its collar and foot registration.
    half = max(max(cx, round(im.width * k) - cx) for _, _, im, k, cx, _, _ in placed)
    top = max(cy + foot for _, _, _, _, _, cy, foot in placed)
    bottom = max(round(im.height * k) - cy - foot for _, _, im, k, _, cy, foot in placed)
    foot_px = int(max(bottom, 0)) + 2
    cw = round((int(half * 2) + 4) * scale)
    ch = round((int(top) + foot_px + 2) * scale)
    foot_px *= scale
    sheet = Image.new("RGBA", (cw * PHASES, ch * (ROWS_R + ROWS_L)), (0, 0, 0, 0))
    for row, ph, im, k, cx, cy, foot in placed:
        size = (max(1, round(im.width * k * scale)), max(1, round(im.height * k * scale)))
        small = im.resize(size, Image.LANCZOS)
        x = round(ph * cw + cw / 2 - cx * scale)
        y = round((row + 1) * ch - foot_px - (foot + cy) * scale)
        sheet.alpha_composite(small, (x, y))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"cell {cw} {ch} foot_px {foot_px}")


if __name__ == "__main__":
    main()
