#!/bin/bash
# probe: evidence/yard29/belt_stand_probe.gd.txt (+ .tscn.txt) = project/dev/prologue_yard/yard_stand.{gd,tscn}, kept out of the tree (debt-ratchet dev_loc); copy in to rerun
# n29 belt-finish film: belt_film.sh  -> before (temp row arched_nospan = arched_line minus the five span_* rows) | after (arched_line), mid yard fight
# tick 1757, 1380 frames, 32 px/m, 1920x1080 60 fps through build/prologue-film (the floor film's engine profile, same as film.sh); crops 960x1080 at x=250, hstack, labels.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
B=C:/Users/kazda/kiro/gtai-wt/n25-yard/build/n29-06b/film; mkdir -p $B
lock() { while ! (set -o noclobber; echo "belt-finish $$ $(date +%H:%M)" > build/yard-godot.lock) 2>/dev/null; do
  if [ -n "$(find build/yard-godot.lock -mmin +25 2>/dev/null)" ]; then rm -f build/yard-godot.lock; fi; sleep 30; done; }
for n in arched_nospan arched_line; do
  lock; echo "$(date +%T) movie $n"
  timeout 1500 "$GODOT_BIN" --rendering-driver d3d12 --path build/prologue-film --position 0,1440 --resolution 1920x1080 --fixed-fps 60 --write-movie $B/$n.avi res://dev/prologue_yard/yard_film.tscn -- --yard-dressing=$n --place=mid --tick=1757 --frames=1380 --ppm=32 > $B/$n.log 2>&1
  echo "exit $? $(grep -c 'SCRIPT ERROR' $B/$n.log) $(grep yard-film $B/$n.log | tail -1)"
  rm -f build/yard-godot.lock
done
echo "$(date +%T) movies done"
