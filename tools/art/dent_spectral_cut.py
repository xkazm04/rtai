"""Cut Dent's magenta masters and preview the packed game texture. Run with py -3 -I.

cut MASTER CELLS   -> tight {facing}_{pose}.png, for ghost_pack.py
board PACKED PREFIX HOVER_HEIGHT   -> PREFIX_board.png and PREFIX_32ppm.png
parts MASTER DEST BOARD   -> scaled top-view PNGs, joint metadata and assembly
HOVER_HEIGHT is the packed median of the five hover poses at that pitch.
"""

import argparse
import json
import math
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw


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


PART_NAMES = ("head", "torso", "upperarm", "forearm_fist", "forearm_open", "tail_root")
# Joint locations on the tight raw take 1 cuts in pixels (shoulder disc, elbow
# disc, proximal forearm socket and knuckle/fingertip at the distal end).
JOINTS = {
    "upperarm": ((80, 94), (352, 104)),
    "forearm_fist": ((29, 106), (351, 106)),
    "forearm_open": ((28, 126), (458, 129)),
}


def assembly(parts, metadata):
    frame = Image.new("RGBA", (600, 760))

    def place(name, anchor, target, degrees):
        im = parts[name]
        ax, ay = anchor
        tx, ty = target
        angle = math.radians(degrees)
        c, s = math.cos(angle), math.sin(angle)
        inverse = (c, s, ax-c*tx-s*ty, -s, c, ay+s*tx-c*ty)
        frame.alpha_composite(im.transform(frame.size, Image.Transform.AFFINE, inverse,
                                           resample=Image.Resampling.BICUBIC))
        bx, by = metadata[name]["pivot_b"]
        return (tx+c*(bx-ax)-s*(by-ay), ty+s*(bx-ax)+c*(by-ay))

    torso = parts["torso"]
    tx, ty = 300, 300
    place("tail_root", metadata["tail_root"]["pivot_a"], (tx, ty-28), 180)
    for side, hand in ((-1, "forearm_fist"), (1, "forearm_open")):
        shoulder = (tx+side*torso.width*0.345, ty-torso.height*0.09)
        elbow = place("upperarm", metadata["upperarm"]["pivot_a"], shoulder, 90-side*18)
        place(hand, metadata[hand]["pivot_a"], elbow, 90+side*12)
    place("torso", metadata["torso"]["pivot_a"], (tx, ty), 0)
    place("head", metadata["head"]["pivot_a"], (tx, ty-torso.height*0.30), 0)
    return frame.crop(frame.getbbox())


def parts(master, dest, proof):
    raw = {PART_NAMES[r*3+c]: im for r, c, im in figures(master, 2, 3)}
    # The master repeats the waist buckle above the tail. Start at the glass
    # and flame below that buckle so the torso supplies the single visible belt.
    tail = raw["tail_root"]
    tail = tail.crop((0, 71, tail.width, tail.height))
    raw["tail_root"] = tail.crop(tail.getbbox())
    with Image.open(dest.parent / "helmet.png") as old:
        scale = old.height / raw["head"].width
    dest.mkdir(parents=True, exist_ok=True)
    metadata = {}
    textures = {}
    for name, im in raw.items():
        w, h = (round(n*scale) for n in im.size)
        texture = im.resize((w, h), Image.Resampling.LANCZOS)
        textures[name] = texture
        texture.save(dest / f"{name}.png")
        a = b = [w/2, h/2]
        if name in JOINTS:
            a, b = ([round(x*w/im.width, 1), round(y*h/im.height, 1)] for x, y in JOINTS[name])
        elif name == "tail_root":
            a, b = [w/2, 0], [w/2, h-1]
        metadata[name] = {"size": [w, h], "sheet": f"n20/dent/masters/{master.name}",
                          "pivot_a": a, "pivot_b": b}
        print(f"{name} {w} x {h} pivots {a} {b}")
    (dest / "parts.json").write_text(json.dumps(metadata, indent=1) + "\n",
                                     encoding="utf-8", newline="\n")
    art = assembly(textures, metadata)
    canvas = Image.new("RGB", (1320, 660), "#3a3a3a")
    labels = ImageDraw.Draw(canvas)
    for i, (name, texture) in enumerate(textures.items()):
        x, y = 147+(i%3)*296, 164+(i//3)*315
        canvas.paste(texture, (x-texture.width//2, y-texture.height//2), texture)
        labels.text((x, y+129), name.replace("_", " "), fill="white", anchor="mm", font_size=18)
    art.thumbnail((380, 552), Image.Resampling.LANCZOS)
    canvas.paste(art, (1100-art.width//2, 308-art.height//2), art)
    labels.text((1100, 609), "assembled", fill="white", anchor="mm", font_size=18)
    proof.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(proof)


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
    top = commands.add_parser("parts")
    top.add_argument("master", type=Path)
    top.add_argument("dest", type=Path)
    top.add_argument("proof", type=Path)
    args = parser.parse_args()
    if args.command == "cut":
        cut(args.master, args.dest)
    elif args.command == "board":
        board(args.packed, args.prefix, args.hover_height)
    else:
        parts(args.master, args.dest, args.proof)
