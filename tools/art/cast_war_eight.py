"""Cut the pile-driver's eight-drawing walk (n29) into game sheets beside the shipped four.

Five facings by eight drawings (2x4 grid per facing, green key by lead, cut by cast_foe_eight.grid_strip),
each facing scaled to the shipped four-drawing sheet's mean body height for that facing, packed in
the shipped war machine's 288 px cells with every drawing's torso point on the facing's common point,
so the mean sole lands on the shipped foot line (FoeWarCardView.BASE_PX). Toned to the shipped walk.

usage: python tools/art/cast_war_eight.py [--look]
"""
import argparse
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_door_eight import amber, key_lead, shipped_heights_rows, strict_red
from cast_foe_eight import FACES, grid_strip, shipped_heights
from cast_soles import ROOT, VIEW, body_point

ART = Path('C:/Users/kazda/kiro/gtai-art/foes-n29/war8')
FOUR = 'war_machine_armed_walk.png'
EIGHT = 'war_machine_planted8_armed_walk.png'
CELL_H = 288
FOOT = 264  # FoeWarCardView.BASE_PX: the shipped sheets' ground baseline
LOOK = ROOT / 'build/look/n29-war8'


def facing_tiles(pitch, col, height):
    strip = grid_strip(ART / 'out' / f'war8_{pitch}_{FACES[col]}.png')
    factor = height / np.mean([im.height for im in strip])
    tiles = [im.resize(tuple(round(v * factor) for v in im.size), Image.Resampling.LANCZOS)
             for im in strip]
    return tiles, [body_point(np.asarray(im)[:, :, 3] > 128) for im in tiles]


def pack(pitch):
    reference = VIEW / f'p{pitch}' / FOUR
    heights = shipped_heights(reference)
    columns = [facing_tiles(pitch, col, heights[col]) for col in range(5)]
    need = max(2 * max(pt[0], im.width - pt[0]) for tiles, pts in columns for im, pt in zip(tiles, pts))
    width = max(Image.open(reference).width // 5, int(np.ceil(need / 2)) * 2 + 4)
    grid = Image.new('RGBA', (width * 5, CELL_H * 8))
    for col, (tiles, bodies) in enumerate(columns):
        body_y = FOOT - np.mean([im.height - pt[1] for im, pt in zip(tiles, bodies)])
        for row, (im, pt) in enumerate(zip(tiles, bodies)):
            x, y = np.rint([width / 2 - pt[0], body_y - pt[1]]).astype(int)
            if y + im.height > CELL_H:
                print(f'p{pitch} {FACES[col]} {row + 1}: lifted {y + im.height - CELL_H} px to fit')
                y = CELL_H - im.height
            if min(x, y) < 0 or x + im.width > width or y + im.height > CELL_H:
                raise ValueError(f'war p{pitch}: clipped figure at {col},{row}: {x},{y} {im.size}')
            grid.paste(im, (col * width + x, row * CELL_H + y))
    work = ART / 'pack'
    work.mkdir(exist_ok=True)
    raw = work / f'war8_{pitch}_cut.png'
    grid.save(raw)
    dest = VIEW / f'p{pitch}' / EIGHT
    subprocess.run([sys.executable, str(Path(__file__).with_name('street_tone.py')),
                    str(raw), str(reference), str(dest)], check=True)
    amber(dest)
    if key_lead(dest):
        raise ValueError(f'{dest}: {key_lead(dest)} opaque key pixels')
    eight = shipped_heights_rows(dest, 8)
    print(f'p{pitch} cell {Image.open(dest).width // 5}x{CELL_H}; body height four',
          [round(h, 1) for h in heights], 'eight', [round(h, 1) for h in eight])
    print(f'p{pitch} key-lead px four {key_lead(reference)} cut {key_lead(raw)} eight {key_lead(dest)};'
          f' strict red four {strict_red(reference)} cut {strict_red(raw)} eight {strict_red(dest)}')


def look(pitch):
    """Both sheets at 1x on grey: the four on top, the eight below, facings left to right."""
    four = Image.open(VIEW / f'p{pitch}' / FOUR).convert('RGBA')
    eight = Image.open(VIEW / f'p{pitch}' / EIGHT).convert('RGBA')
    out = Image.new('RGBA', (max(four.width, eight.width) + 16, four.height + eight.height + 24),
                    (128, 128, 128, 255))
    out.alpha_composite(four, (8, 8))
    out.alpha_composite(eight, (8, four.height + 16))
    LOOK.mkdir(parents=True, exist_ok=True)
    out.convert('RGB').save(LOOK / f'war8_{pitch}_1x.png')
    for col, face in enumerate(FACES):  # one facing per still, eight drawings in a row, for reading
        cell_w = eight.width // 5
        row = Image.new('RGBA', (cell_w * 8 + 16, CELL_H + 16), (128, 128, 128, 255))
        for k in range(8):
            row.alpha_composite(eight.crop((col * cell_w, k * CELL_H, (col + 1) * cell_w, (k + 1) * CELL_H)),
                                (8 + k * cell_w, 8))
        row.convert('RGB').save(LOOK / f'war8_{pitch}_{face}_row.png')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--look', action='store_true', help='only compose the 1x grey look sheets')
    args = parser.parse_args()
    for tilt in (70, 55):
        if not args.look:
            pack(tilt)
        look(tilt)
