#!/bin/bash
# scratch (n15 hero): one single-row p70 strip at x1.5, filmed on cursor_sweep's STAND leg, zoom, commit.
set -e
w=$1
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
sw() { timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/cursor_sweep.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --loadout=$w --sweep-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/${w}_sw_$1 2>&1 | grep -i "ok exit\|FAIL" | tail -1; }
sw before
py -3 -I - "$w" <<'PY'
import json, sys
w = sys.argv[1]
man = json.load(open('tools/art/rivet_frames.json', encoding='utf8'))
p = 'tools/art/rivet_frames.json'; s = open(p, encoding='utf8').read()
sh = man['strips']['p70'][f'rivet_eq_{w}']['sheet']; a = '    "sheet": "%s"\n' % sh
assert s.count(a) == 1; s = s.replace(a, '    "sheet": "%s",\n    "fig_h": 165\n' % sh)
open(p, 'w', encoding='utf8', newline='\n').write(s)
g = 'project/features/characters/rivet_res.gd'; t = open(g, encoding='utf8').read()
i = t.index('\n]', t.index('const X15')); t = t[:i + 1] + chr(9) + f'"p70/rivet_eq_{w}.png",' + chr(10) + t[i + 1:]
open(g, 'w', encoding='utf8', newline='\n').write(t)
PY
cp build/x15/165/p70/rivet_eq_${w}.png project/features/characters/art/view/p70/
sw after
py -3 -I - "$w" <<'PY'
import sys
from PIL import Image, ImageChops, ImageDraw
w = sys.argv[1]; C = 300
a = Image.open(f'build/film/{w}_sw_before.png').convert('RGB'); b = Image.open(f'build/film/{w}_sw_after.png').convert('RGB')
rows = []
for r in range(4):
    rows.append([round(100 * sum(1 for p in ImageChops.difference(a.crop((c*C, r*C, (c+1)*C, (r+1)*C)), b.crop((c*C, r*C, (c+1)*C, (r+1)*C))).convert('L').getdata() if p > 24) / C / C, 1) for c in range(12)])
print('stand', rows[0]); print('others max', max(max(x) for x in rows[1:]))
cols = [1, 3, 6]
out = Image.new('RGB', (3 * (C + 20), 2 * (C + 20)), (30, 30, 30)); d = ImageDraw.Draw(out)
for j, c in enumerate(cols):
    for i, (im, lab) in enumerate([(a, 'BEFORE'), (b, 'AFTER')]):
        out.paste(im.crop((c * C, 0, (c + 1) * C, C)), (j * (C + 20), 20 + i * (C + 20)))
        d.text((j * (C + 20) + 4, 4 + i * (C + 20)), f'{lab} {w} standing, sweep col {c}', fill='white')
out.resize((out.width * 2, out.height * 2), Image.NEAREST).save(f'evidence/it4/rivet_x15_{w}_before_after_x2_64ppm.png')
PY
