"""n11 hero (the owner's "Rivet jumps too much"): measure the helmet's top per walk/run grid cell.

usage: py -3 -I tools/art/rivet_bob.py project/features/characters/art/view project/data/tables/rivet_bob.json

The grids are packed bottom-aligned (rivet_walk.py), so the drawn up-and-down of the helmet is the bob
the game shows. RivetBob reads this table and lifts each frame to cut that travel (damp_walk, damp_run).
Deterministic.
"""

import json
import sys
from pathlib import Path

import numpy as np
from PIL import Image

GRIDS = ("rivet_walk8.png", "rivet_run8.png", "rivet_run8_eq_", "rivet_walk_eq_", "rivet_walk.png")


def cols_of(name: str) -> int:
    return 4 if name == "rivet_walk.png" or name.startswith("rivet_walk_eq_") else 8


def tops_of(path: Path) -> list:
    a = np.asarray(Image.open(path).convert("RGBA"))[:, :, 3] > 40
    cols, rows = cols_of(path.name), 8
    cw, ch = a.shape[1] // cols, a.shape[0] // rows
    out = []
    for r in range(rows):
        row = []
        for c in range(cols):
            cell = a[r * ch : (r + 1) * ch, c * cw : (c + 1) * cw]
            ys = np.nonzero(cell.any(axis=1))[0]
            row.append(int(ys.min()) if len(ys) else 0)
        out.append(row)
    return out


def main() -> None:
    root, table = Path(sys.argv[1]), Path(sys.argv[2])
    grids = {}
    for art in ("p70", "p55"):
        for f in sorted((root / art).glob("*.png")):
            if f.name.startswith(GRIDS) and not f.name.endswith((".import",)):
                grids[f"{art}/{f.name}"] = tops_of(f)
    doc = {
        "damp_run": 0.75,
        "damp_walk": 0.7,
        "doc": "How much of the drawn helmet bounce in Rivet's walk and run grids RivetBob removes "
        "(tools/art/rivet_bob.py measures grids: art key/file -> rows of helmet-top px per column, "
        "as packed bottom-aligned; each frame takes back (top - the row's highest top) x damp, the first "
        "stretch_cell px of it as a height stretch from the feet, which stay planted, and only the "
        "rest as a lift: the run's flight frames). The owner's n11 note: Rivet jumps too much during "
        "the movement. damp 0 = the drawn bob as before, stretch_cell 0 = the whole take-back lifts.",
        "grids": grids,
        "schema": "gtai.rivet-bob/1",
        "stretch_cell": 9,
    }
    table.write_text(json.dumps(doc, indent=2, sort_keys=True) + "\n", encoding="utf-8", newline="\n")
    print("wrote", table, len(grids), "grids")


if __name__ == "__main__":
    main()
