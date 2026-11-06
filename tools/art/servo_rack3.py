"""Servo's rack wing made N bay rows deep from the installed 2-row wing (no new art).

Usage: python tools/art/servo_rack3.py <rack.png> <out.png> [rows]

The 2-row wing (servo_parts.py's cut of the Codex part sheet) is a top cap, bay row A, a cross
bar, bay row B and a bottom cap between two striped side panels. Repeating its top half one row
further back (ServoRig before) left the top cap's chamfered corners and frame bar across the
middle of the wing: a seam at game zoom. Here the centre columns repeat a whole bay row with its
cross bar (BAND), and the side panels (chamfers and hazard stripes) are stretched to the new
height, so the wing reads as one deeper frame. The row pitch is the art's own (BAND px).
"""

import sys

from PIL import Image

SIDE = 21  # px: the striped side panel and its chamfer, each side
TOP = 12  # px: the top cap ends (frame bar) and bay row A begins
BAR_END = 75  # px: the end of the cross bar under bay row A


def deepen(wing, rows):
    w, h = wing.size
    band = wing.crop((SIDE, TOP, w - SIDE, BAR_END))  # bay row A + its cross bar
    extra = rows - 2
    out_h = h + extra * band.height
    out = Image.new("RGBA", (w, out_h), (0, 0, 0, 0))
    centre = (SIDE, 0, w - SIDE)
    out.alpha_composite(wing.crop((centre[0], 0, centre[2], BAR_END)), (SIDE, 0))
    y = BAR_END
    for _ in range(extra):
        out.alpha_composite(band, (SIDE, y))
        y += band.height
    out.alpha_composite(wing.crop((centre[0], BAR_END, centre[2], h)), (SIDE, y))
    for x0, x1 in ((0, SIDE), (w - SIDE, w)):
        side = wing.crop((x0, 0, x1, h)).resize((x1 - x0, out_h), Image.LANCZOS)
        out.alpha_composite(side, (x0, 0))
    return out


def main():
    rows = int(sys.argv[3]) if len(sys.argv) > 3 else 3
    deepen(Image.open(sys.argv[1]).convert("RGBA"), rows).save(sys.argv[2])


if __name__ == "__main__":
    main()
