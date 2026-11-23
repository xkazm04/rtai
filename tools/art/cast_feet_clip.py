"""Replay measured 60 Hz sprite transforms and boot contacts at native 32 and 64 px/m."""
import argparse
import json
import math
import subprocess
from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageDraw

from cast_feet import read_frame
from cast_feet_plate import font
from cast_soles import ROOT

WIDTH = 896
PANEL_X = (40, 984)
INK = '#253332'
PAPER = '#f3f0e9'
CONTACTS = ('#c14418', '#087b78')


@lru_cache(maxsize=96)
def tile(path, rect):
    x, y, w, h = rect
    with Image.open(ROOT/'project'/path.removeprefix('res://')) as im:
        return im.convert('RGBA').crop((x, y, x+w, y+h))


def actor(panel, sprite, crop):
    cell = tile(sprite['path'], tuple(sprite['rect']))
    ox, oy, xx, xy, yx, yy = sprite['xf']
    ox -= crop[0]
    oy -= crop[1]
    corners = [(ox+xx*u+yx*v, oy+xy*u+yy*v) for u in (0, cell.width) for v in (0, cell.height)]
    left, top = (math.floor(min(p[i] for p in corners)) for i in range(2))
    w, h = (math.ceil(max(p[i] for p in corners))-a for i, a in enumerate((left, top)))
    if left < 0 or top < 0 or left+w >= panel.width or top+h >= panel.height:
        raise ValueError('actor clipped by comparison panel')
    det = xx*yy-xy*yx
    a, b, d, e = yy/det, -yx/det, -xy/det, xx/det
    inv = (a, b, a*(left-ox)+b*(top-oy), d, e, d*(left-ox)+e*(top-oy))
    rgba = cell.transform((w, h), Image.Transform.AFFINE, inv, Image.Resampling.BILINEAR)
    panel.paste(rgba, (left, top), rgba)


def grid(take, height, mark):
    ppm = take['ppm']
    k = math.sin(math.radians(take['pitch']))
    diagonal = take['facing'] == 'down_right'
    dx = 6*ppm*(2**-0.5 if diagonal else 1)
    dy = dx*k if diagonal else 0
    mark_x, mark_y = mark
    # Centre the entire six-metre traverse and leave headroom for the standing body.
    usable_height = 283 if ppm == 32 else height
    x0, y0 = round((WIDTH-dx)/2), round((usable_height-dy+ppm*1.65)/2)
    crop = (mark_x-x0, mark_y-y0, mark_y)
    im = Image.new('RGB', (WIDTH,height), '#d5d2c0')
    d = ImageDraw.Draw(im)
    for x in range(x0%ppm, WIDTH, ppm):
        d.line((x,0,x,height),fill='#b9b8a8')
    for i in range(-20,21):
        y = round(y0+i*ppm*k)
        d.line((0,y,WIDTH,y),fill='#b9b8a8')
    d.line((x0-7,y0,x0+7,y0),fill='#424e48',width=1)
    d.line((x0,y0-7,x0,y0+7),fill='#424e48',width=1)
    return im,crop


def read(directory, pitch, ppm):
    takes = json.loads((directory/f'tracks_{pitch}_{ppm}.json').read_text())
    return {(t['gait'],t['facing']):t for t in takes
            if t['archetype']=='patrol_cop' and t.get('host','near')=='near'}


def shots():
    for gait in ('city_walk','walk','run'):
        for pitch in (70,55):
            for facing in (('right',) if gait=='city_walk' else ('right','down_right')):
                yield pitch,gait,facing


def compose(page, x, tick, take, ground, crop):
    frame = take['frames'][tick]
    points = read_frame(frame,take)
    r = 1 if take['ppm']==32 else 2
    current = []
    for key, point in points.items():
        px,py = point[0]-crop[0], point[1]-crop[1]
        if not 0 <= px < ground.width or not 0 <= py < ground.height:
            raise ValueError('support hidden outside panel')
        current.append(((px-r,py-r,px+r,py+r),CONTACTS[int(key)%2]))
    for dot,color in current:
        ImageDraw.Draw(ground).ellipse(dot,fill=color)
    panel = ground.copy()
    actor(panel,frame['card'],crop)
    for dot,color in current:
        ImageDraw.Draw(panel).ellipse(dot,fill=color)
    if take['ppm'] == 32:
        page.paste(panel,(x,198))
        return
    # Keep the feet in the inset during diagonal travel. The crop follows the ground
    # path of the actor; ink and old dots retain their measured world separation.
    shift = (tick+1)*take['speed_mps']*64/60 if take['facing']=='down_right' else 0
    gy = crop[2] - crop[1] + shift*math.sin(math.radians(take['pitch']))/math.sqrt(2)
    top = round(gy-78)
    if top < 0 or top+112 > panel.height:
        raise ValueError('feet inset escaped the recorded ground grid')
    feet = panel.crop((72,top,WIDTH-72,top+112))
    d = ImageDraw.Draw(page)
    d.rectangle((x+69,535,x+WIDTH-69,683),fill=PAPER,outline='#52625d',width=2)
    d.text((x+82,539),'Feet   ·   64 px/m',font=font(17),fill=INK)
    page.paste(feet,(x+72,568))


