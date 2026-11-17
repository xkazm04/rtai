"""n17 npc-react (owner: "policemen are changing sizes on hit"): an n16 death's own drawn cells against the
kind's walk, row by row, at the size the game draws them. Size = sqrt(mean opaque area of the 5 facing cells
/ mean opaque area of the 20 walk cells): an area reads a raised arm far less than a bounding height does
(calibrated on the patrol pistol snap's first row: 1.25 x here, 1.27 x by the shoulders in film b_patrol64).
The own cells draw at 1.7 m per STAND_PX of the cell (the fall grid's px per metre), each row times its
KillDeathCells.FIT_K (read from the script, so this measures what ships). --check exits 1 when a FIT grid's
first row (the hit's frame, where the owner saw the size change) stands more than TOL off the walk; the later
rows are printed only: an area over-reads a body bending or lying (the snap's pitch forward, a corpse). Read only.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/kill_cells_size.py [--check] [<file.png> ...]
"""

import json
import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
P70 = ROOT / "project/features/characters/art/view/p70"
SCRIPT = ROOT / "project/features/combat/kills/kill_death_cells.gd"
TABLE = ROOT / "project/data/tables/signature_kills.json"
HEIGHT_M = 1.7
STAND_PX = 192
ALPHA = 100
TOL = 0.10
WALKS = {
    "cop_patrol": "cop_patrol_armed_walk.png",
    "cop_riot": "cop_riot_armed_walk.png",
    "swat": "swat_armed_walk.png",
    "ped_suit": "ped_suit_walk.png",
}


def fit_k() -> dict:
    """KillDeathCells.FIT_K as {file: [k per row]} (p70 only)."""
    body = re.search(r"const FIT_K: Dictionary\[String, Array\] = \{(.*?)\n\}", SCRIPT.read_text(encoding="utf-8"), re.S)
    rows = re.findall(r'"p70/([^"]+)": \[([^\]]+)\]', body.group(1))
    return {f: [float(v) for v in ks.split(",")] for f, ks in rows}


def own_rows() -> dict:
    """Every p70 own-cell grid of signature_kills.json -> its frame rows (len of cells.at)."""
    out = {}
    for row in json.loads(TABLE.read_text(encoding="utf-8"))["kills"]:
        cells = row.get("cells")
        for file in (cells or {}).get("grids", {}).get("p70", {}).values():
            out[file] = len(cells["at"])
    return out


def areas(path: Path, rows: int, m_per_px: float) -> list:
    """Each row's mean opaque area over the 5 facings, m^2."""
    a = np.asarray(Image.open(path).convert("RGBA"))[:, :, 3] > ALPHA
    ch, cw = a.shape[0] // rows, a.shape[1] // 5
    return [float(np.mean([a[r * ch : (r + 1) * ch, c * cw : (c + 1) * cw].sum() for c in range(5)])) * m_per_px**2 for r in range(rows)]


def main() -> int:
    fits = fit_k()
    every = own_rows()
    files = [a for a in sys.argv[1:] if not a.startswith("--")] or sorted(every)
    bad = 0
    for file in files:
        kind = next((k for k in WALKS if file.startswith(k + "_")), None)
        if kind is None:
            print(f"{file}: no walk for its kind")
            continue
        walk = P70 / WALKS[kind]
        wa = float(np.mean(areas(walk, 4, HEIGHT_M / (Image.open(walk).height // 4))))
        ks = fits.get(file)
        rows = every.get(file, len(ks) if ks else 1)
        sizes = [(x / wa) ** 0.5 for x in areas(P70 / file, rows, HEIGHT_M / STAND_PX)]
        drawn = [s * (ks[i] if ks else 1.0) for i, s in enumerate(sizes)]
        off = abs(drawn[0] - 1.0) > TOL
        bad += off and ks is not None
        cells = " ".join(f"r{i} {s:.2f}->{d:.2f}" for i, (s, d) in enumerate(zip(sizes, drawn)))
        print(f"{file:34s} {'FIT ' if ks else '    '}{cells}")
    if "--check" in sys.argv[1:]:
        print(f"kill_cells_size: {'FAIL' if bad else 'PASS'} ({bad} grid(s) with the first row past {TOL:.0%})")
        return 1 if bad else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
