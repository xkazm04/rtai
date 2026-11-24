# Molotov at tilt 70: own WALK grid only; the sprint stays on the stop-gap

Same route as the ray gun (`grid_ray_gun.md`): the plasma rifle's packed walk sheet as image 1, the molotov equipped strip as image 2, one sheet-sized edit. Round: `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/` (`STATE.md`, `scripts/`, `final3/`). Director decision: the walk column passes at 64 px/m, the run does not ship.

## What ships

`rivet_walk_eq_molotov.png` (cycle 81, walk contacts 27.5 / 34.5, pinned in `test_rivet_grid_stride.gd`). No `rivet_run8_eq_molotov.png`: the weapon sprints on its stop-gap (the bare run with the bottle on the palm).

Code: `RivetWalk.path_of` returned the weapon's own walk sheet at sprint speed when it had no run8 sheet, so the fallback never answered. It now lets the fallback answer the sprint when the own grid is a walk sheet and the fallback has a run sheet. The cadence needed no change: `cycle_cell` / `row_k` are keyed by the sheet actually shown (`is_run` of the card's file), so the sprint uses the bare run cycle (258), not the molotov's walk cycle 81. Test: `test_rivet_walk_sprint_fallback.gd` (walk speed: own sheet; sprint: `rivet_run8.png`).

## Why the run is not shipped

Both full-sheet edits came back, but the run: row 1 (front) cells were drawn about 30 % shorter in the legs than the donor (leg IoU 0.55 to 0.68 in 6 of 8 cells) and the prompt line did not fix it; a row-1-only half sheet fixed the leg IoU (0.84 to 0.89) but the soles were drawn x-shifted from the donor (sole x 80, 96, 94 | 108, 100, 108 against 80, 84, 78 | 108, 88, 102), a planted foot drifting 14 px: the 20.3 cm run step. Donor legs under a seam at 82 % (final4) passed foot_slide (run step 6.03 / 8.93 cm) but the donor-leg seam and the sole-aligned shift (final5: dome offset up to 23.7 % of the donor dome, 6 of 8 cells over the 3 % bar) both fail the look. final4 is kept unshipped in `rivet-n28/molotov/unshipped_run8_final4/`.

## foot_slide (legs-film rig, turn_090 lane, 32 px/m, cm; `grid_molotov_foot_slide_32.json`)

| | Walk hold mean / max | Run step mean / max |
|---|---|---|
| Molotov (walk: own sheet; run: stop-gap `rivet_run8.png`) | 0.43 / 1.56 | 7.05 / 9.41 |
| Plasma rifle (donor) | 0.60 / 1.56 | 6.69 / 8.93 |

The walk meets the bar (<= 2). The run is the bare run's own number (it is the stop-gap, unchanged by this commit; bar 7, 0.05 over on mean for the bare run).

## Stills

Candidate captures (in game, tilt 70) `C:/Users/kazda/kiro/gtai-masters/n28/keys/grid_molotov_arena/candidate_32`, `candidate_64`: the strip lane of `foot_slide` names `rivet_walk_eq_molotov.png` for the walk and `rivet_run8.png` for the sprint. `grid_molotov_32.png` / `_64.png` were composed before the walk-only decision (their run column shows the rejected run); the walk column is the shipped one.
