"""n11 hero: pack a ghost's drawn walk cells into one grid for GhostDrawn.

usage: py -3 -I tools/art/ghost_pack.py <cells dir> <out.png>

Cells are `{row}_{col}.png` (1-indexed, tight, transparent), rows = toward, 3/4 toward right, right
profile, 3/4 away right, away; columns = the cycle. Every cell is centred on a common cell, the feet
on the bottom row less PAD. Prints the cell size and the median figure height. Deterministic.
"""

import statistics
import sys
from pathlib import Path

from PIL import Image

PAD = 2


def main() -> None:
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    cells = {}
    for f in sorted(src.glob("*.png")):
        r, c = (int(x) for x in f.stem.split("_"))
        cells[(r, c)] = Image.open(f).convert("RGBA")
    rows, cols = max(k[0] for k in cells), max(k[1] for k in cells)
    w = max(i.width for i in cells.values()) + 2
    h = max(i.height for i in cells.values()) + PAD + 2
    sheet = Image.new("RGBA", (w * cols, h * rows), (0, 0, 0, 0))
    for (r, c), im in cells.items():
        box = im.getbbox() or (0, 0, im.width, im.height)
        fig = im.crop(box)
        x = (c - 1) * w + (w - fig.width) // 2
        y = r * h - PAD - fig.height
        sheet.paste(fig, (x, y), fig)
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"cell {w} {h} rows {rows} cols {cols} fig_h {statistics.median(i.height for i in cells.values())}")


if __name__ == "__main__":
    main()
