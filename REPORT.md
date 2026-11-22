# REPORT - lane loop (n23, 2026-11-22)

DRAFT (session 3, 03:45). Sections fill in as items land; the final version is written at 09:40.

Branch `n23-loop`, cut from `main` `76111adec`. Evidence under `evidence/n23-loop/`.

## The before page (main `76111adec`, combined game, wheel controls)

Batches: `evidence/n23-loop/base-greedy/` (20 seeds x 3 profiles, greedy picks, 60/60 ok, `report.md`),
`evidence/n23-loop/base-random/` (average, random picks, 20 seeds, `report.md`),
`evidence/n23-loop/base-null-salt1/` (average greedy, bot salt 1, the neutral rerun). Tick cap 72000 (20 sim minutes).

| Profile / pick | Median wave reached | P25..P75 | Lethal deaths | 90 s timeouts | Alive at the cap |
|---|---:|---|---:|---:|---:|
| novice / greedy | 13.5 | 10..20 | 19 | 1 | 0 |
| average / greedy | 36 | 34..37 | 1 | 2 | 17 |
| expert / greedy | 36 | 34..38 | 0 | 3 | 17 |
| average / random | 35 | 35..36 | 0 | 2 | 18 |

- **Separation:** novice is separated from the others (13.5 vs 36); average and expert are NOT: both reach the
  tick cap at about wave 36, so their "wave reached" measures kill speed in 20 sim minutes, not survival.
  Random picks are not harder than greedy (35 vs 36).
- **Wave time** (average, median s; target 15): waves 1-4 5.6-8.5, wave 5 (first boss) 19.1, 7-8 13, 11-20 21-34,
  21-30 33-53, 31+ 46-52. Early waves are too short, every wave after 9 is too long.
- **Who kills** (novice, 19 lethal deaths): war machine stomp 7, shield robot 6, rocket trooper 5, sentry 1;
  8 of 19 on boss waves 5/10/15/20.
- **Damage against repair** (median per wave): average 0.12 / 0.71 / 0.94 / 0.99 HP/s in wave bands
  1-10 / 11-20 / 21-30 / 31+, expert 0.09 / 0.56 / 0.59 / 0.56, against an in-wave repair of 10 HP/s after 3 s
  without damage (`combat.json` rivet), 13.75 HP/s with greedy regen picks by wave 21. Expert minimum HP per wave
  86-99 % of max; repair undid 100 % of each wave's damage (median).
- **Guard / roll / cover** (average, per wave median): deflects 4 / 8 / 12.5 / 17, rolls 1 / 7 / 11 / 15,
  cover ticks 0 / 18 / 33 / 28 (bands as above).

### Why nobody dies (ablations, `evidence/n23-loop/ablate/summary.md`)

Average greedy, seeds 1-2 only (the deadline cut it from 10), control = archived seeds 1-2 (waves 37, 35, alive).

| Arm | Deaths / seeds | Median wave reached |
|---|---:|---:|
| control | 0 / 2 | 36 |
| repair 3 HP/s after 6 s | 2 / 2 | 20 |
| repair off | 1 / 2 | 6.5 (seed 1 stalls: the bot waits to rest, a bot artifact) |
| no stat picks | 1 / 2 | 21 |
| enemy weapon damage x2 | 1 / 2 | 28.5 |
| guard off | 0 / 2 | 32 |

The causes, largest first: (1) **in-wave repair** (10 HP/s, ten times the damage taken per second), (2) **stat picks
stacking hp and regen** to x1.375, (3) **low enemy damage**. The guard is minor. Repair is a `combat.json` number
shared with quest 1: the tuner reaches it only through street's gauntlet override (`NEED street` 01:06).

## The noise floor by a neutral change

DECISION: the neutral change is a **bot salt** (`--bot-salt=<n>`) on the test player's private streams (aim, defence,
forms, pick); the world RNG and every balance number are untouched, so the game's difficulty is the same and only the
player's luck is resampled. Proof it differs: salt 1 changes 20 of 20 result files; `--bot-salt=0` is byte-identical
to no flag. Same batch (average greedy, seeds 1-20), null-salt vs the old cross-seed floor (`base-null-salt1/floors.md`):

| Metric | Null-salt floor (pairs) | Cross-seed floor (pairs) |
|---|---:|---:|
| wave 5 s | 3.38 (20) | 24.35 (10) |
| wave 10 s | 7.77 (20) | 16.17 (10) |
| wave 15 s | 10.07 (20) | 22.45 (10) |
| wave 20 s | 11.48 (19) | 22.47 (10) |
| wave 25 s | 10.17 | 27.42 |
| wave 30 s | 6.28 (17) | 22.03 |
| wave reached | 1 (20) | 4 (10) |

Re-judged n22's reverted cuts: `war_machine.hp` 60 -> 48 (gain 13.67 s, CI95 4.75..19.08 at wave 20) clears the
null floor of 11.48 s with its mean, not with its CI low; `shield_robot.hp` 10 -> 8 (3.67 s, CI95 1.72..6.6 at wave 13)
stays under the 6.73 s floor: noise either way.

## What works

## What does not

## What blocked or slowed you

## Calls for the owner

## Merge notes

## Next steps

## Astra ledger
