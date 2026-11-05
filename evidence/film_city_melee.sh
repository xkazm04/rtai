#!/bin/bash
# film_city_melee.sh <out-name> [extra args...]: rivet-arsenal's live city melee fight at 48 px/m
# (--arena=city --rigs --bot=arsenal, katana/chainsaw/baton, the follow camera), fixed-fps 60.
set -u
N=$1; shift 1
cd /c/Users/kazda/kiro/gtai-wt/d6-combat-notes
export APPDATA=C:/Users/kazda/kiro/gtai-d6/appdata/combat-notes
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-d6/scratch-combat-notes
Q=${QUIT:-1500}
"$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie $S/$N.avi --quit-after $Q --path project res://dev/arena/arena.tscn -- --arena=city --rigs --bot=arsenal --loadout=katana,chainsaw,electro_baton --ppm=48 "$@" > $S/$N.log 2>&1
echo "godot exit $?"; grep -c "SCRIPT ERROR" $S/$N.log
