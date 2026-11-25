"""n30 round band: counts and before|after stills. python -I band_stills.py"""
import colorsys
import json
from PIL import Image, ImageDraw

B = "C:/Users/kazda/kiro/gtai-wt/n23-street/build/n30round/"
OUT = "C:/Users/kazda/kiro/gtai-masters/n30/combat/stills/"
CREAM = (0xF2, 0xE6, 0xC4)


def is_red(r, g, b, a=255):
    h, s, v = colorsys.rgb_to_hsv(r / 255, g / 255, b / 255)
    h *= 360
    return (h <= 24 or h >= 345) and s > 0.5 and v > 0.45


def raw_red(r, g, b):
    return r > 170 and g < 110 and b < 90


def amber(r, g, b):
    return abs(r - 0xED) < 28 and abs(g - 0xAB) < 28 and abs(b - 0x42) < 40


def diff_box(a, b):
    pa, pb = a.load(), b.load()
    pts = [(x, y) for y in range(a.height) for x in range(a.width) if pa[x, y] != pb[x, y]]
    return pts


def run(name, tick, label):
    a = Image.open(f"{B}before/t{tick}.png").convert("RGB")
    b = Image.open(f"{B}after/t{tick}.png").convert("RGB")
    pts = diff_box(a, b)
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    box = (min(xs), min(ys), max(xs) + 1, max(ys) + 1)
    pad = 6
    box = (box[0] - pad, box[1] - pad, box[2] + pad, box[3] + pad)
    inbox = sum(1 for p in pts if box[0] <= p[0] < box[2] and box[1] <= p[1] < box[3])
    res = {"name": name, "tick": tick, "box": box, "diff_total": len(pts), "diff_outside_box": len(pts) - inbox}
    for tag, im in (("before", a), ("after", b)):
        c = im.crop(box)
        px = c.load()
        pix = [px[x, y] for y in range(c.height) for x in range(c.width)]
        res[tag] = {"is_red": sum(is_red(*p) for p in pix), "raw_red": sum(raw_red(*p) for p in pix), "amber": sum(amber(*p) for p in pix)}
    # sheet: full crop context (before|after) + 4x
    ctx = (max(0, box[0] - 90), max(0, box[1] - 60), min(1920, box[2] + 90), min(1080, box[3] + 60))
    s = 4
    cw, ch = (ctx[2] - ctx[0]) * s, (ctx[3] - ctx[1]) * s
    sheet = Image.new("RGB", (2 * cw + 48, ch + 100), (0x15, 0x12, 0x1A))
    d = ImageDraw.Draw(sheet)
    for i, (tag, im) in enumerate((("before (HEAD band, vermilion)", a), ("after (amber band)", b))):
        x0 = 16 + i * (cw + 16)
        d.text((x0, 8), f"{label} tick {tick} 64 px/m: {tag}", fill=CREAM)
        sheet.paste(im.crop(ctx).resize((cw, ch), Image.NEAREST), (x0, 40))
    sheet.save(OUT + f"round_band_{name}_pair_64.png")
    print(json.dumps(res))


run("rocket", 836, "rocket")
run("nuke", 1212, "nuke")
