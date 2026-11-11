"""append_cols.py <sheet.png> <cols> <rows> <cells dir> <k> <out.png>: keep a committed grid's cells
pixel for pixel and append the cells dir's columns ({row}_{n}.png) after them at scale k, each centred
on its alpha mass with its feet on the cell's bottom less PAD (ghost_pack.py's act registration).
The cell widens (evenly, both sides) and heightens (on top) only if a new cell needs it."""
import sys
from pathlib import Path
from PIL import Image
PAD = 2
sheet, cols, rows, cdir, k, out = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), Path(sys.argv[4]), float(sys.argv[5]), sys.argv[6]
im = Image.open(sheet).convert("RGBA")
w, h = im.width // cols, im.height // rows
new = {}
for f in sorted(cdir.glob("*.png")):
    r, n = (int(x) for x in f.stem.split("_"))
    c = Image.open(f).convert("RGBA")
    c = c.resize((max(1, round(c.width * k)), max(1, round(c.height * k))), Image.LANCZOS)
    new[(r, n)] = c.crop(c.getbbox())
def mass_x(c):
    a = c.split()[3].load(); t = n = 0
    for y in range(c.height):
        for x in range(c.width):
            if a[x, y] > 100: t += x; n += 1
    return t / max(n, 1)
half = max(max(mass_x(c), c.width - mass_x(c)) for c in new.values())
W = max(w, int(half * 2) + 4); W += (W - w) % 2
H = max(h, max(c.height for c in new.values()) + PAD + 2)
extra = max(n for _, n in new)
o = Image.new("RGBA", (W * (cols + extra), H * rows), (0, 0, 0, 0))
for r in range(rows):
    for c in range(cols):
        o.paste(im.crop((c * w, r * h, c * w + w, r * h + h)), (c * W + (W - w) // 2, r * H + H - h))
for (r, n), c in new.items():
    x = round((cols + n - 1) * W + W / 2 - mass_x(c))
    o.paste(c, (x, (r - 1) * H + H - PAD - c.height), c)
o.save(out)
print(out, "cell", W, H, "cols", cols + extra)
