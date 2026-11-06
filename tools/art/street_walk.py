"""n8 street: cut a library WALK strip (keyed, 5 rows = facings x 4 columns = stride frames) into a
game grid: 5 columns (facing camera, 3/4 toward, side, 3/4 away, back; the RigHeadCard frame order)
x 4 rows (contact, pass, contact, pass), every cell the same size, cell_h px tall.

usage: python -I tools/art/street_walk.py <keyed_walk.png> <out.png> [cell_h=192]

Finds the five bands of figures (alpha row runs, else the emptiest scanline near each fifth) and the
four figures in each band (the four widest column runs). Each figure keeps its place in its stride:
its feet sit on the band's lowest foot line plus its own offset (the drawing's bob), and it sits on
the band's even spacing plus its own drift, so a row loops in place as drawn. One common cell over
all twenty (the widest and tallest placed figure + 4 px), scaled to cell_h. Raw art. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import cut_facings as cf  # noqa: E402


def _valley(prof: np.ndarray, a: float, b: float) -> int:
    lo, hi = int(a), int(b)
    return lo + int(np.argmin(prof[lo:hi]))


def _bands(prof: np.ndarray, n: int) -> list:
    spans = [s for s in cf.runs(prof > 0) if s[1] - s[0] > 30]
    if len(spans) == n:
        return spans
    ys = np.where(prof > 0)[0]
    a, b = ys[0], ys[-1] + 1
    st = (b - a) / n
    cuts = [a] + [_valley(prof, a + i * st - 0.3 * st, a + i * st + 0.3 * st) for i in range(1, n)]
    return list(zip(cuts, cuts[1:] + [b]))


def _figures(solid: np.ndarray, y0: int, y1: int) -> list:
    sub = solid[y0:y1]
    cols = sorted(cf.runs(sub.sum(axis=0) > 1), key=lambda s: s[1] - s[0], reverse=True)[:4]
    if len(cols) != 4:
        sys.exit(f"band {y0}-{y1}: found {len(cols)} figures, wanted 4")
    out = []
    for x0, x1 in sorted(cols):
        rows = np.where(sub[:, x0:x1].any(axis=1))[0]
        out.append((x0, y0 + rows[0], x1, y0 + rows[-1] + 1))
    return out


def main() -> None:
    args = sys.argv[1:]
    cell_h = int(args[2]) if len(args) > 2 else 192
    rgba = np.asarray(Image.open(args[0]).convert("RGBA"))
    solid = rgba[:, :, 3] > 128
    bands = _bands(solid.sum(axis=1).astype(np.int64), 5)
    placed = []  # (facing, frame, crop, dx from the cell centre, dy above the foot line)
    for f, (y0, y1) in enumerate(bands):
        boxes = _figures(solid, y0, y1)
        base = max(b[3] for b in boxes)
        cx = np.array([(b[0] + b[2]) / 2 for b in boxes])
        k = np.arange(4)
        fit = np.polyval(np.polyfit(k, cx, 1), k)
        for i, b in enumerate(boxes):
            crop = rgba[b[1] : b[3], b[0] : b[2]]
            placed.append((f, i, crop, b[0] - fit[i], base - b[3]))
        print(f"facing {f}: heights {[b[3] - b[1] for b in boxes]}, drift "
              f"{[round(c) for c in cx - fit]}, lift {[base - b[3] for b in boxes]}")
    half = max(max(-p[3], p[3] + p[2].shape[1]) for p in placed)
    cw = int(np.ceil(half * 2)) + 4
    ch = max(p[2].shape[0] + p[4] for p in placed) + 4
    w = round(cw * cell_h / ch)
    grid = Image.new("RGBA", (w * 5, cell_h * 4), (0, 0, 0, 0))
    for f, i, crop, dx, dy in placed:
        cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        at = (int(round(cw / 2 + dx)), ch - 2 - dy - crop.shape[0])
        cell.paste(Image.fromarray(crop), at)
        grid.paste(cell.resize((w, cell_h), Image.LANCZOS), (f * w, i * cell_h))
    grid.save(args[1])
    print(f"{args[1]}: 5 facings x 4 frames of {w}x{cell_h} (crop cell {cw}x{ch})")


if __name__ == "__main__":
    main()
