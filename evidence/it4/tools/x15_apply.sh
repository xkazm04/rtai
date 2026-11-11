#!/bin/bash
# scratch (n15 hero): apply one p70 weapon's x1.5 cut (strip + left), film the after, zoom, commit.
set -e
w=$1
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
py -3 -I - "$w" <<'PY'
import json, sys
w = sys.argv[1]
man = json.load(open('tools/art/rivet_frames.json', encoding='utf8'))
p = 'tools/art/rivet_frames.json'
s = open(p, encoding='utf8').read()
names = [n for n in [f'rivet_eq_{w}', f'rivet_eq_{w}_left'] if n in man['strips']['p70']]
for name in names:
    sh = man['strips']['p70'][name]['sheet']
    a = '    "sheet": "%s"\n' % sh
    assert s.count(a) == 1, (a, s.count(a))
    s = s.replace(a, '    "sheet": "%s",\n    "fig_h": 165\n' % sh)
open(p, 'w', encoding='utf8', newline='\n').write(s)
g = 'project/features/characters/rivet_res.gd'
t = open(g, encoding='utf8').read()
anchor = '\t"p70/rivet_eq_machine_pistol_left.png",\n'
assert anchor in t
add = ''.join(chr(9) + '"p70/' + n + '.png",' + chr(10) for n in names)
i = t.index('\n]', t.index('const X15'))
t = t[:i + 1] + add + t[i + 1:]
open(g, 'w', encoding='utf8', newline='\n').write(t)
PY
for f in rivet_eq_${w}.png rivet_eq_${w}_left.png; do [ -f build/x15/165/p70/$f ] && cp build/x15/165/p70/$f project/features/characters/art/view/p70/ || true; done
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --loadout=$w --film-fire --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/${w}_after 2>&1 | grep -i "ok exit\|FAIL" | tail -1
py -3 -I - "$w" <<'PY'
import sys
from PIL import Image, ImageChops, ImageDraw
w = sys.argv[1]
d = 'build/film/'
worst = []
for leg in range(4):
    for f in range(16):
        a = Image.open(f'{d}{w}_before_{leg}_{f:02d}.png').convert('RGB'); b = Image.open(f'{d}{w}_after_{leg}_{f:02d}.png').convert('RGB')
        n = sum(1 for p in ImageChops.difference(a, b).convert('L').getdata() if p > 24)
        worst.append((round(100 * n / (a.width * a.height), 1), leg, f))
worst.sort()
print('diff % min/median/max', worst[0][0], worst[len(worst)//2][0], worst[-1])
C = 260
picks = [(0, 6), (1, 12), (3, 12)]
out = Image.new('RGB', (C * 3 + 40, C * 2 + 40), (30, 30, 30)); dr = ImageDraw.Draw(out)
for j, (leg, f) in enumerate(picks):
    for i, side in enumerate(['before', 'after']):
        im = Image.open(f'{d}{w}_{side}_{leg}_{f:02d}.png').convert('RGB').crop((0, 0, 260, 260))
        out.paste(im, (j * (C + 20), 20 + i * (C + 20)))
        dr.text((j * (C + 20) + 4, 4 + i * (C + 20)), f'{side.upper()} {w} leg {leg} f{f}', fill='white')
out = out.resize((out.width * 2, out.height * 2), Image.NEAREST)
out.save(f'evidence/it4/rivet_x15_{w}_before_after_x2_64ppm.png')
PY
