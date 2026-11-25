# n29 hall finish: readability at the front (n29-05, item 6): NOT RUN

The readability measure (`evidence/yard29/readability.py` through `bars.sh` / `art_sweep.sh`, the floor call's method) did not fit the call's 03:20 commit stop after the frame cost (six 60 s samples on a saturated machine). Patrol blue / rifle / pellet retention at a front camera are therefore NOT measured for this change; the floor call's numbers (`floor_i55_bars.md`: patrol 80.6 / 88.7 %, rifle 104.5 %, pellet 100.9 %) are the last measured values.

What was measured instead (proxy, not the bars), at the front camera (26, 3), 32 px/m, tick 2290, seed 7 (`hall_finish/band.py`, `hall_finish/rows.py`):

| | d8dd15d98 (collapsed bay only) | now (roof glow + mouth wall pools) |
|---|---|---|
| yard floor y 430..1080 px, mean RGB | 145.0 / 115.2 / 88.9 | 145.4 / 115.6 / 89.0 |
| void strip y 0..165 px, mean RGB | 24.6 / 20.3 / 21.6 | 38.8 / 28.7 / 23.8 |
| void strip red share (hue < 18 deg, S > 0.5, V > 0.5) | 0 % | 0 % |
| void strip teal/blue share | 0 % | 0 % |
| lower window row luma: shutter W / burst / feed / shutter E / collapsed (half in frame) | 39.9 / 84.6 / 86.0 / 67.2 / 59.8 | 39.9 / 110.6 / 86.0 / 67.2 / 85.5 |

The roof glow rect ends at y -7, 5.9 m north of the wall base (-1.1; unit test), so it cannot reach the yard floor; the floor mean moves +0.4 (the mouth wall pools' print light, radius 5.5 m at y -2.9, reaches about 2.6 m into the yard at the two mouths). Expected: bars unchanged within noise; unproven until the readability run.

NOTE (03:18): the frame cost, the stills and the measures above were taken with two extra `yard_hall_mouth_wall` pools (a new kind, no floor glow, at y -2.9). Lint refused the new kind id (the schema enumerates kind ids), so the commit d838f9e66 instead MOVES the existing burst_door / collapsed_wall `yard_hall_mouth` pools from y -0.8 to -2.9 (two fewer lights than measured, so the cost is at most the measured one). The stills show the measured variant, not d838f9e66's; re-shoot owed.
