"""Cut Dent's magenta masters and preview the packed game texture. Run with py -3 -I.

cut MASTER CELLS   -> tight {facing}_{pose}.png, for ghost_pack.py
board PACKED PREFIX HOVER_HEIGHT   -> PREFIX_board.png and PREFIX_32ppm.png
HOVER_HEIGHT is the packed median of the five hover poses at that pitch.
"""

import argparse
from pathlib import Path

import cv2
import numpy as np
from PIL import Image


def key(image):
    rgb = np.array(image.convert("RGB"), dtype=np.float32)
    red, green, blue = rgb.transpose(2, 0, 1)
    spill = np.minimum(red, blue) - green
    # Ink, teal, ochre and steel are clean samples. Recover the coverage of mixed
    # edge pixels against the measured key colour using the nearest clean sample.
    clean = (spill <= 2) & (blue <= green + 7)
    _, nearest = cv2.distanceTransformWithLabels(
        (~clean).astype("uint8"), cv2.DIST_L2, 5, labelType=cv2.DIST_LABEL_PIXEL
    )
    colours = np.empty((nearest.max() + 1, 3), dtype=np.float32)
    colours[nearest[clean]] = rgb[clean]
    pigment = colours[nearest]
    backdrop = np.median(rgb[spill > 180], axis=0)
    vector = pigment - backdrop
    coverage = ((rgb - backdrop) * vector).sum(2) / np.maximum((vector * vector).sum(2), 1)
    alpha = np.where(clean, 1, np.clip(coverage, 0, 1))
    alpha[(alpha < 0.08) | (spill > 209)] = 0
    rgba = np.dstack((pigment, np.rint(alpha * 255))).astype("uint8")
    rgba[alpha == 0] = 0
    return rgba


def figures(master, rows, cols):
    with Image.open(master) as image:
        rgba = key(image)
    mask = (rgba[:, :, 3] > 0).astype("uint8")
    count, labels, stats, centres = cv2.connectedComponentsWithStats(mask, connectivity=8)
    areas = stats[:, cv2.CC_STAT_AREA]
    anchors = sorted(range(1, count), key=lambda i: -int(areas[i]))[:rows * cols]
    if len(anchors) != rows * cols or min(areas[anchors]) < 1000:
        raise ValueError("too few distinct main silhouettes")
    # Every detached shard belongs to the closest silhouette, measured from
    # actual edges. An alpha island is assigned whole, even across a midpoint.
    other = ~np.isin(labels, anchors)
    distance, owners = cv2.distanceTransformWithLabels(
        other.astype("uint8"), cv2.DIST_L2, 5, labelType=cv2.DIST_LABEL_CCOMP
    )
    lookup = np.zeros(count, dtype=np.int32)
    lookup[labels[~other]] = owners[~other]
    for i in np.flatnonzero((areas >= 8) & (lookup == 0)):
        if i == 0:
            continue
        x, y, w, h, _ = stats[i]
        region = np.s_[y:y+h, x:x+w]
        island = labels[region] == i
        distances = distance[region][island]
        pos = distances.argmin()
        if distances[pos] < 48:
            lookup[i] = owners[region][island][pos]
    assigned = lookup[labels]
    anchors.sort(key=lambda i: centres[i, 1])
    for row in range(rows):
        ordered = sorted(anchors[row*cols:(row+1)*cols], key=lambda i: centres[i, 0])
        for col, i in enumerate(ordered):
            mask = assigned == lookup[i]
            x, y, w, h = cv2.boundingRect(mask.astype("uint8"))
            cell = rgba[y:y+h, x:x+w].copy()
            cell[~mask[y:y+h, x:x+w]] = 0
            yield row, col, Image.fromarray(cell)


def cut(master, dest):
    dest.mkdir(parents=True, exist_ok=True)
    for row, col, cell in figures(master, 4, 5):
        cell.save(dest / f"{col+1}_{row+1}.png")


def board(packed, prefix, hover_height):
    sheet = Image.open(packed).convert("RGBA")
    w, h = sheet.width // 4, sheet.height // 5
    if sheet.size != (w * 4, h * 5):
        raise ValueError("expected a four-pose, five-facing atlas")
    size = tuple(round(n * 86.4 / hover_height) for n in (w, h))
    preview = Image.new("RGB", (size[0] * 5, size[1] * 4), "#3a3a3a")
    for pose in range(4):
        for facing in range(5):
            rect = (pose*w, facing*h, (pose+1)*w, (facing+1)*h)
            cell = sheet.crop(rect).resize(size, Image.Resampling.LANCZOS)
            preview.paste(cell, (facing*size[0], pose*size[1]), cell)
    prefix.parent.mkdir(parents=True, exist_ok=True)
    preview.crop((0, 0, preview.width, size[1])).save(f"{prefix}_32ppm.png")
    preview.resize((preview.width*4, preview.height*4), Image.Resampling.NEAREST).save(
        f"{prefix}_board.png"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    cutter = commands.add_parser("cut")
    cutter.add_argument("master", type=Path)
    cutter.add_argument("dest", type=Path)
    preview = commands.add_parser("board")
    preview.add_argument("packed", type=Path)
    preview.add_argument("prefix", type=Path)
    preview.add_argument("hover_height", type=float)
    args = parser.parse_args()
    if args.command == "cut":
        cut(args.master, args.dest)
    else:
        board(args.packed, args.prefix, args.hover_height)
