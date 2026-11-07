"""d9 rivet (Call 2): pack the asset lane's walk cells into one game grid of whole figures.

usage: python -I tools/art/rivet_walk.py <cells_dir> <left_cells_dir> <out.png> [--fig_h=110] [--json=<out.json>]

<cells_dir> holds 20 tight cells `r_c.png` (rows 1-5 = facings toward, 3/4 toward, profile, 3/4 away,
away; columns 1-4 = contact, passing, contact (the other foot), passing), <left_cells_dir> 12 (rows
1-3 = 3/4 left toward, left profile, 3/4 left away), as the library's walk-cells deliveries. The grid
is 4 columns x 8 rows in RivetFrames' base cell order (facings 0-4, left 0-2). One scale for every
cell (the median figure height of the facings rows = fig_h, so a stride never pulses in size; the
left rows matched on their own median height); each cell's anchor is its helmet's centre (the alpha
centre of its top quarter) on the cell's centre column and its lowest alpha row PAD px above the
cell's bottom. Premultiplied resampling. Deterministic.
"""

import json
import sys

import numpy as np
from PIL import Image

PAD = 2
COLS = 4


def _cell(path: str) -> dict:
    im = Image.open(path).convert("RGBA")
    a = np.asarray(im)[:, :, 3] > 24
    ys, xs = np.nonzero(a)
    if len(ys) == 0:
        sys.exit(f"empty cell {path}")
    y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
    top = a[y0 : y0 + max(1, (y1 - y0) // 4), x0:x1]
    ax = x0 + float(np.nonzero(top)[1].mean())
    return {"im": im, "box": (x0, y0, x1, y1), "ax": ax, "h": y1 - y0}


def _rows(folder: str, n: int) -> list:
    return [[_cell(f"{folder}/{r}_{c}.png") for c in range(1, COLS + 1)] for r in range(1, n + 1)]


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    fig_h = float(opts.get("fig_h", 110))
    rows, left = _rows(args[0], 5), _rows(args[1], 3)
    k = fig_h / float(np.median([c["h"] for r in rows for c in r]))
    kl = fig_h / float(np.median([c["h"] for r in left for c in r]))
    items = [(c, k) for r in rows for c in r] + [(c, kl) for r in left for c in r]
    half = max(max(c["ax"] - c["box"][0], c["box"][2] - c["ax"]) * s for c, s in items)
    up = max(c["h"] * s for c, s in items)
    cw, ch = int(np.ceil(2 * half)) + 4, int(np.ceil(up)) + PAD + 2
    out = Image.new("RGBA", (cw * COLS, ch * 8), (0, 0, 0, 0))
    for i, (c, s) in enumerate(items):
        x0, y0, x1, y1 = c["box"]
        fig = c["im"].crop((x0, y0, x1, y1)).convert("RGBa")
        size = (max(1, round((x1 - x0) * s)), max(1, round((y1 - y0) * s)))
        fig = fig.resize(size, Image.LANCZOS).convert("RGBA")
        col, row = i % COLS, i // COLS
        out.alpha_composite(fig, (col * cw + round(cw / 2 - (c["ax"] - x0) * s), (row + 1) * ch - PAD - size[1]))
    out.save(args[2], optimize=True)
    meta = {"cell": [cw, ch], "cols": COLS, "rows": 8, "fig_h": fig_h, "pad": PAD, "scales": [round(k, 4), round(kl, 4)]}
    meta["src"] = [args[0], args[1]]
    if "json" in opts:
        with open(opts["json"], "w", encoding="utf-8") as fh:
            json.dump(meta, fh, indent=1, sort_keys=True)
    print(json.dumps(meta))


if __name__ == "__main__":
    main()
