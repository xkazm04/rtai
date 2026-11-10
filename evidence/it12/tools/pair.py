"""pair.py <ghost>: before/after cursor-sweep crops, per-cell diff and the octant at each grab."""
import csv, sys
from PIL import Image, ImageChops, ImageDraw
g = sys.argv[1]; C = 300
a = Image.open(f"build/film/h3_{g}_before.png").convert("RGB"); b = Image.open(f"build/film/h3_{g}_after.png").convert("RGB")
rows = list(csv.DictReader(open(f"build/film/h3_{g}_after.tsv"), delimiter="\t"))
octs = {}
for r in rows:
    leg, i = int(r["leg"]), int(r["in"])
    every, off = (60, 27) if leg == 3 else (40, 0)
    if i % every == off: octs[(i // every, leg)] = (int(r["oct"]), r["frame"], r["flip"])
for leg in range(4):
    line = []
    for c in range(12):
        box = (c*C, leg*C, (c+1)*C, (leg+1)*C)
        d = sum(1 for p in ImageChops.difference(a.crop(box), b.crop(box)).convert("L").getdata() if p > 24) / C / C * 100
        o = octs.get((c, leg), ("-",))[0]
        line.append(f"{o}:{d:.1f}")
    print(g, "leg", leg, " ".join(line))
