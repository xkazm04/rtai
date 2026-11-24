"""Register the load-bearing shoe in every eight-drawing foe cell and emit the anchor tables.

Windows are percent of the opaque width. The default (0, 100) takes the lowest shoe, which is
the support foot in the planted drawings; OVERRIDES name the cells where the weapon, a shield
edge or the swing shoe is lower, found with the overlay sheet from `--review`.
"""
import argparse
import hashlib
from statistics import mean

import numpy as np
from PIL import Image, ImageDraw

from cast_soles import ROOT, VIEW, band, body_point, bounds

# name: (class, file, strip, fill70, fill55, rows of overrides, has run)
SHEETS = {
    'riot': ('CastRiotAnchors', 'cast_riot_anchors.gd', 'cop_riot_planted8_armed_walk.png',
             (1.11, 1.08), 'cop_riot_armed_walk.png'),
    'swat': ('CastSwatAnchors', 'cast_swat_anchors.gd', 'swat_planted8_armed_walk.png',
             (1.14, 1.07), 'swat_armed_walk.png'),
    'swat_run': ('CastSwatAnchors', 'cast_swat_anchors.gd', 'swat_planted8_run.png',
                 (1.14, 1.07), 'swat_armed_walk.png'),
    'lancer': ('CastLancerAnchors', 'cast_lancer_anchors.gd', 'rocket_trooper_planted8_armed_walk.png',
               (1.0, 1.0), 'rocket_trooper_armed_walk.png'),
    'gunner': ('CastGunnerAnchors', 'cast_gunner_anchors.gd', 'robot_gunner_planted8_armed_walk.png',
               (1.0, 1.0), 'robot_gunner_armed_walk.png'),
    'contractor': ('CastContractorAnchors', 'cast_contractor_anchors.gd',
                   'contractor_planted8_armed_walk.png', (1.0, 1.0), 'contractor_armed_walk.png'),
}
# Sheets whose measured step is replaced by a chosen one (m per drawing): the contractor's measured
# 0.2202 is 13.6 drawings/s at his 3 m/s, over the 5 to 10 bar; 0.30 is the smallest swept step at 10.
STEP_OVERRIDE = {'contractor': 0.30}
FULL = (0, 100)
# (sheet, pitch, column, row): (lo, hi). Filled in from the overlay review.
OVERRIDES = {
    ('riot', 55, 2, 0): (55, 100),
    ('riot', 55, 2, 4): (55, 100),
}


# Drawings 4 and 8 finish on the trailing toe, the rearmost shoe in the three-quarter and profile
# facings (the facing's left; the runtime mirrors the others).
TRAILING = (0, 32)


def window(name, pitch, col, row):
    if (name, pitch, col, row) in OVERRIDES:
        return OVERRIDES[name, pitch, col, row]
    return TRAILING if row in (3, 7) and col in (1, 2, 3) and name != 'swat_run' else FULL


def lead_window(mask):
    """The rightmost shoe in the lowest rows: with both shoes at ground level the lead is the support."""
    x, y, right, bottom = bounds(mask)
    low = np.nonzero(mask)[0].max()
    cols = np.flatnonzero(mask[max(y, low - max(1, round((bottom - y - 1) * .05))):low + 1].any(axis=0))
    groups = np.split(cols, np.flatnonzero(np.diff(cols) > 3) + 1)
    first, last = groups[-1][0], groups[-1][-1] + 1
    width = right - x
    return (max(0, 100 * (first - x) / width - 1), min(100, 100 * (last - x) / width + 1))


def sole(mask, name, pitch, col, row):
    limits = window(name, pitch, col, row)
    if name != 'riot' and limits == FULL and col in (1, 2, 3):
        limits = lead_window(mask)
    return band(mask, limits)


def cells(path):
    alpha = np.asarray(Image.open(path))[:, :, 3] > 128
    return [np.vsplit(strip, 8) for strip in np.hsplit(alpha, 5)]


