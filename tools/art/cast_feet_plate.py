"""Place native 64 px/m viewport stills side by side and bracket every sample of the pictured contact."""
import argparse
import json
from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw, ImageFont


def exposure(directory, name, pitch):
    trace = json.loads((directory/f'{name}_{pitch}_dots.json').read_text())
    tick = trace['tick']
    options = [s for s in trace['spans'] if s['first'] <= tick <= s['last']]
    if not options:
        raise ValueError(f'no complete visible contact at tick {tick} in {directory}')
    span = max(options, key=lambda s: s['last']-s['first'])
    im = Image.open(directory/f'{name}_{pitch}_t{tick}.png').convert('RGB')
    return im, span, np.asarray(span['dots'])*64/trace['ppm']


def font(size):
    try:
        return ImageFont.truetype('segoeui.ttf', size)
    except OSError:
        return ImageFont.load_default(size=size)


def plate(before, after, name, pitch, dest):
    shots = [exposure(d, name, pitch) for d in (before, after)]
    ground = shots[0][2][0]
    left, top = round(ground[0]-145), round(ground[1]-160)
    width, crop_h = 310, 205
    paper, ink = '#f3efe7', '#20282b'
    board = Image.new('RGB', (width*2+30, 330), paper)
    d = ImageDraw.Draw(board)
    d.text((12, 3), f'{name.replace("_"," ").title()}   ·   {pitch}°   ·   64 px/m   ·   tick 38',
           fill=ink, font=font(18))
    for i, (im, span, dots) in enumerate(shots):
        dx, dy = 10+i*(width+10), 57
        d.text((dx, 31), 'Before  ·  0779185ac' if i == 0 else 'After', fill=ink, font=font(15))
        board.paste(im.crop((left, top, left+width, top+crop_h)), (dx, dy))
        offset = np.array([dx-left, dy-top])
        gx, gy = ground+offset
        d.line((gx-7, gy, gx+7, gy), fill='#236883', width=1)
        d.line((gx, gy-7, gx, gy+7), fill='#236883', width=1)
        for x, y in dots+offset:
            d.ellipse((x-1, y-1, x+1, y+1), fill='#bd3b19')
        a, b = span['first'], span['last']
        x0, x1, yy = dx+10, dx+width-12, 278
        d.line((x0, yy, x1, yy), fill=ink)
        d.line((x0, yy-4, x0, yy+4), fill=ink)
        d.line((x1, yy-4, x1, yy+4), fill=ink)
        for t in range(a, b+1):
            x = x0+(x1-x0)*(t-a)/max(1,b-a)
            d.ellipse((x-1, yy-2, x+1, yy+1), fill='#bd3b19')
        d.text((dx, 285), f'Contact {a}–{b}   ·   {len(dots)} frames   ·   {span["travel"]*2:.2f} px',
               fill=ink, font=font(14))
    d.text((10, 309), 'Blue cross  fixed ground mark       Orange dots  support sole on each rendered frame',
           fill=ink, font=font(13))
    dest.mkdir(parents=True, exist_ok=True)
    slug = 'cop_patrol' if name == 'patrol_cop' else name
    path = dest/f'feet_{slug}_before_after_64ppm_tilt{pitch}.png'
    board.save(path)
    print(path)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('before', type=Path)
    ap.add_argument('after', type=Path)
    ap.add_argument('archetype')
    ap.add_argument('destination', type=Path)
    args = ap.parse_args()
    for pitch in (70, 55):
        plate(args.before, args.after, args.archetype, pitch, args.destination)
