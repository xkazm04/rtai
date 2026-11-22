"""Pull six tick-aligned images from a finished owner film and lay out the review sheet."""
import json
from pathlib import Path
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont

master, weapon, take_dir = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3])
cursor = weapon == 'cursor_before_after'
robots = weapon == 'electric_robots'
stem = weapon if cursor or robots else weapon + '_kills'
video = master / 'films' / (stem + '.mp4')
dest = take_dir / 'review'
dest.mkdir(exist_ok=True)
if cursor:
    samples = [(24, 'Pistol'), (174, 'Before wheel'), (222, 'Katana'), (414, 'Chainsaw'),
               (595, 'Hands'), (811, 'Pistol again')]
else:
    result = json.loads((take_dir / 'take.json').read_text())
    foes = result['opponents']
    samples = [(80, 'Approach')]
    for i, o in enumerate(foes):
        tick = o.get('kill_tick') or o.get('hit_tick')
        if i == 1 and o.get('shield_break'):
            tick = o['shield_break']
        samples.append((tick + 3, o['victim'].replace('_', ' ')))
    if robots:
        samples[0] = (foes[3]['overloaded'] + 5, 'Shield overload')
    samples.sort()
selector = '+'.join('eq(n\\,' + str(t - (0 if cursor else 1)) + ')' for t, _ in samples)
subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-i', str(video),
                '-vf', 'select=' + selector, '-fps_mode', 'vfr', '-frames:v', '6',
                str(dest / '%02d.png')], check=True)
title = ImageFont.truetype('C:/Windows/Fonts/segoeuib.ttf', 19)
w, h = (640, 360) if cursor else (560, 300)
sheet = Image.new('RGB', (3*w, 2*(h+40)), '#191b23')
draw = ImageDraw.Draw(sheet)
for i, (tick, label) in enumerate(samples):
    im = Image.open(dest / f'{i+1:02d}.png')
    if im.size != (1920, 1080):
        raise ValueError(im.size)
    panel = im.resize((w,h), Image.Resampling.LANCZOS) if cursor else im.crop((765,342,1325,642))
    x, y = (i % 3)*w, (i//3)*(h+40)
    sheet.paste(panel,(x,y+40))
    draw.text((x+10,y+7),f'{label.title()}   |   {tick}',font=title,fill='#f3e7d4')
out = master / 'films' / 'review'
out.mkdir(exist_ok=True)
sheet.save(out / (weapon + '.jpg'), quality=95)
print(stem, samples)
