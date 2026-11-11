"""n17 npc-react (owner: "policemen are changing sizes on hit"): the drawn thrown-back hit grids'
figure height against the same kind's walk, both at the size the game draws them (StreetWalkerCards
.place: HEIGHT_M x the grid's FILL over the cell's height). Per kind: the mean opaque figure height
of the 20 walk cells (5 facings x 4 stride frames, StreetCopWalk.FILL or StreetWalkerRows.WALK_FILL)
and of the 5 hit cells (StreetWalkerHit.FILL), and the FILL that makes them equal. The tables are
read from the scripts, so this measures what ships. p55 draws the same grids at HEIGHT_BY_ART 2.0
and its walk grids stand at the same share of it, so one FILL serves both.
--check exits 1 when any kind's hit stands more than TOL off its walk. Deterministic, read only.

    PYTHONDONTWRITEBYTECODE=1 python tools/art/street_hit_size.py [--check]
"""

import re
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
CHARS = ROOT / "project/features/characters"
P70 = CHARS / "art/view/p70"
HEIGHT_M = 1.7
ALPHA = 40
TOL = 0.03
# hit grid -> its kind's walk grid (the thug walks as parts and has none)
WALKS = {
    "cop_patrol_hit.png": "cop_patrol_armed_walk.png",
    "cop_riot_hit.png": "cop_riot_armed_walk.png",
    "swat_hit.png": "swat_armed_walk.png",
    "ped_suit_hit.png": "ped_suit_walk.png",
    "ped_elder_hit.png": "ped_elder_walk.png",
    "ped_hat_hit.png": "ped_hat_walk.png",
    "ped_hood_hit.png": "ped_hood_walk.png",
    "ped_cap_hit.png": "ped_cap_walk.png",
    "ped_punk_hit.png": "ped_punk_walk.png",
    "ped_shopper_hit.png": "ped_shopper_walk.png",
    "ped_jogger_hit.png": "ped_jogger_walk.png",
    "ped_worker_hit.png": "ped_worker_walk.png",
}


def table(script: str, name: str) -> dict:
    """A `const NAME: Dictionary[String, float] = {...}` of a script, as {file: value}."""
    text = (CHARS / script).read_text(encoding="utf-8")
    body = re.search(r"const %s: Dictionary\[String, float\] = \{(.*?)\n\}" % name, text, re.S)
    pairs = re.findall(r'"([^"]+)": ([0-9.]+)', body.group(1))
    return {k.split("/")[-1] if k.startswith("p70/") else k: float(v) for k, v in pairs if not k.startswith("p55/")}


def heights(path: Path, rows: int, fill: float) -> list:
    """Each cell's opaque figure height (m) at the drawn size."""
    alpha = np.asarray(Image.open(path).convert("RGBA"))[:, :, 3]
    ch, cw = alpha.shape[0] // rows, alpha.shape[1] // 5
    out = []
    for r in range(rows):
        for c in range(5):
            ys = np.nonzero((alpha[r * ch : (r + 1) * ch, c * cw : (c + 1) * cw] > ALPHA).any(1))[0]
            if len(ys):
                out.append((ys.max() - ys.min() + 1) * HEIGHT_M * fill / ch)
    return out


def main() -> int:
    hit_fill = table("street_walker_hit.gd", "FILL")
    walk_fill = {**table("street_walker_rows.gd", "WALK_FILL"), **table("street_cop_walk.gd", "FILL")}
    bad = 0
    for hit, walk in WALKS.items():
        w = float(np.mean(heights(P70 / walk, 4, walk_fill.get(walk, 1.0))))
        h = float(np.mean(heights(P70 / hit, 1, hit_fill[hit])))
        off = h / w - 1.0
        bad += abs(off) > TOL
        want = hit_fill[hit] * w / h
        print(f"{hit:24s} walk {w:.3f} m  hit {h:.3f} m  {off:+.1%}  FILL {hit_fill[hit]:.2f} -> {want:.2f}")
    if "--check" in sys.argv[1:]:
        print(f"street_hit_size: {'FAIL' if bad else 'PASS'} ({bad} kind(s) past {TOL:.0%})")
        return 1 if bad else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
