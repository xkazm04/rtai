"""The checklist's Ink row for the gunner: the left contour of a front walk pose at 192 px cell height.
Run from the repo root: python tools/art/cast_gunner_ink.py [sheet-stem ...]. The patrol's own reference
(cop_patrol_armed_walk, cell column 0, row 1) is printed first, on the same method."""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_metrics import ink_runs

VIEW = Path(__file__).resolve().parents[2] / "project/features/characters/art/view"


def cell_at_192(path, rows, col, row):
    with Image.open(path) as image:
        rgba = image.convert("RGBA")
    cw, ch = rgba.width // 5, rgba.height // rows
    cell = rgba.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
    if ch != 192:
        cell = cell.resize((round(cw * 192 / ch), 192), Image.Resampling.LANCZOS)
    return np.array(cell, dtype=np.int16)


def report(pitch, stem, rows, cells):
    for row in cells:
        path = VIEW / f"p{pitch}" / f"{stem}.png"
        print(pitch, stem, f"col 0 row {row}", ink_runs(cell_at_192(path, rows, 0, row)))


if __name__ == "__main__":
    for pitch in (70, 55):
        report(pitch, "cop_patrol_armed_walk", 4, [1])
        report(pitch, "robot_gunner_armed_walk", 4, [0, 1, 2, 3])
        report(pitch, "robot_gunner_planted8_armed_walk", 8, range(8))
