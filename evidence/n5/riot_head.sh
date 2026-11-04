#!/usr/bin/env bash
# riot + drive on the branch HEAD (settled 6, the shipped value), 2 runs each, under bench.lock
set -u
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/gunplay
cd /c/Users/kazda/kiro/gtai-wt/n-gunplay
LOCK=/c/Users/kazda/kiro/gtai-n4/bench.lock
set -o noclobber; echo gunplay > $LOCK || { echo "lock held"; exit 3; }; set +o noclobber
"$GODOT_BIN" --headless --path project --export-release windows-bench ../build/export/windows-bench/RTAI-bench.exe > evidence/n5/bench/export.log 2>&1
for R in 1 2; do
  for SC in riot drive; do
    OUT=$(pwd -W)/evidence/n5/bench/$SC-$R-$(date +%H%M%S).json
    (cd build/export/windows-bench && ./RTAI-bench.exe -- --scenario=$SC --label=$SC --secs=30 --zoom=$([ $SC = drive ] && echo 0.3 || echo 1.0) --vsync=disabled --out=$OUT > /dev/null 2>&1)
    echo "$SC run $R -> $OUT"
  done
done
rm -f $LOCK
echo done
