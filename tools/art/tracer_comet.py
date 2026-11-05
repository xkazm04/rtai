"""Rivet's bullet tracer as r2_w4's comet (look lane, n5 iteration 14, 2026-11-05).

The weapon-art lane's `tracer` (tools/art/bullet_tracer.py) is a spear head: a body widening from a
thin tail to a fat pointed head, a hot streak inside. At 64 px/m in the colour print it reads as a
gold blade as long as Rivet. r2_w4's rounds are comets: a round white-hot head, a yellow inner flame
and an orange tail tapering back in ragged tongues. Same canvas (320x64), same anchor (the head's
front, +x = travel) and about the same weight (the head 38 px across, the old one 44), so the row
keeps its size_px / anchor_px and only its `art` moves (back = tracer.png). Palette tokens only:
fx_colour.json's tracer family inks them (wash -> orange, paper_2 -> yellow, paper -> white-hot).

    python tools/art/tracer_comet.py [fx_dir]   then  python tools/art/fx_colour.py <fx_dir> <fx_dir>/colour
"""

import sys
from pathlib import Path

from PIL import ImageDraw

from weapon_fx import PAPER, PAPER_2, SS, WASH, _canvas, _compose, _poly, _save

W, H = 320, 64
CY = H / 2
HX, HR = 291, 19  # head centre x and radius (part px); front = HX + HR = the anchor


def _disc(cx, cy, r):
    m = _canvas(W, H)
    ImageDraw.Draw(m).ellipse([(cx - r) * SS, (cy - r) * SS, (cx + r) * SS, (cy + r) * SS], fill=255)
    return m


def _flame(x0, half, tongues):
    """A tail from x0 (a point) to the head, half-width `half` at the head, ragged in `tongues`."""
    top, bot = [], []
    n = tongues * 2
    for i in range(n + 1):
        t = i / n
        x = x0 + (HX - x0) * t
        w = half * t**0.8 * (0.62 if i % 2 else 1.0)  # notches between the tongues
        lag = 10 if i % 2 else 0  # each tongue's tip trails its notch: a flame licking back
        top.append((x - lag, CY - w))
        bot.append((x - lag * 0.6, CY + w * 0.9))
    return _poly(_canvas(W, H), top + [(HX, CY)] + bot[::-1])


def tracer_comet(out, seed):
    tail = _flame(14, HR - 2, 4)
    inner = _flame(120, HR - 9, 3)
    head = _disc(HX, CY, HR)
    ring = _disc(HX, CY, HR - 6)
    core = _disc(HX + 3, CY, HR - 11)
    layers = [(tail, WASH), (head, WASH), (inner, PAPER_2), (ring, PAPER_2), (core, PAPER)]
    _save(_compose(layers, W, H, seed), out / "tracer_comet.png")
    return [W, H], [HX + HR, int(CY)]


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    print("tracer_comet", *tracer_comet(fx_dir, 11))
