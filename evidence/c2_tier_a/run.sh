#!/usr/bin/env bash
# c-2 tier A: car_route_trails --tier=a at CAR_DEAD_END_TILES 241 / 1 / 65 (the GDScript constant edited in place for
# the run, restored with git checkout after), plus the tier B default as a regression check against
# evidence/t4_trails/after.json. Out: $OUT/{b_default,a241,a1,a65}.{png,json,log}. One Godot at a time.
set -u
cd "$(dirname "$0")/../.."
OUT=${OUT:-C:/Users/kazda/kiro/gtai-n15/flake/c2a}
mkdir -p "$OUT"
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/tools
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
C=project/features/city/sim/sim_constants.gd
run() { "$G" --headless --path project -s res://dev/sim/car_route_trails.gd -- --out="$OUT/$1" "${@:2}" > "$OUT/$1.log" 2>&1; echo "$1 exit $?"; }
run b_default
for m in 241 1 65; do
  sed -i "s/^const CAR_DEAD_END_TILES: int = [0-9]*/const CAR_DEAD_END_TILES: int = $m/" "$C"
  run "a$m" --tier=a
done
git checkout -- "$C"
git diff --quiet -- "$C" && echo "constants restored"
