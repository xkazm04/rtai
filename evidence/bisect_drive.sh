#!/bin/bash
# bisect_drive.sh <commit> <label>: throwaway worktree at <commit>, native DLLs, import, bake,
# export windows-bench, drive scenario 2 x 40 s -> evidence/bench-bisect/<label>-run<n>.json
set -u
C=$1; L=$2
ROOT=/c/Users/kazda/kiro/gtai-wt/n-showcase
WT=/c/Users/kazda/kiro/gtai-n4/scratch-showcase/wt-$L
OUT=$ROOT/evidence/bench-bisect; mkdir -p $OUT
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/showcase
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
cd $ROOT
[ -d $WT ] || git worktree add --detach $WT $C > /dev/null 2>&1
cp -r $ROOT/project/native/bin $WT/project/native/ 2>/dev/null
cd $WT
[ -f build/export/windows-bench/RTAI-bench.exe ] || {
"$G" --headless --path project --import > $OUT/$L-import.log 2>&1
"$G" --headless --path project -s res://dev/bake_city.gd > $OUT/$L-bake.log 2>&1
mkdir -p build/export/windows-bench
"$G" --headless --path project --export-release windows-bench ../build/export/windows-bench/RTAI-bench.exe > $OUT/$L-export.log 2>&1
}
[ "${3:-}" = prep ] && exit 0
cd build/export/windows-bench
for n in 1 2; do
  ./RTAI-bench.exe -- --scenario=drive --label=drive --secs=40 --zoom=0.3 --vsync=disabled --out=C:/Users/kazda/kiro/gtai-wt/n-showcase/evidence/bench-bisect/$L-run$n.json > $OUT/$L-run$n.log 2>&1
done
python -c "
import json
for n in (1,2):
  try:
    m=json.load(open(r'$OUT/$L-run%d.json'%n))['metrics']; print('$L run',n,'p99',m['p99CpuMs'],'avg',m.get('avgFrameMs'),'visible',m.get('visibleAvg'))
  except Exception as e: print('$L run',n,'ERR',e)
" >> $OUT/summary.txt
