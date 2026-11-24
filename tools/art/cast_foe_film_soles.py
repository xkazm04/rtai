"""Sole texels (u, v in the cell) of the shipped four and the new eight, profile column, for the feet films."""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_foe_soles import SHEETS, sole as eight_sole
from cast_soles import VIEW, band, bounds, window

COL = 2
FOURS = {'riot': ('cop_riot_armed_walk', 'cop_riot'), 'swat': ('swat_armed_walk', 'swat'),
         'lancer': ('rocket_trooper_armed_walk', 'rocket_trooper')}


def rows(path, count, point):
    mask = np.asarray(Image.open(path))[:, :, 3] > 128
    strip = np.hsplit(mask, 5)[COL]
    return [None if (p := point(cell, r)) is None else [float(p[0]), float(p[1])]
            for r, cell in enumerate(np.vsplit(strip, count))]


def main(out):
    result = {}
    for pitch in (70, 55):
        for name, (four, _) in FOURS.items():
            path = VIEW / f'p{pitch}' / (four + '.png')
            result.setdefault(four + '.png', {})[str(pitch)] = rows(
                path, 4, lambda cell, r: band(cell, window(four, pitch, COL, r)))
        for name, sheet in SHEETS.items():
            path = VIEW / f'p{pitch}' / sheet[2]
            skip = (3, 7) if name == 'swat_run' else ()
            result.setdefault(sheet[2], {})[str(pitch)] = rows(
                path, 8, lambda cell, r, n=name, p=pitch, s=skip: None if r in s
                else eight_sole(cell, n, p, COL, r))
    Path(out).write_text(json.dumps(result))


if __name__ == '__main__':
    main(sys.argv[1])
