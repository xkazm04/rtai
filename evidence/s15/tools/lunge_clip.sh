#!/bin/bash
# n15 hero it15: stride_film of one ghost striking every ATTACK_EVERY ticks on the sprint-right leg,
# one tick a frame, GhostLunge off (before) and on (after). usage: lunge_clip.sh <ghost> <ppm> [flags]
# Writes build/film/lc_<ghost>_<ppm>_{before,after}[_<leg>_<ff>].png
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
g=$1; ppm=$2; shift 2
for tag in before after; do
  extra=""; [ $tag = before ] && extra="--ghost-lunge=off"
  echo "$g $ppm $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=400 --fixed-fps=60 -- --rigs --ppm=$ppm --start=pad --film-form=$g --film-attack --film-every=1 --film-leg=2 --film-frames=${FRAMES:-48} $extra "$@" --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/lc_${g}_${ppm}_$tag 2>&1 | grep -i 'ok exit\|FAIL\|error' | tail -1)"
done
