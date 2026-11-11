#!/bin/bash
# n15 hero it16: Dent's and Kerf's sprints at the play zoom (32 px/m), one tick a frame, 48 frames,
# legs 2-3 (sprint right + toward) and the diagonals (--film-diag) -> build/film/run32_<g>[_diag]
# for feet_trace.py / hold_ride.py.
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for g in dent kerf; do
  for v in "" "--film-diag" "--film-turn=180"; do
    t=${v//[^a-z0-9]/}; t=${t#film}
    echo "$g $v: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=32 --start=pad --film-form=$g --film-every=1 --film-leg=2 --film-frames=48 $v --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/run32_${g}_${t:-right} 2>&1 | tail -1)"
  done
done
