#!/bin/bash
# film_city.sh <out-name> <weapon> [extra args...]: one lone city-block kill at 48 px/m (gunplay's
# capture: --arena=city --bot=gunplay --lone --cam=fight --reach=6), fixed-fps 60 -> scratch avi.
set -u
N=$1; W=$2; shift 2
cd /c/Users/kazda/kiro/gtai-wt/d6-combat-notes
export APPDATA=C:/Users/kazda/kiro/gtai-d6/appdata/combat-notes
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-d6/scratch-combat-notes
Q=${QUIT:-900}
"$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie $S/$N.avi --quit-after $Q --path project res://dev/arena/arena.tscn -- --arena=city --weapon=$W --bot=gunplay --lone --clean --rigs --cam=fight --reach=6 --ppm=48 "$@" > $S/$N.log 2>&1
echo "godot exit $?"; grep -c "SCRIPT ERROR" $S/$N.log
