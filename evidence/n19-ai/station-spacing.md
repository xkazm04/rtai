# City station spacing

## A10b wall collision

Baseline `d6f76375c7429615cec9c57838834c6b496a0a82`. Wall collision and tests `01781501ffa0e6050139f5d06651dcbcbde3b93e`. For each spacing push the partner's pursuit map supplies the wall, cover and solid city boxes. The stage's circle resolver supplies the candidate position. The route map checks the segment to that point, including a push that could otherwise cross a thin wall and end in open space. A partner without pursuit holds its position.

The probe counted a tick once when any living station partner's centre was inside any solid. It sampled immediately after the partner's spacing step and again after all stage hooks. The second sample also counted ticks with a living hostile within 1 m. Both revisions used seeds 20261103 through 20261122 and 2,400 ticks per seed. All 40 baseline digests reproduced the A10 results.

| City brain | Ticks per revision | Inside immediately after spacing, before / after | Inside at tick end, before / after | Crowded at tick end, before / after | Mean clear (s), both revisions | Mean HP lost, both revisions | Deaths, before / after |
|---|---:|---:|---:|---:|---:|---:|---:|
| Guard | 48,000 | 0 / 0 | 0 / 0 | 0 / 0 | 17.6825 | 3.15 | 0 / 0 |
| Squad | 48,000 | 436 / 0 | 0 / 0 | 0 / 0 | 18.1300 | 2.91 | 0 / 0 |

All 436 baseline post-push penetrations occurred on squad seed 20261107. The stage cleared them by tick end. All 40 paired seeds reproduced the full `fight` result, including individual waves, HP lost and deaths. All reached the three-wave objective. The per-seed clear times and HP losses are in the A10 table below. Squad took 2.5% longer and lost 7.6% less HP than guard.

### Tick 697

The replacement `C:/Users/kazda/kiro/gtai-masters/n19/ai/station/after-t0697.png` has SHA-256 `9fbaedaa45b61a1180f7eea7146841ba7d1af1f1f9972ad005a58b362a13622a`. I opened the old and new stills and compared the west end at double size. The northern cop's boot previously extended onto the top of the slab. In the new frame his feet meet the pavement above its edge. The southern cop's helmet is partly occluded by the drawn wall end. His centre is 1.050 m from the physical box. The five body circles clear the slab and their closest centre pair is 1.650 m apart.

| Partner | Distance from centre to north wall box at tick 697 (m) |
|---|---:|
| 3000 | 1.050 |
| 3001 | 1.946 |
| 3002 | 0.578 |
| 3003 | 1.658 |
| 3004 | 0.736 |

The guard radius is 0.45 m. The wall spans x = 529 to 543 m and y = 533.7 to 534.3 m. All five partners spawn north of this wall at y = 528.4 m. The film used the same camera (530, 535), seed 20261103, squad, pit bot, combo view, 32 px/m and 1280 x 800 frame as A10.

### A10b checks and reproduction

At the baseline, the three original spacing tests passed and all three new tests failed. The new tests cover a push into a wall face, a push through a thin slab to a clear endpoint and a partner without a pursuit map. On the gameplay commit all six passed. The quick gate passed on the five changed GDScript files and the commit hook passed all 18 scoped lint checks. Both restored comments fit within the existing 251 lines of `combat_arena.gd`.

All 17 scenarios in the command below passed. Their log contains the existing Godot shutdown resource diagnostics. The film passed with the same triangulation diagnostic recorded in the original shot. Fresh pit probes matched all 20 fair20 digests per brain. Quest 1 matched the five reference digests per brain in `evidence/n19-ai/cost-digests.json`. The digest commands below were repeated with output under `build/a10b`.

Use the APPDATA and GODOT_BIN settings in the reproduction block below and run one Godot process at a time. For the baseline, use the A10b observer from this evidence revision with the project at `d6f76375c`.

Mutation of `project/features/combat/guard_brain.gd` lines 17-26 killed 10 of 11 valid mutants (90.9%), with zero invalid and zero timeouts. The control passed 23 tests. The survivor changed the ID tie-break from `>` to `>=` for distinct fighters with distinct IDs. Replacing the resolved move with `g.pos += push` failed both wall tests by assertion. Removing the push entirely also failed the original overlapping-partners test.

