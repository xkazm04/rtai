"""The open weapon crate a showcase weapon lies in (n8-hud, the brief's "in an open crate"), cut
from the asset library's keyed prop sheets `keyed/prop/weapon_crate_open_<70|55>.png` (five
rotations, REQUEST hud 22:12). One view per pitch, the lid leaning BEHIND the open hollow so the
straw floor (where the weapon lies) is never covered: 70 = rotation 1 (facing the camera),
55 = rotation 5 (the lid on the far side; rotations 1, 2 and 4 cover the near side with it).
p70 comes from the v3 sheet (round 20261107-0305, A: the v2 values, camera ~65-70) since it10;
before it the v2 sheet (round 20261107-0150, B: deep amber planks, cream straw, a dark
hollow, bold outline; camera ~60; VIEW["p70"] = ("70_v2", 0)) since it8: judged beside the 2300 cut with the guns lying in it,
at 32 px/m the v2 crate reads as a crate and the tan guns pop off its dark hollow. The 2300 sheet
(B, the straw the wood's value) is one value away: VIEW["p70"] = ("70", 0); its fix (the straw
darkened by STRAW_K inside INNER) is applied only to that sheet.

usage: python tools/art/crate_cut.py <library_dir>
"""
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

MAX_W = 384
OUT = "project/features/combat/weapons/art/showcase/crate"
VIEW = {"p70": ("70_v3", 0), "p55": ("55", 4)}
# the 2300 p70's inner rim as fractions of the cut (x0, y0, x1, y1): measured on the cut (it5, 23:20)
INNER = {"70": (0.07, 0.17, 0.93, 0.70)}
# per channel: toward a warm brown (a flat 0.78 read olive at 48 px/m, it5 23:35)
STRAW_K = (0.86, 0.72, 0.6)


def rotations(rgba: np.ndarray) -> list:
    solid = rgba[..., 3] > 32
    lab, _ = ndimage.label(ndimage.binary_dilation(solid, iterations=8))
    objs = ndimage.find_objects(lab)
    big = sorted(range(len(objs)), key=lambda i: -int((lab[objs[i]] == i + 1).sum()))[:5]
    big.sort(key=lambda i: objs[i][1].start)
    out = []
    for i in big:
        sl = objs[i]
        piece = rgba[sl].copy()
        piece[..., 3] = np.where(lab[sl] == i + 1, piece[..., 3], 0)
        out.append(piece)
    return out


def darken_straw(piece: np.ndarray, box: tuple) -> np.ndarray:
    h, w, _ = piece.shape
    x0, y0, x1, y1 = int(box[0] * w), int(box[1] * h), int(box[2] * w), int(box[3] * h)
    rgb = piece[y0:y1, x0:x1, :3].astype(np.float32)
    warm = (rgb[..., 0] > 150) & (rgb[..., 2] < rgb[..., 0] * 0.7)
    rgb[warm] *= np.array(STRAW_K, dtype=np.float32)
    piece[y0:y1, x0:x1, :3] = rgb.astype(np.uint8)
    return piece


def main() -> None:
    lib = sys.argv[1]
    os.makedirs(OUT, exist_ok=True)
    for form, (pitch, idx) in VIEW.items():
        src = os.path.join(lib, "keyed", "prop", f"weapon_crate_open_{pitch}.png")
        piece = rotations(np.array(Image.open(src).convert("RGBA")))[idx]
        if pitch in INNER:
            piece = darken_straw(piece, INNER[pitch])
        im = Image.fromarray(piece)
        if im.width > MAX_W:
            im = im.resize((MAX_W, round(im.height * MAX_W / im.width)), Image.LANCZOS)
        im.save(os.path.join(OUT, f"{form}.png"))
        print(f"{src} [{idx}] -> {OUT}/{form}.png {im.size}")


if __name__ == "__main__":
    main()
