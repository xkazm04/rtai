#!/bin/bash
# model_run.sh <name> <L*> <C*> <hue>: modelled floor (floor_model.py) on the n27 raised_line captures, then the n27 measures.
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
retry() { for i in $(seq 1 12); do "$@" && return 0; sleep 5; done; return 1; }
d=build/n28/m$1
retry python -W ignore -I evidence/yard28/floor_model.py build/dusk27/rl_day build/dusk27/rl $d $2 $3 $4
echo "== $1 L*$2 C*$3 h$4"
retry python -W ignore -I evidence/yard28/rivet_delta.py $d/dusk | cut -c1-120
ROW=raised_line retry python -W ignore -I evidence/yard28/dusk_contrast.py --day $d/day --dusk $d/dusk
