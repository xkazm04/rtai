"""Pack the door carrier on its own common 2 m body scale. Keep the dropped slab on death."""
import argparse
import sys
from pathlib import Path

import numpy as np
from PIL import Image
from scipy import ndimage
from cast_pack import TOOLS, VIEW, check_cells, run
from street_walk import _bands
from street_hit import FOOT_Y


def cells(keyed, action):
    rgba = np.array(keyed)
    solid = rgba[:, :, 3] > 128
    poses = 3 if action == "fall" else 4
    rows = _bands(solid.sum(axis=1), 2 if action == "hit" else 5)
    for facing, (y0, y1) in enumerate(rows):
        count = (5 if facing == 0 else 3) if action == "hit" else poses
        bands = _bands(solid[y0:y1].sum(axis=0), count)
        for pose, (x0, x1) in enumerate(bands):
            crop = rgba[y0:y1, x0:x1].copy()
            labels, _ = ndimage.label(crop[:, :, 3] > 64)
            sizes = np.bincount(labels.ravel())
            keep = sizes >= max(sizes[1:]) * (0.05 if action == "fall" else 0.6)
            keep[0] = False
            crop[~ndimage.binary_dilation(keep[labels], iterations=1)] = 0
            # Remove residual yellow-green key on the hit sheet's short spark ticks.
            rgb = crop[:, :, :3].astype(int)
            spill = rgb[:, :, 1] - np.maximum(rgb[:, :, 0], rgb[:, :, 2])
            crop[spill > 18] = 0
            image = Image.fromarray(crop)
            image = image.crop(image.getbbox())
            if action == "hit":
                if facing == 0:
                    yield pose, 0, image
            else:
                yield facing, pose, image


def pack(folder, library, pitch, action):
    sys.path.insert(0, str(library))
    from sheetlib import key

    stem = "shield_robot_" + action
    source = folder / "out" / f"{stem}_{pitch}.png"
    keyed, _ = key(Image.open(source), "green")
    tiles = list(cells(keyed, action))
    rows = {"armed_walk": 4, "attack": 4, "fall": 3, "hit": 1}[action]
    # Scale each sheet once from the five first poses to keep attack/recoil motion intact.
    body = np.median([im.height for _, row, im in tiles if row == 0])
    scale = min(182 / body, 185 / max(im.height for _, _, im in tiles)) if action != "fall" else 172 / body
    scaled = [(f, r, im.resize((round(im.width*scale), round(im.height*scale)), Image.LANCZOS))
              for f, r, im in tiles]
    cw = max(im.width for _, _, im in scaled) + 10
    ch = 192 if action != "fall" else 2*(max(im.height for _, _, im in scaled)+5)
    grid = Image.new("RGBA", (5*cw, rows*ch))
    base = round(ch * (0.5 if action == "fall" else FOOT_Y))
    for f, r, im in scaled:
        dx = (cw-im.width)//2
        dy = base - im.height
        if action == "fall" and r > 0:
            dy = base - im.height//2
        grid.paste(im, (f*cw+dx, r*ch+dy))
    work = folder / "pack" / f"{stem}_{pitch}"
    work.mkdir(parents=True, exist_ok=True)
    grid.save(work/"grid.png")
    dest = VIEW / ("p"+pitch)
    run(TOOLS/"street_tone.py", work/"grid.png", dest/"cop_patrol_card.png", dest/(stem+".png"))
    check_cells(dest/(stem+".png"), rows)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("round", type=Path)
    parser.add_argument("library", type=Path)
    args = parser.parse_args()
    for tilt in ("70", "55"):
        for action in ("armed_walk", "attack", "hit", "fall"):
            pack(args.round, args.library, tilt, action)
