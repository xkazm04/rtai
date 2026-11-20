"""Compare eight drawn facings with the shipped five-row sheets at game scale.

python tools/art/ohm_n21_eight_cut.py --masters-root DIR --board-dir DIR
python tools/art/ohm_n21_eight_cut.py --masters-root DIR --ship-hover
The n21 manifest selects the raw takes. This writes review boards and the six
1536 x 1024 green sheets alongside them. Both use the same unmirrored silhouettes.
"""

import argparse
import hashlib
import json
import subprocess
from dataclasses import dataclass
from io import BytesIO
from pathlib import Path
from statistics import median

from PIL import Image, ImageDraw, ImageOps

import ohm_spectral_cut as cut


MANIFEST = cut.ROOT / "art_src/n21_polish_ohm.manifest.json"
BASELINE = "f8a634283"  # Five-row art used for all four director boards and height calibration.
FACINGS = (*cut.FACINGS, "away_left", "left", "toward_left")
# First and second rows of each pose in a 4x4 master, in source column order.
TURN_ROWS = ((1, 2, 3, 0), (7, 6, 5, 4))
GROUPS = (("Profile", 2, 6), ("Three-quarter toward", 1, 7),
          ("Three-quarter away", 3, 5), ("Straight toward / away", 0, 4))


@dataclass
class Frame:
    image: Image.Image
    x: int
    y: int
    height: int  # Broad coat height, excluding the narrow pole and wisps.

    def resized(self, factor):
        return Frame(cut.scaled(self.image, factor), round(self.x * factor),
                     round(self.y * factor), round(self.height * factor))

    def mirrored(self):
        return Frame(ImageOps.mirror(self.image), self.image.width - self.x, self.y, self.height)


def baseline_bytes(path):
    ref = f"{BASELINE}:{path.relative_to(cut.ROOT).as_posix()}"
    return subprocess.check_output(["git", "cat-file", "--filters", ref], cwd=cut.ROOT)


def shipped_frames(tilt, meta):
    folder = cut.ART / "view" / tilt
    frames = {}
    for name, sheet_meta in meta["sheets"].items():
        with Image.open(BytesIO(baseline_bytes(folder / f"ohm_spec_{name}.png"))) as body, \
                Image.open(BytesIO(baseline_bytes(folder / f"ohm_spec_{name}_jars.png"))) as mask:
            cols = sheet_meta["columns"]
            for row in range(len(meta["rows"])):
                for col, pose in enumerate(cols):
                    parts = [cut.grid_cell(im, len(cols), len(meta["rows"]), col, row)
                             for im in (body, mask)]
                    box = parts[0].getbbox()
                    _, top, bottom = cut.coat(parts[0].crop(box))
                    x, y = meta["anchor_px"]
                    im = cut.filled(*parts, 3).crop(box)
                    frames[row, pose] = Frame(im, x - box[0], y - box[1], bottom - top)
    return frames


