#!/bin/bash
# n15 hero it13: put one art state in place (before|after from build/rt/<state>/), --import, then cursor_sweep films.
# usage: rt_films.sh <state> <ghost>@<70|55>...   -> build/film/h3_<ghost>[55]_rt<state>.png/.tsv
st=$1; shift
cd /c/Users/kazda/kiro/gtai-wt/n15-hero
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/hero GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
V=project/features/souls/art/view
for f in build/rt/$st/*.png; do n=$(basename $f); cp $f $V/${n:0:3}/${n:4}; done
timeout 600 "$GODOT_BIN" --headless --path project --import > build/rt/import_$st.log 2>&1; echo "import exit $?"
for gp in "$@"; do
  g=${gp%@*}; p=${gp#*@}
  if [ "$p" = 55 ]; then view="--view=tilt"; tag=${g}55; else view=""; tag=$g; fi
  echo "$g p$p $st: $(timeout 900 node tools/dev/run.mjs res://dev/rivet_motion/cursor_sweep.tscn --windowed --timeout=600 --fixed-fps=60 -- --rigs --ppm=64 --start=pad $view --sweep-form=$g --sweep-out=C:/Users/kazda/kiro/gtai-wt/n15-hero/build/film/h3_${tag}_rt$st 2>&1 | grep -i 'ok exit\|FAIL' | tail -1)"
done
