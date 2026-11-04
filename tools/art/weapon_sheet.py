"""Weapon design sheet from the shipped art (weapon-art lane evidence, not a game asset).

Per weapon one row: the top-down held part with its grip (vermilion ring) and muzzle (ink cross)
marked, the side-view pickup, the HUD icon, the muzzle-flash frames, and the held part at its
true 32 px/m and 64 px/m size (nearest-upscaled 4x so the read is visible). The T2 concept sits
on the left for style.

    python tools/art/weapon_sheet.py <out.png> [<concept.jpg>]
"""

import json
import sys
from pathlib import Path

from PIL import Image, ImageDraw

ROOT = Path("project")
PAPER = (242, 232, 213)
INK = (27, 21, 23)
VERM = (232, 80, 42)
ROW_H = 190


def res(p):
    return ROOT / p.replace("res://", "")


def fit(im, w, h):
    k = min(w / im.width, h / im.height)
    return im.resize((max(1, int(im.width * k)), max(1, int(im.height * k))), Image.LANCZOS), k


def tiny(im, length_px, length_m, ppm):
    k = length_m * ppm / length_px
    t = im.resize((max(1, round(im.width * k)), max(1, round(im.height * k))), Image.LANCZOS)
    return t.resize((t.width * 4, t.height * 4), Image.NEAREST)


def main(out, concept=None):
    table = json.loads((ROOT / "data/tables/weapon_art.json").read_text())
    fx = {r["id"]: r for r in table["fx"]}
    rows = table["weapons"]
    left = 420 if concept else 0
    sheet = Image.new("RGB", (left + 2150, 70 + ROW_H * len(rows)), PAPER)
    d = ImageDraw.Draw(sheet)
    d.text((left + 10, 10), "RTAI weapon art (n-weapon-art): held top-down + grip/muzzle | pickup (side) | HUD icon | muzzle flash | held at 32 and 64 px/m (4x nearest)", fill=INK)
    if concept:
        c, _ = fit(Image.open(concept).convert("RGB"), 400, 70 + ROW_H * len(rows) - 20)
        sheet.paste(c, (10, 40))
    for i, w in enumerate(rows):
        y = 40 + i * ROW_H
        d.text((left + 10, y), f"{w['id']}  ({w['grip_class']}, {w['length_m']} m)", fill=INK)
        held = Image.open(res(w["held"])).convert("RGBA")
        h2, k = fit(held, 400, 140)
        x0, y0 = left + 10, y + 20
        sheet.paste(h2, (x0, y0), h2)
        gx, gy = w["grip_px"][0] * k + x0, w["grip_px"][1] * k + y0
        mx, my = w["muzzle_px"][0] * k + x0, w["muzzle_px"][1] * k + y0
        d.ellipse([gx - 7, gy - 7, gx + 7, gy + 7], outline=VERM, width=3)
        d.line([mx - 7, my, mx + 7, my], fill=INK, width=2)
        d.line([mx, my - 7, mx, my + 7], fill=INK, width=2)
        x = left + 430
        for key, box in (("pickup", (300, 150)), ("icon", (220, 120))):
            im, _ = fit(Image.open(res(w[key])).convert("RGBA"), *box)
            sheet.paste(im, (x, y + 20), im)
            x += box[0] + 20
        for f in range(3):
            cell = fx.get(f"{w['muzzle_fx']}_{f}")
            if cell:
                im, _ = fit(Image.open(res(cell["art"])).convert("RGBA"), 110, 110)
                sheet.paste(im, (x, y + 30), im)
                x += 115
        x = max(x, left + 1340)
        for ppm in (32, 64):
            t = tiny(held, w["length_px"], w["length_m"], ppm)
            sheet.paste(t, (x, y + 40), t)
            x += t.width + 20
    sheet.save(out)
    print(f"wrote {out}")


if __name__ == "__main__":
    main(*sys.argv[1:3])
