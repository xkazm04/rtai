"""n13 weapon art: the asset lane's drawn wind-up cells laid into Rivet's wind-up strips.

usage: python -I tools/art/rivet_windup_cells.py [--manifest=tools/art/rivet_windup_cells.json]
       [--only=<row>] [--art=<p70|p55>] [--sim=<preview.png>]

For each row (an equipped strip's name after `rivet_eq_`) and art key in the manifest: the library's
drawn wind-up figures are laid on a strip `rivet_eq_<row>_windup.png` beside the equipped strip
(RivetWindup's slot: 0 = side, 1 = camera; a `_left` row has one cell, the drawn left side wind-up).
A cell's figure is a keyed file (`file`: the it309 pre-cut p70 cells, already at the strip's scale,
or a full keyed figure) or figure `fig` (0 = left, 1 = right) of a row's two-figure `sheet` (the
it313 / it317 p55 and chainsaw pairs, drawn at the keyed sheet's action-band scale: the row's
`sheet_k` is the cutter's action scale for that equipped row, rivet_frames.py's printed `scales`).
Each cell is as wide as the equipped strip's cell (wider if a figure needs it; in the wind-up strip's
own px: n14, the equipped strip may be cut at x1.5, RivetRes.X15, read from its rivet_frames.json
fig_h; a row's `res` is the wind-up strip's own, 1.0 = 110 space; `min_cell` pins a cell measured
before such a re-cut) and tall enough for the raised weapon; the figure's feet (its lowest opaque row)
stand on the pad (PAD px above the cell bottom, RivetStrips.foot_px), and its body's centre (the
alpha centroid of its lower BODY_FRAC rows, where a raised weapon never is) sits on the cell's
centre column, where RivetFrames puts the rig. Per cell `k` scales the figure (premultiplied
Lanczos) and `dx` shifts it (px), both set by eye against the facings and strikes. A row's `ink_rim`
runs blade_ink_rim.py over the strip (the sword's B rim). No new colour. Deterministic.
n15: a row with `eq` (the equipped strip it sits beside, e.g. `electro_baton_left`) and `name`
(the file after `rivet_eq_`, e.g. `electro_baton_left_strike`) writes that file instead of
`<row>_windup.png`: the baton's drawn left strike cell (RivetWindup.LEFT_STRIKE_FILE).
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
PAD = 2
BODY_FRAC = 0.45
SLOTS = ("side", "cam", "left")


def _scale(im: Image.Image, k: float) -> Image.Image:
    if k != 1.0:
        size = (max(1, round(im.width * k)), max(1, round(im.height * k)))
        im = im.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    a = np.asarray(im)[..., 3]
    rows, cols = np.where(a.any(axis=1))[0], np.where(a.any(axis=0))[0]
    return im.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))


def sheet_fig(path: Path, i: int) -> Image.Image:
    """Figure `i` (by x) of a two-figure keyed sheet: the two largest alpha components are the
    figures; every other piece (a spark, a loose cable end) joins the one nearest in x."""
    im = Image.open(path).convert("RGBA")
    a = np.asarray(im)[..., 3]
    lab, n = ndimage.label(a > 0)
    sizes = ndimage.sum(np.ones_like(lab), lab, range(1, n + 1))
    cx = [c[1] for c in ndimage.center_of_mass(np.ones_like(lab), lab, range(1, n + 1))]
    seeds = sorted(np.argsort(sizes)[::-1][:2], key=lambda j: cx[j])
    mine = [j + 1 for j in range(n) if min((0, 1), key=lambda s: abs(cx[j] - cx[seeds[s]])) == i]
    rgba = np.asarray(im).copy()
    rgba[..., 3] = np.where(np.isin(lab, mine), rgba[..., 3], 0)
    return Image.fromarray(rgba, "RGBA")


def _fig(lib: Path, row: dict, c: dict) -> Image.Image:
    if "fig" in c:
        src = sheet_fig(lib / row["sheet"], int(c["fig"]))
        return _scale(src, float(row["sheet_k"]) * float(c.get("k", 1.0)))
    return _scale(Image.open(lib / c["file"]).convert("RGBA"), float(c.get("k", 1.0)))


def _anchor(im: Image.Image) -> tuple:
    """(body centre x, feet y) in the figure's own px: feet = the lowest row with solid alpha."""
    a = np.asarray(im)[..., 3] > 128
    rows = np.where(a.any(axis=1))[0]
    feet = int(rows[-1])
    top = int(rows[0] + (rows[-1] - rows[0]) * (1.0 - BODY_FRAC))
    ys, xs = np.nonzero(a[top : feet + 1])
    return float(xs.mean()), feet


