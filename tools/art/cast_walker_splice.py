"""Register replacement fronts to the review-approved rear poses, on one ground baseline."""
import argparse
from functools import lru_cache
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from cast_pack import TOOLS, VIEW, check_cells, run

CELL = 288
BASE = 264
BODY = 200
POSES = {"walk": 4, "attack": 4, "stomp": 4, "hit": 1, "fall": 3}


@lru_cache(maxsize=3)
def components(path, rows):
    # Several toes cross the nominal grid line. Assign whole silhouettes by centre.
    with Image.open(path) as sheet:
        rgb = np.array(sheet.convert("RGB"))
    r, g, b = rgb.astype(np.int16).transpose(2, 0, 1)
    mask = (g <= np.maximum(r, b) + 12).astype(np.uint8)
    _, labels, stats, centres = cv2.connectedComponentsWithStats(mask)
    cutoff = max(stats[1:, cv2.CC_STAT_AREA]) * .20
    bands = [[] for _ in range(rows)]
    for label in range(1, len(stats)):
        x, y, w, h, area = stats[label]
        if area < cutoff:
            continue
        cx, cy = centres[label]
        section = np.s_[y:y+h, x:x+w]
        alpha = (labels[section] == label).astype(np.uint8)*255
        tile = Image.fromarray(np.dstack((rgb[section], alpha)))
        bands[min(rows-1, int(cy*rows/len(rgb)))].append((cx, tile))
    return [sorted(band, key=lambda item: item[0]) for band in bands]


def figure(path, columns, rows, col, row):
    band = components(path, rows)[row]
    if len(band) != columns:
        raise ValueError(f"{path} row {row+1} has {len(band)} bodies, expected {columns}")
    return band[col][1]


def pick(folder, action, pitch, col, row):
    name = folder / f"war_machine_{action}_{pitch}"
    rows = 2 if action == "hit" else POSES[action]
    if col < 2 and action != "hit":
        return figure(Path(f"{name}_front3.png"), 2, rows, col, row)
    if action == "fall":
        return figure(Path(f"{name}_rear4.png"), 3, 3, col-2, row)
    source = Path(f"{name}.png")
    if action == "hit" and col < 2 or action == "walk" and pitch == 70 and col == 4:
        source = Path(f"{name}_v2.png")
    if action == "attack" and pitch == 55 and col == 4:
        source = Path(f"{name}_v2.png")
        row = (0, 2, 1, 3)[row]
    if action == "stomp" and pitch == 70:
        row = (1, 2, 3, 0)[row]
    tile = figure(source, 5, rows, col, row)
    if action == "walk" and pitch == 70 and col == 4 and row in (1, 3):
        tile = tile.transpose(Image.Transpose.FLIP_LEFT_RIGHT)
    return tile


def front_scale(folder, pitch):
    """Calibrate both axes from the front contact on the same 200 px = 2.6 m ruler."""
    path = folder / f"war_machine_walk_{pitch}.png"
    original = [figure(path, 5, 4, col, 0).height for col in range(5)]
    registered = round(original[0] * BODY / np.median(original))
    front = pick(folder, "walk", pitch, 0, 0)
    width = round(front.width * registered / front.height)
    return (BODY * 1.8 / 2.6) / width, BODY / registered


def pack(folder, pitch, action):
    out = folder / "out"
    rows = POSES[action]
    # Use the original sheet's row-zero elevation per facing. One scale per column
    # preserves the height differences between foot lift, slam, recoil and settle.
    tiles = [[pick(out, action, pitch, c, r) for c in range(5)] for r in range(rows)]
    base = out / f"war_machine_{action}_{pitch}.png"
    originals = [figure(base, 5, 2 if action == "hit" else rows, c, 0) for c in range(5)]
    scale = BODY / np.median([im.height for im in originals])
    heights = [round(im.height * scale) for im in originals]
    width_k, height_k = front_scale(out, pitch)
    widest = max(round(im.width * heights[c] / tiles[0][c].height * width_k)
                 for poses in tiles for c, im in enumerate(poses))
    width = max(CELL, widest + 8)
    grid = Image.new("RGBA", (5*width, rows*CELL))
    for row, poses in enumerate(tiles):
        for col, im in enumerate(poses):
            k = heights[col] / tiles[0][col].height
            tile = im.resize((round(im.width*k*width_k), round(im.height*k*height_k)), Image.Resampling.LANCZOS)
            x, y = (width-tile.width)//2, BASE-tile.height
            if min(x,y) < 2:
                raise ValueError(f"clipped {action} {pitch} row {row+1} col {col+1}")
            grid.paste(tile, (col*width+x, row*CELL+y))
            print(f"{action} p{pitch} r{row+1} c{col+1}: {tile.height}px, baseline {BASE}")
    work = folder / "pack" / f"walker_{pitch}"
    work.mkdir(parents=True, exist_ok=True)
    raw = work / f"{action}.png"
    grid.save(raw)
    stem = "armed_walk" if action == "walk" else action
    dest = VIEW / f"p{pitch}"
    output = dest / f"war_machine_{stem}.png"
    run(TOOLS / "street_tone.py", raw, dest / "cop_patrol_card.png", output)
    check_cells(output, rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    args = parser.parse_args()
    for tilt in (70, 55):
        for action in POSES:
            pack(args.round, tilt, action)
