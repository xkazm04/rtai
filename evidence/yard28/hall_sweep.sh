#!/bin/bash
# n28 hall sweep: hall_sweep.sh <name>: arched_day twin of the current row, import, day+dusk captures, measures (build/n28/<name>.json/.app).
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/yard GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
n=$1
python -I evidence/yard28/day_row.py
"$GODOT_BIN" --headless --path project --import > build/n28/$n-import.log 2>&1
for arm in day dusk; do
  row=arched_line; [ $arm = day ] && row=arched_day
  node tools/art/prologue_yard_stills.mjs --dusk --dressing=$row --out=$PWD/build/n28/$n/$arm > build/n28/$n-$arm.log 2>&1; echo "$(date +%T) $n $arm exit $?"
done
python -I evidence/yard28/day_row.py --drop
python -W ignore -I evidence/yard28/sweep_measure.py build/n28/$n > build/n28/$n.json
python -W ignore -I evidence/yard28/appliance_delta.py build/n28/$n/dusk 2>&1 | tail -3 > build/n28/$n.app
cat build/n28/$n.json build/n28/$n.app
