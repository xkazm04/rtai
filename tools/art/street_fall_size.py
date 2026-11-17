"""n17 npc-react (owner: "policemen are changing sizes on hit"): each kind's drawn fall grid (the 5-row
`<kind>_between_fall.png`: buckle, mid-fall, knees, chest down, lying) against its walk, row by row, at the size
the game draws both: the walk at 1.7 m per cell times its FILL (StreetCopWalk.FILL, StreetWalkerRows.WALK_FILL),
the fall grid at 1.7 m per 192 px (StreetWalkerFall.STILL_PX). Size = sqrt(row's opaque area / walk's), mean of
the 5 facings (an area reads a crouch or a reaching arm far less than a height does). Prints the FIT a row
should take: the buckle and the mid-fall at the walk (the frames right after the thrown-back hit cell, which
stands at the walk), the knees halfway to the chest-down row, the chest-down and lying rows as drawn (owner n11:
bodies keep their length). --check exits 1 when StreetFallFit.FIT_K (read from the script) leaves a buckle or
mid-fall row more than TOL off the walk. Read only.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_fall_size.py [--check]
"""

import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
P70 = ROOT / "project/features/characters/art/view/p70"
SCRIPT = ROOT / "project/features/characters/street_fall_fit.gd"
HEIGHT_M = 1.7
STILL_PX = 192
ALPHA = 100
TOL = 0.05
ROWS = 5
WALKS = {
    "cop_patrol": ("cop_patrol_armed_walk.png", 1.12),
    "cop_riot": ("cop_riot_armed_walk.png", 1.11),
    "swat": ("swat_armed_walk.png", 1.14),
    "ped_suit": ("ped_suit_walk.png", 1.09),
    "ped_elder": ("ped_elder_walk.png", 1.08),
    "ped_hat": ("ped_hat_walk.png", 1.06),
    "ped_hood": ("ped_hood_walk.png", 1.07),
    "ped_cap": ("ped_cap_walk.png", 1.12),
    "ped_punk": ("ped_punk_walk.png", 1.01),
    "ped_shopper": ("ped_shopper_walk.png", 1.09),
    "ped_jogger": ("ped_jogger_walk.png", 1.12),
    "ped_worker": ("ped_worker_walk.png", 1.13),
}


def cell_areas(path: Path, rows: int, m_per_px: float) -> np.ndarray:
    """[row][col] opaque area in m^2."""
    a = np.asarray(Image.open(path).convert("RGBA"))[:, :, 3] > ALPHA
    ch, cw = a.shape[0] // rows, a.shape[1] // 5
    return np.array([[a[r * ch : (r + 1) * ch, c * cw : (c + 1) * cw].sum() for c in range(5)] for r in range(rows)]) * m_per_px**2


def sizes(kind: str) -> list:
    walk, fill = WALKS[kind]
    wpath = P70 / walk
    wh = Image.open(wpath).height // 4
    wa = cell_areas(wpath, 4, HEIGHT_M * fill / wh).mean(0)  # per facing, over the 4 stride frames
    fa = cell_areas(P70 / f"{kind}_between_fall.png", ROWS, HEIGHT_M / STILL_PX)
    return [float(np.mean((fa[r] / wa) ** 0.5)) for r in range(ROWS)]


def fit_of(s: list) -> list:
    """The k per row: buckle and mid-fall to the walk, knees halfway to chest-down, the rest as drawn."""
    target = [1.0, 1.0, (1.0 + s[3]) * 0.5, s[3], s[4]]
    return [round(min(1.0, t / v), 2) for t, v in zip(target, s)]


def shipped() -> dict:
    if not SCRIPT.exists():
        return {}
    body = re.search(r"const FIT_K[^{]*\{(.*?)\n\}", SCRIPT.read_text(encoding="utf-8"), re.S)
    rows = re.findall(r'"p70/([a-z_]+)_between_fall\.png": \[([^\]]+)\]', body.group(1)) if body else []
    return {k: [float(v) for v in ks.split(",")] for k, ks in rows}


def main() -> int:
    ks = shipped()
    bad = 0
    for kind in WALKS:
        s = sizes(kind)
        k = ks.get(kind, [1.0] * ROWS)
        drawn = [v * kk for v, kk in zip(s, k)]
        off = any(abs(drawn[r] - 1.0) > TOL and drawn[r] > 1.0 for r in (0, 1))
        bad += off
        print(f"{kind:12s} as drawn {' '.join(f'{v:.2f}' for v in s)}  fit {fit_of(s)}  shipped -> {' '.join(f'{v:.2f}' for v in drawn)}{'  OVER' if off else ''}")
    if "--check" in sys.argv[1:]:
        print(f"street_fall_size: {'FAIL' if bad else 'PASS'} ({bad} kind(s) with a buckle or mid-fall row past {TOL:.0%} over the walk)")
        return 1 if bad else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
