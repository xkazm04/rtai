#!/bin/bash
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
B=build/n29-07; M=C:/Users/kazda/kiro/gtai-masters/n29/yard; mkdir -p $M
ffmpeg -y -loglevel error -i $B/before.avi -i $B/after.avi -filter_complex "[0:v]crop=960:1080:480:0[a];[1:v]crop=960:1080:480:0[b];[a][b]hstack=inputs=2,fps=60,scale=in_range=full:out_range=tv,format=yuv420p[v]" -map "[v]" -c:v libx264 -crf 18 -preset medium -pix_fmt yuv420p -movflags +faststart $M/hall_front_before_after_32ppm.mp4
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate,pix_fmt,nb_frames:format=duration -of compact $M/hall_front_before_after_32ppm.mp4
