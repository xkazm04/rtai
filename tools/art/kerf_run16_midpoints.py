"""Fill the doubled front and back keys in Kerf's p70 run. Input is the n15 pack:

    python evidence/s14/tools/double_sheet.py <kerf_run8.png> 5 base.png <kerf_run16_70_cells> 1,2,3 3
    python tools/art/kerf_run16_midpoints.py base.png kerf_run16.png

All coordinates are pixels in the shipped 153 x 213 cell, before display scaling.
"""

import argparse
import hashlib
from pathlib import Path

import numpy as np
from PIL import Image

BASE_RGBA = "7c0edede2f3c052006fe814e8df5ac6f6ac212b44fff40e675321ba218456014"
SIZE = (153, 213)

# Each run8 key, screen left to right: crown, shoulders, belt, blade tips,
# knees and toes. Both toes follow their own trajectory through foot exchange.
# fmt: off
FRONT = [
    [(77,16),(39,72),(106,94),(77,108),(26,128),(126,180),(55,149),(83,136),(54,209),(79,157)],
    [(76,32),(40,98),(104,103),(77,121),(28,160),(114,185),(62,154),(87,150),(70,209),(83,186)],
    [(77,24),(46,99),(116,79),(77,111),(25,179),(129,138),(66,142),(86,156),(68,162),(83,209)],
    [(77,41),(46,116),(112,96),(77,130),(25,190),(128,168),(60,155),(90,156),(77,209),(85,186)],
    [(79,15),(52,93),(111,74),(80,108),(28,181),(116,128),(70,135),(99,148),(78,155),(102,209)],
    [(76,32),(44,103),(104,103),(76,121),(36,172),(113,172),(61,154),(87,151),(72,209),(84,187)],
    [(77,24),(46,99),(116,79),(77,111),(25,178),(129,138),(66,142),(86,156),(68,162),(83,209)],
    [(77,41),(46,116),(112,96),(77,130),(25,190),(128,168),(60,155),(90,156),(77,209),(85,186)],
]
BACK_HALF = [
    [(80,13),(58,78),(113,53),(80,96),(26,152),(129,83),(66,141),(91,111),(58,209),(87,122)],
    [(81,57),(57,121),(112,109),(82,137),(23,181),(126,148),(71,168),(91,161),(74,209),(91,182)],
    [(83,10),(59,74),(115,51),(83,96),(24,133),(130,79),(67,139),(94,110),(40,209),(90,122)],
    [(84,53),(58,117),(111,109),(84,135),(26,163),(125,130),(69,162),(91,152),(62,209),(88,167)],
]
# fmt: on


def back_points(keys):
    result = list(BACK_HALF)
    # The second half exchanges sides. The n15 pack centres tight crops with
    # half-even rounding, so use each actual silhouette's reflection axis.
    for i, points in enumerate(BACK_HALF):
        axis = keys[i].getbbox()[0] + keys[i + 4].getbbox()[2] - 1
        result.append(
            [
                (axis - points[j][0], points[j][1])
                for j in (0, 2, 1, 3, 5, 4, 7, 6, 9, 8)
            ]
        )
    return result


def rails(p):
    crown, ls, rs, belt, lb, rb, lk, rk, lt, rt = np.array(p)
    # Rows follow crown, shoulders, hips, knees, toe base, toe point.
    x = np.array(
        [
            [lb[0], crown[0] - 13, crown[0] + 13, rb[0]],
            [ls[0] - 10, belt[0] - 13, belt[0] + 13, rs[0] + 10],
            [lb[0], belt[0] - 12, belt[0] + 12, rb[0]],
            [lb[0], lk[0], rk[0], rb[0]],
            [lb[0], lt[0], rt[0], rb[0]],
            [lb[0], lt[0], rt[0], rb[0]],
        ]
    )
    y = np.array(
        [
            [crown[1]] * 4,
            [ls[1], belt[1] - 26, belt[1] - 26, rs[1]],
            [(ls[1] + lb[1]) / 2, belt[1], belt[1], (rs[1] + rb[1]) / 2],
            [lb[1], lk[1], rk[1], rb[1]],
            [lb[1] + 18, lt[1] - 8, rt[1] - 8, rb[1] + 18],
            [lb[1] + 26, lt[1], rt[1], rb[1] + 26],
        ]
    )
    return x, y


