"""Interpolate the p55 pistons with one continuous warp under the rigid housing."""

import cv2
import numpy as np
from PIL import Image

from tonnage_warp import remap_ink


# fmt: off
# Each visible shaft's sole x, socket x and socket y in its own original key.
# Short charcoal feet behind the silver pistons stay with the underside.
SOCKETS = (
    (((35, 42, 183), (139.5, 126, 182)),
     ((36, 44, 183), (93, 85, 182), (126, 126, 179)),
     ((33, 46, 178), (80.5, 78, 179), (138, 132, 168)),
     ((29, 46, 185), (147, 134, 178)),
     ((46, 49, 186), (138.5, 126, 186)),
     ((38, 45, 185), (63, 66, 185), (113.5, 101, 182)),
     ((32, 45, 175), (82, 81, 182), (134, 132, 176)),
     ((38, 45, 185), (139, 126, 186))),
    (((30, 41, 168), (133, 126, 167)),
     ((43, 43, 168), (76, 83, 170), (132, 125, 167)),
     ((31, 37, 154), (90.5, 92, 166), (137, 126, 164)),
     ((22, 36, 164), (140.5, 126, 172)),
     ((32.5, 42, 171), (124, 124, 170)),
     ((40, 42, 171), (57.5, 69, 172), (132, 125, 170)),
     ((35, 39, 161), (88, 90, 167), (137, 126, 165)),
     ((31.5, 42, 171), (133, 125, 169))),
)


# Height of the lower armoured edge above each row of pistons, traced on
# the shipped keys. All ink above this edge follows the crown rigidly.
RIM_X = (19, 32, 44, 59, 78, 99, 119, 136, 150)
RIMS = (
    ((174, 177, 185, 188, 189, 186, 184, 181, 174),
     (172, 176, 184, 188, 185, 182, 179, 176, 165),
     (169, 173, 179, 182, 181, 177, 173, 168, 158),
     (175, 179, 186, 190, 189, 186, 182, 178, 169),
     (177, 180, 187, 190, 191, 190, 187, 184, 177),
     (172, 177, 185, 189, 188, 185, 182, 179, 170),
     (168, 173, 180, 183, 181, 177, 173, 169, 159),
     (175, 178, 186, 190, 190, 188, 186, 183, 176)),
    ((154, 163, 168, 171, 174, 175, 174, 165, 158),
     (156, 164, 168, 171, 175, 176, 176, 168, 159),
     (147, 154, 157, 160, 164, 167, 168, 165, 152),
     (155, 161, 164, 166, 170, 173, 175, 171, 161),
     (158, 165, 171, 174, 176, 176, 175, 171, 161),
     (158, 165, 170, 172, 175, 177, 175, 170, 158),
     (151, 158, 161, 164, 168, 169, 170, 167, 153),
     (157, 165, 170, 173, 175, 177, 176, 171, 159)),
)


# Two short, shadowed feet sit behind the moving silver pistons.
REAR = (
    ((55, 196, 100, 201), (57, 196, 99, 198), (57, 191, 99, 195), (55, 198, 99, 200),
     (78, 203, 100, 201), (64, 207, 98, 200), (56, 191, 99, 197), (56, 197, 99, 201)),
    ((69, 186, 112, 184), (68, 183, 111, 182), (69, 181, 113, 180), (69, 187, 112, 187),
     (69, 186, 91, 188), (70, 185, 106, 194), (69, 182, 114, 181), (71, 187, 112, 185)),
)
# fmt: on


def housing(key, rim):
    pixels = np.array(key)
    h, w = pixels.shape[:2]
    prior = np.interp(np.arange(w), RIM_X, rim)
    # Follow the dark underside of the metal lip across the light shafts.
    lum = cv2.cvtColor(pixels, cv2.COLOR_RGBA2GRAY).astype(float)
    lum *= pixels[..., 3] / 255
    cut = prior.copy()
    for x, guess in enumerate(prior):
        ys = np.arange(int(guess) - 6, int(guess) + 7)
        contrast = lum[ys - 4, x] - 0.5 * (lum[ys - 1, x] + lum[ys, x])
        cut[x] = ys[np.argmax(contrast - 3 * np.abs(ys - guess))]
    cut = cv2.medianBlur(cut.astype("float32")[None, :], 5)[0] + 1
    pixels[np.arange(h)[:, None] > cut] = 0
    return Image.fromarray(pixels)


