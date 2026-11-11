#!/bin/bash
# n15 hero it16: Rivet's p55 reload strips at x1.5, as reload_x15.sh at p70: rivet_tour under
# --view=tilt (the p55 art). Each 110 cut reproduced IDENTICAL first; x1.5 = 1.5 x each row's fig_h.
#   reload_x15_p55.sh before|apply|after   (W="pistol ..." to limit)
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
G='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
tour() { echo "$1 $2: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/rivet_tour.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --view=tilt --loadout=$1 --tour-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/rl55_$1_$2 2>&1 | tail -1)"; }
case $1 in
  before|after) for w in ${W:-pistol plasma_rifle gatling}; do tour $w $1; done ;;
  apply)
    py -3 -I - ${W:-pistol plasma_rifle gatling} <<'PY'
import json, shutil, sys
FIG = {"rivet_reload_pistol": 153.75, "rivet_reload_pistol_left": 165, "rivet_reload_plasma_rifle": 146.25,
       "rivet_reload_plasma_rifle_left": 165, "rivet_reload_gatling": 165, "rivet_reload_gatling_left": 158.1}
p = "tools/art/rivet_frames.json"; man = json.load(open(p, encoding="utf8"))
g = "project/features/characters/rivet_res.gd"; t = open(g, encoding="utf8").read()
for w in sys.argv[1:]:
    for n in (f"rivet_reload_{w}", f"rivet_reload_{w}_left"):
        shutil.copy(f"build/x15/{FIG[n]}/p55/{n}.png", f"project/features/characters/art/view/p55/{n}.png")
        man["strips"]["p55"][n]["fig_h"] = FIG[n]
        i = t.index("\n]", t.index("const X15"))
        t = t[:i + 1] + f'\t"p55/{n}.png",\n' + t[i + 1:]
open(p, "w", encoding="utf8", newline="\n").write(json.dumps(man, indent=1, ensure_ascii=False) + "\n")
open(g, "w", encoding="utf8", newline="\n").write(t)
PY
    timeout 300 "$G" --headless --path project --import > /dev/null 2>&1 ;;
esac
