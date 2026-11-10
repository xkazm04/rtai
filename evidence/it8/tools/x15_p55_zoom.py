"""n15 hero it8: before/after crops of one p55 weapon's cursor sweep STAND leg (cols 1, 3, 6), x2,
and the per-crop changed share. usage: x15_p55_zoom.py <weapon>"""
import sys
from PIL import Image, ImageChops, ImageDraw
w = sys.argv[1]; C = 300
a = Image.open(f"build/film/p55_{w}_before.png").convert("RGB"); b = Image.open(f"build/film/p55_{w}_after.png").convert("RGB")
share = [round(100 * sum(1 for p in ImageChops.difference(a.crop((c*C, 0, (c+1)*C, C)), b.crop((c*C, 0, (c+1)*C, C))).convert("L").getdata() if p > 24) / C / C, 1) for c in range(12)]
print(w, "stand", share)
cols = [1, 3, 6]
out = Image.new("RGB", (3 * (C + 20), 2 * (C + 20)), (30, 30, 30)); d = ImageDraw.Draw(out)
for j, c in enumerate(cols):
    for i, (im, lab) in enumerate([(a, "BEFORE 110 upscaled"), (b, "AFTER x1.5 native")]):
        out.paste(im.crop((c * C, 0, (c + 1) * C, C)), (j * (C + 20), 20 + i * (C + 20)))
        d.text((j * (C + 20) + 4, 4 + i * (C + 20)), f"{lab} p55 {w}, col {c}", fill="white")
out.resize((out.width * 2, out.height * 2), Image.NEAREST).save(f"evidence/it8/rivet_x15_p55_{w}_before_after_x2_64ppm.png")
