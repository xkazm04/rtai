# n31-26: did the honest yard footprints make the prologue harder?

## Step 0: red `test_prologue_dialogue` (gate blocker)

Verdict: **red on HEAD, not a flake, not edited.** `node tools/tests/run_unit.mjs --select=test_prologue_dialogue`
on HEAD `0cb3a29e6`: `1 failing (4 passed, 1 failed)`, `test_prologue_dialogue.gd:113 test_recurring_orders_show_the_owner_row_through_its_reading_time - [0] expected to equal [4]` (and again on the rerun).
- `db132bf0c` (before the yard footprints): `unit-tests: 5 passed, 0 failed`.
- `428511fc3` (the yard footprints): same failure as HEAD. **That commit turns it red.**
- Cause: the test boots seed 7 with the pilot and waits at most 10000 ticks for 4 Mulroney orders (beat two). On `428511fc3` the seed 7 pilot dies three times (hands 4800, 7800; beat two 12600) and replays the checkpoints, so beat two opens at tick 10770 and seen = 0 at the 10000 cap (db132bf0c: beat two at 5220).
- Re-pin attempt (no product change): cap 10000 -> 18000 gives seen = 5 (order list persists, a fifth order fires inside the fourth's reading window). Counting only the first four orders then fails on `hud.words`: at an order's tick the HUD shows `b2_l01_mulroney_line_up` instead of the order line `b2_l05_mulroney_shoot`, i.e. after a beat two checkpoint replay a recurring order and the opening line overlap and the opening line wins the row. That is no longer a tick-limit pin but a possible behaviour question (does an order show Mulroney's row for its reading time after a death replay?), so the test edit was reverted and nothing is committed to `project/`. Owner/test owner decision: either re-pin with a replay-aware test or fix the row priority; with 0 deaths (main, and any seed that does not die) the test passes as is.

## How measured

`project/dev/ground_n31/pilot_stall_probe.tscn --seed=<n> --result=<dir>` through `node tools/dev/run.mjs`, headless, one Godot at a time under the lane lock. Arms: HEAD `0cb3a29e6` (live tree) and main `ba8e470b0` (temp worktree with the probe copied in, removed afterwards). Seeds are the pilot scenario's: 7, 3, 11, 21, 42. Every run: `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh`. Logs: `build/n31/n31-26/<arm>-s<seed>/pilot_ticks.jsonl` (scratch, not committed). The probe logs every 30 ticks, so a death is read from the hp trace (hp 0 sample, or the respawn jump to 100) and min hp is the lowest 30-tick sample (a lower bound on harm: a hit between samples can be missed). All ran to `ended true`. Phases: hands, beat two, street.

## Table (end tick; deaths with tick and phase; min hp per phase; ticks per phase)

| seed | arm | end tick | deaths | min hp hands / beat two / street | ticks hands / beat two / street |
|---|---|---|---|---|---|
| 7 | main | 11700 | 0 | 59.2 / 36.0 / 94.3 | 3000 / 4080 / 2430 |
| 7 | HEAD | 17700 | 3: 4800 hands, 7800 hands, 12600 beat two | 0 / 0 / 91.8 | 8550 / 4620 / 2340 |
| 3 | main | 11940 | 1: 4800 hands | 0 / 22.2 / 89.8 | 4740 / 2610 / 2400 |
| 3 | HEAD | 10740 | 0 | 24.9 / 20.0 / 71.7 | 3000 / 3150 / 2400 |
| 11 | main | 10380 | 0 | 76.0 / 44.0 / 100 | 2550 / 3240 / 2400 |
| 11 | HEAD | 12600 | 1: 3960 hands | 0 / 29.3 / 100 | 5340 / 2670 / 2400 |
| 21 | main | 12150 | 0 | 28.0 / 28.3 / 100 | 2970 / 4590 / 2400 |
| 21 | HEAD | 10170 | 0 | 20.3 / 37.2 / 100 | 2940 / 2670 / 2370 |
| 42 | main | 13260 | 1: 7800 beat two | 14.2 / 0 / 100 | 3000 / 5670 / 2400 |
| 42 | HEAD | 11730 | 0 | 28.0 / 52.0 / 100 | 3240 / 3960 / 2340 |

(Seed 7 numbers equal n31-23's: main 11701 / 0 deaths, HEAD 17712 / 3 deaths; the 30-tick sampling rounds the end tick.)

## Totals over 5 seeds

| | main `ba8e470b0` | HEAD |
|---|---|---|
| deaths | 2 (hands 1, beat two 1) | 4 (hands 3, beat two 1) |
| seeds with a death | 3, 42 | 7, 11 |
| median end tick | 11940 | 11730 |
| sum of end ticks | 59430 | 62940 |
| median min hp, hands fight | 28.0 | 20.3 |
| total ticks in hands | 16260 | 23070 |

## Reading for the owner

1. Over five seeds HEAD dies 4 times against main's 2, but the deaths move between seeds (main: 3, 42; HEAD: 7, 11): the yard changed the cops' routes, not one spot that kills. Median end tick is the same (11730 vs 11940); the totals differ only because seed 7 costs +6000 ticks in replays.
2. The hands fight is where it is harder: 3 of HEAD's 4 deaths, median lowest hp 20 against 28, 42 % more ticks spent there (23070 vs 16260). Beat two and the street are on par (1 death each side in beat two; street min hp 72-100 both).
3. This is five scripted-pilot runs, not players; the spread between seeds (0 to 3 deaths) is larger than the main-vs-HEAD gap. Any seed that dies on HEAD also breaks the unit test above (a pin of seed 7).
