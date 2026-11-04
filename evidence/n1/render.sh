#!/usr/bin/env bash
# usage: render.sh <weapon> <name> [frames] [extra args...]   -> MASTERS/n4/gunplay/<name>/<name>.mp4
set -u
W=$1; N=$2; F=${3:-900}; shift 3 || shift $#
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/gunplay
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
OUT=C:/Users/kazda/kiro/gtai-masters/n4/gunplay/$N
mkdir -p "$OUT"
cd /c/Users/kazda/kiro/gtai-wt/n-gunplay
timeout 900 "$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie "$OUT/$N.avi" --quit-after "$F" --path project res://dev/gunplay/pistol_fight.tscn -- --out="$OUT" --weapon="$W" "$@" > "$OUT/run.log" 2>&1
echo "godot exit $?"
ffmpeg -y -loglevel error -i "$OUT/$N.avi" -c:v libx264 -pix_fmt yuv420p -crf 20 "$OUT/$N.mp4" && rm -f "$OUT/$N.avi"
grep -i "error\|summary\|shots\|kills" "$OUT/run.log" | grep -v "RIDs\|leaked" | tail -8
