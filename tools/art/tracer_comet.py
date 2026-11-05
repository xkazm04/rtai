"""Rivet's bullet tracer and plasma round as r2_w4's comets (look lane, n5 iteration 14, 2026-11-05).

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

H = 64
CY = H / 2


def _disc(w, cx, cy, r):
    m = _canvas(w, H)
    ImageDraw.Draw(m).ellipse([(cx - r) * SS, (cy - r) * SS, (cx + r) * SS, (cy + r) * SS], fill=255)
    return m


def _flame(w, hx, x0, half, tongues):
    """A tail from x0 (a point) to the head at hx, half-width `half` there, ragged in `tongues`."""
    top, bot = [], []
    n = tongues * 2
    for i in range(n + 1):
        t = i / n
        x = x0 + (hx - x0) * t
        q = half * t**0.8 * (0.62 if i % 2 else 1.0)  # notches between the tongues
        lag = 10 if i % 2 else 0  # each tongue's tip trails its notch: a flame licking back
        top.append((x - lag, CY - q))
        bot.append((x - lag * 0.6, CY + q * 0.9))
    return _poly(_canvas(w, H), top + [(hx, CY)] + bot[::-1])


def comet(out, seed, name, w, hr, inner_x0, front=10):
    """A comet `w` part px long whose round head (radius hr) touches x = w - front (the anchor)."""
    hx = w - front - hr
    tail = _flame(w, hx, 14, hr - 2, 4)
    inner = _flame(w, hx, inner_x0, hr - 9, 3)
    head = _disc(w, hx, CY, hr)
    ring = _disc(w, hx, CY, hr - 6)
    core = _disc(w, hx + 3, CY, hr - 11)
    layers = [(tail, WASH), (head, WASH), (inner, PAPER_2), (ring, PAPER_2), (core, PAPER)]
    _save(_compose(layers, w, H, seed), out / f"{name}.png")
    return [w, H], [hx + hr, int(CY)]


def tracer_comet(out, seed):
    return comet(out, seed, "tracer_comet", 320, 19, 120)


def plasma_comet(out, seed):
    """r2_w4's plasma round: the same comet, shorter and fatter (the plasma_bolt row's 260x64
    canvas and anchor), inked white-hot with a gold rim by fx_colour.json's plasma family."""
    return comet(out, seed, "plasma_comet", 260, 23, 90, front=8)


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    print("tracer_comet", *tracer_comet(fx_dir, 11))
    print("plasma_comet", *plasma_comet(fx_dir, 11))
