#!/bin/bash
# it14 E13b: the linux-slice release export (release .so) replays the Windows- and Linux-recorded quest 1 logs
mkdir -p ~/hh14/slice && cd ~/hh14/slice
cp /mnt/c/Users/kazda/kiro/gtai-wt/d9-handheld/build/export/linux-slice/* . && chmod +x RTAI.x86_64
for r in q1-win q1-linux; do
  timeout 120 ./RTAI.x86_64 --headless -- --replay=$HOME/hh14/$r.replay.json > rel-$r.log 2>&1
  echo "$r exit $?"
  grep -h "replay\|SCRIPT ERROR\|booted" rel-$r.log
done
