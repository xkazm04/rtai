"""n11 hero: pack a ghost's drawn cells into one grid for GhostDrawn.

usage: py -3 -I tools/art/ghost_pack.py <cells dir> <out.png> [--match=<walk fig_h>] [--despeck=<px>]

Cells are `{row}_{col}.png` (1-indexed, tight, transparent), rows = toward, 3/4 toward right, right
profile, 3/4 away right, away; columns = the cycle, or the act phases (wind-up, cut, follow-through,
hit). Every cell is centred on a common cell, the feet on the bottom row less PAD. With --match the
sheet is an act sheet: an arm flung out moves a tight crop, so a cell centres on its alpha's mass
instead of its box, and the whole sheet is scaled so the wind-up column's median height equals the
walk grid's (its figure carries no arc there). Prints the cell size and the median figure height.
--despeck clears alpha islands under that many px (stray marks a cut left beside the figure) and
prints what it cleared, so a wisp the size of a speck shows in the log. Deterministic.
"""

import statistics
import sys
from pathlib import Path

from PIL import Image

PAD = 2


def mass_x(im: Image.Image) -> float:
    a = im.split()[3]
    px = a.load()
    total, weight = 0.0, 0.0
    for y in range(im.height):
        for x in range(im.width):
            if px[x, y] > 100:
                total += x
                weight += 1
    return total / max(weight, 1.0)


def despeck(im: Image.Image, min_px: int) -> tuple[Image.Image, list[int]]:
    """Clear alpha islands (8-connected, alpha > 0) smaller than min_px: stray marks from a cut."""
    a = im.split()[3]
    px = a.load()
    seen, gone = set(), []
    out = im.copy()
    opx = out.load()
    for y0 in range(im.height):
        for x0 in range(im.width):
            if px[x0, y0] == 0 or (x0, y0) in seen:
                continue
            seen.add((x0, y0))
            todo, part = [(x0, y0)], []
            while todo:
                x, y = todo.pop()
                part.append((x, y))
                for nx in (x - 1, x, x + 1):
                    for ny in (y - 1, y, y + 1):
                        if 0 <= nx < im.width and 0 <= ny < im.height and px[nx, ny] > 0:
                            if (nx, ny) not in seen:
                                seen.add((nx, ny))
                                todo.append((nx, ny))
            if len(part) < min_px:
                gone.append(len(part))
                for x, y in part:
                    opx[x, y] = (0, 0, 0, 0)
    return out, gone


def main() -> None:
    src, out = Path(sys.argv[1]), Path(sys.argv[2])
    match = next((float(a.split("=")[1]) for a in sys.argv[3:] if a.startswith("--match=")), 0.0)
    speck = next((int(a.split("=")[1]) for a in sys.argv[3:] if a.startswith("--despeck=")), 0)
    cells = {}
    for f in sorted(src.glob("*.png")):
        r, c = (int(x) for x in f.stem.split("_"))
        cells[(r, c)] = Image.open(f).convert("RGBA")
        if speck:
            cells[(r, c)], gone = despeck(cells[(r, c)], speck)
            if gone:
                print(f"despeck {f.stem}: {gone}")
    rows, cols = max(k[0] for k in cells), max(k[1] for k in cells)
    if match:
        k = match / statistics.median(i.height for (r, c), i in cells.items() if c == 1)
        cells = {
            key: i.resize((max(1, round(i.width * k)), max(1, round(i.height * k))), Image.LANCZOS)
            for key, i in cells.items()
        }
        centre = {key: mass_x(i) for key, i in cells.items()}
        half = max(max(centre[key], i.width - centre[key]) for key, i in cells.items())
        w = int(half * 2) + 4
    else:
        centre = {key: i.width / 2 for key, i in cells.items()}
        w = max(i.width for i in cells.values()) + 2
    h = max(i.height for i in cells.values()) + PAD + 2
    sheet = Image.new("RGBA", (w * cols, h * rows), (0, 0, 0, 0))
    for (r, c), im in cells.items():
        box = im.getbbox() or (0, 0, im.width, im.height)
        fig = im.crop(box)
        x = round((c - 1) * w + w / 2 - centre[(r, c)] + box[0])
        y = r * h - PAD - fig.height
        sheet.paste(fig, (x, y), fig)
    out.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out)
    print(f"cell {w} {h} rows {rows} cols {cols} fig_h {statistics.median(i.height for i in cells.values())}")


if __name__ == "__main__":
    main()
