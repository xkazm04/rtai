#!/bin/bash
# director reel x3 views, headless, fixed 60, on n9-perf HEAD
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf
export TMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
cd /c/Users/kazda/kiro/gtai-wt/n9-perf
for v in top tilt70 combo; do
  "$G" --headless --path project --fixed-fps 60 --quit-after 16000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=$v > /c/Users/kazda/kiro/gtai-n9/tmp/perf/reel7/$v.log 2>&1 &
done
wait
echo done
