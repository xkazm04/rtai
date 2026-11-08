"""it6: the zoom before/after pair (32 px/m left, 40 px/m right) at 1280x800, one label strip."""
import sys
from PIL import Image, ImageDraw, ImageFont

a, b, out, title = sys.argv[1:5]
A, B = Image.open(a).convert("RGB"), Image.open(b).convert("RGB")
W, H = A.size
img = Image.new("RGB", (W * 2 + 16, H + 44), (240, 232, 214))
img.paste(A, (0, 44)); img.paste(B, (W + 16, 44))
d = ImageDraw.Draw(img)
try:
    f = ImageFont.truetype("arial.ttf", 24)
except OSError:
    f = ImageFont.load_default()
d.text((12, 9), "BEFORE 32 px/m (zoom_k 1.0)  " + title, fill=(20, 20, 20), font=f)
d.text((W + 28, 9), "AFTER 40 px/m (zoom_k 1.25, tonight's handheld zoom)", fill=(20, 20, 20), font=f)
img.save(out)
