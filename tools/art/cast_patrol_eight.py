"""Cut the approved patrol sheets into five facings by eight drawings, in game order."""
import argparse
import subprocess
import sys
from pathlib import Path

import cv2
import numpy as np
from PIL import Image, ImageDraw

from cast_patrol_soles import generate
from cast_soles import VIEW, body_point, bounds

CELL = (240, 256)
FOOT = 224


def figures(path, bands):
    rgb = np.asarray(Image.open(path).convert('RGB'))
    r, g, b = rgb.astype(np.int16).transpose(2, 0, 1)
    key = (g > r + 12) & (g > b + 10)
    _, labels, stats, _ = cv2.connectedComponentsWithStats((~key).astype(np.uint8))
    indices = [i for i in range(1, len(stats)) if stats[i, 4] > 1500]
    if len(indices) != bands * 8:
        raise ValueError(f'{path}: expected {bands*8} officers, found {len(indices)}')
    indices.sort(key=lambda i: stats[i, 1] + stats[i, 3] / 2)
    for band in range(bands):
        strip = []
        for i in sorted(indices[band*8:band*8+8], key=lambda i: stats[i, 0]):
            x, y, w, h, _ = stats[i]
            alpha = (labels[y:y+h, x:x+w] == i).astype(np.uint8)*255
            crop = rgb[y:y+h, x:x+w].copy()
            # Residual keyed edge antialiasing lies in the black outline.
            spill = (g[y:y+h,x:x+w] > r[y:y+h,x:x+w]+4) & (g[y:y+h,x:x+w] > b[y:y+h,x:x+w]+3)
            crop[spill] = (21, 24, 29)
            crop[alpha == 0] = 0
            strip.append(Image.fromarray(np.dstack((crop, alpha))))
        yield strip


def reference_height(pitch, facing):
    with Image.open(VIEW/f'p{pitch}/cop_patrol_armed_walk.png') as ref:
        w, h = ref.width//5, ref.height//4
        heights = []
        for row in range(4):
            tile = ref.crop((facing*w, row*h, (facing+1)*w, (row+1)*h))
            _, top, _, bottom = bounds(np.asarray(tile)[:, :, 3] > 128)
            heights.append(bottom - top)
        return np.mean(heights)


def pack(root, gait, pitch):
    folder = root/('cop8' if gait == 'walk' else 'cop8run')
    packdir = folder/'pack'
    packdir.mkdir(exist_ok=True)
    stem = f'cop8_armed_{gait}_{pitch}'
    strips = [*figures(folder/'out'/f'{stem}_a.png', 3), *figures(folder/'out'/f'{stem}_b.png', 2)]
    grid = Image.new('RGBA', (CELL[0]*5, CELL[1]*8))
    for col, strip in enumerate(strips):
        factor = reference_height(pitch, col) / np.mean([im.height for im in strip])
        resized = [im.resize(tuple(round(v*factor) for v in im.size), Image.Resampling.LANCZOS) for im in strip]
        bodies = [body_point(np.asarray(im)[:,:,3] > 128) for im in resized]
        body_y = FOOT - np.mean([im.height - pt[1] for im, pt in zip(resized, bodies)])
        for row, (im, pt) in enumerate(zip(resized, bodies)):
            x, y = np.rint([CELL[0]/2-pt[0], body_y-pt[1]]).astype(int)
            if min(x, y) < 0 or x+im.width > CELL[0] or y+im.height > CELL[1]:
                raise ValueError(f'clipped figure at {col},{row}')
            grid.paste(im, (col*CELL[0]+x, row*CELL[1]+y))
    raw = packdir/f'{stem}_cut.png'
    grid.save(raw)
    dest = VIEW/f'p{pitch}/cop_patrol_planted8_armed_{gait}.png'
    subprocess.run([sys.executable, str(Path(__file__).with_name('street_tone.py')), str(raw),
                    str(VIEW/f'p{pitch}/cop_patrol_card.png'), str(dest)], check=True)
    return dest


def review(path, dest):
    with Image.open(path) as im:
        out = Image.new('RGB', (8*180, 5*176), '#d2cebf')
        draw = ImageDraw.Draw(out)
        for col in range(5):
            for row in range(8):
                x,y = col*CELL[0],row*CELL[1]
                tile = im.crop((x,y,x+CELL[0],y+CELL[1]))
                box = bounds(np.asarray(tile)[:,:,3] > 128)
                tile = tile.crop(box)
                tile.thumbnail((168,147))
                left,top = row*180+(180-tile.width)//2,col*176+12
                out.paste(tile,(left,top),tile)
                for percent in range(0,101,10):
                    x = round(left+tile.width*percent/100)
                    draw.line((x,top+tile.height+1,x,top+tile.height+4),fill='#544d48')
                draw.text((row*180+4,col*176+2),str(row+1),fill='#48433f')
        out.save(dest)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('source', type=Path, help='foes-n26 directory')
    args = p.parse_args()
    for gait in ('walk','run'):
        for pitch in (70,55):
            dest = pack(args.source, gait, pitch)
            folder = 'cop8' if gait == 'walk' else 'cop8run'
            review(dest, args.source/folder/'pack'/f'review_{pitch}.jpg')
    generate()
