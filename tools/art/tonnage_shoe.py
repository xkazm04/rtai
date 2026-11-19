"""Roll a raised p55 rubber rim around its ankle, behind the separate armoured housing."""

import numpy as np
from PIL import Image

from tonnage_warp import remap_ink


# Degrees clockwise from the stance strip, in atlas-column and pad-pin order.
# Measured against the adjacent original rims by evidence/tonnage-hold/measure_pad_tilt.py.
# An empty tuple retains the previously packed pose.
RIM_TURNS = (
    (
        (10.6, 0.0, 0.0), (5.4, 0.0, 0.0), (5.3, 0.0, 0.0), (1.3, 0.0, -6.3),
        (2.7, 0.0, -12.8), (2.7, 0.0, -20.8), (0.0, 0.0, -31.0), (0.0, 0.0, -22.1),
        (0.0, 0.0, -23.0), (0.0, 0.0, -12.3), (), (),
        (3.4, 0.0, 0.0), (4.0, 0.0, 0.0), (7.0, 0.0, 0.0), (6.0, 0.0, 0.0),
        (4.0, 0.0, 0.0), (2.0, 0.0, 0.0), (), (6.0, 0.0, 0.0),
    ),
    (
        (0.0, 0.0, -12.6), (0.0, 0.0, -6.0), (0.0, 0.0, -7.5), (6.0, 0.0, -4.7),
        (18.0, 0.0, -8.5), (25.0, 0.0, -10.3), (29.5, 0.0, 0.0), (19.6, 0.0, 0.0),
        (24.5, 0.0, 0.0), (11.5, 0.0, 0.0), (), (0.0, 0.0, -4.4),
        (0.0, 0.0, -4.4), (0.0, 0.0, -8.0), (0.0, 0.0, -5.0), (0.0, 0.0, -6.0),
        (2.7, 0.0, -9.2), (0.0, 0.0, -10.3), (), (),
    ),
)


def flat_piston(strip, foot, socket, scale, grid):
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


def draw_piston(strip, foot, socket, shoe, grid):
    scale, degrees = shoe
    if not degrees:
        return flat_piston(strip, foot, socket, scale, grid)
    samples = np.asarray(strip)
    ankle = foot + [0, -12 * scale]
    # The rectified strip has shaft ink at row 5. Extend that same section
    # just inside the bearing so there is no gap at maximum shoe roll.
    shaft = np.zeros_like(samples)
    shaft[:18] = samples[5]
    leg = flat_piston(Image.fromarray(shaft), foot, socket, scale, grid)
    rim = samples.copy()
    rim[:11] = 0
    xx, yy = grid
    dx, dy = xx - ankle[0], yy - ankle[1]
    radians = np.deg2rad(degrees)
    cosine, sine = np.cos(radians), np.sin(radians)
    u = (dx * cosine + dy * sine) / scale + 22
    v = (-dx * sine + dy * cosine) / scale + 13
    leg.alpha_composite(remap_ink(Image.fromarray(rim), u.astype("float32"), v.astype("float32")))
    return leg
