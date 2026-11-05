"""The homing shard as r2_w4's crystal arrowheads (look lane, n5 iteration 16, 2026-11-05).

The weapon-art lane's `shard` (tools/art/energy_round_tails.py) is a long pale lozenge on a charcoal
tail: at 64 px/m it reads as a thin dart. r2_w4's shards are barbed arrowheads with swept-back barbs,
a pale crystal body with a bright upper facet, and ink speed dashes trailing behind. Same length
(190) and tip anchor (+x = travel); the canvas grows 44 -> 64 tall so the barbs read at 32 px/m, so
the row's size_px / anchor_px move with its `art` (back = shard.png at 190x44, anchor 182,22). Palette tokens only: fx_colour.json's shard family inks them
(paper_2 -> pale crystal, paper -> the cyan-white glint, the dashes stay ink; teal stays souls').

    python tools/art/shard_arrow.py [fx_dir]   then  python tools/art/fx_colour.py <fx_dir> <fx_dir>/colour
"""

import sys
from pathlib import Path

from PIL import Image, ImageDraw

from weapon_fx import INK, PAPER, PAPER_2, SS, _canvas, _compose, _poly, _save

W, H = 190, 64
CY = H / 2
TIP = 182
## Thinner than the 13 px FX ring so the barbs and their notch stay open at 64 px/m.
OUTLINE_PX = 9
## The head: tip, barb tips swept back, the notch where the barbs meet the shaft stub.
BARB_X, NOTCH_X, STUB_X, BARB_Y = 104, 150, 92, 6
## Speed dashes behind the head, drawn in ink after the outline pass (so they stay apart):
## (x0, x1, y offset, half-thickness at the front). At 32 px/m they merge into the dark tail that
## lets the pale crystal read on cream paving (the weapon-art lane's iteration 8 reason).
DASHES = ((4, 90, -16, 4.5), (24, 96, 0, 4.5), (14, 90, 16, 4.5))


def _head():
    pts = [(TIP, CY), (BARB_X, BARB_Y), (NOTCH_X, CY - 6), (STUB_X, CY - 4), (STUB_X, CY + 4),
           (NOTCH_X, CY + 6), (BARB_X, H - BARB_Y)]
    return _poly(_canvas(W, H), pts)


def _facet():
    return _poly(_canvas(W, H), [(TIP, CY), (BARB_X, BARB_Y), (NOTCH_X, CY - 6), (NOTCH_X + 8, CY)])


def _glint():
    m = _canvas(W, H)
    ImageDraw.Draw(m).ellipse([(TIP - 34) * SS, (CY - 8) * SS, (TIP - 16) * SS, (CY) * SS], fill=255)
    return m


def _dashes(img):
    d = ImageDraw.Draw(img)
    for x0, x1, dy, half in DASHES:
        d.polygon([(x0, CY + dy), (x1, CY + dy - half), (x1, CY + dy + half)], fill=INK + (255,))
    return img


def shard_arrow(out, seed):
    layers = [(_head(), PAPER_2), (_facet(), PAPER), (_glint(), PAPER)]
    head = _compose(layers, W, H, seed, outline=OUTLINE_PX)
    under = _dashes(Image.new("RGBA", head.size, (0, 0, 0, 0)))
    under.alpha_composite(head)
    _save(under, out / "shard_arrow.png")
    return [W, H], [TIP, int(CY)]


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    print("shard_arrow", *shard_arrow(fx_dir, 11))
