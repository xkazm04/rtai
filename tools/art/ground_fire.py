"""The burning ground's fire loop in the round 2 colour sheet (look lane, n5 2026-11-05; r2_w4).

Re-inks quest 1's fx_fire.png (a vermilion body round a cream core, ink outline and hatching)
token by token with fx_colour.recolour: the body goes the flame family's orange, the core hot
yellow, the ink stays ink. Paths and colours are data: tools/art/ground_fire.json.
Deterministic: the same inputs write byte-identical PNGs.

Run from the repo root:
    python tools/art/ground_fire.py tools/art/ground_fire.json
"""

import json
import sys
from pathlib import Path

from fx_colour import _hex, recolour


def main(cfg_path):
    cfg = json.loads(Path(cfg_path).read_text(encoding="utf-8"))
    mapping = {tok: _hex(c) for tok, c in cfg["tokens"].items()}
    recolour(cfg["src"], cfg["dst"], mapping)
    print("ground fire ->", cfg["dst"])


if __name__ == "__main__":
    main(sys.argv[1])
