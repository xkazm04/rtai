"""n9 rivet it7: pack the library's knock-down strips (a car throws Rivet) into one game grid per art key.

usage: python -I tools/art/rivet_knock.py <p70|p55> <out.png> [--len=1.45] [--tone=<ref.png>] [--json=<out.json>]

Rows (RivetKnock.Row): 0 toward (thrown down the picture, helmet leading), 1 away (up the picture), 2 right,
3 left (drawn, not mirrored); columns: impact, tumble, slide, down. Each library sheet is 1 x 4, cut by
quarters by blob (some 55 figures cross the quarter line: every alpha blob joins the quarter of its centroid).
Scale (the library's advice, it118 notes): one k per strip, so that its frame-4 body length (the bbox along
the throw axis: height for toward / away, width for right / left) is LEN x the standing figure (fig_h 110,
RivetFrames.FIG_PX). LEN per art key matches the dome to the walk8 rows' dome (measured on the toward
down frame against walk8's toward cell): p70 1.2, p55 1.45 (the 55 drawings: a smaller helmet, longer legs).
Anchor: the lying cells' (tumble, slide, down) alpha centre on the cell centre (the body lies across his
ground point); the impact cell's lowest row IMPACT_DROP x its height below the cell centre (he is hit
standing: the feet stay near the foot line instead of sinking half a figure). Square cells. Premultiplied
resampling, --tone like rivet_walk.py. Deterministic.
"""

import json
import sys

import numpy as np
from PIL import Image
from scipy import ndimage

LIB = "C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/"
PICKS = {
    "p70": ["toward_70", "away_70_v4", "right_70_v2", "left_70_v2"],
    "p55": ["toward_55_v2", "away_55_v3", "right_55", "left_55"],
}
FIG_H = 110.0
IMPACT_DROP = 0.25
MIN_BLOB = 40


def _cells(name: str) -> list:
    """The 4 figures: each alpha blob (8-connected, MIN_BLOB px or more) goes to the quarter holding its
    centroid, so a limb crossing a quarter line stays on its figure and no neighbour's limb is cut in."""
    im = Image.open(f"{LIB}rivet_knockdown_{name}.png").convert("RGBA")
    px = np.asarray(im)
    lab, n = ndimage.label(px[:, :, 3] > 24, structure=np.ones((3, 3)))
    q = im.width / 4.0
    owner = np.zeros(n + 1, dtype=np.int32) - 1
    for i, sl in enumerate(ndimage.find_objects(lab), start=1):
        ys, xs = np.nonzero(lab[sl] == i)
        if len(xs) >= MIN_BLOB:
            owner[i] = min(3, int((xs.mean() + sl[1].start) / q))
    out = []
    for c in range(4):
        keep = owner[lab] == c
        ys, xs = np.nonzero(keep)
        cell = px.copy()
        cell[~keep] = 0
        box = (int(xs.min()), int(ys.min()), int(xs.max()) + 1, int(ys.max()) + 1)
        out.append(Image.fromarray(cell, "RGBA").crop(box))
    return out


def _tone(out: Image.Image, ref_path: str) -> Image.Image:
    a = np.asarray(out).astype(np.float64)
    r = np.asarray(Image.open(ref_path).convert("RGBA")).astype(np.float64)
    m, rm = a[:, :, 3] > 200, r[:, :, 3] > 200
    rgb = a[:, :, :3]
    mu, sd = rgb[m].mean(0), rgb[m].std(0)
    rmu, rsd = r[:, :, :3][rm].mean(0), r[:, :, :3][rm].std(0)
    a[:, :, :3] = np.clip((rgb - mu) * (rsd / sd) + rmu, 0, 255)
    return Image.fromarray(np.round(a).astype(np.uint8), "RGBA")


def main() -> None:
    opts = {a.split("=")[0][2:]: a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--")}
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    art, dst = args[0], args[1]
    length = float(opts.get("len", 1.45)) * FIG_H
    rows, ks = [], []
    for ri, name in enumerate(PICKS[art]):
        cells = _cells(name)
        down = cells[3]
        k = length / (down.height if ri < 2 else down.width)
        ks.append(round(k, 4))
        sized = []
        for c in cells:
            size = (max(1, round(c.width * k)), max(1, round(c.height * k)))
            sized.append(c.convert("RGBa").resize(size, Image.LANCZOS).convert("RGBA"))
        rows.append(sized)
    half = 0
    for r in rows:
        half = max(half, r[0].width / 2, r[0].height * (1 - IMPACT_DROP))
        half = max([half] + [max(c.width, c.height) / 2 for c in r[1:]])
    cell = int(np.ceil(2 * half)) + 4
    out = Image.new("RGBA", (cell * 4, cell * 4), (0, 0, 0, 0))
    for ri, r in enumerate(rows):
        for ci, c in enumerate(r):
            x = ci * cell + round((cell - c.width) / 2)
            if ci == 0:
                y = ri * cell + round(cell / 2 + c.height * IMPACT_DROP) - c.height
            else:
                y = ri * cell + round((cell - c.height) / 2)
            out.alpha_composite(c, (x, y))
    if "tone" in opts:
        out = _tone(out, opts["tone"])
    out.save(dst, optimize=True)
    meta = {"art": art, "cell": cell, "len_x_fig": float(opts.get("len", 1.45)), "scales": ks}
    meta["src"] = ["rivet_knockdown_" + n for n in PICKS[art]]
    meta["tone"] = opts.get("tone", "")
    meta["impact_drop"] = IMPACT_DROP
    if "json" in opts:
        with open(opts["json"], "w", encoding="utf-8") as fh:
            json.dump(meta, fh, indent=1, sort_keys=True)
    print(json.dumps(meta))


if __name__ == "__main__":
    main()
