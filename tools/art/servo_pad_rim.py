"""Servo's hover pad with the sheet's hazard rim: ink and copper stripes (no new art).

Usage: python tools/art/servo_pad_rim.py <pad.png> <out.png>

servo_parts.py's cut of the pad already carries diagonal stripes round its octagonal rim, but in
copper on a mid brown (value ~100 against ~180): at 32 px/m the rim reads as one brown band. The
target sheet's pads carry high-contrast hazard stripes. Here, inside the rim band only (opaque
pixels within RIM_PX of the pad's edge, past its ink outline), the dark stripes are pulled to ink
and the copper stripes lifted a little, holding the palette gate servo_parts.py keeps for the
sheet's orange: r - max(g, b) <= MUTED (vermilion is reserved for danger). Rivets (light grey)
and the outline are kept. Idempotent: a second pass maps the same pixels to the same colours.
"""

import sys
from collections import deque

from PIL import Image

RIM_PX = 15  # px: the rim band's depth from the pad's edge (the plate's ink line sits at ~16)
OUTLINE_PX = 2  # px: the outer ink outline, kept
INK = (27, 22, 26)
INK_TEXTURE = 0.25  # how much of the old stripe's shading survives on the ink stripe
COPPER_LIFT = 1.1
MUTED = 61  # r - max(g, b), 0..255 (servo_parts.py MUTED 0.24)


def edge_distance(im):
    """Steps (4-connected) from every opaque pixel to the nearest transparent one (or past the
    image's border: the cut's octagon touches it)."""
    w, h = im.size
    a = im.getchannel("A").load()
    dist = {}
    q = deque()
    for y in range(h):
        for x in range(w):
            if a[x, y] < 128:
                dist[(x, y)] = 0
                q.append((x, y))
            elif x in (0, w - 1) or y in (0, h - 1):
                dist[(x, y)] = 1
                q.append((x, y))
    while q:
        x, y = q.popleft()
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h and (nx, ny) not in dist:
                dist[(nx, ny)] = dist[(x, y)] + 1
                q.append((nx, ny))
    return dist


def recolour(px):
    r, g, b, a = px
    hi, lo = max(r, g, b), min(r, g, b)
    sat = (hi - lo) / hi if hi else 0.0
    if hi < 60 or (lo > 150 and sat < 0.25):
        return px  # the ink outline, a rivet
    if sat >= 0.4 and r > 140:  # a copper stripe
        r2 = min(int(r * COPPER_LIFT), 255)
        g2 = min(int(g * COPPER_LIFT), 255)
        b2 = min(int(b * COPPER_LIFT), 255)
        return (min(r2, max(g2, b2) + MUTED), g2, b2, a)
    if hi < 140:  # a dark stripe
        m = (r + g + b) / 3.0
        return tuple(
            [max(0, min(255, int(INK[i] + (c - m) * INK_TEXTURE))) for i, c in enumerate((r, g, b))]
            + [a]
        )
    return px


def main(src, dst):
    im = Image.open(src).convert("RGBA")
    dist = edge_distance(im)
    px = im.load()
    for (x, y), d in dist.items():
        if OUTLINE_PX <= d <= RIM_PX:
            px[x, y] = recolour(px[x, y])
    im.save(dst)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
