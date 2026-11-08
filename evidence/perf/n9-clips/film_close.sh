#!/bin/bash
# film_close.sh: n9 it9 close-ups with the perf HUD (movie mode: the HUD numbers are RELATIVE, LEDGER F4).
# before = main da108c13 (scratch prof3), after = n9-perf HEAD (this worktree; mailbox vsync + the CPU cuts).
# King at 64 px/m (combo), the drive at 48 px/m (tilt70, zoom 1.5). Left before, right after.
set -u
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/perf TMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
T=C:/Users/kazda/kiro/gtai-n9/tmp/perf/film
M=C:/Users/kazda/kiro/gtai-masters/n9/perf
mkdir -p $T
N=${FRAMES:-1200}
run() { # $1 project dir, $2 label, $3 scene, rest user args
  local d=$1 l=$2 sc=$3; shift 3
  rm -f $T/$l.avi
  "$G" --rendering-driver d3d12 --path $d --resolution 1280x800 \
    --write-movie $T/$l.avi --fixed-fps 60 --quit-after $N $sc -- --perf-hud "$@" > $T/$l.log 2>&1
  echo "$l exit $? SE $(grep -c 'SCRIPT ERROR' $T/$l.log)"
}
A=C:/Users/kazda/kiro/gtai-n9/tmp/perf/prof3/project
B=C:/Users/kazda/kiro/gtai-wt/n9-perf/project
KING=(res://dev/arena/arena.tscn --boss=king --bot=boss --seed=2 --rigs --view=combo --ppm=64)
DRIVE=(res://dev/bench/city_bench.tscn --scenario=drive_dense --zoom=1.5 --view=tilt70 --secs=60)
run $A king64-main "${KING[@]}"; run $B king64-head "${KING[@]}"
run $A drive48-main "${DRIVE[@]}"; run $B drive48-head "${DRIVE[@]}"
for s in king64 drive48; do
  ffmpeg -loglevel error -y -i $T/$s-main.avi -i $T/$s-head.avi -filter_complex "[0:v][1:v]hstack=inputs=2" \
    -c:v libx264 -preset veryfast -crf 22 -pix_fmt yuv420p $M/$s-main-vs-n9perf.mp4
  ffmpeg -loglevel error -y -ss 10 -i $M/$s-main-vs-n9perf.mp4 -frames:v 1 -update 1 $M/$s-main-vs-n9perf-10s.png
  echo "$s mp4 $?"
done
