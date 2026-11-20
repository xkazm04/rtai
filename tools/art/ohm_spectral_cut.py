"""Rebuild Ohm's body art from the three accepted PNGs and the shipped walk sheets.

python tools/art/ohm_spectral_cut.py MASTER_P70 MASTER_P55 MASTER_TOP --preview-dir DIR
Coordinates in the JSONs are image pixels, origin top left. Boxes exclude right/bottom.
"""

import argparse
import json
import math
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFilter
from scipy import ndimage as ndi

from ghost_pack import PAD
from ghost_parts import key

ROOT = Path(__file__).resolve().parents[2]
ART = ROOT / "project/features/souls/art"
COP = ROOT / "project/features/characters/art/view/p70/cop_patrol_card.png"
POSES = ("idle", "drift", "charged", "thrust", "recovery", "struck")
FACINGS = ("toward", "toward_right", "right", "away_right", "away")
PARTS = ("body", "hem", "staff", "arm_staff", "arm_free", "beard")
DARK = "#1B1F24"


def figures(path, rows, cols):
    """Identify whole connected figures before assigning a facing or pose to any pixel."""
    rgb = np.array(Image.open(path).convert("RGB"))
    _, alpha = key(rgb)
    # The outside of each silhouette is black ink. Unmix the actual green screen
    # from that rim (also around the holes) without changing the spectral teal inside.
    edge = ndi.binary_dilation(alpha < 0.03, iterations=3)
    screen = np.median(rgb[alpha < 0.03], axis=0)
    pixels = rgb.astype(float)
    spill = (pixels[..., 1] - pixels[..., 2]) / (screen[1] - screen[2])
    spill = np.where(edge, np.clip(spill, 0, 1), 0)
    spill[alpha < 0.03] = 1
    rgb = (pixels - spill[..., None] * screen) / np.maximum(1 - spill[..., None], 0.001)
    rgba = np.dstack([rgb, (1 - spill) * 255]).clip(0, 255).round().astype("uint8")
    labels, count = ndi.label(rgba[..., 3] > 64, np.ones((3, 3)))
    areas = np.bincount(labels.ravel(), minlength=count + 1)
    main = np.argsort(areas[1:])[-rows * cols:] + 1
    if len(main) != rows * cols or areas[main].min() < 0.08 * np.median(areas[main]):
        raise ValueError(f"{path}: cannot identify {rows * cols} separate main silhouettes")
    centers = ndi.center_of_mass(rgba[..., 3], labels, main)
    ordered = sorted(zip(centers, main), key=lambda item: item[0][0])
    seeds = np.where(np.isin(labels, main), labels, 0)
    dist, nearest = ndi.distance_transform_edt(seeds == 0, return_indices=True)
    owner = seeds[tuple(nearest)]
    # Keep detached ink/wisps with their closest figure. Reject remote screen noise.
    owner[(dist > 0.08 * min(rgba.shape[0] / rows, rgba.shape[1] / cols)) |
          (rgba[..., 3] == 0)] = 0
    boxes = ndi.find_objects(owner)
    cells = []
    for row in range(rows):
        group = sorted(ordered[row * cols:(row + 1) * cols], key=lambda item: item[0][1])
        for _, label in group:
            box = boxes[label - 1]
            cell = rgba[box].copy()
            cell[owner[box] != label] = 0
            cells.append(Image.fromarray(cell))
    return cells