def eq_cell(eq: Path, row: dict, eq_res: float) -> tuple:
    """The equipped strip's cell in the wind-up strip's px (its res over the equipped strip's)."""
    if "min_cell" in row:
        return tuple(int(v) for v in row["min_cell"])
    im = Image.open(eq)
    k = float(row.get("res", 1.0)) / eq_res
    return int(im.width // int(row.get("eq_cells", 8)) * k), int(im.height * k)


def strip(lib: Path, eq: Path, row: dict, eq_res: float = 1.0) -> Image.Image:
    cw, ch = eq_cell(eq, row, eq_res)
    figs = []
    for slot in [s for s in SLOTS if s in row["cells"]]:
        c = row["cells"][slot]
        im = _fig(lib, row, c)
        ax, feet = _anchor(im)
        figs.append((im, ax + float(c.get("dx", 0.0)), feet))
    half = max(max(ax, im.width - ax) for im, ax, _ in figs)
    w = max(cw, int(np.ceil(2 * half)) + 4)
    h = max(ch, max(feet for _, _, feet in figs) + 1 + PAD + 2)
    out = Image.new("RGBA", (w * len(figs), h), (0, 0, 0, 0))
    for i, (im, ax, feet) in enumerate(figs):
        out.alpha_composite(im, (i * w + round(w / 2 - ax), h - PAD - 1 - feet))
    return out


def eq_res_of(art: str, name: str) -> float:
    """The equipped strip's px per 110-space px: its rivet_frames.json fig_h over the manifest's."""
    man = json.loads((HERE / "rivet_frames.json").read_text(encoding="utf-8"))
    row = man["strips"].get(art, {}).get(f"rivet_eq_{name}", {})
    return float(row.get("fig_h", man["fig_h"])) / float(man["fig_h"])


def run(manifest: str, only: str = "", sim: str = "", only_art: str = "") -> None:
    man = json.loads(Path(manifest).read_text(encoding="utf-8"))
    lib, out = Path(man["library"]), ROOT / man["out"]
    tiles = []
    for art, rows in man["strips"].items():
        for name, row in rows.items():
            if (only and name != only) or (only_art and art != only_art):
                continue
            base = row.get("eq", name)
            eq = out / art / f"rivet_eq_{base}.png"
            img = strip(lib / row.get("dir", ""), eq, row, eq_res_of(art, base))
            dst = out / art / (f"rivet_eq_{row['name']}.png" if "name" in row else f"rivet_eq_{name}_windup.png")
            if sim:
                tiles.append(img)
                continue
            img.save(dst, optimize=True)
            if "ink_rim" in row:
                sys.path.insert(0, str(HERE))
                from blade_ink_rim import ink_rim  # noqa: E402

                ink_rim(str(dst), str(dst), float(row["ink_rim"]["px"]),
                        float(row["ink_rim"]["reach"]), len(row["cells"]))
            print(f"{art} {name}: {img.size} -> {dst}")
    if sim:
        sheet = Image.new("RGBA", (max(t.width for t in tiles), sum(t.height for t in tiles)),
                          (110, 100, 100, 255))
        y = 0
        for t in tiles:
            sheet.alpha_composite(t, (0, y))
            y += t.height
        sheet.save(sim)


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[-1] for a in sys.argv[1:] if a.startswith("--")}
    run(opts.get("manifest", str(HERE / "rivet_windup_cells.json")), opts.get("only", ""),
        opts.get("sim", ""), opts.get("art", ""))


if __name__ == "__main__":
    main()
