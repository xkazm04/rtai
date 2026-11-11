"""compose.py <ghost> <out> <title> <leg:col,...>: BEFORE row over AFTER row of sweep crops."""
import csv, sys
from PIL import Image, ImageDraw
g, out, title, cells = sys.argv[1], sys.argv[2], sys.argv[3], [tuple(int(x) for x in s.split(":")) for s in sys.argv[4].split(",")]
C, K = 300, int(sys.argv[5]) if len(sys.argv) > 5 else 220  # crop the cell centre (K=300: whole cell)
a = Image.open(f"build/film/h3_{g}_before.png").convert("RGB"); b = Image.open(f"build/film/h3_{g}_after.png").convert("RGB")
rows = list(csv.DictReader(open(f"build/film/h3_{g}_after.tsv"), delimiter="\t"))
octs = {}
for r in rows:
    leg, i = int(r["leg"]), int(r["in"])
    every, off = (60, 27) if leg == 3 else (40, 0)
    if i % every == off: octs[(i // every, leg)] = int(r["oct"])
LEG = ["stand", "walk", "run", "melee"]
m = (C - K) // 2
o = Image.new("RGB", (len(cells) * (K + 6) + 70, 2 * (K + 22) + 26), (24, 24, 24)); d = ImageDraw.Draw(o)
d.text((6, 6), title, fill="white")
for j, (leg, col) in enumerate(cells):
    for i, im in enumerate((a, b)):
        x, y = 70 + j * (K + 6), 26 + i * (K + 22)
        o.paste(im.crop((col * C + m, leg * C + m, col * C + m + K, leg * C + m + K)), (x, y + 16))
        d.text((x + 2, y + 2), f"{LEG[leg]} oct {octs.get((col, leg), '-')}", fill="white")
    pass
d.text((6, 26 + 16 + K // 2), "BEFORE", fill="white"); d.text((6, 26 + K + 22 + 16 + K // 2), "AFTER", fill="white")
o.save(out); print(out, o.size)
