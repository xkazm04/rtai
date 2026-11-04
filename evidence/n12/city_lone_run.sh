#!/usr/bin/env bash
# usage: city_lone_run.sh <weapon> [ppm] [frames] -> MASTERS/citylone21_<ppm>_<weapon>/ (mp4, run.log)
# The city proving block (--arena=city --clean --rigs), one lone guard per wave (--lone), Rivet's
# camera (the city camera follows Rivet), fixed 60 fps movie capture.
set -u
W=$1; P=${2:-48}; F=${3:-1500}
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/gunplay
G=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
D=C:/Users/kazda/kiro/gtai-masters/n4/gunplay/citylone21${TAG:-}_${P}_$W
mkdir -p "$D"
cd C:/Users/kazda/kiro/gtai-wt/n-gunplay
"$G" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn --fixed-fps 60 \
  --write-movie "$D/raw.avi" --quit-after "$F" -- --arena=city --weapon="$W" --bot=gunplay \
  --lone --clean --rigs ${CAM:-} ${REACH:+--reach=$REACH} --ppm="$P" --telemetry="$D/telemetry.json" > "$D/run.log" 2>&1
ffmpeg -v error -y -i "$D/raw.avi" -c:v libx264 -pix_fmt yuv420p -crf 20 "$D/citylone21${TAG:-}_${P}_$W.mp4" && rm -f "$D/raw.avi"
echo "$W done: $(grep -c 'SCRIPT ERROR' "$D/run.log") script errors; $(grep 'lone kill' "$D/run.log" | tr '\n' ' ')"
