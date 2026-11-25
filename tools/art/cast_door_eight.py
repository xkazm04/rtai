"""Cut the door carrier's eight-drawing walk (n29) into game sheets beside the shipped four.

Five facings by eight drawings (2x4 grid per facing, green key, cut by cast_foe_eight.grid_strip),
each facing scaled to the shipped four-drawing sheet's mean body height for that facing, packed in
the shipped door's 192 px cells with every drawing's torso point on the facing's common point, so
the mean sole lands on the shipped foot line. Toned to the shipped door walk.

usage: python tools/art/cast_door_eight.py [--look]
"""
import argparse
import subprocess
import sys
from pathlib import Path

import numpy as np
from PIL import Image

from cast_foe_eight import FACES, grid_strip, shipped_heights
from cast_soles import ROOT, VIEW, body_point, bounds

ART = Path('C:/Users/kazda/kiro/gtai-art/foes-n29/door8')
FOUR = 'shield_robot_armed_walk.png'
EIGHT = 'shield_robot_planted8_armed_walk.png'
CELL_H = 192
FOOT = 189  # round(192 * street_hit.FOOT_Y): the shipped door's foot line
LOOK = ROOT / 'build/look/n29-door8'
# n29-11: drawing 7 of the p70 right facing redrawn (door8b image edit). The edit re-encoded every pixel
# (silhouettes of 1-6 and 8 unchanged), so only drawing 7's grid cell is spliced into the old source,
# and only its sheet cell is taken from the new pack (the tone pass is global: the rest keeps its pixels).
# n30-05: the same one-row edit for p55 drawing 8 (right, down-right) and p70 down-right drawing 1 (door8c).
N30 = Path('C:/Users/kazda/kiro/gtai-art/foes-n30/door8c/out')
# n30-16 (p55 round, door8d): right drawing 7 (support boot back to drawing 3's place) and down-right drawing 5
# (landed boot under the slab as in drawing 6), each spliced into the door8c splice above, so the source rows
# carry both edits; the f8 cells keep their sheet bytes.
N30D = Path('C:/Users/kazda/kiro/gtai-art/foes-n30/door8d/out')
REDRAWN = {(70, 'right'): Path('C:/Users/kazda/kiro/gtai-art/foes-n29/door8b/out/door8_70_right_f7_splice.png'),
           (70, 'dr'): N30 / 'door8_70_dr_f1_splice.png',
           (55, 'right'): N30D / 'door8_55_right_f7_splice.png',
           (55, 'dr'): N30D / 'door8_55_dr_f5_splice.png'}
# (facing column, drawing row), 0-based: the sheet cells this cut replaces. The n29 p70 right row 7 (2, 6) is
# already in the sheet and keeps its bytes (re-toning the new pack moves it by a level; silhouette identical);
# so do the n30-05 p55 row 7 cells (2, 7) and (1, 7).
REDRAWN_CELLS = {70: [(1, 0)], 55: [(2, 6), (1, 4)]}


def keep_others(dest, before, cells):
    """Every cell but the redrawn ones keeps the previous sheet's bytes."""
    new = np.asarray(Image.open(dest).convert('RGBA')).copy()
    if before is None or before.shape != new.shape:
        raise ValueError(f'{dest}: no same-size previous sheet to keep the other drawings from')
    out, width = before.copy(), new.shape[1] // 5
    for col, row in cells:
        box = np.s_[row * CELL_H:(row + 1) * CELL_H, col * width:(col + 1) * width]
        out[box] = new[box]
    Image.fromarray(out).save(dest)


def key_lead(path):
    """Opaque pixels with a 50-level green or magenta lead (the key-clean bar)."""
    r, g, b, a = np.asarray(Image.open(path).convert('RGBA'), dtype=int).transpose(2, 0, 1)
    return int(np.sum((a >= 128) & ((g - np.maximum(r, b) > 50) | (np.minimum(r, b) - g > 50))))


