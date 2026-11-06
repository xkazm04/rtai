#!/bin/bash
# film.sh <out-name> <ppm> <quit-ticks> [extra args...]: one fixed-fps 60 arena capture from this
# worktree (lane n7-melee) -> scratch avi. Arena args go after the `--`.
# The window matches the project viewport (1280x800): under a 1280x720 window the movie drew every
# HUD layer ~70 px left of the world (the ghost card and the telemetry box cut at the edge; 02:25).
set -u
N=$1; P=$2; Q=$3; shift 3
cd /c/Users/kazda/kiro/gtai-wt/n7-melee
export APPDATA=C:/Users/kazda/kiro/gtai-n7p/appdata/melee
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-n7p/scratch/melee
mkdir -p $S
"$G" --rendering-driver d3d12 --fixed-fps 60 --resolution ${RES:-1280x800} --screen 0 --write-movie $S/$N.avi --quit-after $Q --path project res://dev/arena/arena.tscn -- --ppm=$P "$@" > $S/$N.log 2>&1
echo "godot exit $? $N errors=$(grep -c 'SCRIPT ERROR' $S/$N.log)"
