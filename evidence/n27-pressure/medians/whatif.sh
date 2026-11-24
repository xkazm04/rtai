#!/bin/bash
# What-if arms for the owner (measured, never applied): each tuner proposal on the after-melee tree 4a3ff4b04, salt 0,
# paired against medians/melee/salt0. Waits until builder call 3 frees Godot (godot-free-3.txt or its pid gone).
L=/c/Users/kazda/kiro/gtai-wt/n23-loop
while [ ! -f $L/evidence/n27-pressure/godot-free-3.txt ] && tasklist //FI "PID eq 57264" | grep -q node; do sleep 30; done
cd $L
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
D=$L/evidence/n27-pressure/medians/whatif
W=C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/medians/whatif
mkdir -p $D
B="--profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=0 --waves=40 --jobs=1"
date +"%H:%M start repair" >> $D/progress.txt
node tools/gauntlet/ablate.mjs --name=repair --rev=4a3ff4b04 --set=project/data/tables/gauntlet.json#/rivet/repair_per_s=12.5 --set=project/data/tables/gauntlet.json#/rivet/repair_delay_s=2.4 -- $B --out=$W/repair > $D/repair.out.txt 2>&1
date +"%H:%M end repair exit $?" >> $D/progress.txt
node tools/gauntlet/ablate.mjs --name=budget --rev=4a3ff4b04 --set=project/data/tables/gauntlet.json#/budget/per_wave=13 -- $B --out=$W/budget > $D/budget.out.txt 2>&1
date +"%H:%M end budget exit $?" >> $D/progress.txt
M=C:/Users/kazda/kiro/gtai-wt/n23-loop/evidence/n27-pressure/medians
node tools/gauntlet/compare.mjs --arm=melee=$M/melee/salt0/batch.json --arm=repair=$W/repair/batch.json --arm=budget=$W/budget/batch.json --out=$W/compare >> $D/progress.txt 2>&1
(cd evidence && node n27-pressure/medians/killers.mjs melee-s0=n27-pressure/medians/melee/salt0 repair-s0=n27-pressure/medians/whatif/repair budget-s0=n27-pressure/medians/whatif/budget > n27-pressure/medians/whatif/killers.md)
date +"%H:%M DONE" > $D/DONE
