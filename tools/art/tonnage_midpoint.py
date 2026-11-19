"""Pack p70 profile in-betweens from Tonnage's shipped keys, in atlas order."""

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
# The left keys have different pistons and a 215 px cell. Their splayed
# landing at C7 changes stance; follow the outgoing front pad through lift.
LEFT_PADS = {
    0: (1, [(36, 212, 26.5), (135, 198, 132)]),
    1: (2, [(40, 185, 36), (73, 212, 36), (130, 196, 135)]),
    2: (3, [(24, 187, 40), (62, 183, 62), (83, 212, 73), (138, 196, 130)]),
    4: (4, [(24, 179, 21), (85.5, 212, 49.5), (133, 195, 138)]),
    5: (5, [(22, 188, 20), (49.5, 212, 20.5), (74, 183, 72), (138, 204, 142)]),
    8: (8, [(28.5, 212, 42), (121, 195, 131)]),
    9: (10, [(40, 185, 28), (52.5, 212, 42), (131, 195, 131)]),
    10: (11, [(25, 193, 40), (66.5, 212, 52.5), (136, 203, 131)]),
    11: (12, [(32, 185, 25), (83.5, 212, 66.5), (133, 195, 136)]),
    12: (12, [(32, 185, 22.5), (65, 180, 65), (83.5, 212, 136), (133, 195, 136)]),
}
STEPS = (5, *PADS)


def piston_ink(key, neighbour, left):
    """C11 has keyed-out metal. Borrow the corresponding C10 metal under its rim."""
    if left:
        # Only the rear socket is missing in the left C11. The intact
        # near piston already has the left drawing's highlights.
        under = Image.new("RGBA", key.size)
        # Extend the shaft behind the belly without carrying C10's wider
        # housing lip. Back the small keyed hole with adjacent socket metal.
        under.paste(neighbour.crop((102, 179, 107, 186)), (99, 173))
        under.alpha_composite(neighbour.crop((93, 173, 108, 181)), (96, 167))
        under.alpha_composite(neighbour.crop((87, 181, 114, 198)), (90, 175))
        under.alpha_composite(key)
        return under
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


def between(key, neighbour, pins, split_stance=False):
    # Register the rigid crown and print by template matching. Interpolate
    # independent sole displacements below it without blending two outlines.
    def gray(im):
        return cv2.cvtColor(np.asarray(im), cv2.COLOR_RGBA2GRAY)

    # Both grids are foot-anchored. Register and bend at the same
    # distances above the ground in their differently padded cells.
    pad = key.height - 230
    patch = gray(key)[65 + pad:163 + pad, 28:134]
    score = cv2.matchTemplate(gray(neighbour), patch, cv2.TM_CCOEFF_NORMED)
    _, _, _, match = cv2.minMaxLoc(score)
    body = (np.array(match) - [28, 65 + pad]) / 2
    if not split_stance:
        return warp_pads(key, pins, body)
    # C13's long departing piston overlaps the dark rear socket. Move them
    # as separate pieces so a black thread cannot stretch across the gap.
    y, x = np.indices((key.height, key.width))
    lo = np.interp(y, [163, 174, 180, 191, 197], [77, 77, 72, 71, 66])
    hi = np.interp(y, [163, 190, 197], [95, 96, 102])
    near = (y >= 163) & (x >= lo) & (x <= hi)
    trunk = np.array(key)
    leg = trunk.copy()
    trunk[near] = 0
    leg[~near] = 0
    stance = int(np.argmax(np.asarray(pins)[:, 1]))
    # The socket's right rim was hidden behind the shaft in C13 and is
    # exposed at C14. Seat that rim behind the separated C13 housing.
    shell = Image.new("RGBA", key.size)
    shell.paste(neighbour.crop((65, 177, 83, 193)), (64, 163))
    shell.alpha_composite(Image.fromarray(trunk))
    rear = warp_pads(shell, pins[:stance] + pins[stance + 1:], body)
    rear.alpha_composite(warp_pads(Image.fromarray(leg), [pins[stance]], body))
    return rear


def warp_pads(key, pins, body):
    h, w = key.height, key.width
    pad = h - 230
    yy, xx = np.indices((h, w), dtype=np.float32)
    mx, my = xx.copy(), yy.copy()
    pins = np.array(pins)
    half_travel = (pins[:, 2] - pins[:, 0]) / 2
    stance = np.argmax(pins[:, 1])
    for y in range(h):
        # At the pad rim, shift each sole as a rigid piece. Interpolate only
        # between pads; the piston shafts bend between the socket and rim.
        gain = np.clip((y - (176 + pad)) / (pins[:, 1] - 12 - (176 + pad)), 0, 1)
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
        my[y] -= body[1] * np.clip((212 + pad - y) / 36, 0, 1)
    pixels = cv2.remap(np.asarray(key.convert("RGBa")), mx, my, cv2.INTER_LINEAR)
    return Image.frombytes("RGBa", key.size, pixels.tobytes()).convert("RGBA")


def pack(steps, output, left=False):
    suffix = "_left" if left else ""
    sheet = Image.open(VIEW / f"tonnage_walk8{suffix}.png").convert("RGBA")
    rows, row = (3, 1) if left else (5, 2)
    pads = LEFT_PADS if left else PADS
    width, height = sheet.width // 16, sheet.height // rows

    def key(col):
        return sheet.crop((col * width, row * height, (col + 1) * width, (row + 1) * height))

    landing = key(6)
    if not left:
        assert hashlib.sha256(landing.tobytes()).hexdigest() == LANDING_RGBA
    atlas = Image.new("RGBA", (len(steps) * width, height * rows))
    for i, step in enumerate(steps):
        if step == 5 and not left:
            pose = midpoint(landing)
        else:
            source, pins = pads[step]
            other = step + 1 if source == step else step
            ink = key(source)
            if step == 9:
                ink = piston_ink(ink, key(other), left)
            pose = between(ink, key(other), pins, split_stance=left and step == 12)
        atlas.paste(pose, (i * width, row * height))
    atlas.save(output or VIEW / f"tonnage_walk8_mid{suffix}.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steps", nargs="+", type=int, choices=STEPS, default=STEPS)
    parser.add_argument("--left", action="store_true")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    pack(args.steps, args.out, args.left)
