"""Interim showcase art for the 5 weapons the owner redesigned (round 3 picks, 21:06), cut from
their approved design sheets `gtai-art/rivet-final/refs/design_<id>.png` until the asset lane's
showcase sheets (`rivet-final/out/showcase_<id>_{70,55}.png`) land.

Each design sheet: a large hero side view on top, then a bottom row of three: a 3/4 view (~55),
a steeper view (~60-70) and a black silhouette. Cuts: icon = hero, p55 = bottom 1, p70 = bottom 2
(OVERRIDE: the plasma sword's bottom 2 stands end-on, so its p70 is the hero: a blade lying on
the ground seen at 70 is near its side profile, the assets lane's 21:0x finding).
Keying: the sheet's own background (green or magenta) sampled at the corners, alpha from the colour
distance (TOL hard, SOFT ramp), green/magenta spill pulled to grey on the edge.

usage: python tools/art/design_cut.py <rivet_final_dir> <id>[,<id>...] [--showcase]
  --showcase: p70/p55 from the assets lane's sheets `out/showcase_<id>_{70,55}.png` instead (five
  rotations of the weapon lying on the ground; the middle one, the side view, muzzle right, is cut);
  the icon stays the design sheet's hero.
"""
import os
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

MAX_W = 384
TOL = 60.0
SOFT = 40.0
OUT = "project/features/combat/weapons/art/showcase"
# (id, form) -> which cut: "hero", "b0", "b1"
CUTS = {"icon": "hero", "p55": "b0", "p70": "b1"}
OVERRIDE = {("plasma_sword", "p70"): "hero"}


def key(rgb: np.ndarray) -> np.ndarray:
    h, w, _ = rgb.shape
    corners = np.concatenate([rgb[:8, :8], rgb[:8, -8:], rgb[-8:, :8], rgb[-8:, -8:]]).reshape(-1, 3)
    bg = np.median(corners, axis=0)
    d = np.sqrt(((rgb - bg) ** 2).sum(axis=2))
    a = np.clip((d - TOL) / SOFT, 0.0, 1.0)
    out = rgb.copy()
    edge = (a > 0) & (a < 1)
    g = out[..., 1]
    if bg[1] > bg[0] and bg[1] > bg[2]:  # green: no channel G above max(R, B) on the edge
        lim = np.maximum(out[..., 0], out[..., 2])
        out[..., 1] = np.where(edge, np.minimum(g, lim), g)
    else:  # magenta: R and B no higher than G + a little on the edge
        for c in (0, 2):
            lim = out[..., 1] + 30
            out[..., c] = np.where(edge, np.minimum(out[..., c], lim), out[..., c])
    return np.dstack([out, a * 255.0]).astype(np.uint8)


def pieces(rgba: np.ndarray) -> tuple:
    solid = rgba[..., 3] > 128
    lab, _ = ndimage.label(ndimage.binary_dilation(solid, iterations=6))
    boxes = []
    for i, sl in enumerate(ndimage.find_objects(lab)):
        area = int((lab[sl] == i + 1).sum())
        boxes.append((area, i + 1, sl))
    boxes.sort(key=lambda b: -b[0])
    big = boxes[:5]
    hero = min(big, key=lambda b: b[2][0].start)
    rest = [b for b in big if b is not hero and b[2][0].start > hero[2][0].start + 50]
    rest.sort(key=lambda b: b[2][1].start)
    return lab, {"hero": hero, "b0": rest[0], "b1": rest[1]}


def save(rgba: np.ndarray, lab: np.ndarray, piece, path: str) -> None:
    _, n, sl = piece
    cut = rgba[sl].copy()
    cut[..., 3] = np.where(lab[sl] == n, cut[..., 3], 0)  # only this piece: no neighbour's corner
    im = Image.fromarray(cut)
    box = im.getchannel("A").point(lambda v: 255 if v >= 16 else 0).getbbox()
    im = im.crop(box) if box else im
    if im.width > MAX_W:
        im = im.resize((MAX_W, round(im.height * MAX_W / im.width)), Image.LANCZOS)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    im.save(path)
    print(f"-> {path} {im.size}")


def side_of_sheet(path: str) -> tuple:
    """The middle of the five rotations (sorted left to right): (rgba, lab, piece)."""
    rgba = key(np.asarray(Image.open(path).convert("RGB")).astype(np.float32))
    solid = rgba[..., 3] > 128
    lab, _ = ndimage.label(ndimage.binary_dilation(solid, iterations=6))
    boxes = [((lab[sl] == i + 1).sum(), i + 1, sl) for i, sl in enumerate(ndimage.find_objects(lab))]
    five = sorted(sorted(boxes, key=lambda b: -b[0])[:5], key=lambda b: b[2][1].start)
    return rgba, lab, five[len(five) // 2]


def main() -> None:
    src_dir, ids = sys.argv[1], sys.argv[2].split(",")
    if "--showcase" in sys.argv:
        for wid in ids:
            for form, pitch in (("p70", "70"), ("p55", "55")):
                sheet = os.path.join(src_dir, "out", f"showcase_{wid}_{pitch}.png")
                rgba, lab, piece = side_of_sheet(sheet)
                save(rgba, lab, piece, os.path.join(OUT, form, f"{wid}.png"))
        return
    for wid in ids:
        rgb = np.asarray(Image.open(os.path.join(src_dir, "refs", f"design_{wid}.png")).convert("RGB"))
        rgba = key(rgb.astype(np.float32))
        lab, cut = pieces(rgba)
        for form, which in CUTS.items():
            which = OVERRIDE.get((wid, form), which)
            save(rgba, lab, cut[which], os.path.join(OUT, form, f"{wid}.png"))


if __name__ == "__main__":
    main()
