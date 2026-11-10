"""n13 weapon art: the dropped pistol's drawn cell (a stunned cop's gun lying on the floor, ShockArcsView).

    python -I tools/art/dropped_gun.py [--cop] [--sim=<preview.png>]

Reads the pistol's pickup cell (weapon_art.json `pickup`: the side view lying on the floor) and writes
`parts.dropped` (pistol/dropped.png): the same drawing re-toned with held_small.py's lift (the body's
mid tones into Rivet's tone budget, the darkest ink kept, no new colour: at 12 screen px the drawn
rust and steel sat at the pavement's own grey and the gun read as a smudge) and pre-reduced with a
premultiplied Lanczos to CELL_W px across (about 4x its size at 32 px/m, mipmapped in the game), so
the mip chain starts from a clean cut instead of a 25:1 box. The runtime draws a 1 px ink outline
round it (ShockArcsView._cell). Deterministic; re-run after a pickup redraw.

n15 combat: `--cop` writes `parts.dropped_cop` (pistol/dropped_cop.png) from the asset lane's navy
service pistol (it325 `dropped_cop_pistol_70_cells/1.png`, muzzle right as the pickup, grade A), the
gun the cop's forearm cell holds, through the same lift and cut.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from held_small import retone  # noqa: E402

TABLE = ROOT / "project/data/tables/weapon_art.json"
WEAPON = "pistol"
PART = "dropped"
COP_PART = "dropped_cop"
COP_SRC = Path("C:/Users/kazda/kiro/gtai-art/library/keyed/prop/dropped_cop_pistol_70_cells/1.png")
CELL_W = 64
EDGE = 6  # part px of ink along the silhouette before the cut (held_small's edge, scaled to the cell)


def _res(path: str) -> Path:
    return ROOT / "project" / path.removeprefix("res://")


def cell(src: Path) -> Image.Image:
    rgba = np.asarray(Image.open(src).convert("RGBA"))
    lifted, _ = retone(rgba, None, EDGE)
    im = Image.fromarray(lifted).convert("RGBa")
    w, h = im.size
    size = (CELL_W, max(1, round(h * CELL_W / w)))
    return im.resize(size, Image.Resampling.LANCZOS).convert("RGBA")


def main(argv: list) -> None:
    rows = {r["id"]: r for r in json.loads(TABLE.read_text(encoding="utf-8"))["weapons"]}
    row = rows[WEAPON]
    cop = "--cop" in argv
    part = COP_PART if cop else PART
    out = cell(COP_SRC if cop else _res(row["pickup"]))
    sim = next((a.split("=", 1)[1] for a in argv if a.startswith("--sim=")), "")
    if sim:
        bg = Image.new("RGBA", out.size, (110, 100, 100, 255))
        bg.alpha_composite(out)
        bg.resize((out.width * 6, out.height * 6), Image.Resampling.NEAREST).save(sim)
        return
    dst = _res(row["parts"][part])
    out.save(dst, optimize=True)
    print(f"{WEAPON} {part}: {out.size} -> {dst}")


if __name__ == "__main__":
    main(sys.argv[1:])
