# Contractor squad tuning

The three-slot contractor squad meets the five-seed balance target. The tested default switch broke six existing scripted fights or their judges. Guard remains the default pending the director’s rollout decision.

Five seeds (20261103–20261107), 60 Hz. Clear time covers the first three waves including gaps. Damage and deaths cover the full 2,400 arena ticks. The reference is the A1 guard probe on the same seeds. Percentage changes use the unrounded means. All runs reached their objectives.

| Configuration | Shooter slots | Contractor cover_bias | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---|---|---|---|---|---|---|
| A1 guard | — | — | 17.58 | 3.60 | 14.53 | 7.32 | 0 |
| trial1 | 3 | 0.65 | 19.39 (+10.3%) | 2.88 (-20.0%) | 17.92 (+23.3%) | 9.24 (+26.2%) | 0 |
| trial2 | 4 | 0.65 | 19.81 (+12.7%) | 2.04 (-43.3%) | 17.73 (+22.0%) | 8.64 (+18.0%) | 0 |
| trial3 | 3 | 1.0 | 20.62 (+17.3%) | 3.12 (-13.3%) | 17.42 (+19.8%) | 7.44 (+1.6%) | 0 |
| trial4 | 3 | 0.9 | 21.67 (+23.3%) | 2.64 (-26.7%) | 17.40 (+19.7%) | 7.68 (+4.9%) | 0 |
| trial5 | 4 | 1 | 19.91 (+13.2%) | 2.76 (-23.3%) | 17.43 (+19.9%) | 7.08 (-3.3%) | 0 |
| trial6 | 3 | 0.8 | 19.98 (+13.6%) | 1.44 (-60.0%) | 17.52 (+20.6%) | 7.56 (+3.3%) | 0 |

Selected **trial3**, with 3 shooter slots and contractor cover_bias 1. It minimized the largest absolute percentage change across the four city/pit measurements among zero-death candidates (19.8%). The ±20% tuning target and ±25% default-change condition both passed. Peek, aggression, ranges, HP and weapon values retained their A4 values.

## Mixed roster for the owner’s Call

| Mode | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---|---|---|---|---|
| mixed | 24.60 (+39.9%) | 3.84 (+6.7%) | 21.26 (+46.3%) | 7.32 (+0.0%) | 0 |

The mixed run used the selected slot count and the full production roster. All five non-contractor rows are byte-for-byte unchanged.

## Guard parity

All 15 explicit guard digests equal A1. The table gives the digest prefixes. tune.json retains the full SHA-256 digests and individual fight results.

| Seed | City | Pit | Quest 1 |
|---|---|---|---|
| 20261103 | 7a61766c8e50d058 | 1efb05436029012b | 0e26748f40d64c51 |
| 20261104 | 6c453d01df988d82 | b69d9deefdf67c5a | 53d9556ea0e1315b |
| 20261105 | 638eac3e621c0a7d | cb2515acd326c937 | 3e19499c28878dac |
| 20261106 | b98df35202c6ddff | 3976a3c2f3c61b5b | 02f49b97b9ccf8d3 |
| 20261107 | d91f383ea1078089 | 99df41cff4ce6625 | 167aca0103c2f65c |

Each trial used the same command. The guard and mixed verification runs changed only the brain argument and output path.

~~~powershell
node tools/dev/run.mjs fight_probe --all --seeds=5 --enemy-brain=squad --out=<absolute.json>
~~~

## Replay and golden audit

The production selector has one arena consumer, ArenaStage.setup. The standalone fight probe reads the same default for its report. Quest 1 builds Quest1Session and CollectCallStage.

| Input checked before testing the candidate | What runs |
|---|---|
| Seven tracked gtai.replay/1 JSON logs | The two q1 logs under evidence/it14/linux and the three q1 logs under evidence/it15 are Quest 1. The remaining it15 linrel and winrel logs use the plain World boot. The recording logs and release runner scripts identify those entry points. |
| project/tests/golden/look | All 16 PNGs come from look_golden.gd and its city_selftest.gd base. It builds World, CitySystem, CityView and CityTargets.riot directly. |
| project/data/generated/city_chunks.sha256 | CityBake checks the district and textures through CityGen. The arena table and enemy roster are outside that generator. |
| Native parity and city replay | CityParity drives CitySimBackend pairs. The city_replay scenario uses CitySystem. The 60-second replay and integration replay use DummyRun. CitySimHash tests exercise the spatial actor index on CitySimState. |
| Arena and street scenarios | The city, course, pit, range and mixed-squad scenarios record a new ReplayLog and compare it with a second run. The brutality, city-scare, horde, ghost, reaction, Rivet and showcase scenarios that open ArenaSession likewise generate their fight state at runtime. The gunplay hash test builds CombatArena directly. |
| Enemy pit and waves | PitLayout creates an independent EnemyPit, compares repeated seeds and excludes the production-only contractor. |

The search covered project/tests, including golden and parity, the tools and all tracked replay JSON files. No checked-in gfx replay, parity reference, bake hash or sim digest runs the production arena selector.

## Candidate default verification

With the brain option omitted, all 15 fight digests matched the selected squad trial. The five Quest 1 digests also matched A1. An explicit guard sweep with the candidate default matched all 15 A1 digests. Explicit guard tests exercised the legacy rifle approach and standoff in the candidate.

