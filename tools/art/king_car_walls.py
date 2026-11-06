"""d8 bosses: the throne-car's wall art for one view pitch, cut from the approved car sheet.

usage: python -I tools/art/king_car_walls.py <king_car_55.png> <out dir>

KingCarStack draws the car as a sprite stack under a tilt: each slice's rim takes one row of a wall
texture (row 0 = the roof line, the last row = the ground). Three walls, all from the sheet so the
car matches the concept the owner approved:
- side: the side view's body band (glass with gold pillars, the gold belt, plum drapes with gold
  tassels, gilded wheels), nose at the right, tail at the left;
- rear: the rear view's band below the throne (gold deck rail, bumper); its tail lamps were red on
  the sheet and are amber here (red is blood only);
- front: the rear band with its lamps and centre panel painted over by OUR grille: a gilded
  sunburst fan under a plum crest (not the sheet's slatted temple grille, a maker's trade dress,
  LEG-02), round cream headlamps in gold bezels.
The chroma key is cut_facings.key_out; transparent pixels stay (the stack's lacquer fill shows).
Deterministic.
"""

import colorsys
import math
import os
import sys

import numpy as np
from PIL import Image, ImageDraw

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut_facings import key_out  # noqa: E402

SIDE_BOX = (893, 303, 1497, 414)  # sheet px: window tops .. tyre bottoms, bumper to bumper
REAR_BOX = (928, 826, 1202, 962)  # below the throne's crest .. the bumper's foot
LAMP_BOXES = [(933, 886, 1003, 922), (1128, 886, 1198, 922)]  # rear-band px of the tail lamps
GRILLE_BOX = (1010, 858, 1122, 924)
AMBER_HUE = 28.0 / 360.0
INK = (27, 21, 23, 255)
GOLD = (217, 169, 51, 255)
GOLD_HI = (246, 214, 120, 255)
GOLD_DARK = (138, 100, 24, 255)
PLUM = (90, 35, 53, 255)
LAMP = (243, 233, 200, 255)


def amber(rgba: np.ndarray) -> np.ndarray:
    """Every saturated red pixel turned amber, its value kept (the tail lamps, any cape edge)."""
    out = rgba.copy()
    for y in range(out.shape[0]):
        for x in range(out.shape[1]):
            r, g, b, a = (int(v) for v in out[y, x])
            if a == 0:
                continue
            h, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
            if s > 0.4 and v > 0.2 and (h < 18.0 / 360.0 or h > 345.0 / 360.0):
                nr, ng, nb = colorsys.hsv_to_rgb(AMBER_HUE, min(1.0, s * 1.05), min(1.0, v * 1.25))
                out[y, x, :3] = (round(nr * 255), round(ng * 255), round(nb * 255))
    return out


def grille(draw: ImageDraw.ImageDraw, box: tuple) -> None:
    """Our gilded sunburst: gold rays fanning up from a hub at the panel's foot, a plum crest."""
    x0, y0, x1, y1 = box
    draw.rounded_rectangle(box, radius=6, fill=INK)
    draw.rounded_rectangle((x0 + 3, y0 + 3, x1 - 3, y1 - 3), radius=5, fill=GOLD_DARK)
    hub = ((x0 + x1) / 2.0, y1 - 4.0)
    for i in range(13):  # each ray runs to the panel's rim (the box less its ink edge)
        ang = math.pi + math.pi * (i + 0.5) / 13.0
        d = (math.cos(ang), math.sin(ang))
        reach = min((x1 - x0) / 2.0 / max(abs(d[0]), 1e-3), (y1 - y0) / max(abs(d[1]), 1e-3)) - 6.0
        tip = (hub[0] + d[0] * reach, hub[1] + d[1] * reach)
        draw.line([hub, tip], fill=INK, width=7)
        draw.line([hub, tip], fill=GOLD_HI if i % 2 == 0 else GOLD, width=4)
    draw.rectangle((x0, y0, x1, y0 + 6), fill=GOLD)  # the gold header bar over the fan
    cx, cy = hub[0], y0 + 14.0
    draw.ellipse((cx - 11, cy - 11, cx + 11, cy + 11), fill=INK)
    draw.ellipse((cx - 8, cy - 8, cx + 8, cy + 8), fill=GOLD)
    draw.ellipse((cx - 5, cy - 5, cx + 5, cy + 5), fill=PLUM)


def headlamp(draw: ImageDraw.ImageDraw, box: tuple) -> None:
    draw.rounded_rectangle(box, radius=4, fill=INK)  # the tail lamp's housing, lacquered over
    draw.rounded_rectangle((box[0] + 3, box[1] + 3, box[2] - 3, box[3] - 3), radius=3, fill=GOLD_DARK)
    cx, cy = (box[0] + box[2]) / 2.0, (box[1] + box[3]) / 2.0
    for k, r in enumerate((19, 16, 12)):
        col = (INK, GOLD, LAMP)[k]
        draw.ellipse((cx - r, cy - r, cx + r, cy + r), fill=col)
    draw.ellipse((cx - 7, cy - 8, cx - 1, cy - 2), fill=(255, 252, 240, 255))


def main() -> None:
    sheet = Image.open(sys.argv[1])
    out_dir = sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)
    keyed = Image.fromarray(key_out(sheet, 14.0), "RGBA")
    side = Image.fromarray(amber(np.asarray(keyed.crop(SIDE_BOX))), "RGBA")
    rear = Image.fromarray(amber(np.asarray(keyed.crop(REAR_BOX))), "RGBA")
    front = keyed.copy()
    draw = ImageDraw.Draw(front)
    for box in LAMP_BOXES:
        headlamp(draw, box)
    grille(draw, GRILLE_BOX)
    front = Image.fromarray(amber(np.asarray(front.crop(REAR_BOX))), "RGBA")
    front = front.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    side.save(os.path.join(out_dir, "car_side.png"))
    rear.save(os.path.join(out_dir, "car_rear.png"))
    front.save(os.path.join(out_dir, "car_front.png"))


if __name__ == "__main__":
    main()
