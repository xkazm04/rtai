"""Cut the n23 guard masters with Rivet's facing cutter. Run with the masters directory.

The output has four phase bands flattened into one strip. Within each band the facings are
front through back. Match the base cell's helmet width and boot line for each facing. The
target heights leave both in-betweens between standing and braced, including on the reroll.
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

from rivet_frames import _measure, _sheet

ART = Path(__file__).resolve().parents[2] / "project/features/characters/art/view"
HEIGHT = (0.96, 0.90, 0.83, 0.98)
FACINGS = 5


def base_figure(base, facing):
    width = base.width // 14
    cell = base.crop((facing * width, 0, (facing + 1) * width, base.height))
    solid = np.asarray(cell)[:, :, 3] > 128
    ys, xs = np.where(solid)
    return _measure(solid, xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)


def prepare(image, figure, base, phase):
    x, y, right, bottom = figure["box"]
    # The raw transparent generations have a faint matte outside the ink contour.
    part = image.crop((x, y, right, bottom))
    part.putalpha(part.getchannel("A").point(lambda a: 0 if a < 32 else a))
    sx = base["head_w"] / figure["head_w"]
    size = (round((right - x) * sx), round(base["h"] * HEIGHT[phase]))
    part = part.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    return part, round((figure["ax"] - x) * sx)


def cut(masters, pitch):
    folder = ART / pitch
    base = Image.open(folder / "rivet_frames.png").convert("RGBA")
    image, bands = _sheet(masters / f"guard_{pitch}.png", [FACINGS] * len(HEIGHT))
    rows = [[(image, fig) for fig in band] for band in bands]
    if pitch == "p70":
        held, (facings,) = _sheet(masters / "guard_p70_held.png", [FACINGS])
        rows[2] = [(held, fig) for fig in facings]
        front, (facings,) = _sheet(masters / "guard_p70_front.png", [2])
        rows[2][:2] = [(front, fig) for fig in facings]

    figures = []
    for phase, band in enumerate(rows):
        for facing, (source, figure) in enumerate(band):
            ref = base_figure(base, facing)
            part, anchor = prepare(source, figure, ref, phase)
            offset = round(ref["ax"] - base.width / 14 / 2) - anchor
            figures.append((part, offset, ref["box"][3]))

    half = max(max(-left, left + part.width) for part, left, _ in figures)
    # BC textures use four-texel blocks. Leave a gutter at both sides of every cell.
    width = 4 * ((2 * half + 7) // 4)
    strip = Image.new("RGBA", (width * len(figures), base.height))
    for index, (part, left, foot) in enumerate(figures):
        strip.alpha_composite(part, (index * width + width // 2 + left, foot - part.height))
    strip.save(folder / "rivet_guard.png", optimize=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masters", type=Path)
    args = parser.parse_args()
    for art in ("p70", "p55"):
        cut(args.masters, art)
