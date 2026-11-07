#!/bin/sh
# iteration gates: full unit, then the director reel in top / tilt70 / combo (desktop, no --device),
# then one reel under --device=deck (combo) to show the profile does not break combat.
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/handheld
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
cd /c/Users/kazda/kiro/gtai-wt/d9-handheld
node tools/tests/run_unit.mjs 2>&1 | grep -E "unit-tests:|FLAKY" 
for v in top tilt70 combo deck; do
  dev=""; view=$v; if [ $v = deck ]; then dev="--device=deck"; view=combo; fi
  "$G" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn --quit-after 14000 -- --rigs --bot=reel --reel=director --view=$view --clean $dev > evidence/reel-$v.log 2>&1
  down=$(grep -cE "director chapter .*: ([0-9]+)/\1 down" evidence/reel-$v.log)
  all=$(grep -cE "director chapter .*: [0-9]+/[0-9]+ down" evidence/reel-$v.log)
  err=$(grep -c "SCRIPT ERROR" evidence/reel-$v.log)
  echo "reel $v $dev: $down/$all chapters all down, $err SCRIPT ERROR"
done
