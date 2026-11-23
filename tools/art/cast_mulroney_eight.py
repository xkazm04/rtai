"""Pack the director's two eight-pose sheets at the shipped sergeant's scale."""
import argparse
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_patrol_eight import CELL, FOOT, figures, review
from cast_soles import VIEW, body_point, bounds


def pack(folder, pitch):
    work = folder / "pack"
    work.mkdir(exist_ok=True)
    stem = f"mul8_armed_walk_{pitch}"
    strips = [*figures(folder / "out" / f"{stem}_a.png", 3),
              *figures(folder / "out" / f"{stem}_b.png", 2)]
    view = VIEW / f"p{pitch}"
    reference = view / "sergeant_mulroney_armed_walk.png"
    old = np.asarray(Image.open(reference))[:, :, 3] > 128
    grid = Image.new("RGBA", (5 * CELL[0], 8 * CELL[1]))
    for col, strip in enumerate(strips):
        heights = [bounds(frame)[3] - bounds(frame)[1]
                   for frame in np.vsplit(np.hsplit(old, 5)[col], 4)]
        factor = np.mean(heights) / np.mean([im.height for im in strip])
        tiles = [im.resize(tuple(round(v * factor) for v in im.size), Image.Resampling.LANCZOS)
                 for im in strip]
        bodies = [body_point(np.asarray(im)[:, :, 3] > 128) for im in tiles]
        body_y = FOOT - np.mean([im.height - pt[1] for im, pt in zip(tiles, bodies)])
        for row, (im, pt) in enumerate(zip(tiles, bodies)):
            x, y = np.rint([CELL[0] / 2 - pt[0], body_y - pt[1]]).astype(int)
            if min(x, y) < 0 or x + im.width > CELL[0] or y + im.height > CELL[1]:
                raise ValueError(f"clipped figure at {col},{row}")
            grid.paste(im, (col * CELL[0] + x, row * CELL[1] + y))
    raw = work / f"{stem}_cut.png"
    grid.save(raw)
    dest = view / "sergeant_mulroney_planted8_armed_walk.png"
    subprocess.run([sys.executable, str(Path(__file__).with_name("street_tone.py")),
                    str(raw), str(reference), str(dest)], check=True)
    r, g, b, a = np.asarray(Image.open(dest), dtype=int).transpose(2, 0, 1)
    if np.any((a >= 128) & ((g - np.maximum(r, b) > 50) | (np.minimum(r, b) - g > 50))):
        raise ValueError("opaque key pixels")
    review(dest, work / f"review_{pitch}.jpg")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("folder", type=Path)
    args = parser.parse_args()
    for pitch in (70, 55):
        pack(args.folder, pitch)
