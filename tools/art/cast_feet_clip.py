"""Replay the actual 60 Hz cell/viewport samples on a fixed metre grid; no tweening or retiming."""
import argparse
import json
import math
import subprocess
from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageDraw
from cast_feet_plate import font
from cast_soles import ROOT


@lru_cache(maxsize=64)
def tile(path, rect):
    x, y, w, h = rect
    with Image.open(ROOT/'project'/path.removeprefix('res://')) as im:
        return im.convert('RGBA').crop((x, y, x+w, y+h))


def actor(panel, sprite):
    cell = tile(sprite['path'], tuple(sprite['rect']))
    ox, oy, xx, xy, yx, yy = sprite['xf']
    # Keep identical viewport coordinates/crop for the entire shot and both exposures.
    ox -= 280
    oy -= 260
    corners = [(ox+xx*u+yx*v, oy+xy*u+yy*v) for u in (0, cell.width) for v in (0, cell.height)]
    left, top = (math.floor(min(p[i] for p in corners)) for i in range(2))
    w, h = (math.ceil(max(p[i] for p in corners))-a for i, a in enumerate((left, top)))
    det = xx*yy-xy*yx
    a, b, d, e = yy/det, -yx/det, -xy/det, xx/det
    inv = (a, b, a*(left-ox)+b*(top-oy), d, e, d*(left-ox)+e*(top-oy))
    rgba = cell.transform((w, h), Image.Transform.AFFINE, inv, Image.Resampling.BILINEAR)
    panel.paste(rgba, (left, top), rgba)


def grid(pitch):
    im = Image.new('RGB', (896, 278), '#d9ccba')
    d = ImageDraw.Draw(im)
    for x in range(8, im.width, 32):
        d.line((x, 0, x, im.height), fill='#b7ac9d')
    spacing = 32*math.sin(math.radians(pitch))
    for index in range(-4, 9):
        y = round(100+index*spacing)
        d.line((0, y, im.width, y), fill='#b7ac9d')
    d.line((355, 100, 365, 100), fill='#365c6a', width=2)
    d.line((360, 95, 360, 105), fill='#365c6a', width=2)
    return im


def read(directory, pitch):
    takes = json.loads((directory/f'tracks_{pitch}_32.json').read_text())
    return {(t['gait'], t['facing']): t for t in takes if t['archetype'] == 'patrol_cop'}


def shots():
    # Each six-metre traverse plays once, to its recorded end, at its native 60 Hz.
    for gait in ('city_walk', 'walk', 'run'):
        for pitch in (70, 55):
            facings = ('right',) if gait == 'city_walk' else ('right', 'down_right')
            for facing in facings:
                yield pitch, gait, facing


def film(before, after, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    cmd = ['ffmpeg', '-y', '-v', 'error', '-f', 'rawvideo', '-pix_fmt', 'rgb24',
           '-s', '1920x1080', '-r', '60', '-i', '-', '-an', '-c:v', 'libx264',
           '-preset', 'veryfast', '-threads', '3', '-crf', '16', '-pix_fmt', 'yuv420p',
           '-movflags', '+faststart', str(dest)]
    cache = {(directory, pitch): read(directory, pitch) for directory in (before, after) for pitch in (70, 55)}
    with subprocess.Popen(cmd, stdin=subprocess.PIPE) as encoder:
        for pitch, gait, facing in shots():
            takes = [cache[directory, pitch][gait, facing] for directory in (before, after)]
            bg = grid(pitch)
            page = Image.new('RGB', (1920, 1080), '#f3efe7')
            d = ImageDraw.Draw(page)
            d.text((42, 19), 'Patrol cop  /  ground contact', fill='#20282b', font=font(43))
            d.text((44, 82), f'{gait.replace("_", " ").title()}   {takes[0]["speed_mps"]:g} m/s     •     {pitch}°     •     {facing.replace("_", "-")}',
                   fill='#35474d', font=font(29))
            for x, title in [(40, 'Before   0779185ac'), (980, 'After')]:
                d.text((x, 151), title, fill='#20282b', font=font(32))
            d.text((42, 505), '2× detail', fill='#35474d', font=font(24))
            d.text((42, 1006), 'Native panels 32 px/m   •   1 m ground grid   •   60 recorded poses/s',
                   fill='#35474d', font=font(23))
            for frames in zip(*(t['frames'] for t in takes), strict=True):
                for x, f in zip((40, 980), frames):
                    panel = bg.copy()
                    actor(panel, f['card'])
                    page.paste(panel, (x, 214))
                    inset = panel.crop((238, 22, 682, 239)).resize((888, 434), Image.Resampling.NEAREST)
                    page.paste(inset, (x, 549))
                encoder.stdin.write(page.tobytes())
        encoder.stdin.close()
        if encoder.wait():
            raise RuntimeError('ffmpeg could not finish the comparison')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('before', 'after', 'destination'):
        parser.add_argument(name, type=Path)
    args = parser.parse_args()
    film(args.before, args.after, args.destination)
