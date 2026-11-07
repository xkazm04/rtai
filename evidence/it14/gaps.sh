#!/bin/sh
# it14 boss_hit shortest gap under deck (headless, 2400 ticks, the boss bot, combo), stock gun vs fast guns
cd /c/Users/kazda/kiro/gtai-wt/d9-handheld
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/handheld
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
O=/c/Users/kazda/kiro/gtai-d9x/scratch/it14
run() { b=$1; w=$2; extra=""; [ "$w" != stock ] && extra="--weapon=$w"; "$G" --headless --path project --fixed-fps 60 --quit-after 2400 res://dev/arena/arena.tscn -- --boss=$b --bot=boss --rigs --view=combo --device=deck $extra > $O/$b-$w-gap.log 2>&1; }
run king stock & run king gatling & run king machine_pistol & run servo stock & run servo gatling &
wait
grep -H "rumble:\|SCRIPT ERROR\|gunplay" $O/*-gap.log
