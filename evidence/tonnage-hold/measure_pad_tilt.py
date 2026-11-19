"""Measure raised p55 profile rims against Tonnage's own neighbouring keys, in screen degrees."""

import argparse
import functools
from pathlib import Path
import sys

import cv2
import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "tools/art"))
from tonnage_midpoint import PROFILE55_DIVISIONS, PROFILE55_PADS, VIEW  # noqa: E402
from tonnage_profile import SOCKETS  # noqa: E402


def gray(image):
    rgba = np.asarray(image)
    alpha = rgba[..., 3] / 255
    ink = cv2.cvtColor(rgba, cv2.COLOR_RGBA2GRAY)
    return (ink * alpha + 175 * (1 - alpha)).astype("uint8")


class RimGauge:
    """Fit the neutral C2 shoe to one visible rim; keep the template inside the drawn crop."""

    def __init__(self, key, contact):
        x, y = contact
        patch = gray(key.crop((x - 18, y - 16, x + 19, y + 4)))
        inside = np.zeros(patch.shape, "uint8")
        inside[2:-2, 3:-3] = 255
        self.templates = []
        for scale in (0.72, 0.84, 0.94, 1.03):
            for degrees in range(-48, 49, 2):
                matrix = cv2.getRotationMatrix2D((18, 8), -degrees, scale)
                matrix[:, 2] += [8, 14]
                ink = cv2.warpAffine(patch, matrix, (53, 47), borderValue=175)
                mask = cv2.warpAffine(inside, matrix, (53, 47))
                mask[mask < 200] = 0
                ys, xs = np.where(mask)
                box = np.s_[ys.min():ys.max()+1, xs.min():xs.max()+1]
                anchor = (26 - xs.min(), 22 - ys.min())
                self.templates.append((degrees, scale, ink[box], mask[box], anchor))

    def angle(self, image, contact, clip=None):
        padded = cv2.copyMakeBorder(gray(image), 40, 40, 40, 40, cv2.BORDER_CONSTANT, value=175)
        x, y = contact
        best, angle = np.inf, None
        for degrees, scale, ink, mask, (cx, cy) in self.templates:
            px = round(x + 40 - cx) - 8
            py = round(y - 7 * scale + 40 - cy) - 5
            window = padded[py:py+ink.shape[0]+11, px:px+ink.shape[1]+17]
            if clip is None:
                errors = cv2.matchTemplate(window, ink, cv2.TM_SQDIFF, mask=mask)
                errors /= np.count_nonzero(mask)
            else:
                errors = clipped_errors(window, ink, mask, px - 40, clip)
            score = errors.min()
            if score < best:
                best, angle = score, degrees
        return angle


def clipped_errors(window, ink, mask, x_origin, clip):
    """C4's outward rim is cut in both original sheets. Exclude the missing pixels."""
    xs = x_origin + np.arange(window.shape[1])
    valid = np.broadcast_to((xs >= clip[0]) & (xs <= clip[1]), window.shape).astype("float32")
    source, target = window.astype("float32"), ink.astype("float32")
    mask = (mask > 0).astype("float32")

    def corr(a, b):
        return cv2.matchTemplate(a, b, cv2.TM_CCORR)

    count = corr(valid, mask)
    sums = corr(valid * source**2, mask) - 2 * corr(valid * source, mask * target)
    errors = (sums + corr(valid, mask * target**2)) / np.maximum(count, 1)
    errors[count < 0.5 * mask.sum()] = np.inf
    return errors


def row_cells(path, left, columns):
    with Image.open(path) as image:
        w = image.width // columns
        h = image.height // (3 if left else 5)
        y = h if left else 2 * h
        return [image.crop((i*w, y, (i+1)*w, y+h)).convert("RGBA") for i in range(columns)]


def raised_pins(left, step, j, divisions):
    pins = np.array(PROFILE55_PADS[left][step])
    nxt = (step + 1) % 8
    a, b = (step, nxt) if 2*j <= divisions else (nxt, step)
    fraction = min(j, divisions-j) / divisions
    start, end = (pins[:, :2], pins[:, 2:]) if a == step else (pins[:, 2:], pins[:, :2])
    travel = (end - start) * fraction
    old, new = np.argmax(start[:, 1]), np.argmax(end[:, 1])
    if step not in (1, 7) and old != new:
        travel[old, 1] = 0
        travel[new, 1] *= 2
    contact = start + travel + [4, 0]
    for pin, pos in enumerate(contact):
        if pos[1] > contact[:, 1].max() - 5:
            continue
        if any(min(abs(p[0]-x) for p in SOCKETS[left][i]) > tol
               for i, x, tol in ((a, start[pin, 0], 2), (b, end[pin, 0], 3))):
            continue
        yield pin, pos, (a, *start[pin]), (b, *end[pin]), fraction


def measure(left, before, after):
    suffix = "_left.png" if left else ".png"
    name = "tonnage_walk8_detail" + suffix
    keys = row_cells(VIEW.parent / "p55" / ("tonnage_walk8" + suffix), left, 8)
    old, new = (row_cells(directory / name, left, 20) for directory in (before, after))
    gauge = RimGauge(keys[1], (76, 211) if left else (93, 225))

    @functools.cache
    def drawn(index, x, y):
        clip = None
        if index == 3 and (left, x) in ((True, 22), (False, 147)):
            clip = (13, 200) if left else (0, 156)
        return gauge.angle(keys[index], (x, y), clip)

    col = 0
    for step, count in enumerate(PROFILE55_DIVISIONS):
        for j in range(1, count):
            rims = []
            for pin, pos, a, b, fraction in raised_pins(left, step, j, count):
                start, end = drawn(*a), drawn(*b)
                target = start + fraction * (end - start)
                rims.append((pin, target, gauge.angle(old[col], pos), gauge.angle(new[col], pos)))
            yield col+1, step+1, j, count, rims
            col += 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("before", type=Path, help="directory with both brief 10 profile PNGs")
    parser.add_argument("--after", type=Path, default=VIEW.parent / "p55")
    args = parser.parse_args()
    for left in (False, True):
        for col, step, j, count, rims in measure(left, args.before, args.after):
            print("left" if left else "right", col, step, f"{j}/{count}", rims)
