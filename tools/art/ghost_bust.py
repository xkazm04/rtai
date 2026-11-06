"""d8 chars: cut a ghost's tilt card strip from a magenta production sheet (owner fix: ghost sheets on
magenta, since the soul teal keys poorly on green).

usage: python -I tools/art/ghost_bust.py <sheet.png> <out.png> [frames=5] [cell_h=192] [tol=90]
       [--debug=<png>]

The sheet holds N copies of one part in a row (front, front three-quarter, side, back three-quarter,
back, turned to screen right) on flat #FF00FF. Keys the magenta out (distance tolerance `tol` with a
soft edge), despills the kept edge (no pixel keeps red AND blue leading green, so the teal wisps lose
their pink fringe), finds the N widest column runs, crops each, bottom-aligns every copy in a common
cell and scales the cells to cell_h px tall: one horizontal strip, frame i at x = i * cell_w. The
art is drawn raw (the ghosts' parts are raw: decisions.md 2026-11-05). Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import cut_facings as cf  # noqa: E402

KEY = np.array([255, 0, 255], dtype=np.float32)


def key_magenta(img: Image.Image, tol: float) -> np.ndarray:
    a = np.asarray(img.convert("RGB"), dtype=np.float32)
    dist = np.sqrt(((a - KEY) ** 2).sum(axis=2))
    lead = np.minimum(a[:, :, 0], a[:, :, 2]) - a[:, :, 1]
    alpha = np.clip((dist - tol) / 40.0, 0.0, 1.0)
    alpha[lead > 150] = 0.0
    rgb = a.copy()
    # despill: red and blue together may not lead green by more than a hair on a kept pixel
    spill = np.clip(lead - 12.0, 0.0, None)
    rgb[:, :, 0] -= spill
    rgb[:, :, 2] -= spill * 0.5
    rgb = np.clip(rgb, 0.0, 255.0)
    return np.dstack([rgb, alpha * 255.0]).astype(np.uint8)


def strip_of(rgba: np.ndarray, n: int, cell_h: int) -> Image.Image:
    solid = rgba[:, :, 3] > 128
    spans = sorted(cf.runs(solid.sum(axis=0) > 2), key=lambda s: s[1] - s[0], reverse=True)[:n]
    spans.sort()
    if len(spans) != n:
        sys.exit(f"found {len(spans)} copies, wanted {n}")
    crops = []
    for x0, x1 in spans:
        rows = np.where(solid[:, x0:x1].sum(axis=1) > 0)[0]
        crops.append(rgba[rows[0] : rows[-1] + 1, x0:x1])
    cw = max(c.shape[1] for c in crops) + 4
    ch = max(c.shape[0] for c in crops) + 4
    w = round(cw * cell_h / ch)
    strip = Image.new("RGBA", (w * n, cell_h), (0, 0, 0, 0))
    for i, c in enumerate(crops):
        cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cell.paste(Image.fromarray(c), ((cw - c.shape[1]) // 2, ch - 2 - c.shape[0]))
        strip.paste(cell.resize((w, cell_h), Image.LANCZOS), (i * w, 0))
    return strip


def main() -> None:
    src, dst = sys.argv[1], sys.argv[2]
    rest = [a for a in sys.argv[3:] if not a.startswith("--")]
    n = int(rest[0]) if len(rest) > 0 else 5
    cell_h = int(rest[1]) if len(rest) > 1 else 192
    tol = float(rest[2]) if len(rest) > 2 else 90.0
    out = strip_of(key_magenta(Image.open(src), tol), n, cell_h)
    out.save(dst)
    for a in sys.argv:
        if a.startswith("--debug="):
            bg = Image.new("RGBA", out.size, (90, 96, 104, 255))
            bg.alpha_composite(out)
            bg.resize((out.width * 2, out.height * 2), Image.NEAREST).save(a[8:])
    print(f"{dst}: {n} frames of {out.width // n}x{cell_h}")


if __name__ == "__main__":
    main()
