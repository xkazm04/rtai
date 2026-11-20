"""Rebuild Kerf's Swarf Ronin cutouts, packed atlases, landmarks and proof boards.

Run with py -3 -I tools/art/kerf_n21_cut.py ARCHIVE (see the prompt README).
ARCHIVE holds masters/ and receives intermediate cells and proof boards. Source
landmarks use (x, y) from the master top left. Packed metadata uses pixel centres
relative to each cell, with x increasing rightward and y increasing downward.
"""

import argparse
import json
import statistics
import subprocess
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw

HERE = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE))
from dent_spectral_cut import key
from ghost_pack import PAD, mass_x

ROOT = HERE.parents[1]
SOULS = ROOT / "project/features/souls/art"
RONIN = SOULS / "kerf/ronin"
PARTS = ("head", "torso", "upperarm", "blade", "tail_straight", "tail_curled")
BACK = "#1d2228"
FILTER = Image.Resampling.LANCZOS

# Reviewed panel windows in the raw masters, pose-major, then facing. Keep
# the search on the steel plate so visor, rivet and blade highlights cannot
# masquerade as charge slots. None denotes a completely occluded panel.
FLIGHT_PANELS = (
    ((167,106,202,129),(494,105,527,130),(797,107,816,130),(1038,82,1066,107),(1354,81,1394,107)),
    ((150,393,186,408),(492,384,525,401),(803,381,830,402),(1073,339,1107,358),(1360,344,1401,369)),
    ((174,612,210,639),(493,616,521,639),(790,612,814,632),(1097,595,1128,628),(1403,595,1438,631)),
    ((154,828,191,853),(486,831,520,858),(791,835,816,863),(1045,841,1072,867),(1351,838,1385,866)),
)
ACTION_PANELS = (
    ((149,135,169,145),None,None,(1037,78,1075,104),(1364,88,1405,120)),
    ((147,378,180,395),None,None,(1066,333,1101,361),(1366,335,1408,364)),
    ((146,622,180,643),(466,609,500,633),(780,607,797,632),(1043,584,1078,612),(1367,585,1407,614)),
    ((146,889,179,908),(476,879,505,899),None,(1055,826,1098,852),(1367,835,1406,862)),
)


def write_json(path, data):
    path.write_text(json.dumps(data, indent=1) + "\n", encoding="utf-8", newline="\n")


def silhouettes(path, rows, cols):
    """Flood magenta from outside and grid gutters, then unmix the keyed edge.

    Assign each disconnected wisp to the nearest main silhouette as in Dent's
    cutter. Use the main silhouette centres to order the poses: long blades can
    extend through nominal cell boundaries without being chopped off.
    """
    with Image.open(path) as source:
        if source.size != (1536, 1024):
            raise ValueError(f"expected a 1536 x 1024 master: {path}")
        rgb = np.asarray(source.convert("RGB"), dtype=np.int16)
    magenta = np.minimum(rgb[:, :, 0], rgb[:, :, 2]) - rgb[:, :, 1] > 210
    _, regions = cv2.connectedComponents(magenta.astype("uint8"), connectivity=8)
    ys = np.linspace(0, regions.shape[0] - 1, rows + 1).round().astype(int)
    xs = np.linspace(0, regions.shape[1] - 1, cols + 1).round().astype(int)
    seeds = np.unique(np.r_[regions[ys].ravel(), regions[:, xs].ravel()])
    background = np.isin(regions, seeds[seeds != 0])
    # Discard the exterior flood. Unmix the remaining pixels (including the
    # isolated punched holes) against the measured background in Dent's key.
    rgba = np.zeros((*regions.shape, 4), dtype="uint8")
    coverage = key(Image.fromarray(rgb.astype("uint8")))
    rgba[~background] = coverage[~background]
    mask = (rgba[:, :, 3] > 0).astype("uint8")
    count, labels, stats, centres = cv2.connectedComponentsWithStats(mask, connectivity=8)
    areas = stats[:, cv2.CC_STAT_AREA]
    anchors = sorted(range(1, count), key=lambda i: -int(areas[i]))[:rows * cols]
    if len(anchors) != rows * cols or min(areas[anchors]) < 1000:
        raise ValueError(f"too few separate silhouettes: {path}")
    other = ~np.isin(labels, anchors)
    dist, owners = cv2.distanceTransformWithLabels(
        other.astype("uint8"), cv2.DIST_L2, 5, labelType=cv2.DIST_LABEL_CCOMP
    )
    lookup = np.zeros(count, dtype=np.int32)
    lookup[labels[~other]] = owners[~other]
    for i in np.flatnonzero((areas >= 8) & (lookup == 0)):
        if i == 0:
            continue
        x, y, w, h, _ = stats[i]
        rect = np.s_[y:y+h, x:x+w]
        bits = labels[rect] == i
        distances = dist[rect][bits]
        if distances.min() < 48:
            lookup[i] = owners[rect][bits][distances.argmin()]
    assigned = lookup[labels]
    anchors.sort(key=lambda i: centres[i, 1])
    for row in range(rows):
        line = sorted(anchors[row*cols:(row+1)*cols], key=lambda i: centres[i, 0])
        for col, i in enumerate(line):
            bits = assigned == lookup[i]
            x, y, w, h = cv2.boundingRect(bits.astype("uint8"))
            cell = rgba[y:y+h, x:x+w].copy()
            cell[~bits[y:y+h, x:x+w]] = 0
            yield row, col, Image.fromarray(cell), (x, y)


