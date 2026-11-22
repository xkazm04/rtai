"""Pack a foes-n24 lancer sheet with the patrol cutters and navy reference.

python -B tools/art/cast_pack.py <round> <library/tools> <action> <pitch>
Review intermediates in the round's pack/ directory before recording provenance.
"""
import argparse
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

import street_hit

TOOLS = Path(__file__).resolve().parent
VIEW = TOOLS.parents[1] / "project/features/characters/art/view"

# Boot positions on the last drawing's BODY (the discarded tube is often wider).
# The patrol cutter assumes a forward dive. These bodies land on their backs.
REST_BOOTS = {
    "55": [(0.70, 0.95), (0.88, 0.96), (0.94, 0.72), (0.95, 0.65), (0.83, 0.94)],
    "70": [(0.51, 0.96), (0.10, 0.90), (0.95, 0.70), (0.96, 0.66), (0.50, 0.95)],
}


def register_boots(grid, action, pitch):
    im = Image.open(grid).convert("RGBA")
    rows = 3 if action == "fall" else 4
    w, h = im.width // 5, im.height // rows
    tiles = []
    for row in range(rows):
        for col in range(5):
            cell = im.crop((col*w, row*h, (col+1)*w, (row+1)*h))
            alpha = np.asarray(cell.getchannel("A"))
            solid = alpha > 128
            x, y = w//2, h//2
            if action == "fall" and row == 2:
                labels, count = ndimage.label(solid)
                body = max(range(1, count+1), key=np.bincount(labels.ravel()).__getitem__)
                ys, xs = np.nonzero(labels == body)
                u, v = REST_BOOTS[pitch][col]
                x = round(xs.min() + u * np.ptp(xs))
                y = round(ys.min() + v * np.ptp(ys))
            elif action != "fall":
                y = int(np.nonzero(solid.any(axis=1))[0][-1]) + 1
                if action == "attack":
                    box = cell.getchannel("A").getbbox()
                    x = round(box[0] + street_hit.foot_x(alpha[box[1]:box[3], box[0]:box[2]]))
            box = cell.getchannel("A").getbbox()
            tiles.append((cell.crop(box), x-box[0], y-box[1]))
    half_w = max(max(x, tile.width-x) for tile, x, _ in tiles) + 3
    cw = 2 * half_w
    ch = h
    baseline = round(h * street_hit.FOOT_Y)
    if action == "fall":
        baseline = max(max(y, tile.height-y) for tile, _, y in tiles) + 3
        ch = 2 * baseline
    result = Image.new("RGBA", (cw*5, ch*rows))
    for i, (tile, x, y) in enumerate(tiles):
        result.paste(tile, (cw*(i%5) + half_w-x, ch*(i//5) + baseline-y))
    result.save(grid)


def run(script, *args):
    subprocess.run([sys.executable, "-B", str(script), *map(str, args)], check=True)


def pack_hit(source, work, library, raw):
    run(library / "ghost_cells.py", source, work, "--bg=green", "--rows=5,3")
    files = [work / f"1_{col}.png" for col in range(1, 6)]
    scale = street_hit.CELL_H * street_hit.FILL / max(street_hit.cropped(f).height for f in files)
    grid = Image.new("RGBA", (street_hit.CELL_W * 5, street_hit.CELL_H))
    for col, file in enumerate(files):
        street_hit.cell(file, grid, col, scale)
    grid.save(raw)


def check_cells(grid, rows):
    with Image.open(grid) as image:
        pixels = np.asarray(image.convert("RGBA"), dtype=np.int16)
    height, width, _ = pixels.shape
    if height % rows or width % 5:
        raise ValueError(f"{grid}: expected five columns and {rows} equal rows")
    for row, cells in enumerate(np.split(pixels, rows)):
        for col, cell in enumerate(np.split(cells, 5, axis=1)):
            solid = cell[:, :, 3] > 127
            name = f"{grid}, row {row + 1}, facing {col + 1}"
            if not solid.any():
                raise ValueError(f"{name}: empty silhouette")
            if solid[[0, -1], :].any() or solid[:, [0, -1]].any():
                raise ValueError(f"{name}: opaque silhouette reaches the cell boundary")
            spill = cell[:, :, 1] - np.maximum(cell[:, :, 0], cell[:, :, 2])
            if (solid & (spill > 50)).any():
                raise ValueError(f"{name}: opaque green key spill")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    parser.add_argument("library", type=Path)
    parser.add_argument("action", choices=("armed_walk", "attack", "hit", "fall"))
    parser.add_argument("pitch", choices=("70", "55"))
    args = parser.parse_args()
    stem = f"rocket_trooper_{args.action}"
    name = f"{stem}_{args.pitch}"
    source = args.round / "out" / (name + ".png")
    work = args.round / "pack" / name
    work.mkdir(exist_ok=True, parents=True)
    raw = work / "grid.png"
    dest = VIEW / ("p" + args.pitch)
    if args.action == "hit":
        pack_hit(source, work, args.library, raw)
    else:
        sys.path.insert(0, str(args.library))
        from sheetlib import key

        rgba, _ = key(Image.open(source), "green")
        keyed = work / "keyed.png"
        rgba.save(keyed)
        cutter = "street_fall.py" if args.action == "fall" else "street_walk.py"
        run(TOOLS / cutter, keyed, raw)
        register_boots(raw, args.action, args.pitch)
    toned = work / "toned.png"
    run(TOOLS / "street_tone.py", raw, dest / "cop_patrol_card.png", toned)
    check_cells(toned, {"armed_walk": 4, "attack": 4, "hit": 1, "fall": 3}[args.action])
    shutil.copyfile(toned, dest / (stem + ".png"))


if __name__ == "__main__":
    main()
