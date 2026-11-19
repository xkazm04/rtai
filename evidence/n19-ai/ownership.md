# Squad ownership in the arena

The pit registers its own fighters at spawn and clears membership on replacement or reset. The same spawner supplies the street fight and horde. Only members enter squad planning, token allocation, separation and morale. Regular guards retain the arena's guard tell or GuardBrain, and station dummies retain their station motion.

## Cause of the six A7 failures

Temporary instrumentation on A7 logged each fighter when it first entered ArenaSquad.assign and when it first acquired a token. IDs below are observations from those runs. Registration uses the Fighter instance, so neither numeric ranges nor archetype names decide ownership.

| Scenario | Non-wave fighters assigned on A7 | Consequence |
|---|---|---|
| ghost_attacks | Ghost-reel victims 1-6 and claw cops 3000-3004 | All six victims received a token. Tonnage landed one of two required slams. |
| rivet_chainsaw | Claw cops 3000-3004 | Their pinned triggers prevented tokens, but squad steering moved them out of reach. Zero kills. |
| rivet_claw | Claw cops 3000-3004 | Zero hits on ten attempts. |
| rivet_katana | Claw cops 3000-3004 | Zero kills. |
| showcase_director | Reel victims 1-30 and claw cops 3000-3004 | Victim 15 received a token. The electro-chain chapter killed three of four. |
| rivet_city_fight | Claw cops 3000-3004 plus genuine wave members 1-14 across this scenario's runs | Its stationary-defender control removed guard pursuit while wave members still used the squad's route map. The planted bot reached wave four. Both sides of that control now disable both navigation controllers. Its live fight and replay still run the default. |

In the city and pit probes on seed 20261103, the five claw cops had squad minds and zero shooting tokens. They consumed planning work and participated in steering. The inspected A7 probe reproduced the saved A7 digest in both encounters.

## Five-seed balance

Times cover the first three waves. Damage and deaths cover all 2,400 arena ticks. Percentage changes use unrounded means against A1. Each completed sweep used seeds 20261103 through 20261107 and the production fight probe.

| Run | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---:|---:|---:|---:|---:|
| A1 guard | 17.58 | 3.60 | 14.53 | 7.32 | 0 |
| A7 tuned squad | 20.62 (+17.3%) | 3.12 (-13.3%) | 17.42 (+19.8%) | 7.44 (+1.6%) | 0 |
| A7b scoped squad | 20.03 (+13.9%) | 3.12 (-13.3%) | 17.10 (+17.7%) | 7.08 (-3.3%) | 0 |
| A7b mixed | 23.83 (+35.6%) | 3.24 (-10.0%) | 20.63 (+41.9%) | 8.16 (+11.5%) | 0 |

Compared with A7, the scoped squad changed city clear by -0.59 s and kept mean damage at 3.12 HP. Pit changed by -0.31 s and -0.36 HP. The mixed roster remains an owner's Call on clear time. No row or weapon changed.

With ownership alone, city seed 20261104 cleared only two waves within the 40-second probe. The remaining contractor repeatedly walked out of cover, spent its peek on distant sight and retreated before sustaining an engagement. Counting row-defined peek time when the enemy can see a target within attack range let all five seeds finish. The raw ownership-only results, including the incomplete seed, are in ownership.json.

All 15 explicit guard SHA-256 digests matched A1. Quest 1 uses its own stage. The seven recorded replays, 16 look goldens, city bake, city parity and standalone sim hash tests identified in the A7 audit have no dependency on the production arena selector.

## Scenario coverage

With exactly three shooter slots, the standard city seed assigned tokens to every living ranged flanker on every planning turn in the first five waves. A second trace counted zero times when a ranged flanker planned without a token in either the live or planted run. That seed still produced two shooters firing from a flank. The mixed scenario now clears and replays five waves on each of the five published probe seeds, and requires positive FLANK occupancy across them. It retains the original cover, flanking-fire and separation checks on the standard seed.

The five FLANK counts were 0, 0, 0, 24 and 0. Standard-seed cover was 49.9%. Crowded hostile-ticks rose from 0.0% to 8.4% when separation was disabled.

## Default rollout

The no-flag sweep matched all 15 explicit squad digests. Its five Quest 1 digests matched A1. The pit scenario now requires both scripted waves before its 60-second limit. All six previously failing station scenarios passed in the full suite. Tonnage landed two slams, the chainsaw killed three cops, the claw landed ten hits, the katana killed four cops, and the showcase electro-chain killed all four victims. The city fight reached wave four with its working bot, while the planted bot stayed below wave three in the fixed-defender control.

~~~text
run_scenarios: 56 ran, 0 failed
unit-tests: 2985 passed, 0 failed, 2 skipped (GUT, headless)
parity: native == GDScript reference bit for bit over 1200 steps (40 snapshot checks, 3502 floats); planted mutation caught at step 629
~~~

The same six scenarios also passed under explicit guard and mixed flags. A temporary copy of the scenario runner accepted the extra game flag and ran the unchanged scenario scripts. Across guard, squad and mixed, the complete ghost, chainsaw, claw, katana and showcase telemetry files matched. The city fight exercises real waves and its live results vary by roster.

## Mutation and final unit results

Both mutation runs used the checked-in tests and the deterministic 20-mutant sample. The SquadMind sample contained the same 20 operations as A7.

| Source | Killed / (killed + survived) | Survived | Invalid | Timed out |
|---|---:|---:|---:|---:|
| arena_squad.gd | 10/20 | 10 | 0 | 0 |
| squad_mind.gd | 17/20 | 3 | 0 | 0 |

A7 killed 11/20 SquadMind mutants. The current tests also kill 6 of the nine original survivors. Their A7 source lines and mutations are 88 (<= to <), 90 (+ to -), 97 (/ to *), 174 (0 to 1), 189 (<= to <), 189 (>= to >). The ownership and peek tests cover the token retreat, and the added tests cover stable cover draws plus melee cooldown, reach and facing at the exact attack boundary.

~~~text
unit-tests: 2987 passed, 0 failed, 2 skipped (GUT, headless)
~~~

The two skips are the missing Tonnage and Ohm tilt-art card strips.

Godot exited with status 0 after the full scenario run. At shutdown it logged ObjectDB and resource-leak diagnostics. The A7 engine log and the explicit guard control also contain these shutdown diagnostics.
