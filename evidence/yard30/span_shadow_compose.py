"""n30 span shadow still: before (shadow hidden) | after (shadow shown), crops of the 64 px/m stand probe round Rivet.
python -I evidence/yard30/span_shadow_compose.py <st64 dir> <label> <out png>"""
import json, sys
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont
d, lab, out = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
fr = [f for f in json.loads((d / "sample_points.json").read_text())["frames"] if f["frame"] == lab][0]
x, y = [p for p in fr["points"] if p["kind"] == "rivet"][0]["xy"]
W, H = 900, 760
box = (x - W // 2, y - H + 220, x + W // 2, y + 220)
sheet = Image.new("RGB", (2 * W + 12, H + 56), (20, 18, 22))
font = ImageFont.truetype("arial.ttf", 30)
draw = ImageDraw.Draw(sheet)
for i, (name, text) in enumerate(((f"{lab}_off.png", "before: no span shadow"), (f"{lab}.png", "after: span_shadow (alpha 0.45, 1.1 x 0.45 m)"))):
    sheet.paste(Image.open(d / name).convert("RGB").crop(box), (i * (W + 12), 56))
    draw.text((i * (W + 12) + 16, 12), text, fill=(240, 232, 213), font=font)
sheet.save(out)
print(out, sheet.size, "feet px", x, y)
