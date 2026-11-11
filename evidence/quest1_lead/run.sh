#!/bin/bash
# quest1 stills at t13708 from two --stills lists, old jump (--still-lead=0) vs the new lead (default),
# all on one commit (film --rev), sequential (one Godot). Then diff t13708 A vs B per arm.
set -u
cd /c/Users/kazda/kiro/gtai-wt/n15-tools || exit 9
export APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/tools
REV=${1:?rev}; OUT=build/film/quest1_lead
for arm in jump lead; do
  extra=(); [ $arm = jump ] && extra=(-- --still-lead=0)
  for list in 13600,13708 13708; do
    node tools/film/film.mjs quest1 --rev=$REV --out=$OUT/$arm-${list%%,*} --stills=$list --ppm=32 "${extra[@]}" 2>&1 | tail -2
  done
done
node evidence/quest1_lead/diff.mjs $OUT
