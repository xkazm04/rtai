# Street-fight squad balance

The city squad dealt **2.91 HP** and cleared three waves in **18.13 s**, with **zero deaths** over 20 seeds. Compared with the city guard, damage was 7.6% lower and clear time was 2.5% longer. Both are within the 25% target.

## A9b before and after

The headless fight probe used the pit bot and seeds 20261103–20261122 in each arm. Clear time includes gaps between the first three waves. HP lost and deaths cover all 2,400 ticks. Parentheses give sample standard deviations. All 80 final fights reached the objective.

| Encounter | Brain | Before clear, s (SD) | After clear, s (SD) | Before HP lost (SD) | After HP lost (SD) | Deaths before → after | Matched seed digests |
|---|---|---:|---:|---:|---:|---:|---:|
| City | Guard | 17.68 (0.75) | 17.68 (0.75) | 3.15 (1.77) | 3.15 (1.77) | 0 → 0 | 20/20 |
| City | Squad | 21.14 (1.88) | 18.13 (1.31) | 2.13 (1.07) | 2.91 (2.07) | 0 → 0 | 0/20 |
| Pit | Guard | 14.72 (0.64) | 14.72 (0.64) | 8.13 (2.97) | 8.13 (2.97) | 0 → 0 | 20/20 |
| Pit | Squad | 17.68 (1.47) | 17.68 (1.47) | 7.44 (2.00) | 7.44 (2.00) | 0 → 0 | 20/20 |

## Selected setting

`project/data/tables/arena.json` sets `city.squad.contractor_speed_mps` to 4.2. The shared contractor moves at 3.0 m/s. Both squads still field contractors with three shooter slots. On the city block the squad can also override the mix or slot count independently. Omitted settings inherit their existing values. Guard and mixed use their existing setup.

The speed change gave the contractors more firing opportunities over the 20 fights. They fired 258 rounds and landed 97 hits, up from 209 rounds and 71 hits. Damage per hit stayed at 0.6 HP. The selected speed first ran on a city-only copy of the contractor row. Applying the same speed directly to the session's contractor reproduced every candidate digest and fight record and kept the original contractor ID.

## City squad tuning runs

Each row uses all 20 seeds. The mean clear time uses only seeds that cleared three waves. A candidate needed 20 clears, zero deaths, at least 2.37 HP lost and a mean clear of at most 22.10 s. The 18 m attack range exceeded the rifle's 16 m range.

| Change from baseline | Cleared | Mean clear, s | Mean HP lost | Deaths |
|---|---:|---:|---:|---:|
| Baseline, 3 slots | 20/20 | 21.14 | 2.13 | 0 |
| 4 shooter slots | 20/20 | 19.00 | 1.65 | 0 |
| 5 shooter slots | 20/20 | 19.00 | 2.13 | 0 |
| 2 shooter slots | 20/20 | 25.18 | 1.92 | 0 |
| Aggression 0.7 → 1.0 | 20/20 | 20.09 | 1.65 | 0 |
| Aggression 0.7 → 0.45 | 20/20 | 21.27 | 1.74 | 0 |
| Attack range 15 → 14 m | 20/20 | 20.64 | 2.04 | 0 |
| Attack range 15 → 16 m | 19/20 | 21.50 | 1.95 | 0 |
| Attack range 15 → 18 m | 15/20 | 21.30 | 2.22 | 0 |
| Cover bias 1.0 → 0.65 | 20/20 | 20.10 | 1.92 | 0 |
| Peek 1.25 → 2.0 s | 20/20 | 20.59 | 2.10 | 0 |
| Peek 1.25 → 0.6 s | 15/20 | 21.65 | 1.80 | 0 |
| **Speed 3.0 → 4.2 m/s** | 20/20 | 18.13 | 2.91 | 0 |

A five-seed screen also tested movement speed, strafing, preferred distance, morale and combinations of shooter slots with range or cover. At 3.6 and 4.2 m/s the squad dealt 2.76 and 2.88 HP respectively. The 4.2 m/s result above comes from the full 20-seed run.

## Verification

