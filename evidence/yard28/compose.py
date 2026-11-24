"""Stills composites. python -W ignore -I evidence/yard28/compose.py plate <game.png> <out.png> "<game label>"
(plate A left on #1c1c1e, game right, 3840x1080, labelled) and  ... pair <left.png> <right.png> <out.png> "<left label>" "<right label>"."""
import sys
from PIL import Image, ImageDraw, ImageFont
PLATE = "C:/Users/kazda/kiro/gtai-art/factory-n27/refs/plate_a.png"
font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 26)

mode = sys.argv[1]
if mode == "plate":
    left = Image.open(PLATE).convert("RGB"); left = left.resize((1920, round(left.height * 1920 / left.width)), Image.LANCZOS)
    canvas = Image.new("RGB", (1920, 1080), (28, 28, 30)); canvas.paste(left, (0, (1080 - left.height) // 2))
    right = Image.open(sys.argv[2]).convert("RGB"); labs = ("plate A  torn line (concept)", sys.argv[4])
    out = sys.argv[3]
else:
    canvas = Image.open(sys.argv[2]).convert("RGB"); right = Image.open(sys.argv[3]).convert("RGB")
    labs = (sys.argv[5], sys.argv[6]); out = sys.argv[4]
wide = Image.new("RGB", (3840, 1080)); wide.paste(canvas, (0, 0)); wide.paste(right, (1920, 0))
d = ImageDraw.Draw(wide, "RGBA")
for x, t in ((0, labs[0]), (1920, labs[1])):
    w = d.textlength(t, font=font); d.rectangle([x + 4, 4, x + 4 + w + 20, 44], fill=(0, 0, 0, 170)); d.text((x + 14, 8), t, fill="white", font=font)
wide.save(out)
