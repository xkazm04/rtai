"""d9 rivet: measure the muzzle point of each drawn Rivet strip cell (RivetMuzzle reads it).

usage: python -I tools/art/rivet_muzzle.py [--check] [--sheet=<contact.png>]

Reads the strips rivet_frames.py cut (tools/art/rivet_frames.json) and writes
project/data/tables/rivet_muzzle.json (gtai.rivet-muzzle/1): per art key and strip, the cells
whose muzzle could be measured -> [x, y] px from the cell's top-left (unmirrored).

- An equipped strip's fire cells (5 = fire toward camera-right, 6 = toward the camera) carry a
  drawn flash: the muzzle is the flash's root, the pixel of the biggest flash-core blob (pale hot
  yellow) nearest the figure's body centre; blobs count off the visor (a flat hot blob centred in
  the helmet's span above VISOR_BAND of the figure) and, in the side cell, right of the body centre
  (a launcher's back-blast is drawn hot too). A cell with fewer than MIN_FLASH core px (a
  whirl or a beam drawn in another hue) takes its shape: the arm band's rightmost px (cell 5),
  the arm band's centre at CAM_Y of the figure (cell 6).
- The cone weapon's facing cells (FACE_WEAPONS, cells 0-4): the flamer fires from its facing
  cells off the side and camera octants (RivetFrames), so its game jet must leave the drawn wand.
  The wand points right in all five drawn facings: the rightmost px in FACE_BAND (the nozzle ring).
  Other holds are drawn every which way in their facings (the pistol at image left in cell 0): no
  facing point, they fire from their fire cells.
- A swing with no drawn arc (STRIKE_TIP): its side strike cell's (5) tip, the smear's reach.
- A one-handed hold's drawn left strip (cells 0-2): the gun points left, so the muzzle is the
  leftmost opaque pixel in the arm band (ARM_BAND of the figure height, below the helmet).

--check exits 1 when the table on disk differs from a fresh measure. --sheet writes a contact
sheet with every measured point marked (a red cross) to judge by eye. Deterministic.
"""

import json
import sys

import numpy as np
from PIL import Image, ImageDraw
from scipy import ndimage

MANIFEST = "tools/art/rivet_frames.json"
OUT = "project/data/tables/rivet_muzzle.json"
SCHEMA = "gtai.rivet-muzzle/1"
FIRE_CELLS = (5, 6)
FACE_CELLS = (0, 1, 2, 3, 4)
FACE_WEAPONS = ("flamethrower",)
## The p70 wand is held low (the nozzle at ~0.8 of the figure in the three-quarter facings).
FACE_BAND = (0.38, 0.86)
EQ_CELLS = 8
LEFT_CELLS = 3
MIN_FLASH = 6
ARM_BAND = (0.38, 0.72)
VISOR_BAND = 0.58
CAM_Y = 0.7
VISOR_FLAT = 2.0
## Blades, the baton and the bottle: no muzzle flash (the swing's smear, the lit rag instead).
NO_FLASH = ("katana", "chainsaw", "plasma_sword", "electro_baton", "molotov")
## Swings whose strike cell draws no arc (RivetStrips.NO_ARC): the side strike cell's (5) weapon
## tip, the arm band's rightmost px, so the game's smear reaches the drawn tip (RivetMuzzle).
STRIKE_TIP = ("electro_baton",)
## Left cells whose gun is held low at the hip (the asset lane's hand fix: the gun in the far
## claw), so the near cable spike is the leftmost px of the arm band: the bell mouth, read by eye
## on a x5 zoom of the cut cell (d9 it16). Re-read it when the strip is re-cut from another sheet.
LEFT_PINNED = {("p55", "rivet_eq_homing_shard_left", 2): [43, 78]}


def flash_core(rgba):
    r, g, b, a = (rgba[:, :, i].astype(int) for i in range(4))
    return (a > 128) & (r > 225) & (g > 195) & (b < 190)


def fire_point(cell, c):
    core = flash_core(cell)
    rows = np.nonzero((cell[:, :, 3] > 128).any(axis=1))[0]
    top, bot = rows.min(), rows.max()
    _drop_visor(core, cell[:, :, 3] > 128, top, bot)
    body = (cell[:, :, 3] > 128) & ~flash_core(cell)
    by, bx = np.nonzero(body)
    cy, cx = by.mean(), bx.mean()
    if c == 5:
        core[:, : int(cx)] = False  # a launcher's back-blast is drawn hot too
    lab, n = ndimage.label(core)
    if n == 0:
        return None
    sizes = ndimage.sum(core, lab, range(1, n + 1))
    if sizes.max() < MIN_FLASH:
        return None
    fy, fx = np.nonzero(lab == int(np.argmax(sizes)) + 1)  # the flash: the biggest hot blob
    i = int(np.argmin((fx - cx) ** 2 + (fy - cy) ** 2))
    return [int(fx[i]), int(fy[i])]


def _drop_visor(core, alpha, top, bot):
    """Clears the visor's core blobs: flat (VISOR_FLAT wide per tall), centred in the helmet's
    span, above VISOR_BAND (a flash drawn in front of the chest is round or spiky)."""
    head = np.nonzero(alpha[top : int(top + (bot - top) * 0.25)].any(axis=0))[0]
    lab, n = ndimage.label(core)
    boxes = ndimage.find_objects(lab)
    for k, (y, x) in enumerate(ndimage.center_of_mass(core, lab, range(1, n + 1))):
        h = boxes[k][0].stop - boxes[k][0].start
        w = boxes[k][1].stop - boxes[k][1].start
        flat = w >= VISOR_FLAT * h
        if flat and y < top + (bot - top) * VISOR_BAND and head.min() - 2 <= x <= head.max() + 2:
            core[lab == k + 1] = False


