"""Numbers from cast_gunner_poses.mjs: the live rim at 64 px/m and the ring-off shadow counts at 32.
usage: python tools/art/cast_gunner_review.py <folder holding poses70_32, poses70_64, poses55_32, poses55_64>"""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image

from cast_mulroney_edge import rim

ACTIONS = ("planted8_armed_walk", "attack", "hit", "fall")


def rims(folder):
    for pitch in (70, 55):
        for action in ACTIONS:
            d = folder / f"poses{pitch}_64" / ("edge_" + action)
            raw, ground = [np.asarray(Image.open(d / (n + ".png")).convert("RGB"), dtype=int) for n in ("raw", "ground")]
            visible = int((abs(raw - ground).max(2) > 22).sum())
            if visible < 100:
                raise ValueError(f"empty exposure: {d}")
            print(pitch, action, "added dark exterior pixels", rim(d), "visible pixels", visible)


def shadows(folder):
    for pitch in (70, 55):
        for ppm in (32, 64):
            d = folder / f"poses{pitch}_{ppm}"
            for on in sorted(d.glob("*.png")):
                off = on.with_name(on.stem + "_no_shadow.png")
                if on.stem.endswith("_no_shadow") or not off.exists():
                    continue
                a, b = [np.asarray(Image.open(p).convert("RGB"), dtype=int) for p in (on, off)]
                print(pitch, ppm, on.stem, "pixels darkened >= 12:", int(((b - a).max(2) >= 12).sum()))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    args = parser.parse_args()
    rims(args.folder)
    shadows(args.folder)
