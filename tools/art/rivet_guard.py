"""Cut the n23 guard masters with Rivet's facing cutter. Run with the masters directory.

The output has four phase bands flattened into one strip. Within each band the facings are
front through back. Match the standing dome and boot line for the same facing.
"""

import argparse
from pathlib import Path

import numpy as np
from PIL import Image

from rivet_frames import _measure, _sheet

ART = Path(__file__).resolve().parents[2] / "project/features/characters/art/view"
FACINGS = 5
# The p70 held rerolls are taller than rest at the same dome width. Use a shallow
# crouch there. The p55 painting already lowers the helmet through all three phases.
P70_HEIGHT = (0.985, 0.972, 0.952, 0.98)
# Last clean scanline on the exposed dome, as a percentage of the opaque figure height.
# Read from the accepted paintings in order: rest, low, mid, held, stagger (front to back).
# Stop above the side discs, tipped visor and raised forearms, which vary with the pose.
CROWN_END = {
    "p70": [
        (21, 29, 27, 31, 21),
        (21, 29, 27, 29, 21),
        (22, 30, 28, 30, 23),
        (19, 26, 26, 28, 19),
        (18, 20, 22, 29, 20),
    ],
    "p55": [
        (17, 21, 22, 23, 17),
        (17, 21, 20, 22, 17),
        (18, 22, 21, 23, 18),
        (18, 22, 21, 23, 18),
        (13, 14, 15, 21, 17),
    ],
}


def dome_width(part, end_percent):
    """Widest opaque chord above the annotated landmark in this tight RGBA crop."""
    rows = np.asarray(part)[:round(part.height * end_percent / 100) + 1, :, 3] > 128
    rows = rows[rows.any(axis=1)]
    left = rows.argmax(axis=1)
    right = part.width - rows[:, ::-1].argmax(axis=1)
    return int((right - left).max())


def base_figure(base, facing, end_percent):
    width = base.width // 14
    cell = base.crop((facing * width, 0, (facing + 1) * width, base.height))
    solid = np.asarray(cell)[:, :, 3] > 128
    ys, xs = np.where(solid)
    ref = _measure(solid, xs.min(), ys.min(), xs.max() + 1, ys.max() + 1)
    ref["dome"] = dome_width(cell.crop(ref["box"]), end_percent)
    return ref


def prepare(image, figure, base, end_percent, height_fraction):
    x, y, right, bottom = figure["box"]
    # The raw transparent generations have a faint matte outside the ink contour.
    part = image.crop((x, y, right, bottom))
    part.putalpha(part.getchannel("A").point(lambda a: 0 if a < 32 else a))
    scale = base["dome"] / dome_width(part, end_percent)
    vertical = scale
    if height_fraction is not None:
        target = base["h"] * height_fraction / part.height
        # Use uniform scaling first, reserving 1.5% of the dome tolerance for raster rounding.
        scale *= np.clip(target / scale, 0.965, 1.035)
        vertical = scale * np.clip(target / scale, 0.90, 1.06)
    size = (round(part.width * scale), round(part.height * vertical))
    part = part.convert("RGBa").resize(size, Image.Resampling.LANCZOS).convert("RGBA")
    return part, round((figure["ax"] - x) * scale)


def cut(masters, pitch):
    folder = ART / pitch
    base = Image.open(folder / "rivet_frames.png").convert("RGBA")
    image, bands = _sheet(masters / f"guard_{pitch}.png", [FACINGS] * 4)
    rows = [[(image, fig) for fig in band] for band in bands]
    if pitch == "p70":
        held, (facings,) = _sheet(masters / "guard_p70_held.png", [FACINGS])
        rows[2] = [(held, fig) for fig in facings]
        front, (facings,) = _sheet(masters / "guard_p70_front.png", [2])
        rows[2][:2] = [(front, fig) for fig in facings]

    marks = CROWN_END[pitch]
    refs = [base_figure(base, i, marks[0][i]) for i in range(FACINGS)]
    figures = []
    for phase, band in enumerate(rows):
        for facing, (source, figure) in enumerate(band):
            ref = refs[facing]
            height = P70_HEIGHT[phase] if pitch == "p70" else None
            part, anchor = prepare(source, figure, ref, marks[phase + 1][facing], height)
            offset = round(ref["ax"] - base.width / 14 / 2) - anchor
            figures.append((part, offset, ref["box"][3]))

    half = max(max(-left, left + part.width) for part, left, _ in figures)
    # BC textures use four-texel blocks. Leave a gutter at both sides of every cell.
    width = 4 * ((2 * half + 7) // 4)
    # The renderer anchors from the bottom. Extra room above the head keeps tall poses whole.
    extra = max(0, max(part.height - foot + 2 for part, _, foot in figures))
    strip = Image.new("RGBA", (width * len(figures), base.height + extra))
    for index, (part, left, foot) in enumerate(figures):
        strip.alpha_composite(part, (index * width + width // 2 + left, extra + foot - part.height))
    strip.save(folder / "rivet_guard.png", optimize=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("masters", type=Path)
    args = parser.parse_args()
    for art in ("p70", "p55"):
        cut(args.masters, art)
