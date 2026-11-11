#!/bin/bash
# n15 hero it12: cursor_sweep films of the drawn ghosts at p55 (--view=tilt).
# usage: p55_films.sh <tag> <ghost>...  -> build/film/h3_<ghost>55_<tag>.png/.tsv (compose.py/pair.py read h3_<name>_*)
tag=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for g in "$@"; do
  echo "$g p55 $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/cursor_sweep.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --view=tilt --sweep-form=$g --sweep-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/h3_${g}55_$tag 2>&1 | grep -i 'ok exit\|FAIL' | tail -1)"
done
