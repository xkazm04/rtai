"""Pack walk in-betweens from Tonnage's shipped keys, in atlas order."""

import argparse
import hashlib
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from tonnage_profile import profile_pose
from tonnage_warp import articulated_pose, diagonal_pads, register_crown, warp_pads, midpoint, piston_ink


VIEW = Path(__file__).resolve().parents[2] / "project/features/souls/art/view/p70"
LANDING_RGBA = "4cd2ebc2bf4bcaa84cb5c10b17b06a6015b1dafe6753f487bbf49cd933b2a4de"


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


# P55 profile soles in each neighbouring pair, (source x,y, destination x,y).
# At C4 and C7 the adjacent key loads another piston. Follow both physical
# soles during the exchange, including the one rising behind the housing.
PROFILE55_PADS = (
    (
        [(35, 208, 36, 210), (100, 201, 126, 199), (139.5, 225, 93, 225)],
        [(36, 210, 33, 209), (93, 225, 80.5, 225), (126, 199, 138, 193)],
        [(33, 209, 54, 196), (80.5, 225, 29, 225), (138, 193, 147, 213)],
        [(29, 225, 46, 209), (99, 200, 100, 201), (147, 213, 138.5, 225)],
        [(46, 209, 38, 209), (78, 203, 63, 207), (138.5, 225, 113.5, 225)],
        [(38, 209, 32, 208), (113.5, 225, 82, 225), (124, 190, 134, 198)],
        [(32, 208, 54, 197), (82, 225, 38, 210), (134, 198, 139, 225)],
        [(38, 210, 35, 208), (99, 201, 100, 201), (139, 225, 139.5, 225)],
    ), (
        [(30, 211, 76, 211), (68, 186, 43, 183), (133, 194, 132, 196)],
        [(43, 183, 31, 179), (76, 211, 90.5, 211), (132, 196, 137, 195)],
        [(31, 179, 22, 200), (90.5, 211, 140.5, 211), (137, 195, 116, 187)],
        [(22, 200, 32.5, 211), (69, 187, 70, 185), (140.5, 211, 124, 195)],
        [(32.5, 211, 57.5, 211), (83, 188, 103, 194), (124, 195, 132, 196)],
        [(40, 182, 35, 184), (57.5, 211, 88, 211), (132, 196, 137, 195)],
        [(35, 184, 31.5, 211), (88, 211, 133, 196), (137, 195, 117, 184)],
        [(31.5, 211, 30, 211), (71, 187, 68, 186), (133, 196, 133, 194)],
    ),
)


# Number of equal intervals between adjacent key centres, including C16-C1.
DIAGONAL_DIVISIONS = (4, 6, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2, 2)


def pack_intervals(sheet, rows, selected, divisions, profile55=False):
    w, h = sheet.width // len(divisions), sheet.height // rows
    atlas = Image.new("RGBA", ((w + 8) * (sum(divisions) - len(divisions)), sheet.height))
    for row in selected:
        col = 0
        keys = [sheet.crop((i*w, row*h, (i+1)*w, (row+1)*h)) for i in range(len(divisions))]
        pins = [] if profile55 else [diagonal_pads(key) for key in keys]
        for i, count in enumerate(divisions):
            k = (i + 1) % len(keys)
            if profile55:
                matched = np.array(PROFILE55_PADS[rows == 3][i])
                start, end = matched[:, :2], matched[:, 2:]
            else:
                start, end = pins[i], pins[k]
            for j in range(1, count):
                # Use the nearer original to retain drawn detail on both sides of the handoff.
                a, b = (i, k) if 2*j <= count else (k, i)
                fraction = min(j, count - j) / count
                source, target = (start, end) if a == i else (end, start)
                crown = register_crown(keys[a], keys[b])
                if profile55 and i not in (1, 7):
                    pose = profile_pose((keys[a], keys[b]), (source, target), crown, fraction,
                                        (rows == 3, a, b))
                else:
                    pose = articulated_pose(keys[a], source, target, crown, fraction)
                atlas.paste(pose, (col * (w + 8), row * h))
                col += 1
    return atlas


def pack_diagonal(output, left):
    suffix = "_left" if left else ""
    sheet = Image.open(VIEW / f"tonnage_walk8{suffix}.png").convert("RGBA")
    rows, selected = (3, (0, 2)) if left else (5, (1, 3))
    atlas = pack_intervals(sheet, rows, selected, DIAGONAL_DIVISIONS)
    atlas.save(output or VIEW / f"tonnage_walk8_diag{suffix}.png")


PROFILE55_DIVISIONS = (4, 4, 4, 4, 4, 4, 2, 2)


def pack_profile55(output, left):
    suffix = "_left" if left else ""
    view = VIEW.parent / "p55"
    sheet = Image.open(view / f"tonnage_walk8{suffix}.png").convert("RGBA")
    rows, selected = (3, (1,)) if left else (5, (2,))
    atlas = pack_intervals(sheet, rows, selected, PROFILE55_DIVISIONS, profile55=True)
    atlas.save(output or view / f"tonnage_walk8_detail{suffix}.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steps", nargs="+", type=int, choices=STEPS, default=STEPS)
    parser.add_argument("--left", action="store_true")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--diagonal", action="store_true")
    mode.add_argument("--p55", action="store_true")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.p55:
        pack_profile55(args.out, args.left)
    elif args.diagonal:
        pack_diagonal(args.out, args.left)
    else:
        pack(args.steps, args.out, args.left)
