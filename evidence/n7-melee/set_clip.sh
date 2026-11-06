#!/bin/bash
# set_clip.sh <tag>: the combined clip of the polished melee + ghost set in the city block at 32 px/m
# (brief evidence), re-cut on the current head. Each melee chapter is filmed alone
# (RECUT=1 re-cuts the scratch AVIs without filming) (--chapter=<id>: frame 0 is the chapter's start, so hit-stop drift never moves a cut); each ghost
# reel is filmed alone and cut to frames 40-400. Game audio is cut per segment (atrim), never
# carried whole (FRICTION 23:46). Output: gtai-masters/n7/melee/melee_polished_set_city_32ppm.mp4.
set -u
T=${1:-head}
cd /c/Users/kazda/kiro/gtai-wt/n7-melee
S=C:/Users/kazda/kiro/gtai-n7p/scratch/melee
M=C:/Users/kazda/kiro/gtai-masters/n7/melee
F=evidence/n7-melee/film.sh
# chapter:first:last frame (the walk-up trimmed: in the city each chapter's kills land late, after
# the cops come in; windows read off a 30-frame sheet per chapter on bd36c37c)
MELEE="claw_combo:200:420 katana:210:390 chainsaw:270:450 plasma_sword_deflect:30:480 electro_baton:210:390"
GHOSTS="tonnage dent kerf ohm"
IN=(); FILT=""; n=0
for cl in $MELEE; do
	ch=${cl%%:*}; last=${cl##*:}; first=${cl#*:}; first=${first%%:*}
	[ "${RECUT:-0}" = 1 ] || bash $F set_${ch} 32 $((last + 10)) --arena=city --bot=reel --reel=director --chapter=$ch --loadout=pistol
	IN+=(-i "$S/set_${ch}.avi")
	FILT+="[$n:v]trim=start_frame=$first:end_frame=$last,setpts=PTS-STARTPTS[v$n];"
	FILT+="[$n:a]atrim=$(awk "BEGIN{print $first/60}"):$(awk "BEGIN{print $last/60}"),asetpts=PTS-STARTPTS[a$n];"
	n=$((n + 1))
done
for g in $GHOSTS; do
	[ "${RECUT:-0}" = 1 ] || bash $F set_ghost_${g} 32 410 --arena=city --bot=ghosts --ghost=$g --rigs
	IN+=(-i "$S/set_ghost_${g}.avi")
	FILT+="[$n:v]trim=start_frame=40:end_frame=400,setpts=PTS-STARTPTS[v$n];"
	FILT+="[$n:a]atrim=$(awk "BEGIN{print 40/60}"):$(awk "BEGIN{print 400/60}"),asetpts=PTS-STARTPTS[a$n];"
	n=$((n + 1))
done
CAT=""
for i in $(seq 0 $((n - 1))); do CAT+="[v$i][a$i]"; done
ffmpeg -v error -y "${IN[@]}" -filter_complex "${FILT}${CAT}concat=n=$n:v=1:a=1[v][a]" \
	-map "[v]" -map "[a]" -c:v libx264 -crf 23 -pix_fmt yuv420p -c:a aac -b:a 128k \
	"$S/set_new.mp4" && mv "$S/set_new.mp4" "$M/melee_polished_set_city_32ppm.mp4"
echo "set clip exit $? ($T): $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$M/melee_polished_set_city_32ppm.mp4") s"
grep -c "SCRIPT ERROR" $S/set_*.log | tr '\n' ' '; echo
