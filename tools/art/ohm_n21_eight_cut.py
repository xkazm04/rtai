"""Compare eight drawn facings with the shipped five-row sheets at game scale.

python tools/art/ohm_n21_eight_cut.py --masters-root DIR --board-dir DIR
The n21 manifest selects the raw takes. This writes review boards and the six
1536 x 1024 green sheets alongside them. Both use the same unmirrored silhouettes.
"""

import argparse
import hashlib
import json
from dataclasses import dataclass
from pathlib import Path
from statistics import median

from PIL import Image, ImageDraw, ImageOps

import ohm_spectral_cut as cut


MANIFEST = cut.ROOT / "art_src/n21_polish_ohm.manifest.json"
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


def shipped_frames(tilt, meta):
    folder = cut.ART / "view" / tilt
    frames = {}
    for name, sheet_meta in meta["sheets"].items():
        with Image.open(folder / f"ohm_spec_{name}.png") as body, \
                Image.open(folder / f"ohm_spec_{name}_jars.png") as mask:
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


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--masters-root", type=Path, required=True)
    parser.add_argument("--board-dir", type=Path, required=True)
    args = parser.parse_args()
    args.board_dir.mkdir(parents=True, exist_ok=True)
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))["masters"]
    for tilt in ("p70", "p55"):
        paths = []
        for pair in "abc":
            entry = manifest[f"ohm_eight_{tilt}_{pair}"]
            path = args.masters_root / entry["file"].removeprefix("masters:")
            if hashlib.sha256(path.read_bytes()).hexdigest() != entry["sha256"]:
                raise ValueError(f"Master hash mismatch: {path}")
            paths.append(path)
        meta = json.loads((cut.ART / "view" / tilt / "ohm_spec_cells.json").read_text())
        old = shipped_frames(tilt, meta)
        masters = [cut.figures(path, 4, 4) for path in paths]
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
