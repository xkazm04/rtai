"""Pack p70 right-profile in-betweens from Tonnage's shipped keys, in atlas order."""

import argparse
import hashlib
from pathlib import Path

import cv2
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


# Zero-based outgoing step. Each pin tracks the same visible pad between keys
# (source centre x, lowest y, neighbour centre x).
# The first key named in each row supplies the ink. The pins in that column
# remain rigid at the sole and taper toward their sockets under the housing.
PADS = {
    0: (1, [(27, 211, 29), (124.5, 227, 135.5)]),
    1: (2, [(26, 213, 27), (99.5, 227, 124.5), (130, 202, 130)]),
    2: (2, [(26, 213, 24), (99.5, 227, 79.5), (130, 202, 144)]),
    4: (5, [(19, 210, 27), (62, 227, 75.5), (139, 216, 139)]),
    8: (8, [(42, 208, 33), (134.5, 227, 121)]),
    9: (10, [(33, 209, 33), (110.5, 227, 121), (124, 199, 135)]),
    10: (11, [(25, 216, 33), (96, 227, 110.5), (138, 206, 124)]),
    11: (12, [(28, 211, 25), (78, 227, 96), (131, 204, 138)]),
    12: (12, [(28, 211, 27), (78, 227, 28), (131, 204, 140)]),
}
STEPS = (5, *PADS)


def piston_ink(key, neighbour):
    """C11 has keyed-out metal. Borrow the corresponding C10 metal under its rim."""
    pixels = np.array(key)
    _, labels = cv2.connectedComponents((pixels[..., 3] < 247).astype("uint8"))
    holes = {labels[y, x] for x, y in [(102, 198), (110, 214), (109, 218)]}
    yy, xx = np.indices(pixels.shape[:2], dtype=np.float32)
    source_y = np.interp(yy, [186, 211, 216, 227], [194, 211, 216, 227])
    here = np.interp(yy, [186, 211, 216], [97, 107, 110.5])
    there = np.interp(source_y, [194, 211, 216], [126, 132, 134])
    sample = cv2.remap(np.asarray(neighbour), (xx - here + there).astype("float32"),
                       source_y.astype("float32"), cv2.INTER_LINEAR)
    missing = np.isin(labels, list(holes)) & (xx > 85) & (yy > 184)
    pixels[missing] = sample[missing]
    # The socket behind the trailing foot is open in C11. Seat the back
    # piston from C10 behind its existing rim, aligned at the belly.
    under = Image.new("RGBA", key.size)
    under.paste(neighbour.crop((49, 193, 78, 213)), (46, 186))
    under.alpha_composite(Image.fromarray(pixels))
    return under


def between(key, neighbour, pins):
    # Register the rigid crown and print by template matching. Interpolate
    # independent sole displacements below it without blending two outlines.
    def gray(im):
        return cv2.cvtColor(np.asarray(im), cv2.COLOR_RGBA2GRAY)

    patch = gray(key)[65:163, 28:134]
    score = cv2.matchTemplate(gray(neighbour), patch, cv2.TM_CCOEFF_NORMED)
    _, _, _, match = cv2.minMaxLoc(score)
    body = (np.array(match) - [28, 65]) / 2
    h, w = key.height, key.width
    yy, xx = np.indices((h, w), dtype=np.float32)
    mx, my = xx.copy(), yy.copy()
    pins = np.array(pins)
    half_travel = (pins[:, 2] - pins[:, 0]) / 2
    stance = np.argmax(pins[:, 1])
    for y in range(h):
        # At the pad rim, shift each sole as a rigid piece. Interpolate only
        # between pads; the piston shafts bend between the socket and rim.
        gain = np.clip((y - 176) / (pins[:, 1] - 12 - 176), 0, 1)
        dx = body[0] + gain * (half_travel - body[0])
        # Below a raised pad only the planted leg occupies the scanline.
        # Fade its neighbour's influence out smoothly across the rim.
        weight = np.clip((pins[:, 1] + 9 - y) / 9, 0, 1)
        plant_dx = dx[stance]
        dx = plant_dx + weight * (dx - plant_dx)
        centres = pins[:, 0] + dx
        gaps = np.diff(centres)
        rim = np.minimum(16, 0.46 * np.minimum(np.r_[100, gaps], np.r_[gaps, 100]))
        rails = np.column_stack((centres - rim, centres + rim)).ravel()
        mx[y] -= np.interp(xx[y], rails, np.repeat(dx, 2))
        my[y] -= body[1] * np.clip((212 - y) / 36, 0, 1)
    pixels = cv2.remap(np.asarray(key.convert("RGBa")), mx, my, cv2.INTER_LINEAR)
    return Image.frombytes("RGBa", key.size, pixels.tobytes()).convert("RGBA")


def pack(steps, output):
    sheet = Image.open(VIEW / "tonnage_walk8.png").convert("RGBA")
    width, height = sheet.width // 16, sheet.height // 5

    def key(col):
        return sheet.crop((col * width, 2 * height, (col + 1) * width, 3 * height))

    landing = key(6)
    assert hashlib.sha256(landing.tobytes()).hexdigest() == LANDING_RGBA
    atlas = Image.new("RGBA", (len(steps) * width, height * 5))
    for i, step in enumerate(steps):
        if step == 5:
            pose = midpoint(landing)
        else:
            source, pins = PADS[step]
            other = step + 1 if source == step else step
            ink = key(source)
            if step == 9:
                ink = piston_ink(ink, key(other))
            pose = between(ink, key(other), pins)
        atlas.paste(pose, (i * width, 2 * height))
    atlas.save(output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steps", nargs="+", type=int, choices=STEPS, default=STEPS)
    parser.add_argument("--out", type=Path, default=VIEW / "tonnage_walk8_mid.png")
    args = parser.parse_args()
    pack(args.steps, args.out)
