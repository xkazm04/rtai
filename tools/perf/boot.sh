#!/bin/bash
# Boot-to-first-frame upper bound (LEDGER): the wall time of a process that boots, draws ONE frame
# (--quit-after 1) and exits, windowed D3D12 1920x1080, interleaved exe / editor N rounds.
# usage: tools/perf/boot.sh [rounds]   (run from the repo root; export the windows-bench exe first)
N=${1:-5}
export APPDATA=${APPDATA_PERF:-C:/Users/kazda/kiro/gtai-d9x/appdata/perf}
G=${GODOT_BIN:-C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe}
EXE=build/export/windows-bench/RTAI-bench.exe
A=(--screen 0 --rendering-driver d3d12 --resolution 1920x1080 --quit-after 1)
U=(-- --scenario=riot --secs=1 --out=build/boot-probe.json)
ms() { local t0; t0=$(date +%s%N); "$@" > /dev/null 2>&1; echo $(( ($(date +%s%N) - t0) / 1000000 )); }
for i in $(seq 1 "$N"); do
  e=$(ms "$EXE" "${A[@]}" "${U[@]}")
  d=$(ms "$G" --path project "${A[@]}" res://dev/bench/city_bench.tscn "${U[@]}")
  echo "round $i: exe ${e} ms, editor ${d} ms"
done
