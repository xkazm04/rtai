# n31 ghost 15: Dent's drop, play measure and width sweep (main | HEAD)

Builder `g15-dent`, 2026-11-26. `node tools/ghost/deploy_measure.mjs --mode=play --form=dent --seeds=10 --waves=3`
on the live tree, the Dent row as committed in `87ac21445` (press_mode drop, charge_s 0.25 = 15 ticks, life_ticks 57)
with only `ram_half_m` changed per run (temp edit, restored: `build/n31/g15/sweep.sh`). The runs at 0.9 / 1.3 / 1.6
ran on the step-1 tree before its commit landed (file rev `8abdee4d9` = HEAD then; the Dent code and row were the
same as `87ac21445`); 1.8 / 2.0 ran at `87ac21445`. Main row: `evidence/n31/ghost/measure-others-main.md` (`ba8e470b0`,
hold mode: hold to aim, an instant release). The bot is the shipped `GhostDeployBot` (Dent fires at 2+ bodies on the lane
by centre distance at the row's ram_half_m). JSON per run: `evidence/n31/ghost/measure-<rev>-play-g15-dent-h<w>.json`.

## Totals (10 seeds x 3 waves)
| variant | ram_half_m | deploys | mean hits | median hits | mean kills | mean near | share hit | zero-hit | key-down->damage ticks (median) |
|---|---|---|---|---|---|---|---|---|---|
| main (hold, instant) | 0.9 | 53 | 1.81 | 2 | 1.81 | 5.13 | 35% | 6 (11 %) | 1 |
| HEAD drop | 0.9 | 52 | 1.79 | 2 | 1.79 | 5.19 | 34% | 6 (12 %) | 15 |
| HEAD drop | 1.3 | 54 | 2.04 | 2 | 2.04 | 4.59 | 44% | 3 (6 %) | 15 |
| HEAD drop | 1.6 | 55 | 2.00 | 2 | 2.00 | 4.47 | 45% | 5 (9 %) | 15 |
| HEAD drop | 1.8 | 55 | 2.07 | 2 | 2.07 | 4.65 | 45% | 4 (7 %) | 15 |
| HEAD drop | 2.0 | 54 | 2.24 | 2 | 2.24 | 4.76 | 47% | 5 (9 %) | 15 |

## Reading
- The drop costs nothing at the shipped width: 0.25 s of wind-up with the lane frozen (foes step out) is paid back by
  counting each body's radius (1.79 vs 1.81 hits, same zero-hit share).
- **No width up to 2.0 m meets the bar (mean >= 2.5 and zero-hit <= 8 %).** 1.3 m is the only one under 8 % zero-hit
  and lifts the mean to 2.04 (share 34 -> 44 %); past it the mean creeps (2.0 -> 2.24 at 2.0 m) and zero-hit does not fall.
  Per the brief the row keeps 0.9 and the width is a call.
- Likely why the mean is stuck near 2: the shipped bot fires Dent as soon as 2 bodies line up (`ghost_deploy_bot_spot.gd`
  `_fits`: `bodies >= 2`), and early gauntlet waves rarely put 3+ foes on one 8 m lane. A wider lane mostly turns the
  same 2-body shots into sure 2-body hits. A 2.5 mean is a fit question (a relaxed or stricter dev fit, as Ohm's
  `--fit=relaxed`) as much as a width question.
