#!/bin/bash
# film_rt.sh <label> [engine args...]: reel ch 18 city fight in REAL TIME (the exported release,
# vsync as shipped), screen-captured from the game window with gdigrab at 60 fps while FightFrames
# logs every frame -> masters/d6/perf-city/<label>.mp4 + evidence/perf/<label>.json.
set -u
L=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/d6-perf-city
M=C:/Users/kazda/kiro/gtai-masters/d6/perf-city
mkdir -p $M
EXE=1 bash evidence/perf/fight.sh $L "$@" &
FP=$!
sleep ${LEAD:-6}
ffmpeg -loglevel error -y -f gdigrab -framerate 60 -draw_mouse 0 -t ${SECS:-28} -i title="RTAI: Uprising" \
  -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p $M/$L.mp4
wait $FP
echo "film $L $?"
