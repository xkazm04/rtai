"""Rebuild diagonal exhaust from the launcher's own facing strip and fit the drawn lefts."""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageOps

from cell_metrics import cells
from launcher_left_fit import fit_left
from mini_nuke_strips import stamp
from shard_strips import CUT, VIEW, cut

NAME = "rivet_eq_rocket_launcher"
# Exit at the rim, or the projected end of the tube behind a hidden shoulder.
# (x, y), direction, projected plume length, whether the rim is occluded.
EXHAUST = {
    "p55": [((40, 67), 210, 38, False), ((15, 105), 145, 36, True),
            ((130, 67), -30, 38, False), ((154, 106), 35, 36, True)],
    "p70": [((80, 97), 214, 43, True), ((57, 125), 136, 42, True),
            ((181, 97), -34, 43, True), ((201, 125), 44, 42, True)],
}


def plates(pitch):
    base = VIEW / pitch / (NAME + ".png")
    fire = Image.fromarray(cells(base, 8)[5])
    dark = Image.fromarray(cells(base.with_stem(NAME + "_noflash"), 8)[5])
    if pitch == "p55":
        lit = np.array(fire)
        lit[np.array(dark)[:, :, 3] > 0] = 0
        flame = ImageOps.mirror(Image.fromarray(lit).crop((0, 62, 51, 108)))
        root_y = 87 - 62
        rim_pts = [(45, 88), (47, 79), (54, 74), (62, 79), (70, 83),
                   (67, 96), (52, 101), (47, 99)]
    else:
        flame = fire.crop((206, 74, 259, 141))
        root_y = 116 - 74
        rim_pts = [(85, 120), (87, 110), (96, 98), (102, 100), (115, 107),
                   (114, 124), (94, 129), (87, 127)]
    mask = Image.new("L", dark.size)
    ImageDraw.Draw(mask).polygon(rim_pts, fill=255)
    rim = Image.new("RGBA", dark.size)
    rim.paste(dark, (0, 0), mask)
    rim = ImageOps.mirror(rim.crop(rim.getbbox()))
    return flame, root_y, rim


def build(masters):
    manifest = json.loads(CUT.with_suffix(".json").read_text())
    for pitch, poses in EXHAUST.items():
        dest = VIEW / pitch
        stem = "rocket_launcher_" + pitch
        source = masters / (stem + "_diag_original.png")
        original = cells(source, 4)
        dark = cells(source.with_stem(source.stem + "_dark"), 4)
        flame, root_y, rim = plates(pitch)
        h, w = original[0].shape[:2]
        width = w + (32 if pitch == "p55" else 0)
        for light, figures in [(True, original), (False, dark)]:
            strip = Image.new("RGBA", (4*width, h))
            for i, (pose, pixels) in enumerate(zip(poses, figures)):
                (x, y), angle, length, hidden = pose
                shift = 32 if pitch == "p55" and i == 1 else 0
                exit_pt = (x+shift, y)
                tile = Image.new("RGBA", (width, h))
                if light:
                    stamp(tile, flame, exit_pt, angle, length, root_y)
                if hidden:
                    rad = math.radians(angle)
                    rim_len = 18
                    root = (exit_pt[0]-rim_len*math.cos(rad), y-rim_len*math.sin(rad))
                    stamp(tile, rim, root, angle, rim_len+2, rim.height*.55)
                tile.alpha_composite(Image.fromarray(pixels), (shift, 0))
                strip.paste(tile, (i*width, 0))
            suffix = "_diag" if light else "_diag_noflash"
            strip.save(dest / (NAME + suffix + ".png"), optimize=True)
        target = dest / (NAME + "_left.png")
        row = manifest["strips"][pitch][target.stem]
        cut(masters / (stem + "_left_key.png"), target, row)
        fit_left(target, row["shell_fit"], row["shell_curve"])


if __name__ == "__main__":
    build(Path(sys.argv[1]))
