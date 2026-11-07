"""A prop card's world-print twin (night n8, lane city).

PropOcclusion redraws an arena card over a body on the actor layer, whose item print
(look_d4_item) snaps each pixel to the nearest ink: the orange crates snap to vermilion there,
while the world print (look_d4, which the floor's card goes through) prints them by ink density
as cream and wash. The twin is the strip pre-printed the world's way (look_d4 plates(): ink
density with the vermilion plate's ink taken out, the d4 profile's three wash steps), so the item
print snaps it to the same paper, wash and ink. Alpha is kept.

    python tools/art/print_twin.py <in.png> <out.png>
"""

import sys

from PIL import Image

PAPER = (0.949, 0.910, 0.835)
WASH = (0.400, 0.372, 0.408)
INK = (0.090, 0.075, 0.106)
# look_profiles.json d4 world
STEP_LO, STEP_MID, STEP_HI = 0.19, 0.45, 0.68
WASH_LO, WASH_MID, WASH_HI = 0.30, 0.90, 0.30


def mix(a, b, k):
    return tuple(x + (y - x) * k for x, y in zip(a, b))


def density(r, g, b):
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    v = min(max((r - max(g, b) - 0.12) * 2.6, 0.0), 1.0)
    return min(max((0.93 - lum) * 1.25 - v * 0.55, 0.0), 1.0)


def tone(t):
    if t >= STEP_HI:
        return mix(WASH, INK, WASH_HI)
    if t >= STEP_MID:
        return mix(PAPER, WASH, WASH_MID)
    if t >= STEP_LO:
        return mix(PAPER, WASH, WASH_LO)
    return PAPER


def main(src, dst):
    im = Image.open(src).convert("RGBA")
    out = Image.new("RGBA", im.size)
    cache = {}
    px = []
    for r, g, b, a in im.getdata():
        key = (r, g, b)
        if key not in cache:
            c = tone(density(r / 255.0, g / 255.0, b / 255.0))
            cache[key] = tuple(round(x * 255) for x in c)
        px.append(cache[key] + (a,))
    out.putdata(px)
    out.save(dst, optimize=True)


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
