#!/bin/bash
# it15: the iGPU sim runs and window grabs of deck40 and switch_handheld that bench.lock blocked at it14.
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
OUT=C:/Users/kazda/kiro/gtai-n10/tmp/handheld/it15
cd /c/Users/kazda/kiro/gtai-wt/n10-handheld || exit 3
for dev in deck40 switch_handheld; do
  for scene in king city_combo; do
    echo "=== $(date +%H:%M:%S) $dev $scene"
    node tools/handheld/sim.mjs --device=$dev --scene=$scene --ticks=1800 --label=${dev}_$scene --out=evidence/n10h/it15/sim --grab=25:$OUT/${dev}_$scene.png
    echo "exit $? ($dev $scene)"
  done
done
echo DONE $(date +%H:%M:%S)
