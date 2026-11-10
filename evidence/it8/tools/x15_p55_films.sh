#!/bin/bash
# n15 hero it8: film each p55 weapon on cursor_sweep's STAND leg under --view=tilt (the boss pitch).
# usage: x15_p55_films.sh before|after <weapon>...   (writes build/film/p55_<w>_<tag>.png)
tag=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for w in "$@"; do
  echo "$w $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/cursor_sweep.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --view=tilt --loadout=$w --sweep-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/p55_${w}_$tag 2>&1 | grep -i 'ok exit\|FAIL' | tail -1)"
done
