#!/bin/bash
# n31 melee 04f: item 4's impact play takes, main | n31 impacts, one side-by-side film per weapon.
# usage: impact_takes.sh <temp worktree at 0f1e1ce95, native DLLs copied, imported> <weapon>...
# The before plays from the temp tree (its play_take.mjs has no --game-flags: its defaults are the old
# rules, melee sweep off and kill feed off); the after plays HEAD with --melee-sweep=off,--kill-feed=off,
# so both sides play the same rules and only the view-only impacts differ. The temp tree's play_take
# locks its own build/n31/godot.lock, so this script holds the lane lock around it by hand; HEAD's
# play_take takes and frees the lane lock itself (never hold it around that call).
cd "$(dirname "$0")/../.." || exit 1
S=$(pwd); T=$1; shift
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/melee
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
M=C:/Users/kazda/kiro/gtai-masters/n31/melee; O=$S/build/n31/04f/takes; L=$S/build/n31/godot.lock
take() { until (set -o noclobber; echo "04f $$ $(date +%H:%M:%S)" > "$L") 2>/dev/null; do sleep 5; done; }
free() { grep -q "^04f $$ " "$L" && rm "$L"; }
FONT="fontfile='C\:/Windows/Fonts/arialbd.ttf'"
lbl() { echo "drawtext=$FONT:text='$1':x=20:y=20:fontsize=34:fontcolor=white:box=1:boxcolor=black@0.6"; }
CROP="crop=iw/2:ih:iw/4:0,scale=-2:1080"
for w in "$@"; do
  echo "== $w before $(date +%H:%M:%S)"; take
  (cd "$T" && node tools/melee/play_take.mjs --label=impb --weapons="$w" --seed=7 --frames=2100 --ppm=32 --out="$O")
  free
  echo "== $w after $(date +%H:%M:%S)"
  node tools/melee/play_take.mjs --label=impa --weapons="$w" --seed=7 --frames=2100 --ppm=32 --out="$O" --tag=04f \
    --game-flags=--melee-sweep=off,--kill-feed=off || { echo "FAIL after $w"; continue; }
  ffmpeg -hide_banner -loglevel error -y -i "$O/impb_play_$w.mp4" -i "$O/impa_play_$w.mp4" -filter_complex \
    "[0:v]$CROP,$(lbl main)[a];[1:v]$CROP,$(lbl 'n31 impacts')[b];[a][b]hstack=inputs=2,pad=1920:1080:(ow-iw)/2:0" \
    -c:v libx264 -crf 20 -pix_fmt yuv420p -an "$M/beside_impacts_$w.mp4" && echo "beside $w ok $(date +%H:%M:%S)"
done
