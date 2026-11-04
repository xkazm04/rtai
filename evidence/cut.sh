#!/bin/bash
# cut.sh <name> <ppm> [chapter ids...]: the director cut, one fresh fixed-fps run per chapter
# (`--reel=director --chapter=<id>`, a clean floor under every kill), concatenated -> masters mp4.
# Chapter ticks mirror ReelChapters.all() (+30 ticks of hold).
set -u
N=$1; P=$2; shift 2
declare -A T=([claw_combo]=360 [pistol]=360 [machine_pistol]=420 [rocket_launcher]=360 [flamethrower]=420
  [electro_gun]=330 [molotov]=420 [katana]=330 [chainsaw]=390 [plasma_sword_deflect]=420 [hand_cannon]=300
  [plasma_rifle]=300 [ray_gun]=300 [homing_shard]=330 [riot_cop]=420 [mini_nuke]=480)
ALL="claw_combo pistol machine_pistol rocket_launcher flamethrower electro_gun molotov katana chainsaw plasma_sword_deflect hand_cannon plasma_rifle ray_gun homing_shard riot_cop mini_nuke"
IDS=${@:-claw_combo pistol machine_pistol rocket_launcher flamethrower electro_gun molotov katana chainsaw plasma_sword_deflect hand_cannon plasma_rifle ray_gun homing_shard riot_cop mini_nuke}
cd /c/Users/kazda/kiro/gtai-wt/n-showcase
export APPDATA=${FILM_APPDATA:-C:/Users/kazda/kiro/gtai-n4/appdata/showcase}
G='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'
S=C:/Users/kazda/kiro/gtai-n4/scratch-showcase/cut-$N
M=C:/Users/kazda/kiro/gtai-masters/n4/showcase
mkdir -p $S; : > $S/list.txt; : > $S/film.log
for id in $IDS; do
  q=$(( ${T[$id]} + 30 ))
  "$G" --rendering-driver d3d12 --fixed-fps 60 --resolution 1280x720 --write-movie $S/$id.avi --quit-after $q --path project res://dev/arena/arena.tscn -- --bot=reel --reel=director --chapter=$id --loadout=pistol --ppm=$P --clean --rigs >> $S/film.log 2>&1
  k=1; for a in $ALL; do [ $a = $id ] && break; k=$((k+1)); done
  title=$(printf "%02d   %s" $k "$(echo $id | tr '_' ' ' | tr a-z A-Z)")
  cap="drawtext=fontfile='C\:/Windows/Fonts/arialbd.ttf':text='$title':x=28:y=28:fontsize=30:fontcolor=0x1B1A17:box=1:boxcolor=0xF2E8D5:boxborderw=14"
  ffmpeg -y -loglevel error -i $S/$id.avi -vf "$cap" -c:v libx264 -pix_fmt yuv420p -crf 20 -r 60 $S/$id.mp4 && rm -f $S/$id.avi
  echo "file '$id.mp4'" >> $S/list.txt; echo "chapter $id done" >> $S/film.log
done
ffmpeg -y -loglevel error -f concat -safe 0 -i $S/list.txt -c copy $M/$N.mp4
echo "done $N $?" >> $S/film.log