```powershell
python evidence/n19-ai/station-probe.py build/a10b/before
# With project at 01781501f:
python evidence/n19-ai/station-probe.py build/a10b/after
node tools/tests/run_unit.mjs --select=test_arena_station_spacing --no-rerun
node tools/gate/quick.mjs --no-clash --files=project/features/arena/arena_walls.gd,project/features/combat/combat_arena.gd,project/features/combat/guard_brain.gd,project/features/combat/guard_pursuit.gd,project/tests/unit/test_arena_station_spacing.gd
node tools/tests/run_scenarios.mjs --only=arena_stations,rivet_claw,rivet_chainsaw,rivet_katana,arena_city,arena_zebra,arena_pit,quest1_dent,quest1_dent_lock,quest1_input,quest1_kerf,quest1_keys,quest1_ohm,quest1_tonnage,quest_collect_call,enemy_pit,enemy_waves
node evidence/n19-ai/station-mutate.mjs --lines=17-26
node evidence/n19-ai/station-film.mjs 01781501ffa0e6050139f5d06651dcbcbde3b93e build/a10b/film-after
```

## A10 original spacing comparison

The five city station partners now use 1.65 m centre spacing. `arena_stations.gd` reads the optional `city.station_spacing_m` from `project/data/tables/arena_stations/arena.json` under `arena_station.schema.json`. On the city block, `arena_session.gd` sets the `fighter.gd` field on the claw station's own partners. The guard branch in `combat_arena.gd` calls `GuardBrain.space_partner`, which shares `EnemyMotor.repel` with the squad motor. The stage then applies its wall and city collision. Wave members and range dummies can be neighbours. Only the station partner moves in response.

| City brain and revision | Ticks with any partner within 1 m / 48,000 | Crowded partner-ticks | Mean three-wave clear (s) | Mean HP lost | Deaths |
|---|---:|---:|---:|---:|---:|
| Guard before | 36,610 | 110,321 | 17.6825 | 3.15 | 0 |
| Guard after | 0 | 0 | 17.6825 | 3.15 | 0 |
| Squad before | 36,388 | 114,314 | 18.1300 | 2.91 | 0 |
| Squad after | 0 | 0 | 18.1300 | 2.91 | 0 |

Squad took 2.5% longer to clear and lost 7.6% less HP than guard. All 40 runs reached the three-wave objective at each revision. Clear time and HP lost matched before and after on every paired seed. On guard seed 20261121 the sixth wave took three additional ticks.

The before gameplay HEAD was `f4b08fa71568d8cf032b1901797e79fc3f57505a`. Commit `34a4d1b57` recorded the baseline, including the match to all 40 A9b city digests in `build/a9b/final`. The after gameplay and test HEAD was `27fde67fa1c63f5e561b450b939ba04bb322d099`.

For the absent-key control, I ran the after code with the before revision's station table. The only data difference was the optional city spacing block. With the ordinary A1 probe, all 20 guard and 20 squad city fight digests and every non-timing result field matched the before runs exactly. I restored the enabled table byte for byte.

The A1 fight probe runs the pit bot for 2,400 ticks on each seed from 20261103 through 20261122. Its normal trace covers wave members. The observer in `station-probe.py` samples after all station hooks, before the stage returns. It counts each living partner (3000 through 3004) once if its centre is at most 1 m from any other living fighter in the arena's hostile list, including wave members and dummies. A tick with multiple affected partners counts once in the first column. The observer restores the original stage bytes after each sweep.

## City results by seed

Each seed contributes 2,400 end-of-tick observations. The clear-time and HP pairs give guard first and squad second. Every row had zero deaths in both brains.

