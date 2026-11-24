"""Translate packed street_walk.py cells. Preserve every original RGBA pixel and the 192 px scale."""
import argparse
from pathlib import Path

import numpy as np
from PIL import Image
from cast_soles import band, body_point, window

# Cut geometry in texels. STEP_M in StreetCopWalk controls the live cadence.
ADVANCE = [(0, 14), (10, 9), (14, 0), (10, -9), (0, -14)]
CELL_H = 256


def pack(source, dest, pitch, name):
    with Image.open(source) as im:
        rgba = im.convert('RGBA')
    w, h = rgba.width//5, rgba.height//4
    if h != 192:
        raise ValueError('expected original 192 px street_walk cells')
    tiles = []
    for col, advance in enumerate(ADVANCE):
        for start in (0, 2):
            pair = []
            for row in (start, start+1):
                tile = rgba.crop((col*w, row*h, (col+1)*w, (row+1)*h))
                mask = np.asarray(tile)[:, :, 3] > 128
                sole = band(mask, window(name, pitch, col, row))
                pair.append((tile, sole, body_point(mask)))
            # Centre the two upper-body positions around the SAME point for both
            # supports. This divides the transfer between feet equally at wrap.
            delta = (pair[1][2]-pair[1][1])-(pair[0][2]-pair[0][1])
            centre = np.array([w/2, CELL_H-h+45])
            for j, (tile, _, torso) in enumerate(pair):
                shift = np.rint(centre+(j-.5)*delta-j*np.array(advance)-torso).astype(int)
                tiles.append((col, start+j, tile, int(shift[0]), int(shift[1])))
    # Seat each facing on the common 7/8 anchor. Keep bottom padding for the
    # unloaded boot when the raised forward heel and the back toe differ in height.
    seated = []
    for col in range(5):
        facing = [t for t in tiles if t[0] == col]
        soles = []
        for _, row, tile, dx, dy in facing[::2]:
            point = band(np.asarray(tile)[:, :, 3] > 128, window(name, pitch, col, row))
            soles.append(point[1] + dy)
        shift = round(CELL_H * .875 - np.mean(soles))
        for col, row, tile, dx, dy in facing:
            seated.append((col, row, tile, dx, dy+shift))
    tiles = seated
    pad = max(abs(dx) for _, _, _, dx, _ in tiles)
    width = w+2*pad
    grid = Image.new('RGBA', (width*5, CELL_H*4))
    for col, row, tile, dx, dy in tiles:
        box = tile.getbbox()
        if box[1]+dy < 0 or box[3]+dy > CELL_H:
            raise ValueError(f'clipped boot or head at {col},{row}')
        grid.paste(tile.crop(box), (col*width+pad+dx+box[0], row*CELL_H+dy+box[1]))
    grid.save(dest)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('original', type=Path, help='original p70 and p55 directories')
    p.add_argument('destination', type=Path)
    args = p.parse_args()
    for pitch in (70, 55):
        for name in ('cop_patrol_walk', 'cop_patrol_armed_walk'):
            rel = Path(f'p{pitch}', name+'.png')
            output = rel if name == 'cop_patrol_walk' else rel.with_name('cop_patrol_planted_armed_walk.png')
            pack(args.original/rel, args.destination/output, pitch, name)