- With the optional key absent on the final code, all 20 city squad digests and fight records matched `0925e0399`. With the key present, all 60 control digests and fight records matched across city guard, pit guard and pit squad.
- All five requested headless scenarios passed (`arena_city`, `arena_pit`, `arena_squad`, `arena_zebra`, `enemy_pit`). City and pit telemetry, the mixed squad report and the enemy pit report each matched its pre-tune SHA-256. The zebra judge found zero overlaps. No expected file required re-blessing.
- Thirteen schema cases covered missing, partial and combined overrides, rejected unknown fields and archetypes, and checked numeric bounds and types. The focused GUT tests exercise loading a table that omits the key, inheriting each setting independently and applying the speed only to city squad contractors.
- `node tools/tests/run_unit.mjs --changed` ran the full suite with 2,980 passed, 0 failed and 2 skipped. The quick gate passed on both production scripts and the new unit test.
- Mutation testing used the repository's operators and GUT oracle on an isolated export of commit `56b619faa` under this worktree's `build/a9b`. For `arena_stage.gd` lines 66–75, the tests killed five generated faults and a hand-planted omission of the speed assignment. Deleting the mix assignment failed to parse. For `arena_plan.gd`, the tests caught a skipped optional row and a read that wrongly required it on a legacy table. The combined score was **8/(8+0)**, with one invalid mutant and zero timeouts. The focused suite passed again after the original bytes were restored.

To repeat a sweep, run the command below from the repository root for each encounter and brain, directing the output to four distinct files named `city-guard.json`, `city-squad.json`, `pit-guard.json` and `pit-squad.json`. Run `evidence/briefs/fair20-sum.py` from their directory.

```text
node tools/dev/run.mjs fight_probe --encounter=<city|pit> --enemy-brain=<guard|squad> --seeds=20 --out=<absolute-json-path>
```

## A9 layout-only trials (historical)

The best of six 20-seed city-only layouts dealt **2.19 HP** in **21.91 s**, with **zero deaths**. It missed the 2.37 HP floor by 0.18 HP. All six cleared within the 22.10 s ceiling. I restored the original data.

### A9 layout-only baseline and retained results

The director's four headless `fight_probe` runs at `0925e0399` used the pit bot and seeds 20261103–20261122. Each seed cleared three waves. Clear time covers those waves including gaps. HP lost and deaths cover all 2,400 ticks. Parentheses give sample standard deviations. The retained figures carry forward the baseline measurements because a full `git diff 0925e0399 -- project` was empty after restoring the table.

| Encounter | Brain | Before clear, s (SD) | Retained clear, s (SD) | Before HP lost (SD) | Retained HP lost (SD) | Deaths before → retained |
|---|---|---:|---:|---:|---:|---:|
| City | Guard | 17.68 (0.75) | 17.68 (0.75) | 3.15 (1.77) | 3.15 (1.77) | 0 → 0 |
| City | Squad | 21.14 (1.88) | 21.14 (1.88) | 2.13 (1.07) | 2.13 (1.07) | 0 → 0 |
| Pit | Guard | 14.72 (0.64) | 14.72 (0.64) | 8.13 (2.97) | 8.13 (2.97) | 0 → 0 |
| Pit | Squad | 17.68 (1.47) | 17.68 (1.47) | 7.44 (2.00) | 7.44 (2.00) | 0 → 0 |

I reproduced the summary with `python ../../evidence/briefs/fair20-sum.py` from `build/fair20`. The individual seed digests in those four JSONs are the comparison point for the tuning trials.

### What the city waves read at the A9 baseline

`ArenaStage.setup` in `project/features/arena/arena_stage.gd` reads `pit.squad_mix` and `pit.max_shooters` for both encounters. The squad uses the contractor row and three shooter slots in both. The mixed brain uses `pit.squad_mix_full`. `ArenaPlan.shipped` reads the same pit dictionary at either arena origin.

`ArenaSession.open_with_args` applies `city.shift_props` only on the city block, before building collision and the guard route map. That map also supplies nearby cover to the squad. I moved individual cover props to test whether contractors could get a shot sooner while protecting the two guard baselines. The north wall and its zebra-crossing clearances stayed in place for every trial.

### City-only cover trials

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

### Verification on the A9 baseline

- A fresh five-seed guard probe for each encounter matched the director's original seed, digest and every fight field in all 10 runs.
- `node tools/tests/run_scenarios.mjs --only=arena_city,arena_pit,arena_squad,arena_zebra,enemy_pit` passed 5/5. SHA-256 matched the pre-trial files for the city and pit telemetry, arena squad and enemy pit. No scenario expected file needed re-blessing.
- `node tools/tests/run_unit.mjs --changed` ran the full mapped suite on this branch. GUT reported 2,976 passed, zero failed and two skipped.
- `node tools/gate/quick.mjs --no-clash` exited zero and reported zero changed GDScript files.
