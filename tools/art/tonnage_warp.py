"""Single-silhouette warps used by the Tonnage midpoint atlas packer."""

import cv2
import numpy as np
from PIL import Image


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
    return remap_ink(key, mx, my)


def diagonal_pads(key):
    """The two outer pads and the near pad, whose sole anchors these rows."""
    alpha = np.asarray(key)[..., 3] > 128
    bottom = np.where(alpha.any(0), key.height - 1 - alpha[::-1].argmax(0), -1)

    # A cut through a sloping shaft can be lower than the far sole. Locate
    # actual peaks of the whole silhouette before assigning the three sockets.
    peaks = bottom == cv2.dilate(bottom.astype("float32")[None, :],
                                 np.ones((1, 7), "uint8"))[0]
    pads = []
    indices = np.flatnonzero(peaks)
    for group in np.split(indices, np.flatnonzero(np.diff(indices) > 1) + 1):
        x = group[len(group) // 2]
        y = bottom[x]
        l = r = x
        while l > 0 and bottom[l - 1] >= y - 3:
            l -= 1
        while r + 1 < key.width and bottom[r + 1] >= y - 3:
            r += 1
        if r - l < 38:
            pads.append(((l + r) / 2, y))
    return np.array([max((p for p in pads if lo <= p[0] < hi), key=lambda p: p[1])
                     for lo, hi in [(0, 45), (48, 115), (118, key.width)]])


def register_crown(key, neighbour):
    # Register the top casing, excluding pistons, alpha fringe and empty margins.
    def gray(im):
        return cv2.cvtColor(np.asarray(im), cv2.COLOR_RGBA2GRAY)

    top = key.height - 153
    patch = gray(key)[top:top + 57, 39:123]
    score = cv2.matchTemplate(gray(neighbour), patch, cv2.TM_CCOEFF_NORMED)
    return np.array(cv2.minMaxLoc(score)[3]) - [39, top]


def articulated_pose(key, start, end, crown, fraction):
    """One source silhouette. Keep each sole rigid and bend its shaft at the socket."""
    h, w = key.height, key.width
    yy, xx = np.indices((h, w + 8), dtype=np.float32)
    xx -= 4  # transparent gutters keep adjacent poses out of the linear-filtered outline
    mx, my = xx.copy(), yy.copy()
    delta = fraction * (end - start)
    dst = start + delta
    for y in range(h):
        gain = np.clip((y - dst[:, 1] + 50) / 36, 0, 1)[:, None]
        shift = crown * fraction + gain * (delta - crown * fraction)
        centres = start[:, 0] + shift[:, 0]
        gaps = np.diff(centres)
        rim = np.minimum(13, .44 * np.minimum(np.r_[100, gaps], np.r_[gaps, 100]))
        rails = np.column_stack((centres - rim, centres + rim)).ravel()
        mx[y] -= np.interp(xx[y], rails, np.repeat(shift[:, 0], 2))
        my[y] -= np.interp(xx[y], rails, np.repeat(shift[:, 1], 2))
    return remap_ink(key, mx, my)


def remap_ink(key, mx, my):
    pixels = cv2.remap(np.asarray(key.convert("RGBa")), mx, my, cv2.INTER_LINEAR)
    return Image.frombytes("RGBa", (mx.shape[1], mx.shape[0]), pixels.tobytes()).convert("RGBA")
