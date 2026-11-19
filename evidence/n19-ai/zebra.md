# City arena zebra crossings

The city arena at hub (524, 524) had four wall/cover intersections on three props at baseline `52aa0c510`. The fixed layout has zero across 47 solid boxes and 11 generated zebra decals in the station bounds. Prop indices start at zero. The judge reads each decal's world transform from the generated chunk and its full footprint from the city texture table.

| Station/prop | Crossing centre (world m) | Before (m²) | After (m²) |
|---|---|---:|---:|
| pit/0 | (524, 531.35), south approach | 2.400 | 0 |
| pit/1 | (524, 531.35), south approach | 2.100 | 0 |
| pit/1 | (531.35, 524), east approach | 1.440 | 0 |
| boss_fight/24 | (652, 516.65), boulevard north approach | 0.560 | 0 |

The third north-wall segment, pit/2, had no overlap before the change. All three segments and their two door markers moved 3 m south, from hub-relative y = 7 to y = 10. Both openings remain 4 m wide. A 1 m move still intersected the decal. A 2 m move cleared the ground footprint, but the raised wall still covered the tips of the stripes in the default combo view. The 3 m move is the first whole-metre shift that clears both. The boulevard high cover needed 1 m north.

Only city sessions apply these offsets, before building the walls, guard routes and floor view from the session's station props. Both layouts dropped the same five existing spawns inside buildings.

## Five-seed city fight

Each run used `node tools/dev/run.mjs fight_probe --encounter=city --seeds=5` with an explicit brain and JSON output. Clear time covers the first three waves. HP lost and deaths cover all 2,400 ticks. Every run reached the three-wave objective. Each pair below is before → after.

| Seed | Squad clear (s) | Squad HP lost | Guard clear (s) | Guard HP lost |
|---|---:|---:|---:|---:|
| 20261103 | 19.75 → 19.72 | 0.60 → 1.20 | 16.82 → 16.82 | 2.40 → 1.80 |
| 20261104 | 19.57 → 18.93 | 4.20 → 2.40 | 17.75 → 16.93 | 5.40 → 5.40 |
| 20261105 | 20.33 → 20.68 | 3.00 → 3.60 | 18.47 → 18.33 | 5.40 → 4.20 |
| 20261106 | 19.50 → 26.03 | 3.60 → 2.40 | 16.52 → 16.95 | 4.20 → 2.40 |
| 20261107 | 20.98 → 22.67 | 4.20 → 1.20 | 18.35 → 17.87 | 0.60 → 3.60 |
| **Mean** | **20.03 → 21.61** | **3.12 → 2.16** | **17.58 → 17.38** | **3.60 → 3.48** |

Mean clear time changed **+7.9% for squad** and **−1.1% for guard**, from unrounded times. **Squad seed 20261106 took 33.5% longer** after the layout change, the only individual clear-time change over 10%. Both brains had zero deaths on every seed before and after.

## Replays and regression

The same judge runs through `node tools/dev/run.mjs zebra_walls` and `scenario_arena_zebra`. It also checks the original doorway widths and segment alignment. Removing the entire `city.shift_props` key on disk reproduced all four baseline intersections and made the scenario exit 1. Restoring the key produced the following result.

```text
zebra_walls: 0 overlaps (47 boxes, 11 decals); unshifted: 4
```

The replay digests below are the simulation's final SHA-256 from the scenario recording. Both city layouts replayed identically against their own recording. The only gameplay difference between the two digest runs was the city prop override.

| Scenario | Before | After |
|---|---|---|
| arena_city | `f50c0146e8f0d4251ecce0adc3abc1923282fc64c42c85496b7fbc6252d0f848` | `86fa7b6d1ce3882f13d061c79fa69662f0a83dc43b1bfe6d5cc72e9f5c11babe` |
| arena_pit | `de7eb709c6f69239ad37a3d32777f416c3286e2cdfb92ef6114584b3ad515cef` | identical |

The pit completed two waves in 12.93 s in both runs. Pit and city telemetry and the station report each matched the pre-change file byte for byte. The scenario run covered arena_city, arena_pit, arena_stations, arena_zebra, arena_squad and rivet_city_fight. The unit run covered arena walls, stations, guard-wall collision and the fight probe. The junction and block look goldens passed 11/11 and 5/5.

```text
run_scenarios: 6 ran, 0 failed
unit-tests: 20 passed, 0 failed, 0 skipped (GUT, headless)
quick: ok, 7 file(s)
lint: all 19 checks pass over 1626 GDScript files
```

## Frames

The D3D12 captures used the secondary screen at (0, 1440), the combo view, seed 20261103, tick 30 and a 1600 × 800 viewport. The 32 px/m pair used the same camera transform centred at (538, 531). The 64 px/m close-up centres on the south zebra at (524, 531.35). In both after frames, asphalt separates the ends of the stripes from the top of the wall.

| Frame | File under `C:/Users/kazda/kiro/gtai-masters/n19/ai/zebra/` |
|---|---|
| Before, 32 px/m | `north-wall-before-32ppm-t30.png` |
| After, 32 px/m | `north-wall-after-32ppm-t30.png` |
| After, south crossing at 64 px/m | `crossing-after-64ppm-t30.png` |
| After, boulevard crossing at 64 px/m | `boulevard-cover-after-64ppm-t30.png` |

The additional boulevard close-up shows a gap between the dumpster and the stripes. The pit film logs reported the same rig-shadow triangulation error and shutdown resource diagnostics before and after. All stills were saved and inspected.
