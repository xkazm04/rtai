#!/bin/bash
# Interleaved rig_bench A/B: ab.sh <out-dir> <view> <pairs> [head-dir]
# base = the 9bbe6d0a worktree, head = this lane's worktree (or another dir).
set -u
OUT=$(cygpath -m "$(mkdir -p "$1"; cd "$1"; pwd)"); VIEW=$2; PAIRS=$3
HEAD=${4:-/c/Users/kazda/kiro/gtai-wt/n10-perf}
BASE=/c/Users/kazda/kiro/gtai-n10/tmp/perf/base
GODOT='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/perf TMP=C:/Users/kazda/kiro/gtai-n10/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/perf
mkdir -p "$OUT"
run() { # arm dir round
  local out="$OUT/$1-$VIEW-$3.json"
  "$GODOT" --headless --path "$2/project" -s res://dev/bench/rig_bench.gd -- --out="$out" --view="$VIEW" > "$OUT/$1-$VIEW-$3.log" 2>&1
  n=$(tasklist //FI "IMAGENAME eq Godot*" 2>/dev/null | grep -c Godot)
  python -c "
import json,sys
d=json.load(open(r'$out'))
for r in d['runs']:
    m=r['metrics']
    print('$1 $VIEW r$3 people=%d p50=%.3f p99=%.3f avg=%.3f godots=$n'%(r['people'],m['rigMsP50'],m['rigMsP99'],m['rigMsAvg']))
" | tee -a "$OUT/summary.txt"
}
for r in $(seq 1 "$PAIRS"); do
  if [ $((r % 2)) -eq 1 ]; then run base "$BASE" "$r"; run head "$HEAD" "$r"; else run head "$HEAD" "$r"; run base "$BASE" "$r"; fi
done