def piston_strip(key, sole, root):
    # Rectify the near piston into an upright strip. Pick a bright shaft
    # cross-section above the collar and keep the original rounded shoe.
    x, y = sole
    rgb = np.asarray(key)
    pad = np.zeros((28, 45, 4), dtype="uint8")
    # The broad silver band two dozen pixels above the ground is clear of
    # the bevel. Keep its original specular highlight and both dark edges.
    sy = int(y) - 23
    t = np.clip((sy - root[2]) / max(1, y - 12 - root[2]), 0, 1)
    here = round(root[1] * (1 - t) + x * t)
    line = rgb[sy, here - 21 : here + 22]
    lum = line[:, :3].mean(1)
    idx = np.flatnonzero((lum > 105) & (line[:, 3] > 128))
    bands = [g for g in np.split(idx, np.flatnonzero(np.diff(idx) > 1) + 1) if len(g)]
    band = min(bands, key=lambda g: abs((g[0] + g[-1]) / 2 - 21))
    first, last = max(0, band[0] - 3), min(len(line) - 1, band[-1] + 3)
    start = 22 - (last - first) // 2
    pad[:22, start : start + last - first + 1] = line[first : last + 1]
    for row in range(11, 28):
        yy = int(y) - 25 + row
        if yy >= key.height:
            continue
        xs = np.flatnonzero(rgb[yy, :, 3])
        for g in np.split(xs, np.flatnonzero(np.diff(xs) > 1) + 1):
            if len(g) and g[0] <= x <= g[-1]:
                first, last = max(g[0], round(x) - 21), min(g[-1], round(x) + 21)
                pad[row, first - round(x) + 22 : last - round(x) + 23] = rgb[yy, first : last + 1]
    return Image.fromarray(pad)


def draw_piston(strip, foot, socket, scale, grid):
    xx, yy = grid
    # The upper two rows of the strip are the original cylindrical shaft.
    # Extend it behind the housing, shearing from the socket to the ankle.
    sx, sy = socket
    fx, fy = foot
    ankle = fy - 13 * scale
    t = np.clip((yy - sy) / max(1, ankle - sy), 0, 1)
    centre = sx + t * (fx - sx)
    mx = (xx - centre) / scale + 22
    my = np.clip((yy - fy) / scale + 25, 0, 28)
    my[yy < sy - 12] = 29
    return remap_ink(strip, mx.astype("float32"), my.astype("float32"))


def rear_pad(pair, left):
    """Take a complete shadowed rim from the clearer of these two shipped keys."""
    i, k = pair[0][1], pair[1][1]
    step = i if (i + 1) % 8 == k else k
    chosen = (0, 2, 3, 3, 4, 6, 7, 0)[step]
    key = next(im for im, index in pair if index == chosen)
    rear = REAR[left][chosen]
    x, y = rear[:2] if left else rear[2:]
    side = -1 if left else 1
    yy, xx = np.indices((25, 31), dtype=np.float32)
    rgba = np.array(remap_ink(key, x + side * np.abs(xx - 15), y - 23 + yy))
    # Keep only the continuous rim around the centre. Extend its dark top
    # under the armour, so an occluding shaft or a piece of casing cannot
    # leave a hairline in the silhouette when this pad is transplanted.
    columns = np.flatnonzero(rgba[17:24, :, 3].max(0) > 128)
    groups = np.split(columns, np.flatnonzero(np.diff(columns) > 1) + 1)
    span = next(g for g in groups if 15 in g)
    out = np.zeros_like(rgba)
    for col in span:
        occupied = np.flatnonzero(rgba[15:, col, 3] > 96) + 15
        if not len(occupied):
            continue
        low = occupied[-1]
        top = max(15, low - 7)
        out[:top, col] = rgba[top, col]
        out[top : low + 1, col] = rgba[top : low + 1, col]
    return Image.fromarray(out)


def profile_pose(keys, pins, crown, fraction, indices):
    key, neighbour = keys
    start, end = pins
    left, i, k = indices
    sockets, other = SOCKETS[left][i], SOCKETS[left][k]
    body = crown * fraction
    delta = (end - start) * fraction
    old, new = start[:, 1].argmax(), end[:, 1].argmax()
    if old != new:
        delta[old, 1] = 0
        delta[new, 1] *= 2
    yy, xx = np.indices((key.height, key.width + 8), dtype=np.float32)
    xx -= 4
    out = Image.new("RGBA", (key.width + 8, key.height))
    rear = REAR[left][i]
    root = min(sockets, key=lambda p: abs(p[0] - start[old, 0]))
    strip = piston_strip(key, start[old], root)
    caster = rear_pad([(key, i), (neighbour, k)], left)
    for x, y in zip(rear[::2], rear[1::2]):
        out.alpha_composite(caster, (round(x - 15 + 4 + body[0]), round(y - 23 + body[1])))
    for j in np.argsort(start[:, 1] + delta[:, 1]):
        px, py = start[j]
        close, sx, sy = min(sockets, key=lambda p: abs(p[0] - px))
        if abs(close - px) > 2:
            continue
        ex, ey = end[j]
        close, tx, ty = min(other, key=lambda p: abs(p[0] - ex))
        root = np.array([tx - sx, ty - sy]) * fraction if abs(close - ex) < 3 else body
        scale = 1.0 if j == old else 0.84
        out.alpha_composite(draw_piston(strip, start[j] + delta[j], [sx, sy] + root, scale, (xx, yy)))
    hull = housing(key, RIMS[left][i])
    out.alpha_composite(
        remap_ink(hull, (xx - body[0]).astype("float32"), (yy - body[1]).astype("float32"))
    )
    return out
