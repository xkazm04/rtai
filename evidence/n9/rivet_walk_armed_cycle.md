# Armed walk cycles (n9 it6, on the claw grids f2e05223)

Method: each grid's profile rows (right = row 3, left = row 7 of the 8-row grid), the lowest 6 alpha rows of each
cell split into foot blobs (gap > 3 px). The stance boot is the leading foot at frame 1 (contact), the single foot at
frame 2 (passing), the trailing foot at frame 3 (contact, other foot): its travel over those two frame steps is a
half cycle, so cycle = 2 x travel. Units are grid cell px (fig_h 110 = his standing height). walk8 measured the same
way gives ~7 px a step (CYCLE_CELL 60: right). Blob centres:

| grid | right f1 -> f2 -> f3 | travel | left f1 -> f2 -> f3 | travel | cycle (mean x 2) |
|---|---|---|---|---|---|
| p70 pistol | 75.5 -> 60.5 -> 30.5 | 45 | 50 -> 62.5 -> 80.5 | 30.5 | 76 |
| p70 plasma rifle | 67.5 -> 51.5 -> 22 | 45.5 | 42 -> 57 -> 73 | 31 | 76 |
| p70 katana | 79.5 -> 70.5 -> 45.5 | 34 | 56 -> 71.5 -> 87.5 | 31.5 | 66 |
| p70 gatling | 81 -> 68 -> 47.5 | 33.5 | 48.5 -> 64.5 -> 83.5 | 35 | 68 |
| p55 pistol | 63.5 -> 50 -> 23.5 | 40 | 35.5 -> 52 -> 72.5 | 37 | 77 |
| p55 plasma rifle | 70.5 -> 55.5 -> 36 | 34.5 | 40.5 -> 58 -> 79.5 | 39 | 74 |
| p55 katana | 73 -> 60 -> 39.5 | 33.5 | 48 -> 63 -> 86 | 38 | 72 |
| p55 gatling | 73.5 -> 59 -> 33 | 40.5 | 41 -> 55 -> 81.5 | 40.5 | 81 |
| flamer 70/55 | one blob per frame (a shuffle, no two-foot contact) | - | - | - | CYCLE_CELL 60 |

The right and left rows disagree by up to 1.5x on the one- and two-hand grids (drawn by different rounds): the mean
is wired. The cap (MAX_CYCLES_S 2.0) still rules above ~2.3 m/s: an armed walk at his 6.75 m/s top speed covers
~3.4 m per drawn cycle against a ~1.1 m drawn stride (the armed glide at speed: needs a drawn armed run).