def points(image, box, scale=1):
    """Measure bright cores inside a reviewed chest/back panel; ignore edge glints."""
    if not box:
        return []
    x, y = box[:2]
    red, green, blue, alpha = np.asarray(image.crop(box)).transpose(2, 0, 1)
    bright = (red >= 195) & (green >= 240) & (blue >= 224) & (alpha >= 128)
    count, _, stats, centres = cv2.connectedComponentsWithStats(bright.astype("uint8"))
    return sorted([round(x+cx, 2), round(y+cy, 2)]
                  for i, (cx, cy) in enumerate(centres[1:count], 1)
                  if stats[i, cv2.CC_STAT_AREA] >= 6 * scale**2)


def centre(image):
    moments = cv2.moments(np.asarray(image.getchannel("A")))
    return [round(moments[k] / moments["m00"], 2) for k in ("m10", "m01")]


def top_parts(master):
    # Pixel centres on the accepted raw drawing: discs, blade tip, ribbon ends.
    joints = {
        "head": ((257, 290), (257, 290)),
        "torso": ((759, 251), (759, 251)),
        "upperarm": ((1125, 289), (1424, 297)),
        "blade": ((101, 754), (484, 667)),
        "tail_straight": ((767, 532), (751, 998)),
        "tail_curled": ((1273, 532), (1237, 990)),
    }
    raw = list(silhouettes(master, 2, 3))
    scale = 165 / raw[0][2].width  # Dent's shipped top-view spectral head width.
    metadata = {}
    RONIN.mkdir(parents=True, exist_ok=True)
    for name, (_, _, cut, (x, y)) in zip(PARTS, raw, strict=True):
        size = tuple(round(v * scale) for v in cut.size)
        part = cut.resize(size, FILTER)
        part.save(RONIN / f"{name}.png")
        sx, sy = part.width/cut.width, part.height/cut.height
        a, b = ([round((px-x)*sx, 1), round((py-y)*sy, 1)] for px, py in joints[name])
        metadata[name] = {"size": list(size), "sheet": f"n21/kerf/masters/{master.name}",
                          "pivot_a": a, "pivot_b": b}
        if name == "torso":
            box = (round((716-x)*sx), round((153-y)*sy),
                   round((803-x)*sx), round((209-y)*sy))
            torso = {"cell_size": list(size), "alpha_mass_center": centre(part),
                     "slots": points(part, box)}
            if len(torso["slots"]) != 3:
                raise ValueError(f"expected three back slots: {torso}")
    write_json(RONIN / "parts.json", metadata)
    return torso


def atlas_cells(path):
    """Dent's shipped drawer indexes pose across and facing down."""
    with Image.open(path) as source:
        w, h = source.width // 4, source.height // 5
        if source.size != (4*w, 5*h):
            raise ValueError(f"invalid atlas: {path}")
        return {(pose, face): source.crop((pose*w, face*h, (pose+1)*w, (face+1)*h))
                for face in range(5) for pose in range(4)}


