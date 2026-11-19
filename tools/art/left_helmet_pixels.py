"""Count native RGBA changes in reviewed helmet boxes in the shipped left strips.

Boxes enclose the cap, shell, ear disc and lower rim. Coordinates are relative
to the source's opaque extent (use the dark twin's origin for both fire frames).
The rectangular corners also enclose visible collar stripes on the curved neck.
Compare against a collar-only reconstruction to count these separately.
"""
from pathlib import Path
import sys
import numpy as np
from PIL import Image
import json

from cell_metrics import VIEW, cells
from left_from_right import mirror_cell

# Left, right (exclusive), bottom (exclusive). Top is the crown, at offset 0.
# Native source order is SE, E, NE, E firing.
BOXES = {
    "gloria": (( (15,71,66), (4,57,64), (9,64,63), (22,76,56) ),
               ( (16,94,82), (4,81,84), (6,81,82), (21,95,81) )),
    "rocket_launcher": (((25,83,69),(10,68,64),(6,63,63),(23,70,48)),
                        ((16,94,88),(5,82,89),(3,81,87),(17,89,76))),
    "mini_nuke": (((18,76,67),(2,55,65),(4,62,65),(22,75,60)),
                  ((11,98,93),(2,88,90),(10,96,92),(11,108,93))),
    "plasma_rifle": (((15,74,68),(0,56,65),(9,66,66),(16,68,59)),
                    ((19,109,90),(9,98,93),(13,103,91),(23,109,85))),
    "gatling": (((30,90,69),(19,77,67),(23,81,65),(32,85,59)),
                ((32,112,87),(26,105,86),(23,106,85),(34,111,82))),
    "flamethrower": (((31,87,69),(23,81,67),(23,84,66),(32,85,60)),
                     ((32,109,89),(29,108,84),(29,107,81),(37,113,80))),
}


def rows(gun):
    recipes = json.loads((Path(__file__).parent / "left_regions" / (gun + ".json")).read_text())
    for pitch, boxes in zip(("p55", "p70"), BOXES[gun]):
        base = VIEW / pitch / ("rivet_eq_" + gun + ".png")
        dark = base.with_stem(base.stem + "_noflash")
        for slot, (i, name) in enumerate(zip((1, 2, 3, 5), ("SW", "W", "NW", "W-fire"))):
            firing = i == 5
            ref = dark if firing and dark.exists() else base
            ox, oy, _, _ = Image.fromarray(cells(ref, 8)[i]).getbbox()
            l, r, b = boxes[slot]
            box = (ox+l, oy, ox+r, oy+b)
            regions = recipes[pitch + ("_fire" if firing else "")][0 if firing else slot]
            collar = [region for region in regions if "collar" in region["part"]]
            if len(collar) != 1:
                raise ValueError("expected a reviewed collar band")
            for source in ([base, dark] if firing and dark.exists() else [base]):
                suffix = "_left_fire" if firing else "_left"
                if source == dark:
                    suffix += "_noflash"
                target = cells(base.with_stem(base.stem + suffix), 1 if firing else 3)[0 if firing else slot]
                target = target[:, ::-1][box[1]:box[3], box[0]:box[2]]
                image = Image.fromarray(cells(source, 8)[i])
                original = np.asarray(image.crop(box))
                allowed = np.asarray(mirror_cell(image, collar))[:, ::-1][box[1]:box[3], box[0]:box[2]]
                changed = np.any(target != original, axis=2)
                other = changed & np.any(target != allowed, axis=2)
                total = int(changed.sum())
                yield (gun, pitch, name + ("-noflash" if source == dark else ""),
                       ",".join(map(str, box)), total, total-int(other.sum()), int(other.sum()))


if __name__ == "__main__":
    print("weapon pitch pose source_helmet_xyxy changed collar_only other")
    failures = 0
    for weapon in sys.argv[1:] or BOXES:
        for row in rows(weapon):
            print(*row)
            failures += row[-1]
    sys.exit(bool(failures))
