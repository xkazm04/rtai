#!/bin/bash
# it15 E13c: the linux-dev release export (release .so, main.tscn) replays editor- and release-recorded World logs,
# then records its own (seed 13), which the Windows release exe replays afterwards.
S=/mnt/c/Users/kazda/kiro/gtai-d9x/scratch/it15
mkdir -p ~/hh15 && cd ~/hh15
cp $S/linuxdev/* . && chmod +x RTAI.x86_64
for r in q1-win q1-linux winrel; do
  timeout 300 ./RTAI.x86_64 --headless -- --replay=$S/$r.replay.json > rel-$r.log 2>&1
  echo "$r exit $?"
  grep -h "replay:\|SCRIPT ERROR" rel-$r.log
done
timeout 300 ./RTAI.x86_64 --headless --quit-after 3600 -- --record=$S/linrel.replay.json --seed=17 > rec.log 2>&1
echo "record exit $?"; grep -h "replay:\|SCRIPT ERROR" rec.log
timeout 300 ./RTAI.x86_64 --headless -- --replay=$S/linrel.replay.json > rel-linrel.log 2>&1
echo "linrel on linux exit $?"; grep -h "replay:" rel-linrel.log
cp rel-*.log rec.log $S/ 
