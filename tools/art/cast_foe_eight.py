"""Cut the director's eight-drawing foe walks (riot, SWAT walk and run, lancer) into game sheets.

Five facings by eight drawings, packed at the shipped walk's body height with the same tone as
the shipped sheet, the same cell foot line (224 of 256) as the patrol and Mulroney cuts.
"""
import argparse
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_patrol_eight import CELL as CELL_PATROL, FOOT, figures, key_figures
from cast_patrol_eight import review as review_patrol
from cast_soles import VIEW, body_point, bounds

ART = Path('C:/Users/kazda/kiro/gtai-art/foes-n26')
FACES = ('down', 'dr', 'right', 'ur', 'up')
# folder, source stem, shipped sheet, output name, layout, cell width
JOBS = {
    'riot': ('riot8c', 'riot8c_{p}_{f}_t3', 'cop_riot_armed_walk.png', 'cop_riot_planted8_armed_walk.png', 'grid', 240),
    'swat': ('swat8c', 'swat8c_{p}_{f}_t3', 'swat_armed_walk.png', 'swat_planted8_armed_walk.png', 'grid', 240),
    'swat_run': ('swat8run', 'swat8run_{p}_{f}_t3', 'swat_armed_walk.png', 'swat_planted8_run.png', 'grid', 240),
    'lancer': ('lancer8', 'lancer8_armed_walk_{p}_', 'rocket_trooper_armed_walk.png',
               'rocket_trooper_planted8_armed_walk.png', 'bands', 320),
}


def grid_strip(path):
    """Eight figures of one facing in a 2x4 grid: drawings 1-4 on top, 5-8 below."""
    rgb, labels, stats, spill = key_figures(path)
    ids = [i for i in range(1, len(stats)) if stats[i, 4] > 1500]
    if len(ids) != 8:
        raise ValueError(f'{path}: expected 8 figures, found {len(ids)}')
    ids.sort(key=lambda i: stats[i, 1] + stats[i, 3] / 2)
    ordered = sorted(ids[:4], key=lambda i: stats[i, 0]) + sorted(ids[4:], key=lambda i: stats[i, 0])
    strip = []
    for i in ordered:
        x, y, w, h, _ = stats[i]
        alpha = (labels[y:y+h, x:x+w] == i).astype(np.uint8) * 255
        crop = rgb[y:y+h, x:x+w].copy()
        crop[spill[y:y+h, x:x+w]] = (21, 24, 29)
        crop[alpha == 0] = 0
        strip.append(Image.fromarray(np.dstack((crop, alpha))))
    return strip


def sources(job, pitch):
    folder, stem, _, _, layout, _ = JOBS[job]
    out = ART / folder / 'out'
    if layout == 'grid':
        return [grid_strip(out / (stem.format(p=pitch, f=f) + '.png')) for f in FACES]
    base = out / stem.format(p=pitch, f='')
    return [*figures(Path(str(base) + 'a.png'), 3), *figures(Path(str(base) + 'b.png'), 2)]


def shipped_heights(reference):
    mask = np.asarray(Image.open(reference))[:, :, 3] > 128
    heights = []
    for strip in np.hsplit(mask, 5):
        rows = []
        for tile in np.vsplit(strip, 4):
            _, top, _, bottom = bounds(tile)
            rows.append(bottom - top)
        heights.append(np.mean(rows))
    return heights


def pack(job, pitch):
    folder, _, ref_name, out_name, _, width = JOBS[job]
    cell = (width, CELL_PATROL[1])
    view = VIEW / f'p{pitch}'
    reference = view / ref_name
    heights = shipped_heights(reference)
    grid = Image.new('RGBA', (cell[0] * 5, cell[1] * 8))
    for col, strip in enumerate(sources(job, pitch)):
        factor = heights[col] / np.mean([im.height for im in strip])
        tiles = [im.resize(tuple(round(v * factor) for v in im.size), Image.Resampling.LANCZOS)
                 for im in strip]
        bodies = [body_point(np.asarray(im)[:, :, 3] > 128) for im in tiles]
        body_y = FOOT - np.mean([im.height - pt[1] for im, pt in zip(tiles, bodies)])
        for row, (im, pt) in enumerate(zip(tiles, bodies)):
            x, y = np.rint([cell[0] / 2 - pt[0], body_y - pt[1]]).astype(int)
            if min(x, y) < 0 or x + im.width > cell[0] or y + im.height > cell[1]:
                raise ValueError(f'{job} p{pitch}: clipped figure at {col},{row}: {x},{y} {im.size}')
            grid.paste(im, (col * cell[0] + x, row * cell[1] + y))
    work = ART / folder / 'pack'
    work.mkdir(exist_ok=True)
    raw = work / f'{out_name[:-4]}_{pitch}_cut.png'
    grid.save(raw)
    dest = view / out_name
    subprocess.run([sys.executable, str(Path(__file__).with_name('street_tone.py')),
                    str(raw), str(reference), str(dest)], check=True)
    r, g, b, a = np.asarray(Image.open(dest), dtype=int).transpose(2, 0, 1)
    if np.any((a >= 128) & ((g - np.maximum(r, b) > 50) | (np.minimum(r, b) - g > 50))):
        raise ValueError('opaque key pixels')
    review_patrol_cell(dest, work / f'review_{pitch}.jpg', cell)


def review_patrol_cell(path, dest, cell):
    from PIL import ImageDraw
    with Image.open(path) as im:
        out = Image.new('RGB', (8 * 180, 5 * 176), '#d2cebf')
        draw = ImageDraw.Draw(out)
        for col in range(5):
            for row in range(8):
                x, y = col * cell[0], row * cell[1]
                tile = im.crop((x, y, x + cell[0], y + cell[1]))
                tile = tile.crop(bounds(np.asarray(tile)[:, :, 3] > 128))
                tile.thumbnail((168, 147))
                left, top = row * 180 + (180 - tile.width) // 2, col * 176 + 12
                out.paste(tile, (left, top), tile)
                draw.text((row * 180 + 4, col * 176 + 2), str(row + 1), fill='#48433f')
        out.save(dest)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('job', choices=sorted(JOBS))
    args = parser.parse_args()
    for pitch in (70, 55):
        pack(args.job, pitch)
