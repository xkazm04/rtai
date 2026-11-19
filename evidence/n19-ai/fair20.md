# Street-fight squad balance

The best of six 20-seed city-only layouts dealt **2.19 HP** in **21.91 s**, with **zero deaths**. It missed the 2.37 HP floor by 0.18 HP. All six cleared within the 22.10 s ceiling. I restored the original data.

## Before and retained results

The director's four headless `fight_probe` runs at `0925e0399` used the pit bot and seeds 20261103–20261122. Each seed cleared three waves. Clear time covers those waves including gaps. HP lost and deaths cover all 2,400 ticks. Parentheses give sample standard deviations. The retained figures carry forward the baseline measurements because a full `git diff 0925e0399 -- project` was empty after restoring the table.

| Encounter | Brain | Before clear, s (SD) | Retained clear, s (SD) | Before HP lost (SD) | Retained HP lost (SD) | Deaths before → retained |
|---|---|---:|---:|---:|---:|---:|
| City | Guard | 17.68 (0.75) | 17.68 (0.75) | 3.15 (1.77) | 3.15 (1.77) | 0 → 0 |
| City | Squad | 21.14 (1.88) | 21.14 (1.88) | 2.13 (1.07) | 2.13 (1.07) | 0 → 0 |
| Pit | Guard | 14.72 (0.64) | 14.72 (0.64) | 8.13 (2.97) | 8.13 (2.97) | 0 → 0 |
| Pit | Squad | 17.68 (1.47) | 17.68 (1.47) | 7.44 (2.00) | 7.44 (2.00) | 0 → 0 |

I reproduced the summary with `python ../../evidence/briefs/fair20-sum.py` from `build/fair20`. The individual seed digests in those four JSONs are the comparison point for the tuning trials.

## What the city waves read

`ArenaStage.setup` in `project/features/arena/arena_stage.gd` reads `pit.squad_mix` and `pit.max_shooters` for both encounters. The squad uses the contractor row and three shooter slots in both. The mixed brain uses `pit.squad_mix_full`. `ArenaPlan.shipped` reads the same pit dictionary at either arena origin.

`ArenaSession.open_with_args` applies `city.shift_props` only on the city block, before building collision and the guard route map. That map also supplies nearby cover to the squad. I moved individual cover props to test whether contractors could get a shot sooner while protecting the two guard baselines. The north wall and its zebra-crossing clearances stayed in place for every trial.

## City-only cover trials

I screened 29 layouts against the city guard digest for seed 20261103. Eleven matched. I ran six of those layouts on all 20 squad seeds. Each row moves the same low crate, `pit/10`, from (17, 27) to the listed position in metres relative to the hub. The last column counts identical **city squad** fight digests out of 20. All 120 runs reached the objective.

| Crate position (x, y) | Mean clear, s | Mean HP lost | Deaths | Matched squad digests |
|---|---:|---:|---:|---:|
| (5, 34) | 21.91 | 2.19 | 0 | 5 |
| (29, 7) | 21.23 | 2.16 | 0 | 1 |
| (−2, 28) | 21.49 | 2.01 | 0 | 3 |
| (34, 8) | 21.11 | 2.13 | 0 | 2 |
| (−1, 21) | 21.14 | 2.13 | 0 | 18 |
| (6, 33) | 21.39 | 1.47 | 0 | 3 |

Small moves near the guard's approach failed the digest screen immediately. On seed 20261103 the baseline guard took 16.82 s and dealt 1.80 HP. Moving `pit/7` one metre east and one north produced 15.77 s and 4.80 HP. Moving `pit/10` to (1, 27) reproduced the baseline time and HP on that seed, but changed the digest of the per-tick hostile positions and health. I rejected both.

To reproduce a trial, set the `pit/10` entry in `city.shift_props` to the listed position minus (17, 27), then run the probe from the repository root. The pit bot is the default.

```text
node tools/dev/run.mjs fight_probe --encounter=city --seeds=20 --enemy-brain=squad --out=<absolute-json-path>
```

## Verification on the retained build

- A fresh five-seed guard probe for each encounter matched the director's original seed, digest and every fight field in all 10 runs.
- `node tools/tests/run_scenarios.mjs --only=arena_city,arena_pit,arena_squad,arena_zebra,enemy_pit` passed 5/5. SHA-256 matched the pre-trial files for the city and pit telemetry, arena squad and enemy pit. No scenario expected file needed re-blessing.
- `node tools/tests/run_unit.mjs --changed` ran the full mapped suite on this branch. GUT reported 2,976 passed, zero failed and two skipped.
- `node tools/gate/quick.mjs --no-clash` exited zero and reported zero changed GDScript files.
