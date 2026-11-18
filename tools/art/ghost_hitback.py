"""Pack it384's rear-hit poses into optional one-column GhostSheet grids at their delivered scale.

Usage: python tools/art/ghost_hitback.py <library/keyed/ghosts> <output view dir>
"""
import argparse
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory


def pack(source, out):
    # The delivery numbers these as HIT (column 4). Give the independent grid one column.
    with TemporaryDirectory() as scratch:
        for row in range(1, 6):
            shutil.copyfile(source / f"{row}_4.png", Path(scratch) / f"{row}_1.png")
        subprocess.run([sys.executable, Path(__file__).with_name("ghost_pack.py"),
                        scratch, out, "--k=1"], check=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("keyed", type=Path)
    parser.add_argument("out", type=Path)
    args = parser.parse_args()
    for pitch in (70, 55):
        for form in ("dent", "ohm"):
            src = args.keyed / f"{form}_act_{pitch}_cells_hitback"
            pack(src, args.out / f"p{pitch}" / f"{form}_act_hitback.png")
