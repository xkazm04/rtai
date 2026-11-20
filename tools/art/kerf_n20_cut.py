"""Cut the Gantry Wraith's three accepted chroma masters, then pack the two hover grids.

Usage: py -3 -I tools/art/kerf_n20_cut.py <n20/kerf/masters>
Requires Pillow, NumPy and OpenCV. Paths below project/ are relative to this checkout.
The dark printed rules identify the green gutters even when generated rows drift.
Flood the sampled green field from the margin, then vent enclosed matching background
windows (socket, hose loops). Unmix green only at the black ink's exposed edge.
Crop with 2 px of clearance. Hover poses share their tilt's nozzle-to-tail scale
and sit on their alpha-weighted centres. Coordinates use the top-left pixel edge.
"""

import argparse
import hashlib
import json
import math
import statistics
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageOps

ART = Path(__file__).resolve().parents[2] / "project/features/souls/art"
PARTS = ("hull", "cables", "arm", "lens_open", "lens_half", "lens_slit")
FACINGS = ("toward", "three_quarter_toward", "profile", "three_quarter_away", "away")
MOODS = ("poised", "cruise", "lunge")
# Source pixel centres at the aftmost fitting and the nozzle tip in profile/cruise.
PROFILE = {70: ((341, 766), (617, 875)), 55: ((338, 785), (618, 860))}
KEY = np.array([0, 177, 64])
PAD = 2


def cell_spans(rgb, count):
    """Bound each interval by the green margins immediately inside its printed rules."""
    dark = (rgb[:, :, 1] < 145).mean(axis=1) > 0.93
    rules = np.flatnonzero(dark)
    groups = np.split(rules, np.where(np.diff(rules) > 6)[0] + 1)
    if len(groups) != count + 1 or any(not len(g) for g in groups):
        raise ValueError(f"Expected {count + 1} gutter rules, found {groups}")
    return [(int(a[-1]) + 4, int(b[0]) - 3) for a, b in zip(groups, groups[1:])]


def cut_cell(rgb):
    field = np.median(rgb[0], axis=0)
    if np.max(np.abs(field - KEY)) > 25:
        raise ValueError(f"Missing green margin, sampled {field}")
    distance = np.max(np.abs(rgb.astype(np.int16) - field), axis=2)
    eligible = (distance < 46).astype(np.uint8)
    # Add a common border so every side gets a flood seed.
    mask = np.pad(eligible, 1, constant_values=1)
    cv2.floodFill(mask, None, (0, 0), 2)
    mask = mask[1:-1, 1:-1].copy()
    # A hose or the socket can enclose green that the exterior flood cannot reach.
    # Grow each such window only from a patch matching the actual margin swatch.
    cores = ((mask == 1) & (distance < 13)).astype(np.uint8)
    n, labels, stats, _ = cv2.connectedComponentsWithStats(cores, connectivity=4)
    for i in range(1, n):
        if stats[i, cv2.CC_STAT_AREA] >= 3:
            y = stats[i, cv2.CC_STAT_TOP]
            x = np.flatnonzero(labels[y] == i)[0]
            if mask[y, x] == 1:
                cv2.floodFill(mask, None, (int(x), int(y)), 2)
    outside = (mask == 2).astype(np.uint8)
    rim = cv2.dilate(outside, np.ones((5, 5), np.uint8)) > outside
    r, g, b = rgb.astype(float).transpose(2, 0, 1)
    spill = np.clip((g - r) / (field[1] - field[0]), 0, 1)
    fringe = rim & (r < 45) & (abs(b - r - spill * (field[2] - field[0])) < 24)
    alpha = np.where(outside, 0, np.where(fringe, np.rint(255 * (1 - spill)), 255))
    rgba = np.dstack((rgb, alpha)).astype(np.uint8)
    rgba[fringe, :3] = np.clip(r[fringe], 0, 255).astype(np.uint8)[:, None]
    rgba[outside != 0] = 0
    return Image.fromarray(rgba)