With cover_bias 1, non-token contractors try cover on every eligible plan. They still flanked when no cover spot was available, for 36 observed hostile-ticks in the city and 12 in the pit across the five seeds.

| Scenario telemetry | A4 guard default → tested squad default |
|---|---|
| arena-city-telemetry | Identical |
| arena-course-telemetry | Identical |
| arena-pit-telemetry | damage_taken 0 → 1.8, dodges 1 → 4, pit_done_s 11.683 → 12.933, shots 5 → 6, shots_stopped_by_cover 0 → 3, ticks 701 → 776 |
| arena-range-telemetry | Identical |
| arena-squad | live.cover 0.51 → 0.522, live.flank_ticks 180 → 24, live.flankers 2 → 4, live.ticks 3071 → 2927 |
| arena-stations | Identical |
| enemy-pit | Identical |
| enemy-waves | Identical |

The candidate pit judge required the bot to finish both scripted waves inside its existing 60-second limit. The mixed scenario explicitly selects mixed on both sides. Its change reflects the shared shooter limit and contractor tuning. The independent enemy pit and wave digests remain c706f7c549ec2a9d and a2eca1619e189de6. tune.json records every changed telemetry field.

Quest 1 telemetry was identical apart from the process-specific scratch path in quest1-input.json. The final replay hash was 37bf8deacaad2f480055af695e77aa9296bb08c4f6b681c57344832333d4664a.

~~~text
run_scenarios: [1/20] arena_city ok, 3.5 s
run_scenarios: [2/20] arena_course ok, 2.2 s
run_scenarios: [3/20] arena_pit ok, 3.8 s
run_scenarios: [4/20] arena_range ok, 3.4 s
run_scenarios: [5/20] arena_squad ok, 11.7 s
run_scenarios: [6/20] arena_stations ok, 0.0 s
run_scenarios: [7/20] city_bake ok, 5.9 s
run_scenarios: [8/20] city_parity_ref ok, 8.5 s
run_scenarios: [9/20] city_replay ok, 7.2 s
run_scenarios: [10/20] enemy_pit ok, 1.8 s
run_scenarios: [11/20] enemy_waves ok, 2.9 s
run_scenarios: [12/20] quest1_dent ok, 0.8 s
run_scenarios: [13/20] quest1_dent_lock ok, 0.3 s
run_scenarios: [14/20] quest1_input ok, 16.7 s
run_scenarios: [15/20] quest1_kerf ok, 0.7 s
run_scenarios: [16/20] quest1_keys ok, 0.1 s
run_scenarios: [17/20] quest1_ohm ok, 0.9 s
run_scenarios: [18/20] quest1_tonnage ok, 0.7 s
run_scenarios: [19/20] quest_collect_call ok, 3.2 s
run_scenarios: [20/20] replay_60s ok, 0.3 s
scenario-tests: 20 passed (headless)
unit-tests: 2967 passed, 0 failed, 2 skipped (GUT, headless)
parity: native == GDScript reference bit for bit over 1200 steps (40 snapshot checks, 3502 floats); planted mutation caught at step 629
~~~

## Additional arena replay scenarios

Six of the sixteen additional scenarios failed with the candidate squad default. All six passed on the same tuned data when only the default was switched back to guard.

| Scenario | Measured outcome | Guard control | Squad candidate |
|---|---|---:|---:|
| scenario_ghost_attacks | Tonnage slams | 2 | 1 |
| scenario_rivet_chainsaw | Cops killed | 3 | 0 |
| scenario_rivet_city_fight | Highest wave reached with close-in and flank disabled | below 3 | 4 |
| scenario_rivet_claw | Claw hits | 10 | 0 |
| scenario_rivet_katana | Cops killed | 4 | 0 |
| scenario_showcase_director | Electro-chain victims killed | 4 | 3 |

The claw station pins the guards’ triggers and relies on their approach to put them within melee reach. Squad steering changes their positions. The city fight’s planted bot disables the legacy pursuit map to make its defenders hold position. The squad keeps a separate route map, so a broken bot can advance. The ghost and showcase scenarios missed their authored attack counts before reaching replay comparison.

## SquadMind mutation check

The mapped arena squad and search-budget tests killed 11 of 20 sampled mutations (55.0%) at commit 8054148b2. 9 survived, 0 timed out and 0 were invalid. The sample covered 20 of 173 available mutations.

## Retained guard default

With no brain flag, all 15 final probe digests matched A1, including all five Quest 1 digests. The final tree passed all 16 requested arena, enemy and quest scenarios. The city, course, pit, range, stations and enemy telemetry matched the pre-tune reference. The scenario that explicitly requests mixed retained the changes shown above. Quest 1 telemetry matched apart from the temporary replay log path. The unit runner reported one radio-action test that passed on its automatic isolated rerun.

~~~text
unit-tests: 2966 passed, 0 failed, 2 skipped (GUT, headless, FLAKY 1)
FLAKY: res://tests/unit/test_audio_driving.gd test_the_radio_action_changes_the_station_only_while_driving
scenario-tests: 16 passed (headless)
~~~
