"""Sole landmarks measured on Tonnage’s shipped walk drawings."""

import cv2
import numpy as np


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
        first = last = x
        while first > 0 and bottom[first - 1] >= y - 3:
            first -= 1
        while last + 1 < key.width and bottom[last + 1] >= y - 3:
            last += 1
        if last - first < 38:
            pads.append(((first + last) / 2, y))
    return np.array([max((p for p in pads if lo <= p[0] < hi), key=lambda p: p[1])
                     for lo, hi in [(0, 45), (48, 115), (118, key.width)]])


def straight_pads(key):
    """Track the lowest sole on each side of a front- or rear-facing housing."""
    alpha = np.asarray(key)[..., 3] > 128
    bottom = np.where(alpha.any(0), key.height - 1 - alpha[::-1].argmax(0), -1)
    pads = []
    for first, last in [(0, key.width // 2), (key.width // 2, key.width)]:
        low = bottom[first:last].max()
        xs = np.flatnonzero(bottom[first:last] >= low - 3)
        sole = max(np.split(xs, np.flatnonzero(np.diff(xs) > 1) + 1), key=len)
        pads.append((first + (sole[0] + sole[-1]) / 2, low))
    return np.array(pads)
