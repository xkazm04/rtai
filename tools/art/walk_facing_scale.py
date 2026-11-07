"""d9 seams: scale one facing's figures in a game walk grid (street_walk.py's 5 facings x 4 frames)
about each figure's foot point, so a facing the model drew at a smaller scale stops popping on the
turn (swat_armed_walk p55 facing 2, the round-1320 3/4-toward row: helmet 52 px vs 57-61 in the
other facings, head line 12 px under the front's in a 192 px cell).

usage: python -I tools/art/walk_facing_scale.py <grid.png> <out.png> F:K [F:K ...]

F = facing column 1..5, K = scale (1.06 = 6 % larger). The foot point is the figure's lowest opaque
row at the centre of its opaque columns; it stays put. Lanczos resample of the straight RGBA, alpha
re-premultiplied by PIL. Fails if a scaled figure leaves its cell. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

COLS = 5
ROWS = 4


def _scale_cell(cell: Image.Image, k: float) -> Image.Image:
    a = np.asarray(cell)[..., 3] > 16
    ys = np.where(a.any(1))[0]
    xs = np.where(a.any(0))[0]
    foot = (float(xs[0] + xs[-1] + 1) * 0.5, float(ys[-1] + 1))
    big = cell.resize((round(cell.width * k), round(cell.height * k)), Image.Resampling.LANCZOS)
    out = Image.new("RGBA", cell.size, (0, 0, 0, 0))
    # x rounds; y puts the scaled figure's measured sole exactly on the old foot line (no 1 px bob)
    sole = int(np.where((np.asarray(big)[..., 3] > 16).any(1))[0][-1]) + 1
    out.alpha_composite(big, (round(foot[0] - foot[0] * k), int(foot[1]) - sole))
    kept = int((np.asarray(out)[..., 3] > 16).sum())
    want = int(a.sum() * k * k)
    if kept < want * 0.98:
        raise SystemExit(f"scaled figure leaves its cell ({kept} of {want} px kept)")
    return out


def main() -> None:
    if len(sys.argv) < 4:
        raise SystemExit(__doc__)
    grid = Image.open(sys.argv[1]).convert("RGBA")
    cw, ch = grid.width // COLS, grid.height // ROWS
    for arg in sys.argv[3:]:
        f, k = arg.split(":")
        col, scale = int(f) - 1, float(k)
        for r in range(ROWS):
            box = (col * cw, r * ch, (col + 1) * cw, (r + 1) * ch)
            cell = _scale_cell(grid.crop(box), scale)
            grid.paste(cell, box[:2])
    grid.save(sys.argv[2])
    print("scaled", sys.argv[3:], "->", sys.argv[2])


if __name__ == "__main__":
    main()
