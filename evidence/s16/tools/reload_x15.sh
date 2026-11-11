#!/bin/bash
# n15 hero it16: Rivet's p70 reload strips (pistol, plasma_rifle, gatling, each + its drawn left
# strip) at x1.5. Each 110 cut was reproduced IDENTICAL first (x15_cut.py p70 keep ...). Steps:
#   reload_x15.sh before   -> rivet_tour per loadout (8 octants, reload columns) at 64 px/m
#   reload_x15.sh apply    -> copies the x1.5 cuts in, X15 + manifest fig_h (x1.5 of each row's own)
#   reload_x15.sh after    -> the same tours
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
G='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
tour() { echo "$1 $2: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/rivet_tour.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --loadout=$1 --tour-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/rl_$1_$2 2>&1 | tail -1)"; }
case $1 in
  before|after) for w in ${W:-pistol plasma_rifle gatling}; do tour $w $1; done ;;
  apply)
    for w in ${W:-pistol plasma_rifle gatling}; do
      f=165; [ $w = pistol ] && f=174.6
      cp build/x15/$f/p70/rivet_reload_$w.png build/x15/165/p70/rivet_reload_${w}_left.png project/features/characters/art/view/p70/
      py -3 -I - "$w" "$f" <<'PY'
import json, sys
w, f = sys.argv[1], sys.argv[2]
p = 'tools/art/rivet_frames.json'; man = json.load(open(p, encoding='utf8'))
for n, h in ((f'rivet_reload_{w}', float(f)), (f'rivet_reload_{w}_left', 165.0)):
    man['strips']['p70'][n]['fig_h'] = int(h) if h == int(h) else h
open(p, 'w', encoding='utf8', newline='\n').write(json.dumps(man, indent=1, ensure_ascii=False) + '\n')
g = 'project/features/characters/rivet_res.gd'; t = open(g, encoding='utf8').read()
i = t.index('\n]', t.index('const X15'))
add = ''.join(f'\t"p70/rivet_reload_{w}{s}.png",\n' for s in ('', '_left'))
t = t[:i + 1] + add + t[i + 1:]
open(g, 'w', encoding='utf8', newline='\n').write(t)
PY
    done
    timeout 300 "$G" --headless --path project --import > /dev/null 2>&1 ;;
esac
