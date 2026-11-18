"""Prepare the two pitches and cut the quest rifle strips with the normal Rivet anchors.

python tools/art/assault_rifle_strips.py C:/Users/kazda/kiro/gtai-masters/n19/guns/masters
The chroma-keyed lit master supplies geometry for both twins. The dark twin clips only
the printed flare beyond each muzzle rim. All left and diagonal cells are drawn.
"""
import json
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from assault_rifle_parts import keyed

MANIFEST = Path("tools/art/rivet_frames.json")
CUT = MANIFEST.with_suffix(".py")
NAME = "rivet_eq_assault_rifle"
# Rect containing each flare, point on its muzzle rim, outward screen vector.
FLARES = {
    "eq70": [
        ((426, 600, 575, 749), (431, 692), (1, 0)),
        ((683, 820, 829, 990), (754, 824), (0, 1)),
    ],
    "diag70": [
        ((518, 380, 566, 427), (523, 394), (2, 1)),
        ((1134, 135, 1183, 185), (1142, 167), (1, -1)),
        ((111, 956, 159, 1003), (151, 968), (-2, 1)),
        ((869, 699, 913, 751), (905, 735), (-1, -1)),
    ],
    "main": [
        ((449, 659, 504, 718), (449, 690), (1, 0)),
        ((734, 803, 790, 863), (763, 804), (0, 1)),
    ],
    "diag": [
        ((572, 332, 644, 390), (580, 353), (2, 1)),
        ((1345, 54, 1405, 109), (1355, 94), (2, -1)),
        ((114, 850, 186, 907), (177, 865), (-2, 1)),
        ((943, 554, 1005, 605), (996, 593), (-2, -1)),
    ],
}


def remove_flares(im, poses):
    a = np.array(im)
    for (x0, y0, x1, y1), (cx, cy), (dx, dy) in poses:
        yy, xx = np.mgrid[y0:y1, x0:x1]
        a[y0:y1, x0:x1][(xx - cx) * dx + (yy - cy) * dy >= 0] = 0
    return Image.fromarray(a)


def diagonal_row(im):
    # Two rows of two, in DIAG_CELL order. Use the same untrimmed halves for both twins.
    w, h = im.size
    out = Image.new("RGBA", (2 * w, (h + 1) // 2))
    out.paste(im.crop((0, 0, w, h // 2)), (0, 0))
    out.paste(im.crop((0, h // 2, w, h)), (w, 0))
    return out


def prepare(masters, sheets):
    for sheet, take in sheets.items():
        source = keyed(masters / (sheet + "_" + take + ".png"))
        lit = diagonal_row(source) if sheet.startswith("diag") else source
        lit.save(masters / (sheet + "_key.png"))
        if sheet in FLARES:
            dark = remove_flares(source, FLARES[sheet])
            if sheet.startswith("diag"):
                dark = diagonal_row(dark)
            dark.save(masters / (sheet + "_dark.png"))


def twins(masters, man, pitch, sheets):
    rows = man["strips"][pitch]
    dest = Path(man["out"]) / pitch
    for sheet, suffix in zip(sheets, ("", "_diag")):
        row = rows[NAME + suffix]
        args = [sys.executable, str(CUT), str(masters / (sheet + "_key.png")),
                str(dest / (NAME + suffix + "_noflash.png")), row["counts"],
                "--fig_h=" + str(row["fig_h"]), "--pixels=" + str(masters / (sheet + "_dark.png"))]
        for opt in ("act_k", "action_feet_up"):
            if opt in row:
                args.append(f"--{opt}={row[opt]}")
        subprocess.run(args, check=True)


if __name__ == "__main__":
    masters = Path(sys.argv[1])
    manifest = json.loads(MANIFEST.read_text())
    prepare(masters, {"main": "raw", "left": "raw", "diag": "raw",
                      "eq70": "raw", "left70": "corrected", "diag70": "corrected"})
    subprocess.run([sys.executable, str(CUT), "--manifest=" + str(MANIFEST), "--only=" + NAME], check=True)
    twins(masters, manifest, "p55", ("main", "diag"))
    twins(masters, manifest, "p70", ("eq70", "diag70"))
