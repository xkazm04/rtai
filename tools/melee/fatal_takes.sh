#!/bin/bash
# 03p5 fatality takes: before (main rules) then after (HEAD defaults) per weapon, then a side-by-side film.
# usage: fatal_takes.sh [--compose-only] <weapon>...   (needs the lane lock and APPDATA for Godot runs)
cd "$(dirname "$0")/../.." || exit 1
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/melee
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
M=C:/Users/kazda/kiro/gtai-masters/n31/melee
COMPOSE_ONLY=0
if [ "$1" = "--compose-only" ]; then COMPOSE_ONLY=1; shift; fi
FONT="fontfile='C\:/Windows/Fonts/arialbd.ttf'"
lbl() { echo "drawtext=$FONT:text='$1':x=20:y=20:fontsize=34:fontcolor=white:box=1:boxcolor=black@0.6"; }
CROP="crop=iw/2:ih:iw/4:0,scale=-2:1080"
for w in "$@"; do
  echo "== $w $(date +%H:%M:%S)"
  if [ $COMPOSE_ONLY = 0 ]; then
    node tools/melee/play_take.mjs --label=fatalb --weapons=$w --seed=7 --frames=2100 --ppm=32 --out=$M --tag=03p5 --game-flags=--melee-sweep=off,--kill-feed=off || { echo "FAIL before $w"; continue; }
    mv -f $M/fatalb_play_$w.mp4 $M/fatal_play_${w}_before.mp4
    node tools/melee/play_take.mjs --label=fatala --weapons=$w --seed=7 --frames=2100 --ppm=32 --out=$M --tag=03p5 --game-flags= || { echo "FAIL after $w"; continue; }
    mv -f $M/fatala_play_$w.mp4 $M/fatal_play_${w}_after.mp4
  fi
  ffmpeg -hide_banner -loglevel error -y -i $M/fatal_play_${w}_before.mp4 -i $M/fatal_play_${w}_after.mp4 -filter_complex \
   "[0:v]$CROP,$(lbl main)[a];[1:v]$CROP,$(lbl 'n31 fatality')[b];[a][b]hstack=inputs=2,pad=1920:1080:(ow-iw)/2:0" \
   -c:v libx264 -crf 20 -pix_fmt yuv420p -an $M/beside_fatal_$w.mp4 && echo "beside $w ok $(date +%H:%M:%S)"
done
echo "== done $(date +%H:%M:%S)"
