"""The bullet tracer and Gloria's nail, heavier (weapon-art lane, iteration 9, 2026-11-04).

Iteration 1's `tracer` cell (280x48, a charcoal needle 18 px at its widest under a 10 px ink ring)
drew 3-4 px tall at 32 px/m (fx_draw_scale 2 x 32/320 = 0.2): in the city proving block on cream
paving (`--arena=city --loadout=pistol --bot=arsenal`, frames cut at 30 fps) Rivet's pistol round
printed as a pale hairline slash while the guard's rounds (gunplay's charcoal bar with a vermilion
head) read at a glance. Now the tracer's two-tone rule at a weight that survives the 0.2 scale: a
charcoal body widening from a thin tail to a fat pointed head (44 px across), a paper hot streak
along the front half and a paper head core (reads on asphalt), the ink ring at 13 px like every other
cell. Still a needle (no vermilion: that is the enemy's danger head), so Rivet's rounds and the
guard's never read alike. Anchor = the head's tip, +x = travel. Palette tokens only.

Gloria's `nail` (iteration 2, 150x40: a steel shank 10 px across under an 8 px ink ring) drew 30x2 px
at 32 px/m: a pale speck on cream paving and nearly nothing on asphalt (the cells composited at the
true 0.2 draw scale on crops of the city block). Gloria is the signature gun, so its nail gets the
weight of a round: a bigger shank (22 px across) in steel with a paper glint along it, a broad paper
head disc, and a charcoal speed tail behind the head (the shard's rule: the tail reads on cream, the
steel and paper on asphalt). Still a nail: head, shank, point. Anchor = the point.

    python tools/art/bullet_tracer.py <fx_dir>
then set the `tracer` and `nail` rows' size_px / anchor_px in data/tables/weapon_art.json to the printed values.
"""

import sys
from pathlib import Path

from PIL import ImageDraw

from weapon_fx import INK_2, PAPER, SS, STEEL, _canvas, _compose, _poly, _save

W, H = 320, 64
CY = H / 2


def tracer(out, seed):
    tip = W - 10
    body = _poly(_canvas(W, H), [(12, CY - 2), (tip - 46, CY - 22), (tip, CY), (tip - 46, CY + 22), (12, CY + 2)])
    streak = _poly(_canvas(W, H), [(W * 0.38, CY), (tip - 52, CY - 7), (tip - 18, CY), (tip - 52, CY + 7)])
    _save(_compose([(body, INK_2), (streak, PAPER)], W, H, seed), out / "tracer.png")
    return [W, H], [tip, int(CY)]



def nail(out, seed):
    w, h, cy, hx = 240, 64, 32, 84
    tail = _poly(_canvas(w, h), [(10, cy - 2), (hx - 6, cy - 12), (hx - 6, cy + 12), (10, cy + 2)])
    shank = _poly(_canvas(w, h), [(hx + 10, cy - 11), (w - 52, cy - 11), (w - 12, cy), (w - 52, cy + 11), (hx + 10, cy + 11)])
    head = _canvas(w, h)
    ImageDraw.Draw(head).rounded_rectangle([hx * SS, 8 * SS, (hx + 18) * SS, (h - 8) * SS], radius=4 * SS, fill=255)
    glint = _poly(_canvas(w, h), [(hx + 24, cy - 6), (w - 60, cy - 6), (w - 36, cy - 2), (hx + 24, cy - 2)])
    _save(_compose([(tail, INK_2), (shank, STEEL), (head, PAPER), (glint, PAPER)], w, h, seed), out / "nail.png")
    return [w, h], [w - 12, cy]


if __name__ == "__main__":
    fx_dir = Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx")
    for fn in (tracer, nail):
        print(fn.__name__, *fn(fx_dir, 11))