| Seed | Guard crowded ticks before | Squad crowded ticks before | Crowded ticks after (guard / squad) | Clear time (s) | HP lost |
|---:|---:|---:|---:|---:|---:|
| 20261103 | 1,096 | 1,862 | 0 / 0 | 16.82 / 17.02 | 1.80 / 1.80 |
| 20261104 | 2,116 | 2,073 | 0 / 0 | 16.93 / 21.18 | 5.40 / 3.00 |
| 20261105 | 2,140 | 1,933 | 0 / 0 | 18.33 / 17.87 | 4.20 / 2.40 |
| 20261106 | 1,479 | 2,122 | 0 / 0 | 16.95 / 16.42 | 2.40 / 2.40 |
| 20261107 | 2,123 | 1,224 | 0 / 0 | 17.87 / 20.73 | 3.60 / 4.80 |
| 20261108 | 2,031 | 1,848 | 0 / 0 | 17.87 / 16.10 | 3.60 / 1.80 |
| 20261109 | 2,118 | 2,031 | 0 / 0 | 17.87 / 16.62 | 3.00 / 0.60 |
| 20261110 | 1,298 | 789 | 0 / 0 | 17.48 / 19.43 | 6.00 / 1.20 |
| 20261111 | 1,403 | 2,110 | 0 / 0 | 16.37 / 18.32 | 4.20 / 6.00 |
| 20261112 | 2,104 | 1,717 | 0 / 0 | 17.87 / 17.40 | 0.60 / 1.80 |
| 20261113 | 2,143 | 1,961 | 0 / 0 | 19.20 / 17.92 | 3.60 / 1.20 |
| 20261114 | 1,906 | 1,390 | 0 / 0 | 16.98 / 18.07 | 6.60 / 1.20 |
| 20261115 | 2,137 | 2,115 | 0 / 0 | 17.38 / 17.98 | 0.60 / 3.00 |
| 20261116 | 656 | 2,047 | 0 / 0 | 18.20 / 18.02 | 1.80 / 3.60 |
| 20261117 | 2,124 | 2,012 | 0 / 0 | 16.63 / 19.48 | 4.20 / 1.20 |
| 20261118 | 2,104 | 1,761 | 0 / 0 | 18.42 / 17.37 | 4.80 / 4.20 |
| 20261119 | 2,000 | 1,962 | 0 / 0 | 18.28 / 17.33 | 1.80 / 2.40 |
| 20261120 | 2,079 | 1,830 | 0 / 0 | 18.53 / 18.65 | 1.80 / 9.60 |
| 20261121 | 2,138 | 1,692 | 0 / 0 | 18.38 / 18.12 | 0.60 / 3.00 |
| 20261122 | 1,415 | 1,909 | 0 / 0 | 17.28 / 18.58 | 2.40 / 3.00 |

## Matched stills

I opened both PNGs. Before spacing, the five bodies crowd the corner and obscure each other's outlines. After spacing, all five can be picked out individually on the asphalt and pavement around the wall end. The camera was locked at (530, 535) m for both captures, with the pit bot, squad, seed 20261103, combo view, 32 px/m, 1280 x 800 and film tick 697. The closest pair of station centres changed from 0.99995 m to 1.65001 m. Both film runs passed on D3D12 at (0, 1440), with zero script errors. Both logs contain the existing triangulation and shutdown diagnostics.

| Original A10 PNG (superseded after frame retained in `build/a10/film-after/t697.png`) | Original SHA-256 |
|---|---|
| before-t0697.png | `02416d9018611466c542b4b0d05d221266855ebb70d9ca60f247d87f32b1b00a` |
| after-t0697.png | `0258a868199208d44a6455279570b5e1673cc6387cfef4b886dd581329b14fdc` |

## Reproduction

Run each command from this worktree at the indicated gameplay revision, one Godot process at a time. The film wrapper passes the revision to `tools/film/film.mjs`, checks the clean project against that HEAD and sets the second-display window position.

For a fresh baseline checkout with both wrappers already in Git, use `34a4d1b57` for the checkout and the film revision. Its project tree is identical to the original before capture.

```powershell
$env:APPDATA='C:/Users/kazda/kiro/gtai-n19/appdata/ai'
$env:GODOT_BIN='C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe'
node evidence/n19-ai/station-film.mjs f4b08fa71568d8cf032b1901797e79fc3f57505a build/a10/film-before
python evidence/n19-ai/station-probe.py build/a10/before
node evidence/n19-ai/station-film.mjs 27fde67fa1c63f5e561b450b939ba04bb322d099 build/a10/film-after
python evidence/n19-ai/station-probe.py build/a10/after
node tools/tests/run_unit.mjs --select=test_arena_station_spacing,test_arena_stations,test_enemy_motor,test_guard_tell,test_arena_squad --no-rerun
node tools/gate/quick.mjs --no-clash
node tools/tests/run_scenarios.mjs --only=arena_stations,rivet_claw,rivet_chainsaw,rivet_katana,arena_city,arena_zebra,arena_pit,quest1_dent,quest1_dent_lock,quest1_input,quest1_kerf,quest1_keys,quest1_ohm,quest1_tonnage,quest_collect_call,enemy_pit,enemy_waves
```

The key-absent control used `node tools/dev/run.mjs fight_probe --encounter=city --seeds=20 --enemy-brain=<brain> --out=<absolute-json-path> --timeout=300` for each brain, writing under `build/a10/absent`.

