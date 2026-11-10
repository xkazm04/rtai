"""n13 weapon art: the asset lane's drawn wind-up cells laid into Rivet's wind-up strips.

usage: python -I tools/art/rivet_windup_cells.py [--manifest=tools/art/rivet_windup_cells.json]
       [--only=<weapon>] [--sim=<preview.png>]

For each weapon and art key in the manifest: the library's side and camera wind-up figures (keyed,
already at the shipped strip's scale: gtai-art/library/keyed/rivet/rivet_windup_70_cells/, asset
lane it309) are laid on a two-cell strip `rivet_eq_<weapon>_windup.png` beside the equipped strip
(0 = side, 1 = camera: RivetWindup's slot). Each cell is as wide as the equipped strip's cell (wider
if a figure needs it) and tall enough for the raised weapon; the figure's feet (its lowest opaque
row) stand on the equipped strip's pad (PAD px above the cell bottom, RivetStrips.foot_px), and its
body's centre (the alpha centroid of the figure's lower BODY_FRAC rows, where a raised weapon never
is) sits on the cell's centre column, where RivetFrames puts the rig. Per cell `k` scales the figure
(premultiplied Lanczos; the sword's camera figure is drawn about 8 % long: k 0.92) and `dx` shifts
it (px, set by eye on film). A row's `ink_rim` runs blade_ink_rim.py over the strip (the sword's B
rim). No new colour: whole drawn figures, resampled only where k != 1. Deterministic.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
PAD = 2
BODY_FRAC = 0.45


def _fig(path: Path, k: float) -> Image.Image:
    im = Image.open(path).convert("RGBA")
    if k != 1.0:
        size = (max(1, round(im.width * k)), max(1, round(im.height * k)))
        im = im.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    a = np.asarray(im)[..., 3]
    rows, cols = np.where(a.any(axis=1))[0], np.where(a.any(axis=0))[0]
    return im.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))


def _anchor(im: Image.Image) -> tuple:
    """(body centre x, feet y) in the figure's own px: feet = the lowest row with solid alpha."""
    a = np.asarray(im)[..., 3] > 128
    rows = np.where(a.any(axis=1))[0]
    feet = int(rows[-1])
    top = int(rows[0] + (rows[-1] - rows[0]) * (1.0 - BODY_FRAC))
    ys, xs = np.nonzero(a[top : feet + 1])
    return float(xs.mean()), feet


def strip(lib: Path, eq: Path, cells: dict) -> Image.Image:
    eq_im = Image.open(eq)
    cw, ch = eq_im.width // 8, eq_im.height
    figs = []
    for slot in ("side", "cam"):
        c = cells[slot]
        im = _fig(lib / c["file"], float(c.get("k", 1.0)))
        ax, feet = _anchor(im)
        figs.append((im, ax + float(c.get("dx", 0.0)), feet))
    half = max(max(ax, im.width - ax) for im, ax, _ in figs)
    w = max(cw, int(np.ceil(2 * half)) + 4)
    h = max(ch, max(feet for _, _, feet in figs) + 1 + PAD + 2)
    out = Image.new("RGBA", (w * 2, h), (0, 0, 0, 0))
    for i, (im, ax, feet) in enumerate(figs):
        out.alpha_composite(im, (i * w + round(w / 2 - ax), h - PAD - 1 - feet))
    return out


def run(manifest: str, only: str = "", sim: str = "") -> None:
    man = json.loads(Path(manifest).read_text(encoding="utf-8"))
    lib, out = Path(man["library"]), ROOT / man["out"]
    tiles = []
    for art, rows in man["strips"].items():
        for weapon, row in rows.items():
            if only and weapon != only:
                continue
            eq = out / art / f"rivet_eq_{weapon}.png"
            img = strip(lib / row.get("dir", ""), eq, row["cells"])
            dst = out / art / f"rivet_eq_{weapon}_windup.png"
            if sim:
                tiles.append(img)
                continue
            img.save(dst, optimize=True)
            if "ink_rim" in row:
                sys.path.insert(0, str(HERE))
                from blade_ink_rim import ink_rim  # noqa: E402

                ink_rim(str(dst), str(dst), float(row["ink_rim"]["px"]),
                        float(row["ink_rim"]["reach"]), 2)
            print(f"{art} {weapon}: {img.size} -> {dst}")
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
        opts.get("sim", ""))


if __name__ == "__main__":
    main()
