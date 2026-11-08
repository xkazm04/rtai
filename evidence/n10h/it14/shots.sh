#!/bin/bash
# it14: look-only stills of the rows with no image evidence (discrete GPU, --shot, no timing read)
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
OUT=C:/Users/kazda/kiro/gtai-n10/tmp/handheld/it14
cd /c/Users/kazda/kiro/gtai-wt/n10-handheld || exit 3
shot() { # name device tick extra...
  local name=$1 dev=$2 tick=$3; shift 3
  echo "=== $(date +%H:%M:%S) $name"
  timeout 200 "$G" --rendering-driver d3d12 --path project --fixed-fps 60 res://dev/arena/arena.tscn -- --clean --rigs --device=$dev "$@" --shot=$OUT/$name.png --shot-tick=$tick > $OUT/$name.log 2>&1
  echo "exit $? ($name) SCRIPT_ERROR=$(grep -c 'SCRIPT ERROR' $OUT/$name.log) $(grep -m1 'frame .* at tick' $OUT/$name.log | cut -c1-120)"
}
shot sw_king switch_handheld 900 --boss=king --bot=boss --view=combo
shot d40_king deck40 900 --boss=king --bot=boss --view=combo
shot h1080_king handheld_1080 900 --boss=king --bot=boss --view=combo
shot deck_king_48 deck 900 --boss=king --bot=boss --view=combo --ppm=48
echo DONE
