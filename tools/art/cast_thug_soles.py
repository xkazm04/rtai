"""Emit CastThugAnchors from robot thug A's shipped eight-drawing walk (sole and torso per cell).

Reuses cast_foe_soles (same windows, lead-shoe pick and step fit) without editing it: the thug's
sheet is registered in its SHEETS table at run time. `--review` writes the overlay sheets to
gtai-art/foes-n29/thug/pack/soles_{70,55}.png.
"""
import argparse
from pathlib import Path

import cast_foe_soles as soles

NAME = 'thug'
CLASS = 'CastThugAnchors'
FILE = 'cast_thug_anchors.gd'
PACK = Path('C:/Users/kazda/kiro/gtai-art/foes-n29/thug/pack')
soles.SHEETS[NAME] = (CLASS, FILE, 'robot_thug_planted8_armed_walk.png', (1.0, 1.0),
                      'robot_thug_armed_walk.png')
# (pitch, facing column): percent of the opaque width (from the left) that is his big claw. In the
# down and down-right facings it hangs as low as the shoes (lower at 70 degrees), so it is cut away
# before the shoe is looked for (bottom profiles per 5 % of width + --review).
CLAW = {(70, 0): 46, (70, 1): 50, (55, 0): 32, (55, 1): 50}
_sole = soles.sole


def sole(mask, name, pitch, col, row):
    if name == NAME and (pitch, col) in CLAW:
        x, _y, right, _bottom = soles.bounds(mask)
        mask = mask.copy()
        mask[:, :x + round((right - x) * CLAW[pitch, col] / 100)] = False
    return _sole(mask, name, pitch, col, row)


soles.sole = sole


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--review', action='store_true')
    if parser.parse_args().review:
        PACK.mkdir(parents=True, exist_ok=True)
        for pitch in (70, 55):
            soles.review(NAME, pitch, PACK / f'soles_{pitch}.png')
        return
    soles.generate([NAME], CLASS, FILE)
    path = soles.ROOT / 'project/features/characters' / FILE
    text = path.read_text(encoding='utf-8').replace('tools/art/cast_foe_soles.py', 'tools/art/cast_thug_soles.py')
    path.write_text(text, encoding='utf-8', newline='\n')


if __name__ == '__main__':
    main()
