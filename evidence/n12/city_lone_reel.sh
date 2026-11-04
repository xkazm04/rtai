#!/usr/bin/env bash
# usage: city_lone_reel.sh <out.mp4> <weapon>:<kill_tick> ... -> one full-frame 5.5 s cut per gun
# (2.5 s before the kill, 3 s after), labelled, concatenated, sound off.
# env: PPM (label, default 48), PFX (run dir prefix, e.g. 64_ for lone19_64_<gun>/)
set -eu
OUT=$1; shift
M=C:/Users/kazda/kiro/gtai-masters/n4/gunplay
T=$(cygpath -m "$(mktemp -d)")
i=0; : > "$T/list.txt"
for spec in "$@"; do
  w=${spec%%:*}; k=${spec#*:}; i=$((i+1))
  ss=$(python -c "print(max(0.0,$k/60-2.5))")
  label=$(echo "$w" | tr '_' ' ')
  ffmpeg -v error -y -ss "$ss" -t ${DUR:-5.5} -i "$M/citylone21${TAG:-}_${PPM:-48}_$w/citylone21${TAG:-}_${PPM:-48}_$w.mp4" \
    -vf "drawtext=fontfile='C\:/Windows/Fonts/arialbd.ttf':text='$label  (one guard, city block, ${PPM:-48} px/m)':fontcolor=white:fontsize=30:box=1:boxcolor=black@0.6:boxborderw=8:x=16:y=16" \
    -c:v libx264 -pix_fmt yuv420p -crf 20 -r 60 "$T/$i.mp4"
  echo "file '$T/$i.mp4'" >> "$T/list.txt"
done
ffmpeg -v error -y -f concat -safe 0 -i "$T/list.txt" -c copy "$OUT"
rm -rf "$T"
