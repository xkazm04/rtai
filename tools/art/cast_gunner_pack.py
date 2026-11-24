"""Cut robot gunner A (navy plates): walk, eight-drawing walk, attack, hit and fall sheets.

Every sheet is scaled by the figure's own body height per facing to the patrol cop's drawn height
(never by its cell), anchored on the same foot line, and keeps the muzzle flash and the dropped
rifle as props of the nearest body. No tone change: all sheets come from one plate.
"""
import argparse
import shutil
from pathlib import Path

import cv2
import numpy as np
from PIL import Image

from cast_foe_eight import shipped_heights
from cast_pack import check_cells
from cast_patrol_eight import FOOT, key_figures
from cast_soles import VIEW, band, body_point, bounds

SRC = Path('C:/Users/kazda/kiro/gtai-art/foes-n27/gunnerA')
FILL = {70: 1.12, 55: 1.08}
BODY_MIN = 4000
NAME = 'robot_gunner'


def gap(a, b):
    """Distance between two (x, y, w, h) boxes (0 when they touch)."""
    dx = max(a[0] - (b[0] + b[2]), b[0] - (a[0] + a[2]), 0)
    dy = max(a[1] - (b[1] + b[3]), b[1] - (a[1] + a[3]), 0)
    return (dx * dx + dy * dy) ** .5


def sheet(path, layout):
    """Figures in game order per layout row (a list of strips); each is (rgba image, body mask)."""
    rgb, labels, stats, spill = key_figures(path)
    ids = [i for i in range(1, len(stats)) if stats[i, 4] >= 30]
    bodies = sorted((i for i in ids if stats[i, 4] > BODY_MIN), key=lambda i: stats[i, 1] + stats[i, 3] / 2)
    if len(bodies) != sum(layout):
        raise ValueError(f'{path}: expected {sum(layout)} figures, got {len(bodies)}')
    props = {b: [] for b in bodies}
    for i in ids:
        if i not in props:
            near = min(bodies, key=lambda b: gap(stats[i, :4], stats[b, :4]))
            if gap(stats[i, :4], stats[near, :4]) < 120:
                props[near].append(i)
    rgb = rgb.copy()
    rgb[spill] = (21, 24, 29)
    result = []
    for n in layout:
        row = sorted(bodies[:n], key=lambda i: stats[i, 0])
        bodies = bodies[n:]
        strip = []
        for b in row:
            members = [b, *props[b]]
            x, y = stats[members, :2].min(axis=0)
            r, d = (stats[members, :2] + stats[members, 2:4]).max(axis=0)
            local = labels[y:d, x:r]
            alpha = np.isin(local, members)
            color = rgb[y:d, x:r].copy()
            color[~alpha] = 0
            im = Image.fromarray(np.dstack((color, alpha.astype(np.uint8) * 255)))
            kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (11, 11))
            main = cv2.morphologyEx((local == b).astype(np.uint8), cv2.MORPH_OPEN, kernel)
            n_c, parts, sizes, _ = cv2.connectedComponentsWithStats(main)
            mask = parts == (1 + np.argmax(sizes[1:n_c, 4]))
            strip.append((im, mask))
        result.append(strip)
    return result


def stature(mask):
    _, top, _, bottom = bounds(mask)
    return bottom - top


def source(action, pitch):
    out = SRC / 'out'
    if action == 'armed_walk':
        return sheet(out / 'gunnerA_armed_walk_70.png', [4] * 5)
    if action == 'attack':
        return sheet(out / f'gunnerA_attack_{pitch}.png', [4] * 5)
    if action == 'hit':
        return [[d] for d in sheet(out / 'gunnerA_hit_70.png', (5, 3))[0]]
    if action == 'fall':
        return sheet(out / f'gunnerA_fall_{pitch}.png', [3] * 5)
    a = sheet(out / f'gunnerA8_{pitch}_a.png', (4, 4, 4, 4))
    b = sheet(out / f'gunnerA8_{pitch}_b.png', (4, 4, 4, 4))
    c = sheet(out / f'gunnerA8_{pitch}_c.png', (4, 4))
    return [a[0] + a[1], a[2] + a[3], b[0] + b[1], b[2] + b[3], c[0] + c[1]]


