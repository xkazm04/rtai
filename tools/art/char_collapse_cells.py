"""Pack the asset lane's burn collapse (it434 A8, p70, facing 1) for KillCharCells.

Per kind three 344x256 cells in the char_hit cells' format and scale (feet on the FOOT_Y line):
1 crumbling (a shoulder breaking off), 2 slumped on the knees with the skull and rib arcs
showing, 3 the ash heap with the skull and the kind's charred gear. Laid three across at full
size: `project/features/combat/weapons/art/gore/char_collapse_<kind>.png`.

Usage: python tools/art/char_collapse_cells.py <kind>... [--src=<library keyed/street dir>]
"""

import sys
from pathlib import Path

from PIL import Image

SRC = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/street")
OUT = Path(__file__).resolve().parents[2] / "project/features/combat/weapons/art/gore"


def pack(src: Path, kind: str) -> None:
    cells = [Image.open(src / f"{kind}_char_collapse_70_cells" / f"1_{n}.png").convert("RGBA") for n in (1, 2, 3)]
    w, h = cells[0].size
    sheet = Image.new("RGBA", (w * 3, h), (0, 0, 0, 0))
    for n, c in enumerate(cells):
        sheet.paste(c, (w * n, 0))
    out = OUT / f"char_collapse_{kind}.png"
    sheet.save(out, optimize=True)
    print(f"{out.name}: {w}x{h} x3")


def main():
    src = SRC
    kinds = []
    for a in sys.argv[1:]:
        if a.startswith("--src="):
            src = Path(a[6:])
        else:
            kinds.append(a)
    for k in kinds:
        pack(src, k)


if __name__ == "__main__":
    main()
