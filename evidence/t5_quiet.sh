#!/usr/bin/env bash
# Wait for a quiet machine (no other Godot over 200 MB, no bench.lock), then run t5_aab.sh under the bench lock.
# Gives up at the deadline (HHMM). Usage: t5_quiet.sh <rounds> <deadline HHMM> <out.tsv>
set -u
LOCK=C:/Users/kazda/kiro/gtai-n15/bench.lock
heavy() { powershell -NoProfile -Command "(Get-Process | Where-Object { \$_.ProcessName -like 'Godot*' -and \$_.WorkingSet64 -gt 200MB } | Measure-Object).Count" | tr -d '\r'; }
while :; do
  now=$(date +%H%M)
  if [ "$now" -ge "$2" ]; then echo "t5_quiet: gave up at $(date +%H:%M:%S), never quiet"; exit 3; fi
  h=$(heavy)
  if [ "$h" = "0" ] && [ ! -e "$LOCK" ]; then
    q2=0; sleep 20; h2=$(heavy); [ "$h2" = "0" ] && q2=1
    if [ $q2 = 1 ] && ( set -o noclobber; echo "n15-tools t-5 $(date)" > "$LOCK" ) 2>/dev/null; then
      echo "t5_quiet: quiet at $(date +%H:%M:%S), lock taken"
      bash /c/Users/kazda/kiro/gtai-wt/n15-tools/evidence/t5_aab.sh "$1" > "$3"
      rc=$?; rm -f "$LOCK"; echo "t5_quiet: done $(date +%H:%M:%S) rc $rc, lock removed"; exit $rc
    fi
  fi
  sleep 30
done
