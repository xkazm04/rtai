"""The flamethrower's jet as r2_w4's flame cone (look lane, n5 iteration 18, 2026-11-05).

The weapon-art lane's jet cell (`flame_0..2`, tools/art/weapon_fx_jet.py) is a round-headed
teardrop with a paper heart: strung along the stream it reads as a chain of bubbles at 64 px/m.
r2_w4's flame is one widening cone with ragged flame-licked edges: an orange outer band, a hot
yellow body, a pale streak down its axis. This cell is a slice of that cone pointing +x on the
teardrop's height (300x120, head centre 230,60; 80 px longer behind the head than the teardrop,
so each slice's tail reaches into the previous round's: n5-look iteration 18 take 3), so WeaponFxArt._jet's overlapping
cells (grown and fanned with range) close into one ragged cone. Palette tokens only:
fx_colour.json's explosion + flame families ink them (wash -> orange, paper_2 -> yellow,
paper -> the pale core; the flame rim paints the orange-red band inside the ink).

    python tools/art/flame_cone.py [fx_dir]   then  python tools/art/fx_colour.py <fx_dir> <fx_dir>/colour
"""

import random
import sys
from pathlib import Path

from weapon_fx import PAPER, PAPER_2, WASH, _canvas, _compose, _poly, _save

W, H = 300, 120
CY = H / 2
ANCHOR = (230, 60)
## (tail x, front x, front half-height, tongues per edge, tongue reach, front tongues) per layer.
OUTER = (6, 276, 40, 7, 12, 3)
INNER = (40, 264, 28, 6, 8, 3)
## The pale axis streak: tail x, front x, half-height at the front.
CORE = (90, 258, 11)
OUTLINE_PX = 8
## The wedge's half-height at its tail as a share of the front's (0.12 read as a thin arrow in game).
TAIL_K = 0.45


def _edge(rng, x0, x1, half, n, reach, side):
    """One ragged edge from the tail (x0) to the front (x1): the wedge widens linearly to `half`;
    each tongue leans outward and forward (r2_w4's licks curl toward the flame front)."""
    pts = []
    for i in range(n):
        t0, t1 = i / n, (i + 1) / n
        xa, xb = x0 + (x1 - x0) * t0, x0 + (x1 - x0) * t1
        ha, hb = half * (TAIL_K + (1 - TAIL_K) * t0), half * (TAIL_K + (1 - TAIL_K) * t1)
        tip_t = rng.uniform(0.5, 0.95)
        big = rng.uniform(0.25, 1.15)  # uneven licks: a sawtooth of equal teeth reads as a saw
        tx = xa + (xb - xa) * tip_t + reach * big * rng.uniform(0.5, 1.0)
        th = ha + (hb - ha) * tip_t + reach * big * (0.4 + 0.6 * t1)
        pts += [(xa, CY + side * ha), (tx, CY + side * th), (xb - (xb - xa) * 0.2, CY + side * hb * 0.86)]
    return pts


def _front(rng, x1, half, n, reach):
    """The flame front: `n` forward tongues across the wedge's wide end, bottom to top."""
    pts = []
    for i in range(n):
        y0 = CY + half * (1 - 2 * i / n)
        y1 = CY + half * (1 - 2 * (i + 1) / n)
        tip = (x1 + reach * rng.uniform(0.6, 1.2), (y0 + y1) / 2 + rng.uniform(-0.2, 0.2) * (y1 - y0))
        pts += [(x1 - rng.uniform(0, 8), y0), tip]
    return pts + [(x1 - 6, CY - half)]


def _wedge(rng, spec):
    x0, x1, half, n, reach, nf = spec
    top = _edge(rng, x0, x1, half, n, reach, -1)
    bottom = _edge(rng, x0, x1, half, n, reach, 1)
    pts = [(x0, CY)] + bottom + _front(rng, x1, half, nf, reach) + list(reversed(top))
    return _poly(_canvas(W, H), pts)


def _core(rng):
    x0, x1, half = CORE
    wob = rng.uniform(-3, 3)
    pts = [(x0, CY), (x0 + 40, CY - half * 0.5 + wob), (x1, CY - half), (x1 + 6, CY), (x1, CY + half),
           (x0 + 40, CY + half * 0.5 + wob)]
    return _poly(_canvas(W, H), pts)


def flame_cone(out, frame, seed):
    rng = random.Random(seed * 17 + frame)
    layers = [(_wedge(rng, OUTER), WASH), (_wedge(rng, INNER), PAPER_2), (_core(rng), PAPER)]
    _save(_compose(layers, W, H, seed + frame, outline=OUTLINE_PX), out / f"flame_cone_{frame}.png")
    return [W, H], list(ANCHOR)


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    for f in range(3):
        print(f"flame_cone_{f}", *flame_cone(fx_dir, f, 59))
