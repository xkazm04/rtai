"""n30 c23: count the nuke round's colours before|after the soot seam, and the 6x pair still.
python -I seam_stills.py <before_dir> <after_dir> [--still=<png>]
Box: t1212 = 395,328,440,401 (band.md); other ticks = before|after diff bbox + 6 px. Counts per band_stills.py:
vermilion r-max(g,b) >= 0.31 (= the is_red gate count of band.md), amber, red (is_red), teal.
"""
import json
import sys
from PIL import Image, ImageDraw

TICKS = (1206, 1212, 1218)
FIXED = {1212: (395, 328, 440, 401)}
CREAM = (0xF2, 0xE6, 0xC4)


def verm(r, g, b):
    return (r - max(g, b)) / 255 >= 0.31


def amber(r, g, b):
    return abs(r - 0xED) < 28 and abs(g - 0xAB) < 28 and abs(b - 0x42) < 40


def red(r, g, b):
    return r > 170 and g < 110 and b < 90


def teal(r, g, b):
    return abs(r - 0x1F) < 30 and abs(g - 0xB5) < 30 and abs(b - 0xA8) < 30


def counts(im, box):
    c = im.crop(box)
    pix = list(c.getdata())
    return {f.__name__: sum(f(*p) for p in pix) for f in (verm, amber, red, teal)}


def run(bdir, adir, tick):
    a = Image.open(f"{bdir}/t{tick}.png").convert("RGB")
    b = Image.open(f"{adir}/t{tick}.png").convert("RGB")
    pa, pb = a.load(), b.load()
    pts = [(x, y) for y in range(a.height) for x in range(a.width) if pa[x, y] != pb[x, y]]
    box = FIXED.get(tick)
    if box is None and pts:
        xs, ys = [p[0] for p in pts], [p[1] for p in pts]
        box = (min(xs) - 6, min(ys) - 6, max(xs) + 7, max(ys) + 7)
    out = 0 if box is None else sum(1 for x, y in pts if not (box[0] <= x < box[2] and box[1] <= y < box[3]))
    return {"tick": tick, "box": box, "diff": len(pts), "diff_outside_box": out,
            "before": counts(a, box), "after": counts(b, box)}, a, b


def still(path, res, a, b):
    box, s = res["box"], 6
    w, h = (box[2] - box[0]) * s, (box[3] - box[1]) * s
    sheet = Image.new("RGB", (2 * w + 48, h + 72), (0x15, 0x12, 0x1A))
    d = ImageDraw.Draw(sheet)
    for i, (tag, im) in enumerate((("before (HEAD)", a), ("after (soot seam)", b))):
        x0 = 16 + i * (w + 16)
        c = res[tag.split()[0]]
        d.text((x0, 8), f"t{res['tick']} 64 px/m {tag}", fill=CREAM)
        d.text((x0, 24), f"vermilion {c['verm']}  amber {c['amber']}  red {c['red']}  teal {c['teal']}", fill=CREAM)
        sheet.paste(im.crop(box).resize((w, h), Image.NEAREST), (x0, 56))
    sheet.save(path)


def main():
    bdir, adir = sys.argv[1], sys.argv[2]
    st = next((x.split("=", 1)[1] for x in sys.argv if x.startswith("--still=")), None)
    for t in TICKS:
        res, a, b = run(bdir, adir, t)
        print(json.dumps(res))
        if st and t == 1212:
            still(st, res, a, b)


main()
