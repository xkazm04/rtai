"""n31 melee 02p4 part 3: the labelled before | after polar sheet of the melee hit volumes.

python tools/melee/volume_sheet.py [--before=<dir>] [--after=<dir>] [--out=<png>]

Each <dir> holds blade_volume_plot.mjs's per-weapon polar plots (<weapon>.png, 480x480, Rivet at the
centre facing right, 64 px/m). Rows: claw, chainsaw, baton, katana, plasma sword; left = before
(main), right = after (sweep); a legend of the plot's colours at the bottom.
"""

import sys

from PIL import Image, ImageDraw, ImageFont

ROWS = [
    ("hands", "claw"),
    ("chainsaw", "chainsaw"),
    ("electro_baton", "baton"),
    ("katana", "katana"),
    ("plasma_sword", "plasma\nsword"),
]
CELL, LABEL_W, HEAD_H, LEGEND_H = 480, 190, 140, 150
BG, INK, DIM_INK = (21, 23, 27), (244, 236, 216), (170, 170, 178)
# the colours blade_volume_plot.mjs draws with
HIT, CREAM, VERMILION = (140, 158, 178), (244, 236, 216), (227, 66, 52)
ICE, BOTH, DIM = (143, 211, 255), (153, 153, 153), (89, 89, 97)


def font(size):
    for name in ("arialbd.ttf", "arial.ttf", "DejaVuSans.ttf"):
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def arg(key, default):
    for a in sys.argv[1:]:
        if a.startswith("--" + key + "="):
            return a.split("=", 1)[1]
    return default


def legend(d, y, f):
    items = [
        ("ring", VERMILION, "drawn, no hit (blade shown, nobody hurt)"),
        ("ring", ICE, "hit, not drawn (hurt with no blade there)"),
        ("ring", BOTH, "drawn and hit (they agree)"),
        ("fill", HIT, "hit sector (reach + body radius inside the cone)"),
        ("line", CREAM, "drawn outline (every tick of the swing, body cut out)"),
        ("thin", DIM, "a dummy neither drawn nor hit"),
    ]
    for i, (kind, col, text) in enumerate(items):
        x = 30 + (i % 2) * 560
        yy = y + 18 + (i // 2) * 40
        if kind in ("ring", "thin"):
            d.ellipse((x, yy, x + 24, yy + 24), outline=col, width=3 if kind == "ring" else 1)
        elif kind == "fill":
            mix = tuple(round(b * 0.65 + c * 0.35) for b, c in zip(BG, col))
            d.rectangle((x, yy, x + 24, yy + 24), fill=mix)
        else:
            d.line((x, yy + 12, x + 24, yy + 12), fill=col, width=2)
        d.text((x + 36, yy + 2), text, fill=INK, font=f)


def main():
    before = arg("before", "evidence/n31-melee/01-volumes/before")
    after = arg("after", "evidence/n31-melee/02-sweep/volumes/after-2")
    out = arg("out", "evidence/n31-melee/02-sweep/volumes/before_after.png")
    w = LABEL_W + 2 * CELL
    h = HEAD_H + len(ROWS) * CELL + LEGEND_H
    sheet = Image.new("RGB", (w, h), BG)
    d = ImageDraw.Draw(sheet)
    big, mid, small = font(34), font(26), font(19)
    d.text((24, 14), "Melee hit volume vs the drawn swing", fill=INK, font=big)
    sub = "Rivet at centre facing right, 1 m rings, 60 dummies. Grey wedge = the table cone, not"
    sub += " the per-tick sweep sector;\nred rings behind him are mostly his own strike arm (an upper bound)."
    d.multiline_text((24, 52), sub, fill=DIM_INK, font=small)
    for col, title in enumerate(("before (main)", "after (sweep)")):
        tw = d.textlength(title, font=mid)
        d.text((LABEL_W + col * CELL + (CELL - tw) / 2, 104), title, fill=INK, font=mid)
    for r, (stem, name) in enumerate(ROWS):
        y = HEAD_H + r * CELL
        d.multiline_text((24, y + CELL / 2 - 16 * (name.count("\n") + 1)), name, fill=INK, font=mid)
        for col, src in enumerate((before, after)):
            sheet.paste(Image.open(f"{src}/{stem}.png").convert("RGB"), (LABEL_W + col * CELL, y))
        d.line((0, y, w, y), fill=DIM, width=1)
    legend(d, HEAD_H + len(ROWS) * CELL, small)
    sheet.save(out)
    print(f"{out} {w}x{h}")


if __name__ == "__main__":
    main()
