#!/usr/bin/env bash
# riot-only A/B of blood_fx.json game.settled_redraw_ticks (6 vs 30), same load, back to back, under bench.lock
set -u
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
export APPDATA=C:/Users/kazda/kiro/gtai-n4/appdata/gunplay
cd /c/Users/kazda/kiro/gtai-wt/n-gunplay
LOCK=/c/Users/kazda/kiro/gtai-n4/bench.lock
set -o noclobber; echo gunplay > $LOCK || { echo "lock held"; exit 3; }; set +o noclobber
J=project/features/fx/noir/blood_fx.json
for S in 6 30 6 30; do
  sed -i "s/\"settled_redraw_ticks\": [0-9]*/\"settled_redraw_ticks\": $S/" $J
  "$GODOT_BIN" --headless --path project --export-release windows-bench ../build/export/windows-bench/RTAI-bench.exe > evidence/n3/bench/export-$S.log 2>&1
  OUT=$(pwd -W)/evidence/n3/bench/riot-s$S-$(date +%H%M%S).json
  (cd build/export/windows-bench && ./RTAI-bench.exe -- --scenario=riot --label=riot --secs=30 --zoom=1.0 --vsync=disabled --out=$OUT > /dev/null 2>&1)
  echo "settled=$S -> $OUT"
done
sed -i "s/\"settled_redraw_ticks\": [0-9]*/\"settled_redraw_ticks\": 6/" $J
rm -f $LOCK
echo done
