#!/bin/bash
# n29-05 frame cost: before = temp row arched_n28 (c649a15d6's arched_line), after = arched_line at HEAD.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
LOCK=C:/Users/kazda/kiro/gtai-n29/bench.lock
O=$PWD/build/frame29${SUFFIX}; mkdir -p $O
if [ -f $LOCK ]; then
  age=$(( $(date +%s) - $(stat -c %Y $LOCK) ))
  if [ $age -gt 1200 ]; then rm -f $LOCK; echo "stale lock removed ($age s)"; fi
fi
set -o noclobber
for i in $(seq 1 60); do
  if { echo "n29-yard hall-finish $$ $(date +%s)" > $LOCK; } 2>/dev/null; then got=1; break; fi
  echo "LOCK HELD: $(cat $LOCK)"; sleep 10
done
set +o noclobber
[ -z "$got" ] && { echo "SKIPPED: no lock in 10 min"; exit 3; }
trap 'rm -f $LOCK' EXIT
echo "load start: $(cat $GTAI_CAP_STATUS 2>/dev/null)"
run() {
  echo "$(date +%T) r$1 $2"
  node build/n29-05/probe.mjs --yard-dressing=$3 --out=$O/r$1_$2.json > $O/r$1_$2.log 2>&1
  echo "  exit $? $(tail -1 $O/r$1_$2.log)"
  powershell -NoProfile -Command "(Get-Counter '\Processor(_Total)\% Processor Time' -SampleInterval 1 -MaxSamples 3 | % {\$_.CounterSamples.CookedValue} | Measure-Object -Average).Average" | sed 's/^/  cpu% after: /'
}
run 1 before arched_n28; run 1 after arched_line
run 2 after arched_line; run 2 before arched_n28
run 3 before arched_n28; run 3 after arched_line
echo "load end: $(cat $GTAI_CAP_STATUS 2>/dev/null)"
echo "$(date +%T) done"
