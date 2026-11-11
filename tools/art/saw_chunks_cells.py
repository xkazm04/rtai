"""Pack the asset lane's chainsaw chunks (it418 A5, p70) for KillSawChunks.

Ten 96x96 cells at one scale (1-4 meat chunks with drops, 5-6 bone chips, 7 a rib piece, 8 a
cop-navy cloth scrap, 9 a grey cloth scrap, 10 a tooth chip) are downscaled by SCALE (Lanczos)
and laid ten across: `project/features/combat/weapons/art/gore/saw_chunks.png`.

Usage: python tools/art/saw_chunks_cells.py [<library keyed/fx/saw_chunks_70_cells dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SCALE = 0.5
SRC = Path(sys.argv[1] if len(sys.argv) > 1 else "C:/Users/kazda/kiro/gtai-art/library/keyed/fx/saw_chunks_70_cells")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore/saw_chunks.png"


def main():
    cells = [Image.open(SRC / f"1_{n}.png").convert("RGBA") for n in range(1, 11)]
    side = round(cells[0].width * SCALE)
    sheet = Image.new("RGBA", (side * len(cells), side), (0, 0, 0, 0))
    for n, c in enumerate(cells):
        sheet.paste(c.resize((side, side), Image.LANCZOS), (side * n, 0))
    sheet.save(OUT, optimize=True)
    print(f"{OUT.name}: {side}x{side} x{len(cells)}")


if __name__ == "__main__":
    main()
