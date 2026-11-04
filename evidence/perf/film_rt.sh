#!/bin/bash
# film_rt.sh <label> [engine args...]: reel ch 18 city fight in REAL TIME (the exported release,
# vsync as shipped), screen-captured at 60 fps while FightFrames logs every frame
# -> masters/d6/perf-city/<label>.mp4 + evidence/perf/<label>.json.
# Capture: Desktop Duplication (ddagrab) of the window's client rect (client_rect.ps1). gdigrab's
# title mode grabs a D3D12 flip-model window black. The window is --always-on-top because the
# desktop is shared (the owner works on it): anything above the window would be filmed. --screen 0
# keeps it on the primary display (ddagrab output 0); a window on the second display failed.
set -u
L=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/d6-perf-city
M=C:/Users/kazda/kiro/gtai-masters/d6/perf-city
mkdir -p $M
EXE=1 bash evidence/perf/fight.sh $L --screen 0 --always-on-top "$@" &
FP=$!
sleep ${LEAD:-6}
read X Y W H < <(powershell -NoProfile -ExecutionPolicy Bypass -File evidence/perf/client_rect.ps1)
echo "window client $X $Y ${W}x$H"
ffmpeg -loglevel error -y -f lavfi \
  -i "ddagrab=output_idx=0:framerate=60:draw_mouse=0:offset_x=$X:offset_y=$Y:video_size=${W}x${H},hwdownload,format=bgra" \
  -t ${SECS:-28} -c:v libx264 -preset veryfast -crf 18 -pix_fmt yuv420p $M/$L.mp4
wait $FP
echo "film $L $?"
