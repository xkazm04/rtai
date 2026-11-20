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
from kerf_n21_profile import add_far_blade

ROOT = HERE.parents[1]
SOULS = ROOT / "project/features/souls/art"
RONIN = SOULS / "kerf/ronin"
PARTS = ("head", "torso", "upperarm", "blade", "tail_straight", "tail_curled")
BACK = "#1d2228"
FILTER = Image.Resampling.LANCZOS

# Master-pixel samples inside each visible lamp, in pose-major, facing-minor
# order. The cutter locates each connected bright core again on the packed
# texture; the stored centroid comes from every pixel in that core. Empty
# tuples mark occlusion by the blade or by the side of the torso.
SLOT_SAMPLES = {
    "fly_70": (
        # Hover
        ((166, 146), (177, 146), (187, 146)),
        ((497, 149), (506, 149), (513, 148)),
        ((801, 152), (806, 150)),
        ((1035, 137), (1044, 137), (1055, 139)),
        ((1358, 133), (1370, 133), (1383, 133)),
        # Cruise
        ((165, 406), (176, 407), (189, 406)),
        ((514, 404), (522, 406), (527, 410)),
        ((811, 405),),
        ((1074, 359), (1084, 359), (1094, 362)),
        ((1357, 363), (1369, 363), (1380, 363)),
        # Turn
        ((190, 612), (198, 617), (208, 622)),
        ((508, 620), (513, 626), (521, 629)),
        ((798, 617), (803, 622)),
        ((1094, 592), (1103, 599), (1111, 605)),
        ((1394, 590), (1405, 592), (1415, 596)),
        # Hit
        ((162, 855), (173, 854), (186, 855)),
        ((491, 860), (501, 858), (511, 859)),
        ((801, 857), (809, 855)),
        ((1036, 872), (1046, 872), (1057, 870)),
        ((1356, 870), (1368, 870), (1382, 869)),
    ),
    "act_70": (
        # Cock
        ((155, 155), (167, 166), (177, 163)),
        ((493, 163), (497, 162), (502, 160)),
        (),
        (),
        ((1344, 128), (1357, 128), (1368, 128)),
        # Cut
        ((158, 400), (168, 400), (178, 399)),
        (),
        (),
        (),
        ((1364, 374), (1375, 374), (1386, 374)),
        # Recover
        ((157, 631), (168, 631), (179, 631)),
        ((485, 628), (492, 628), (499, 628)),
        (),
        (),
        ((1350, 617), (1362, 617), (1374, 617)),
        # Blink
        ((157, 900), (167, 901), (177, 901)),
        ((485, 896), (492, 899), (500, 894)),
        (),
        (),
        ((1351, 856), (1362, 855), (1374, 855)),
    ),
    "fly_55": (
        # Hover
        ((150, 135), (159, 135), (168, 136)),
        ((477, 134), (483, 135), (491, 133)),
        ((792, 130), (795, 129)),
        ((1037, 118), (1043, 119), (1050, 120)),
        ((1367, 123), (1377, 123), (1386, 123)),
        # Cruise
        ((149, 386), (158, 390), (168, 388)),
        ((488, 377), (497, 379), (501, 380)),
        ((812, 376), (815, 378)),
        ((1091, 344), (1097, 343), (1104, 343)),
        ((1372, 344), (1382, 344), (1391, 344)),
        # Turn
        ((166, 629), (172, 633), (181, 635)),
        ((488, 625), (495, 625), (501, 627)),
        ((790, 624),),
        ((1075, 594), (1083, 595), (1088, 600)),
        ((1393, 599), (1401, 601), (1410, 604)),
        # Hit
        ((149, 843), (159, 843), (169, 843)),
        ((480, 829), (488, 827), (496, 827)),
        ((780, 822), (784, 819)),
        ((1043, 846), (1049, 845), (1056, 843)),
        ((1366, 846), (1376, 846), (1386, 846)),
    ),
    "act_55": (
        # Cock
        ((158, 167), (168, 164)),
        ((494, 149), (503, 148), (510, 145)),
        ((810, 137),),
        ((1058, 123), (1064, 124), (1070, 128)),
        ((1365, 130), (1377, 131), (1390, 131)),
        # Cut
        ((158, 385), (167, 385), (176, 383)),
        ((472, 392), (478, 393)),
        ((797, 388),),
        ((1065, 357), (1072, 357), (1079, 359)),
        ((1361, 360), (1371, 359), (1379, 360)),
        # Recover
        ((157, 629), (168, 629), (178, 629)),
        ((485, 620), (493, 621), (499, 621)),
        ((802, 623),),
        ((1061, 605), (1069, 605), (1076, 606)),
        ((1366, 608), (1377, 608), (1390, 608)),
        # Blink
        ((154, 904), (164, 905), (175, 904)),
        ((483, 900), (490, 900)),
        ((799, 896),),
        ((1062, 860), (1069, 861), (1077, 862)),
        ((1369, 865), (1379, 865), (1390, 867)),
    ),
}

