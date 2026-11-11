"""n15 hero it16: rivet_tour before/after: per column the % of crop px changed (non-reload columns
should be 0), and a sheet of the reload columns (6-8) of the 8 octants, before | after, per weapon.
usage: py -3 -I reload_sheet.py <out.png> <weapon>..."""
import sys
from PIL import Image, ImageChops, ImageDraw

C = 180
out, ws = sys.argv[1], sys.argv[2:]
blocks = []
for w in ws:
    a = Image.open(f"build/film/rl_{w}_before.png").convert("RGB")
    b = Image.open(f"build/film/rl_{w}_after.png").convert("RGB")
    ch = []
    for c in range(a.width // C):
        box = (c * C, 0, (c + 1) * C, a.height)
        d = ImageChops.difference(a.crop(box), b.crop(box)).convert("L").point(lambda v: 255 if v > 24 else 0)
        ch.append(100.0 * d.histogram()[255] / (C * a.height))
    print(w, "changed % per column:", " ".join(f"{v:.1f}" for v in ch))
    blk = Image.new("RGB", (C * 6 + 12, a.height + 20), (30, 30, 34))
    blk.paste(a.crop((6 * C, 0, 9 * C, a.height)), (0, 20))
    blk.paste(b.crop((6 * C, 0, 9 * C, a.height)), (3 * C + 12, 20))
    ImageDraw.Draw(blk).text((4, 4), f"{w}: reload ticks 6/30/60, 8 octants. before (110 upscaled) | after (x1.5 cut)", fill=(240, 240, 240))
    blocks.append(blk)
sheet = Image.new("RGB", (sum(x.width for x in blocks) + 10 * (len(blocks) - 1), blocks[0].height), (30, 30, 34))
x = 0
for blk in blocks:
    sheet.paste(blk, (x, 0))
    x += blk.width + 10
sheet.save(out)
print(out, sheet.size)
