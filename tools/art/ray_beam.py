"""The ray gun's round as r2_w4's beam (look lane, n5 iteration 16, 2026-11-05).

The weapon-art lane's ray round is a train of hoops (`ray_ring_0..2`, WeaponFxRay): at 64 px/m four
green rings strung back from the head. r2_w4's ray is one straight acid-green beam with a pale core
and fine green tendrils crackling along both edges. Three frames (the tendrils re-crackle per tick)
on a 320x120 canvas whose tail anchor (12,60) and 296 px span to the round head mirror the electro
arc cells, so WeaponFxRay stretches the beam back from the head like the arc. Palette tokens only:
fx_colour.json's ray family inks them (wash -> acid green, paper_2 / paper -> the pale core, ink_2
-> the tendrils' green).
n5-look iteration 18: the tendrils were short green specks beside r2_w4's halo; now inked veins
(EDGE px of ink each side) that trail back along the beam at a shallow angle, each with a fork,
reaching up to about three body half-heights (the canvas grew 80 -> 120 px for them).

    python tools/art/ray_beam.py [fx_dir]   then  python tools/art/fx_colour.py <fx_dir> <fx_dir>/colour
"""

import random
import sys
from pathlib import Path

from PIL import Image, ImageDraw

from weapon_fx import INK, INK_2, PAPER, PAPER_2, SS, WASH, _canvas, _compose, _poly, _save

W, H = 320, 120
CY = H / 2
TAIL, HEAD = 12, 308
## Band half-heights: the green body, the pale inner band, the core; the tail tapers over TAPER px.
BODY, INNER, CORE, TAPER = 13.0, 9.0, 4.5, 70
## Tendrils per edge, their reach off the band (part px), kinks each, stroke width (part px).
TENDRILS, REACH, KINKS, STROKE = 11, (20, 38), 4, 5
ROOT = 40  # the veins root this far past the taper: they trail back up to ~100 part px
EDGE = 2  # ink each side of a tendril stroke (r2_w4's tendrils are inked)
OUTLINE_PX = 9


def _band(half):
    """A beam band `half` part px thick each side, its tail a point at TAIL, its head round."""
    m = _poly(_canvas(W, H), [(TAIL, CY), (TAIL + TAPER, CY - half), (HEAD - half, CY - half),
                               (HEAD - half, CY + half), (TAIL + TAPER, CY + half)])
    cx = HEAD - half
    ImageDraw.Draw(m).ellipse([(cx - half) * SS, (CY - half) * SS, (cx + half) * SS, (CY + half) * SS], fill=255)
    return m


def _tendril(rng, x, y, side, reach):
    pts = [(x, y)]
    for k in range(KINKS):
        x += rng.uniform(-24, -12)  # the veins trail back along the beam at a shallow angle (r2_w4)
        y = CY + side * (BODY + reach * (k + 1) / KINKS) + rng.uniform(-3, 3)
        pts.append((x, y))
    return pts


def _tendrils(img, frame):
    rng = random.Random(53 + frame)
    lines = []
    for side in (-1, 1):
        for i in range(TENDRILS):
            x = TAIL + TAPER + ROOT + (HEAD - TAIL - TAPER - ROOT - 12) * (i + rng.random()) / TENDRILS
            reach = rng.uniform(*REACH)
            main = _tendril(rng, x, CY + side * (BODY - 1), side, reach)
            lines.append((main, STROKE))
            bx, by = main[1]  # a fork off the first kink, shorter and thinner
            fork = [(bx, by)] + [(bx - rng.uniform(10, 18) * (k + 1), by + side * rng.uniform(3, 7) * (k + 1)) for k in range(2)]
            lines.append((fork, STROKE - 2))
    d = ImageDraw.Draw(img)
    for pts, w in lines:
        d.line(pts, fill=INK + (255,), width=w + 2 * EDGE, joint="curve")
    for pts, w in lines:
        d.line(pts, fill=INK_2 + (255,), width=w, joint="curve")
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