def cut_sheet(path, rows):
    rgb = np.array(Image.open(path).convert("RGB"))
    xs = cell_spans(rgb.transpose(1, 0, 2), 3)
    ys = cell_spans(rgb, rows)
    cells = []
    for y, bottom in ys:
        for x, right in xs:
            # Top take 3 has one hose plugged into the hull. Its three fittings
            # meet the rear plate on the same ink seam at source y=125.
            top = 125 if rows == 2 and not cells else y
            im = cut_cell(rgb[y:bottom, x:right])
            im = im.crop((0, top - y, im.width, im.height))
            box = im.getbbox()
            if box is None or box[0] == 0 or box[2] == im.width or box[3] == im.height:
                raise ValueError(f"Empty or clipped figure at {x},{y} in {path.name}")
            cells.append(ImageOps.expand(im.crop(box), PAD, fill=(0, 0, 0, 0)))
    return cells


def legacy_height():
    im = Image.open(ART / "view/p70/kerf_run8.png").convert("RGBA")
    w, h = im.width // 8, im.height // 5
    heights = []
    for y in range(0, im.height, h):
        for x in range(0, im.width, w):
            box = im.crop((x, y, x + w, y + h)).getbbox()
            heights.append(box[3] - box[1])
    return statistics.median(heights)


def mass(im):
    a = np.asarray(im.getchannel("A"), dtype=float)
    return np.array([a.sum(0) @ (np.arange(im.width) + 0.5),
                     a.sum(1) @ (np.arange(im.height) + 0.5)]) / a.sum()


def pack(cells, tilt, ppm):
    scale = 1.5 * ppm / math.dist(*PROFILE[tilt])
    scaled = []
    for im in cells:
        # Resize premultiplied, retaining coverage in thin needles.
        tight = im.crop(im.getbbox())
        size = tuple(round(side * scale) for side in tight.size)
        scaled.append(tight.resize(size, Image.Resampling.LANCZOS))
    centres = [mass(im) for im in scaled]
    radii = [np.maximum(c, im.size - c) for im, c in zip(scaled, centres)]
    w, h = (2 * (np.ceil(np.max(radii, axis=0)).astype(int) + PAD)).tolist()
    sheet = Image.new("RGBA", (3 * w, 5 * h))
    entries = []
    for i, (src, im, c) in enumerate(zip(cells, scaled, centres)):
        row, col = divmod(i, 3)
        xy = np.rint([w / 2, h / 2] - c).astype(int)
        sheet.paste(im, (col * w + int(xy[0]), row * h + int(xy[1])))
        entries.append(dict(facing=FACINGS[row], mood=MOODS[col], cut_px=src.size,
                            scaled_px=im.size, origin_px=xy.tolist(),
                            alpha_mass_offset_px=(xy + c - [w / 2, h / 2]).round(6).tolist()))
    sheet.save(ART / f"view/p{tilt}/kerf_hover.png")
    return dict(cell_px=[w, h], sheet_px=sheet.size, master_scale=scale,
                profile_endpoints_px=PROFILE[tilt], cells=entries)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masters", type=Path)
    masters = parser.parse_args().masters
    dest = ART / "kerf/spectral"
    dest.mkdir(parents=True, exist_ok=True)
    old = legacy_height()
    meta = dict(_doc="Generated by kerf_n20_cut.py. DO NOT EDIT. Offsets are from cell centre, "
                     "in pixels, +x right and +y down.",
                schema="gtai.kerf_cut/1", old_grid="view/p70/kerf_run8.png",
                old_figure_m=1.8, old_median_px=old,
                px_per_m=old / 1.8, profile_cruise_m=1.5, pad_px=PAD, parts={}, hover={},
                master_sha256={})
    for name, rows in [("kerf_parts_top_take3", 2), ("kerf_hover_70_take1", 5),
                       ("kerf_hover_55_take1", 5)]:
        path = masters / (name + ".png")
        meta["master_sha256"][name] = hashlib.sha256(path.read_bytes()).hexdigest()
        cells = cut_sheet(path, rows)
        if rows == 5:
            tilt = int(name.split("_")[2])
            meta["hover"][f"p{tilt}"] = pack(cells, tilt, meta["px_per_m"])
            continue
        cells[0] = cells[0].transpose(Image.Transpose.ROTATE_90)
        for part, im in zip(PARTS, cells):
            im.save(dest / (part + ".png"))
            meta["parts"][part] = dict(cut_px=im.size,
                alpha_mass_offset_px=(mass(im) - np.array(im.size) / 2).round(6).tolist())
    (dest / "cut.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="utf-8", newline="\n")


if __name__ == "__main__":
    main()