All 34 selected GUT tests passed. The quick gate passed on the eight changed GDScript files, and all 19 scoped pre-commit lint checks passed. The station data files validated against the updated schema.

| Requested scenarios | Result |
|---|---|
| scenario_arena_stations, scenario_arena_city, scenario_arena_zebra, scenario_arena_pit | 4/4 passed |
| scenario_rivet_claw, scenario_rivet_chainsaw, scenario_rivet_katana | 3/3 passed |
| scenario_quest1_dent, scenario_quest1_dent_lock, scenario_quest1_input, scenario_quest1_kerf, scenario_quest1_keys, scenario_quest1_ohm, scenario_quest1_tonnage | 7/7 passed |
| scenario_quest_collect_call | Passed |
| scenario_enemy_pit, scenario_enemy_waves | 2/2 passed |

## Pit and quest digests

Each comparison joined the complete seed set to its SHA-256 fight digests. The pit also matched every non-timing field of the fair20 runs. Both quest brains reproduced the same five per-seed digests from `evidence/n19-ai/cost-digests.json` at `91644f6cfe4259ee384fa2636dfbcd3876f018da`.

| Encounter and brain | Reference | Matched | SHA-256 of ordered seed/digest lines |
|---|---|---:|---|
| Pit guard | build/fair20/pit-guard.json | 20/20 | `ba86a1f16c99da7a926475ffd8e025313cfcef8c8ba455ce9ae9f5fb44e981e4` |
| Pit squad | build/fair20/pit-squad.json | 20/20 | `05a1c27b7f94c55f651bf8bc3d1868a7c88acc99246c13420e833a12fc91ba65` |
| Quest 1 guard | cost-digests.json | 5/5 | `e2d20fbb4b06da41d261fbb8a308598da6c8e5e0debaa08caee7fcbef4e2c60a` |
| Quest 1 squad | cost-digests.json | 5/5 | `e2d20fbb4b06da41d261fbb8a308598da6c8e5e0debaa08caee7fcbef4e2c60a` |

The ordered input to the last column is ASCII, one line per ascending seed, with one space between the decimal seed and its lowercase hex digest and an LF after every line.

| Quest 1 seed | Matched fight digest in both brains |
|---:|---|
| 20261103 | `0e26748f40d64c51e27d2ac3fe8c9b81d7f1723d1f9d5e61cd686d39e1bb566f` |
| 20261104 | `53d9556ea0e1315b4cebb25d94b1258d22608cbe47177e4a37e89ea942ce8cb6` |
| 20261105 | `3e19499c28878dac78e27a9504f3f3c4bb6f6fa93f22f666b9a6f4ea5f07a082` |
| 20261106 | `02f49b97b9ccf8d34409c4996f9d612675f25eff7a3a246e8995683825319334` |
| 20261107 | `167aca0103c2f65c271bf819497699917a1f9068135b61854ff240fadc9119f3` |

```powershell
foreach ($encounter in @('pit','quest1')) {
  foreach ($brain in @('guard','squad')) {
    $n = if ($encounter -eq 'pit') { 20 } else { 5 }
    $out = Join-Path $PWD "build/a10/$encounter-$brain.json"
    node tools/dev/run.mjs fight_probe "--encounter=$encounter" "--enemy-brain=$brain" "--seeds=$n" "--out=$out" "--result=$out" --timeout=300
  }
}
```

## Mutation score

`node evidence/n19-ai/station-mutate.mjs` ran every single-line mutation generated by `tools/mutate/operators.mjs` for `project/features/combat/guard_brain.gd` at the after HEAD. It used a disposable project copy under this worktree's `build/a10`. Each fault ran alone in a fresh headless GUT process. The unchanged control passed all 20 tests across station spacing, guard routing, guard tells, Dock 9 waves and the fight probe.

| Scope | Killed | Survived | Killed / (killed + survived) | Invalid | Timed out |
|---|---:|---:|---:|---:|---:|
| Entire GuardBrain | 21 | 17 | 21/38 (55.3%) | 0 | 0 |
| Changed spacing helper | 8 | 1 | 8/9 (88.9%) | 0 | 0 |

The helper's sole survivor changes the ID tie-break from `>` to `>=`. Self is already excluded and distinct fighters have distinct IDs. The other 16 survivors are in the existing guard trigger and approach code. In a separate control, replacing the whole helper with a no-op failed both the overlapping-partner test and the live-wave-neighbour test by assertion.
