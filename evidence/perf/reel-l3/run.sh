#!/bin/bash
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
cd /c/Users/kazda/kiro/gtai-wt/d9-perf
for v in top tilt70 combo; do
  "$G" --headless --path project --fixed-fps 60 --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=$v > evidence/perf/reel-l3/$v.log 2>&1 &
done
wait
echo done
