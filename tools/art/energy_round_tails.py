"""Energy rounds with ink tails: the plasma bolt comet and the tailed homing shard (weapon-art lane,
iteration 8, 2026-11-04).

Replaces iteration 1's `plasma_bolt` cell, which failed the in-game read: a steel oval with a paper
core inside a thin ink ring printed as a pale seed on the city's cream paving at 32 px/m (seen frame
by frame in the city proving block, `--arena=city --loadout=plasma_rifle`), while its impact burst
read loud. Now the tracer's two-tone rule at the bolt's own shape: a long charcoal tail tapering back
toward -x (reads on cream paving) under a fat head with a steel halo and a paper hot core (reads on
asphalt), one paper speed streak in the tail. A fat blob on a comet, so it never reads as the
tracer's needle. Anchor = the head's front tip, +x = travel. Palette tokens only (no new accent:
owner call weapon-art-3 is still open).

The homing shard's pale crystal diamond printed as the same pale seed on cream paving (the leaf seen in
the city block). It keeps its crystal head (paper_2 body, paper facet) and gains a charcoal speed tail
behind it, so the crystal reads on asphalt and the tail on cream.

The ray gun's rings (`ray_ring_0..2`, first drawn in flight in iteration 8 by WeaponFxRay) were a thin
paper band in a 5 px ink line: two hairlines at 64 px/m. Now a fat charcoal band in the ink ring with
a paper stripe along it, the band widening per frame; same sizes and anchors.

    python tools/art/energy_round_tails.py <fx_dir>
then set the `plasma_bolt` and `shard` rows' size_px / anchor_px in data/tables/weapon_art.json to the printed
values and canonicalise it with tools/art/canon_json.mjs.
"""

import sys
from pathlib import Path

from PIL import ImageDraw

from weapon_fx import INK_2, PAPER, PAPER_2, SS, STEEL, _canvas, _compose, _poly, _save

W, H = 260, 64
CY = H / 2
HEAD_X = 204


def _ellipse(w, h, cx, cy, rx, ry):
    m = _canvas(w, h)
    ImageDraw.Draw(m).ellipse([(cx - rx) * SS, (cy - ry) * SS, (cx + rx) * SS, (cy + ry) * SS], fill=255)
    return m


def plasma_bolt(out, seed):
    tail = _poly(_canvas(W, H), [(8, CY - 2), (HEAD_X - 20, CY - 17), (HEAD_X - 20, CY + 17), (8, CY + 2)])
    body = _ellipse(W, H, HEAD_X, CY, 42, 21)
    tail.paste(255, (0, 0), body)
    halo = _ellipse(W, H, HEAD_X + 6, CY, 33, 16)
    core = _ellipse(W, H, HEAD_X + 12, CY, 22, 9)
    streak = _poly(_canvas(W, H), [(52, CY - 1), (HEAD_X - 30, CY - 4), (HEAD_X - 30, CY + 4), (52, CY + 1)])
    layers = [(tail, INK_2), (streak, PAPER), (halo, STEEL), (core, PAPER)]
    _save(_compose(layers, W, H, seed), out / "plasma_bolt.png")
    return [W, H], [HEAD_X + 42 + 6, int(CY)]


def shard(out, seed):
    w, h, x0 = 190, 44, 70
    tail = _poly(_canvas(w, h), [(8, h / 2 - 1), (x0 + 30, h / 2 - 9), (x0 + 30, h / 2 + 9), (8, h / 2 + 1)])
    body = _poly(_canvas(w, h), [(x0 + 10, 22), (x0 + 40, 8), (x0 + 112, 22), (x0 + 40, 36)])
    facet = _poly(_canvas(w, h), [(x0 + 40, 8), (x0 + 112, 22), (x0 + 46, 22)])
    _save(_compose([(tail, INK_2), (body, PAPER_2), (facet, PAPER)], w, h, seed), out / "shard.png")
    return [w, h], [x0 + 112, 22]


def ray_ring(frame, out, seed):
    s = 70 + 30 * frame
    m, band = 8, 12 + 3 * frame
    ring = _ellipse(s, s, s / 2, s / 2, s / 2 - m, s / 2 - m)
    hole = _ellipse(s, s, s / 2, s / 2, s / 2 - m - band, s / 2 - m - band)
    ring.paste(0, (0, 0), hole)
    r_mid = s / 2 - m - band / 2
    stripe = _ellipse(s, s, s / 2, s / 2, r_mid + 2.5, r_mid + 2.5)
    stripe.paste(0, (0, 0), _ellipse(s, s, s / 2, s / 2, r_mid - 2.5, r_mid - 2.5))
    img = _compose([(ring, INK_2), (stripe, PAPER)], s, s, seed + frame, outline=6)
    _save(img, out / f"ray_ring_{frame}.png")
    return [s, s], [s // 2, s // 2]


if __name__ == "__main__":
    for f in range(3):
        print(f"ray_ring_{f}", *ray_ring(f, Path(sys.argv[1]), 43))
    for fn in (plasma_bolt, shard):
        size, anchor = fn(Path(sys.argv[1]), 11)
        print(f"{fn.__name__} size_px {size} anchor_px {anchor}")
