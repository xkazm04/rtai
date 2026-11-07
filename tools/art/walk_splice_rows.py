"""d9 seams: splice fresh rows of trimmed cells (<cells>/<row>_<col>.png, the asset library's
`<strip>_rfresh*_cells/`) into a keyed walk sheet (5 bands of 4 figures), for street_walk.py.

usage: python -I tools/art/walk_splice_rows.py <keyed_sheet.png> <cells_dir> <out.png> ROW [ROW ...]

ROW = band 1..5. The band's old figures are cleared; each fresh figure is centred on the old
figure's column and hung from one HEAD LINE (the band's foot line minus the tallest fresh figure),
as the library draws every row: all four tops level, the passing frames' feet higher. Standing the
trimmed cells on the foot line instead (the d9 it4 scratch splice) turned the drawn level head into
a 7-9 px dip at each passing frame. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import street_walk as sw  # noqa: E402


def _columns(band: np.ndarray) -> list:
    cp = band.sum(0)
    cols, x, w = [], 0, band.shape[1]
    while x < w:
        if cp[x] > 0:
            x0 = x
            while x < w and cp[x] > 0:
                x += 1
            cols.append((x0, x))
        x += 1
    return sorted(sorted(cols, key=lambda c: c[1] - c[0])[-4:])


def splice(arr: np.ndarray, cells_dir: str, row: int) -> np.ndarray:
    a = arr[..., 3] > 16
    y0, y1 = (int(v) for v in sw._bands(a.sum(1), 5)[row - 1])
    y1 = y0 + int(np.where(a[y0:y1].any(1))[0][-1]) + 1
    cols = _columns(a[y0:y1])
    cells = [Image.open(f"{cells_dir}/{row}_{c + 1}.png").convert("RGBA") for c in range(4)]
    head = y1 - max(c.height for c in cells)
    out = arr.copy()
    out[y0:y1] = 0
    img = Image.fromarray(out, "RGBA")
    for (x0, x1), cell in zip(cols, cells):
        img.alpha_composite(cell, ((x0 + x1) // 2 - cell.width // 2, head))
    print(f"row {row}: band {y0}-{y1}, head line {head}, heights {[c.height for c in cells]}")
    return np.asarray(img)


def main() -> None:
    sheet, cells_dir, out = sys.argv[1], sys.argv[2], sys.argv[3]
    arr = np.asarray(Image.open(sheet).convert("RGBA"))
    for row in sys.argv[4:]:
        arr = splice(arr, cells_dir, int(row))
    Image.fromarray(arr, "RGBA").save(out)


if __name__ == "__main__":
    main()
