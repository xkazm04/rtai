# Tonnage step-cap sweep at 32 px/m

Each row uses the same 110 consecutive sprint-right ticks in the p70 and p55 views. Ride is ground travel within a held pose. Drift is the mean absolute change in the planted pad’s ground position between pose centres, using the n15 it13 method. Distances are pixels at 32 px/m. The score is the larger of worst ride / 9 and drift / 3, computed before rounding. Bold values mark the lowest score in each pitch.

| Cap × mean step | p70 worst ride | p70 mean ride | p70 drift | p70 score | p55 worst ride | p55 mean ride | p55 drift | p55 score |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| off | 25.42 | 9.75 | 2.819 | 2.8249 | 31.71 | 20.24 | 7.222 | 3.5230 |
| 2.0 | 18.39 | 9.47 | 2.991 | 2.0439 | 31.71 | 20.24 | 7.222 | 3.5230 |
| 1.75 | 21.25 | 9.52 | 3.195 | 2.3613 | 31.71 | 20.32 | 7.267 | 3.5230 |
| 1.5 | 16.14 | 9.62 | 3.667 | 1.7933 | 27.55 | 20.20 | 7.506 | 3.0610 |
| 1.25 | **14.13** | **10.37** | **4.040** | **1.5704** | 27.55 | 22.12 | 8.103 | 3.0613 |
| 1.0 | 12.04 | 9.94 | 4.779 | 1.5929 | **23.46** | **19.49** | **8.546** | **2.8486** |

**p70 ships 1.25.** Worst ride falls from 25.42 to 14.13 px, 5.13 px above the worst-hold bar. Drift rises from 2.819 to 4.040 px, 1.040 px above its bar. Even timing shortens the worst hold further but scores 1.5929 against 1.5704 for 1.25.

**p55 ships 1.0.** Worst ride falls from 31.71 to 23.46 px, 14.46 px above the bar. Drift rises from 7.222 to 8.546 px, 5.546 px above the bar. The even eight-frame gait holds most poses for ten or eleven ticks.

The mean filmed ride also exceeds 9 px by 1.37 px at p70 and 10.49 px at p55. The historical sheet calculation reports mean dwell travel of 8.1 and 15.5 nominal px respectively across all six caps because each pitch retains its cycle length.

In the p70 trace the longest diagonal streaks shorten, but the pad still moves forward during the hold and steps back when the pose changes. The p55 trace shows this skate clearly even with even timing. The first 110 ticks of each shipped clip reproduce the selected arm's hold lengths and rides. [p70 trace](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/tonnage_p70_cap_trace_32ppm.png>) · [p55 trace](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/tonnage_p55_cap_trace_32ppm.png>) · [12-second walk comparison](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/tonnage_cap_walk_32ppm.mp4>)

## Reproduction

1. Set both Tonnage entries in `GhostStride.MAX_STEP_SHARE` to the cap in the first column (0 for off). This redistributes the measured steps before the usual adjacent-step averaging and minimum dwell. Tonnage’s cycle, speed and artwork are common to all arms.
2. Use the lane’s Godot binary and APPDATA. Film `res://dev/rivet_motion/stride_film.tscn` at fixed 60 fps, D3D12, window position `0,1440`, with `--rigs --ppm=32 --start=pad --film-form=tonnage --film-every=1 --film-leg=2 --film-frames=110 --film-out=<prefix>`. Use the default combo view for p70 and add `--view=tilt` for p55.
3. Run `py -3 -I evidence/s15/tools/hold_ride.py <prefix> 2 110 0,45 70,150,190,222`. The ground band is above Tonnage on both pitches. The figure box covers his legs and lower body. The historical tool counts holds closed by a pose change.
4. Pass the values returned by `GhostStride.table_of("tonnage", pitch)` as comma-separated steps to `py -3 -I evidence/it13/tools/ghost_slip.py <pitch> <walk-sheet> <cycle> 190.5 3.3 4.2 <steps> <columns>`. Use 235 cell px and 16 columns for p70, 223.25 (235 × 0.95) and 8 for p55. Drift uses the matched contacts in the lowest four rows of each profile cell. The ride measurements above come from the rendered frames.
5. Make the ground-stabilised traces with `py -3 -I evidence/s15/tools/feet_trace.py <prefix> 2 110 0,45 198,214 <out.png> 1`. The clip shows 180 consecutive ticks at real time, then replays them at one-third speed.
