#!/bin/bash
# reel3.sh <tag>: the director reel headless in top, tilt70 and combo (the gate), logs under evidence/n9-world.
cd /c/Users/kazda/kiro/gtai-wt/n9-world
export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/world TMP=C:/Users/kazda/kiro/gtai-n9/tmp/world TEMP=C:/Users/kazda/kiro/gtai-n9/tmp/world
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
for v in top tilt70 combo; do
  L=evidence/n9-world/director-reel-$1-$v.log
  "$G" --headless --fixed-fps 60 --quit-after 16000 --path project res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=$v > $L 2>&1
  echo "$v exit $? errors $(grep -c 'SCRIPT ERROR' $L)" >> evidence/n9-world/director-reel-$1.txt
done
