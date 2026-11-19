# Tonnage's p70 right-profile step 5

In the shipped capped walk, C6 to C7 takes the stance centre from 62 to 17.5 cell px. The req221 cells (C3 and C7) already ship. For the midpoint at 39.75 px, the neighbouring 3_6_v2 and v3 candidates put the pad at 63 and 75 px. The old walk8 has a contact near 41 px but its feet retract beneath the housing. The in-between derives from the shipped C7 landing. The sole remains the same width and centres at 39.5 px. At tick 321 the near shaft stands more upright as the opposite pad descends. [Same-tick comparison at 32 px/m](<C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/tonnage_step5_32ppm.png>).

The new pose occupies the central half of capped step 5, from phase 0.39851 to 0.45897, across the C6/C7 boundary at 0.42874. The right-profile sheet uses the usual 163 by 230 px cell and 2 px foot offset. The other directions use their original sheets. The p70 and p55 step caps are 2.0 and off. The hit lean is 4 degrees.

| 32 px/m, 110 ticks | Before | After |
|---|---:|---:|
| Changes counted by hold_ride.py | 21 | 22 |
| Worst held ride across C6 to C7 | 16.194 px | 11.263 px |
| Mean held ride over the film | 9.471 px | 8.911 px |
| Worst held ride over the film (C3) | 18.395 px | 18.395 px |
| Mean absolute stance drift between pose centres | 2.991 px | 2.381 px |

Leg 2, ticks 239-348. Ticks 315-329 originally held C6 for eight ticks (16.194 px), then C7 for seven (13.382 px). Now C6 holds for six ticks, the midpoint for five (9.157 px), then C7 for four (6.308 px). All 105 crops outside the five midpoint ticks matched exactly. C3 holds for nine ticks, with C13 close behind at 18.32 px. Level 4 requires every hold below 9 px.

## Reproduction

Pack with `python tools/art/tonnage_midpoint.py`. Film `stride_film.tscn` on the pad at fixed 60 fps, D3D12, window position `0,1440`, with `--rigs --ppm=32 --start=pad --film-form=tonnage --film-every=1 --film-leg=2 --film-frames=110 --film-turn=0 --film-out=<prefix>`. The capture probe logs the sheet and cell before each ordinary grab. Both arms and their logs are in `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/raw/step5/`.

For each prefix run `python evidence/s15/tools/hold_ride.py <prefix> 2 110 0,45 70,150,190,222`. Drift uses the lowest four pixel rows and the stance pairing in `evidence/it13/tools/ghost_slip.py`. For the after arm, take a quarter of capped step 5 from each of C6 and C7's existing dwells and insert their sum as the midpoint dwell. Both arms normalise total dwell to 235 cell px, with figure height 190.5 cell px and world height 3.3 m.
