"""n11 combat: the fall to lying pop (critique it6: arms and head jump between the mid-fall and the
lying frame). The asset lane drew two in-between cells per facing column (keyed/street/
<kind>_hit_70_cells/fall1_<c>.png knees and hands landing, fall2_<c>.png chest down, one leg bent;
c = 1..5 the grid's columns, already at the grid's scale). This inserts them as rows 2 and 3 of the
kind's long fall grid: 5 rows = buckle, mid-fall, fall1, fall2, lying, same cell size, each figure
placed as street_fall.py places its frames (fall1 as a mid-fall frame: the lowest rows' x centre on
the cell centre; fall2 as a lying frame: the end away from the column's fall direction). Writes
<kind>_between_fall.png beside the 3-row grid (StreetWalkerFall.BETWEEN). Deterministic.
it18: fall1, fall2 and the lying row are scaled down (proportions kept) to at most CAP of the still
strip's STILL_PX on their longest side: delivered at 1.1, 1.9 and 2.2 x standing, the owner's "the
size gets increased" (StreetFallBetween.LIE_IN_GRID lies the body in that row, at the card's scale).

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_fall_between.py [--lib=<library>/keyed/street]
"""

import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent))
import street_fall as sf  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
P70 = ROOT / "project/features/characters/art/view/p70"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/street")
# kind -> (the 3-row long fall grid, the 5-row grid written)
KINDS = {
    "cop_patrol": ("cop_patrol_long_fall.png", "cop_patrol_between_fall.png"),
    "cop_riot": ("cop_riot_long_fall.png", "cop_riot_between_fall.png"),
    "swat": ("swat_long_fall.png", "swat_between_fall.png"),
    "ped_suit": ("ped_suit_long_fall.png", "ped_suit_between_fall.png"),
}
COLS = 5
# kinds whose long fall grid draws a warm arm band: greyed by street_armband.py (colour law)
BAND = {"cop_riot", "swat"}
STILL_PX = 192.0  # StreetWalkerFall.STILL_PX
# row -> the longest side's cap, of STILL_PX (fall1, fall2, lying)
CAP = {2: 1.06, 3: 1.06, 4: 1.06}


def capped(cell: Image.Image, row: int) -> Image.Image:
    """`cell` scaled down so its figure's longest side is at most CAP[row] x STILL_PX."""
    rgba = cell.convert("RGBA")
    ys, xs = np.nonzero(np.asarray(rgba)[:, :, 3] > 128)
    longest = max(xs.max() - xs.min() + 1, ys.max() - ys.min() + 1)
    k = min(1.0, CAP[row] * STILL_PX / longest)
    if k >= 1.0:
        return rgba
    return rgba.resize((round(rgba.width * k), round(rgba.height * k)), Image.LANCZOS)


def place(sheet: Image.Image, cell: Image.Image, col: int, row: int, cw: int, ch: int, frame: int):
    rgba = np.asarray(capped(cell, row))
    mask = rgba[:, :, 3] > 128
    ys, xs = np.nonzero(mask)
    crop = Image.fromarray(rgba[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1])
    fx, fy = sf._feet(mask[ys.min() : ys.max() + 1, xs.min() : xs.max() + 1], col, frame)
    sheet.alpha_composite(crop, (round(col * cw + cw / 2 - fx), round(row * ch + ch / 2 - fy)))


def build(kind: str, lib: Path) -> None:
    src, out = KINDS[kind]
    grid = Image.open(P70 / src).convert("RGBA")
    cw, ch = grid.width // COLS, grid.height // 3
    sheet = Image.new("RGBA", (grid.width, ch * 5), (0, 0, 0, 0))
    for r in (0, 1):
        sheet.alpha_composite(grid.crop((0, r * ch, grid.width, (r + 1) * ch)), (0, r * ch))
    cells = lib / f"{kind}_hit_70_cells"
    for c in range(COLS):
        place(sheet, grid.crop((c * cw, 2 * ch, (c + 1) * cw, 3 * ch)), c, 4, cw, ch, 2)
        place(sheet, Image.open(cells / f"fall1_{c + 1}.png"), c, 2, cw, ch, 1)
        place(sheet, Image.open(cells / f"fall2_{c + 1}.png"), c, 3, cw, ch, 2)
    sheet.save(P70 / out, optimize=True)
    if kind in BAND:
        band = Path(__file__).resolve().parent / "street_armband.py"
        subprocess.run([sys.executable, "-I", str(band), str(P70 / out), str(P70 / out)], check=True)
        Image.open(P70 / out).save(P70 / out, optimize=True)
    print(f"street_fall_between: {out} {sheet.size}, cell {cw}x{ch}")


def main() -> int:
    lib = LIB
    for arg in sys.argv[1:]:
        if arg.startswith("--lib="):
            lib = Path(arg[6:])
    for kind in KINDS:
        build(kind, lib)
    return 0


if __name__ == "__main__":
    sys.exit(main())
