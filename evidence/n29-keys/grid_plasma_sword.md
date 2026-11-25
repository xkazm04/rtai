# Plasma sword at tilt 70: own walk grid (katana donor), n29-02b

Commit `3dbef1803` "keys n29: plasma sword walks on its own p70 grid (katana donor)".
- Ships `rivet_walk_eq_plasma_sword.png` (848x1480) and its `.import`.
- `rivet_motion.json`: `armed_cycle_cell` `p70/plasma_sword` 66.7 (katana 66), `walk_profile_travel` 15.5, 30.0.
- Pins in `test_rivet_grid_stride.gd`: the file stays at 200 lines because `_bare_rig` now takes face and speed.
- Provenance line appended.
- `walk_grid.by_weapon` is left unset for plasma_sword. Its grip `two_hand_long` maps to the plasma_rifle family, so the fallback is `bare_claw`, and `RivetWalk.path_of` sprints on the bare `rivet_run8.png` with the held part (the molotov precedent). Setting it to `plasma_sword` before a run8 sheet exists would make the sprint play the walk sheet.
- `run_unit --changed`: 881 passed, 0 failed.

Round: `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/` (`STATE.md`, `jobs.json`, `scripts/`, `final/`).

## Walk rows (one image edit per row, s1.0; bars from `scripts/prep_row.py`)

| Row | dome w | dome x | sole y | leg IoU min | lead | travel own / donor | tone post | tries | note |
|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.0 % | 0.78 % | 2 | 0.959 | 4/4 | -16.33,16.33 / -16.67,16.67 | 0.02 | 1 | accepted n29-02a |
| 2 | 0.73 % | 1.51 % | 2 | 0.960 | 4/4 | -7.33,7.33 / same | 0.03 | 1 | |
| 3 | 0.0 % | 1.91 % | 2 | 0.951 | 4/4 | 35.33,10.0 / 34.67,9.33 | 0.01 | 1 | dark-red crossguard ring, as row 1 |
| 4 | 0.69 % | 0.73 % | 2 | 0.944 | 4/4 | -7.33,50.67 / -7.67,51.33 | 0.04 | 1 | |
| 5 | 0.0 % | 1.41 % | 2 | 0.956 | 4/4 | -9.67,9.67 / -10,10 | 0.02 | 1 | |
| 6 | 0.0 % | 0.88 % | 2 | 0.950 | 4/4 | -15.33,15.33 / same | 0.16 | 2 | try 1: the blade was cut by the cell edge; the retry asked for a katana-length blade |
| 7 | 0.0 % | 1.58 % | 2 | 0.896 | 4/4 | 31.33,34.0 / 30.33,34.0 | 0.06 | 1 | |
| 8 | 2.29 % | 0.75 % | 0 | 0.961 | 4/4 | -7.33,7.33 / -7.67,7.67 | 0.19 | 1 | col 3 was drawn 4 px short: scaled to the donor figure height (`FITH=3`) |

Donor legs were not used in any row. By eye, at 4x:
- the collar is a flat striped band
- the blade is straight and amber, with a crossguard
- there is no katana steel and no extra hand

## foot_slide

Legs film, turn_090 lane, row 0, 32 px/m, in cm. Files: `gtai-masters/n29/keys/sword/grid_{plasma_sword,katana}_foot_slide_32.json`.

| | Walk hold mean / max | Walk step mean / max | Run step mean / max |
|---|---|---|---|
| Plasma sword (walk: own sheet; run: stop-gap `rivet_run8.png` + held part) | 1.00 / 1.56 | 19.0 / 23.4 | 26.6 / 43.8 (not a slide figure, see below) |
| Katana (donor) | 0.45 / 1.56 | 20.2 / 23.4 | 7.76 / 9.15 |

**Walk:** meets the bar (walk hold <= 2 cm).

**Run lane:** this is the old stop-gap, which this commit does not change. In that lane the held blade hangs below the boots (`rows/turn_090/plasma_sword_32/t100.png`), so the lowest-5 % landmark lands on the blade tip and the figure is not a foot slide. The sword's own run8 sheet replaces this lane.

