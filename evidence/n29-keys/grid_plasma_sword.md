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