def jars(image, facing):
    """Extract coverage before resampling. Number jars from anatomical left to right."""
    pixels = np.array(image)
    red, green, blue = pixels[..., :3].astype(float).transpose(2, 0, 1)
    chroma = np.minimum(red, blue) - green
    # Pick saturated cores first: the low-coverage edges of adjacent cylinders
    # sometimes touch across a one-pixel ink rim.
    labels, count = ndi.label((chroma > 70) & (pixels[..., 3] > 0))
    areas = np.bincount(labels.ravel(), minlength=count + 1)
    blobs = [i for i in np.argsort(areas[1:])[::-1] + 1 if areas[i] >= 3]
    # A hose highlight can exceed the tiny visible sliver of an occluded jar.
    # Where two clear windows establish the jar bank, drop flecks off that axis.
    if len(blobs) > 3 and areas[blobs[2]] < areas[blobs[1]] * 0.25:
        pts = np.array(ndi.center_of_mass(chroma, labels, blobs))
        delta = pts[1] - pts[0]
        normal = np.array([-delta[1], delta[0]]) / np.linalg.norm(delta)
        radius = math.sqrt(areas[blobs[1]] / math.pi)
        blobs = [b for b, p in zip(blobs, pts) if abs((p - pts[0]) @ normal) < radius]
    blobs = blobs[:3]
    centers = ndi.center_of_mass(chroma, labels, blobs) if blobs else []
    # Screen direction from jar 1 to 3: toward = left, right profile = down,
    # away = right. The straight-down rig faces +x so anatomical right is +y.
    dx, dy = ((-1, 0), (-1, 0.7), (0, 1), (0, 1), (1, 0), (0, 1))[facing]
    ordered = sorted(zip(centers, blobs), key=lambda item: item[0][1] * dx + item[0][0] * dy)
    mask = np.zeros_like(pixels)
    glass = np.array([11, 38, 36])
    if blobs:
        distance, nearest = ndi.distance_transform_edt(~np.isin(labels, blobs), return_indices=True)
        owner = labels[tuple(nearest)]
    for channel, (_, blob) in zip(visible_channels(facing, ordered), ordered):
        use = (owner == blob) & (distance <= 3) & (chroma > 8) & (pixels[..., 3] > 0)
        # Saturate the flat window interior despite small print/compression variations.
        full = 0.86 * np.percentile(chroma[labels == blob], 65)
        coverage = np.clip(chroma[use] / full, 0, 1)
        mask[use, channel] = np.rint(coverage * 255)
    # Also clear subpixel magenta flecks left by ink/hatching in the glass.
    use = (chroma > 0) & (pixels[..., 3] > 0)
    use &= ndi.binary_dilation(chroma > 22, iterations=2)
    weight = np.clip(chroma[use] / 235, 0, 1)
    neutral = np.minimum(pixels[use, :3], green[use, None] + 1)
    pixels[use, :3] = np.rint(neutral * (1 - weight[:, None]) + glass * weight[:, None])
    pixels[use, 3] = np.rint(pixels[use, 3] * (1 - weight) + 200 * weight)
    mask[..., 3] = np.where(mask[..., :3].any(axis=2), 255, 0)
    return Image.fromarray(pixels), Image.fromarray(mask)


def visible_channels(facing, ordered):
    if len(ordered) == 3:
        return range(3)
    # In a right-facing view, the far (left) jar disappears behind the nearer pair.
    # Front-on, a central jar can disappear behind the hood, leaving the outside pair.
    # Away-right recovery on the p70 master exposes the far and near ends,
    # with the middle window hidden by their overlapping rims.
    if facing in (0, 3) and len(ordered) == 2:
        return (0, 2)
    return range(3 - len(ordered), 3)


def coat(image):
    """Find the broad torso/coat. The thin staff and tapering wisps do not set its height."""
    solid = np.array(image.getchannel("A")) > 110
    radius = max(3, round(min(image.size) * 0.047))
    yy, xx = np.ogrid[-radius:radius + 1, -radius:radius + 1]
    broad = ndi.binary_opening(solid, structure=xx * xx + yy * yy <= radius * radius)
    lab, _ = ndi.label(broad)
    core = lab == np.argmax(np.bincount(lab.ravel())[1:]) + 1
    widths = core.sum(axis=1)
    ys = np.flatnonzero(widths >= 0.28 * widths.max())
    return round(float(np.median(np.nonzero(core)[1]))), int(ys[0]), int(ys[-1] + 1)


def grid_cell(sheet, cols, rows, col, row):
    w, h = sheet.width // cols, sheet.height // rows
    return sheet.crop((col * w, row * h, (col + 1) * w, (row + 1) * h))


def scaled(image, scale, resample=Image.Resampling.LANCZOS):
    return image.resize(tuple(max(1, round(v * scale)) for v in image.size), resample)


def resize_mask(mask, size):
    # RGB stores coverage, including the edge. Alpha is presence, never a second coverage.
    channels = [c.resize(size, Image.Resampling.BILINEAR) for c in mask.split()[:3]]
    alpha = Image.fromarray(np.maximum.reduce([np.array(c) for c in channels]) > 0).convert("L")
    return Image.merge("RGBA", (*channels, alpha))


