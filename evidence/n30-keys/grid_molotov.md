# n30 keys: the molotov runs on its own p70 grid (one row per image job)

Commit `4513bda2a` ships `project/features/characters/art/view/p70/rivet_run8_eq_molotov.png`: the molotov leaves the
stop-gap (bare `rivet_run8.png` + held part) and sprints on its own run sheet. Donor: the plasma rifle's p70 run rows,
each row laid out at s0.95 as image one, the molotov walk row of the same facing as image two (bottle in one claw,
amber flame). Round (scripts, refs, every returned png, metrics): `C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/`
(`STATE.md`). 10 images: rows 1-8 plus one retry each for rows 4 and 8.

## Rows (bars: dome <= 3 %, sole y <= 2 px, sole x within 3 px of the donor per cell, leg IoU >= 0.80, same lead, tone post <= 2)

| row | facing | kept | dome w / x % | sole y px | sole x max px | leg IoU min | lead | tone post | note |
|---|---|---|---|---|---|---|---|---|---|
| 1 | front | try 1 | 0.75 / 0.79 | 2 | 1.0 | 0.830 | 8/8 | 0.08 | |
| 2 | 3/4 front right | try 1, FITH col 1 | 2.86 / 1.47 | 2 | 1.5 | 0.850 | 8/8 | 0.04 | |
| 3 | right | try 1 | 0 / 0.76* | 2 | 1.5 | 0.832 | 8/8 | 0.12 | *prep reads 21 % on cols 1,5 from its bottom-row sole mean; dome centres match the donor within 0.5 px (`domechk.py`) |
| 4 | 3/4 back right | try 1 + donor legs cols 2,6 | 0.74 / 1.54 | 0 | 1.0 | 0.856 | 8/8 | 0.09 | legs failed twice (0.786/0.782, retry 0.768/0.769): cols 2,6 take the donor legs below 70 % of the figure (`seam.py`) |
| 5 | back | try 1, FITH col 7 | 2.14 / 1.46 | 2 | 1.5 | 0.838 | 6/8 | 0.03 | lead flag off on passing cols 2,8 (IoU 0.895/0.887, sole x 1.5/0.5) |
| 6 | 3/4 front left | try 1 | 0 / 0.74 | 2 | 1.0 | 0.891 | 8/8 | 0.08 | |
| 7 | left | try 1, FITH cols 4,8 | 1.64 / 0.79 | 1 | 1.0 | 0.835 | 8/8 | 0.15 | |
| 8 | 3/4 back left | retry + donor legs cols 2,6 | 1.69 / 1.69 | 0 | 1.0 | 0.812 | 8/8 | 0.06 | legs failed twice (0.662/0.631, retry 0.781/0.797): cols 2,6 take the donor legs below 78 % (0.70 kept the donor's rifle claw) |

Dome measure for rows 4-8 is the helmet only (`DOMERUN=1`: the longest opaque run per row of the band), because the
raised flame sits beside the helmet in the back facings (row 5 plain: dome read 30 % wide, figure scaled 23 % short).
Eye, 4x crops (`eye_run*_4x.png` in the round): one bottle in one claw as in the walk sheet of that facing, amber flame,
flat rigid striped collar, no rifle remnant, no extra hand, no teal.

## Wiring

`rivet_motion.json` grid_stride.run_row_k `p70/molotov/0` 0.98, `/1` 0.98, `/3` 0.96, `/4` 0.99 (own run travel under the
bare run's, the plasma sword rule); walk numbers untouched (cycle 81, contacts 27.5/34.5). `walk_grid.by_weapon` unchanged:
`RivetWalk.path_of` takes the weapon's own run8 first. `test_rivet_walk_sprint_fallback.gd`: no p70 or p55 weapon is
walk-only now, so the molotov stays the example with `RivetStrips._exists[run8] = false`, plus a pin that it sprints on
its own sheet. `run_unit --changed`: 736 passed, 0 failed. `quick.mjs` Godot parse fails 'Failed to compile depended
scripts' on untouched files (rig_clips.gd, events.gd, ...): environmental; `--no-godot` ok.

## In game: foot_slide, turn_090 lane row 0, 32 px/m

| sheet | walk hold mean / max cm (bar <= 2) | run step mean / max cm (bar <= 7) |
|---|---|---|
| molotov (own walk + new own run) | 0.43 / 1.56 PASS | 7.28 / 9.86 MISS by 0.28 |
| plasma rifle donor, same capture | 0.60 / 1.56 | 6.69 / 8.93 |

The run lane reads the new sheet (strip `rivet_run8_eq_molotov.png`). The two planted steps are 9.86 + 4.69 cm vs the
donor's 8.93 + 4.45 cm: 0.30 px and 0.08 px at 32 px/m; not traced to cells (row 1 sole x is within 1.0 px of the donor in every cell, a likely source).

Files (`C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/`): `grid_molotov_run_foot_slide_32.json`,
`grid_plasma_rifle_foot_slide_32.json`, `grid_molotov_arena/rows/`, `grid_plasma_rifle_arena/rows/`,
`grid_molotov_64.png` / `grid_molotov_32.png` (8 run facings: stop-gap | new | plasma rifle),
`grid_molotov_arena/candidate_32/`, `candidate_64/` (boulevard run film, 16 samples each).

## Run step trace (n30-09)

The foot_slide run lane (turn_090, lane row 0 = front facing, 32 px/m) plants in two windows: ticks 53-93 over run cells 4,5,6
(9.86 cm) and ticks 107-147 over cells 0,1,2 (4.69 cm); the donor's are 52-92 and 107-146 (8.93 / 4.45 cm). Sole x
(`foot_slide.sole_x`, sheet px) of row 1 per cell, molotov vs plasma rifle donor: cols 4,5,6 are 107.5/88.0/102.0 vs 107.5/88.5/102.5,
cols 0,1,2 are 80.5/84.5/77.0 vs 80.5/84.5/77.5 (col 3 differs by 1.0). Cells are registered within 0.5 px, yet the planted
step is 1 cm over: the planted foot rides the strip, so the 0.5 px offsets in cols 5 and 6 are the drift.

Route A (data) failed: `p70/molotov/0` 0.98 -> 1.0 gave bit-identical numbers (7.28/9.86): armed runs have no bare cycles, so
`phase_of` takes `max(cycle * k, speed / MAX_RUN_CYCLES_S)` and the floor binds at 3.2 m/s; the k cannot move this row (left at 0.98).
Route B (art, registration): row 1 cols 5 and 6 (cells 6 and 7) moved 1 px right inside their cells (alpha moved, not repainted;
sole x 89.0/103.0, 0.5 px the other side of the donor). Re-measured after `--import`, same capture:

| run | walk hold mean / max cm (bar <= 2) | run step mean / max cm (bar <= 7) | planted steps cm |
|---|---|---|---|
| before (4513bda2a) | 0.43 / 1.56 | 7.28 / 9.86 MISS | 9.86, 4.69 |
| k 1.0 (route A) | 0.43 / 1.56 | 7.28 / 9.86 MISS | 9.86, 4.69 |
| cols 5,6 +1 px (route B, shipped) | 0.43 / 1.56 PASS | 5.77 / 6.85 PASS | 6.85, 4.69 |

Files: `molotov_run_k100_foot_slide_32.json`, `molotov_run_shift56_foot_slide_32.json` beside the old json in
`C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/`.

## Grid at HEAD (n30-22)

The 11:30 grids were rendered before `0e399a732` moved row 1 cols 5, 6 of `p70/rivet_run8_eq_molotov.png` by 1 px. Re-rendered at
HEAD (4c5da4f7b) as new files; the old `grid_molotov_64.png` / `_32.png` and `grid_molotov_arena/` are untouched.

Commands (cwd = worktree, `GODOT_BIN` + n30 keys `APPDATA`, lane lock held around Godot):
- `python -I .../rivet-n30/molotov/scripts/composite.py build/n30-22` (no Godot; reads the shipped art; the grid is a composite, not a capture), copied to
  `grid_molotov_head_64.png` / `_32.png`.
- `build/n30-22/capture28_head.py molotov rows` and `... candidate` = `capture28.py` with only the output dir changed to `grid_molotov_head_arena`
  (and its sources read from the archived `rows_source` / `candidate_source`, the n24 path it named is gone). All three captures exit 0.
- `python -I tools/film/foot_slide.py grid_molotov_head_arena/rows/turn_090/molotov_32 --out grid_molotov_head_foot_slide_32.json`.

Per-cell diff, old grid vs head grid (8 facings x 3 bands x 8 columns, changed px = any RGB channel differs):

| ppm | cell | changed px |
|---|---|---|
| 64 | facing 1, new, col 5 | 13705 |
| 64 | facing 1, new, col 6 | 14595 |
| 64 | total | 28300 (every other cell 0, stop-gap and plasma rifle columns 0) |
| 32 | facing 1, new, col 5 | 3463 |
| 32 | facing 1, new, col 6 | 3677 |
| 32 | total | 7140 (every other cell 0) |

The bar holds: only the two cells that show row 1 cols 5, 6 differ. The counts are not a thin outline: a 1 px sheet shift moves the
whole figure under nearest scaling, so rim, shading and panel edges all change (the sheet itself differs on 31183 px, all in row 1 cols 5, 6).

foot_slide, turn_090 lane row 0, 32 px/m (`grid_molotov_head_foot_slide_32.json`): walk hold 0.43 / 1.56 cm (bar <= 2) PASS;
run hold 0.45 / 1.56; run step mean / max 5.77 / 6.85 cm (bar <= 7) PASS, planted steps 6.85 + 4.69 cm. Identical to n30-09 (`molotov_run_shift56_foot_slide_32.json`).

Seen at 2x on `grid_molotov_head_64.png`, front facing (r1 new, cols 4 to 7 cropped): the bottle sits in the left claw with an amber flame
above it, the other claw is open and empty, the soles are under the body in each cell, the collar is a flat striped hazard band, no rifle remnant.
Cols 5 and 6 (the moved cells) read like their neighbours with no seam or clipped edge.

Files: `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_head_64.png`, `grid_molotov_head_32.png`, `grid_molotov_head_arena/`
(`rows`, `candidate_32`, `candidate_64`), `grid_molotov_head_foot_slide_32.json`; `frames.json` entry now `molotov/grid_molotov_head_64.png`.
