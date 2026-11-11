"""n15 hero it15: the MELEE leg row (8 cursor octants, 7 ticks after each press) of a cursor_sweep,
before over after. usage: py -3 -I lunge_pair.py <before.png> <after.png> <title> <out.png>"""
import sys
from PIL import Image, ImageDraw, ImageChops
C, N = 300, 8
a, b = Image.open(sys.argv[1]).convert("RGBA"), Image.open(sys.argv[2]).convert("RGBA")
out = Image.new("RGBA", (C * N, C * 2 + 40), (30, 30, 30, 255))
d = ImageDraw.Draw(out)
for i, (im, y) in enumerate(((a, 20), (b, C + 40))):
    out.paste(im.crop((0, 3 * C, N * C, 4 * C)), (0, y))
d.text((6, 4), "BEFORE (--ghost-lunge=off) " + sys.argv[3], fill=(255, 255, 255, 255))
d.text((6, C + 24), "AFTER, same ticks (GhostLunge)", fill=(255, 255, 255, 255))
for c in range(N):
    box = (c * C, 3 * C, (c + 1) * C, 4 * C)
    diff = ImageChops.difference(a.crop(box).convert("RGB"), b.crop(box).convert("RGB")).convert("L")
    n = sum(1 for p in diff.getdata() if p > 24)
    print(f"col {c}: {100.0 * n / (C * C):.1f} % changed")
out.convert("RGB").save(sys.argv[4])
