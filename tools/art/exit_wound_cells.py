"""Pack the asset lane's hand cannon exit wound (it434 A6, p70) for KillExitWound.

Three 160x160 cells at one scale (1 fresh with grey cloth flaps, 2 dried with grey flaps, 3 fresh
with cop-navy flaps; the hole ~65 px across, the spatter tongue out to +x) are downscaled by SCALE
(Lanczos) and laid three across: `project/features/combat/weapons/art/gore/exit_wound.png`.
KillExitWound.ART_HOLE_PX is the hole's width at that scale. The p55 view squashes in code.

Set 2 (it434 A6b, the redraw: a ragged hole, snapped ribs fanned out, the spine knocked out of
line, nothing that reads as teeth) is the one packed; `--set=1` packs the first drawing.

Usage: python tools/art/exit_wound_cells.py [--set=1|2] [<library keyed/fx/exit_wound_70_cells dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SCALE = 0.5
ARGS = [a for a in sys.argv[1:] if not a.startswith("--set=")]
SET = next((a[6:] for a in sys.argv[1:] if a.startswith("--set=")), "2")
SRC = Path(ARGS[0] if ARGS else "C:/Users/kazda/kiro/gtai-art/library/keyed/fx/exit_wound_70_cells")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore/exit_wound.png"


def main():
    cells = [Image.open(SRC / f"{SET}_{n}.png").convert("RGBA") for n in (1, 2, 3)]
    side = round(cells[0].width * SCALE)
    sheet = Image.new("RGBA", (side * len(cells), side), (0, 0, 0, 0))
    for n, c in enumerate(cells):
        sheet.paste(c.resize((side, side), Image.LANCZOS), (side * n, 0))
    sheet.save(OUT, optimize=True)
    print(f"{OUT.name}: {side}x{side} x{len(cells)}")


if __name__ == "__main__":
    main()
