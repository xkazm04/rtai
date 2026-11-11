#!/bin/bash
# n15 hero it15: before (build/s15/*_before.png) / after (*_after.png) films of Dent's 3/4 away run row
# (--film-diag, leg 2) and Kerf's 3/4 left run rows (--film-turn=135, legs 2-3), one tick a frame.
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero
G='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
P=project/features/souls/art/view/p70
for tag in before after; do
  cp build/s15/dent_run16_$tag.png $P/dent_run16.png
  cp build/s15/kerf_run16_left_$tag.png $P/kerf_run16_left.png
  timeout 300 "$G" --headless --path project --import > /dev/null 2>&1
  bash evidence/s14/tools/k16_film.sh dent s15diag_$tag --film-diag
  bash evidence/s14/tools/k16_film.sh kerf s15t135_$tag --film-turn=135
done
