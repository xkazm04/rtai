#!/bin/bash
# it17: (1) under bench.lock, the Deck row in the city four times, ABBA with and without the window grab, on the code of 78746a1a:
# do E24's three process spikes come back, and is frame 24's pump spike the grab tool's? (2) after the lock is released, the
# director reel with a weapon on the two rows it16 did not run it on.
export APPDATA=C:/Users/kazda/kiro/gtai-n10/appdata/handheld TMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld TEMP=C:/Users/kazda/kiro/gtai-n10/tmp/handheld
export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
cd /c/Users/kazda/kiro/gtai-wt/n10-handheld || exit 3
OUT=evidence/n10h/it17
SCRATCH=C:/Users/kazda/kiro/gtai-n10/tmp/handheld/it17
mkdir -p "$SCRATCH"
LOCK=/c/Users/kazda/kiro/gtai-n10/bench.lock
if ( set -o noclobber; echo handheld > "$LOCK" ) 2>/dev/null; then
  echo "lock taken $(date +%H:%M:%S)"
  n=0
  for arm in grab none none grab; do
    n=$((n+1))
    label=deck_${arm}_r$n
    g=""; [ $arm = grab ] && g="--grab=25:$SCRATCH/$label.png"
    echo "=== $(date +%H:%M:%S) $label"
    node tools/handheld/sim.mjs --device=deck --scene=city_combo --ticks=1800 --label=$label --out="$SCRATCH" $g
    echo "exit $? ($label)"
    cp "$SCRATCH/$label.json" $OUT/sim/
  done
  rm -f /c/Users/kazda/kiro/gtai-n10/bench.lock
  echo "lock released $(date +%H:%M:%S)"
else
  echo "lock held by $(cat "$LOCK"), sim skipped $(date +%H:%M:%S)"
fi
reel() { # row
  "$GODOT_BIN" --headless --path project --quit-after 40000 res://dev/arena/arena.tscn -- --rigs --bot=reel --reel=director --view=combo --device=$1 --loadout=pistol > $OUT/reel/$1_loadout.log 2>&1
  echo $? > $OUT/reel/$1_loadout.exit
  echo "reel $1 exit $(cat $OUT/reel/$1_loadout.exit) $(date +%H:%M:%S)"
}
reel deck40 &
reel switch_handheld &
wait
echo DONE $(date +%H:%M:%S)
