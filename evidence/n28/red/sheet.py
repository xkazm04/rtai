"""Contact sheet of the flagged cells: each on mid grey, reddish pixels (R>170,G<110,B<90) repainted green beside it.
python -I evidence/n28/red/sheet.py (from the repo root) -> evidence/n28/red/cells.png"""
import numpy as np
from PIL import Image, ImageDraw
W = "project/features/combat/weapons/art/"
ATLAS = "project/features/fx/art/fx_atlas.png"
items = [(W + "fx/flash_pistol_0.png", "flash_pistol_0"), (W + "fx/flash_smg_0.png", "flash_smg_0"),
         (W + "fx/flash_tube_0.png", "flash_tube_0"), (W + "fx/flash_nuke_0.png", "flash_nuke_0"),
         (W + "fx/blast_1.png", "blast_1"), (W + "fx/flame_1.png", "flame_1"), (W + "fx/rocket.png", "rocket"),
         (W + "plasma_sword/held_long.png", "plasma_sword held_long"), (W + "molotov/held.png", "molotov held")]
atlas = Image.open(ATLAS).convert("RGBA")
for i in (0, 1, 2, 8, 9, 10, 11, 12):
    r, c = divmod(i, 8)
    items.append((atlas.crop((c * 256, r * 256, c * 256 + 256, r * 256 + 256)), "fx_atlas cell %d" % i))
T = 180
cols = 4
rows_n = (len(items) + cols - 1) // cols
sheet = Image.new("RGB", (cols * T * 2 + 10, rows_n * (T + 22)), (70, 70, 70))
d = ImageDraw.Draw(sheet)
for n, (src, label) in enumerate(items):
    im = (Image.open(src) if isinstance(src, str) else src).convert("RGBA")
    a = np.array(im)
    mask = (a[..., 0] > 170) & (a[..., 1] < 110) & (a[..., 2] < 90) & (a[..., 3] > 0)
    m = a.copy()
    m[mask] = (0, 255, 0, 255)
    x, y = (n % cols) * T * 2, (n // cols) * (T + 22)
    for k, arr in enumerate((a, m)):
        t = Image.fromarray(arr)
        t.thumbnail((T - 4, T - 4))
        bg = Image.new("RGBA", t.size, (128, 128, 128, 255))
        bg.alpha_composite(t)
        sheet.paste(bg.convert("RGB"), (x + k * T + 2, y + 20))
    d.text((x + 4, y + 4), "%s  red=%d" % (label, int(mask.sum())), fill=(255, 255, 255))
sheet.save("evidence/n28/red/cells.png")
