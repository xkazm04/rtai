"""Median figure height per row of a packed sheet: rowh.py <sheet.png> <cols> <rows>"""
import statistics, sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGBA"); cols, rows = int(sys.argv[2]), int(sys.argv[3])
w, h = im.width // cols, im.height // rows
out = []
for r in range(rows):
    hs = []
    for c in range(cols):
        a = im.crop((c * w, r * h, (c + 1) * w, (r + 1) * h)).split()[3].point(lambda v: 255 if v > 100 else 0)
        b = a.getbbox()
        if b: hs.append(b[3] - b[1])
    out.append(statistics.median(hs) if hs else 0)
print(sys.argv[1].split("/")[-1], f"cell {w}x{h}", " ".join(f"{x:.0f}" for x in out))
