#!/bin/bash
# Median death waves on the scratch join tree (main + other lanes merged, detached). Usage: join.sh <arm name>
# Runs in C:/Users/kazda/kiro/gtai-n27/scratch/pressure-join, writes to the lane's evidence/n27-pressure/medians/<arm>/.
ARM=$1
cd /c/Users/kazda/kiro/gtai-n27/scratch/pressure-join
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
D=/c/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/medians/$ARM
DW=C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/medians/$ARM
mkdir -p $D
git log --oneline -1 > $D/tree.txt
"$GODOT_BIN" --headless --path project --import > $D/import.log 2>&1
for s in 0 1; do
  date +"%H:%M start salt $s" >> $D/progress.txt
  node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=$s --waves=40 --jobs=1 --out=$DW/salt$s > $D/salt$s.out.txt 2>&1
  date +"%H:%M end salt $s exit $?" >> $D/progress.txt
  node tools/gauntlet/report.mjs --batch=$DW/salt$s/batch.json >> $D/salt$s.out.txt 2>&1
done
node tools/gauntlet/tune.mjs floor --before=$DW/salt0/batch.json --null=$DW/salt1/batch.json --out=$DW/floors.md >> $D/salt1.out.txt 2>&1
date +"%H:%M DONE" > $D/DONE
