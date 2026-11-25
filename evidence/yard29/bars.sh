#!/bin/bash
# n29: both arms (i55 committed, i20 temp edit restored after) through art_sweep.sh with imp_row.py
cd /c/Users/kazda/kiro/gtai-wt/n25-yard
export ROWPY=imp_row.py
bash evidence/yard29/art_sweep.sh i55 ffffff8c
bash evidence/yard29/art_sweep.sh i20 ffffff33
git checkout project/data/tables/prologue_yard_dressings.json
git diff --stat
echo ALLDONE