def layout(pitch, gait, facing, speed):
    page = Image.new('RGB',(1920,1080),PAPER)
    d = ImageDraw.Draw(page)
    title = {'city_walk':'City walk','walk':'Wave walk','run':'Retreat'}[gait]
    d.text((40,20), title, fill=INK, font=font(51))
    d.text((42,92), f'Patrol cop     {speed:g} m/s     {pitch}°     {facing.replace("_","-")}',
           fill=INK,font=font(28))
    for x, name in zip(PANEL_X, ('Before   ·   0779185ac','After   ·   8 drawings')):
        d.text((x,149),name,fill=INK,font=font(29))
    d.text((40,977),'Each dot marks the support sole on one rendered frame.',fill=INK,font=font(27))
    d.text((40,1023),'Alternating colours identify contacts. Dots accumulate on the fixed ground grid.',
           fill=INK,font=font(22))
    d.text((1290,44),'32 px/m     ·     1 m grid     ·     60 fps',fill=INK,font=font(27))
    return page


def film(before, after, dest):
    dest.parent.mkdir(parents=True,exist_ok=True)
    cmd = ['ffmpeg','-y','-v','error','-f','rawvideo','-pix_fmt','rgb24','-s','1920x1080',
           '-r','60','-i','-','-an','-c:v','libx264','-preset','veryfast','-threads','3',
           '-crf','16','-pix_fmt','yuv420p','-movflags','+faststart',str(dest)]
    cache = {(directory,pitch,ppm):read(directory,pitch,ppm) for directory in (before,after)
             for pitch in (70,55) for ppm in (32,64)}
    with subprocess.Popen(cmd,stdin=subprocess.PIPE) as encoder:
        reports = {d:json.loads((d/'feet.json').read_text())['rows'] for d in (before,after)}
        for pitch,gait,facing in shots():
            panels = []
            for directory,x in zip((before,after),PANEL_X):
                for ppm,height in ((32,520),(64,608)):
                    take = cache[directory,pitch,ppm][gait,facing]
                    # Both fixed cameras were centred on the same MARK. The later sampler
                    # also records its projection; use that common origin for both panels.
                    mark = cache[after,pitch,ppm][gait,facing]['ground_mark']
                    panels.append((x,take,*grid(take,height,mark)))
            lengths = {len(t['frames']) for _,t,_,_ in panels}
            if len(lengths)!=1:
                raise ValueError(f'unmatched capture durations: {lengths}')
            page = layout(pitch,gait,facing,panels[0][1]['speed_mps'])
            d = ImageDraw.Draw(page)
            for directory,x in zip((before,after),PANEL_X):
                report = next(r for r in reports[directory] if r['archetype']=='patrol_cop'
                              and (r['pitch'],r['gait'],r['facing'])==(pitch,gait,facing)
                              and r.get('host','near')=='near')
                frames = cache[directory,pitch,32][gait,facing]['frames']
                edges = [i for i in range(1,len(frames)) if frames[i]['card']['row']!=frames[i-1]['card']['row']]
                hz = 60*(len(edges)-1)/(edges[-1]-edges[0])
                pairs = [('Max sole travel', f"{report['max_contact_travel_px']:.2f} px"),
                         ('Max body jump', f"{report['max_body_jump_px']:.2f} px"),
                         ('Drawings / s', f'{hz:.2f}')]
                for j,(label,value) in enumerate(pairs):
                    d.text((x+j*303,760),label,fill=INK,font=font(25))
                    d.text((x+j*303,804),value,fill=INK,font=font(44))
            for tick in range(lengths.pop()):
                for x,take,ground,crop in panels:
                    compose(page,x,tick,take,ground,crop)
                encoder.stdin.write(page.tobytes())
        encoder.stdin.close()
        if encoder.wait():
            raise RuntimeError('ffmpeg could not finish the comparison')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('before','after','destination'):
        parser.add_argument(name,type=Path)
    args = parser.parse_args()
    film(args.before,args.after,args.destination)
