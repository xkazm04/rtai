#!/bin/bash
# n15 hero it16: before/after films of Kerf's and Dent's run16 LEFT sheets (all three left rows +
# the taken alternates): sprint legs 2-3 under --film-turn 135, 180 and -135, one tick a frame.
# before/after sheets in build/s16/<ghost>_run16_left_{before,after}.png.
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero
G='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
P=project/features/souls/art/view/p70
for tag in before after; do
  cp build/s16/kerf_run16_left_$tag.png $P/kerf_run16_left.png
  cp build/s16/dent_run16_left_$tag.png $P/dent_run16_left.png
  timeout 300 "$G" --headless --path project --import > /dev/null 2>&1
  for g in kerf dent; do
    for t in 135 180 -135; do
      bash evidence/s14/tools/k16_film.sh $g s16t${t}_$tag --film-turn=$t
    done
  done
done
