#!/bin/bash
# view lab: a clip of the seeded King fight in a view. film.sh <view> <frames> <ppm> <out.avi> [extra flags]
export APPDATA=C:/Users/kazda/kiro/gtai-n7x/appdata/view
G=${GODOT_BIN:-/c/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe}
V=$1; N=$2; P=$3; O=$4; shift 4
"$G" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn --fixed-fps 60 \
  --write-movie "$O" --quit-after "$N" -- \
  --rigs --boss=king --bot=boss --bot-human --seed=2 --boss-cam --ppm=$P --view=$V "$@" > "${O%.avi}.log" 2>&1
echo "$V exit $? errors $(grep -c 'SCRIPT ERROR' "${O%.avi}.log")"
