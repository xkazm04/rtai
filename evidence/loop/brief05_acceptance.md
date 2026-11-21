# Brief 05 acceptance

## Tests and lint

```text
node --test "tools/gauntlet/*.test.mjs"
ℹ tests 39
ℹ pass 39
ℹ fail 0
ℹ skipped 0

node tools/lint/lint.mjs
lint: all 19 checks pass over 1901 GDScript files
```

The night integration test supplied synthetic before and after batches. The real report and tuner CLIs produced both reports, kept one change and reverted two in a temporary Git repository.

## First-cycle coverage

Reading the original batches accepts all ten average runs on each side. Seed 10 reached the cap alive before. Seeds 6 and 10 reached it alive after. The original ledger records five reverts. Applying the new confirmation rule to those planned changes gives the following counts. [Before batch](tune1-before/batch.json) · [After batch](tune1-after/batch.json) · [Original plan](tune1-before/plan.json) · [Original ledger](tune1-after/tune-ledger.md) · [Refreshed telemetry report](tune1-before/report.md)

| Knob | Matched wave timings | Before A/A pairs | Verdict |
|---|---:|---:|---|
| robot_gunner.hp | 3 | 2 | too few pairs |
| shield_robot.hp | 5 | 3 | too few pairs |
| war_machine.hp | 9 | 4 | too few pairs |
| robot_thug.hp | 8 | 4 | too few pairs |
| sentry_turret.hp | 6 | 4 | too few pairs |

## Street proposal

```text
node tools/gauntlet/tune.mjs propose --batch=evidence/loop/batch-street-1/batch.json --out=build/gauntlet/plan-street-1b.json
average wave 10 median 47.72 s over 1 timed runs against 15 s, robot_thug present in 1/1 timed rosters: too few runs (need 3 timed runs)
average wave 5 median 36.26 s over 4 timed runs against 15 s, war_machine present in 4/4 timed rosters: war_machine.hp 60 -> 48
novice median wave 5, expert 5 against a gap of at least 1 wave, 4/10 runs ended in death, war_machine in 3/6 timed final rosters: knob or offer already selected this night
average wave 3 median 6.92 s over 5 timed runs against 15 s, below the 12 s lower bound, raise budget.base to add enemies: budget.base at 2 has no legal upward step within bounds
average wave 2 median 8.35 s over 5 timed runs against 15 s, below the 12 s lower bound, raise budget.base to add enemies: budget.base at 2 has no legal upward step within bounds
average wave 1 median 8.68 s over 5 timed runs against 15 s, below the 12 s lower bound, raise budget.base to add enemies: budget.base at 2 has no legal upward step within bounds
average wave 4 median 8.93 s over 5 timed runs against 15 s, below the 12 s lower bound, raise budget.base to add enemies: budget.base at 2 has no legal upward step within bounds
average wave 9 median 20.43 s over 1 timed runs against 15 s, robot_gunner present in 1/1 timed rosters: too few runs (need 3 timed runs)
average wave 6 median 10.19 s over 2 timed runs against 15 s, below the 12 s lower bound: too few runs (need 3 timed runs)
turret_gun recorded as killer in 5/8 deaths (62.5% against 50%): enemy_weapon.turret_gun.damage 4 -> 3.2
average wave 7 median 11.36 s over 2 timed runs against 15 s, below the 12 s lower bound: too few runs (need 3 timed runs)
2 changes from 11 measured misses in build/gauntlet/plan-street-1b.json
```

## Night preview

```text
node tools/gauntlet/night.mjs --seeds=3 --dry-run
node tools/gauntlet/batch.mjs --seeds=3 --profile=average --pick=greedy --controls=wheel --seed0=1 --jobs=1 --out=build/gauntlet/night-2026-11-21/before
node tools/gauntlet/report.mjs --batch=build/gauntlet/night-2026-11-21/before/batch.json
node tools/gauntlet/tune.mjs propose --batch=build/gauntlet/night-2026-11-21/before/batch.json --out=build/gauntlet/night-2026-11-21/plan.json --profile=average
Only n22-tune* branches continue after propose.
node tools/gauntlet/tune.mjs apply --plan=build/gauntlet/night-2026-11-21/plan.json
node tools/gauntlet/batch.mjs --seeds=3 --profile=average --pick=greedy --controls=wheel --seed0=1 --jobs=1 --out=build/gauntlet/night-2026-11-21/after
node tools/gauntlet/tune.mjs confirm --before=build/gauntlet/night-2026-11-21/before/batch.json --after=build/gauntlet/night-2026-11-21/after/batch.json --plan=build/gauntlet/night-2026-11-21/plan.json --revert
node tools/gauntlet/report.mjs --batch=build/gauntlet/night-2026-11-21/after/batch.json --baseline=build/gauntlet/night-2026-11-21/before/batch.json
Writes build/gauntlet/night-2026-11-21/night.md on completion.
```
