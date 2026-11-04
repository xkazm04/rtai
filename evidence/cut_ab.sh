#!/bin/bash
# cut_ab.sh <out.mp4> <before.avi> <after.avi> <crop x> <crop y> <first frame> <last frame> <slow> <caption>
# One side-by-side A/B segment (640x360 crops, BEFORE left, AFTER right, 1280x360), <slow> = PTS
# factor (1 = real time, 2.5 = 0.4x); the caption and the BEFORE/AFTER labels burned in.
set -eu
O=$1; B=$2; A=$3; X=$4; Y=$5; F0=$6; F1=$7; SL=$8; CAP=$9
FONT=arialbd.ttf  # copied into the cwd (a drive colon breaks the filter graph)
[ -f arialbd.ttf ] || cp /c/Windows/Fonts/arialbd.ttf .
lab() { echo "drawtext=fontfile=$FONT:text='$1':x=12:y=10:fontsize=22:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6"; }
V="trim=start_frame=$F0:end_frame=$F1,setpts=$SL*(PTS-STARTPTS),crop=640:360:$X:$Y"
ffmpeg -loglevel error -y -i "$B" -i "$A" -filter_complex \
"[0:v]$V,$(lab BEFORE)[b];[1:v]$V,$(lab AFTER)[a];[b][a]hstack,drawtext=fontfile=$FONT:text='$CAP':x=(w-tw)/2:y=h-34:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6,fps=60,format=yuv420p" \
-c:v libx264 -crf 18 -preset medium "$O"
