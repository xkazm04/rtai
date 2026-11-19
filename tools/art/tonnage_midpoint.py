"""Pack Tonnage's p70 profile in-between from the shipped landing pose."""

import hashlib
from pathlib import Path

import numpy as np
from PIL import Image


VIEW = Path(__file__).resolve().parents[2] / "project/features/souls/art/view/p70"
LANDING_RGBA = "4cd2ebc2bf4bcaa84cb5c10b17b06a6015b1dafe6753f487bbf49cd933b2a4de"


def warp_rows(image, dx, dy):
    """Inverse displacements of each horizontal scan line, in cell pixels."""
    width, height = image.size
    mesh = []
    for y in range(height):
        a, b = y + dy[y], y + 1 + dy[y + 1]
        l, r = dx[y], dx[y + 1]
        mesh.append(((0, y, width, y + 1), (l, a, r, b, width + r, b, width + l, a)))
    return image.transform(
        image.size, Image.Transform.MESH, mesh, Image.Resampling.BILINEAR
    )


def midpoint(landing):
    pixels = np.asarray(landing)
    y, x = np.indices(pixels.shape[:2])
    # Cut the two near shafts at their visible boundaries below the belly.
    # The two far pads stay behind them.
    edge = np.interp(y, [185, 194, 203, 211], [49, 44, 37, 36])
    trailing = (y >= 185) & (x < edge)
    leading = (y >= 190) & (x >= 112)
    body = pixels.copy()
    body[trailing | leading] = 0
    result = Image.fromarray(body)
    rows = np.arange(landing.height + 1)
    zero = np.zeros_like(rows)
    # Stance centre C6 = 62, C7 = 17.5: put the landing pad 22.25 px
    # forward and lift the approaching pad, keeping both pad widths.
    swing = np.interp(rows, [190, 208], [0, 5])
    stance = np.interp(rows, [185, 211], [0, -22.25])
    for mask, dx, dy in [(leading, zero, swing), (trailing, stance, zero)]:
        layer = pixels.copy()
        layer[~mask] = 0
        result.alpha_composite(warp_rows(Image.fromarray(layer), dx, dy))
    # In the keys the housing moves 1.4 px right and 6 px down. Place it
    # halfway through that dip. The displacement fades out along the shafts.
    upper = np.interp(rows, [184, 214], [1, 0])
    return warp_rows(result, 0.7 * upper, 3 * upper)


def pack():
    sheet = Image.open(VIEW / "tonnage_walk8.png").convert("RGBA")
    cell = sheet.crop((6 * 163, 2 * 230, 7 * 163, 3 * 230))
    assert hashlib.sha256(cell.tobytes()).hexdigest() == LANDING_RGBA
    single = Image.new("RGBA", (163, 5 * 230))
    single.paste(midpoint(cell), (0, 2 * 230))
    single.save(VIEW / "tonnage_walk8_mid.png")


if __name__ == "__main__":
    pack()
