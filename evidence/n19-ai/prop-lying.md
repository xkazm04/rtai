# Lying-card occlusion at the city kerb

At seed 5, tick 900, cop 3002's visible fall card reaches past its head socket. The original GUT run against `003b2d152` returned an empty patch where the barrier overlapped a 64 × 19 pixel part of the test sprite. The transformed, multi-frame case also failed. Both failures repeated on the isolated rerun.

The fix maps the sprite's current cell directly into the occluder's local coordinates, merges it with the socket box and clips the result to the prop area. A corpse hit requests only the prop redraw. The previous silhouette code clamped a zero-height figure to a one-pixel hip, so setting the hit's head equal to its feet could still draw ink.

## Frame comparison

All captures used D3D12, window position (0, 1440), fixed 60 fps, the Rivet bot, rigs, clean mode, seed 5, tilt70 and tick 900. PNGs are in [the frame directory](C:/Users/kazda/kiro/gtai-masters/n19/ai/prop-lying/).

| Layout | Zoom | Before and after |
|---|---|---|
| Shipped | 32 and 64 px/m | Both corpses lie clear of the wall. Both full-frame pairs have zero changed RGB pixels. |
| Original gfx wall position | 32 px/m | 951 pixels changed, all within x 525–583, y 493–511. The barrier covers cop 3002's helmet and shield. The other corpse remains visible above the barrier. |
| Original gfx wall position | 64 px/m | 8,409 pixels changed, all within x 155–527, y 586–652. The barrier covers the overlapping parts of both corpses at this zoom. |

The shipped layout includes `f20a377ac`, which moved the north wall 3 m south. To repeat the gfx contact, both historical-layout captures temporarily omitted the call to `s.stations.shift_props(s.plan.city_prop_shifts)` in `ArenaSession.open_with_args`. The source bytes were restored after each pair of zooms. The 32 px/m before crop at (384, 416)–(599, 536) matches the director's gfx reference pixel for pixel.

The shipped full frames are named `before-32ppm-t900.png` and `after-32ppm-t900.png`, with corresponding 64 px/m files. The historical-layout filenames start with `gfx-layout-`. The [64 px/m crop](C:/Users/kazda/kiro/gtai-masters/n19/ai/prop-lying/barrier-64ppm-before-after.png) shows before on the left and after on the right at native resolution.

## Verification

- `node tools/tests/run_unit.mjs --changed` passed 2,976 tests with two skips. All seven cases in `test_prop_lying.gd` passed.
- `node tools/tests/run_scenarios.mjs --only=arena_city,arena_pit` passed both scenarios.
- `node tools/lint/lint.mjs` passed all 19 checks. The junction look goldens passed 11/11 and the block goldens passed 5/5. Worst mean pixel differences were 0.31 and 0.17 respectively, against a limit of 4.
- `node tools/gate/quick.mjs --no-clash` exited 1 on the standalone parse of `prop_lying.gd`. The raw `--check-only` runs on `003b2d152` and `35264793b` both reported the unregistered `Log` and `LaunchArgs` autoloads and a `PagedAllocator` shutdown error. The checker retained 117 error and location lines on each version. Quick gate's remaining checks passed on all three files with `--no-godot`. The GUT and scenario runs compiled the project with autoloads registered.
- The windowed captures exited 0. Both versions logged the existing polygon triangulation and resource-shutdown errors. Each run recorded three arena deaths.
- Mutation on `35264793b` scored **100.0%**, with 12 killed, zero survivors, two invalid and zero timeouts across all 14 generated mutants in `features/arena/prop_lying.gd`. The two invalid mutations replaced transform multiplication with unsupported division. The mapped suite ran `test_city_occlusion`, `test_prop_cards`, `test_prop_lying` and `test_prop_occlusion` in 296 seconds including the baseline.
