"""n15 hero it14: a run16 sheet = the shipped run8 with each column twice, plus the new halfway
cells (odd 0-indexed columns) of chosen rows from a ghost_pack'd 16-column sheet. ghost_pack rounds
half-to-even, so a 16-column repack shifts some cells 1 px; composing keeps every shipped key
byte-identical.

usage: py -3 -I double_sheet.py <run8.png> <rows> <out.png> [<packed16.png> <row0>[,<row0>...]]
  e.g. double_sheet.py kerf_run8.png 5 kerf_run16.png packed.png 2   (row 2 = right profile)
       double_sheet.py kerf_run8_left.png 3 kerf_run16_left.png       (left rows doubled only)
"""

import sys

from PIL import Image

s = Image.open(sys.argv[1]).convert("RGBA")
rows = int(sys.argv[2])
n = Image.open(sys.argv[4]).convert("RGBA") if len(sys.argv) > 4 else None
fresh = {int(x) for x in sys.argv[5].split(",")} if len(sys.argv) > 5 else set()
cw, ch = s.width // 8, s.height // rows
out = Image.new("RGBA", (cw * 16, ch * rows), (0, 0, 0, 0))
for r in range(rows):
    for c in range(16):
        src, sc = (n, c) if (r in fresh and c % 2 == 1) else (s, c // 2)
        out.paste(src.crop((sc * cw, r * ch, (sc + 1) * cw, (r + 1) * ch)), (c * cw, r * ch))
out.save(sys.argv[3])
print(f"{sys.argv[3]} {out.size} fresh rows {sorted(fresh)}")
