"""Draws the per-weapon mouse cursors (n11, owner note "cursor icon styled per weapon equipped"):
one ink mark per weapon class on a paper rim, teal rim for the ghost forms (colour law: teal is the
souls'). Hand-coded shapes, supersampled, cut at SIZE px with the hotspot at the centre.

usage: python tools/art/cursor_draw.py [<out_dir>]   (default project/features/hud/art/cursors)
"""
import math
import os
import sys

from PIL import Image, ImageChops, ImageDraw, ImageFilter

SIZE = 48
SS = 4
INK = (23, 19, 27, 255)
PAPER = (233, 220, 195, 255)
TEAL = (46, 196, 181, 255)
RIM_PX = 2.2  # the paper (or teal) edge round the ink, at SIZE


def px(v):
    return v * SS


class Mark:
    """An ink shape drawn in SIZE-px coordinates on a supersampled L mask."""

    def __init__(self):
        self.mask = Image.new("L", (SIZE * SS, SIZE * SS), 0)
        self.draw = ImageDraw.Draw(self.mask)

    def line(self, pts, width):
        self.draw.line([(px(x), px(y)) for x, y in pts], fill=255, width=int(px(width)), joint="curve")

    def poly(self, pts):
        self.draw.polygon([(px(x), px(y)) for x, y in pts], fill=255)

    def dot(self, c, r):
        self.draw.ellipse((px(c[0] - r), px(c[1] - r), px(c[0] + r), px(c[1] + r)), fill=255)

    def ring(self, c, r, width):
        self.draw.ellipse((px(c[0] - r), px(c[1] - r), px(c[0] + r), px(c[1] + r)), outline=255, width=int(px(width)))

    def arc(self, c, r, a0, a1, width, steps=40):
        pts = []
        for i in range(steps + 1):
            a = math.radians(a0 + (a1 - a0) * i / steps)
            pts.append((c[0] + math.cos(a) * r, c[1] + math.sin(a) * r))
        self.line(pts, width)


C = (24.0, 24.0)


def tick(m, a, r0, r1, w):
    ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a))
    m.line([(C[0] + ca * r0, C[1] + sa * r0), (C[0] + ca * r1, C[1] + sa * r1)], w)


def small_arm(m):
    for a in (0, 90, 180, 270):
        tick(m, a, 7, 17, 2.6)
    m.dot(C, 2.0)


def rifle(m):
    tick(m, 0, 6, 20, 2.6)
    tick(m, 180, 6, 20, 2.6)
    tick(m, 90, 6, 14, 2.6)
    m.dot(C, 1.8)


def auto(m):
    for a in (45, 135, 225, 315):
        tick(m, a, 8, 17, 2.6)
    m.ring(C, 4.0, 1.8)


def energy(m):
    r = 13.0
    m.line([(C[0], C[1] - r), (C[0] + r, C[1]), (C[0], C[1] + r), (C[0] - r, C[1]), (C[0], C[1] - r)], 2.4)
    tick(m, 0, 15, 20, 2.2)
    tick(m, 180, 15, 20, 2.2)
    m.dot(C, 2.2)


def flame(m):
    tip = (C[0] + 1.0, C[1] - 16.0)
    pts = [tip]
    for i in range(0, 25):  # up the right side and round the belly, a licking tongue on the left
        t = i / 24.0
        a = math.radians(-60.0 + 300.0 * t)
        r = 9.5 + 1.5 * math.sin(t * math.pi)
        pts.append((C[0] + math.cos(a) * r, C[1] + 5.0 + math.sin(a) * r))
    pts.append(tip)
    m.line(pts, 2.4)
    m.line([(C[0] - 1.0, C[1] + 10.0), (C[0] + 2.5, C[1] + 4.0), (C[0] - 1.5, C[1] - 2.5)], 2.0)


def blast(m):
    m.ring(C, 12.0, 2.4)
    for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
        x, y = C[0] + sx * 20.0, C[1] + sy * 20.0
        m.line([(x, y - sy * 7.0), (x, y), (x - sx * 7.0, y)], 2.4)
    tick(m, 0, 0, 5, 2.0)
    tick(m, 90, 0, 5, 2.0)
    tick(m, 180, 0, 5, 2.0)
    tick(m, 270, 0, 5, 2.0)


