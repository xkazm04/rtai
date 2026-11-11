"""Side by side: before | after car_route_trails PNGs, a label strip on top. pair.py before.png after.png out.png "title" """
import sys
from PIL import Image, ImageDraw, ImageFont
a, b = Image.open(sys.argv[1]).convert("RGB"), Image.open(sys.argv[2]).convert("RGB")
gap, head = 16, 56
out = Image.new("RGB", (a.width + b.width + gap, max(a.height, b.height) + head), (12, 12, 12))
out.paste(a, (0, head)); out.paste(b, (a.width + gap, head))
d = ImageDraw.Draw(out)
try:
    f = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 20)
except OSError:
    f = ImageFont.load_default()
d.text((8, 4), "BEFORE (d720e22da, old rule: U-turn before any non-road tile)", fill=(230, 230, 230), font=f)
d.text((a.width + gap + 8, 4), "AFTER (t-4: U-turn only at void = city edge / unloaded)", fill=(230, 230, 230), font=f)
d.text((8, 30), sys.argv[4], fill=(170, 170, 170), font=f)
out.save(sys.argv[3])
