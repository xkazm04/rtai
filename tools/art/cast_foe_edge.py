"""Added dark pixels outside the painted figure at 64 px/m, per foe, from cast_feet.mjs's edge_* folders."""
import argparse
from pathlib import Path

from cast_mulroney_edge import rim

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", type=Path)
    args = parser.parse_args()
    for folder in sorted(args.directory.glob("edge_*")):
        print(folder.name, "added dark exterior pixels", rim(folder))
