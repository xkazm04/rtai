"""Mean on-screen figure height of each eight-drawing sheet against the shipped walk it replaces.

Both draw at (texel height) x fill / 192 screen px per texel (the eight's cells are 256 tall and
its fill carries CELL_RATIO), so the ratio of mean opaque heights is the size change.
"""
import numpy as np
from PIL import Image

from cast_foe_soles import SHEETS
from cast_soles import VIEW, bounds


def mean_height(path, rows):
    mask = np.asarray(Image.open(path))[:, :, 3] > 128
    heights = []
    for strip in np.hsplit(mask, 5):
        heights.append(np.mean([bounds(t)[3] - bounds(t)[1] for t in np.vsplit(strip, rows)]))
    return heights


if __name__ == '__main__':
    for name, sheet in SHEETS.items():
        for pitch in (70, 55):
            new = mean_height(VIEW / f'p{pitch}' / sheet[2], 8)
            old = mean_height(VIEW / f'p{pitch}' / sheet[4], 4)
            ratio = [round(n / o, 3) for n, o in zip(new, old)]
            print(name, pitch, 'per facing', ratio, 'mean', round(float(np.mean(ratio)), 3))
