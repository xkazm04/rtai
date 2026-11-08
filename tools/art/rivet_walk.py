"""d9 rivet (Call 2): pack the asset lane's walk cells into one game grid of whole figures.

usage: python -I tools/art/rivet_walk.py <cells_dir> <left_cells_dir> <out.png> [--fig_h=110] [--cols=4] [--json=<out.json>]

<cells_dir> holds 20 tight cells `r_c.png` (rows 1-5 = facings toward, 3/4 toward, profile, 3/4 away,
away; columns 1-4 = contact, passing, contact (the other foot), passing), <left_cells_dir> 12 (rows
1-3 = 3/4 left toward, left profile, 3/4 left away), as the library's walk-cells deliveries. The grid
is 4 columns x 8 rows in RivetFrames' base cell order (facings 0-4, left 0-2). One scale for every
cell (the median figure height of the facings rows = fig_h, so a stride never pulses in size; the
left rows matched on their own median height); each cell's anchor is its helmet's centre (the alpha
centre of its top quarter) on the cell's centre column and its lowest alpha row PAD px above the
cell's bottom. Premultiplied resampling. Deterministic. n9: --cols=8 packs the library's 8-frame
walk (columns contact, down, passing, up, contact (other foot), down, passing, up).
n9 it4: <left_cells_dir> = "mirror" builds the left rows from right rows 2-4 mirrored (a two-handed
hold without drawn left views: the heavy and flamer armed walks; the equipped strips mirror those too).
--tone=<ref.png> matches the grid's per-channel mean and spread (opaque pixels, straight RGB, alpha
untouched) to the reference strip's, so the walk does not change tone when the strip swaps (the armed
walks against the weapon's equipped strip: the library sheets read ~10-20 levels lighter).
--k=<k,kl> fixed scales for the right and left rows instead of the median height (the run8 cells are
pre-scaled by dome width to the walk8 rows, and run poses change the height: pass walk8's scales).
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


def _rows(folder: str, n: int, cols: int) -> list:
    return [[_cell(f"{folder}/{r}_{c}.png") for c in range(1, cols + 1)] for r in range(1, n + 1)]


def _mirrored(rows: list) -> list:
    out = []
    for r in rows[1:4]:
        row = []
        for c in r:
            im = c["im"].transpose(Image.FLIP_LEFT_RIGHT)
            x0, y0, x1, y1 = c["box"]
            w = im.width
            row.append({"im": im, "box": (w - x1, y0, w - x0, y1), "ax": w - c["ax"], "h": c["h"]})
        out.append(row)
    return out


def _tone(out: Image.Image, ref_path: str) -> Image.Image:
    a = np.asarray(out).astype(np.float64)
    r = np.asarray(Image.open(ref_path).convert("RGBA")).astype(np.float64)
    m, rm = a[:, :, 3] > 200, r[:, :, 3] > 200
    rgb = a[:, :, :3]
    mu, sd = rgb[m].mean(0), rgb[m].std(0)
    rmu, rsd = r[:, :, :3][rm].mean(0), r[:, :, :3][rm].std(0)
    a[:, :, :3] = np.clip((rgb - mu) * (rsd / sd) + rmu, 0, 255)
    return Image.fromarray(np.round(a).astype(np.uint8), "RGBA")


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    fig_h = float(opts.get("fig_h", 110))
    cols = int(opts.get("cols", COLS))
    rows = _rows(args[0], 5, cols)
    left = _mirrored(rows) if args[1] == "mirror" else _rows(args[1], 3, cols)
    k = fig_h / float(np.median([c["h"] for r in rows for c in r]))
    kl = fig_h / float(np.median([c["h"] for r in left for c in r]))
    if "k" in opts:  # fixed scales "k,kl" (cells pre-scaled to another grid's rows: the run to walk8)
        k, kl = (float(v) for v in opts["k"].split(","))
    items = [(c, k) for r in rows for c in r] + [(c, kl) for r in left for c in r]
    half = max(max(c["ax"] - c["box"][0], c["box"][2] - c["ax"]) * s for c, s in items)
    up = max(c["h"] * s for c, s in items)
    cw, ch = int(np.ceil(2 * half)) + 4, int(np.ceil(up)) + PAD + 2
    out = Image.new("RGBA", (cw * cols, ch * 8), (0, 0, 0, 0))
    for i, (c, s) in enumerate(items):
        x0, y0, x1, y1 = c["box"]
        fig = c["im"].crop((x0, y0, x1, y1)).convert("RGBa")
        size = (max(1, round((x1 - x0) * s)), max(1, round((y1 - y0) * s)))
        fig = fig.resize(size, Image.LANCZOS).convert("RGBA")
        col, row = i % cols, i // cols
        out.alpha_composite(fig, (col * cw + round(cw / 2 - (c["ax"] - x0) * s), (row + 1) * ch - PAD - size[1]))
    if "tone" in opts:
        out = _tone(out, opts["tone"])
    out.save(args[2], optimize=True)
    meta = {"cell": [cw, ch], "cols": cols, "rows": 8, "fig_h": fig_h, "pad": PAD, "scales": [round(k, 4), round(kl, 4)]}
    meta["src"] = [args[0], args[1]]
    meta["tone"] = opts.get("tone", "")
    if "json" in opts:
        with open(opts["json"], "w", encoding="utf-8") as fh:
            json.dump(meta, fh, indent=1, sort_keys=True)
    print(json.dumps(meta))


if __name__ == "__main__":
    main()