def lock(m):
    r = 15.0
    tip = [(C[0] + r * math.cos(math.radians(a)), C[1] + r * math.sin(math.radians(a))) for a in (-90, 30, 150, -90)]
    m.line(tip, 2.4)
    m.dot(C, 2.2)


def crescent(m, centre, r, a0, a1, thick):
    """A tapered blade stroke: full width mid-sweep, a point at each end."""
    outer, inner = [], []
    n = 40
    for i in range(n + 1):
        t = i / n
        a = math.radians(a0 + (a1 - a0) * t)
        half = thick * 0.5 * math.sin(t * math.pi)
        for ring, rr in ((outer, r + half), (inner, r - half)):
            ring.append((centre[0] + math.cos(a) * rr, centre[1] + math.sin(a) * rr))
    m.poly(outer + inner[::-1])


def melee(m):
    crescent(m, (C[0] + 5.0, C[1] + 5.0), 18.0, 150, 300, 6.5)
    tick(m, 225, 3, 9, 2.4)
    m.dot(C, 1.8)


def ghost_tonnage(m):
    for sx, sy in ((-1, -1), (1, -1), (1, 1), (-1, 1)):
        x, y = C[0] + sx * 15.0, C[1] + sy * 15.0
        m.line([(x, y - sy * 8.0), (x, y), (x - sx * 8.0, y)], 4.0)
    m.draw.rectangle((px(C[0] - 4.5), px(C[1] - 4.5), px(C[0] + 4.5), px(C[1] + 4.5)), fill=255)


def ghost_dent(m):
    for a in (45, 135, 225, 315):
        ca, sa = math.cos(math.radians(a)), math.sin(math.radians(a))
        tip = (C[0] + ca * 7.0, C[1] + sa * 7.0)
        out = 19.0
        side = (-sa * 5.0, ca * 5.0)
        m.poly([tip, (C[0] + ca * out + side[0], C[1] + sa * out + side[1]), (C[0] + ca * out - side[0], C[1] + sa * out - side[1])])
    m.dot(C, 2.4)


def ghost_kerf(m):
    crescent(m, (C[0] + 4.0, C[1] + 4.0), 17.0, 165, 345, 7.5)
    crescent(m, (C[0] + 4.0, C[1] + 4.0), 10.0, 195, 315, 3.5)
    m.dot(C, 1.8)


def ghost_ohm(m):
    bolt = [(C[0] + 2.0, C[1] - 15.0), (C[0] - 5.0, C[1] + 1.0), (C[0] + 1.0, C[1] + 1.0), (C[0] - 3.0, C[1] + 15.0)]
    m.line(bolt, 3.2)
    m.ring(C, 17.0, 1.8)


# name: (draw, rim colour)
STYLES = {
    "small_arm": (small_arm, PAPER),
    "rifle": (rifle, PAPER),
    "auto": (auto, PAPER),
    "energy": (energy, PAPER),
    "flame": (flame, PAPER),
    "blast": (blast, PAPER),
    "lock": (lock, PAPER),
    "melee": (melee, PAPER),
    "ghost_tonnage": (ghost_tonnage, TEAL),
    "ghost_dent": (ghost_dent, TEAL),
    "ghost_kerf": (ghost_kerf, TEAL),
    "ghost_ohm": (ghost_ohm, TEAL),
}


def render(fn, rim):
    m = Mark()
    fn(m)
    grown = m.mask.filter(ImageFilter.GaussianBlur(px(RIM_PX) * 0.5)).point(lambda v: 255 if v > 30 else 0)
    grown = ImageChops.lighter(grown, m.mask)
    out = Image.new("RGBA", m.mask.size, (0, 0, 0, 0))
    out.paste(rim, (0, 0), grown)
    out.paste(INK, (0, 0), m.mask)
    return out.resize((SIZE, SIZE), Image.LANCZOS)


def main():
    root = os.path.join(os.path.dirname(__file__), "..", "..", "project")
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(root, "features/hud/art/cursors")
    os.makedirs(out, exist_ok=True)
    for name, (fn, rim) in STYLES.items():
        render(fn, rim).save(os.path.join(out, name + ".png"))
        print(name)


if __name__ == "__main__":
    main()
