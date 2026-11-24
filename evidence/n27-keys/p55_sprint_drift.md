# p55 bare sprint profile drift (n27)

Brief `n27-05-p55-drift`. Last run (`evidence/n26-keys/hands_after.md`) left the p55 bare sprint profile drift at 8.53 cm at 32 px/m (bar 7 cm).

## Change

`rivet_motion.json` `grid_stride.run_row_k` gains `p55/sprint/2` and `p55/sprint/6` = 0.98 (the right and left profile rows of `p55/rivet_run8.png`).
`RivetGridStride.sprint_k(art, row, mps)` fades the factor in linearly from 1.0 at the 6.75 m/s walk to the full value at the 9.3 m/s sprint
(`RivetWalk._bare_cycles` multiplies the row's measured stance cycles by it). At 6.75 m/s the factor is exactly 1, so the walk, every p70 row
and the depth rows are untouched; the p55 sprint cycle is 2 % shorter. Visual only: `RivetWalk` reads no sim state and writes none.

Why not a flat row factor: scaling the row at both speeds moved the 6.75 m/s p55 profile walk mean from 2.29 to 2.76 cm (0.98), 3.49 (1.02) and 4.95 (0.96).

## Measurement

Same harness as `hands_after.md` (arena, `StagePilot` + `LiveInput`, run8 sheet, planted-boot residual per stance, 120-tick beats, 8 facings x walk 6.75 / sprint 9.3 m/s).
Before = the committed table re-measured (it reproduces `hands_after.md` exactly: 3.13/1.46 walk and 9.31/7.75 sprint at p55 32). Drift in cm, right and left profile, profile mean.
Smallest drawing hold on either profile in the last column (ticks, bar >= 2).

| Pitch | px/m | Speed (m/s) | Right drift (cm) | Left drift (cm) | Profile mean (cm) | Min hold (ticks) |
|---|---:|---:|---|---|---|---:|
| p70 | 32 | 6.75 | 0.94 → 0.94 | 2.92 → 2.92 | 1.93 → 1.93 | 6 |
| p70 | 32 | 9.30 | 2.56 → 2.56 | 2.31 → 2.31 | 2.44 → 2.44 | 4 |
| p70 | 64 | 6.75 | 0.46 → 0.46 | 2.92 → 2.92 | 1.69 → 1.69 | 6 |
| p70 | 64 | 9.30 | 3.34 → 3.34 | 3.09 → 3.09 | 3.22 → 3.22 | 4 |
| p55 | 32 | 6.75 | 3.13 → 3.13 | 1.46 → 1.46 | 2.29 → 2.29 | 5 |
| p55 | 32 | 9.30 | 9.31 → 2.31 | 7.75 → 3.00 | 8.53 → 2.66 | 3 |
| p55 | 64 | 6.75 | 3.91 → 3.91 | 0.52 → 0.52 | 2.22 → 2.22 | 5 |
| p55 | 64 | 9.30 | 8.53 → 3.09 | 7.75 → 4.56 | 8.14 → 3.83 | 3 |

p55 32 px/m sprint profile mean 8.53 → 2.66 (bar 7). p55 walk and both p70 rows are bit-identical to before (same measured values).

## Factor scan (p55, 32 px/m, profile sprint mean cm)

Drift on a 4-stance take is quantised by the 15.5 cm a sprint tick covers, so the mean is not smooth in the factor. Row factors 0.97 / 0.98 / 0.99 / 1.00 / 1.02:
6.56 / **2.66** / 5.03 / 8.53 / 4.51. At 64 px/m the same three lowest: 5.78 / **3.83** / 5.42 (1.00: 8.14). 0.98 is the only value under the bar at both zooms with margin; 0.97 and 0.99 pass only by luck of the phase.
Scaling both speeds (rejected, above): 0.96 6.06, 0.98 3.62, 1.02 3.72, 1.04 6.60, with the walk worse at every one of them.

## Identity

`node tools/tests/run_scenarios.mjs` -> `scenario-tests: 68 passed (headless)`, no DIVERGED. The change touches only a view-side cadence; no sim input, no tape bit.
`node tools/tests/run_unit.mjs --changed`: `4094 passed, 0 failed, 2 skipped (FLAKY 1: test_audio_driving, unrelated)` before the code was split into its final files; then `--select=test_rivet_grid_stride,test_rivet_walk,test_rivet_sprint_k` 22 passed.

## Media

- `C:/Users/kazda/kiro/gtai-masters/n27/keys/p55_sprint_before_after_32.mp4`: before | after, same ticks, p55 sprint in 8 directions (93 ticks each, 2x crop on Rivet, nearest), 1920x1080 60 fps, 12.43 s.
- `C:/Users/kazda/kiro/gtai-masters/n27/keys/p55_sprint_before_after_64.png`: the right profile sprint at 64 px/m, same tick (1048), before | after.

## Mutate

`node tools/mutate/mutate.mjs --file=project/features/characters/rivet_grid_stride.gd --max=20 --lines=8-9,50-52 --tests=test_rivet_grid_stride,test_rivet_sprint_k,test_rivet_walk` at `5d05dccc5`: 4 mutants, killed 4 / (4 + 0 survived) = 100 %. (The single changed line in `rivet_walk.gd` has no mutable literal; its effect is pinned by `test_the_sprint_factor_shortens_the_bare_cycle_only_at_sprint_speed`.)
