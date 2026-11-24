#!/bin/bash
# n28 floor sweep: for each k, day + dusk --dusk captures of arched_day / arched_line (same sim, paired). Temp data edits only.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/yard GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
for spec in "$@"; do
  k=${spec%%:*}; rest=${spec#*:}; [ "$rest" = "$spec" ] && rest=""
  python -I evidence/yard28/sweep_row.py ${k/#c/1.0} ${rest//:/ }
  for arm in day dusk; do
    row=arched_line; [ $arm = day ] && row=arched_day
    node tools/art/prologue_yard_stills.mjs --dusk --dressing=$row --out=$PWD/build/n28/k$k/$arm > build/n28/k$k-$arm.log 2>&1; echo "$(date +%T) k$k $arm exit $?"
  done
done
echo sweep-done
