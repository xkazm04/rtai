"""d8 chars: cut a street-cast head card strip (helmet/head + collar, 5 facings) from a keyed 55 game
view sheet of the assets library (gtai-art/library/keyed/street/<id>_55.png: alpha-keyed, five
standing facings in the top row, action poses below).

usage: python -I tools/art/street_head.py <sheet.png> <out.png> [band=0.3] [cell_h=128]

Finds the five figures in the top row (the widest alpha column runs above the sheet's middle),
crops each from its top down `band` of its own height (head and collar), bottom-aligns every crop in
a common cell and scales the cells to cell_h px tall: one strip, frame i at x = i * cell_w. Prints
each crop's head width (the widest run in its top fifth) so the card row's width can be set.
Raw art (no print). Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import cut_facings as cf  # noqa: E402


def main() -> None:
    args = sys.argv[1:]
    band = float(args[2]) if len(args) > 2 else 0.3
    cell_h = int(args[3]) if len(args) > 3 else 128
    rgba = np.asarray(Image.open(args[0]).convert("RGBA"))
    top = rgba[: int(rgba.shape[0] * 0.47)]
    solid = top[:, :, 3] > 128
    spans = sorted(cf.runs(solid.sum(axis=0) > 2), key=lambda s: s[1] - s[0], reverse=True)[:5]
    spans.sort()
    if len(spans) != 5:
        sys.exit(f"found {len(spans)} figures, wanted 5")
    crops = []
    for x0, x1 in spans:
        rows = np.where(solid[:, x0:x1].sum(axis=1) > 0)[0]
        y0, y1 = rows[0], rows[-1] + 1
        yb = y0 + int((y1 - y0) * band)
        sub = solid[y0:yb, x0:x1]
        cols = np.where(sub.sum(axis=0) > 0)[0]
        crops.append(top[y0:yb, x0 + cols[0] : x0 + cols[-1] + 1])
        head = solid[y0 : y0 + (y1 - y0) // 5, x0:x1].sum(axis=1).max()
        print(f"figure {len(crops)}: crop {crops[-1].shape[1]}x{crops[-1].shape[0]}, head {head}px")
    cw = max(c.shape[1] for c in crops) + 4
    ch = max(c.shape[0] for c in crops) + 4
    w = round(cw * cell_h / ch)
    strip = Image.new("RGBA", (w * 5, cell_h), (0, 0, 0, 0))
    for i, c in enumerate(crops):
        cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cell.paste(Image.fromarray(c), ((cw - c.shape[1]) // 2, ch - 2 - c.shape[0]))
        strip.paste(cell.resize((w, cell_h), Image.LANCZOS), (i * w, 0))
    strip.save(args[1])
    print(f"{args[1]}: 5 frames of {w}x{cell_h} (crop cell {cw}x{ch})")


if __name__ == "__main__":
    main()
