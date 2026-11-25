#!/bin/bash
# n29-07 readability at the front camera (26,3): day/dusk captures for now (arched_line) and n28 (c649a15d6's arched_line, temp row), one Godot per capture under the lane lock.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
O=$PWD/build/n29-07/bars; mkdir -p $O/now $O/n28
L=build/yard-godot.lock
lock() { while :; do
  if [ -f $L ] && [ $(( $(date +%s) - $(stat -c %Y $L) )) -gt 1500 ]; then rm -f $L; fi
  if ( set -o noclobber; echo "hall-polish $$ $(date +%H:%M)" > $L ) 2>/dev/null; then return; fi
  sleep 30; done; }
trap 'rm -f $L' EXIT
python build/n29-07/temprows.py add
cap() { lock; node tools/art/prologue_yard_stills.mjs --dusk=front --dressing=$2 --out=$O/$1 > $O/$1.log 2>&1; echo "$(date +%T) $1 exit $? $(tail -1 $O/$1.log)"; rm -f $L; }
cap now/day arched_day; cap now/dusk arched_line; cap n28/day arched_n28_day; cap n28/dusk arched_n28
for a in now:arched_line n28:arched_n28; do n=${a%%:*}; row=${a##*:}
  echo "== $n"; ROW=$row python -W ignore -I evidence/yard29/dusk_contrast.py --day $O/$n/day --dusk $O/$n/dusk --json $O/$n/contrast.json
  python -W ignore -I evidence/yard29/rivet_delta.py $O/$n/dusk
done
python build/n29-07/temprows.py remove
git diff --stat -- project/data/tables/prologue_yard_dressings.json
echo BARSDONE
