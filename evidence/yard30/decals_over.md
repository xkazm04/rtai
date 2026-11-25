# n30 decals over the i55 impression: evidence (partial: contrast + pilots; bars and film not finished)

Change under test: `5950ceb34` + `ed6b97278` (stain layer, non-ochre torn_line stamps and ochre bay lines print above the i55 impression). Before = `6c32defe4`, after = `aacc0c87e` (same code as `ed6b97278`), i20 = `c649a15d6` (n30 shade05's own i20 stills `build/shade/d05/i20_{mid,gate}_32.png`, not re-rendered).
Renders came from two overlay projects (junctions to this worktree's project, the listed code/table files taken from git at each rev), because `git worktree add` and `git archive` stalled for 20+ min on the 23 000-file repo; both through `runGodot` with cwd = the overlay.

## Pilots
Seeds 7, 3, 11, 21, 42 in one Godot process (`yard_pilot_rows`): ticks, deaths, min_hp, stuck and sha256 IDENTICAL to `evidence/yard30/prologue-yard-pilots-shade05.json` -> `evidence/yard30/prologue-yard-pilots-decals.json`.

## Decal contrast (method: `evidence/yard30/decal_contrast.py`)
Mean |decal - floor ring| luminance, Rec.709 linear, 32 px/m, tick 300, seed 7. Boxes picked by hand (screen px), away from actors; decal pixels = darkest 30 % (tyre marks, stains) or most ochre 30 % by R - B (bay lines); ring = 14 px outside the box minus a 3 px gap.

Mid camera (boxes: tyre A (335,600,525,715), tyre B (1330,5,1560,100), bay 1 (1105,190,1615,215), bay 2 (1300,200,1325,355), stain 1 (205,395,335,440), stain 2 (225,640,325,690)):

| decal box | method | i20 | before | after | after / before | after / i20 |
|---|---|---|---|---|---|---|
| tyre sweep A (left, 2 arcs) | darkest 30 % | 0.1395 | 0.0792 | 0.0802 | 101 % | 57 % |
| tyre sweep B (right arc, faint) | darkest 30 % | 0.1324 | 0.0680 | 0.0518 | 76 % | 39 % |
| bay line run 1 (horizontal) | most ochre 30 % | 0.1210 | 0.0645 | 0.0663 | 103 % | 55 % |
| bay line run 2 (vertical) | most ochre 30 % | 0.1210 | 0.0650 | 0.0652 | 100 % | 54 % |
| stain 1 (oil) | darkest 30 % | 0.1854 | 0.1199 | 0.1493 | 125 % | 81 % |
| stain 2 (dark patch) | darkest 30 % | 0.0734 | 0.0419 | 0.0517 | 123 % | 70 % |
| mean, dark classes | | 0.1327 | 0.0772 | 0.0832 | 108 % | 63 % |
| mean, ochre classes | | 0.1210 | 0.0648 | 0.0657 | 101 % | 54 % |

Gate camera: full table `evidence/yard30/decals_over_gate_table.txt`; summary: tyre A 108 %, tyre B 77 %, bay lines 99 % and 95 %, stains 99 % and 119 % (after / before).

Bar "every decal class after >= before": NOT met for one box. The faint wide tyre arc B (the lighter arcs near the skip) is 76 to 77 % at both cameras, and the gate bay run 2 is 95 %. Tyre sweep A (the dark, ink tyre marks), both mid bay runs and both stains are at or above before (stains +23 to +25 %). Every class stays far below i20 (39 to 81 % of it): the browner after floor plus the shade 0.5 lift the floor luminance, so decal-to-floor contrast is still short of i20's.

## Readability bars: NOT measured
The n29 sweep (`evidence/yard29/sweep_measure.py`) ran on the after overlay and gave floor between pools L* 50.8 / C* 21.6 and Rivet luminance delta 0.1340 (0.147 at i55; a drop of 0.013 = more than 0.01, reported as a FAIL against the bar, but this was one run and the before arm was not measured to compare). Its patrol-blue/rifle/pellet part returned `dusk 1.000 retained 20 %`, no rifle or pellet lines: the dusk frames of this overlay run did not give usable cop pixels, so I do not trust those numbers and publish none. The before arm hung in a `--import` (class cache stale: `PrologueSpanShadow`) and was killed.

## Not done
Film (before | after mp4, masters copy, frames.json), the relabel of `decals_over_before_after_mid_32ppm.png`, the decisions line and the mutate run.
