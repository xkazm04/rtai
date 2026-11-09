#!/bin/bash
# A/A control for film.sh: identical code twice (head vs head, main vs main) at 32 px/m, 1200 frames, against the same frame diff.
set -u
ROOT=C:/Users/kazda/kiro/gtai-n10; export APPDATA=$ROOT/appdata/perf TMP=$ROOT/tmp/perf TEMP=$ROOT/tmp/perf
G="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"
T=$ROOT/tmp/perf/film; E=C:/Users/kazda/kiro/gtai-wt/n10-perf/evidence/perf/n10-film
BASE=$ROOT/tmp/perf/base/project; HEAD=C:/Users/kazda/kiro/gtai-wt/n10-perf/project
run() { "$G" --rendering-driver d3d12 --path "$1" --resolution 1280x800 --write-movie "$T/$2.avi" --fixed-fps 60 --quit-after 1200 \
    res://dev/bench/city_bench.tscn -- --scenario=riot --zoom=1.0 --view=combo --secs=60 > "$E/$2.log" 2>&1; echo "$2 exit $? SE $(grep -c 'SCRIPT ERROR' "$E/$2.log")"; }
run "$HEAD" head32b & run "$BASE" main32b & wait
cd "$T"
for pair in head32:head32b main32:main32b; do a=${pair%:*}; b=${pair#*:}
  ffmpeg -loglevel error -y -i $a.avi -i $b.avi -lavfi psnr=stats_file=psnr_$b.log -f null - 2>/dev/null; mv -f psnr_$b.log $E/psnr_aa_$b.log
done
