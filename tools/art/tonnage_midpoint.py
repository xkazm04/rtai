"""Pack walk in-betweens from Tonnage's shipped keys, in atlas order."""

import argparse
import hashlib
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from tonnage_profile import profile_pose
from tonnage_pads import LEFT_PADS, PADS, PROFILE55_PADS, diagonal_pads, straight_pads
from tonnage_warp import articulated_pose, midpoint, piston_ink, register_crown, warp_pads


VIEW = Path(__file__).resolve().parents[2] / "project/features/souls/art/view/p70"
LANDING_RGBA = "4cd2ebc2bf4bcaa84cb5c10b17b06a6015b1dafe6753f487bbf49cd933b2a4de"


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


# Number of equal intervals between adjacent key centres, including C16-C1.
DIAGONAL_DIVISIONS = (4, 6, 4, 4, 4, 4, 2, 2, 4, 4, 4, 4, 4, 2, 2, 2)


def pack_intervals(sheet, rows, selected, divisions, style="diagonal"):
    profile55 = style == "profile"
    w, h = sheet.width // len(divisions), sheet.height // rows
    atlas = Image.new("RGBA", ((w + 8) * (sum(divisions) - len(divisions)), sheet.height))
    for row in selected:
        col = 0
        keys = [sheet.crop((i*w, row*h, (i+1)*w, (row+1)*h)) for i in range(len(divisions))]
        detect = straight_pads if rows == 5 and row in (0, 4) else diagonal_pads
        warp = ""
        if style == "fill":
            if rows == 5 and row == 0:
                warp = "sill"
            elif detect is diagonal_pads:
                warp = "separate"
        if style == "fill70":
            warp = "short_soles"
        pins = [] if profile55 else [detect(key) for key in keys]
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
                # The front C5 and C13 shoes retract flush to the sill. Use the
                # extended neighbour's silver shaft as it comes out of the socket.
                if style == "fill70" and row == 0 and i in (4, 12) and 2 * j == count:
                    a, b = k, i
                fraction = (j if a == i else count - j) / count
                source, target = (start, end) if a == i else (end, start)
                crown = register_crown(keys[a], keys[b])
                if profile55 and i not in (1, 7):
                    pose = profile_pose((keys[a], keys[b]), (source, target), crown, fraction,
                                        (rows == 3, a, b))
                else:
                    pose = articulated_pose(keys[a], (source, target), crown, fraction, warp)
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
    atlas = pack_intervals(sheet, rows, selected, PROFILE55_DIVISIONS, style="profile")
    atlas.save(output or view / f"tonnage_walk8_detail{suffix}.png")


OTHER55_DIVISIONS = (6, 8, 8, 8, 6, 6, 6, 4)


def pack_fill(pitch, page, output, left):
    """Split the additional poses over two lossless textures under 4096 px wide."""
    view = VIEW.parent / pitch
    suffix = "_left" if left else ""
    sheet = Image.open(view / f"tonnage_walk8{suffix}.png").convert("RGBA")
    rows, selected = (3, (0, 2)) if left else (5, (0, 1, 3, 4))
    divisions = OTHER55_DIVISIONS
    if pitch == "p70":
        if left:
            raise ValueError("The p70 straight rows use the five-facing sheet.")
        selected = (0, 4)
        divisions = DIAGONAL_DIVISIONS
    atlas = pack_intervals(sheet, rows, selected, divisions, style="fill70" if pitch == "p70" else "fill")
    half = atlas.width // 2
    x = 0 if page == "a" else half
    atlas.crop((x, 0, x + half, atlas.height)).save(output or view / f"tonnage_walk8_fill_{page}{suffix}.png")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--steps", nargs="+", type=int, choices=STEPS, default=STEPS)
    parser.add_argument("--left", action="store_true")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--diagonal", action="store_true")
    mode.add_argument("--p55", action="store_true")
    mode.add_argument("--fill", choices=["p55", "p70"])
    parser.add_argument("--page", choices=["a", "b"], default="a")
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()
    if args.fill:
        pack_fill(args.fill, args.page, args.out, args.left)
    elif args.p55:
        pack_profile55(args.out, args.left)
    elif args.diagonal:
        pack_diagonal(args.out, args.left)
    else:
        pack(args.steps, args.out, args.left)
