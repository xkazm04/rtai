#!/bin/bash
# film_32_all.sh: every combat-notes chapter at 32 px/m (the owner's judging scale), after (this
# build) and before (all the lane's before flags), 3 renders at a time -> scratch r32_<ch>[_before].avi
cd /c/Users/kazda/kiro/gtai-wt/d6-combat-notes
B="--no-shard-flinch --soft-shock --no-plasma-heat --soft-swing"
CH="homing_shard electro_gun electro_chain plasma_rifle plasma_armored katana chainsaw electro_baton claw_combo"
n=0
for c in $CH; do
  QUIT=400 bash evidence/film_chapter.sh r32_$c 32 $c > /dev/null &
  QUIT=400 bash evidence/film_chapter.sh r32_${c}_before 32 $c $B > /dev/null &
  n=$((n+2)); if [ $n -ge 4 ]; then wait; n=0; fi
done
wait
grep -c "SCRIPT ERROR" /c/Users/kazda/kiro/gtai-d6/scratch-combat-notes/r32_*.log
