#!/bin/bash
# E15: per-thread CPU of a Deck-profile run on the iGPU (perf's thread_cpu.ps1), one arm per call.
dev=$1; out=/c/Users/kazda/kiro/gtai-d9x/scratch/it18
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/handheld
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
cd /c/Users/kazda/kiro/gtai-wt/d9-handheld
node tools/handheld/sim.mjs --device=$dev --scene=city --ticks=2400 --label=e15-$dev --out=$out/sim-$dev > $out/sim-$dev.log 2>&1 &
simpid=$!
sleep 18
pid=$(powershell -NoProfile -File C:/Users/kazda/kiro/gtai-d9x/scratch/it18/pid.ps1 -Dev $dev | tr -d '\r')
echo "game pid=$pid" >> $out/sim-$dev.log
powershell -NoProfile -File C:/Users/kazda/kiro/gtai-wt/d9-perf/tools/perf/thread_cpu.ps1 -ProcessId $pid -Seconds 12 > $out/threads-$dev.json 2>&1
wait $simpid
echo "sim exit $?" >> $out/sim-$dev.log
