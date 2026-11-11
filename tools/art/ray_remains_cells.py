"""Pack the asset lane's ray gun remains (it434 A7, p70) for KillRemainsArt.

Four 256x160 cells at one scale (set 1 cop-navy clothes, set 2 neutral grey; frame 1 with amber
glowing cracks, frame 2 cooled): an ash heap with a half-sunk skull, rib arcs and a forearm bone,
the empty clothes crumpled flat beside it (to +x). Downscaled by SCALE (Lanczos) and laid four
across in the order 1_1, 1_2, 2_1, 2_2: `project/features/combat/weapons/art/gore/ray_remains.png`.

Usage: python tools/art/ray_remains_cells.py [<library keyed/fx/ray_remains_70_cells dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SCALE = 0.5
SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/kazda/kiro/gtai-art/library/keyed/fx/ray_remains_70_cells")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore/ray_remains.png"
ORDER = ("1_1", "1_2", "2_1", "2_2")


def main():
    cells = [Image.open(SRC / f"{n}.png").convert("RGBA") for n in ORDER]
    w, h = round(cells[0].width * SCALE), round(cells[0].height * SCALE)
    sheet = Image.new("RGBA", (w * len(cells), h), (0, 0, 0, 0))
    for n, c in enumerate(cells):
        sheet.paste(c.resize((w, h), Image.LANCZOS), (w * n, 0))
    sheet.save(OUT, optimize=True)
    print(f"{OUT.name}: {w}x{h} x{len(cells)}")


if __name__ == "__main__":
    main()
