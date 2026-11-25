"""Live 64 px/m rim of robot thug A: added dark exterior px per state, from cast_thug_edge's folders.
Run from the repo root: python tools/art/cast_thug_edge.py <build/look/n29-thug/rim>
Each edge<pitch>_64/edge_<state>/ holds frozen live / raw / ground frames; live.png is also
written next to a 3x crop of the added px (red) as added.png for looking."""
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_mulroney_edge import rim


def added(folder):
    live, raw, ground = [np.asarray(Image.open(folder / f"{n}.png").convert("RGB"), dtype=int)
                         for n in ("live", "raw", "ground")]
    mask = (abs(live - ground).max(2) > 22) & (abs(raw - ground).max(2) <= 8) & (live.max(2) < 64)
    shown = live.astype(np.uint8).copy()
    shown[mask] = (255, 0, 0)
    both = np.concatenate([live.astype(np.uint8), shown], axis=1)
    Image.fromarray(both).resize((both.shape[1] * 2, both.shape[0] * 2), Image.NEAREST).save(folder / "added.png")


if __name__ == "__main__":
    root = Path(sys.argv[1])
    for pitch in (70, 55):
        counts = {}
        for folder in sorted((root / f"edge{pitch}_64").glob("edge_*")):
            counts[folder.name[5:]] = rim(folder)
            added(folder)
        print(pitch, counts)
