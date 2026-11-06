#!/bin/bash
# reels.sh <tag>: the director reel in the arena and the city block (windowed, d3d12), then scenarios.
cd /c/Users/kazda/kiro/gtai-wt/n7-melee
export APPDATA=C:/Users/kazda/kiro/gtai-n7p/appdata/melee
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
E=evidence/n7-melee
"$G" --rendering-driver d3d12 --screen 0 --path project res://dev/arena/arena.tscn --quit-after 7400 -- --bot=reel --reel=director --loadout=pistol > $E/director-arena-loadout-$1.log 2>&1
echo "arena exit $? down=$(grep -c 'director chapter' $E/director-arena-loadout-$1.log) err=$(grep -c 'SCRIPT ERROR' $E/director-arena-loadout-$1.log)"
"$G" --rendering-driver d3d12 --screen 0 --path project res://dev/arena/arena.tscn --quit-after 7400 -- --bot=reel --reel=director --loadout=pistol --arena=city > $E/director-city-loadout-$1.log 2>&1
echo "city exit $? down=$(grep -c 'director chapter' $E/director-city-loadout-$1.log) err=$(grep -c 'SCRIPT ERROR' $E/director-city-loadout-$1.log)"
"$G" --headless --path project -s res://tests/run_scenarios.gd > $E/scenarios-$1.log 2>&1
echo "scenarios exit $? $(grep -E 'ran|failed' $E/scenarios-$1.log | tail -1)"
