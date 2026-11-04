"""The bullet tracer, heavier (weapon-art lane, iteration 9, 2026-11-04).

Iteration 1's `tracer` cell (280x48, a charcoal needle 18 px at its widest under a 10 px ink ring)
drew 3-4 px tall at 32 px/m (fx_draw_scale 2 x 32/320 = 0.2): in the city proving block on cream
paving (`--arena=city --loadout=pistol --bot=arsenal`, frames cut at 30 fps) Rivet's pistol round
printed as a pale hairline slash while the guard's rounds (gunplay's charcoal bar with a vermilion
head) read at a glance. Now the tracer's two-tone rule at a weight that survives the 0.2 scale: a
charcoal body widening from a thin tail to a fat pointed head (44 px across), a paper hot streak
along the front half and a paper head core (reads on asphalt), the ink ring at 13 px like every other
cell. Still a needle (no vermilion: that is the enemy's danger head), so Rivet's rounds and the
guard's never read alike. Anchor = the head's tip, +x = travel. Palette tokens only.

    python tools/art/bullet_tracer.py <fx_dir>
then set the `tracer` row's size_px / anchor_px in data/tables/weapon_art.json to the printed values.
"""

import sys
from pathlib import Path

from weapon_fx import INK_2, PAPER, _canvas, _compose, _poly, _save

W, H = 320, 64
CY = H / 2


def tracer(out, seed):
    tip = W - 10
    body = _poly(_canvas(W, H), [(12, CY - 2), (tip - 46, CY - 22), (tip, CY), (tip - 46, CY + 22), (12, CY + 2)])
    streak = _poly(_canvas(W, H), [(W * 0.38, CY), (tip - 52, CY - 7), (tip - 18, CY), (tip - 52, CY + 7)])
    _save(_compose([(body, INK_2), (streak, PAPER)], W, H, seed), out / "tracer.png")
    return [W, H], [tip, int(CY)]


if __name__ == "__main__":
    size, anchor = tracer(Path(sys.argv[1] if len(sys.argv) > 1 else "project/features/combat/weapons/art/fx"), 11)
    print("tracer", size, anchor)
