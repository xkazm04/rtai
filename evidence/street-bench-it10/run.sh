#!/bin/bash
# 3 alternating riot pairs top/tilt70 under bench.lock, 30 s each, windowed d3d12, vsync off
export APPDATA=C:/Users/kazda/kiro/gtai-n8/appdata/street
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
L=/c/Users/kazda/kiro/gtai-n5/bench.lock
D=C:/Users/kazda/kiro/gtai-n8/scratch/street/bench6
set -o noclobber
echo "street $(date)" > $L || { echo "LOCK HELD"; exit 3; }
set +o noclobber
cd /c/Users/kazda/kiro/gtai-wt/n8-street
for i in 1 2 3; do
 for v in top tilt70; do
  echo "== $i $v $(date +%T) others: $(tasklist | grep -ci godot)"
  timeout 200 "$G" --rendering-driver d3d12 --path project --fixed-fps 60 res://dev/bench/city_bench.tscn -- --scenario=riot --label=riot --secs=30 --zoom=1.0 --vsync=disabled --view=$v --out=$D/riot-$v-$i.json > $D/riot-$v-$i.log 2>&1
  echo "exit $?"
 done
done
rm -f $L
