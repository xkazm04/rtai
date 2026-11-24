"""Sole texels (u, v in the cell) of the door carrier's shipped four drawings, profile column, for the feet films."""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_door_soles import NAME, sole
from cast_soles import VIEW

COL = 2


def main(out):
    result = {NAME: {}}
    for pitch in (70, 55):
        mask = np.asarray(Image.open(VIEW / f'p{pitch}' / NAME))[:, :, 3] > 128
        strip = np.hsplit(mask, 5)[COL]
        result[NAME][str(pitch)] = [[float(p[0]), float(p[1])] for p in
                                    (sole(cell, pitch, COL, r) for r, cell in enumerate(np.vsplit(strip, 4)))]
    Path(out).write_text(json.dumps(result))


if __name__ == '__main__':
    main(sys.argv[1])
