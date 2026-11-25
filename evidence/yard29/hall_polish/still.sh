#!/bin/bash
# usage: still.sh <dressing> <ppm> <name> [place] [tick]  -> build/n29-07/<name>.png ; holds build/yard-godot.lock
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
L=build/yard-godot.lock
while :; do
  if [ -f $L ] && [ $(( $(date +%s) - $(stat -c %Y $L) )) -gt 1500 ]; then rm -f $L; echo "stale lock removed"; fi
  if ( set -o noclobber; echo "hall-polish $$ $(date +%H:%M)" > $L ) 2>/dev/null; then break; fi
  echo "$(date +%T) lock held: $(cat $L 2>/dev/null)"; sleep 30
done
trap 'rm -f $L' EXIT
node tools/art/prologue_yard_film.mjs --dressing=$1 --place=${4:-front} --tick=${5:-2290} --ppm=$2 --still=$PWD/build/n29-07/$3.png 2>&1 | tail -1
