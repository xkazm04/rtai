"""Register the clamshell on its fixed 1.4 m plate. Source rows are time, columns are facing."""
import argparse
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from cast_pack import TOOLS, VIEW, check_cells, run

CELL = 256
PLATE_WIDTH = 160
PLATE_BOTTOM = 224
RIM_HEIGHT = 10
ROWS = {"attack": 4, "hit": 1, "fall": 3}


def cut_body(image, flash, hit):
    """Keep the closed ink silhouette. Key-coloured smoke and detached spark ticks have no ink."""
    rgb = np.asarray(image.convert("RGB"))
    r, g, b = rgb.astype(np.int16).transpose(2, 0, 1)
    ink = (rgb.max(axis=2) < 118) & (g - np.maximum(r, b) < 12)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    closed = cv2.morphologyEx(ink.astype(np.uint8), cv2.MORPH_CLOSE, kernel)
    contours, _ = cv2.findContours(closed, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    contour = max(contours, key=cv2.contourArea)
    alpha = np.zeros(ink.shape, np.uint8)
    cv2.drawContours(alpha, [contour], -1, 255, cv2.FILLED)
    top = cv2.boundingRect(contour)[1]
    bottom = top + cv2.boundingRect(contour)[3]
    # The clean metal can be lighter than the ink. Restore it below the stack caps,
    # including the bright barrel mouths. Restrict hit ticks to the inked outer contour.
    material = (g - np.maximum(r, b) <= 12).astype(np.uint8)
    material[:top] = 0
    cap_end = top + round((bottom-top)*.21)
    inside = cv2.dilate(alpha, np.ones((3, 3), np.uint8)) > 0
    material[:cap_end] *= inside[:cap_end]
    _, labels, stats, _ = cv2.connectedComponentsWithStats(material)
    largest = 1 + stats[1:, cv2.CC_STAT_AREA].argmax()
    body = labels == largest
    if not flash:
        # Detached bright ticks are excluded by the component test. Trim connected
        # uninked spark rays outside barrel ends on impact art only.
        if hit:
            body &= inside
    else:
        warm = (r > 150) & (r > g * .91) & (g > b + 20)
        reach = cv2.dilate(alpha, np.ones((51, 51), np.uint8)) > 0
        reach[:cap_end] = False
        body |= warm & reach
    alpha = body.astype(np.uint8) * 255
    tile = Image.fromarray(np.dstack((rgb, alpha)))
    return tile.crop(tile.getbbox())


def source_tile(folder, action, pitch, pose, facing):
    row = pose
    if action == "attack" and pitch == 70:
        # The 70-degree flash is in raw row two; the glowing jackets are in row three.
        row = (0, 2, 1, 3)[pose]
    path = folder / f"sentry_turret_{action}_{pitch}_v2.png"
    rows = 2 if action == "hit" else ROWS[action]
    if action == "fall" and pose == 1:
        path = folder / f"sentry_turret_fall_open_{pitch}_clean.png"
        rows, row = 1, 0
    with Image.open(path) as source:
        w, h = source.size
        box = (round(w*facing/5), round(h*row/rows), round(w*(facing+1)/5), round(h*(row+1)/rows))
        return cut_body(source.crop(box), action == "attack" and pose == 2, action == "hit")


def register(tile):
    alpha = np.asarray(tile.getchannel("A"))
    # Measure the lower edge of the striped apron, independently of barrel projection.
    y, x = np.nonzero(alpha[-max(4, round(tile.height * .035)):] > 128)
    left, right = int(x.min()), int(x.max()) + 1
    k = PLATE_WIDTH / (right - left)
    size = tuple(round(d*k) for d in tile.size)
    body = tile.resize(size, Image.Resampling.LANCZOS)
    x0 = round(CELL / 2 - (left + right) * k / 2)
    y0 = PLATE_BOTTOM - size[1]
    if min(x0, y0, CELL - x0 - size[0]) < 1:
        raise ValueError(f"cell clips the {size} body at {(x0,y0)}")
    cell = Image.new("RGBA", (CELL, CELL))
    cell.paste(body, (x0, y0))
    return cell


def pack(folder, pitch):
    dest = VIEW / f"p{pitch}"
    work = folder / "pack" / f"clamshell_{pitch}"
    work.mkdir(parents=True, exist_ok=True)
    rim = None
    band = (0, PLATE_BOTTOM - RIM_HEIGHT, CELL, PLATE_BOTTOM)
    for action, rows in ROWS.items():
        grid = Image.new("RGBA", (5*CELL, rows*CELL))
        for pose in range(rows):
            for facing in range(5):
                tile = source_tile(folder / "out", action, pitch, pose, facing)
                cell = register(tile)
                if rim is None:
                    rim = cell.crop(band)
                cell.paste(rim, band)
                grid.paste(cell, (facing*CELL, pose*CELL))
        raw = work / f"{action}.png"
        grid.save(raw)
        output = dest / f"sentry_turret_{action}.png"
        run(TOOLS / "street_tone.py", raw, dest / "cop_patrol_card.png", output)
        check_cells(output, rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    args = parser.parse_args()
    for angle in (70, 55):
        pack(args.round, angle)
