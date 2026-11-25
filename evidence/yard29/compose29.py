"""n29: python -W ignore -I evidence/yard29/compose29.py  -> floor_i20_vs_i55_{mid,gate}_32ppm.png, floor_i55_64ppm.png (from build/films29) and the label overlay build/films29/label.png"""
from PIL import Image, ImageDraw, ImageFont
B = "build/films29/"; O = "evidence/yard29/"
font = ImageFont.truetype("C:/Windows/Fonts/arial.ttf", 26)
L20 = "i20  tint ffffff33  Rivet luminance delta 0.183"
L55 = "i55  tint ffffff8c  Rivet luminance delta 0.147"
def label(im, x, t):
    d = ImageDraw.Draw(im, "RGBA"); w = d.textlength(t, font=font)
    d.rectangle([x + 4, 4, x + 4 + w + 20, 44], fill=(0, 0, 0, 170)); d.text((x + 14, 8), t, fill="white", font=font)
for p in ("mid", "gate"):
    wide = Image.new("RGB", (3840, 1080))
    wide.paste(Image.open(f"{B}i20_{p}_32.png").convert("RGB"), (0, 0)); wide.paste(Image.open(f"{B}i55_{p}_32.png").convert("RGB"), (1920, 0))
    label(wide, 0, L20); label(wide, 1920, L55); wide.save(f"{O}floor_i20_vs_i55_{p}_32ppm.png")
im = Image.open(f"{B}i55_mid_64.png").convert("RGB"); label(im, 0, "i55  tint ffffff8c  64 px/m  Rivet on the floor between pools"); im.save(f"{O}floor_i55_64ppm.png")
for name, t in (("l", L20), ("r", L55)):
    o = Image.new("RGBA", (960, 1080), (0, 0, 0, 0)); label(o, 0, t); o.save(f"{B}label_{name}.png")
