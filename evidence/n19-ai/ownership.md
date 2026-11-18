# Squad ownership in the arena

The pit registers its own fighters at spawn and clears membership on replacement or reset. The same spawner supplies the street fight and horde. Only members enter squad planning, token allocation, separation and morale. Regular guards retain the arena's guard tell or GuardBrain, and station dummies retain their station motion.

## Cause of the six A7 failures

Temporary instrumentation on A7 logged each fighter when it first entered ArenaSquad.assign and when it first acquired a token. IDs below are observations from those runs. Registration uses the Fighter instance, so neither numeric ranges nor archetype names decide ownership.

| Scenario | Non-wave fighters assigned on A7 | Consequence |
|---|---|---|
| ghost_attacks | Ghost-reel victims 1?6 and claw cops 3000?3004 | All six victims received a token. Tonnage landed one of two required slams. |
| rivet_chainsaw | Claw cops 3000?3004 | Their pinned triggers prevented tokens, but squad steering moved them out of reach. Zero kills. |
| rivet_claw | Claw cops 3000?3004 | Zero hits on ten attempts. |
| rivet_katana | Claw cops 3000?3004 | Zero kills. |
| showcase_director | Reel victims 1?30 and claw cops 3000?3004 | Victim 15 received a token. The electro-chain chapter killed three of four. |
| rivet_city_fight | Claw cops 3000?3004 plus genuine wave members 1?14 across this scenario's runs | Its stationary-defender control removed guard pursuit while wave members still used the squad?s route map. The planted bot reached wave four. Both sides of that control now disable both navigation controllers. Its live fight and replay still run the default. |

In the city and pit probes on seed 20261103, the five claw cops had squad minds and zero shooting tokens. They consumed planning work and participated in steering. The inspected A7 probe reproduced the saved A7 digest in both encounters.

## Five-seed balance

Times cover the first three waves. Damage and deaths cover all 2,400 arena ticks. Percentage changes use unrounded means against A1. Each completed sweep used seeds 20261103 through 20261107 and the production fight probe.

| Run | City clear s | City HP lost | Pit clear s | Pit HP lost | Deaths |
|---|---:|---:|---:|---:|---:|
| A1 guard | 17.58 | 3.60 | 14.53 | 7.32 | 0 |
| A7 tuned squad | 20.62 (+17.3%) | 3.12 (-13.3%) | 17.42 (+19.8%) | 7.44 (+1.6%) | 0 |
| A7b scoped squad | 20.03 (+13.9%) | 3.12 (-13.3%) | 17.10 (+17.7%) | 7.08 (-3.3%) | 0 |
| A7b mixed | 23.83 (+35.6%) | 3.24 (-10.0%) | 20.63 (+41.9%) | 8.16 (+11.5%) | 0 |

Compared with A7, the scoped squad changed city clear by -0.59 s and damage by +0.00 HP. Pit changed by -0.31 s and -0.36 HP. The mixed roster remains an owner?s Call on clear time. No row or weapon changed.

With ownership alone, city seed 20261104 cleared only two waves within the 40-second probe. The remaining contractor repeatedly walked out of cover, spent its peek on distant sight and retreated before sustaining an engagement. Counting row-defined peek time when the enemy can see a target within attack range let all five seeds finish. The raw ownership-only results, including the incomplete seed, are in ownership.json.

All 15 explicit guard SHA-256 digests matched A1. Quest 1 uses its own stage. The seven recorded replays, 16 look goldens, city bake, city parity and standalone sim hash tests identified in the A7 audit have no dependency on the production arena selector.

## Scenario coverage

With exactly three shooter slots, the standard city seed assigned tokens to every living ranged flanker on every planning turn in the first five waves. A second trace counted zero times when a ranged flanker planned without a token in either the live or planted run. That seed still produced two shooters firing from a flank. The mixed scenario now clears and replays five waves on each of the five published probe seeds, and requires positive FLANK occupancy across them. It retains the original cover, flanking-fire and separation checks on the standard seed.

The five FLANK counts were 0, 0, 0, 24 and 0. Standard-seed cover was 49.9%. Crowded hostile-ticks rose from 0.0% to 8.4% when separation was disabled.