def halfway(key, here, following):
    sx, sy = rails(here)
    tx, ty = rails((np.asarray(here) + following) / 2)
    w, h = key.size
    xx = np.arange(w)
    origin = np.empty((h, w, 2))
    heights = np.arange(h)
    target_x = np.array([np.interp(heights, ty[:, j], tx[:, j]) for j in range(4)]).T
    shifts_x = np.array(
        [np.interp(heights, ty[:, j], sx[:, j] - tx[:, j]) for j in range(4)]
    ).T
    shifts_y = np.array(
        [np.interp(heights, ty[:, j], sy[:, j] - ty[:, j]) for j in range(4)]
    ).T
    for y, rails_x in enumerate(target_x):
        # Extend displacement outside the end joints by keeping the rail
        # direction vertical there, including beyond the bottom of the toes.
        # Give each rail a small rigid span across the limb, fading to the
        # next rail only in the gap. Closely passing toes share that gap.
        gaps = np.diff(rails_x)
        widths = np.minimum(5.0, 0.38 * np.minimum(np.r_[100, gaps], np.r_[gaps, 100]))
        edges = np.column_stack((rails_x - widths, rails_x + widths)).ravel()
        origin[y, :, 0] = xx + np.interp(xx, edges, np.repeat(shifts_x[y], 2))
        origin[y, :, 1] = y + np.interp(xx, edges, np.repeat(shifts_y[y], 2))
    src = np.asarray(key.convert("RGBa"), dtype=float)
    # Below the pelvis the legs can overlap in projection, although one is
    # swinging up and the other reaching down. Sample them as separate pieces.
    # Cut in the gap between the legs where one exists in the source drawing.
    masks = np.zeros((4, h, w))
    for y in range(h):
        centres = np.array([np.interp(y, sy[:, j], sx[:, j]) for j in range(4)])
        gaps = []
        for left, right in zip(centres, centres[1:]):
            mid = (left + right) / 2
            lo, hi = int(left + 1), int(right)
            weights = src[y, lo:hi, 3] + abs(xx[lo:hi] - mid)
            gaps.append(lo + np.argmin(weights) if hi > lo else int(mid))
        owners = np.searchsorted(gaps, xx)
        for j in range(4):
            masks[j, y] = owners == j

    result = np.zeros_like(src)
    for j, mask in enumerate(masks):
        coords = origin.copy()
        # Keep the upper body together, then move each limb independently.
        mix = np.clip((heights - ty[2, 1] - 2) / 18, 0, 1)[:, None]
        coords[:, :, 0] += mix * (xx + shifts_x[:, j, None] - coords[:, :, 0])
        coords[:, :, 1] += mix * ((heights + shifts_y[:, j])[:, None] - coords[:, :, 1])
        pixels = sample(src * mask[:, :, None], coords)
        # Share seam coverage; a rear leg can disappear behind the stance leg.
        result += pixels
    result = np.minimum(result, 255).round().astype("uint8")
    return Image.fromarray(result, "RGBa").convert("RGBA")


def sample(src, coords):
    h, w = src.shape[:2]
    coords = coords.clip([0, 0], [w - 1.001, h - 1.001])
    x, y = coords.astype(int).transpose(2, 0, 1)
    dx, dy = (coords - coords.astype(int)).transpose(2, 0, 1)[:, :, :, None]
    top = (1 - dx) * src[y, x] + dx * src[y, x + 1]
    bottom = (1 - dx) * src[y + 1, x] + dx * src[y + 1, x + 1]
    return (1 - dy) * top + dy * bottom


def pack(base, out):
    sheet = Image.open(base).convert("RGBA")
    assert hashlib.sha256(sheet.tobytes()).hexdigest() == BASE_RGBA, (
        "expected the n15 run16 pack"
    )
    w, h = SIZE
    for row in (0, 4):
        keys = [
            sheet.crop((c * w, row * h, (c + 1) * w, (row + 1) * h))
            for c in range(0, 16, 2)
        ]
        poses = FRONT if row == 0 else back_points(keys)
        for i in range(len(keys)):
            j = (i + 1) % 8
            # Start from the more open silhouette at foot exchanges so
            # the swing leg has a complete outline when it emerges.
            a, b = (
                (j, i) if (row == 0 and i % 2) or (row == 4 and i in (3, 7)) else (i, j)
            )
            sheet.paste(
                halfway(keys[a], poses[a], poses[b]), ((2 * i + 1) * w, row * h)
            )
    sheet.save(out)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("base", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    pack(args.base, args.output)
