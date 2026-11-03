# Riot p99 bisect (item 4), 2026-11-03 22:35-23:06

Scenario: `riot` (400 actors on foot, 32 px/m), exported windows-bench (release, D3D12, native sim), 3 runs x 45 s per step, median reported.
Each step: throwaway worktree at the commit, `--import`, `bake_city`, `--export-release windows-bench`, native DLL = int-day's (baf2e80) in every step, private APPDATA, bench.lock held per run.

**CONTENDED**: the machine ran 4-5 other Godot/node sessions the whole time (idle bench of record: p99 4.835 ms). Absolute p99 is 1.5-3x the idle number and noisy, so the verdict rests on the *average frame* (steadier) and on A/B pairs at the same commit.

| step | commit | median p99 (ms) | per-run p99 | median 1 % low (fps) | median avg frame (ms) | sim ms/tick | rig p99 ms |
|---|---|---|---|---|---|---|---|
| base (n-noir, morning main) | 03358af | 6.44 | 6.27 / 6.44 / 6.92 | 106 | 1.28 | 0.153 | 0.864 |
| d-cast merged (after d-city) | 230d281 | 4.94 | 3.18 / 4.94 / 6.00 | 143 | 1.13 | 0.114 | 0.679 |
| **d-combat merged** | f54c4ec | **8.26** | 8.26 / 8.47 / 7.50 | 91 | **2.08** | 0.105 | 0.738 |
| d-vehicles merged | e9239c9 | 7.24 | 6.13 / 7.50 / 7.24 | 101 | 2.06 | 0.102 | 0.672 |
| d-slice merged (very contended, other lane's bench overlapped) | ba6c28e | 15.75 | 16.73 / 15.75 / 14.46 | 41 | 3.99 | 0.183 | 1.021 |
| main tip (int-day) | baf2e80 | 7.91 | 7.71 / 7.91 / 8.04 | 89 | 2.06 | 0.131 | 0.706 |
| **A/B at f54c4ec: CityBlood not attached** | f54c4ec + 2-line patch | **5.23** | 5.23 / 4.28 / 5.30 | 145 | **1.13** | 0.112 | 0.710 |
| A/B: CorpseStains off (no `follow()`) | f54c4ec + patch | 10.14 (load spike, rig p99 also 1.05) | 10.96 / 10.14 / 9.41 | 47 | 2.76 | 0.157 | 1.051 |
| A/B: muzzle pop off (`game.muzzle_pop.on=false`) | f54c4ec + patch | 8.01 | 8.49 / 8.01 / 6.50 | 98 | 2.13 | 0.104 | 0.692 |

Not measured (skipped for time, unmeasured is not zero): d-city alone (76ac381; covered by d-cast, which contains it and is as fast as base), d-bodies (335a835), d-save (7b94e5c), d-audio (8f988db). d-slice's number is noise from an overlapping run, not a verdict; the tip (which contains everything after) is back at 2.06.

## Verdict
- **The step is the d-combat merge (f54c4ec)**: avg frame 1.13 -> 2.08 ms, p99 4.9 -> 8.3 ms (contended). Nothing after it moves the average (d-vehicles 2.06, tip 2.06).
- **The cost is `CityBlood` (boot/city_blood.gd, attached by `CityCharacters._init`)**: the same commit with its two lines (`CityBlood.attach` + `blood.follow`) commented out is back at 1.13 ms avg / 5.2 ms p99.
- Excluded by A/B: the muzzle pop (2.13, unchanged) and, within noise, the corpse stains (2.76 under a load spike where the rigs also doubled: no drop).
- Remaining suspects inside it (not split for lack of time): `CombatBlood` -> `BloodFx` redraw (`queue_redraw` every frame while drops fly, else every `settled_redraw_ticks` = 6; `_draw` re-records every live pool and decal, 16 pools / 1024 decals, `BloodBatch.pool` polygons) in a riot where 100 cops keep killing; `BloodSplatMesh.update` (a shader-parameter set per mesh per frame, plus a full `multimesh.buffer` upload whenever a splat lands); the extra canvas layer/items on the actors canvas.

## Fix
Not made tonight: the cost is in d-combat's fx code (`features/fx`), not look/render/city code, and there was no time to split it further and re-bench. REQUEST 2 in JOURNAL (-> d5-combat/gunplay owner): print `CombatBlood.spent_us / frames` and `BloodFx.draw_us` in the bench JSON (they already exist), then cut the redraw (settled_redraw_ticks 6 -> 30, draw pools only when a pool changes, bake settled pools into the ground print).
Raw runs: `bisect/<step>/riot-N.json`, `step.sh` / `sum.py` reproduce the table.
