"""View lab: cut a chroma-green facing sheet (N copies of one part in a row) into a game strip.

usage: python -I tools/art/cut_facings.py <sheet.png> <out.png> <frames> <cell_h> [tol] [--snap | --tan]
       [--glass]

Keys out the flat #00B140 background (distance tolerance `tol`, default 70, with a soft edge),
finds the N largest column runs of opaque pixels, crops each to its own box, bottom-aligns every
copy in a common cell (the widest and tallest copy), scales the cells to cell_h px tall and writes
one horizontal strip, frame i at x = i * cell_w. --snap prints every pixel to the nearest part
print ink (print_part.gdshader: cream, ink, the two wash tints, vermilion, gold, dark gold) for a
card drawn raw (its gold would print vermilion through the part shader). --glass fills the keyed
holes enclosed by the part (a clear visor the chroma showed through) with an opaque pale steel, so
the head has no see-through hole. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

KEY = np.array([0, 177, 64], dtype=np.float32)


def key_out(img: Image.Image, tol: float) -> np.ndarray:
    a = np.asarray(img.convert("RGB"), dtype=np.float32)
    dist = np.sqrt(((a - KEY) ** 2).sum(axis=2))
    green_lead = a[:, :, 1] - np.maximum(a[:, :, 0], a[:, :, 2])
    alpha = np.clip((dist - tol) / 30.0, 0.0, 1.0)
    alpha[green_lead > 60] = 0.0
    rgb = a.copy()
    # despill: no channel may let green lead on a kept edge pixel
    rgb[:, :, 1] = np.minimum(rgb[:, :, 1], np.maximum(rgb[:, :, 0], rgb[:, :, 2]) + 8)
    out = np.dstack([rgb, alpha * 255.0]).astype(np.uint8)
    return out


PRINT = np.array(
    [[0.949, 0.910, 0.835], [0.090, 0.075, 0.106], [0.691, 0.660, 0.616], [0.417, 0.392, 0.383],
     [0.910, 0.314, 0.165], [0.851, 0.663, 0.200], [0.541, 0.392, 0.094]],
    dtype=np.float32,
) * 255.0


def snap(rgba: np.ndarray) -> np.ndarray:
    rgb = rgba[:, :, :3].astype(np.float32)
    d = ((rgb[:, :, None, :] - PRINT[None, None, :, :]) ** 2).sum(axis=3)
    out = rgba.copy()
    out[:, :, :3] = PRINT[d.argmin(axis=2)].astype(np.uint8)
    return out


TAN_LT = np.array([0.860, 0.786, 0.673]) * 255.0
TAN = np.array([0.800, 0.700, 0.565]) * 255.0


def tan(rgba: np.ndarray) -> np.ndarray:
    """Rivet's game read (cast-9, the light tan core): dark steel prints by value as ink, tan and
    light tan, the cream glow cream, the vermilion collar vermilion (the logo's steel is darker
    than the game body, so the part shader would print it solid ink at 32-48 px/m)."""
    rgb = rgba[:, :, :3].astype(np.float32)
    lum = (rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32)) / 255.0
    verm = rgb[:, :, 0] - np.maximum(rgb[:, :, 1], rgb[:, :, 2]) > 62
    out = np.zeros_like(rgb)
    out[:] = PRINT[0]
    out[lum < 0.62] = TAN_LT
    out[lum < 0.36] = TAN
    out[lum < 0.22] = PRINT[1]
    out[verm] = PRINT[4]
    res = rgba.copy()
    res[:, :, :3] = out.astype(np.uint8)
    return res


GLASS = np.array([196, 204, 214], dtype=np.uint8)


def glass(rgba: np.ndarray) -> np.ndarray:
    from scipy.ndimage import binary_fill_holes

    solid = rgba[:, :, 3] > 128
    hole = binary_fill_holes(solid) & ~solid
    out = rgba.copy()
    out[hole, :3] = GLASS
    out[hole, 3] = 255
    return out


def runs(mask_cols: np.ndarray) -> list:
    spans, start = [], None
    for x, on in enumerate(mask_cols):
        if on and start is None:
            start = x
        elif not on and start is not None:
            spans.append((start, x))
            start = None
    if start is not None:
        spans.append((start, len(mask_cols)))
    return spans


def main() -> None:
    src, dst, n, cell_h = sys.argv[1], sys.argv[2], int(sys.argv[3]), int(sys.argv[4])
    rest = [a for a in sys.argv[5:] if not a.startswith("--")]
    tol = float(rest[0]) if rest else 70.0
    rgba = key_out(Image.open(src), tol)
    if "--glass" in sys.argv:
        rgba = glass(rgba)
    solid = rgba[:, :, 3] > 128
    spans = sorted(runs(solid.sum(axis=0) > 2), key=lambda s: s[1] - s[0], reverse=True)[:n]
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
    if "--snap" in sys.argv:
        strip = Image.fromarray(snap(np.asarray(strip)))
    if "--tan" in sys.argv:
        strip = Image.fromarray(tan(np.asarray(strip)))
    strip.save(dst)
    print(f"{dst}: {n} frames of {w}x{cell_h}")


if __name__ == "__main__":
    main()
