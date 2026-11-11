#!/bin/bash
# n15 hero it12: stride_film runs for the left rows. usage: left_films.sh <tag> <form> <act flag> <turn>...
# writes build/film/l12_<form>_<turn>_<tag>.png (one row per leg: walk, walk toward, sprint, sprint toward)
tag=$1; form=$2; act=$3; shift 3
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for t in "$@"; do
  echo "$form $t $tag: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/stride_film.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad --film-form=$form $act --film-turn=$t --film-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/l12_${form}_${t}_$tag 2>&1 | grep -i 'ok exit\|FAIL\|ERROR' | tail -1)"
done
