#!/bin/bash
# it13: item 3's quiet release riot: main vs head (40e719fd code, windows-bench-exists) vs its twin (A/A), wall-clock, under bench.lock.
# Waits for 4 clean polls (0 Godot/RTAI, no lock); a side poller logs every process of those names during the whole A/B.
set -u
ROOT=/c/Users/kazda/kiro/gtai-n10; T=$ROOT/tmp/perf; H=/c/Users/kazda/kiro/gtai-wt/n10-perf; LOCK=$ROOT/bench.lock
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/perf TMP=C:/Users/kazda/kiro/gtai-n10/tmp/perf TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/perf
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
POLL=$T/quiet_it13.log; GIVE_UP=$(date -d '05:10' +%s); streak=0; : > "$POLL"
while :; do
  n=$(tasklist //NH //FO CSV 2>/dev/null | grep -i -c 'godot\|rtai')
  now=$(date +%s); lock=0; [ -e "$LOCK" ] && lock=1
  echo "$(date +%H:%M:%S) godots=$n lock=$lock" >> "$POLL"
  if [ "$n" -eq 0 ] && [ "$lock" -eq 0 ]; then streak=$((streak+1)); else streak=0; fi
  [ "$streak" -ge 4 ] && break
  [ "$now" -ge "$GIVE_UP" ] && { echo "NEVER QUIET by 05:10; polls: $(wc -l < "$POLL")"; exit 4; }
  sleep 20
done
( set -o noclobber; echo perf > "$LOCK" ) 2>/dev/null || { echo "lost lock race"; exit 3; }
trap 'rm -f "$LOCK"; kill $SIDE 2>/dev/null' EXIT
echo "quiet at $(date +%H:%M:%S), starting the A/B"
SIDELOG=$T/quiet_it13_during.log; : > "$SIDELOG"
( while :; do echo "$(date +%H:%M:%S) $(tasklist //NH //FO CSV 2>/dev/null | grep -i 'godot\|rtai' | cut -d, -f1,2 | tr '\n' ' ')" >> "$SIDELOG"; sleep 3; done ) &
SIDE=$!
cd "$H" && node tools/perf/ab.mjs --no-lock --scenes=riotc --pairs=8 --arms=main@exe-windows-bench-main:,head@exe-windows-bench-exists:,twin@exe-windows-bench-exists2: --out=evidence/perf/n10-riotc-quiet > "$T/ab_riot_quiet_it13.log" 2>&1
echo "ab exit $? at $(date +%H:%M:%S)"