## Stills
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/grid_plasma_sword_arena/rows/` (legs film, 4 turns, 32 px/m)
- `grid_katana_arena/rows/` beside it
- The candidate (in-game arena) capture and the `grid_plasma_sword_64/_32.png` composites were not made in this call (time).

## Run rows (s0.95 layout, not wired)
- Kept: 1, 2, 3. Each passed after one column was scaled to the donor figure height (`FITH`).
- Row 4: FAILED (leg IoU 0.18, dome x 71 %: a different facing was drawn). Needs a retry.
- Rows 5-8: not done.

# Plasma sword at tilt 70: own run grid (katana donor), n29-02c

Commit `d72d49bd8` "keys n29: plasma sword runs on its own p70 grid (katana donor)".
- Ships `rivet_run8_eq_plasma_sword.png` (1552x1560, rows laid out at s0.95) and its `.import`.
- `rivet_motion.json`: `run_row_k` `p70/plasma_sword/1` 0.98, the only octant whose own run travel is under the bare run. Walk numbers unchanged (66.7; 15.5, 30.0).
- `test_rivet_grid_stride.gd`: one RUN_ROW_K pin. The third `_bare_rig` caller in `test_only_the_boot...` now passes face and speed, so the file is 199 lines.
- Provenance line appended (`prov.py run8`).
- `walk_grid.by_weapon.plasma_sword` was NOT set, which departs from the brief. With `"plasma_sword": "plasma_sword"`, `run_unit --changed` failed 2 tests in `test_rivet_walk_every_weapon.gd`:
  - "p55 plasma_sword walks" got `""`. The fallback becomes the weapon itself, and p55 has no sword grids.
  - `p55/rivet_walk_eq_plasma_sword.png` must exist for every named override.

  `RivetWalk.path_of` already plays the weapon's own run8 at p70 before any fallback (`own = _grid(dir, weapon, fast)`). The p70 sprint therefore uses the new sheet without the override. The legs film run lane plays `rivet_run8_eq_plasma_sword.png` (see foot_slide below), and p55 keeps the bare grids with the held part. With the line removed, `test_rivet_walk_every_weapon` + `test_rivet_grid_stride` pass (17 passed, 0 failed). The `--changed` run with the line in place was 879 passed, 2 failed (the two tests above).
- `quick --no-godot` ok on the test. quick's Godot parse check fails "Failed to compile depended scripts" on untouched `cut_rig.gd` / `death_pose.gd`, which is environmental, as at 02:03.
- The hook passed (lint 19 checks).

## Run rows (s0.95 layout; bars from `scripts/prep_row.py`, per-cell sole x from `scripts/solex.py`)

| Row | facing | dome w | dome x | sole y | sole x max | leg IoU min | lead | travel own / donor | tone post | tries | fit |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | front | 1.49 % | 1.54 % | 2 | 0.5 | 0.947 | 8/8 | 3.33,4.33 / 2.67,4.0 | 0.05 | 2 (n29-02a s0.64 + redo at s0.95) | FITH=2 |
| 2 | front right | 1.43 % | 1.42 % | 2 | 1.0 | 0.936 | 8/8 | 45.33,46.67 / 45.0,46.33 | 0.02 | 1 | FITH=3 |
| 3 | right | 1.49 % | 0.75 % | 2 | 1.0 | 0.945 | 8/8 | 69.67,65.67 / 70.0,64.67 | 0.03 | 1 | FITH=4 |
| 4 | back right | 0.75 % | 2.17 % | 2 | 1.0 | 0.948 | 7/8 (col 6, boots match by eye) | -4.0,2.0 / -4.33,3.0 | 0.03 | 2 (try 1 drew another facing) | plain |
| 5 | back | 0.70 % | 2.09 % | 2 | 1.5 | 0.937 | 8/8 | 3.67,-2.33 / 3.67,-3.0 | 0.03 | 1 (relaunched: the n29-02b job never returned) | plain |
| 6 | front left | 2.11 % | 9.82 % (col 8 only, see note) | 1 | 1.5 | 0.955 | 8/8 | 45.33,46.0 / 45.67,45.67 | 0.04 | 1 (shorter-blade prompt from the start) | FITH=1,7 |
| 7 | left | 1.61 % | 2.31 % | 2 | 1.5 | 0.911 | 8/8 | 64.33,65.67 / 63.0,65.0 | 0.04 | 1 | FITH=8, FITMIX=1,3,6:0.75 |
| 8 | back left | 1.67 % | 1.59 % | 2 | 1.0 | 0.946 | 6/8 (cols 2,6 passing frames, boots match by eye) | 48.33,47.67 / 48.0,47.33 | 0.10 | 1 | FITH=4,5,7,8 |

The fit column:
- FITH: those columns scale to the donor figure height, not the dome width.
- FITMIX col:t: the scale is blended t of the way from the dome fit to the height fit. Used where a column was drawn 2-3 % shorter and a full height fit pushed dome w past 3 %.

Row 6 dome x: the bar reads 9.82 % on col 8 only. That is how `prep_row.py` measures, not a drawn offset:
- Its sole reference is the mean x of the bottom 6 px rows.
- The donor's back boot reaches those rows; the new back boot sits 1 px higher.
- The dome centres are 104.0 vs 104.5 px (0.8 % of the 63 px dome).
- The foot_slide sole x differs by 1.5 px.

Donor legs were not used in any row. By eye, at 4x (`eye_run<r>.png` in the round dir):
- the collar is a flat, rigid striped band
- the blade is straight and amber, with a small guard
- there is no katana steel and no extra hand
- every blade tip sits inside its cell, with no opaque px on any cell edge. The closest is row 5, 2 px from the right edge; rows 6-8 are 21+ px inside

Red px are above the donor's on every row (e.g. row 1: 334 vs 34; row 8: 1261 vs 241), from the dark reddish-bronze grip and guard (on rows 6-8, the `_left` strip's own hilt colour) and the rust outline on the blade's back edge. No red or teal element otherwise.

IMAGES n29-02c: 5 (`edit_run_row4_b`, `edit_run_row5`, `edit_run_row6_b`, `edit_run_row7`, `edit_run_row8`). 0 retries.

## foot_slide (run sheet)

Legs film `rows2`, turn_090 lane, row 0, 32 px/m, in cm. Files: `gtai-masters/n29/keys/sword/grid_plasma_sword_run_foot_slide_32.json`, `grid_katana_foot_slide_32.json`.

| | Walk hold mean / max | Run hold mean / max | Run step mean / max |
|---|---|---|---|
| Plasma sword (own walk + own run8) | 1.00 / 1.56 | 0.22 / 1.56 | **8.29 / 9.38** |
| Katana (donor) | 0.45 / 1.56 | 1.12 / 1.56 | 7.76 / 9.15 |

**Walk:** meets the bar (walk hold <= 2 cm).

**Run step:** MISSES the 7 cm bar by 1.29 cm on the mean (2.38 cm on the max). It is 0.53 cm (mean) and 0.23 cm (max) above the katana donor, which also misses the bar (7.76 / 9.15). The run lane now plays the sword's own sheet (`rows2/turn_090/plasma_sword_32/t100.png`), so the stop-gap's 26.6 / 43.8 cm blade-tip reading is gone.

## Stills
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/grid_plasma_sword_64.png` and `_32.png`: 8 run facings x (stop-gap | new | katana) at in-game size. Built by `scripts/composite.py`, no Godot.
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/grid_plasma_sword_arena/rows2/`: legs film, 4 turns, 32 px/m.
- `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/grid_plasma_sword_arena/candidate_{32,64}/`: the in-game arena on the boulevard with the plasma_sword loadout. Each has 1000 frames plus `sample_*.png` (for example `candidate_32/sample_0250.png`).

## run_row_k octant 0 (n29-11)

Result: none passed. Nothing was added to `rivet_motion.json` or the test pin.

Method: the legs film (`capture28.py plasma_sword rows_*`, turn_090 lane, sheet row 0, 32 px/m), `foot_slide.py`, one Godot process per candidate, table edited per candidate and restored (HEAD json unchanged).

Correction to the brief: the film lane's sheet row 0 is **octant 2**, not octant 0 (`RivetFrames.BASE_OCT = [2, 1, 0, 5, 6, 7, 4, 3]`: octant o plays sheet row BASE_OCT[o]; `RivetWalk.row_k` keys by octant). The first sweep on key `p70/plasma_sword/0` (k 1.0, 0.94, 0.97, 1.03, 1.06) gave frames byte-identical to HEAD (that key moves sheet row 2, a row the lane never shows). The valid sweep is on `p70/plasma_sword/2`:

| k (key `/2`) | run step mean / max (cm) | run hold mean / max (cm) | cycle rate vs HEAD |
|---|---|---|---|
| 1.00 (HEAD) | 8.29 / 9.38 | 0.22 / 1.56 | 0 % |
| 0.94 | 8.27 / 9.38 | 0.20 / 1.56 | -6 % |
| 0.97 | 8.23 / 9.38 | 0.20 / 1.56 | -3 % |
| 1.03 | 8.31 / 9.38 | 0.22 / 1.56 | +3 % |
| 1.06 | 8.28 / 9.38 | 0.26 / 1.56 | +6 % |

Reading: HEAD reproduces 8.29 / 9.38. The best k (0.97) improves the mean by 0.06 cm, against the bar (mean <= 7.0, or an improvement of >= 0.6 cm). The step is set by the run8 drawing (two planted steps per lane), not by the cycle rate, so one scalar cannot reach 7 cm. Fix route: re-cut that row's legs, not a k.

Files: `C:/Users/kazda/kiro/gtai-masters/n29/keys/sword/sword_run_k_1.0.json`, `sword_run_o2k_{0.94,0.97,1.03,1.06}.json`; films in `grid_plasma_sword_arena/rows_k10`, `rows_k094..rows_k106` (key `/0`, no effect) and `rows_o2k094..rows_o2k106`. No clip was made (time).