def packed_transform(image, origin, cell, k):
    """Map master pixel positions through ghost_pack's actual resize and seat."""
    scaled = image.resize(tuple(round(v*k) for v in image.size), FILTER)
    left, top, _, bottom = scaled.getbbox()
    x = round(cell.width/2 - mass_x(scaled) + left) - left
    y = cell.height - PAD - bottom
    sx, sy = scaled.width/image.width, scaled.height/image.height
    return lambda px, py: (round(x + (px-origin[0])*sx), round(y + (py-origin[1])*sy))


def pack(master, work, output, k, panels, head):
    work.mkdir(parents=True, exist_ok=True)
    cuts = {}
    for pose, face, image, origin in silhouettes(master, 4, 5):
        image.save(work / f"{face+1}_{pose+1}.png")
        cuts[pose, face] = image, origin
    subprocess.run([sys.executable, "-I", str(HERE / "ghost_pack.py"), str(work),
                    str(output), f"--k={k}"], check=True)
    atlas = atlas_cells(output)
    entries = []
    for (pose, face), cell in atlas.items():
        to_cell = packed_transform(*cuts[pose, face], cell, k)
        panel = panels[pose][face]
        box = (*to_cell(*panel[:2]), *to_cell(*panel[2:])) if panel else None
        slots = points(cell, box, k)
        if len(slots) > 3:
            raise ValueError(f"extra highlights: {master.name}, pose {pose}, face {face}: {slots}")
        entries.append({"pose": pose, "facing": face, "alpha_mass_center": centre(cell),
                        "slots": slots})
    cell = atlas[0, 2]
    to_cell = packed_transform(*cuts[0, 2], cell, k)
    x0, y = to_cell(head[0], head[2])
    x1, _ = to_cell(head[1], head[2])
    opaque = np.flatnonzero(np.asarray(cell.getchannel("A"))[y, x0:x1] >= 128)
    width = int(opaque[-1] - opaque[0] + 1)
    heights = [atlas[0, f].getbbox()[3] - atlas[0, f].getbbox()[1] for f in range(5)]
    return {"cell_size": list(cell.size), "cells": entries, "profile_head_width": width,
            "profile_head_scan": [x0, x1, y], "first_pose_median_height": statistics.median(heights)}


