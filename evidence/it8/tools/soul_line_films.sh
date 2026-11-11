#!/bin/bash
# n15 hero it8: each drawn ghost on stride_film, the teal soul line off (before) and on (after), at
# 64 and 32 px/m. Writes build/film/soul_<ghost>_<ppm>_{before,after}.png
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for g in "$@"; do for ppm in 64 32; do for tag in before after; do
  extra=""; [ $tag = before ] && extra="--ghost-soul-line=off"
  echo "$g $ppm $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=$ppm --start=pad --film-form=$g $extra --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/soul_${g}_${ppm}_$tag 2>&1 | grep -i 'ok exit\|FAIL' | tail -1)"
done; done; done
