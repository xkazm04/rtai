#!/bin/bash
# cut_32_all.sh <out.mp4>: the 32 px/m A/B reel from film_32_all.sh's renders: per chapter a
# 640x360 crop at native 32 px/m (no scaling), BEFORE left / AFTER right, frames F0-F1 real time.
set -eu
O=$1
S=/c/Users/kazda/kiro/gtai-d6/scratch-combat-notes
cd $S
FONT=arialbd.ttf
T=$(cygpath -m "$(mktemp -d)")  # ffmpeg is native: no /tmp
lab() { echo "drawtext=fontfile=$FONT:text='$1':x=12:y=10:fontsize=22:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6"; }
i=0
while read -r c f0 f1 x y cap; do
  V="trim=start_frame=$f0:end_frame=$f1,setpts=PTS-STARTPTS,crop=640:360:$x:$y"
  ffmpeg -loglevel error -y -i r32_${c}_before.avi -i r32_$c.avi -filter_complex \
  "[0:v]$V,$(lab BEFORE)[b];[1:v]$V,$(lab AFTER)[a];[b][a]hstack,drawtext=fontfile=$FONT:text='32 px per m real time - ${cap//_/ }':x=(w-tw)/2:y=h-34:fontsize=20:fontcolor=white:box=1:boxcolor=black@0.6:boxborderw=6,fps=60,format=yuv420p" \
  -an -c:v libx264 -crf 18 -preset medium $T/$i.mp4
  echo "file '$T/$i.mp4'" >> $T/l.txt
  i=$((i+1))
done < "${LIST:-/dev/stdin}"
ffmpeg -loglevel error -y -f concat -safe 0 -i $T/l.txt -c copy "$O"
rm -rf "$T"
