"""n16 kills-new: packs a signature death's drawn cells into one grid per kind.

The asset lane draws each n16 death per street kind as cells
`<lib>/<kind>_<death>_70_cells/<frame>_<column>.png` (frames 1..N down, columns 1..5 in the kind's
long fall grid order: front, 3/4 front, side, 3/4 away, away; each cell at the fall grid's px per
metre, the figure's feet registered to the cell's bottom-centre line of the grid). This writes
`project/features/characters/art/view/p70/<kind>_<death>.png`: 5 columns x N rows, every cell
shifted so the upright frame's feet (frame 2, the buckle, or UPRIGHT_BY_DEATH's: the lowest opaque row of each column)
sit on the cell centre, as the fall grids draw them (KillFallCells: `centered`). The away column's
corpse (the last frame) is the 3/4-away one when BACK_FROM_AWAY names the kind, as the long fall
grids do (a face-down corpse seen from behind reads as a person standing). Deterministic.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/kill_cells_pack.py --death=pistol_snap [--art=p55] [--lib=<dir>]
A death in SCRAPS_BY_DEATH also packs its loose scrap row as `<kind>_<death>_scraps.png`.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/kill_cells_pack.py --headgear  (<kind>_headgear_tumble.png)
"""

import argparse
import hashlib
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
VIEW = ROOT / "project/features/characters/art/view"
P70 = VIEW / "p70"
LIB = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/street")
KINDS = ("cop_patrol", "cop_riot", "swat", "ped_suit")
COLS = 5
# kind -> the kinds whose delivered away corpse reads standing (use the 3/4-away corpse)
BACK_FROM_AWAY = {"pistol_snap": ("cop_patrol",)}
ALPHA_MIN = 40
UPRIGHT_FRAME = 2
# death -> its upright frame when not frame 2 (nail_pin: frame 2 hangs with the knees drawn up)
UPRIGHT_BY_DEATH = {"nail_pin": 1, "gatling_shred": 1}
# death -> its frame count when the folder holds more rows (gatling_shred: row 4 is the loose scraps)
FRAMES_BY_DEATH = {"gatling_shred": 3}
# death -> its row of loose scrap cells, packed as <kind>_<death>_scraps.png (one square cell each)
SCRAPS_BY_DEATH = {"gatling_shred": 4}
# kind -> its row of the loose headgear cells (cop_headgear_tumble_70_cells/<row>_<frame>.png)
HEADGEAR = {"cop_patrol": 1, "cop_riot": 2, "swat": 3}


def feet_y(cell: Image.Image) -> int:
    a = np.asarray(cell.getchannel("A")) > ALPHA_MIN
    rows = np.nonzero(a.any(axis=1))[0]
    return int(rows[-1]) if rows.size else cell.height // 2


def frames_of(src: Path) -> int:
    n = 0
    while (src / f"{n + 1}_1.png").exists():
        n += 1
    return n


def pack(kind: str, death: str, lib: Path, art: str = "p70") -> Path | None:
    src = lib / f"{kind}_{death}_{art[1:]}_cells"
    n = min(frames_of(src), FRAMES_BY_DEATH.get(death, 99))
    if n == 0:
        return None
    first = Image.open(src / "1_1.png")
    w, h = first.size
    up = UPRIGHT_BY_DEATH.get(death, UPRIGHT_FRAME)
    out = Image.new("RGBA", (w * COLS, h * n), (0, 0, 0, 0))
    for c in range(1, COLS + 1):
        dy = h // 2 - feet_y(Image.open(src / f"{up}_{c}.png").convert("RGBA"))
        for f in range(1, n + 1):
            col = c
            if f == n and c == COLS and kind in BACK_FROM_AWAY.get(death, ()):
                col = COLS - 1
            cell = Image.open(src / f"{f}_{col}.png").convert("RGBA")
            if f == n and col != c:  # the 3/4-away corpse keeps its own column's registration
                dy_c = h // 2 - feet_y(Image.open(src / f"{up}_{col}.png").convert("RGBA"))
            else:
                dy_c = dy
            slot = Image.new("RGBA", (w, h), (0, 0, 0, 0))
            slot.paste(cell, (0, dy_c))  # clipped to its own cell
            out.alpha_composite(slot, ((c - 1) * w, (f - 1) * h))
    dst = VIEW / art / f"{kind}_{death}.png"
    out.save(dst, optimize=True)
    return dst


def pack_scraps(kind: str, death: str, lib: Path, art: str = "p70") -> Path | None:
    """The death's loose scraps (row SCRAPS_BY_DEATH): across, each centred in a square cell."""
    if death not in SCRAPS_BY_DEATH:
        return None
    src = lib / f"{kind}_{death}_{art[1:]}_cells"
    row = SCRAPS_BY_DEATH[death]
    cells = []
    while (src / f"{row}_{len(cells) + 1}.png").exists():
        cells.append(Image.open(src / f"{row}_{len(cells) + 1}.png").convert("RGBA"))
    if not cells:
        return None
    side = max(max(c.size) for c in cells)
    out = Image.new("RGBA", (side * len(cells), side), (0, 0, 0, 0))
    for i, c in enumerate(cells):
        out.alpha_composite(c, (i * side + (side - c.width) // 2, (side - c.height) // 2))
    dst = VIEW / art / f"{kind}_{death}_scraps.png"
    out.save(dst, optimize=True)
    return dst


def pack_headgear(kind: str, lib: Path) -> Path | None:
    """The kind's loose cap or helmet: its 2 tumble frames across, each centred in a square cell."""
    if kind not in HEADGEAR:
        return None
    src = lib / "cop_headgear_tumble_70_cells"
    cells = [Image.open(src / f"{HEADGEAR[kind]}_{f}.png").convert("RGBA") for f in (1, 2)]
    side = max(max(c.size) for c in cells)
    out = Image.new("RGBA", (side * 2, side), (0, 0, 0, 0))
    for i, c in enumerate(cells):
        out.alpha_composite(c, (i * side + (side - c.width) // 2, (side - c.height) // 2))
    dst = P70 / f"{kind}_headgear_tumble.png"
    out.save(dst, optimize=True)
    return dst


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--death", default="pistol_snap")
    ap.add_argument("--lib", default=str(LIB))
    ap.add_argument("--art", default="p70", help="p70 or p55 (the cells' pitch)")
    ap.add_argument("--headgear", action="store_true", help="pack the loose headgear cells instead")
    args = ap.parse_args()
    for kind in KINDS:
        if args.headgear:
            dst = pack_headgear(kind, Path(args.lib))
        else:
            dst = pack(kind, args.death, Path(args.lib), args.art)
        if dst is None:
            print(f"{kind}: no cells")
            continue
        scraps = None if args.headgear else pack_scraps(kind, args.death, Path(args.lib), args.art)
        if scraps is not None:
            sha_s = hashlib.sha256(scraps.read_bytes()).hexdigest()
            print(f"{kind}: {scraps.relative_to(ROOT).as_posix()} {Image.open(scraps).size} sha256 {sha_s}")
        sha = hashlib.sha256(dst.read_bytes()).hexdigest()
        print(f"{kind}: {dst.relative_to(ROOT).as_posix()} {Image.open(dst).size} sha256 {sha}")


if __name__ == "__main__":
    main()
