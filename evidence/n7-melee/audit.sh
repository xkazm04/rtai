#!/bin/bash
# audit.sh: iteration 1's audit films on the current head (melee chapters + the four ghosts, 32 and 48 px/m).
cd /c/Users/kazda/kiro/gtai-wt/n7-melee
F=evidence/n7-melee/film.sh
for p in 32 48; do
  for c in claw_combo katana chainsaw plasma_sword_deflect electro_baton; do
    bash $F audit_${c}_$p $p 420 --bot=reel --reel=director --chapter=$c --loadout=pistol --clean --rigs
  done
  for g in tonnage dent kerf ohm; do
    bash $F audit_ghost_${g}_$p $p 900 --bot=ghosts --ghost=$g --rigs
  done
done
echo AUDIT DONE
