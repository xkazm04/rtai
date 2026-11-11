"""n15 hero it15: each delivered run16 key (odd slot) against the shipped run8 cell: the best integer
shift (dx, dy in -3..3) of the delivered cell placed as ghost_pack places it, and the px that still
differ in alpha (>32) and in colour (>24 on any channel where both are opaque) at that shift.
usage: py -3 -I key_shift.py <run8.png> <rows> <cells dir> <row0>"""
import sys
from pathlib import Path
from PIL import Image, ImageChops
s = Image.open(sys.argv[1]).convert("RGBA"); rows = int(sys.argv[2]); d = Path(sys.argv[3]); r = int(sys.argv[4])
cw, ch = s.width // 8, s.height // rows
for k in range(8):
    ship = s.crop((k * cw, r * ch, (k + 1) * cw, (r + 1) * ch))
    im = Image.open(d / f"{r + 1}_{2 * k + 1}.png").convert("RGBA")
    box = im.getbbox(); fig = im.crop(box)
    best = None
    for dx in range(-3, 4):
        for dy in range(-3, 4):
            cell = Image.new("RGBA", (cw, ch))
            cell.paste(fig, (round(cw / 2 - im.width / 2 + box[0]) + dx, ch - 2 - fig.height + dy), fig)
            a = ImageChops.difference(cell.getchannel("A"), ship.getchannel("A")).point(lambda v: 255 if v > 32 else 0)
            na = a.histogram()[255]
            if best is None or na < best[0]:
                both = ImageChops.multiply(cell.getchannel("A"), ship.getchannel("A")).point(lambda v: 255 if v > 200 else 0)
                c = ImageChops.difference(cell.convert("RGB"), ship.convert("RGB")).convert("L").point(lambda v: 255 if v > 24 else 0)
                nc = ImageChops.multiply(c, both).histogram()[255]
                best = (na, nc, dx, dy, fig.size)
    print(f"key {k + 1}: alpha {best[0]} px, colour {best[1]} px at shift ({best[2]},{best[3]}), fig {best[4]}")
