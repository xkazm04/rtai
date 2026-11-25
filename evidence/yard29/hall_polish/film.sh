#!/bin/bash
# n29-07 hall film + stills: after = arched_line at HEAD, before = c649a15d6's arched_line swapped in under the lock and restored.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
B=$PWD/build/n29-07; L=build/yard-godot.lock
lock() { while :; do
  if [ -f $L ] && [ $(( $(date +%s) - $(stat -c %Y $L) )) -gt 1500 ]; then rm -f $L; fi
  if ( set -o noclobber; echo "hall-polish $$ $(date +%H:%M)" > $L ) 2>/dev/null; then return; fi
  sleep 30; done; }
trap 'rm -f $L; [ -f $B/swapped ] && python $B/swap.py out && rm -f $B/swapped' EXIT
f() { node tools/art/prologue_yard_film.mjs --dressing=arched_line --place=front "$@" 2>&1 | tail -1; }
for arm in ${ARMS:-after before}; do
  lock
  [ $arm = before ] && { python $B/swap.py in; touch $B/swapped; }
  echo "$(date +%T) $arm movie"
  timeout 1500 "$GODOT_BIN" --rendering-driver d3d12 --path build/prologue-film --position 0,1440 --resolution 1920x1080 --fixed-fps 60 --write-movie $B/${arm}.avi res://dev/prologue_yard/yard_film.tscn -- --yard-dressing=arched_line --place=front --tick=1757 --frames=1380 --ppm=32 > $B/${arm}_movie.log 2>&1
  echo "exit $? scripterr $(grep -c 'SCRIPT ERROR' $B/${arm}_movie.log) $(grep yard-film $B/${arm}_movie.log | tail -1)"
  [ $arm = before ] && { python $B/swap.py out; rm -f $B/swapped; git diff --stat -- project/data/tables/prologue_yard_dressings.json; }
  rm -f $L
done
echo "$(date +%T) FILMDONE"
