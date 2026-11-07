"""d9 rivet: cut Rivet's dialogue bust (portraits.json row `rivet`) from the approved 55 sheet.

usage: python -I tools/art/rivet_portrait.py <rivet_55_v2.png> <out.png> [--check]

The library's keyed rivet_55_v2 (owner-approved production sheet, round 20261106-2215) holds five
full-body facings in its top row; the front facing (the leftmost figure) is cut from the helmet's
top down to CUT of its height (helmet, the amber visor, the hazard collar, the chest), at the
sheet's own resolution (no resample: ~274 x 225, the cast portraits' size), and its bottom FADE px
fade to clear so the cut reads as a bust edge, not a slice. --check exits 1 when <out.png> differs
from a fresh cut. Deterministic.
"""

import sys

import numpy as np
from PIL import Image
from scipy import ndimage

TOP_ROW_PX = 520
MIN_FIG_H = 200
CUT = 0.54
FADE = 22


def cut(sheet):
    a = np.asarray(sheet.convert("RGBA")).copy()
    m = a[:, :, 3] > 40
    m[TOP_ROW_PX:] = False
    lab, _ = ndimage.label(ndimage.binary_dilation(m, iterations=3))
    figs = [o for o in ndimage.find_objects(lab) if o[0].stop - o[0].start > MIN_FIG_H]
    ys, xs = min(figs, key=lambda o: o[1].start)  # the front facing: the leftmost figure
    bottom = int(ys.start + (ys.stop - ys.start) * CUT)
    out = a[ys.start : bottom, xs.start : xs.stop].copy()
    ramp = np.linspace(1.0, 0.0, FADE + 1)[1:]
    out[-FADE:, :, 3] = (out[-FADE:, :, 3] * ramp[:, None]).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 2
    img = cut(Image.open(argv[0]))
    if "--check" in argv:
        same = np.array_equal(np.asarray(Image.open(argv[1]).convert("RGBA")), np.asarray(img))
        print("rivet_portrait: " + ("up to date" if same else "STALE"))
        return 0 if same else 1
    img.save(argv[1])
    print(f"rivet_portrait: {img.size[0]}x{img.size[1]} -> {argv[1]}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
