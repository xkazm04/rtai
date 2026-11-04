#!/bin/bash
# reel.sh <name> <cut dir name> [city seconds offset]: the morning reel = the director chapters of
# cut-<cut dir name> (evidence/cut.sh) + chapter 17, 15 s of the pit fight on the city block at
# 32 px/m (a fresh fixed-fps film on HEAD, its gun beat from <offset> s, default 16), titled
# like the chapters -> gtai-masters/n4/showcase/<name>.mp4.
set -u
N=$1; C=$2; OFF=${3:-16}
cd /c/Users/kazda/kiro/gtai-wt/n-showcase
S=C:/Users/kazda/kiro/gtai-n4/scratch-showcase
D=$S/cut-$C
M=C:/Users/kazda/kiro/gtai-masters/n4/showcase
bash evidence/film.sh city-raw-$N 32 2100 --arena=city --reel=pit --riot \
  --loadout=pistol,plasma_rifle,rocket_launcher,molotov
mv $M/city-raw-$N.mp4 $S/city-raw-$N.mp4
cap="drawtext=fontfile='C\:/Windows/Fonts/arialbd.ttf':text='17   CITY BLOCK':x=28:y=28:fontsize=30:fontcolor=0x1B1A17:box=1:boxcolor=0xF2E8D5:boxborderw=14"
ffmpeg -y -loglevel error -f lavfi -i anullsrc=r=44100:cl=stereo -ss $OFF -t 15 -i $S/city-raw-$N.mp4 \
  -map 1:v -map 0:a -shortest -vf "$cap" -c:v libx264 -pix_fmt yuv420p -crf 20 -r 60 -c:a aac \
  $D/city_free.mp4
cp $D/list.txt $D/list-full.txt
echo "file 'city_free.mp4'" >> $D/list-full.txt
ffmpeg -y -loglevel error -f concat -safe 0 -i $D/list-full.txt -c copy $M/$N.mp4
echo "reel $N $? ($(ffprobe -v error -show_entries format=duration -of csv=p=0 $M/$N.mp4) s)"
