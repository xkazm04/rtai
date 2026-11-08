"""it6: the handheld boss cam before/after at 1280x800 (left: the follow cam; right: BossCam)."""
import sys
from PIL import Image, ImageDraw, ImageFont

a, b, out, la, lb = sys.argv[1:6]
A, B = Image.open(a).convert("RGB"), Image.open(b).convert("RGB")
W, H = A.size
img = Image.new("RGB", (W * 2 + 16, H + 44), (240, 232, 214))
img.paste(A, (0, 44)); img.paste(B, (W + 16, 44))
d = ImageDraw.Draw(img)
f = ImageFont.truetype("arial.ttf", 24)
d.text((12, 9), la, fill=(20, 20, 20), font=f)
d.text((W + 28, 9), lb, fill=(20, 20, 20), font=f)
img.save(out)
