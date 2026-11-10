"""n15 hero it8: soul line before/after from stride_film sheets (260 px cells, 16 a row, legs as
rows). usage: soul_compose.py <ghost>  -> evidence/it8/<ghost>_soul_line_before_after_64_32ppm.png"""
import sys
from PIL import Image, ImageDraw
g = sys.argv[1]; C = 260
picks = [(0, 0), (0, 8), (1, 0), (3, 4)]  # (leg, frame): walk right, walk toward, sprint toward
out = Image.new("RGB", (len(picks) * 2 * (C + 4) + 90, 2 * (C + 20) + 20), (24, 24, 24)); d = ImageDraw.Draw(out)
d.text((4, 4), f"n15 {g}: soul-teal outline (GhostSoulLine) off / on, stride_film same ticks; left block 64 px/m, right block 32 px/m", fill="white")
for k, ppm in enumerate(("64", "32")):
    for i, tag in enumerate(("before", "after")):
        im = Image.open(f"build/film/soul_{g}_{ppm}_{tag}.png").convert("RGB")
        for j, (leg, f) in enumerate(picks):
            x = 90 + (k * len(picks) + j) * (C + 4); y = 20 + i * (C + 20)
            out.paste(im.crop((f * C, leg * C, (f + 1) * C, (leg + 1) * C)), (x, y + 16))
            d.text((x + 2, y + 2), f"{ppm} px/m leg {leg} f{f}", fill="white")
        d.text((4, 20 + i * (C + 20) + C // 2), "OFF (before)" if i == 0 else "ON (after)", fill="white")
out.save(f"evidence/it8/{g}_soul_line_before_after_64_32ppm.png"); print(out.size)
