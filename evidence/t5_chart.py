"""Paired dot plot of t5_aab.tsv: per round, B-A (HW 132 vs 80) and A2-A (A/A noise floor); two panels, own axes."""
import csv, sys
from PIL import Image, ImageDraw, ImageFont
rows = list(csv.DictReader(open(sys.argv[1]), delimiter="\t"))
by = {}
for r in rows:
    by.setdefault(r["round"], {})[r["arm"]] = (float(r["gd_ms"]), float(r["native_ms"]) * 1000)
SURF, INK, INK2, GRID = (252, 252, 251), (11, 11, 11), (82, 81, 78), (226, 225, 221)
BLUE, ORANGE = (42, 120, 214), (235, 104, 52)
F = lambda s: ImageFont.truetype("C:/Windows/Fonts/segoeui.ttf", s)
W, H = 1400, 560
img = Image.new("RGB", (W, H), SURF); d = ImageDraw.Draw(img)
d.text((40, 16), "t-5 hash window HW 80 -> 132: extra cost per sim step, 6 paired rounds (CONTENDED machine)", fill=INK, font=F(26))
d.text((40, 54), "Each dot = one round's difference from arm A (HW 80). B-A is the change; A2-A is the same build run twice (noise floor).", fill=INK2, font=F(18))
def panel(x0, k, unit, title, lo, hi, step):
    y0, y1, pw = 150, 470, 600
    d.text((x0, 104), title, fill=INK, font=F(22))
    sx = lambda v: x0 + 70 + (v - lo) / (hi - lo) * (pw - 90)
    v = lo
    while v <= hi + 1e-9:
        X = sx(v); d.line([(X, y0), (X, y1)], fill=GRID if abs(v) > 1e-9 else INK2, width=1 if abs(v) > 1e-9 else 2)
        d.text((X - 14, y1 + 8), f"{v:g}", fill=INK2, font=F(16)); v += step
    d.text((x0 + 70 + (pw - 90) / 2 - 40, y1 + 34), unit, fill=INK2, font=F(16))
    for row, (arm, col, name) in enumerate([("B", BLUE, "B - A  (HW 132)"), ("A2", ORANGE, "A2 - A (A/A)")]):
        y = y0 + 80 + row * 160
        d.text((x0, y - 50), name, fill=INK, font=F(18))
        vals = sorted(by[r][arm][k] - by[r]["A"][k] for r in by)
        for i, val in enumerate(vals):
            X, Y = sx(val), y + (i % 3 - 1) * 12
            d.ellipse([X - 7, Y - 7, X + 7, Y + 7], fill=col, outline=SURF, width=2)
        med = (vals[2] + vals[3]) / 2
        d.line([(sx(med), y - 26), (sx(med), y + 26)], fill=INK, width=2)
        d.text((sx(med) + 6, y - 44), f"median {med:+.2f}", fill=INK, font=F(16))
panel(40, 0, "ms per step (A median 4.43 ms)", "GDScript reference sim", -0.6, 1.2, 0.3)
panel(720, 1, "us per step (A median 52 us)", "Native sim (shipped)", -10, 16, 5)
img.save(sys.argv[2])
