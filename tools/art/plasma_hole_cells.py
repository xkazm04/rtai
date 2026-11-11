"""Pack the asset lane's plasma hole ring (it418 A4, p70) for KillHoleFx.

Three 256x256 frames (1 white-hot cream, 2 amber, 3 cooled char; the hole's open centre ~70 px
in radius) are downscaled by SCALE (Lanczos) and laid three across:
`project/features/combat/weapons/art/gore/plasma_hole.png`. KillHoleFx.ART_HOLE_PX is the open
radius at that scale.

Usage: python tools/art/plasma_hole_cells.py [<library keyed/fx/plasma_hole_70_cells dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SCALE = 0.5
SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/kazda/kiro/gtai-art/library/keyed/fx/plasma_hole_70_cells")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore/plasma_hole.png"


def main():
    frames = [Image.open(SRC / f"1_{n}.png").convert("RGBA") for n in (1, 2, 3)]
    side = round(frames[0].width * SCALE)
    sheet = Image.new("RGBA", (side * 3, side), (0, 0, 0, 0))
    for n, f in enumerate(frames):
        sheet.paste(f.resize((side, side), Image.LANCZOS), (side * n, 0))
    sheet.save(OUT, optimize=True)
    print(f"{OUT.name}: {side}x{side} x3")


if __name__ == "__main__":
    main()
