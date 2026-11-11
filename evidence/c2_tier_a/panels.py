"""N panels side by side with a label each: panels.py out.png "caption" img1 "label1" img2 "label2" ..."""
import sys
from PIL import Image, ImageDraw, ImageFont
out_path, caption, rest = sys.argv[1], sys.argv[2], sys.argv[3:]
imgs = [(Image.open(rest[k]).convert("RGB"), rest[k + 1]) for k in range(0, len(rest), 2)]
gap, head = 16, 56
w = sum(i.width for i, _ in imgs) + gap * (len(imgs) - 1)
out = Image.new("RGB", (w, max(i.height for i, _ in imgs) + head), (12, 12, 12))
d = ImageDraw.Draw(out)
try:
    f = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 20)
except OSError:
    f = ImageFont.load_default()
x = 0
for im, label in imgs:
    out.paste(im, (x, head)); d.text((x + 8, 4), label, fill=(230, 230, 230), font=f); x += im.width + gap
d.text((8, 30), caption, fill=(170, 170, 170), font=f)
out.save(out_path)
