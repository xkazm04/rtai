"""Sole texels (u, v in the cell) of the door carrier's walks (four and eight drawings), profile column, for the feet films."""
import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_door_soles import ROWS, sole
from cast_soles import VIEW

COL = 2


def main(out):
    result = {name: {} for name in ROWS}
    for name, rows in ROWS.items():
        for pitch in (70, 55):
            mask = np.asarray(Image.open(VIEW / f'p{pitch}' / name))[:, :, 3] > 128
            cells = np.vsplit(np.hsplit(mask, 5)[COL], rows)
            result[name][str(pitch)] = [[float(p[0]), float(p[1])] for p in
                                        (sole(cell, pitch, COL, r, name) for r, cell in enumerate(cells))]
    Path(out).write_text(json.dumps(result))


if __name__ == '__main__':
    main(sys.argv[1])
