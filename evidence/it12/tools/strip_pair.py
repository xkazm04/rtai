"""strip_pair.py <out.png> <title> <name>:<leg>:<f,f,...> ...: BEFORE over AFTER crops of stride_film
sheets build/film/l12_<name>_{before,after}.png (260 px cells, 16 frames per leg row), same ticks."""
import sys
from PIL import Image, ImageChops, ImageDraw
C = 260
out, title, specs = sys.argv[1], sys.argv[2], sys.argv[3:]
cells = []
for s in specs:
    name, leg, fs = s.split(":")
    for f in fs.split(","):
        cells.append((name, int(leg), int(f)))
o = Image.new("RGB", (len(cells) * (C + 4) + 64, 2 * (C + 18) + 24), (24, 24, 24))
d = ImageDraw.Draw(o)
d.text((6, 6), title, fill="white")
for j, (name, leg, f) in enumerate(cells):
    ims = [Image.open(f"build/film/l12_{name}_{t}.png").convert("RGB") for t in ("before", "after")]
    box = (f * C, leg * C, f * C + C, leg * C + C)
    a, b = ims[0].crop(box), ims[1].crop(box)
    pct = sum(1 for p in ImageChops.difference(a, b).convert("L").getdata() if p > 24) / C / C * 100
    for i, im in enumerate((a, b)):
        x, y = 64 + j * (C + 4), 24 + i * (C + 18)
        o.paste(im, (x, y + 14))
        d.text((x + 2, y + 2), f"{name} leg {leg} f{f}" + (f"  {pct:.1f}%" if i else ""), fill="white")
d.text((6, 24 + C // 2), "BEFORE", fill="white")
d.text((6, 24 + C + 18 + C // 2), "AFTER", fill="white")
o.save(out)
print(out, o.size)
