#!/bin/bash
# it15 E14: resume a quest 1 autosave written on Windows (GTSV slot folder) in the Linux editor, then write one on Linux.
S=/mnt/c/Users/kazda/kiro/gtai-d9x/scratch/it15
P=~/hh14/project
mkdir -p $P/dev/handheld && cp /mnt/c/Users/kazda/kiro/gtai-wt/d9-handheld/project/dev/handheld/save_cross*.gd $P/dev/handheld/
G=~/hh14/Godot_v4.7.2-stable_linux.x86_64
rm -rf ~/hh15/save-win && cp -r $S/save-win ~/hh15/save-win
timeout 300 $G --headless --path $P -s res://dev/handheld/save_cross.gd -- --mode=read --dir=$HOME/hh15/save-win --after=600 > $S/save-read-linux.log 2>&1
echo "read exit $?"; grep -h "save_cross\|resumed\|SCRIPT ERROR" $S/save-read-linux.log
rm -rf ~/hh15/save-lin && mkdir -p ~/hh15/save-lin
timeout 300 $G --headless --path $P -s res://dev/handheld/save_cross.gd -- --mode=write --dir=$HOME/hh15/save-lin --ticks=2400 --after=600 --seed=11 > $S/save-write-linux.log 2>&1
echo "write exit $?"; grep -h "save_cross\|resumed\|SCRIPT ERROR" $S/save-write-linux.log
rm -rf $S/save-lin && cp -r ~/hh15/save-lin $S/save-lin
