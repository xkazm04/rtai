#!/bin/bash
# it16: the four rows windowed on the iGPU in the city in combo after the merge of n10-world 3cf3ffdc. Run under bench.lock.
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
OUT=C:/Users/kazda/kiro/gtai-n10/tmp/handheld/it16
mkdir -p "$OUT"
cd /c/Users/kazda/kiro/gtai-wt/n10-handheld || exit 3
for dev in deck deck40 handheld_1080 switch_handheld; do
  echo "=== $(date +%H:%M:%S) $dev"
  node tools/handheld/sim.mjs --device=$dev --scene=city_combo --ticks=1800 --label=${dev}_city_combo --out=evidence/n10h/it16/sim --grab=25:$OUT/${dev}_city_combo.png
  echo "exit $? ($dev)"
done
echo DONE $(date +%H:%M:%S)
