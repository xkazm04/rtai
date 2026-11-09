"""n11 combat: the asset lane's guard rifle lying on the ground at 70 degrees (keyed/props/
ground_rifle_70/muzzle_<deg>.png, 8 headings drawn, clockwise on screen from muzzle right) packed
as one 8 x 1 sheet for GroundRifle. Each cell is CELL px square with the GUN's own centre (the
opaque pixels that are not the olive sling) on the cell centre, so the gun, not the sling's
bounding box, lies on the drop point. One scale for all eight, as delivered. Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/ground_rifle_sheet.py [--lib=<library>]
"""

import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "project/features/combat/weapons/art/ground_rifle_70.png"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library")
HEADINGS = ["000", "045", "090", "135", "180", "225", "270", "315"]
CELL = 288


def gun_centre(im: Image.Image) -> tuple[float, float]:
    """The bbox centre of the opaque pixels that are not the sling (olive: green over red and blue)."""
    a = np.asarray(im).astype(np.int32)
    r, g, b, al = a[..., 0], a[..., 1], a[..., 2], a[..., 3]
    sling = (g > r + 4) & (g > b + 20)
    ys, xs = np.nonzero((al > 128) & ~sling)
    return (xs.min() + xs.max() + 1) / 2.0, (ys.min() + ys.max() + 1) / 2.0


def main() -> int:
    lib = LIB
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
    src = lib / "keyed/props/ground_rifle_70"
    sheet = Image.new("RGBA", (CELL * len(HEADINGS), CELL), (0, 0, 0, 0))
    for i, deg in enumerate(HEADINGS):
        im = Image.open(src / f"muzzle_{deg}.png").convert("RGBA")
        cx, cy = gun_centre(im)
        sheet.alpha_composite(im, (round(CELL * i + CELL / 2.0 - cx), round(CELL / 2.0 - cy)))
    sheet.save(OUT, optimize=True)
    print(f"ground_rifle_sheet: {OUT.relative_to(ROOT).as_posix()} {sheet.size}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
