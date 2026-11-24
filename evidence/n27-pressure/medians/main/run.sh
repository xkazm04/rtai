#!/bin/bash
# Median death waves on main a3b3f1466: salt 0 then salt 1, args of n26 (profile all, greedy, wheel, 10 seeds, 40 waves).
cd /c/Users/kazda/kiro/gtai-wt/n23-loop
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
D=evidence/n27-pressure/medians/main
for s in 0 1; do
  date +"%H:%M start salt $s" >> $D/progress.txt
  node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=$s --waves=40 --jobs=1 --out=$(pwd -W)/$D/salt$s > $D/salt$s.out.txt 2>&1
  date +"%H:%M end salt $s exit $?" >> $D/progress.txt
done
date +"%H:%M DONE" > $D/DONE