def write_json(path, data):
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8", newline="\n")


def fork_points(tile):
    """Fit both copper tines together. The distal end opens into air, the base into the pole."""
    rgba = np.asarray(tile, dtype=float)
    red, green, blue, alpha = rgba.transpose(2, 0, 1)
    copper = (red > 1.19 * green) & (green > 1.15 * blue) & (red - blue > 55) & (alpha > 110)
    solid = ndi.binary_closing(copper, structure=np.ones((3, 3)))
    labels, count = ndi.label(solid, structure=np.ones((3, 3)))
    if count < 2:
        raise ValueError("expected two separate copper tines")
    areas = np.bincount(labels.ravel())[1:]
    blobs = [np.column_stack(np.nonzero(labels == i + 1)[::-1]) for i in np.argsort(areas)[-2:]]
    # A joint principal axis stays stable even when one tine is partly foreshortened.
    centred = np.concatenate([blob - blob.mean(axis=0) for blob in blobs])
    axis = np.linalg.eigh(centred.T @ centred)[1][:, -1]
    centre = np.mean([blob.mean(axis=0) for blob in blobs], axis=0)
    normal = np.array([-axis[1], axis[0]])
    relative = np.concatenate(blobs) - centre
    extent = relative @ axis
    width = max(abs(relative @ normal))

    def occupancy(sign):
        end = extent.max() if sign > 0 else extent.min()
        along = end + sign * np.linspace(2, max(5, np.ptp(extent) * 0.8), 12)
        across = np.linspace(-width, width, 11)
        samples = centre + along[:, None, None] * axis + across[None, :, None] * normal
        return ndi.map_coordinates(alpha, samples.transpose(2, 0, 1)[::-1], order=1).sum()

    if occupancy(-1) < occupancy(1):
        axis = -axis
    tips = []
    for blob in blobs:
        reach = blob @ axis
        cap = blob[reach >= reach.max() - 1.5]
        # Coordinates are continuous cell pixels, measured at the centres of the end-cap texels.
        tips.append((cap.mean(axis=0) + 0.5).round(2).tolist())
    tips.sort()
    return dict(fork_px=np.mean(tips, axis=0).round(3).tolist(), prongs_px=tips)


