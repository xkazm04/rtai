"""Register the load-bearing pad in every drawing of the pile-driver walks (FOUR: 4 rows, EIGHT: 8 rows).

The shipped four-drawing strip has a flat rear pad in every drawing (cast-audit "Pile-driver feet,
n28"), so its anchor is the lowest opaque band of the whole cell. The n29 eight-drawing strip
(tools/art/cast_war_eight.py) takes the foe eights' windows (cast_foe_soles.sole: the trailing pad
in drawings 4 and 8 of the three-quarter and profile facings, else the lead pad of the lowest rows).
WALK selects which walk ships: SHEET, WALK70/WALK55 and WALK_STEP_M are derived from WALK in
GDScript, so the switch is the one WALK line (--walk writes it). FOUR_STEP_M is the shipped stride
over four drawings, so the view's stride (WALK_STEP_M x rows) is unchanged while WALK is FOUR.

usage: python tools/art/cast_war_soles.py [--walk FOUR|EIGHT] [--review]
"""
import argparse
import hashlib
from statistics import mean

import numpy as np
from PIL import Image, ImageDraw

from cast_foe_soles import sole as foe_sole
from cast_soles import ROOT, VIEW, band, body_point

NAME = 'war_machine_armed_walk.png'
EIGHT = 'war_machine_planted8_armed_walk.png'
ROWS = {NAME: 4, EIGHT: 8}
# The eight ships since n30 (owner's n29 pick: held-foot jump 9.93-10.74 px against the four's 11.78-16.82).
WALK = 'EIGHT'
# Sheet px to metres: FoeWarCardView draws BODY_PX 200 as HEIGHT_M 2.6 x body_scale 0.84.
M_PER_PX = 2.6 * 0.84 / 200
OUT = ROOT / 'project/features/characters/cast_war_anchors.gd'


def cells(path):
    alpha = np.asarray(Image.open(path))[:, :, 3] > 128
    return [np.vsplit(strip, ROWS[path.name]) for strip in np.hsplit(alpha, 5)]


def sole(mask, pitch, col, row, name=NAME):
    if name == EIGHT:
        return foe_sole(mask, 'war', pitch, col, row)
    return band(mask)


def table(pitch, lines, name, const):
    path = VIEW / f'p{pitch}' / name
    lines += [f'## p{pitch} SHA-256 ' + hashlib.sha256(path.read_bytes()).hexdigest(),
              f'const {const}{pitch}: Array[Vector4] = [']
    offsets = []
    for col, strip in enumerate(cells(path)):
        row_offsets = []
        for row, mask in enumerate(strip):
            foot, body = sole(mask, pitch, col, row, name), body_point(mask)
            row_offsets.append(body[0] - foot[0])
            pivot = np.array([mask.shape[1] / 2, 264.0])
            x, y = foot - pivot
            u, v = body - pivot
            lines.append(f'\tVector4({x:g}, {y:g}, {u:g}, {v:g}),')
        if col == 2:
            offsets = row_offsets
    lines.append(']')
    return offsets


def review(pitch):
    """Every drawing of the eight with its registered pad (red ring), for the window check."""
    path = VIEW / f'p{pitch}' / EIGHT
    image = Image.open(path).convert('RGBA')
    cw, ch = image.width // 5, image.height // 8
    out = Image.new('RGB', (8 * (cw + 4), 5 * (ch + 4)), '#808080')
    draw = ImageDraw.Draw(out)
    for col, strip in enumerate(cells(path)):
        for row, mask in enumerate(strip):
            left, top = row * (cw + 4), col * (ch + 4)
            tile = image.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
            out.paste(tile, (left, top), tile)
            fx, fy = sole(mask, pitch, col, row, EIGHT)
            draw.ellipse((left + fx - 4, top + fy - 4, left + fx + 4, top + fy + 4), outline='#ff2020', width=2)
            draw.text((left + 3, top + 2), str(row + 1), fill='#ffffff')
    dest = ROOT / 'build/look/n29-war8' / f'soles_{pitch}.png'
    dest.parent.mkdir(parents=True, exist_ok=True)
    out.save(dest)


def main(walk):
    lines = ['class_name CastWarAnchors', 'extends RefCounted',
             '## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_war_soles.py.',
             '## Vector4(sole x, sole y, body x, body y) per facing x drawing, px from the cell\'s',
             '## centre on the foot line (FoeWarCardView.BASE_PX), before the view\'s mirror.',
             f'const EIGHT: String = "{EIGHT}"', f'const FOUR: String = "{NAME}"',
             '## The shipped walk (n30: the eight); FOUR = the n28 four (regenerate with --walk).',
             f'const WALK: String = {walk}', 'const SHEET: String = WALK']
    for name, const in ((NAME, 'FOUR'), (EIGHT, 'EIGHT')):
        steps = []
        for pitch in (70, 55):
            offsets = table(pitch, lines, name, const)
            span = ROWS[name] // 2 - 1
            for start in range(0, ROWS[name], ROWS[name] // 2):
                steps.append(abs(offsets[start + span] - offsets[start]) * M_PER_PX / span)
        print(const, 'metres per drawing', [round(x, 4) for x in steps], 'mean', round(mean(steps), 4))
        if name == NAME:
            lines.append('const FOUR_STEP_M: float = StreetQuestCards.STRIDE_M / 4.0')
        else:
            lines.append(f'const EIGHT_STEP_M: float = {mean(steps):.4f}')
    lines += ['const FOUR_ROWS: int = 4', 'const EIGHT_ROWS: int = 8',
              '## Derived from WALK alone: switching the walk is the one WALK value (n29-11).',
              'const WALK70: Array[Vector4] = EIGHT70 if WALK == EIGHT else FOUR70',
              'const WALK55: Array[Vector4] = EIGHT55 if WALK == EIGHT else FOUR55',
              'const WALK_STEP_M: float = EIGHT_STEP_M if WALK == EIGHT else FOUR_STEP_M',
              'const WALK_ROWS: int = EIGHT_ROWS if WALK == EIGHT else FOUR_ROWS']
    OUT.write_text('\n'.join(lines) + '\n', encoding='utf-8', newline='\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--walk', choices=('FOUR', 'EIGHT'), default=WALK)
    parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    if args.review:
        for tilt in (70, 55):
            review(tilt)
    else:
        main(args.walk)
