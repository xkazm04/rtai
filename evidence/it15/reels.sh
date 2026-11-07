#!/bin/bash
# it15 reels: top / tilt70 / combo / combo + deck, 4 in parallel, --quit-after 14000
cd /c/Users/kazda/kiro/gtai-wt/d9-handheld
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/handheld
GB=/c/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
O=C:/Users/kazda/kiro/gtai-d9x/scratch/it15/reels; mkdir -p $O
"$GB" --headless --fixed-fps 60 --path project --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=top > $O/reel-top.log 2>&1 &
"$GB" --headless --fixed-fps 60 --path project --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70 > $O/reel-tilt70.log 2>&1 &
"$GB" --headless --fixed-fps 60 --path project --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=combo > $O/reel-combo.log 2>&1 &
"$GB" --headless --fixed-fps 60 --path project --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=combo --device=deck > $O/reel-deck.log 2>&1 &
wait
: > $O/reels-summary.log
for v in top tilt70 combo deck; do
  f=$O/reel-$v.log
  ch=$(grep -E "director chapter .*: [0-9]+/[0-9]+ down" $f | wc -l)
  ok=$(grep -E "director chapter .*: ([0-9]+)/\1 down" $f | wc -l)
  se=$(grep -c "SCRIPT ERROR" $f)
  echo "reel $v: $ok/$ch chapters all down, $se SCRIPT ERROR" >> $O/reels-summary.log
done
cat $O/reels-summary.log