def cut_tilt(master, pitch):
    folder = ART / "view" / pitch
    old = Image.open(folder / "ohm_walk8.png").convert("RGBA")
    heights = []
    for row in range(5):
        for col in range(8):
            box = grid_cell(old, 8, 5, col, row).getbbox()
            heights.append(box[3] - box[1])
    cells = figures(master, 5, 6)
    core = [coat(cell) for cell in cells]
    target = float(np.median(heights))
    scale = target / float(np.median([bottom - top for _, top, bottom in core[::6]]))
    cut = []
    for i, (cell, (x, _, bottom)) in enumerate(zip(cells, core)):
        body, mask = jars(cell, i // 6)
        body = scaled(body, scale)
        cut.append((body, resize_mask(mask, body.size), round(x * scale), round(bottom * scale)))
    half = PAD + max(max(x, im.width - x) for im, _, x, _ in cut)
    ay = PAD + max(y for _, _, _, y in cut)
    size = (2 * half, ay + max(im.height - y for im, _, _, y in cut) + PAD)
    meta = dict(cell_px=size, anchor_px=[half, ay], scale=scale, legacy_median_height_px=target,
                draw_scale_32ppm=draw_scale(), rows=FACINGS, bbox_format="xyxy_exclusive",
                jar_channels=["left", "middle", "right"], sheets={})
    packed = {}
    for name, cols in (("hover", (0, 1)), ("act", (2, 3, 4, 5))):
        sheets = [Image.new("RGBA", (size[0] * len(cols), size[1] * 5)) for _ in range(2)]
        frames = []
        forks = []
        for row in range(5):
            for j, col in enumerate(cols):
                body, mask, x, y = cut[row * 6 + col]
                tile, jars_tile = (Image.new("RGBA", size) for _ in range(2))
                for sheet, dest, src in zip(sheets, (tile, jars_tile), (body, mask)):
                    dest.paste(src, (half - x, ay - y))
                    sheet.paste(dest, (j * size[0], row * size[1]))
                boxes = [ch.getbbox() for ch in jars_tile.split()[:3]]
                frames.append(boxes)
                forks.append(fork_points(tile))
                packed[row, col] = tile, jars_tile
        for sheet, suffix in zip(sheets, ("", "_jars")):
            sheet.save(folder / f"ohm_spec_{name}{suffix}.png")
        meta["sheets"][name] = dict(columns=[POSES[c] for c in cols], jar_boxes_row_major=frames,
                                    forks_row_major=forks)
    write_json(folder / "ohm_spec_cells.json", meta)
    return packed, meta


def draw_scale():
    # OhmRig's fully unfolded, neutral-breath GhostDrawn height / reference height.
    player_k = json.loads((ROOT / "project/data/tables/player_scale.json").read_text())["k"]
    return 32 * 1.55 * player_k / 180


def cut_top(master):
    folder = ART / "ohm/spectral"
    folder.mkdir(exist_ok=True)
    parts = {}
    # Fractions of each tight silhouette: torso centre, coat collar, pole grip,
    # pauldron centres and beard mounting plate. All lengths retain the master scale.
    pivots = ((0.5, 0.5), (0.96, 0.5), (0.39, 0.5),
              (0.17, 0.48), (0.16, 0.50), (0.07, 0.50))
    meta = dict(front="+x", scale=1, parts={}, body_jars=[])
    for name, cell, pivot in zip(PARTS, figures(master, 2, 3), pivots):
        body, mask = jars(cell, 5) if name == "body" else (cell, Image.new("RGBA", cell.size))
        size = tuple(v + 2 * PAD for v in body.size)
        tile, jars_tile = (Image.new("RGBA", size) for _ in range(2))
        tile.paste(body, (PAD, PAD))
        jars_tile.paste(mask, (PAD, PAD))
        tile.save(folder / f"{name}.png")
        parts[name] = tile, jars_tile
        meta["parts"][name] = dict(size_px=size,
                                   pivot_px=[PAD + round(f * v) for f, v in zip(pivot, body.size)])
        if name == "staff":
            meta["parts"][name].update(fork_points(tile))
        if name == "body":
            jars_tile.save(folder / "body_jars.png")
            for c in jars_tile.split()[:3]:
                if c.getbbox() is None:
                    raise ValueError(f"{master}: expected three visible jar circles on the body")
                weights = np.array(c) / 255
                y, x = ndi.center_of_mass(weights)
                meta["body_jars"].append(dict(center_px=[round(x, 2), round(y, 2)],
                                              radius_px=round(math.sqrt(weights.sum() / math.pi), 2)))
            meta["body_long_side_m"] = 0.8  # OhmRig.SHELL_M
            meta["texels_per_m"] = max(body.size) / meta["body_long_side_m"]
    write_json(folder / "parts.json", meta)
    return parts


def filled(body, mask, level):
    if level == 0:
        return body
    color = "#FFB000" if level == 4 else "#2EC4B6"
    coverage = np.maximum.reduce([np.array(c) for c in mask.split()[:min(level, 3)]])
    fill = Image.new("RGBA", body.size, color)
    fill.putalpha(Image.fromarray(coverage))
    light = Image.new("RGBA", body.size, color)
    light.putalpha(Image.fromarray(coverage).filter(ImageFilter.GaussianBlur(3)).point(lambda a: a // 3))
    return Image.alpha_composite(Image.alpha_composite(body, light), fill)


def preview(tilts, parts, dest):
    # Facing / pose down the page; both pitches have their own five charge columns.
    w, h, label, header = 122, 104, 112, 51
    canvas = Image.new("RGB", (label + 10 * w + 12, header + 36 * h + 32), DARK)
    draw = ImageDraw.Draw(canvas)
    for group, pitch in enumerate(tilts):
        start = label + group * (5 * w + 12)
        draw.text((start, 5), pitch.upper(), fill="white")
        for j, title in enumerate(("Empty", "Jar 1", "Jars 1+2", "Full", "Full amber")):
            draw.text((start + j * w, 28), title, fill="#ACC5C1")
        cells, _ = tilts[pitch]
        factor = min((w - 4) / cells[0, 0][0].width, (h - 4) / cells[0, 0][0].height)
        for (row, col), pair in cells.items():
            y = header + (6 * row + col) * h
            if group == 0:
                if col == 0:
                    draw.text((5, y + 12), FACINGS[row], fill="white")
                draw.text((5, y + 35), POSES[col], fill="#ACC5C1")
            for level in range(5):
                im = scaled(filled(*pair, level), factor)
                x = start + level * w + (w - im.width) // 2
                canvas.paste(im, (x, y + (h - im.height) // 2), im)
    start = header + 30 * h + 30
    draw.text((5, start - 24), "Straight down", fill="white")
    for level, title in enumerate(("Empty", "Jar 1", "Jars 1+2", "Full", "Full amber")):
        draw.text((label + level * 2 * w, start - 24), title, fill="#ACC5C1")
    factor = min(min((2*w-5) / p.width, (h-4) / p.height) for p, _ in parts.values())
    for i, (name, pair) in enumerate(parts.items()):
        y = start + i * h
        draw.text((5, y + 35), name, fill="#ACC5C1")
        for level in range(5):
            im = scaled(filled(*pair, level), factor)
            x = label + level * 2 * w + (2 * w - im.width) // 2
            canvas.paste(im, (x, y + (h - im.height) // 2), im)
    canvas.save(dest / "body_preview.png")


def guard_preview(tilt, dest):
    packed, meta = tilt
    old = Image.open(ART / "view/p70/ohm_walk8.png").convert("RGBA")
    cop = Image.open(COP).convert("RGBA")
    s = draw_scale()
    cop_scale = 32 * 1.15 / (cop.width / 5)  # StreetQuestCards.WIDTH_M
    strip = Image.new("RGB", (254, 125 * 5), DARK)
    for row in range(5):
        new = filled(*packed[row, 0], 3)
        legacy = grid_cell(old, 8, 5, 2, row)  # GhostDrawn.STAND_COL
        guard = grid_cell(cop, 5, 1, row, 0)
        baseline = row * 125 + 98
        for x, im, factor, anchor_y in ((49, new, s, meta["anchor_px"][1]),
                                         (135, guard, cop_scale, 0.985 * guard.height),
                                         (210, legacy, s, legacy.height - PAD)):
            im = scaled(im, factor)
            strip.paste(im, (round(x - im.width/2), baseline - round(anchor_y * factor)), im)
    canvas = Image.new("RGB", (3 * strip.width + 130, 2 * strip.height + 62), DARK)
    draw = ImageDraw.Draw(canvas)
    for start, factor in ((100, 1), (strip.width + 120, 2)):
        draw.text((start, 5), "32 px/m" if factor == 1 else "2x nearest neighbour", fill="white")
        for x, name in ((30, "Spectral"), (116, "Patrol"), (193, "Legacy")):
            draw.text((start + x * factor, 28), name, fill="#ACC5C1")
        for row, facing in enumerate(FACINGS):
            panel = strip.crop((0, row * 125, strip.width, (row + 1) * 125))
            panel = scaled(panel, factor, Image.Resampling.NEAREST)
            y = 52 + row * 250
            canvas.paste(panel, (start, y + 196 - 98 * factor))
            draw.text((4, y + 184), facing, fill="#ACC5C1")
    canvas.save(dest / "body_32ppm_guard.png")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("p70", "p55", "top"):
        parser.add_argument(name, type=Path)
    parser.add_argument("--preview-dir", type=Path, required=True)
    args = parser.parse_args()
    tilts = {pitch: cut_tilt(getattr(args, pitch), pitch) for pitch in ("p70", "p55")}
    parts = cut_top(args.top)
    args.preview_dir.mkdir(exist_ok=True, parents=True)
    preview(tilts, parts, args.preview_dir)
    guard_preview(tilts["p70"], args.preview_dir)
    for pitch, (packed, meta) in tilts.items():
        print(pitch, "cell", meta["cell_px"], "anchor", meta["anchor_px"], "scale", meta["scale"])
        for row in range(5):
            print(FACINGS[row], [sum(bool(c.getbbox()) for c in packed[row, col][1].split()[:3])
                                 for col in range(6)])
    print("top body:", sum(bool(c.getbbox()) for c in parts["body"][1].split()[:3]), "jars")


if __name__ == "__main__":
    main()
