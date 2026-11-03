#!/bin/sh
# rivet-who-is-this: the TTS read the written "...One" as a stray syllable ("a fraced one", found by tools/audio/stt_check.py: Whisper heard
# it; 4.45-5.12 s of the raw take). Cuts the syllable (4.45 s .. 5.36 s of the raw take) and puts a 0.25 s beat back, then the same loudnorm as process.py.
# Usage: sh tools/audio/fix_who_is_this.sh <raw rivet-who-is-this.mp3> <out.ogg>
ffmpeg -y -v error -i "$1" -f lavfi -t 0.25 -i anullsrc=r=44100:cl=mono -filter_complex \
 "[0:a]aresample=44100,atrim=0:4.45,asetpts=PTS-STARTPTS[a];[0:a]aresample=44100,atrim=5.36,asetpts=PTS-STARTPTS[b];[a][1:a][b]concat=n=3:v=0:a=1,loudnorm=I=-18:TP=-2:LRA=11" \
 -ac 1 -ar 44100 -c:a libvorbis -q:a 4 "$2"
