"""d8 chars: cut Rivet's tilt bust card (head + hazard collar + chest) from the 55-degree angle sheet.

usage: python -I tools/art/rivet_bust.py <rivet_55.png> <out.png> [cell_h] [--debug=<png>]

The sheet's top row holds five full-body facings (front, front three-quarter, side, back
three-quarter, back, turned to screen right) on chroma #00B140. Per facing, everything above the
collar's lower edge is kept whole (the visor head and the collar); below it only the chest band
(the torso plate, not the shoulder balls or arms: the rig's own lifted arms draw those) down to the
chest plate's lower edge, which fades out over FADE px. The five busts are then cut, bottom-aligned
and printed to the game's tan core (tan55; key_out from tools/art/cut_facings.py). Deterministic.
"""

import sys

import numpy as np
from PIL import Image

sys.path.insert(0, __file__.rsplit("\\", 1)[0].rsplit("/", 1)[0])
import cut_facings as cf  # noqa: E402

# per facing (sheet px): figure x0, x1; whole above y_h (head, visor, ear discs); the collar band
# cx0..cx1 down to its lower edge y_c (not the shoulder balls beside it); the chest band tx0..tx1
# down to the chest plate's lower edge y_b
FACINGS = [
    (77, 345, 200, 145, 282, 268, 158, 278, 318),
    (397, 624, 196, 444, 574, 236, 468, 570, 318),
    (713, 850, 250, 713, 850, 250, 718, 834, 318),
    (946, 1137, 200, 988, 1118, 254, 996, 1118, 312),
    (1201, 1462, 205, 1272, 1403, 242, 1288, 1388, 312),
]
TOP = 44
FADE = 6
INK = 4


def bust_mask(h: int, w: int) -> np.ndarray:
    m = np.zeros((h, w), dtype=np.float32)
    for x0, x1, yh, cx0, cx1, yc, tx0, tx1, yb in FACINGS:
        m[TOP:yh, x0:x1] = 1.0
        m[yh:yc, cx0:cx1] = 1.0
        for y in range(yc, yb):
            m[y, tx0:tx1] = min(1.0, (yb - y) / FADE)
    return m


def reink(rgba: np.ndarray, whole: np.ndarray) -> np.ndarray:
    """Where the mask cut through opaque art (an arm, the shoulder ball, the chest's lower edge), the
    new edge gets the ink outline INK px wide, so a cut reads as drawn, not sliced."""
    from scipy.ndimage import binary_dilation

    kept = rgba[:, :, 3] > 128
    cut = whole & ~kept
    edge = kept & binary_dilation(cut, iterations=INK)
    out = rgba.copy()
    out[edge, :3] = cf.PRINT[1].astype(np.uint8)
    out[edge, 3] = 255
    return out


def tan55(rgba: np.ndarray) -> np.ndarray:
    """The sheet's warm tan printed to the game's tan core with more steps than cut_facings.tan
    (whose thresholds print this sheet's lighter tan all cream): highlight cream, body light tan,
    shade tan, seams, rivets and outline ink, the collar's stripes vermilion."""
    rgb = rgba[:, :, :3].astype(np.float32)
    lum = (rgb @ np.array([0.299, 0.587, 0.114], dtype=np.float32)) / 255.0
    verm = rgb[:, :, 0] - np.maximum(rgb[:, :, 1], rgb[:, :, 2]) > 62
    out = np.zeros_like(rgb)
    out[:] = cf.PRINT[0]
    out[lum < 0.80] = cf.TAN_LT
    out[lum < 0.54] = cf.TAN
    out[lum < 0.28] = cf.PRINT[1]
    out[verm] = cf.PRINT[4]
    res = rgba.copy()
    res[:, :, :3] = out.astype(np.uint8)
    return res


def main() -> None:
    src, dst = sys.argv[1], sys.argv[2]
    rest = [a for a in sys.argv[3:] if not a.startswith("--")]
    cell_h = int(rest[0]) if rest else 192
    rgba = cf.key_out(Image.open(src), 70.0).astype(np.float32)
    whole = rgba[:, :, 3] > 128
    rgba[:, :, 3] *= bust_mask(rgba.shape[0], rgba.shape[1])
    rgba = reink(rgba.astype(np.uint8), whole)
    solid = rgba[:, :, 3] > 128
    crops = []
    for x0, x1, *_ in FACINGS:
        rows = np.where(solid[:, x0:x1].any(axis=1))[0]
        cols = np.where(solid[:, x0:x1].any(axis=0))[0]
        crops.append(rgba[rows[0] : rows[-1] + 1, x0 + cols[0] : x0 + cols[-1] + 1])
    cw = max(c.shape[1] for c in crops) + 4
    ch = max(c.shape[0] for c in crops) + 4
    w = round(cw * cell_h / ch)
    strip = Image.new("RGBA", (w * len(crops), cell_h), (0, 0, 0, 0))
    for i, c in enumerate(crops):
        cell = Image.new("RGBA", (cw, ch), (0, 0, 0, 0))
        cell.paste(Image.fromarray(c), ((cw - c.shape[1]) // 2, ch - 2 - c.shape[0]))
        strip.paste(cell.resize((w, cell_h), Image.LANCZOS), (i * w, 0))
    out = Image.fromarray(tan55(np.asarray(strip)))
    out.save(dst)
    for a in sys.argv:
        if a.startswith("--debug="):
            bg = Image.new("RGBA", out.size, (90, 96, 104, 255))
            bg.alpha_composite(out)
            bg.resize((out.width * 2, out.height * 2), Image.NEAREST).save(a[8:])
    print(f"{dst}: {len(crops)} frames of {w}x{cell_h}")


if __name__ == "__main__":
    main()
