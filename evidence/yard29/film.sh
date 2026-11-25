#!/bin/bash
# n29 floor film/stills: film.sh <name> ; renders at the CURRENT table row (name = i20|i55). Stills 32 ppm mid/gate, 64 ppm mid; movie mid tick 1757, 1380 frames.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
B=C:/Users/kazda/kiro/gtai-wt/n25-yard/build/films29; mkdir -p $B
n=$1
s() { echo "$(date +%T) still $n $1 $2 $3"; node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=$1 --tick=$2 --ppm=$3 --still=$B/${n}_$1_$3.png; }
s mid 2290 32; s gate 6400 32; s mid 2290 64
if [ "$2" = movie ]; then
echo "$(date +%T) movie $n"
timeout 1500 "$GODOT_BIN" --rendering-driver d3d12 --path build/prologue-film --position 0,1440 --resolution 1920x1080 --fixed-fps 60 --write-movie $B/${n}_mid.avi res://dev/prologue_yard/yard_film.tscn -- --yard-dressing=arched_line --place=mid --tick=1757 --frames=1380 --ppm=32 > $B/${n}_mid.log 2>&1
echo "exit $? $(grep -c 'SCRIPT ERROR' $B/${n}_mid.log) $(grep yard-film $B/${n}_mid.log | tail -1)"
fi
echo "$(date +%T) done $n"
