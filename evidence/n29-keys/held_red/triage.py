"""Triage reddish px (R>170,G<110,B<90,a>0) of weapon item art by hue band. Run: python -I triage.py files.txt out_dir"""
import sys, colorsys, json
import numpy as np
from PIL import Image, ImageDraw
files = [l.strip() for l in open(sys.argv[1]) if l.strip()]
out = sys.argv[2]

def masks(a):
    r, g, b, al = [a[..., i].astype(float) for i in range(4)]
    red = (r > 170) & (g < 110) & (b < 90) & (al > 0)
    mx = np.maximum(np.maximum(r, g), b); mn = np.minimum(np.minimum(r, g), b)
    d = mx - mn + 1e-9
    h = np.where(mx == r, ((g - b) / d) % 6, np.where(mx == g, (b - r) / d + 2, (r - g) / d + 4)) * 60
    s = d / (mx + 1e-9); v = mx / 255
    verm = red & (h >= 9) & (h <= 24) & (s > 0.6) & (v > 0.6)
    true = red & ~verm
    return red, true, verm

rows = []
for p in files:
    a = np.array(Image.open(p).convert("RGBA"))
    red, true, verm = masks(a)
    if red.sum():
        rows.append((int(true.sum()), int(verm.sum()), int(red.sum()), p))
rows.sort(reverse=True)
json.dump(rows, open(out + "/rows.json", "w"))
with open(out + "/table.md", "w") as f:
    f.write("| true-red px | vermilion px | reddish px | file |\n|---|---|---|---|\n")
    for t, v, r, p in rows:
        f.write("| %d | %d | %d | `%s` |\n" % (t, v, r, p))
    f.write("\nTOTAL true %d verm %d red %d files %d\n" % (sum(x[0] for x in rows), sum(x[1] for x in rows), sum(x[2] for x in rows), len(rows)))
# contact sheet top 20, each 4x (cap at 256 px source side by cropping to bbox of red)
top = rows[:20]
tiles = []
for i, (t, v, r, p) in enumerate(top):
    a = np.array(Image.open(p).convert("RGBA"))
    _, true, _ = masks(a)
    ys, xs = np.where(true)
    pad = 6
    y0, y1 = max(ys.min() - pad, 0), min(ys.max() + pad, a.shape[0]); x0, x1 = max(xs.min() - pad, 0), min(xs.max() + pad, a.shape[1])
    # limit crop to 128x128 around red centroid
    cy, cx = int(ys.mean()), int(xs.mean())
    y0 = max(min(y0, cy - 64), 0) if y1 - y0 > 128 else y0; y1 = min(y0 + 128, a.shape[0]) if y1 - y0 > 128 else y1
    x0 = max(min(x0, cx - 64), 0) if x1 - x0 > 128 else x0; x1 = min(x0 + 128, a.shape[1]) if x1 - x0 > 128 else x1
    c = a[y0:y1, x0:x1].copy(); m = true[y0:y1, x0:x1]
    t2 = c.copy(); t2[m] = [255, 0, 255, 255]
    def up(arr):
        im = Image.fromarray(arr).resize((arr.shape[1] * 4, arr.shape[0] * 4), Image.NEAREST)
        bg = Image.new("RGBA", im.size, (70, 70, 80, 255)); bg.alpha_composite(im); return bg
    A, B = up(c), up(t2)
    tiles.append((i, p, t, A, B))
W = 1100; H = 0; cellh = 560
sheet_w = 2 * 520 + 20
cols = 2
rowsn = (len(tiles) + 1) // 2
sheet = Image.new("RGBA", (cols * 1080, rowsn * 560), (30, 30, 36, 255))
for k, (i, p, t, A, B) in enumerate(tiles):
    ox, oy = (k % 2) * 1080, (k // 2) * 560
    A.thumbnail((520, 520)); B.thumbnail((520, 520))
    sheet.alpha_composite(A, (ox + 4, oy + 28)); sheet.alpha_composite(B, (ox + 4 + 530, oy + 28))
    ImageDraw.Draw(sheet).text((ox + 6, oy + 6), "%d %s true=%d" % (i + 1, p.split("art/")[-1], t), fill=(255, 255, 255, 255))
sheet.save(out + "/contact_4x.png")
