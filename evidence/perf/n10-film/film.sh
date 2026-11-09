#!/bin/bash
# n10 it9: the city riot at combo, before (main 9bbe6d0a) vs after (n10-perf head), 32 and 48 px/m, no HUD so a per-frame PSNR can compare the arms.
# -> gtai-masters/n10/perf/riot<ppm>-main-vs-n10perf.mp4 (left before, right after) + a still; psnr logs next to this script.
set -u
ROOT=C:/Users/kazda/kiro/gtai-n10
export APPDATA=$ROOT/appdata/perf TMP=$ROOT/tmp/perf TEMP=$ROOT/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
T=$ROOT/tmp/perf/film; M=C:/Users/kazda/kiro/gtai-masters/n10/perf; E=C:/Users/kazda/kiro/gtai-wt/n10-perf/evidence/perf/n10-film
BASE=$ROOT/tmp/perf/base/project; HEAD=C:/Users/kazda/kiro/gtai-wt/n10-perf/project
mkdir -p $T $M
N=${FRAMES:-1200}
run() { # arm dir label zoom
  "$G" --rendering-driver d3d12 --path "$2" --resolution 1280x800 --write-movie "$T/$3.avi" --fixed-fps 60 --quit-after $N \
    res://dev/bench/city_bench.tscn -- --scenario=riot --zoom=$4 --view=combo --secs=60 > "$E/$3.log" 2>&1
  echo "$3 exit $? SE $(grep -c 'SCRIPT ERROR' "$E/$3.log")"
}
cp -n /c/Windows/Fonts/arial.ttf "$T/arial.ttf"
cap() { echo "drawtext=fontfile=arial.ttf:text='$1':x=12:y=12:fontsize=26:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6"; }
cd "$T"   # ffmpeg's filter parser splits on the drive colon, so the font and stats file go by relative name
for z in 1.0:32 1.5:48; do
  zoom=${z%:*}; ppm=${z#*:}
  if [ "${SKIP_FILM:-0}" != 1 ]; then run base "$BASE" main$ppm $zoom & run head "$HEAD" head$ppm $zoom & wait; fi
  ffmpeg -loglevel error -y -i main$ppm.avi -i head$ppm.avi -lavfi psnr=stats_file=psnr$ppm.log -f null - 2> $E/psnr$ppm.txt
  mv -f psnr$ppm.log $E/psnr$ppm.log
  ffmpeg -loglevel error -y -i main$ppm.avi -i head$ppm.avi -filter_complex "[0:v]$(cap "before main 9bbe6d0a")[a];[1:v]$(cap "after n10-perf head")[b];[a][b]hstack=inputs=2" \
    -c:v libx264 -preset veryfast -crf 22 -pix_fmt yuv420p $M/riot$ppm-main-vs-n10perf.mp4
  ffmpeg -loglevel error -y -sseof -0.1 -i $M/riot$ppm-main-vs-n10perf.mp4 -frames:v 1 -update 1 $M/riot$ppm-main-vs-n10perf-end.png
  ffmpeg -loglevel error -y -ss 10 -i $M/riot$ppm-main-vs-n10perf.mp4 -frames:v 1 -update 1 $M/riot$ppm-main-vs-n10perf-10s.png
  echo "riot$ppm mp4 $?"
done
