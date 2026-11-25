"""Register the load-bearing sole in every drawing of the door-carrier walks (FOUR: 4 rows, EIGHT: 8 rows).

The shipped four-drawing strip takes its windows from cast_soles.OTHERS (shield_robot, right facing);
the down-right contact hides the supporting boot behind the slab, so there (and in the unmeasured
facings) the lowest opaque pixels stand in: a body anchor, not a verified sole. The n29 eight-drawing
strip (tools/art/cast_door_eight.py) takes the foe eights' windows (cast_foe_soles.sole). WALK selects
which walk ships: SHEET, WALK70/WALK55 and WALK_STEP_M are the selected walk's.

usage: python tools/art/cast_door_soles.py [--walk FOUR|EIGHT] [--review]
"""
import argparse
import hashlib
from statistics import mean

import numpy as np
from PIL import Image, ImageDraw

from cast_foe_soles import sole as foe_sole
from cast_soles import OTHERS, ROOT, VIEW, band, body_point, bounds

NAME = 'shield_robot_armed_walk.png'
EIGHT = 'shield_robot_planted8_armed_walk.png'
ROWS = {NAME: 4, EIGHT: 8}
# The shipped walk ships until every facing of the eight passes the sole bar (n29: see cast-audit.md).
WALK = 'FOUR'
# FOUR: tuned on cast_feet (lowest sole drift at <= 10 drawings/s). EIGHT: the drawn advance (None = measured mean).
STEP_M = {NAME: '0.16', EIGHT: None}


def cells(path):
    alpha = np.asarray(Image.open(path))[:, :, 3] > 128
    return [np.vsplit(strip, ROWS[path.name]) for strip in np.hsplit(alpha, 5)]


def without_bar(mask):
    """The profile slab is a bar standing to the ground in front: drop it so the boots carry the sole."""
    x, y, right, bottom = bounds(mask)
    top = np.flatnonzero(mask[y:y + max(2, (bottom - y) // 10)].any(axis=0))
    bar = top[np.split(top, np.flatnonzero(np.diff(top) > 3) + 1)[-1].size * -1:][0]
    out = mask.copy()
    out[:, bar - 1:] = False
    return out


def sole(mask, pitch, col, row, name=NAME):
    if name == EIGHT:
        return foe_sole(without_bar(mask) if col == 2 else mask, 'door', pitch, col, row)
    windows = OTHERS['shield_robot'][pitch][1]
    return band(mask, windows[row]) if col == 2 else band(mask)


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
            pivot = np.array([mask.shape[1] / 2, mask.shape[0] * .875])
            x, y = foot - pivot
            u, v = body - pivot
            lines.append(f'\tVector4({x:g}, {y:g}, {u:g}, {v:g}),')
        if col == 2:
            offsets = row_offsets
    lines.append(']')
    return offsets


def review(pitch):
    """Every drawing of the eight with its registered sole (red ring), for the window check."""
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
    dest = ROOT / 'build/look/n29-door8' / f'soles_{pitch}.png'
    dest.parent.mkdir(parents=True, exist_ok=True)
    out.save(dest)


def main(walk):
    lines = ['class_name CastDoorAnchors', 'extends RefCounted',
             '## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_door_soles.py.',
             f'const EIGHT: String = "{EIGHT}"', f'const FOUR: String = "{NAME}"',
             '## The shipped walk; EIGHT selects the n29 eight-drawing walk (regenerate with --walk).',
             f'const WALK: String = {walk}', 'const SHEET: String = WALK']
    for name, const in ((NAME, 'FOUR'), (EIGHT, 'EIGHT')):
        steps = []
        for pitch, height in ((70, 1.7), (55, 2.0)):
            offsets = table(pitch, lines, name, const)
            span = ROWS[name] // 4 if name == NAME else 3
            for start in range(0, ROWS[name], ROWS[name] // 2):
                steps.append(abs(offsets[start + span] - offsets[start]) * height / 192 / span)
        print(const, 'metres per drawing', [round(x, 4) for x in steps], 'mean', round(mean(steps), 4))
        step = STEP_M[name] or f'{mean(steps):.4f}'
        lines.append(f'const {const}_STEP_M: float = {step}')
    lines += [f'const WALK70: Array[Vector4] = {walk}70', f'const WALK55: Array[Vector4] = {walk}55',
              f'const WALK_STEP_M: float = {walk}_STEP_M']
    (ROOT / 'project/features/characters/cast_door_anchors.gd').write_text(
        '\n'.join(lines) + '\n', encoding='utf-8', newline='\n')


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
