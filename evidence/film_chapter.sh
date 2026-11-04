#!/bin/bash
# film_chapter.sh <out-name> <ppm> <chapter> [extra args...]: one director-cut chapter, fixed-fps 60,
# from this worktree (lane combat-notes) -> scratch avi -> masters mp4 (title card burned in).
set -u
N=$1; P=$2; ID=$3; shift 3
cd /c/Users/kazda/kiro/gtai-wt/d6-combat-notes
export APPDATA=C:/Users/kazda/kiro/gtai-d6/appdata/combat-notes
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-d6/scratch-combat-notes
M=C:/Users/kazda/kiro/gtai-masters/d6/combat-notes
mkdir -p $S $M
Q=${QUIT:-360}
"$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie $S/$N.avi --quit-after $Q --path project res://dev/arena/arena.tscn -- --bot=reel --reel=director --chapter=$ID --loadout=pistol --ppm=$P --clean --rigs "$@" > $S/$N.log 2>&1
echo "godot exit $?"
grep -c "SCRIPT ERROR" $S/$N.log