def strict_red(path):
    """Opaque pixels that read red or vermilion, not amber (hue under ~20 deg: green at most 0.45 red)."""
    r, g, b, a = np.asarray(Image.open(path).convert('RGBA'), dtype=int).transpose(2, 0, 1)
    return int(np.sum((a >= 128) & (r >= 120) & (g * 20 <= r * 9) & (b * 2 <= r)))


def amber(path):
    """Lift the few burnt-orange stripe shadows the source drew past amber (green under 0.45 red)."""
    rgba = np.asarray(Image.open(path).convert('RGBA'), dtype=int)
    r, g, b, a = rgba.transpose(2, 0, 1)
    red = (a >= 128) & (r >= 120) & (g * 20 <= r * 9) & (b * 2 <= r)
    rgba[..., 1] = np.where(red, (r * 47 + 99) // 100, g)
    print(f'{path.name}: {int(red.sum())} burnt-orange px lifted to amber')
    Image.fromarray(rgba.astype(np.uint8)).save(path)


def facing_tiles(pitch, col, height):
    source = REDRAWN.get((pitch, FACES[col]), ART / 'out' / f'door8_{pitch}_{FACES[col]}.png')
    strip = grid_strip(source)
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
            if y + im.height > CELL_H:  # a tall slab drawing: rest it on the cell floor instead
                print(f'p{pitch} {FACES[col]} {row + 1}: lifted {y + im.height - CELL_H} px to fit')
                y = CELL_H - im.height
            if min(x, y) < 0 or x + im.width > width or y + im.height > CELL_H:
                raise ValueError(f'door p{pitch}: clipped figure at {col},{row}: {x},{y} {im.size}')
            grid.paste(im, (col * width + x, row * CELL_H + y))
    work = ART / 'pack'
    work.mkdir(exist_ok=True)
    raw = work / f'door8_{pitch}_cut.png'
    grid.save(raw)
    dest = VIEW / f'p{pitch}' / EIGHT
    before = np.asarray(Image.open(dest).convert('RGBA')).copy() if dest.exists() else None
    subprocess.run([sys.executable, str(Path(__file__).with_name('street_tone.py')),
                    str(raw), str(reference), str(dest)], check=True)
    amber(dest)
    if pitch in REDRAWN_CELLS:
        keep_others(dest, before, REDRAWN_CELLS[pitch])
    if key_lead(dest):
        raise ValueError(f'{dest}: {key_lead(dest)} opaque key pixels')
    report(pitch, reference, raw, dest, heights)


def report(pitch, reference, raw, dest, heights):
    eight = shipped_heights_rows(dest, 8)
    print(f'p{pitch} cell {Image.open(dest).width // 5}x{CELL_H}; body height four',
          [round(h, 1) for h in heights], 'eight', [round(h, 1) for h in eight])
    print(f'p{pitch} key-lead px four {key_lead(reference)} cut {key_lead(raw)} eight {key_lead(dest)};'
          f' strict red four {strict_red(reference)} cut {strict_red(raw)} eight {strict_red(dest)}')


def shipped_heights_rows(path, rows):
    mask = np.asarray(Image.open(path))[:, :, 3] > 128
    out = []
    for strip in np.hsplit(mask, 5):
        spans = [bounds(tile)[3] - bounds(tile)[1] for tile in np.vsplit(strip, rows)]
        out.append(float(np.mean(spans)))
    return out


def look(pitch):
    """Both sheets at 1x on grey: the four on top, the eight below, facings left to right."""
    four = Image.open(VIEW / f'p{pitch}' / FOUR).convert('RGBA')
    eight = Image.open(VIEW / f'p{pitch}' / EIGHT).convert('RGBA')
    out = Image.new('RGBA', (max(four.width, eight.width) + 16, four.height + eight.height + 24),
                    (128, 128, 128, 255))
    out.alpha_composite(four, (8, 8))
    out.alpha_composite(eight, (8, four.height + 16))
    LOOK.mkdir(parents=True, exist_ok=True)
    out.convert('RGB').save(LOOK / f'door8_{pitch}_1x.png')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--look', action='store_true', help='only compose the 1x grey look sheets')
    args = parser.parse_args()
    for tilt in (70, 55):
        if not args.look:
            pack(tilt)
        look(tilt)
