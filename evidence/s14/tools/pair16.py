"""n15 hero it14: before/after sheet + slowed side-by-side clip of one stride_film leg.
usage: py -3 -I pair16.py <before prefix> <after prefix> <leg> <title> <out.png> <out.gif> [crop]"""
import sys
from PIL import Image, ImageDraw
bp, ap, leg, title, op, og = sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], sys.argv[5], sys.argv[6]
c = int(sys.argv[7]) if len(sys.argv) > 7 else 260
a, b = Image.open(bp + ".png"), Image.open(ap + ".png")
out = Image.new("RGBA", (c * 16, c * 2 + 40), (30, 30, 30, 255))
d = ImageDraw.Draw(out)
out.paste(a.crop((0, leg * c, 16 * c, (leg + 1) * c)), (0, 20))
out.paste(b.crop((0, leg * c, 16 * c, (leg + 1) * c)), (0, c + 40))
d.text((6, 4), "BEFORE " + title, fill=(255, 255, 255, 255))
d.text((6, c + 24), "AFTER, same ticks", fill=(255, 255, 255, 255))
out.save(op)
fr = []
for f in range(16):
    o = Image.new("RGB", (c * 2, c))
    o.paste(Image.open(f"{bp}_{leg}_{f:02d}.png").convert("RGB"), (0, 0))
    o.paste(Image.open(f"{ap}_{leg}_{f:02d}.png").convert("RGB"), (c, 0))
    fr.append(o)
fr[0].save(og, save_all=True, append_images=fr[1:], duration=125, loop=0)
out.crop((0, 0, c * 8, out.height)).save(op.replace(".png", "_a.png"))
