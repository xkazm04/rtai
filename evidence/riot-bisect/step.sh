#!/bin/bash
# usage: step.sh <label> <commit> [runs] [secs]  -> bisect/<label>/riot-N.json
set -u
L=$1; C=$2; RUNS=${3:-3}; SECS=${4:-45}
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
G="$GODOT_BIN"
OUT=/c/Users/kazda/kiro/gtai-masters/eve/visual-fixes/bisect/$L
WT=/c/Users/kazda/kiro/gtai-wt/bis-$L
mkdir -p $OUT
export APPDATA=/c/Users/kazda/kiro/gtai-eve/appdata/bis-$L; T=$APPDATA/Godot/export_templates/4.7.2.stable; mkdir -p $T; [ -f $T/windows_release_x86_64.exe ] || cp /c/Users/kazda/AppData/Roaming/Godot/export_templates/4.7.2.stable/{windows_*,version.txt,icudt_godot.dat} $T/
cd /c/Users/kazda/kiro/gtai-wt/e-fixes
[ -d $WT ] || git worktree add --detach $WT $C > $OUT/log.txt 2>&1
cd $WT
mkdir -p project/native/bin && cp -n /c/Users/kazda/kiro/gtai-wt/int-day/project/native/bin/*.dll project/native/bin/
t0=$(date +%s)
"$G" --headless --path project --import >> $OUT/log.txt 2>&1
"$G" --headless --path project -s res://dev/bake_city.gd >> $OUT/log.txt 2>&1 || echo BAKEFAIL >> $OUT/log.txt
t1=$(date +%s)
mkdir -p build/export/windows-bench
"$G" --headless --path project --export-release windows-bench ../build/export/windows-bench/RTAI-bench.exe >> $OUT/log.txt 2>&1
t2=$(date +%s)
echo "prep bake+import $((t1-t0))s export $((t2-t1))s" >> $OUT/log.txt
ls build/export/windows-bench/RTAI-bench.exe >> $OUT/log.txt 2>&1 || { echo EXPORTFAIL >> $OUT/log.txt; exit 1; }
LOCK=/c/Users/kazda/kiro/gtai-eve/bench.lock
for i in $(seq 1 $RUNS); do
  while true; do
    if [ -f $LOCK ] && [ $(( $(date +%s) - $(date -r $LOCK +%s) )) -gt 1200 ]; then rm -f $LOCK; fi
    ( set -o noclobber; echo visual-fixes > $LOCK ) 2>/dev/null && break
    sleep 15
  done
  ( cd build/export/windows-bench && ./RTAI-bench.exe -- --scenario=riot --label=riot --secs=$SECS --zoom=1.0 --vsync=disabled --out=$OUT/riot-$i.json > $OUT/run-$i.log 2>&1 )
  rm -f $LOCK
  wmic cpu get loadpercentage 2>/dev/null | tr -d '\r\n ' >> $OUT/load.txt; echo >> $OUT/load.txt
done
echo DONE >> $OUT/log.txt
