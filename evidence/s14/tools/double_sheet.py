"""n15 hero it14: a run16 sheet = the shipped run8 with each column twice, plus the new halfway
cells (odd 0-indexed columns) of chosen rows. ghost_pack rounds half-to-even, so a 16-column repack
shifts some cells 1 px; composing keeps every shipped key byte-identical.

usage: py -3 -I double_sheet.py <run8.png> <rows> <out.png> [<new> <row0>[,<row0>...] [<pad px>]]
  <pad px> widens every cell by that much a side (a halfway frame wider than the run8's cell); the
  cells keep their centres, so the sprite's feet offset does not move.
  <new> a ghost_pack'd 16-column sheet at the run8's cell, or a cells dir (`<row>_<col>.png`,
  1-indexed, 16 columns, tight crops at the run8's scale): a cell is placed as ghost_pack places a
  column-1 cell (centred by its box, feet on the cell bottom less PAD), and the dir's odd-slot keys
  are checked against the shipped cells first (prints each key's differing px count).
  e.g. double_sheet.py kerf_run8.png 5 kerf_run16.png packed.png 2   (row 2 = right profile)
       double_sheet.py kerf_run8_left.png 3 kerf_run16_left.png       (left rows doubled only)
"""

import sys
from pathlib import Path

from PIL import Image, ImageChops

PAD = 2

s = Image.open(sys.argv[1]).convert("RGBA")
rows = int(sys.argv[2])
cw, ch = s.width // 8, s.height // rows
src = Path(sys.argv[4]) if len(sys.argv) > 4 else None
fresh = {int(x) for x in sys.argv[5].split(",")} if len(sys.argv) > 5 else set()
pad = int(sys.argv[6]) if len(sys.argv) > 6 else 0


def placed(path: Path) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    box = im.getbbox() or (0, 0, im.width, im.height)
    fig = im.crop(box)
    cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
    cell.paste(fig, (round(cw / 2 - im.width / 2 + box[0]), ch - PAD - fig.height), fig)
    return cell


def placed_wide(path: Path) -> Image.Image:
    """The cell at the padded width (nothing clipped), centred as placed() centres it."""
    im = Image.open(path).convert("RGBA")
    box = im.getbbox() or (0, 0, im.width, im.height)
    fig = im.crop(box)
    cell = Image.new("RGBA", (cw + 2 * pad, ch), (0, 0, 0, 0))
    x = pad + round(cw / 2 - im.width / 2 + box[0])
    cell.paste(fig, (x, ch - PAD - fig.height), fig)
    return cell


def new_cell(r: int, c: int) -> Image.Image:
    if src is not None and src.is_dir():
        return placed(src / f"{r + 1}_{c + 1}.png")
    n = Image.open(src).convert("RGBA")
    return n.crop((c * cw, r * ch, (c + 1) * cw, (r + 1) * ch))


W = cw + 2 * pad
out = Image.new("RGBA", (W * 16, ch * rows), (0, 0, 0, 0))
for r in range(rows):
    for c in range(16):
        key = s.crop((c // 2 * cw, r * ch, (c // 2 + 1) * cw, (r + 1) * ch))
        if r in fresh and src is not None and src.is_dir() and c % 2 == 0:
            d = ImageChops.difference(key, new_cell(r, c))
            print(f"row {r} key {c + 1}: {sum(1 for p in d.getdata() if max(p) > 0)} px differ")
        if r in fresh and c % 2 == 1 and src.is_dir():
            out.paste(placed_wide(src / f"{r + 1}_{c + 1}.png"), (c * W, r * ch))
        else:
            out.paste(new_cell(r, c) if (r in fresh and c % 2 == 1) else key, (c * W + pad, r * ch))
out.save(sys.argv[3])
print(f"{sys.argv[3]} {out.size} cell {W}x{ch} (run8 {cw}, pad {pad}) fresh rows {sorted(fresh)}")
