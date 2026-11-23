"""Recut the three accepted factory-n26 masters. Pass their out directory as the argument."""

import argparse
from pathlib import Path

from PIL import Image

from prologue_yard_cut import ART, cut_job


def piece(name, box, metres, **options):
    return dict(id=name, box=box, size_m=metres, **options)


def cover(name, box, metres, **options):
    return piece(name, box, metres, trim_to_solid=True, **options)


# Source boxes are in master pixels; metre sizes are the final ground-plane projection.
SHEETS = {
    "conveyor-run": [
        cover("straight_west", (0, 0, 885, 315), (5.4, 1.2)),
        cover("straight_east", (885, 0, 889, 315), (5.2, 1.2)),
        cover("bent_rail", (0, 315, 900, 340), (5.2, 1.2)),
        cover("torn_end", (900, 315, 874, 340), (5.4, 1.2)),
    ],
    "front-broken-b": [
        piece("burst_bay", (0, 0, 768, 545), (15, 7.35)),
        piece("feed_bay", (768, 0, 768, 545), (15, 7.85)),
        piece("shutter_bay", (0, 545, 768, 479), (15, 6.95)),
        piece("collapsed_bay", (768, 545, 768, 479), (15, 7.35)),
        piece("wall_lamp", (360, 710, 87, 68), (0.95, 0.85),
              outline=[(36, 17), (41, 16), (43, 29), (49, 35), (58, 42), (62, 50),
                       (53, 53), (42, 54), (39, 57), (34, 54), (18, 52), (16, 48),
                       (21, 42), (29, 36), (35, 29)]),
    ],
    "yard-props": [
        piece("gate_lamp", (0, 0, 480, 550), (1.6, 1.6)),
        piece("payphone", (545, 0, 350, 550), (0.82, 1.19)),
        cover("pallet_stack", (975, 0, 561, 550), (2.4, 1.6)),
        cover("pallet_toppled", (0, 550, 435, 474), (2.4, 1.6)),
        cover("toppled_arm", (435, 550, 535, 474), (2.5, 3.7), turn_clockwise=True),
        cover("fridge_bank", (970, 550, 566, 474), (4, 1.8)),
    ],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    args = parser.parse_args()
    folder = ART / "line_fire"
    folder.mkdir(exist_ok=True)
    for name, rows in SHEETS.items():
        with Image.open(args.source / f"{name}.png") as master:
            cuts = cut_job(master, {"px_per_m": 96, "shadow_ink": "#211e1c", "pieces": rows})
        for stem, cut in cuts.items():
            cut.save(folder / f"{stem}.png")


if __name__ == "__main__":
    main()