def shape_point(cell, c, arm=ARM_BAND):
    """A fire cell without a drawn flash: the arm band's right tip (5), its centre (6)."""
    a = cell[:, :, 3] > 128
    ys = np.nonzero(a.any(axis=1))[0]
    top, bot = ys.min(), ys.max()
    y0 = int(top + (bot - top) * arm[0])
    y1 = int(top + (bot - top) * arm[1])
    if c == 6:
        bx = np.nonzero(a[y0:y1].any(axis=0))[0]
        return [int((bx.min() + bx.max()) // 2), int(top + (bot - top) * CAM_Y)]
    band = a[y0:y1]
    x = int(np.nonzero(band.any(axis=0))[0].max())
    return [x, int(y0 + np.nonzero(band[:, x])[0].mean())]


def left_point(cell):
    a = cell[:, :, 3] > 128
    ys = np.nonzero(a.any(axis=1))[0]
    top, bot = ys.min(), ys.max()
    y0 = int(top + (bot - top) * ARM_BAND[0])
    y1 = int(top + (bot - top) * ARM_BAND[1])
    band = a[y0:y1]
    xs = np.nonzero(band.any(axis=0))[0]
    x = int(xs.min())
    col = np.nonzero(band[:, x])[0]
    return [x, int(y0 + col.mean())]


def im_w(out_dir, art, name):
    return Image.open(f"{out_dir}/{art}/{name}.png").size[0]


def cell_of(out_dir, art, name, c, w):
    im = np.asarray(Image.open(f"{out_dir}/{art}/{name}.png").convert("RGBA"))
    return im[:, c * w : (c + 1) * w]


def measure(out_dir, strips):
    table = {}
    for art in sorted(strips):
        rows = {}
        for name in sorted(strips[art]):
            if name[9:] in STRIKE_TIP:
                w = im_w(out_dir, art, name) // EQ_CELLS
                rows[name] = {"cells": {"5": shape_point(cell_of(out_dir, art, name, 5, w), 5)}}
                continue
            if not name.startswith("rivet_eq_") or name[9:].split("_left")[0] in NO_FLASH:
                continue
            im = np.asarray(Image.open(f"{out_dir}/{art}/{name}.png").convert("RGBA"))
            left = name.endswith("_left")
            n = LEFT_CELLS if left else EQ_CELLS
            w = im.shape[1] // n
            cells = {}
            face = FACE_CELLS if name[9:] in FACE_WEAPONS else ()
            for c in range(LEFT_CELLS) if left else face + FIRE_CELLS:
                cell = im[:, c * w : (c + 1) * w]
                if left:
                    p = LEFT_PINNED.get((art, name, c)) or left_point(cell)
                elif c in face:
                    p = shape_point(cell, 5, FACE_BAND)  # the wand's nozzle
                else:
                    p = fire_point(cell, c) or shape_point(cell, c)
                if p is not None:
                    cells[str(c)] = p
            if cells:
                rows[name] = {"cells": cells}
        table[art] = rows
    return table


def contact(out_dir, table, path):
    tiles = []
    for art in table:
        for name, row in table[art].items():
            im = Image.open(f"{out_dir}/{art}/{name}.png").convert("RGBA")
            n = LEFT_CELLS if name.endswith("_left") else EQ_CELLS
            w = im.width // n
            for c, (x, y) in row["cells"].items():
                t = Image.new("RGBA", (w, im.height), (120, 120, 120, 255))
                t.alpha_composite(im.crop((int(c) * w, 0, (int(c) + 1) * w, im.height)))
                d = ImageDraw.Draw(t)
                d.line((x - 6, y, x + 6, y), fill=(255, 0, 0, 255), width=1)
                d.line((x, y - 6, x, y + 6), fill=(255, 0, 0, 255), width=1)
                d.text((2, 2), f"{art} {name[9:]} {c}", fill=(255, 255, 0, 255))
                tiles.append(t)
    cols = 10
    tw = max(t.width for t in tiles)
    th = max(t.height for t in tiles)
    g = Image.new("RGB", (cols * tw, ((len(tiles) + cols - 1) // cols) * th), (60, 60, 60))
    for i, t in enumerate(tiles):
        g.paste(t.convert("RGB"), ((i % cols) * tw, (i // cols) * th))
    g.save(path)


def main(argv):
    man = json.load(open(MANIFEST, encoding="utf-8"))
    table = measure(man["out"], man["strips"])
    doc = (
        "d9 rivet: the muzzle point of Rivet's drawn strip cells, measured by "
        "tools/art/rivet_muzzle.py (px from the cell's top-left, unmirrored). The flamer's facing "
        "cells 0-4: the wand's nozzle; fire cells 5/6: the drawn flash's root; a one-handed left strip's cells 0-2: the gun's left tip. RivetMuzzle "
        "publishes it as HeldMuzzle while the drawn figure carries the weapon; a cell without a "
        "point keeps the caller's fallback spot."
    )
    data = {"doc": doc, "schema": SCHEMA, "strips": table}
    text = json.dumps(data, indent=2, sort_keys=True) + "\n"
    for a in argv:
        if a.startswith("--sheet="):
            contact(man["out"], table, a.split("=", 1)[1])
    if "--check" in argv:
        same = open(OUT, encoding="utf-8").read() == text
        print("rivet_muzzle: " + ("up to date" if same else "STALE"))
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    count = sum(len(r["cells"]) for t in table.values() for r in t.values())
    print(f"rivet_muzzle: {count} points in {OUT}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
