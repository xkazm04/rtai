#!/bin/bash
# film.sh <name> <ppm> <frames> [extra args...]: a fixed-fps reel capture of the arena -> mp4 in the masters folder
set -u
N=$1; P=$2; F=$3; shift 3
cd /c/Users/kazda/kiro/gtai-wt/n-showcase
export APPDATA=${FILM_APPDATA:-C:/Users/kazda/kiro/gtai-n4/appdata/showcase}
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-n4/scratch-showcase
M=C:/Users/kazda/kiro/gtai-masters/n4/showcase
"$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie $S/$N.avi --quit-after $F --path project res://dev/arena/arena.tscn -- --bot=reel --ppm=$P --clean --rigs "$@" > $S/film-$N.log 2>&1
ffmpeg -y -loglevel error -i $S/$N.avi -c:v libx264 -pix_fmt yuv420p -crf 20 $M/$N.mp4 && rm -f $S/$N.avi
echo "done $N $?" >> $S/film-$N.log
