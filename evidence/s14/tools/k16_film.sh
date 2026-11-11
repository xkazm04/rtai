#!/bin/bash
# n15 hero it14: stride_film of one ghost (sprint legs every tick) -> build/film/k16_<tag>
# usage: k16_film.sh <form> <tag> [extra flags]
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
f=$1; tag=$2; shift 2
mkdir -p build/film
timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --film-form=$f --film-every=1 --film-leg=2 --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/k16_${f}_$tag "$@" 2>&1 | tail -2
