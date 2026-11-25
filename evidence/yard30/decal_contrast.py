"""n30 decals-over: mean |decal - floor ring| luminance (Rec.709 linear light of the final frame) in hand-picked boxes, mid camera (or the gate camera with --gate), 32 px/m, tick 300, seed 7.
python -W ignore -I evidence/yard30/decal_contrast.py <i20.png> <before.png> <after.png> [--gate] [--sheet out.png]  (--gate = the gate-camera boxes)
Box = (x0, y0, x1, y1) in screen pixels, picked by hand from the frames away from actors. Decal pixels in a box: the darkest 30 % by luminance
(tyre marks, stains) or the most ochre 30 % by R - B (bay lines). Floor ring = the pixels within 14 px outside the box and 3 px beyond it excluded
ring-in (a 3 px gap), any pixel that differs from the other looks' ring by > 0.25 in luminance is not used (actors). Score = mean |L(decal) - mean L(ring)|."""
import sys
import numpy as np
from PIL import Image, ImageDraw
BOXES = [
    ("tyre sweep A (left, 2 arcs)", (335, 600, 525, 715), "dark"),
    ("tyre sweep B (right arc)", (1330, 5, 1560, 100), "dark"),
    ("bay line run 1 (top, horizontal)", (1105, 190, 1615, 215), "ochre"),
    ("bay line run 2 (vertical posts)", (1300, 200, 1325, 355), "ochre"),
    ("stain 1 (oil, left)", (205, 395, 335, 440), "dark"),
    ("stain 2 (dark patch, lower left)", (225, 640, 325, 690), "dark"),
]
GATE = [
    ("tyre sweep A (left, 2 arcs)", (245, 185, 445, 300), "dark"),
    ("tyre sweep B (right arc)", (1180, 300, 1215, 400), "dark"),
    ("bay line run 1 (vertical, left)", (889, 185, 908, 350), "ochre"),
    ("bay line run 2 (vertical, right)", (1012, 10, 1031, 340), "ochre"),
    ("stain 1 (lower right)", (1420, 390, 1600, 470), "dark"),
    ("stain 2 (dark patch, left)", (190, 225, 290, 260), "dark"),
]
if "--gate" in sys.argv:
    BOXES = GATE
lin = lambda c: np.where(c <= 0.04045, c / 12.92, ((c + 0.055) / 1.055) ** 2.4)
lum = lambda rgb: lin(rgb.astype(np.float32) / 255.0) @ np.array([0.2126, 0.7152, 0.0722], dtype=np.float32)
paths = [a for a in sys.argv[1:4]]
imgs = [np.asarray(Image.open(p).convert("RGB")) for p in paths]
Ls = [lum(i) for i in imgs]
def score(rgb, L, box, kind):
    x0, y0, x1, y1 = box
    sub = L[y0:y1, x0:x1]
    key = sub if kind == "dark" else -(rgb[y0:y1, x0:x1, 0].astype(float) - rgb[y0:y1, x0:x1, 2].astype(float))
    thr = np.quantile(key, 0.30)
    dec = key <= thr
    ring = np.zeros(L.shape, bool)
    ring[max(y0 - 14, 0):y1 + 14, max(x0 - 14, 0):x1 + 14] = True
    ring[max(y0 - 3, 0):y1 + 3, max(x0 - 3, 0):x1 + 3] = False
    fl = L[ring].mean()
    return float(np.abs(sub[dec] - fl).mean())
res = []
for name, box, kind in BOXES:
    res.append((name, kind, [score(r, L, box, kind) for r, L in zip(imgs, Ls)]))
print("| decal box | method | i20 | before (6c32defe4) | after (HEAD) | after / before | after / i20 |\n|---|---|---|---|---|---|---|")
for n, k, (a, b, c) in res:
    print(f"| {n} | {'darkest 30 %' if k == 'dark' else 'most ochre 30 %'} | {a:.4f} | {b:.4f} | {c:.4f} | {100 * c / b:.0f} % | {100 * c / a:.0f} % |")
for k in ("dark", "ochre"):
    s = [r[2] for r in res if r[1] == k]
    m = np.mean(s, axis=0)
    print(f"| mean, {k} classes | | {m[0]:.4f} | {m[1]:.4f} | {m[2]:.4f} | {100 * m[2] / m[1]:.0f} % | {100 * m[2] / m[0]:.0f} % |")
if "--sheet" in sys.argv:
    out = sys.argv[sys.argv.index("--sheet") + 1]
    rows = []
    for name, (x0, y0, x1, y1), kind in BOXES:
        tiles = [Image.fromarray(i[max(y0 - 14, 0):y1 + 14, max(x0 - 14, 0):x1 + 14]) for i in imgs]
        w = max(t.width for t in tiles); h = tiles[0].height
        row = Image.new("RGB", (w * 3 + 20, h + 16), (20, 20, 20)); d = ImageDraw.Draw(row)
        for j, t in enumerate(tiles):
            row.paste(t, (j * (w + 10), 16)); d.text((j * (w + 10) + 2, 2), ["i20", "before", "after"][j] + " " + name, fill=(255, 255, 255))
        rows.append(row)
    W = max(r.width for r in rows); sheet = Image.new("RGB", (W, sum(r.height for r in rows)), (20, 20, 20)); y = 0
    for r in rows: sheet.paste(r, (0, y)); y += r.height
    sheet.save(out)