def landscape_sheets(masters, tilt, dest):
    # The service chose the raw canvas dimensions. Use one uniform reduction across
    # the tilt, preserve aspect and give each figure its own 384 x 256 green cell.
    cells = [cell for page in masters for cell in page]
    factor = min(372 / max(cell.width for cell in cells), 244 / max(cell.height for cell in cells))
    for pair, page in zip("abc", masters):
        sheet = Image.new("RGB", (1536, 1024), "#00B140")
        for i, cell in enumerate(page):
            figure = cut.scaled(cell, factor)
            row, col = divmod(i, 4)
            pos = (col * 384 + (384 - figure.width) // 2, row * 256 + (256 - figure.height) // 2)
            sheet.paste(figure, pos, figure)
        sheet.save(dest / f"ohm_eight_{tilt}_{pair}_1536x1024.png")


def new_frames(masters, meta):
    frames = {}
    for pair, cells in enumerate(masters):
        for index, cell in enumerate(cells):
            row, col = divmod(index, 4)
            facing = TURN_ROWS[row % 2][col]
            pose = cut.POSES[2 * pair + row // 2]
            x, top, bottom = cut.coat(cell)
            # At full charge the three channels are the union of all visible windows.
            body, mask = cut.jars(cell, min(facing, 8 - facing))
            frames[facing, pose] = Frame(cut.filled(body, mask, 3), x, bottom, bottom - top)
    idle_height = median(frames[row, "idle"].height for row in range(8))
    scale = meta["legacy_median_height_px"] / idle_height
    return {key: frame.resized(scale) for key, frame in frames.items()}


def comparison_rows(group, old, new, cop):
    _, right, left = group
    for pose in cut.POSES:
        shipped = old[right, pose]
        other = shipped.mirrored() if right else old[left, pose]
        yield (shipped, new[right, pose], other, new[left, pose], cop)


def draw_group(canvas, pos, group, rows, layout):
    x, y = pos
    width, above, below = layout
    draw = ImageDraw.Draw(canvas)
    draw.text((x, y), group[0], fill="white")
    headings = (("Shipped R", "Drawn R", "Mirror L", "Drawn L") if group[1] else
                ("Shipped front", "Drawn front", "Shipped back", "Drawn back"))
    for col, label in enumerate((*headings, "Patrol")):
        draw.text((x + 64 + col * width + width // 2, y + 23), label, anchor="mt", fill="#ACC5C1")
    for i, frames in enumerate(rows):
        baseline = y + 48 + i * (above + below + 28) + above
        draw.text((x, baseline - above // 2), cut.POSES[i], fill="white")
        for col, frame in enumerate(frames):
            cx = x + 64 + col * width + width // 2
            canvas.paste(frame.image, (cx - frame.x, baseline - frame.y), frame.image)
            if col in (1, 3):
                difference = frame.height - frames[col - 1].height
                base = frames[col - 1].height
                draw.text((cx, baseline + below + 2), f"{difference/base:+.1%}", anchor="mt",
                          fill="#FFA373" if abs(difference) * 20 > base else "#ACC5C1")


def board(tilt, ppm, old, new, meta, dest):
    scale = meta["draw_scale_32ppm"] * ppm / 32
    # Keep the percentage based on calibrated art pixels, before display rounding.
    def display(frame):
        result = frame.resized(scale)
        result.height = frame.height
        return result

    old = {key: display(frame) for key, frame in old.items()}
    new = {key: display(frame) for key, frame in new.items()}
    with Image.open(cut.COP) as card:
        panels = []
        for group in GROUPS:
            guard = cut.grid_cell(card, 5, 1, group[1], 0).convert("RGBA")
            cop = Frame(guard, guard.width // 2, round(0.985 * guard.height), guard.height)
            panels.append(list(comparison_rows(group, old, new, cop.resized(ppm * 1.15 / guard.width))))
    frames = [frame for rows in panels for row in rows for frame in row]
    width = max(84, 8 + 2 * max(max(f.x, f.image.width - f.x) for f in frames))
    above = max(f.y for f in frames)
    below = max(f.image.height - f.y for f in frames)
    w, h = 78 + 5 * width, 50 + len(cut.POSES) * (above + below + 28)
    canvas = Image.new("RGB", (2 * w + 16, 2 * h + 62), cut.DARK)
    draw = ImageDraw.Draw(canvas)
    draw.text((10, 6), f"Ohm   /   {tilt}   /   {ppm} px/m   /   all visible jars charged", fill="white")
    draw.text((10, 25), "Drawn cells show coat height change from shipped. Orange exceeds 5%.", fill="#ACC5C1")
    for i, group in enumerate(GROUPS):
        draw_group(canvas, (10 + i % 2 * w, 56 + i // 2 * h), group, panels[i], (width, above, below))
    canvas.save(dest / f"ohm_eight_vs_shipped_{tilt}_{ppm}.png")


def anatomical_jars(cell, facing):
    if facing <= 4:
        return cut.jars(cell, facing)
    # The existing extractor indexes near/far windows on a right-facing view.
    # Reflect only for segmentation; on the left view the nearest jar is anatomical left.
    body, mask = cut.jars(ImageOps.mirror(cell), 8 - facing)
    r, g, b, a = ImageOps.mirror(mask).split()
    return ImageOps.mirror(body), Image.merge("RGBA", (b, g, r, a))


def coat_bounds(body):
    box = body.getbbox()
    x, top, bottom = cut.coat(body.crop(box))
    return x + box[0], bottom + box[1], bottom - top


def calibrated(body, target):
    _, _, height = coat_bounds(body)
    scale = target / height
    best = None
    for _ in range(6):
        resized = cut.scaled(body, scale)
        x, y, h = coat_bounds(resized)
        if best is None or abs(h - target) < abs(best[-1] - target):
            best = resized, x, y, h
        if h == target:
            break
        scale *= target / h
    if abs(best[-1] - target) > target * 0.05:
        raise ValueError(f"Coat height {best[-1]} outside tolerance of {target}")
    return best


def ship_hover(folder, meta, cells, old):
    width, height = meta["cell_px"]
    ax, ay = meta["anchor_px"]
    frames = []
    boxes, forks = [], []
    for facing, label in enumerate(FACINGS):
        for col, pose in enumerate(cut.POSES[:2]):
            source_row = int(facing in TURN_ROWS[1])
            source_col = TURN_ROWS[source_row].index(facing)
            cell = cells[(2 * col + source_row) * 4 + source_col]
            body, mask = anatomical_jars(cell, facing)
            target = old[min(facing, 8 - facing), pose].height
            body, x, y, h = calibrated(body, target)
            dx, dy = ax - x, ay - y
            if min(dx, dy) < cut.PAD:
                raise ValueError(f"{folder.name} {label} {pose}: invalid anchor")
            width = max(width, dx + body.width + cut.PAD)
            height = max(height, dy + body.height + cut.PAD)
            frames.append((body, cut.resize_mask(mask, body.size), (dx, dy)))
            print(f"{folder.name} {label:12s} {pose:5s} {target} -> {h} ({(h-target)/target:+.2%})")
    sheets = [Image.new("RGBA", (2 * width, 8 * height)) for _ in range(2)]
    for i, (body, mask, pos) in enumerate(frames):
        tile, glass = (Image.new("RGBA", (width, height)) for _ in range(2))
        tile.paste(body, pos)
        glass.paste(mask, pos)
        for sheet, part in zip(sheets, (tile, glass)):
            sheet.paste(part, (i % 2 * width, i // 2 * height))
        boxes.append([c.getbbox() for c in glass.split()[:3]])
        forks.append(cut.fork_points(tile))
    for sheet, suffix in zip(sheets, ("", "_jars")):
        sheet.save(folder / f"ohm_spec_hover{suffix}.png")
    meta["sheets"]["hover"].update(rows=FACINGS, cell_px=[width, height],
                                   jar_boxes_row_major=boxes, forks_row_major=forks)
    meta["sheets"]["act"].setdefault("rows", meta["rows"])
    cut.write_json(folder / "ohm_spec_cells.json", meta)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--masters-root", type=Path, required=True)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--board-dir", type=Path)
    mode.add_argument("--ship-hover", action="store_true")
    args = parser.parse_args()
    if args.board_dir:
        args.board_dir.mkdir(parents=True, exist_ok=True)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))["masters"]
    for tilt in ("p70", "p55"):
        paths = []
        for pair in ("a" if args.ship_hover else "abc"):
            entry = manifest[f"ohm_eight_{tilt}_{pair}"]
            path = args.masters_root / entry["file"].removeprefix("masters:")
            if hashlib.sha256(path.read_bytes()).hexdigest() != entry["sha256"]:
                raise ValueError(f"Master hash mismatch: {path}")
            paths.append(path)
        folder = cut.ART / "view" / tilt
        meta = json.loads(baseline_bytes(folder / "ohm_spec_cells.json"))
        old = shipped_frames(tilt, meta)
        masters = [cut.figures(path, 4, 4) for path in paths]
        if args.ship_hover:
            current = json.loads((folder / "ohm_spec_cells.json").read_text(encoding="utf-8"))
            ship_hover(folder, current, masters[0], old)
            continue
        landscape_sheets(masters, tilt, args.board_dir)
        new = new_frames(masters, meta)
        for ppm in (32, 64):
            board(tilt, ppm, old, new, meta, args.board_dir)
        diffs = []
        for (row, pose), frame in new.items():
            baseline = old[min(row, 8 - row), pose].height
            diffs.append((abs(frame.height - baseline) / baseline, row, pose))
        worst, row, pose = max(diffs)
        print(f"{tilt}: {sum(d > 0.05 for d, _, _ in diffs)}/48 exceed 5%; "
              f"largest {worst:.1%}, row {row}, {pose}")


if __name__ == "__main__":
    main()
