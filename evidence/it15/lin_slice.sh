#!/bin/bash
# it15 E13c: the linux-slice release export replays an editor-recorded quest 1 log (quest1.tscn, --autostart, 425 ticks)
S=/mnt/c/Users/kazda/kiro/gtai-d9x/scratch/it15
mkdir -p ~/hh15/slice && cd ~/hh15/slice
cp /mnt/c/Users/kazda/kiro/gtai-wt/d9-handheld/build/export/linux-slice/* . && chmod +x RTAI.x86_64
timeout 300 ./RTAI.x86_64 --headless -- --replay=$S/q1ed.replay.json > rel-q1ed.log 2>&1
echo "q1ed exit $?"; grep -h "replay:\|quest1\|SCRIPT ERROR" rel-q1ed.log; cp rel-q1ed.log $S/lin-slice-rel-q1ed.log
