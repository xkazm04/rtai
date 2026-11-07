"""Advisory self-check for a vehicle card atlas (vehicle_cards.py output): does each row turn one way?

usage: python -I tools/art/vehicle_turn_check.py <atlas.png> [...] [--exempt=<row>,...] [--margin=0.02]

A generated turntable sometimes draws a 3/4 view turned against its side view (nose down-left beside
a nose-right side); it is only seen turning. Per row, the alpha silhouettes of the 3/4-toward cell
(col 1) and the 3/4-away cell (col 3) are box-normalised to 64x32 and compared (cosine) with the side
cell (col 2) and with the side mirrored. A row that turns one way has col 1 closer to the side
(+) and col 3 closer to the mirror (-). A row is FLAGGED when col 1 < -margin or col 3 > +margin.

Measured on the n8 atlases (2026-11-07): it flags 4 of the 5 rows mirrored by hand tonight (p55
traffic van and police car, p55 truck col 1, p55 depot van cols 1+3); it misses the p55 parked pickup
(margin 0.009) and flags the bike (built from mirrored 3/4s, a narrow silhouette: exempt it). A
heuristic, not a gate: look at a FLAGGED row turning before mirroring anything. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

CELL_PX = 448


def _profile(mask: np.ndarray) -> np.ndarray | None:
    ys, xs = np.nonzero(mask)
    if len(xs) < 500:
        return None
    sub = mask[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1].astype(np.uint8) * 255
    return np.asarray(Image.fromarray(sub).resize((64, 32)), np.float32) / 255.0


def _cos(a: np.ndarray, b: np.ndarray) -> float:
    return float((a * b).sum() / np.sqrt((a * a).sum() * (b * b).sum()))


def row_margins(atlas: np.ndarray, row: int) -> tuple[float, float] | None:
    def cell(col: int) -> np.ndarray:
        r0, c0 = row * CELL_PX, col * CELL_PX
        return atlas[r0 : r0 + CELL_PX, c0 : c0 + CELL_PX, 3] > 128

    side = _profile(cell(2))
    toward, away = _profile(cell(1)), _profile(cell(3))
    if side is None or toward is None or away is None:
        return None
    flipped = side[:, ::-1]
    return _cos(toward, side) - _cos(toward, flipped), _cos(away, side) - _cos(away, flipped)


def main(argv: list[str]) -> int:
    exempt = {int(x) for a in argv if a.startswith("--exempt=") for x in a[9:].split(",") if x}
    margin = next((float(a[9:]) for a in argv if a.startswith("--margin=")), 0.02)
    flagged = 0
    for path in [a for a in argv if not a.startswith("--")]:
        atlas = np.asarray(Image.open(path).convert("RGBA"))
        for row in range(atlas.shape[0] // CELL_PX):
            m = row_margins(atlas, row)
            if m is None:
                continue
            bad = m[0] < -margin or m[1] > margin
            tag = "exempt" if row in exempt else ("FLAGGED" if bad else "ok")
            flagged += int(bad and row not in exempt)
            print(f"{path} row {row}: col1 {m[0]:+.3f} col3 {m[1]:+.3f} {tag}")
    print(f"flagged {flagged}")
    return 1 if flagged else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
