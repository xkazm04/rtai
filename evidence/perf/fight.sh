#!/bin/bash
# fight.sh <label> [extra engine args...]: reel chapter 18's city block fight (the reel's bot and
# loadout, 32 px/m), real time, FightFrames log -> evidence/perf/<label>.json (+ .log).
# EXE=1 runs the exported release (build/export/windows/RTAI.exe) instead of the editor binary;
# TICKS=<n> (default 2100, the reel film's length) ends the run at that sim tick.
# UARGS="--spans=<json>" adds game (user) args, e.g. the per-node span probe.
set -u
L=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/d6-perf-city
export APPDATA=${APPDATA_DIR:-C:/Users/kazda/kiro/gtai-d6/appdata/perf-city}
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
mkdir -p evidence/perf
USER_ARGS=(--bot=reel --ppm=32 --clean --rigs --arena=city --reel=pit --riot
  --loadout=pistol,plasma_rifle,rocket_launcher,molotov
  --frames=$(pwd -W)/evidence/perf/$L.json --frames-ticks=${TICKS:-2100} ${UARGS:-})
if [ "${EXE:-0}" = 1 ]; then
  build/export/windows/RTAI.exe --rendering-driver d3d12 --resolution 1280x720 "$@" -- "${USER_ARGS[@]}" > evidence/perf/$L.log 2>&1
else
  "$G" --rendering-driver d3d12 --resolution 1280x720 "$@" --path project res://dev/arena/arena.tscn -- "${USER_ARGS[@]}" > evidence/perf/$L.log 2>&1
fi
echo "exit $?"
