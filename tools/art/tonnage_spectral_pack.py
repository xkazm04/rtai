"""Pack a 4 x 5 Press Golem master. For attacks, supply the packed pose with --pose."""

import argparse
from pathlib import Path
from statistics import median

import numpy as np
from PIL import Image
from scipy import ndimage as ndi

from tonnage_spectral_parts import keyed_image


COLS, ROWS = 4, 5
WIDTH, HEIGHT = 384, 320
BASELINE = HEIGHT - 5  # Inclusive last opaque row in cell coordinates.


def figures(master):
    """Find whole silhouettes before assigning cells, even on an unevenly spaced grid."""
    alpha = np.asarray(master.getchannel("A"))
    labels, _ = ndi.label(alpha > 0, structure=np.ones((3, 3)))
    cells = {}
    for label, region in enumerate(ndi.find_objects(labels), start=1):
        y, x = region
        w, h = x.stop - x.start, y.stop - y.start
        if w < 50 or h < 50 or w > master.width * 0.45 or h > master.height * 0.35:
            continue  # Specks and full-sheet rules.
        row = (y.start + y.stop) * ROWS // (2 * master.height)
        col = (x.start + x.stop) * COLS // (2 * master.width)
        if (row, col) in cells:
            raise ValueError(f"Two figures in row {row + 1}, column {col + 1}")
        box = (x.start, y.start, x.stop, y.stop)
        fig = master.crop(box)
        fig.putalpha(Image.fromarray(np.where(labels[region] == label, alpha[region], 0)))
        cells[row, col] = fig
    if len(cells) != ROWS * COLS:
        raise ValueError(f"Expected 20 silhouettes, found {len(cells)}")
    return cells


def pose_carry(path):
    pose = Image.open(path).convert("RGBA")
    if pose.size != (WIDTH * COLS, HEIGHT * ROWS):
        raise ValueError("Pose sheet must use the same cell size")
    result = []
    for row in range(ROWS):
        cell = pose.crop((0, row * HEIGHT, WIDTH, (row + 1) * HEIGHT))
        result.append(cell.crop(cell.getbbox()))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("master", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--pose", type=Path)
    parser.add_argument("--contact", type=Path)
    args = parser.parse_args()
    cells = figures(keyed_image(args.master))
    carry = pose_carry(args.pose) if args.pose else []
    carry_col = COLS - 1 if carry else 0
    target = median(im.height for im in carry) if carry else 220
    scale = target / median(cells[r, carry_col].height for r in range(ROWS))
    sheet = Image.new("RGBA", (COLS * WIDTH, ROWS * HEIGHT))
    heights = []
    for (row, col), im in cells.items():
        if carry and col == carry_col:
            fig = carry[row]  # The recovery loop returns to the exact pose sprite.
        else:
            size = (round(im.width * scale), round(im.height * scale))
            fig = im.resize(size, Image.Resampling.LANCZOS)
            fig = fig.crop(fig.getbbox())
        x = (WIDTH - fig.width) // 2
        y = BASELINE + 1 - fig.height
        if min(x, y) < 4:
            raise ValueError(f"Figure {row + 1},{col + 1} exceeds cell budget")
        sheet.paste(fig, (col * WIDTH + x, row * HEIGHT + y))
        heights.append(fig.height)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output)
    if args.contact:
        bg = Image.new("RGB", sheet.size, "#808080")
        bg.paste(sheet, mask=sheet.getchannel("A"))
        bg.save(args.contact)
    print(f"cell {WIDTH} x {HEIGHT}, fig_px {median(heights):g}, bottom-anchor y {BASELINE}, "
          f"carry height {target:g}, scale {scale:.6f}")


if __name__ == "__main__":
    main()
