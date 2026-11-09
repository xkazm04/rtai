"""n11 hero: pack the library's bare-claw strike cells into Rivet's strike grid (RivetStrike).

usage: py -3 -I tools/art/rivet_strike.py <library keyed/rivet dir> <art key 70|55> <out.png>

Cells `{row}_{phase}.png` (tight, transparent) in rivet_claw_strike_<art>_cells (5 right facings:
toward, 3/4 toward, profile, 3/4 away, away) and ..._left_cells (3: 3/4 toward left, left profile,
3/4 away left); phases wind-up, strike, follow-through. The grid has 8 rows in RivetFrames' base
cell order (right 0-4, left 5-7) and 3 columns. An arm flung out moves the bounding box, so a cell
registers on his collar (the hazard band: the only saturated orange on him): the collar's x on the
cell's centre, the collar's height above the foot line as the walk grid's on that facing (the walk's
median over the row), at the walk grid's scale (fig_h 110). A foot line above the cell's bottom
leaves room for a claw struck below the feet. Prints the cell, foot_px. Deterministic.
"""

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
    lib, art, out = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
    ref = walk_ref(lib, art)
    placed = []
    dirs = [(f"rivet_claw_strike_{art}_cells", ROWS_R, 0), (f"rivet_claw_strike_{art}_left_cells", ROWS_L, ROWS_R)]
    for folder, rows, base in dirs:
        for r in range(1, rows + 1):
            k, foot = ref[base + r - 1]
            for ph in range(1, PHASES + 1):
                im = load(lib / folder / f"{r}_{ph}.png")
                cx, cy = collar(im)
                small = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
                placed.append((base + r - 1, ph - 1, small, cx * k, cy * k, foot))
    half = max(max(p[3], p[2].width - p[3]) for p in placed)
    top = max(p[4] + p[5] for p in placed)  # over the foot line: the top to the collar, plus the collar's height
    bottom = max(p[2].height - p[4] - p[5] for p in placed)
    cw, foot_px = int(half * 2) + 4, int(max(bottom, 0)) + 2
    ch = int(top) + foot_px + 2
    sheet = Image.new("RGBA", (cw * PHASES, ch * (ROWS_R + ROWS_L)), (0, 0, 0, 0))
    for row, ph, small, cx, cy, foot in placed:
        x = round(ph * cw + cw / 2 - cx)
        y = round((row + 1) * ch - foot_px - foot - cy)
        sheet.alpha_composite(small, (x, y))
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"cell {cw} {ch} foot_px {foot_px}")


if __name__ == "__main__":
    main()
