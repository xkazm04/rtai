#!/bin/bash
# it16: every gate on the head after the merge of n10-world 3cf3ffdc: import, evidence (no bench), the director reel on the four rows and in the three views.
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
cd /c/Users/kazda/kiro/gtai-wt/n10-handheld || exit 3
OUT=evidence/n10h/it16
LOG=C:/Users/kazda/kiro/gtai-n10/tmp/handheld/evidence-it16.log
"$GODOT_BIN" --headless --path project --import > C:/Users/kazda/kiro/gtai-n10/tmp/handheld/import-it16.log 2>&1
echo "import exit $? $(date +%H:%M:%S)"
reel() { # name, device-or-empty, view
  local dev=""; [ -n "$2" ] && dev="--device=$2"
  "$GODOT_BIN" --headless --path project --quit-after 40000 res://dev/arena/arena.tscn -- --rigs --bot=reel --reel=director --view=$3 $dev > $OUT/reel/$1.log 2>&1
  echo $? > $OUT/reel/$1.exit
  echo "reel $1 exit $(cat $OUT/reel/$1.exit) $(date +%H:%M:%S)"
}
( node tools/evidence/run.mjs --no-bench > "$LOG" 2>&1; echo "evidence exit $? $(date +%H:%M:%S)"; echo "exit done" >> "$LOG" ) &
reel deck deck combo &
reel deck40 deck40 combo &
reel handheld_1080 handheld_1080 combo &
reel switch_handheld switch_handheld combo &
wait
for v in top tilt70 combo; do reel $v "" $v & done
wait
echo DONE $(date +%H:%M:%S)
