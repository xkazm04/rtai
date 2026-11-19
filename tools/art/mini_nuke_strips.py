"""Rebuild Rivet's mini-nuke strips from n19/guns/masters (no mirrored poses).

The front flare is sampled from the original action. The exhaust is a separately
keyed ImageGen plate. Attach both in the uncut diagonal master so the standard
cutter can use identical bounds for the lit and dark strips.
"""
import json
import math
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from assault_rifle_parts import keyed
from assault_rifle_strips import diagonal_row
from launcher_left_fit import fit_left
from rivet_frames import _sheet
from shard_strips import CUT, VIEW, cut

NAME = "rivet_eq_mini_nuke"
# Front and rear tube centres in the flashless 165 px proof cut, DIAG order.
ENDS = {
    "p55": [((106, 108), (32, 70)), ((130, 62), (35, 104)),
            ((16, 101), (94, 68)), ((4, 52), (90, 99))],
    "p70": [((123, 133), (29, 83)), ((144, 72), (39, 123)),
            ((17, 133), (103, 91)), ((5, 58), (112, 119))],
}
# Native crop for the original idle aperture, then centre, radii and shear in each shot.
CAP = {
    "p55": ((168.0, 110, 4.5, 9, -.26), [(192, 81, 4, 10, -.10), (149, 98, 10, 12, -.18)]),
    "p70": ((211.0, 177, 6, 13, -.30), [(222, 168, 4, 13, -.23), (137.5, 165, 15, 11, 0)]),
}


def facing_twin(lit, pitch):
    source = np.asarray(lit)
    dark = source.copy()
    w = lit.width // 8
    y, x = np.indices((lit.height, w))
    (sx, sy, sw, sh, slant), mouths = CAP[pitch]
    for index, (cx, cy, rx, ry, shear) in enumerate(mouths, 5):
        block = dark[:, index*w:(index+1)*w]
        u = (x-cx-shear*(y-cy))/rx
        v = (y-cy)/ry
        aperture = u*u + v*v <= 1.0
        if index == 5:
            plume = x >= cx
        elif pitch == "p55":
            boundary = np.interp(y, [63, 77, 83, 87, 108, 113, 128, 137],
                                 [166, 165, 164, 154, 150, 154, 162, 167])
            plume = (x >= boundary) & (y >= 65) & (y <= 129)
        else:
            rim = ((x-cx)/22)**2 + ((y-163)/17)**2 <= 1
            plume = (y >= cy-1) & (abs(x-cx) <= 39) & (~rim | (abs(x-cx) <= 11))
        block[plume & ~aperture] = 0
        ax, ay = sw/rx, sh/ry
        bx = slant*ay-ax*shear
        transform = (ax, bx, sx-ax*cx-bx*cy+7*w, 0, ay, sy-ay*cy)
        cap = lit.transform((w, lit.height), Image.Transform.AFFINE, transform, Image.Resampling.BILINEAR)
        block[aperture] = np.asarray(cap)[aperture]
    return Image.fromarray(dark)


def stamp(canvas, plate, origin, angle, length, root_y):
    """Rotate about the plate's source pixel. All orientations are rotations."""
    theta = math.radians(angle)
    unit = length / plate.width
    c, s = math.cos(theta)/unit, math.sin(theta)/unit
    x, y = origin
    inv = (c, s, -c*x-s*y, -s, c, root_y+s*x-c*y)
    turned = plate.convert("RGBa").transform(canvas.size, Image.Transform.AFFINE, inv, Image.Resampling.BILINEAR)
    canvas.alpha_composite(turned.convert("RGBA"))


def diagonals(masters, pitch, front, smoke):
    stem = "mini_nuke_" + pitch + "_diag"
    dark = diagonal_row(keyed(masters / (stem + "_raw.png")))
    dark_path = masters / (stem + "_dark.png")
    dark.save(dark_path)
    _, (figs,) = _sheet(dark_path, [4])
    scale = 165 / np.median([f["h"] for f in figs])
    w = math.ceil(2*scale*max(max(f["ax"]-f["box"][0], f["box"][2]-f["ax"]) for f in figs))+4
    h = math.ceil(scale*max(f["h"] for f in figs))+4
    lit = dark.copy()
    for f, (mouth, rear) in zip(figs, ENDS[pitch]):
        angle = math.degrees(math.atan2(mouth[1]-rear[1], mouth[0]-rear[0]))
        def point(pos):
            return (f["ax"]+(pos[0]-w/2)/scale, f["box"][3]+(pos[1]-h+2)/scale)
        stamp(lit, smoke, point(rear), angle+180, 46/scale, smoke.height*.57)
        stamp(lit, front, point(mouth), angle, 41/scale, front.height*.50)
    lit_path = masters / (stem + "_key.png")
    lit.save(lit_path)
    row = {"counts": "4", "fig_h": 165}
    target = VIEW / pitch / (NAME + "_diag.png")
    cut(lit_path, target, row)
    cut(lit_path, target.with_stem(NAME + "_diag_noflash"), row, dark_path)


def build(masters):
    manifest = json.loads(CUT.with_suffix(".json").read_text())
    smoke = keyed(masters / "launcher_exhaust_raw.png")
    smoke = smoke.crop(smoke.getbbox())
    for pitch in ("p55", "p70"):
        row = manifest["strips"][pitch][NAME]
        original = masters / ("mini_nuke_" + pitch + "_original.png")
        cut(Path(manifest["library"]) / row["sheet"], original, row)
        lit = Image.open(original).convert("RGBA")
        facing_twin(lit, pitch).save(VIEW / pitch / (NAME + "_noflash.png"), optimize=True)
        left = "mini_nuke_" + pitch + "_left"
        key = masters / (left + "_key.png")
        keyed(masters / (left + "_raw.png")).save(key)
        target = VIEW / pitch / (NAME + "_left.png")
        cut(key, target, {"counts": "3", "fig_h": 165})
        fit_left(target, manifest["strips"][pitch][NAME + "_left"]["shell_fit"])
    orig = Image.open(masters / "mini_nuke_p55_original.png")
    x = 5*orig.width//8
    front = orig.crop((x+195, 46, x+257, 117))
    diagonals(masters, "p55", front, smoke)
    diagonals(masters, "p70", front, smoke)


if __name__ == "__main__":
    build(Path(sys.argv[1]))
