"""King's gang: the rich robot thug (lane n7-king), derived from the thug's parts, no generation.

The thug's names, sizes and pivots (parts.json copied as is), so GangPlan only swaps the art dir:
    art/gang/      from art/thug/
    art/d5/gang/   from art/d5/thug/
The wealth (BOSSES.md, boss_king.jpg: "bodyguard bots in gold chains and visor shades"): a black
wraparound visor with a gold frame across the helmet's front (+x, the rig's facing) in place of
the round optic; two heavy gold chains hanging round the chest plate's front; gold knuckle rings on
the claws. No red, no vermilion (the King's cape is the only vermilion in the procession).

    python tools/art/gang_parts.py
"""

import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path("project/features/characters/art")
SETS = [("thug", "gang"), ("d5/thug", "d5/gang")]
INK = (27, 21, 23, 255)
GOLD = (217, 169, 51, 255)
GOLD_HI = (246, 214, 120, 255)
SHADE = (18, 16, 20, 255)
GLINT = (233, 220, 195, 255)
## The D4 steel lift (n7-king it5): the thug's dark steel (median luminance 74) prints as solid ink
## at 32-48 px/m under the D4 look, where the target's gang is steel grey. Grey pixels brighter than
## LIFT_FROM are scaled by LIFT_K on the D4 set only (the D5 set prints its own grime from 56 px/m);
## ink lines and gold keep their values. LIFT_K 1.0 is the old dark gang.
LIFT_FROM = 40
LIFT_K = 1.55
## Where the visor band starts across the helmet (0.30 = the old full visor).
VISOR_FROM = 0.60
## n7-king it7: a steel dome painted over the thug's round optic (the white ring and black pupil
## printed as a black disc at 32 px/m: the target's gang have steel helmets with shades at the
## front). DOME False = the it5 helmet (optic kept beside the visor band).
DOME = True
STEEL = (158, 154, 146, 255)
STEEL_HI = (206, 202, 192, 255)
HEAD = '[remap]\n\nimporter="texture"\ntype="CompressedTexture2D"\n\n[params]'


def clip_to(img, src):
    a = img.split()[3]
    s = src.convert("RGBA").split()[3]
    img.putalpha(Image.fromarray(np.minimum(np.array(a), np.array(s))))
    return img


def helmet(img):
    """A black wraparound visor across the front, a gold frame line, one paper glint."""
    w, h = img.size
    d = ImageDraw.Draw(img)
    lw = max(3, w // 30)
    if DOME:
        d.ellipse((w * 0.12, h * 0.14, w * 0.84, h * 0.86), fill=STEEL, outline=INK, width=lw)
        d.arc((w * 0.22, h * 0.24, w * 0.74, h * 0.76), 150, 250, fill=STEEL_HI, width=lw + 2)
        d.line((w * 0.20, h * 0.50, w * 0.60, h * 0.50), fill=INK, width=max(2, lw // 2))
    # it5: a front band (the helmet's steel dome reads from above; it was 0.30-0.92, a black disc)
    box = (w * VISOR_FROM, h * 0.18, w * 0.94, h * 0.82)
    d.rounded_rectangle(box, radius=w * 0.10, fill=SHADE, outline=INK, width=lw)
    d.arc((w * 0.20, h * 0.10, w * 0.95, h * 0.90), -62, 62, fill=GOLD, width=lw + 1)
    d.ellipse((w * 0.76, h * 0.26, w * 0.86, h * 0.36), fill=GLINT)
    return img


def chain(d, c, r, a0, a1, link, lw):
    """Gold links along an arc (degrees, 0 = +x the chest's front)."""
    n = max(4, int(abs(a1 - a0) * math.pi / 180 * r / (link * 1.5)))
    for i in range(n + 1):
        a = math.radians(a0 + (a1 - a0) * i / n)
        x, y = c[0] + math.cos(a) * r, c[1] + math.sin(a) * r
        d.ellipse((x - link, y - link, x + link, y + link), fill=GOLD, outline=INK, width=lw)
        d.ellipse((x - link * 0.45, y - link * 0.6, x, y - link * 0.1), fill=GOLD_HI)


def torso(img):
    """Two heavy gold chains round the chest plate's front (the head covers the neck)."""
    w, h = img.size
    d = ImageDraw.Draw(img)
    lw = max(2, w // 70)
    c = (w * 0.42, h * 0.5)
    chain(d, c, w * 0.34, -58, 58, w * 0.045, lw)
    chain(d, c, w * 0.46, -44, 44, w * 0.055, lw)
    return img


def claw(img):
    """A gold knuckle ring band across the claw's back."""
    w, h = img.size
    d = ImageDraw.Draw(img)
    lw = max(2, w // 40)
    d.rectangle((w * 0.30, h * 0.18, w * 0.42, h * 0.82), fill=GOLD, outline=INK, width=lw)
    return img


def lift(img):
    """Brighten the grey steel (low saturation, above LIFT_FROM), never the ink or the gold."""
    a = np.array(img).astype(np.float32)
    rgb = a[..., :3]
    lum = rgb.mean(axis=2)
    sat = rgb.max(axis=2) - rgb.min(axis=2)
    m = (lum > LIFT_FROM) & (sat < 40)
    rgb[m] = np.clip(rgb[m] * LIFT_K, 0, 255)
    a[..., :3] = rgb
    return Image.fromarray(a.astype(np.uint8), "RGBA")


EXTRA = {"helmet": helmet, "torso": torso, "claw_open": claw, "claw_closed": claw}


def main():
    for src_dir, dst_dir in SETS:
        s, d = ROOT / src_dir, ROOT / dst_dir
        d.mkdir(parents=True, exist_ok=True)
        (d / "parts.json").write_bytes((s / "parts.json").read_bytes())
        for png in sorted(s.glob("*.png")):
            src = Image.open(png).convert("RGBA")
            img = lift(src.copy()) if dst_dir == "gang" else src.copy()
            if png.stem in EXTRA:
                img = clip_to(EXTRA[png.stem](img), src)
            img.save(d / png.name)
            imp = d / f"{png.name}.import"
            if imp.exists():  # keep Godot's uid and path (a rewrite drops them)
                continue
            params = (s / f"{png.name}.import").read_text().split("[params]", 1)[1]
            imp.write_bytes((HEAD + params).encode())


if __name__ == "__main__":
    main()
