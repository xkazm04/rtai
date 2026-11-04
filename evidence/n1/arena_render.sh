#!/usr/bin/env bash
# usage: arena_render.sh <weapon> <name> <frames> [extra arena args...] -> MASTERS/n4/gunplay/<name>/<name>.mp4
set -u
W=$1; N=$2; F=$3; shift 3
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/gunplay-render; mkdir -p $APPDATA
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
OUT=C:/Users/kazda/kiro/gtai-masters/n4/gunplay/$N
mkdir -p "$OUT"
cd /c/Users/kazda/kiro/gtai-wt/n-gunplay
timeout 900 "$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie "$OUT/$N.avi" --quit-after "$F" --path project res://dev/arena/arena.tscn -- --weapon="$W" --telemetry="$OUT/telemetry.json" "$@" > "$OUT/run.log" 2>&1
echo "godot exit $?"
ffmpeg -y -loglevel error -i "$OUT/$N.avi" -c:v libx264 -pix_fmt yuv420p -crf 20 "$OUT/$N.mp4" && rm -f "$OUT/$N.avi"
ffmpeg -y -loglevel error -i "$OUT/$N.mp4" -vf "select='not(mod(n\,$((F/9))))',scale=426:-1,tile=3x3" -frames:v 1 "$OUT/contact.png"
grep -i "error\|gunplay\|arena" "$OUT/run.log" | grep -v "RIDs\|leaked\|resources still" | tail -8