def heights(pitch):
    ref = VIEW / f'p{pitch}' / 'cop_patrol_armed_walk.png'
    return np.array(shipped_heights(ref)) * FILL[pitch]


def pack(action, pitch, target):
    strips = source(action, pitch)
    frames = len(strips[0])
    fall = action == 'fall'
    ch = 440 if fall else 256
    baseline = ch // 2 if fall else FOOT
    figures = []
    for col, strip in enumerate(strips):
        ref = strip[:1] if fall else strip
        scale = target[col] / np.mean([stature(m) for _, m in ref])
        tiles = []
        for row, (im, mask) in enumerate(strip):
            size = tuple(round(v * scale) for v in im.size)
            tile = im.resize(size, Image.Resampling.LANCZOS)
            sm = np.asarray(Image.fromarray(mask.astype(np.uint8) * 255).resize(size, Image.Resampling.BILINEAR)) > 127
            if fall and row:
                x, y, r, d = bounds(sm)
                boot = np.array([(x + r) / 2, y + (d - y) * .62])
            else:
                boot = band(sm)
            tiles.append((tile, boot, sm))
        if frames == 8:
            pts = [body_point(np.asarray(t)[:, :, 3] > 128) for t, _, _ in tiles]
            body_y = baseline - np.mean([boot[1] - pt[1] for (_, boot, _), pt in zip(tiles, pts)])
            tiles = [(t, np.array([pt[0], pt[1] - body_y + baseline]), sm) for (t, _, sm), pt in zip(tiles, pts)]
        figures.append(tiles)
    cw = 2 * (4 + int(np.ceil(max(max(b[0], t.width - b[0]) for s in figures for t, b, _ in s))))
    grid = Image.new('RGBA', (cw * 5, ch * frames))
    for col, strip in enumerate(figures):
        for row, (tile, boot, _) in enumerate(strip):
            x, y = np.rint([cw / 2 - boot[0], baseline - boot[1]]).astype(int)
            if min(x, y) < 1 or y + tile.height >= ch or x + tile.width >= cw:
                raise ValueError(f'{pitch}/{action}/{col}/{row}: {x},{y} size {tile.size} in {cw},{ch}')
            grid.paste(tile, (cw * col + x, ch * row + y))
    dest = VIEW / f'p{pitch}/{NAME}_{action}.png'
    grid.save(dest)
    check_cells(dest, frames)
    review(grid, cw, ch, frames, SRC / 'pack' / f'{action}_{pitch}.jpg')
    return dest


def review(grid, cw, ch, frames, dest):
    plate = Image.new('RGB', (frames * 160, 5 * 150))
    for col in range(5):
        for row in range(frames):
            tile = grid.crop((col * cw, row * ch, (col + 1) * cw, (row + 1) * ch))
            tile = tile.crop(tile.getbbox())
            tile.thumbnail((155, 140))
            box = (row * 160, col * 150, (row + 1) * 160, (col + 1) * 150)
            plate.paste('#c8c6bc' if (row + col) % 2 else '#424447', box)
            plate.paste(tile, (box[0] + (160 - tile.width) // 2, box[1] + (150 - tile.height) // 2), tile)
    plate.save(dest, quality=88)


if __name__ == '__main__':
    argparse.ArgumentParser(description=__doc__).parse_args()
    (SRC / 'pack').mkdir(exist_ok=True)
    for pitch in (70, 55):
        target = heights(pitch)
        for action in ('planted8_armed_walk', 'attack', 'hit', 'fall'):
            print(pitch, action, pack(action, pitch, target).name)
        if pitch == 70:
            pack('armed_walk', pitch, target)
        else:
            shutil.copyfile(VIEW / 'p55' / f'{NAME}_planted8_armed_walk.png', VIEW / 'p55' / f'{NAME}_armed_walk.png')
