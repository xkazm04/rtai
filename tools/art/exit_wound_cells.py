"""Pack the asset lane's hand cannon exit wound (it434 A6, p70) for KillExitWound.

Three 160x160 cells at one scale (1 fresh with grey cloth flaps, 2 dried with grey flaps, 3 fresh
with cop-navy flaps; the hole ~65 px across, the spatter tongue out to +x) are downscaled by SCALE
(Lanczos) and laid three across: `project/features/combat/weapons/art/gore/exit_wound.png`.
KillExitWound.ART_HOLE_PX is the hole's width at that scale. The p55 view squashes in code.

Usage: python tools/art/exit_wound_cells.py [<library keyed/fx/exit_wound_70_cells dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SCALE = 0.5
SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/kazda/kiro/gtai-art/library/keyed/fx/exit_wound_70_cells")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore/exit_wound.png"


def main():
    cells = [Image.open(SRC / f"1_{n}.png").convert("RGBA") for n in (1, 2, 3)]
    side = round(cells[0].width * SCALE)
    sheet = Image.new("RGBA", (side * len(cells), side), (0, 0, 0, 0))
    for n, c in enumerate(cells):
        sheet.paste(c.resize((side, side), Image.LANCZOS), (side * n, 0))
    sheet.save(OUT, optimize=True)
    print(f"{OUT.name}: {side}x{side} x{len(cells)}")


if __name__ == "__main__":
    main()