# The crossing blade hides most of the three-quarter cock lamps; only their
# dim ends remain. The last blink lamp at the same facing also lies in shade.
SLOT_THRESHOLDS = {
    ("kerf_sp_act_70_take1", 0, 1): (80, 207, 165),
    ("kerf_sp_act_70_take1", 3, 1): (115, 215, 189),
}

# Whole accepted master, ghost_pack scale and profile helmet scan (x0, x1, y).
SHEETS = {
    "fly_70": (4, 1.64, (760, 841, 89)),
    "act_70": (1, 1.855, (794, 858, 91)),
    "fly_55": (1, 1.59, (755, 839, 73)),
    "act_55": (1, 1.36, (804, 875, 83)),
}


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


def trim_top_fringe(part, name, tip):
    """Cut back exterior teal flames to the ink contour, retaining the luminous point and vapor."""
    rgba = np.array(part)
    _, green, blue, alpha = rgba.transpose(2, 0, 1).astype(np.int16)
    ink = (alpha > 96) & ((green < 120) | (green - blue > 19))
    close = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (7, 7))
    joined = cv2.morphologyEx(ink.astype("uint8"), cv2.MORPH_CLOSE, close)
    contours, _ = cv2.findContours(joined, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    matte = np.zeros_like(joined)
    cv2.drawContours(matte, [max(contours, key=cv2.contourArea)], -1, 255, -1)
    matte = cv2.medianBlur(matte, 7)
    if name == "blade":
        # The distal edge is pure lamp color. Join its measured tip to the terminal ink only.
        ys, xs = np.nonzero(matte)
        terminal = xs > part.width * 0.78
        point = np.rint(tip).astype(np.int32)
        hull = cv2.convexHull(np.vstack((np.column_stack((xs[terminal], ys[terminal])), point))
                              .astype(np.int32))
        cv2.fillConvexPoly(matte, hull, 255)
        cv2.circle(matte, tuple(point), 1, 255, -1)
    matte = cv2.GaussianBlur(matte, (0, 0), 0.9)
    if name.startswith("tail_"):
        # Narrow the uninked end continuously so the ribbon meets flight's trailing wisp.
        y = np.linspace(0, 1, part.height)[:, None]
        distance = cv2.distanceTransform((alpha > 64).astype("uint8"), cv2.DIST_L2, 5)
        core = np.clip((distance - (1 - y) * 10) * 110, 0, 255)
        matte = np.maximum(matte, (core * np.clip((y - 0.59) / 0.16, 0, 1)).astype("uint8"))
    rgba[:, :, 3] = np.minimum(rgba[:, :, 3], matte)
    # A few sparks inside the filled contour disconnect when the outer rim is removed.
    count, labels, stats, _ = cv2.connectedComponentsWithStats((rgba[:, :, 3] > 32).astype("uint8"))
    if count > 2:
        body = 1 + stats[1:, cv2.CC_STAT_AREA].argmax()
        edge = cv2.dilate((labels == body).astype("uint8"), np.ones((3, 3), "uint8"))
        rgba[:, :, 3] *= edge
    rgba[rgba[:, :, 3] == 0] = 0
    return Image.fromarray(rgba)


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
        sx, sy = part.width/cut.width, part.height/cut.height
        a, b = ([round((px-x)*sx, 1), round((py-y)*sy, 1)] for px, py in joints[name])
        part = trim_top_fringe(part, name, b)
        part.save(RONIN / f"{name}.png")
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


def slot_centres(image, seeds, scale, threshold):
    """Find connected light cores near the reviewed positions on the charge panel."""
    if not seeds:
        return []
    margin = round(16 * scale)
    left = min(x for x, _ in seeds) - margin
    top = min(y for _, y in seeds) - margin
    right = max(x for x, _ in seeds) + margin + 1
    bottom = max(y for _, y in seeds) + margin + 1
    red, green, blue, alpha = np.asarray(image.crop((left, top, right, bottom))).transpose(2, 0, 1)
    r, g, b = threshold
    bright = (red >= r) & (green >= g) & (blue >= b) & (alpha >= 128)
    _, labels, _, centres = cv2.connectedComponentsWithStats(bright.astype("uint8"))
    ys, xs = np.nonzero(bright)
    selected = []
    for x, y in seeds:
        dist_sq = (xs + left - x)**2 + (ys + top - y)**2
        if not len(dist_sq) or dist_sq.min() > (4 * scale)**2:
            raise ValueError(f"no slot core near {x}, {y}")
        idx = dist_sq.argmin()
        component = int(labels[ys[idx], xs[idx]])
        if component in selected:
            raise ValueError(f"two landmarks reach the same highlight near {x}, {y}")
        selected.append(component)
    return sorted([round(float(centres[i, 0]) + left, 2), round(float(centres[i, 1]) + top, 2)]
                  for i in selected)


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
        seeds = [to_cell(x, y) for x, y in panels[pose * 5 + face]]
        try:
            threshold = SLOT_THRESHOLDS.get((master.stem, pose, face), (155, 223, 201))
            slots = slot_centres(cell, seeds, k, threshold)
        except ValueError as exc:
            raise ValueError(f"{master.stem}, pose {pose}, facing {face}: {exc}") from exc
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
    board = Image.new("RGB", (2360, 1280), BACK)
    plate = Image.open(archive / "masters/refs/kerf_b.png").convert("RGB")
    fit(board, plate, (16, 260, 800, 550))
    label(board, (16, 222), "SWARF RONIN   /   Owner's concept", 22)
    for row, pitch in enumerate((70, 55)):
        for col, kind in enumerate(("fly", "act")):
            x, y = 840 + col*760, 20 + row*466
            path, _, status = sheets[kind, pitch]
            name = "Flight" if kind == "fly" else "Action"
            label(board, (x, y), f"{pitch} deg {name}   /   {status}", 20)
            poses = ("Hover", "Cruise", "Turn", "Hit") if kind == "fly" else (
                "Cock", "Cut", "Recover", "Blink"
            )
            for (pose, face), cell in atlas_cells(path).items():
                top = y + 34 + pose*104
                if face == 0:
                    label(board, (x, top+43), poses[pose], 14)
                fit(board, cell, (x+66+face*134, top, 130, 100))
    label(board, (840, 966), "Overhead parts   /   take 1", 20)
    for index, name in enumerate(PARTS):
        x = 840 + index*250
        fit(board, Image.open(RONIN / f"{name}.png"), (x, 1014, 232, 204))
        label(board, (x+46, 1236), name.replace("_", " "))
    board.save(archive / "body_contact_sheet.png")


def scale_board(archive, sheets):
    board = Image.new("RGB", (825, 346), BACK)
    cop_path = ROOT / "project/features/characters/art/view/p70/cop_patrol_card.png"
    cop = Image.open(cop_path).convert("RGBA")
    cw = cop.width//5
    label(board, (10, 7), "32 px/m     P70 guard   /   Kerf   /   Dent", 15)
    for row, pitch in enumerate((70, 55)):
        dent = atlas_cells(SOULS / f"view/p{pitch}/dent_sp_fly.png")
        path, info, status = sheets["fly", pitch]
        kerf = atlas_cells(path)
        factor = 86.4 / info["first_pose_median_height"]
        label(board, (10, 37+145*row), f"{pitch} deg   {status}", 13)
        for col, face in enumerate((0, 2, 4)):
            x, y = 5+col*273, 144+row*145
            label(board, (x+87, y+8), ("Toward","Profile","Away")[col], 13)
            guard = cop.crop((face*cw, 0, (face+1)*cw, cop.height))
            trio = [(guard, 32*1.15/cw, 26), (kerf[0,face], factor, 117),
                    (dent[0,face], 86.4/(223 if pitch==70 else 212), 223)]
            for cell, scale, cx in trio:
                tile = cell.resize(tuple(round(v*scale) for v in cell.size), FILTER)
                tile = tile.crop(tile.getbbox())
                board.paste(tile, (x+cx-tile.width//2, y-tile.height), tile)
    zoom = board.resize((board.width*3, board.height*3), Image.Resampling.NEAREST)
    combined = Image.new("RGB", (zoom.width, board.height+zoom.height+32), BACK)
    combined.paste(board)
    label(combined, (8, board.height+4), "3x nearest-neighbour")
    combined.paste(zoom, (0, board.height+32))
    combined.save(archive / "body_scale_32ppm.png")


def slot_board(archive, sheets, torso):
    panels = []
    for row, pitch in enumerate((70, 55)):
        path, info, _ = sheets["fly", pitch]
        cells = atlas_cells(path)
        for col, (face, direction) in enumerate(((0, "toward"), (4, "away"))):
            entry = next(e for e in info["cells"] if e["pose"] == 0 and e["facing"] == face)
            panels.append((cells[0, face], entry["slots"], f"{pitch} deg {direction} hover", col, row))
    panels.append((Image.open(RONIN / "torso.png"), torso["slots"], "Overhead torso", 2, 0))
    tiles = []
    for image, slots, caption, col, row in panels:
        x0, y0, x1, y1 = image.getbbox()
        tile = image.crop((x0, y0, x1, y1)).resize(((x1-x0)*2, (y1-y0)*2), Image.Resampling.NEAREST)
        pen = ImageDraw.Draw(tile)
        for cx, cy in slots:
            x, y = (cx-x0+0.5)*2-0.5, (cy-y0+0.5)*2-0.5
            pen.ellipse((x-8,y-8,x+8,y+8), outline="#ff612f", width=2)
            pen.point((x,y), fill="#ff612f")
        tiles.append((tile, caption, col, row))
    w = max(im.width for im, *_ in tiles) + 24
    h = max(im.height for im, *_ in tiles) + 68
    board = Image.new("RGB", (w*3, h*2), BACK)
    for im, caption, col, row in tiles:
        x, y = col*w+(w-im.width)//2, row*h
        label(board, (x,y+12), caption, 20)
        board.paste(im, (x,y+52), im)
    board.save(archive / "body_slots.png")


def rebuild(archive):
    masters = archive / "masters"
    torso = top_parts(masters / "kerf_sp_top_take1.png")
    sheets = {}
    metadata = {}
    for key, (take, scale, head) in SHEETS.items():
        kind, pitch = key.split("_")
        name = f"kerf_sp_{key}"
        master = masters / f"{name}_take{take}.png"
        output = SOULS / f"view/p{pitch}/kerf_sp_{kind}.png"
        info = pack(master, archive / f"cut/{master.stem}", output, scale, SLOT_SAMPLES[key], head)
        if kind == "fly":
            # Retain the original body anchor and charge landmarks beneath the far arm.
            add_far_blade(output, pitch)
        info.update(texture="res://" + output.relative_to(ROOT / "project").as_posix(),
                    master=f"n21/kerf/masters/{master.name}", scale=scale)
        metadata[name] = info
        sheets[kind, int(pitch)] = (output, info, f"take {take}")
    write_json(RONIN / "cut.json", {"schema": "gtai.kerf_ronin_cut/1",
                                     "sheets": metadata, "torso": torso})
    contact(archive, sheets)
    scale_board(archive, sheets)
    slot_board(archive, sheets, torso)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("archive", type=Path)
    rebuild(parser.parse_args().archive)
