"""The ray gun's round as r2_w4's beam (look lane, n5 iteration 16, 2026-11-05).

The weapon-art lane's ray round is a train of hoops (`ray_ring_0..2`, WeaponFxRay): at 64 px/m four
green rings strung back from the head. r2_w4's ray is one straight acid-green beam with a pale core
and fine green tendrils crackling along both edges. Three frames (the tendrils re-crackle per tick)
on a 320x80 canvas whose tail anchor (12,40) and 296 px span to the round head mirror the electro
arc cells, so WeaponFxRay stretches the beam back from the head like the arc. Palette tokens only:
fx_colour.json's ray family inks them (wash -> acid green, paper_2 / paper -> the pale core, ink_2
-> the tendrils' green).

    python tools/art/ray_beam.py [fx_dir]   then  python tools/art/fx_colour.py <fx_dir> <fx_dir>/colour
"""

import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw

from weapon_fx import INK_2, PAPER, PAPER_2, SS, WASH, _canvas, _compose, _poly, _save

W, H = 320, 80
CY = H / 2
TAIL, HEAD = 12, 308
## Band half-heights: the green body, the pale inner band, the core; the tail tapers over TAPER px.
BODY, INNER, CORE, TAPER = 13.0, 9.0, 4.5, 70
## Tendrils per edge, their reach off the band (part px), kinks each, stroke width (part px).
TENDRILS, REACH, KINKS, STROKE = 12, (12, 25), 3, 6
OUTLINE_PX = 9


def _band(half):
    """A beam band `half` part px thick each side, its tail a point at TAIL, its head round."""
    m = _poly(_canvas(W, H), [(TAIL, CY), (TAIL + TAPER, CY - half), (HEAD - half, CY - half),
                               (HEAD - half, CY + half), (TAIL + TAPER, CY + half)])
    cx = HEAD - half
    ImageDraw.Draw(m).ellipse([(cx - half) * SS, (CY - half) * SS, (cx + half) * SS, (CY + half) * SS], fill=255)
    return m


def _tendrils(img, frame):
    rng = random.Random(53 + frame)
    d = ImageDraw.Draw(img)
    for side in (-1, 1):
        for i in range(TENDRILS):
            x = TAIL + TAPER + (HEAD - TAIL - TAPER - 20) * (i + rng.random()) / TENDRILS
            y = CY + side * (BODY - 1)
            pts = [(x, y)]
            reach = rng.uniform(*REACH)
            for k in range(KINKS):
                x += rng.uniform(-9, 5)  # the tendrils trail back from the head a little
                y = CY + side * (BODY + reach * (k + 1) / KINKS) + rng.uniform(-2, 2)
                pts.append((x, y))
            d.line(pts, fill=INK_2 + (255,), width=STROKE, joint="curve")
    return img


def ray_beam(out, frame, seed):
    layers = [(_band(BODY), WASH), (_band(INNER), PAPER_2), (_band(CORE), PAPER)]
    beam = _compose(layers, W, H, seed + frame, outline=OUTLINE_PX)
    under = _tendrils(Image.new("RGBA", beam.size, (0, 0, 0, 0)), frame)
    under.alpha_composite(beam)
    _save(under, out / f"ray_beam_{frame}.png")
    return [W, H], [TAIL, int(CY)]


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    for f in range(3):
        print(f"ray_beam_{f}", *ray_beam(fx_dir, f, 43))