def fit(board, image, rect):
    x, y, w, h = rect
    tile = image.copy()
    tile.thumbnail((w, h), FILTER)
    at = (x+(w-tile.width)//2, y+(h-tile.height)//2)
    board.paste(tile, at, tile if tile.mode == "RGBA" else None)


def label(board, xy, caption, size=16):
    ImageDraw.Draw(board).text(xy, caption, fill="#e6eeee", font_size=size)


def contact(archive, sheets):
    board = Image.new("RGB", (1712, 948), BACK)
    plate = Image.open(archive / "masters/refs/kerf_b.png").convert("RGB")
    fit(board, plate, (16, 154, 800, 550))
    label(board, (16, 118), "SWARF RONIN   /   Owner's concept", 21)
    label(board, (840, 544), "Overhead parts   /   accepted take 1", 18)
    for index, name in enumerate(PARTS):
        x, y = 840+index%3*290, 578+index//3*180
        fit(board, Image.open(RONIN / f"{name}.png"), (x, y, 265, 141))
        label(board, (x+65, y+144), name.replace("_", " "))
    for i, (kind, pitch) in enumerate((("fly",70), ("act",70), ("fly",55), ("act",55))):
        x, y = 840+(i%2)*436, 20+(i//2)*472
        name = "Flight" if kind == "fly" else "Action"
        if (kind, pitch) not in sheets:
            label(board, (x, y), f"{pitch}° {name}   /   awaiting 70° acceptance")
            continue
        path, _, status = sheets[kind, pitch]
        label(board, (x, y), f"{pitch}° {name}   /   {status}")
        cells = atlas_cells(path)
        for (pose, face), cell in cells.items():
            # The board preserves the master's pose rows and facing columns.
            fit(board, cell, (x+face*85, y+52+pose*107, 83, 103))
    board.save(archive / "body_contact_sheet.png")


def scale_board(archive, sheets):
    board = Image.new("RGB", (825, 346), BACK)
    cop_path = ROOT / "project/features/characters/art/view/p70/cop_patrol_card.png"
    cop = Image.open(cop_path).convert("RGBA")
    cw = cop.width//5
    label(board, (10, 7), "32 px/m     P70 guard   /   Kerf   /   Dent", 15)
    for row, pitch in enumerate((70, 55)):
        dent = atlas_cells(SOULS / f"view/p{pitch}/dent_sp_fly.png")
        kerf = sheets.get(("fly", pitch))
        status = kerf[2] if kerf else "no accepted 70° pair"
        label(board, (10, 37+145*row), f"{pitch}°   {status}", 13)
        for col, face in enumerate((0, 2, 4)):
            x, y = 5+col*273, 144+row*145
            label(board, (x+87, y+8), ("Toward","Profile","Away")[col], 13)
            guard = cop.crop((face*cw, 0, (face+1)*cw, cop.height))
            trio = [(guard, 32*1.15/cw, 26), (dent[0,face], 86.4/(223 if pitch==70 else 212), 223)]
            if kerf:
                src, meta, _ = kerf
                trio.append((atlas_cells(src)[0,face], 86.4/meta["first_pose_median_height"], 117))
            for cell, factor, cx in trio:
                tile = cell.resize(tuple(round(v*factor) for v in cell.size), FILTER)
                tile = tile.crop(tile.getbbox())
                board.paste(tile, (x+cx-tile.width//2, y-tile.height), tile)
    zoom = board.resize((board.width*3, board.height*3), Image.Resampling.NEAREST)
    combined = Image.new("RGB", (zoom.width, board.height+zoom.height+32), BACK)
    combined.paste(board)
    label(combined, (8, board.height+4), "3× nearest-neighbour")
    combined.paste(zoom, (0, board.height+32))
    combined.save(archive / "body_scale_32ppm.png")


def slot_board(archive, sheets, torso):
    panels = []
    for pitch in (70, 55):
        if ("fly", pitch) not in sheets:
            continue
        path, info, status = sheets["fly", pitch]
        cells = atlas_cells(path)
        for face, direction in ((0,"toward"), (4,"away")):
            entry = next(e for e in info["cells"] if e["pose"] == 0 and e["facing"] == face)
            panels.append((cells[0,face], entry["slots"], f"{pitch}° {direction} hover   /   {status}"))
    panels.append((Image.open(RONIN / "torso.png"), torso["slots"], "Overhead torso   /   accepted"))
    tiles = []
    for image, slots, caption in panels:
        x0, y0, x1, y1 = image.getbbox()
        tile = image.crop((x0, y0, x1, y1)).resize(((x1-x0)*2, (y1-y0)*2), Image.Resampling.NEAREST)
        pen = ImageDraw.Draw(tile)
        for cx, cy in slots:
            x, y = (cx-x0+0.5)*2-0.5, (cy-y0+0.5)*2-0.5
            pen.ellipse((x-8,y-8,x+8,y+8), outline="#ff612f", width=2)
            pen.point((x,y), fill="#ff612f")
        tiles.append((tile, caption))
    board = Image.new("RGB", (sum(im.width+24 for im,_ in tiles),
                              max(im.height for im,_ in tiles)+68), BACK)
    x = 12
    for im, caption in tiles:
        label(board, (x,12), caption, 20)
        board.paste(im, (x,54), im)
        x += im.width+24
    board.save(archive / "body_slots.png")


def rebuild(archive):
    masters = archive / "masters"
    torso = top_parts(masters / "kerf_sp_top_take1.png")
    # Only accepted artwork has a runtime file or a row in the runtime metadata.
    write_json(RONIN / "cut.json", {"schema": "gtai.kerf_ronin_cut/1", "sheets": {}, "torso": torso})
    sheets = {}
    trials = (("fly", 3, FLIGHT_PANELS, (780,847,60)),
              ("act", 2, ACTION_PANELS, (803,861,77)))
    for kind, take, panels, head in trials:
        name = f"kerf_sp_{kind}_70_take{take}"
        output = archive / f"cut/{name}.png"
        info = pack(masters / f"{name}.png", archive / f"cut/{name}", output, 1.8, panels, head)
        sheets[kind, 70] = (output, info, f"rejected take {take}")
        write_json(output.with_suffix(".json"), info)
    contact(archive, sheets)
    scale_board(archive, sheets)
    slot_board(archive, sheets, torso)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    rebuild(parser.parse_args().archive)
