# REPORT n24 lane `pressure` (DRAFT, filled at 01:40)

Branch `n24-pressure` in `C:\Users\kazda\kiro\gtai-wt\n23-loop`. Merged: `n24-motion` at `b0a9c4c09` (dash).
Gate: TODO (`node tools/gate/run.mjs --rev=HEAD` line + `gate.json` path).

## What works

### Before / after table (3 skill levels x 5 seeds, 40 waves, greedy picks, wheel controls)

| batch | rev | novice (6) | average (12) | expert (20) | censored |
|---|---|---|---|---|---|
| base-main | `b3f4727c0` | 13 (11-20) | 40 (40-40) | 40 (40-40) | 9 / 15 |
| after-gaps (x2 damage, no in-wave repair, 45 s timer, gaps, rocket) | `032f6de91` | 5 | 10 (5-15) | 12 (3-32) | 0 / 15 |
| after-deflect (+ 50 % pass, 12 deg) | `a9e8adc78` | 5 (5-5) | 5 (3-5) | 7 (5-9) | 0 / 15 |
| arm-rocket14 (+ rocket cooldown 1.4, 13 m/s) | `a9e8adc78` + 2 sets | 5 (5-5) | 6 (5-11) | 5 (5-10) | 0 / 15 |
| final | TODO | | | | |

Median death wave (P25-P75); targets in brackets. Reports: `evidence/n24-pressure/base-main/report.md`,
`evidence/n24-pressure/after-gaps/report.md`, `evidence/n24-pressure/after-deflect/report.md`,
`evidence/n24-pressure/arm-rocket14/report.md`.

### Enemy fire: rounds per second and hits on a moving Rivet (30 s, 10 m, seed 1)

| enemy | RPS before | RPS after | hits standing before -> after | hits circling before -> after |
|---|---:|---:|---:|---:|
| patrol_cop (rifle) | 2.133 | 4.033 | 36 -> 60 | 0 -> 27 |
| swat | 2.133 | 4.033 | 27 -> 51 | 0 -> 38 |
| robot_gunner | 2.133 | 4.033 | 29 -> 56 | 0 -> 30 |
| contractor | 2.133 | 4.033 | 35 -> 59 | 0 -> 25 |
| rocket_trooper | 0.333 | 0.600 (cooldown 0.55; final 1.4: TODO) | 10 -> 18 | 0 -> 9 |
| sentry_turret | 2.100 | 3.900 | 7 -> 18 | 0 -> 0 |
| war_machine | 0.400 | 0.400 | 12 -> 12 | 0 -> 0 |

`evidence/n24-pressure/fire-gaps/before.md`, `evidence/n24-pressure/fire-gaps/after.md`. Circling without skill went from
never hit to hit 25-38 times in 30 s by every rifle.

### Deflect: half through, the rest scattered

Share of RETURNED rounds that still hit their shooter, guard / plasma bat (`evidence/n24-pressure/deflect/share.md`):

| distance | 6 deg | 12 deg (shipped) | 20 deg |
|---|---:|---:|---:|
| 6 m | 84 / 96 % | 42 / 52 % | 24 / 31 % |
| 12 m | 41 / 44 % | 19 / 20 % | 10 / 11 % |
| 20 m | 23 / 23 % | 10 / 10 % | 7 / 7 % |

Bonus rows to add later (not added): TODO two or three rows scaling `pass_ratio_k`.

## What does not

TODO

## What blocked or slowed you

- Hook failure on a merge commit (`tools/merge/clash.test.mjs` under the hook's git env): ~15 min.
- First Astra launch through Git Bash `nohup &` hung the tool call: ~6 min.

## Calls for the owner

TODO

## Merge notes

TODO

## Next steps

TODO

## Astra ledger

| call | minutes | verdict |
|---|---:|---|
| numbers-gaps | 64 | accepted |
| gaps | 74 | accepted |
| rocket-gap | 45 | accepted |
| deflect | 59 | accepted |