def review(name, pitch, dest):
    path = VIEW / f'p{pitch}' / SHEETS[name][2]
    grid = cells(path)
    image = Image.open(path).convert('RGBA')
    cw, ch = image.width // 5, image.height // 8
    out = Image.new('RGB', (8 * 180, 5 * 176), '#d2cebf')
    draw = ImageDraw.Draw(out)
    for col in range(5):
        for row in range(8):
            mask = grid[col][row]
            tile = image.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
            x0, y0, x1, y1 = bounds(mask)
            foot = sole(mask, name, pitch, col, row)
            scale = min(168 / (x1 - x0), 147 / (y1 - y0))
            tile = tile.crop((x0, y0, x1, y1)).resize((round((x1 - x0) * scale), round((y1 - y0) * scale)))
            left, top = row * 180 + (180 - tile.width) // 2, col * 176 + 12
            out.paste(tile, (left, top), tile)
            fx, fy = left + (foot[0] - x0) * scale, top + (foot[1] - y0) * scale
            draw.ellipse((fx - 4, fy - 4, fx + 4, fy + 4), outline='#ff2020', width=2)
            draw.text((row * 180 + 4, col * 176 + 2), str(row + 1), fill='#48433f')
    out.save(dest)


def table(name, pitch, lines, const):
    path = VIEW / f'p{pitch}' / SHEETS[name][2]
    lines += [f'## p{pitch} SHA-256 ' + hashlib.sha256(path.read_bytes()).hexdigest(),
              f'const {const}{pitch}: Array[Vector4] = [']
    offsets = []
    for col, strip in enumerate(cells(path)):
        row_offsets = []
        for row, mask in enumerate(strip):
            foot, body = sole(mask, name, pitch, col, row), body_point(mask)
            row_offsets.append(body[0] - foot[0])
            pivot = np.array([mask.shape[1] / 2, mask.shape[0] * .875])
            x, y = foot - pivot
            u, v = body - pivot
            lines.append(f'\tVector4({x:g}, {y:g}, {u:g}, {v:g}),')
        if col == 2:
            offsets = row_offsets
    lines.append(']')
    return offsets


def generate(names, class_name, filename):
    lines = [f'class_name {class_name}', 'extends RefCounted',
             '## DO NOT EDIT. Generated from shipped alpha by tools/art/cast_foe_soles.py.']
    for name in names:
        strip = SHEETS[name][2]
        const = 'RUN' if name == 'swat_run' else 'WALK'
        lines.append(f'const {"RUN_" if const == "RUN" else ""}EIGHT: String = "{strip}"')
        if const == 'WALK':
            lines.append(f'const FOUR: String = "{SHEETS[name][4]}"')
            lines.append('## Select FOUR to restore the shipped four-drawing walk.')
            lines.append('const WALK: String = EIGHT')
    for name in names:
        const = 'RUN' if name == 'swat_run' else 'WALK'
        steps = []
        for pitch, height, fill in [(70, 1.7, SHEETS[name][3][0]), (55, 2.0, SHEETS[name][3][1])]:
            offsets = table(name, pitch, lines, const)
            # Walk: the contact runs from touchdown to the trailing toe (drawing 4). Run: the
            # airborne drawing has no sole, so fit contact to passing.
            span = 2 if name == 'swat_run' else 3
            for start in (0, 4):
                steps.append((offsets[start + span] - offsets[start]) * height * fill / 192 / span)
        print(name, 'metres per drawing', steps)
        text = f'{STEP_OVERRIDE[name]:.2f}' if name in STEP_OVERRIDE else f'{abs(mean(steps)):.4f}'
        lines.append(f'const {const}_STEP_M: float = {text}')
    (ROOT / 'project/features/characters' / filename).write_text(
        '\n'.join(lines) + '\n', encoding='utf-8', newline='\n')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('name', choices=sorted(SHEETS))
    parser.add_argument('--review', action='store_true')
    args = parser.parse_args()
    if args.review:
        from cast_foe_eight import ART
        folder = {'riot': 'riot8c', 'swat': 'swat8c', 'swat_run': 'swat8run', 'lancer': 'lancer8',
                  'gunner': '../foes-n27/gunnerA', 'contractor': 'contractor8c'}[args.name]
        for pitch in (70, 55):
            review(args.name, pitch, ART / folder / 'pack' / f'soles_{pitch}.png')
    else:
        group = [n for n, s in SHEETS.items() if s[0] == SHEETS[args.name][0]]
        generate(group, SHEETS[args.name][0], SHEETS[args.name][1])
