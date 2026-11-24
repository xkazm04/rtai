"""Register the load-bearing sole in every drawing of the shipped door-carrier walk (4 rows x 5 facings).

No art changes: the shipped strip stays, the runtime places each drawing by the sole measured here.
Windows come from cast_soles.OTHERS (shield_robot, right facing). The down-right contact hides the
supporting boot behind the slab, so there (and in the unmeasured facings) the lowest opaque pixels
stand in: a body anchor, not a verified sole.
"""
import hashlib
from statistics import mean

import numpy as np
from PIL import Image

from cast_soles import OTHERS, ROOT, VIEW, band, body_point, bounds

NAME = 'shield_robot_armed_walk.png'


def cells(path):
    alpha = np.asarray(Image.open(path))[:, :, 3] > 128
    return [np.vsplit(strip, 4) for strip in np.hsplit(alpha, 5)]


def sole(mask, pitch, col, row):
    windows = OTHERS['shield_robot'][pitch][1]
    return band(mask, windows[row]) if col == 2 else band(mask)


def table(pitch, lines):
    path = VIEW / f'p{pitch}' / NAME
    lines += [f'## p{pitch} SHA-256 ' + hashlib.sha256(path.read_bytes()).hexdigest(),
              f'const WALK{pitch}: Array[Vector4] = [']
    offsets = []
    for col, strip in enumerate(cells(path)):
        row_offsets = []
        for row, mask in enumerate(strip):
            foot, body = sole(mask, pitch, col, row), body_point(mask)
            row_offsets.append(body[0] - foot[0])
            pivot = np.array([mask.shape[1] / 2, mask.shape[0] * .875])
            x, y = foot - pivot
            u, v = body - pivot
            lines.append(f'\tVector4({x:g}, {y:g}, {u:g}, {v:g}),')
        if col == 2:
            offsets = row_offsets
    lines.append(']')
    return offsets


def main():
    lines = ['class_name CastDoorAnchors', 'extends RefCounted',
             '## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_door_soles.py.',
             f'const SHEET: String = "{NAME}"']
    steps = []
    for pitch, height in ((70, 1.7), (55, 2.0)):
        offsets = table(pitch, lines)
        for start in (0, 2):
            steps.append(abs(offsets[start + 1] - offsets[start]) * height / 192)
    print('metres per drawing', steps)
    lines.append('const WALK_STEP_M: float = 0.16')  # tuned on cast_feet: lowest sole drift at <= 10 drawings/s
    (ROOT / 'project/features/characters/cast_door_anchors.gd').write_text(
        '\n'.join(lines) + '\n', encoding='utf-8', newline='\n')


if __name__ == '__main__':
    main()
