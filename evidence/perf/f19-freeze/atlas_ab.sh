#!/bin/bash
# F-19 pixel check: bakes the crowd atlas in quest 1 (windowed, --autostart) on the async and sync readback arms
# and writes each atlas PNG (CB_DUMP, a scratch hook in CrowdBaker) to $OUT; md5 compares them.
OUT=${OUT:-C:/Users/kazda/kiro/gtai-n9/tmp/perf/atlas}; mkdir -p "$OUT"
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf
G=/c/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
for arm in "$@"; do
  name=${arm%%:*}; flag=${arm#*:}
  rm -f "$OUT/$name.png"
  CB_DUMP="$OUT/$name.png" timeout 25 "$G" --path project --rendering-driver d3d12 --resolution 1920x1080 --quit-after 600 res://boot/quest1.tscn -- --autostart $flag > "$OUT/$name.log" 2>&1
  echo "$name $(md5sum "$OUT/$name.png" 2>/dev/null | cut -c1-12) $(grep -c 'SCRIPT ERROR' "$OUT/$name.log")"
done
