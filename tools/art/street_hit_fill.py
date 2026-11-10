"""n11 combat it21: the drawn hit cells are fitted to the cell's height (street_hit.py FILL), but they
are drawn from a shallower camera than the walk strips and the fall grids, so a whole standing body
fills that height and the head and torso come out about 0.65 x the walking figure's (the film's
walk -> shrink -> grow pop at a death's first frames). This measures, per hit grid, the scale that
draws its figure at the drawing scale of the fall grid's mid-fall row it hands over to (that row
already matches the walker): the ratio of their body THICKNESS (street_fall_between.thickness, the
95th percentile of the figure's distance to its outline), each per px of the person's height on
screen. Prints the StreetWalkerHit.FILL lines. Deterministic, read only.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_hit_fill.py
"""

import sys
from pathlib import Path

from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import street_fall_between as fb  # noqa: E402

COLS = 5
# hit grid -> the kind whose between grid it hands over to
GRIDS = {f"{k}_hit.png": k for k in fb.KINDS}
GRIDS["cop_patrol_shoulder_hit.png"] = "cop_patrol"
GRIDS["cop_patrol_gut_hit.png"] = "cop_patrol"


def mean_thickness(sheet: Image.Image, row: int, rows: int) -> float:
    cw, ch = sheet.width // COLS, sheet.height // rows
    cells = [sheet.crop((c * cw, row * ch, (c + 1) * cw, (row + 1) * ch)) for c in range(COLS)]
    return sum(fb.thickness(c) for c in cells) / COLS / ch


def fill_of(hit: str, kind: str) -> float:
    grid = Image.open(fb.P70 / fb.KINDS[kind][1]).convert("RGBA")
    mid = mean_thickness(grid, 1, 5) * (grid.height / 5) / fb.STILL_PX
    return mid / mean_thickness(Image.open(fb.P70 / hit).convert("RGBA"), 0, 1)


def main() -> int:
    for hit, kind in sorted(GRIDS.items()):
        print(f'\t"{hit}": {fill_of(hit, kind):.2f},')
    return 0


if __name__ == "__main__":
    sys.exit(main())
