"""Repaint only the rear flash on the original rocket diagonals and cut three drawn lefts.

Run with the n19/guns/masters directory. Coordinates are native strip pixels.
The narrow p55 away cells need extra room behind the bell. Only cell 1 moves
inside its canvas. Both twins get exactly the same padding and helmet offset.
"""
import sys
from pathlib import Path

from PIL import Image

from assault_rifle_parts import keyed
from mini_nuke_strips import stamp
from shard_strips import VIEW, cut

# Rear bell (or the point where its axis clears the shoulder), angle and space available.
EXHAUST = {
    "p55": [((40, 67), 206, 41), ((15, 98), 146, 42),
            ((129, 67), -24, 39), ((150, 106), 28, 42)],
    "p70": [((85, 104), 206, 47), ((51, 111), 141, 47),
            ((169, 105), -26, 46), ((198, 110), 32, 48)],
}
NAME = "rivet_eq_rocket_launcher"


def build(masters):
    smoke = keyed(masters / "launcher_exhaust_raw.png")
    smoke = smoke.crop(smoke.getbbox())
    for pitch, cells in EXHAUST.items():
        dest = VIEW / pitch
        stem = "rocket_launcher_" + pitch
        original = Image.open(masters / (stem + "_diag_original.png")).convert("RGBA")
        w = original.width // len(cells)
        width = w + (32 if pitch == "p55" else 0)
        lit = Image.new("RGBA", (4*width, original.height))
        if pitch == "p55":
            old_dark = Image.open(masters / (stem + "_diag_original_dark.png")).convert("RGBA")
            dark = Image.new("RGBA", lit.size)
        for i, ((x, y), angle, length) in enumerate(cells):
            box = (i*w, 0, (i+1)*w, original.height)
            shift = 32 if pitch == "p55" and i == 1 else 0
            plume = Image.new("RGBA", (width, original.height))
            stamp(plume, smoke, (x+shift, y), angle, length, smoke.height*.57)
            plume.alpha_composite(original.crop(box), (shift, 0))
            lit.paste(plume, (i*width, 0))
            if pitch == "p55":
                dark.paste(old_dark.crop(box), (i*width+shift, 0))
        lit.save(dest / (NAME + "_diag.png"), optimize=True)
        if pitch == "p55":
            dark.save(dest / (NAME + "_diag_noflash.png"), optimize=True)
        left = masters / (stem + "_left_key.png")
        keyed(masters / (stem + "_left_raw.png")).save(left)
        cut(left, dest / (NAME + "_left.png"), {"counts": "3", "fig_h": 165})


if __name__ == "__main__":
    build(Path(sys.argv[1]))
