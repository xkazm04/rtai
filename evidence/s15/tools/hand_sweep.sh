#!/bin/bash
# n15 hero it15: cursor_sweep of each drawn ghost at 64 px/m, GhostHand off (--ghost-ohm-hand=sim, before) and on (after),
# same ticks. Writes build/film/lunge_<ghost>_{before,after}.{png,tsv}
# env: EXTRA=<more flags, e.g. --view=tilt for p55>, TAG=<suffix for the output name>
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
ppm=${PPM:-64}
for g in "$@"; do for tag in before after; do
  extra=""; [ $tag = before ] && extra="--ghost-ohm-hand=sim"
  echo "$g $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/cursor_sweep.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=$ppm --start=pad --sweep-form=$g $extra $EXTRA --sweep-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/hand_${g}_${ppm}${TAG}_$tag 2>&1 | grep -i 'ok exit\|FAIL\|error' | tail -1)"
done; done
