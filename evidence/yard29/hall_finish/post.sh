#!/bin/bash
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
B=$PWD/build/n29-05
s() { node tools/art/prologue_yard_film.mjs --dressing=$1 --place=front --tick=2290 --ppm=$2 --still=$B/$3.png 2>&1 | tail -1; }
until grep -q "^[0-9:]* done$\|SKIPPED" build/n29-05/frame.out; do sleep 2; done
sleep 2
echo "$(date +%T) stills now"
s arched_line 32 now_32; s arched_line 64 now_64
echo "$(date +%T) pilots"
node tools/dev/run.mjs yard_pilot_rows --timeout=900 --dressings=arched_line --seeds=7,3,11,21,42 --out=$PWD/build/n29-05/pilots_raw.json 2>&1 | tail -2
python build/n29-05/pilots_cmp.py build/n29-05/pilots_raw.json evidence/yard29/prologue-yard-pilots-hall.json
until grep -q "go:" build/n29-05/commit2.out; do sleep 2; done
sleep 15
echo "$(date +%T) still before"
python build/n29-05/temprow.py add
s arched_n28 32 n28_32
python build/n29-05/temprow.py remove
git diff --stat -- project/data/tables/prologue_yard_dressings.json
bash build/n29-05/stills_compose.sh
echo "$(date +%T) post done"
