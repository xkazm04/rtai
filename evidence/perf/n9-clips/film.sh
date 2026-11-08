#!/bin/bash
# film.sh: n9 before/after clips with the perf HUD (movie mode: the HUD numbers are RELATIVE, LEDGER F4).
# before = main da108c13 (scratch prof3), after = n9-world 746c2856 (BC7 + combo + bikes; scratch world3).
# -> gtai-masters/n9/perf/<scene>32-main-vs-bc7.mp4 (left before, right after) + an end still.
set -u
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf TMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
T=C:/Users/kazda/kiro/gtai-n9/tmp/perf/film
M=C:/Users/kazda/kiro/gtai-masters/n9/perf
mkdir -p $T
N=${FRAMES:-1200}
run() { # $1 arm dir, $2 label, $3 scene, rest user args
  local d=$1 l=$2 sc=$3; shift 3
  "$G" --rendering-driver d3d12 --path C:/Users/kazda/kiro/gtai-n9/tmp/perf/$d/project --resolution 1280x800 \
    --write-movie $T/$l.avi --fixed-fps 60 --quit-after $N $sc -- --perf-hud "$@" > $T/$l.log 2>&1
  echo "$l exit $? SE $(grep -c 'SCRIPT ERROR' $T/$l.log)"
}
KING=(res://dev/arena/arena.tscn --boss=king --bot=boss --seed=2 --rigs --view=combo)
DRIVE=(res://dev/bench/city_bench.tscn --scenario=drive_dense --zoom=1.0 --view=tilt70 --secs=60)
run prof3 king-main "${KING[@]}" & run world3 king-bc7 "${KING[@]}" & wait
run prof3 drive-main "${DRIVE[@]}" & run world3 drive-bc7 "${DRIVE[@]}" & wait
for s in king drive; do
  ffmpeg -loglevel error -y -i $T/$s-main.avi -i $T/$s-bc7.avi -filter_complex "[0:v][1:v]hstack=inputs=2" \
    -c:v libx264 -preset veryfast -crf 22 -pix_fmt yuv420p $M/${s}32-main-vs-bc7.mp4
  ffmpeg -loglevel error -y -sseof -0.1 -i $M/${s}32-main-vs-bc7.mp4 -frames:v 1 -update 1 $M/${s}32-main-vs-bc7-end.png
  echo "$s mp4 $?"
done
