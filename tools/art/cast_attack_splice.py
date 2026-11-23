"""Register the two rear lancer facings to the shipped grid, leaving the front three intact."""
import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage

from cast_pack import TOOLS, VIEW, check_cells, run
from street_hit import foot_x


def solid_box(image):
    return image.getchannel("A").point(lambda a: 255 if a > 128 else 0).getbbox()


def figure(image):
    """Remove the tiny key speckles outside the drawing before measuring the boots."""
    arr = np.array(image)
    labels, _ = ndimage.label(arr[:, :, 3] > 60)
    sizes = np.bincount(labels.ravel())
    mask = labels == sizes[1:].argmax() + 1
    arr[~ndimage.binary_dilation(mask, iterations=2)] = 0
    result = Image.fromarray(arr)
    return result.crop(solid_box(result))


def splice(pitch, folder, library):
    sys.path.insert(0, str(library))
    from sheetlib import key

    path = VIEW / ("p" + pitch) / "rocket_trooper_attack.png"
    work = folder / "pack" / ("attack_splice_" + pitch)
    work.mkdir(parents=True, exist_ok=True)
    original = work / "original.png"
    if not original.exists():
        original.write_bytes(path.read_bytes())
    grid = Image.open(original).convert("RGBA")
    cw, ch = grid.width // 5, grid.height // 4
    source = folder / "out" / f"rocket_trooper_attack_{pitch}_v3.png"
    sheet, _ = key(Image.open(source), "green")
    sheet.save(work / "keyed.png")
    run(TOOLS / "street_tone.py", work / "keyed.png", path.parent / "cop_patrol_card.png",
        work / "toned.png")
    source = Image.open(work / "toned.png")
    for row in range(4):
        for col in (3, 4):
            x, y = cw * col, ch * row
            old = grid.crop((x, y, x+cw, y+ch))
            left, top, right, base = solid_box(old)
            target = source.crop((round(col*source.width/5), max(0, round(row*source.height/4)-10),
                                  round((col+1)*source.width/5), min(source.height, round((row+1)*source.height/4)+10)))
            tile = figure(target)
            height = base - top
            tile = tile.resize((round(tile.width * height / tile.height), height), Image.LANCZOS)
            anchor = round(left + foot_x(np.asarray(old)[top:base, left:right, 3]))
            offset = round(anchor - foot_x(np.asarray(tile)[:, :, 3]))
            if offset < 0 or offset+tile.width > cw:
                raise ValueError(f"{row}/{col} cannot fit in original cell")
            grid.paste((0, 0, 0, 0), (x, y, x+cw, y+ch))
            grid.paste(tile, (x+offset, y+top))
            print(f"p{pitch} row {row+1} col {col+1}: {cw}x{ch}, height {height}, baseline {base}")
    grid.save(path)
    check_cells(path, 4)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    parser.add_argument("library", type=Path)
    args = parser.parse_args()
    for tilt in ("70", "55"):
        splice(tilt, args.round, args.library)
