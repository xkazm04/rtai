"""n9 rivet: pack the asset lane's diagonal flamer FIRE cells into one game strip per art key.

usage: python -I tools/art/rivet_flame_diag.py <art> <cells_dir> [--check]

<cells_dir> holds 4 tight cells `1_1..1_4` (3/4 toward right, 3/4 away right, 3/4 toward left,
3/4 away left; the left ones drawn, never mirrored), as the library's
`rivet_eq_flamethrower_fire_diag_<p>_cells` deliveries. Writes
project/features/characters/art/view/<art>/rivet_eq_flamethrower_diag.png: 4 cells in that order
(RivetStrips.DIAG_CELL maps the octant to the cell). The scale: the house rule the library drew
them to, the robot (without its flame: the tallest non-flame columns) as tall as the robot of the
equipped strip's side fire cell (5), so a diagonal burst reads the size of a side burst. Each cell's anchor is its helmet's centre (the robot's top quarter) on the
cell's centre column and the robot's lowest row (its feet) FOOT px above the cell's bottom: a flame
toward the camera reaches below his feet, so the strip has room under the foot line
(RivetStrips.DIAG_FOOT_PX takes the printed value). Premultiplied resampling. Deterministic.
"""

import sys

import numpy as np
from PIL import Image

PAD = 2
VIEW = "project/features/characters/art/view"
EQ_CELLS = 8


def robot_rows(a):
    """The robot without its flame (the library's flamer_diag_cut measure): the non-flame pixels'
    tallest columns (the flame and its ink lie to one side), and the rows they fill."""
    r, g, b, al = (a[:, :, i].astype(int) for i in range(4))
    m = (al > 128) & ~((r > 200) & (g > 120) & (b < 175) & (r - b > 80))
    colh = m.sum(0)
    cols = np.nonzero(colh > 0.6 * colh.max())[0]
    band = m[:, cols.min() : cols.max() + 1]
    rows = np.nonzero(band.sum(1) > max(1, a.shape[0] // 100))[0]
    return m, cols, rows


def measure(a):
    m, cols, rows = robot_rows(a)
    top, feet = int(rows[0]), int(rows[-1])
    head = m[top : top + max(1, (feet - top) // 4), cols.min() : cols.max() + 1]
    ax = cols.min() + float(np.nonzero(head)[1].mean())
    return {"top": top, "feet": feet, "ax": ax, "h": feet - top + 1}


def scaled(im, k):
    a = np.asarray(im.convert("RGBA")).astype(np.float32)
    a[:, :, :3] *= a[:, :, 3:4] / 255.0
    w, h = max(1, round(im.width * k)), max(1, round(im.height * k))
    chans = [Image.fromarray(a[:, :, i]).resize((w, h), Image.LANCZOS) for i in range(4)]
    out = np.stack([np.asarray(c) for c in chans], axis=2)
    out = np.clip(out, 0.0, 255.0)
    al = out[:, :, 3:4]
    out[:, :, :3] = np.where(al > 0.5, out[:, :, :3] * 255.0 / np.maximum(al, 1e-3), 0.0)
    return np.clip(out, 0, 255).astype(np.uint8)


def side_robot_h(art):
    """The robot's height in the equipped strip's side fire cell (5): the house size."""
    eq = np.asarray(Image.open(f"{VIEW}/{art}/rivet_eq_flamethrower.png").convert("RGBA"))
    w = eq.shape[1] // EQ_CELLS
    return measure(eq[:, 5 * w : 6 * w])["h"]


def pack(art, cells_dir):
    ims = [Image.open(f"{cells_dir}/1_{i}.png").convert("RGBA") for i in range(1, 5)]
    ms = [measure(np.asarray(im)) for im in ims]
    k = side_robot_h(art) / float(np.median([m["h"] for m in ms]))
    half = max(max(m["ax"], im.width - m["ax"]) for m, im in zip(ms, ims)) * k
    above = max(m["feet"] for m in ms) * k
    below = max(im.height - m["feet"] for m, im in zip(ms, ims)) * k
    cw, foot = int(np.ceil(half)) * 2 + 4, int(np.ceil(below)) + PAD
    ch = int(np.ceil(above)) + foot
    sheet = Image.new("RGBA", (cw * 4, ch), (0, 0, 0, 0))
    for i, (im, m) in enumerate(zip(ims, ms)):
        cell = Image.fromarray(scaled(im, k))
        x = i * cw + round(cw / 2 - m["ax"] * k)
        y = round(ch - foot - m["feet"] * k)
        sheet.alpha_composite(cell, (x, y))
    return sheet, k, foot


def main(argv):
    art, cells_dir = argv[0], argv[1]
    sheet, k, foot = pack(art, cells_dir)
    out = f"{VIEW}/{art}/rivet_eq_flamethrower_diag.png"
    if "--check" in argv:
        same = np.array_equal(np.asarray(Image.open(out).convert("RGBA")), np.asarray(sheet))
        print("rivet_flame_diag: " + ("up to date" if same else "STALE"))
        return 0 if same else 1
    sheet.save(out, optimize=True)
    print(f"rivet_flame_diag: {out} cell {sheet.width // 4}x{sheet.height} k {k:.4f} foot {foot}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
