#!/bin/bash
# n28 art sweep: art_sweep.sh <name> <tint> <stains tint> <wash>: temp row edit, day+dusk captures, then the measures (one JSON line to build/n29/<name>.json).
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
n=$1; shift
python -I evidence/yard29/${ROWPY:-art_row.py} "$@"
# TILE=<png> (optional): this arm's floor tile, copied over the shipped one, then imported; the arm FAILS unless the .ctex is newer than the png.
png=project/boot/prologue/art/arched_line/floor_tile.png
[ -n "$TILE" ] && cp "$TILE" $png
"$GODOT_BIN" --headless --path project --import > build/n29/$n-import.log 2>&1
ctex=$(ls -t project/.godot/imported/floor_tile.png-*.ctex 2>/dev/null | head -1)
if [ -z "$ctex" ] || [ ! "$ctex" -nt "$png" ]; then echo "ARM $n FAILED: stale import ($ctex not newer than $png)"; exit 1; fi
for arm in day dusk; do
  row=arched_line; [ $arm = day ] && row=arched_day
  node tools/art/prologue_yard_stills.mjs --dusk --dressing=$row --out=$PWD/build/n29/$n/$arm > build/n29/$n-$arm.log 2>&1; echo "$(date +%T) $n $arm exit $?"
done
python -W ignore -I evidence/yard29/sweep_measure.py build/n29/$n > build/n29/$n.json
python -W ignore -I evidence/yard29/appliance_delta.py build/n29/$n/dusk 2>&1 | tail -3 > build/n29/$n.app
cat build/n29/$n.json build/n29/$n.app
