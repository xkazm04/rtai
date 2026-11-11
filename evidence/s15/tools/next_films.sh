#!/bin/bash
# n15 hero it16: (1) Dent's run16 3/4 away alternate 4_16 before/after (--film-diag, legs 2-3, every
# tick); (2) Tonnage's and Ohm's gait at the play zoom (32 px/m), sprint-right + sprint-toward legs,
# one tick a frame, 48 frames: the planted-feet clips LEVEL asks to be looked at.
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
G='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
P=project/features/souls/art/view/p70
for tag in before after; do
  cp build/s16/dent_run16_$tag.png $P/dent_run16.png
  cp build/s16/dent_run16_left_$tag.png $P/dent_run16_left.png
  timeout 300 "$G" --headless --path project --import > /dev/null 2>&1
  bash evidence/s14/tools/k16_film.sh dent s16diag_$tag --film-diag --film-frames=40
  bash evidence/s14/tools/k16_film.sh dent s16t180long_$tag --film-turn=180 --film-frames=40
done
for g in tonnage ohm; do
  echo "$g: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=32 --start=pad --film-form=$g --film-every=1 --film-leg=2 --film-frames=48 --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/gait32_$g 2>&1 | tail -1)"
done
