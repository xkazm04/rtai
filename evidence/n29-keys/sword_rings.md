# n29 keys: the plasma sword's hilt rings in Rivet's strips

Commit `0906b2f7c`. Script `evidence/n29-keys/sword_rings/recolour.py`, proof `verify.py` (-> `proof.json`, against HEAD).
Rule: red-magenta hue (h <= 17 or >= 325, s > 0.45, v > 0.22) AND within 19 px (p55: 14) of an amber blade blob (>= 100 px; p55 60; p70 windup 28)
-> hue 218, s 0.10, value and alpha kept (combat's steel). The rings are < 25 px parts, so combat's size rule does not apply; the copper blade housing (hue 18-27) and the collar stay.

| file | px changed | alpha changed | changed outside mask | hazard-vermilion px changed |
|---|---|---|---|---|
| p55/rivet_eq_plasma_sword.png | 533 | 0 | 0 | 4 of 446 |
| p55/rivet_eq_plasma_sword_left.png | 179 | 0 | 0 | 0 of 212 |
| p55/rivet_eq_plasma_sword_left_strike.png | 60 | 0 | 0 | 0 of 32 |
| p55/rivet_eq_plasma_sword_left_windup.png | 60 | 0 | 0 | 4 of 37 |
| p55/rivet_eq_plasma_sword_windup.png | 212 | 0 | 0 | 1 of 109 |
| p70/rivet_eq_plasma_sword.png | 888 | 0 | 0 | 4 of 782 |
| p70/rivet_eq_plasma_sword_left.png | 653 | 0 | 0 | 6 of 589 |
| p70/rivet_eq_plasma_sword_left_strike.png | 140 | 0 | 0 | 2 of 185 |
| p70/rivet_eq_plasma_sword_left_windup.png | 115 | 0 | 0 | 5 of 125 |
| p70/rivet_eq_plasma_sword_windup.png | 188 | 0 | 0 | 1 of 221 |
| p70/rivet_run8_eq_plasma_sword.png | 9654 | 0 | 0 | 3 of 10283 |
| p70/rivet_walk_eq_plasma_sword.png | 6166 | 0 | 0 | 47 of 8563 |

Outside the mask every pixel is byte-identical (asserted). The vermilion counts are hilt-copper pixels that match the loose vermilion test; the collar was checked by eye on the 4x sheet (collar stripes unchanged in every cell).
Before | after 4x: `gtai-masters/n29/keys/sword_rings/rings_cells_4x.png` (looked at: rings steel, amber blade unchanged, collar unchanged). Tests: `run_unit.mjs --changed` 1158 passed; no pin changed.
Not done: no in-game 64 px/m still (no capture built in the time).
