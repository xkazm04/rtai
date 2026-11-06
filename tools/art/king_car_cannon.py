"""d8 bosses: the throne-car's hood cannon barrel for one view pitch, cut from the approved car sheet.

usage: python -I tools/art/king_car_cannon.py <king_car_55.png> <out dir>

The side view's barrel (breech ring to muzzle, the laurel and the mount bracket left out) is the
same silhouette a round barrel shows from above, so KingBodyView draws it as a textured quad along
the barrel under a tilt. Only the barrel's upper half is clean on the sheet (the laurel and the
bracket cover its lower half), so the strip is that half mirrored about the barrel's axis: a
symmetric barrel, breech at the left (x 0), muzzle at the right. Chroma key: cut_facings.key_out.
Deterministic.
"""

import os
import sys

import numpy as np
from PIL import Image

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut_facings import key_out  # noqa: E402

BARREL_BOX = (1385, 233, 1474, 256)  # sheet px: breech ring .. muzzle lip, the top ink .. the axis


def main() -> None:
    if len(sys.argv) != 3:
        sys.exit("usage: king_car_cannon.py <king_car_55.png> <out dir>")
    sheet = Image.open(sys.argv[1]).convert("RGB")
    keyed = key_out(sheet.crop(BARREL_BOX), 14.0)
    upper = keyed[:-1]  # the axis row once, at the middle
    strip = np.concatenate([upper, keyed[-1:], upper[::-1]], axis=0)
    os.makedirs(sys.argv[2], exist_ok=True)
    Image.fromarray(strip, "RGBA").save(os.path.join(sys.argv[2], "cannon.png"))


if __name__ == "__main__":
    main()
