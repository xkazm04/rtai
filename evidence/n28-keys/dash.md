# n28 dash cooldown 40 -> 24: what was and was not measured

Commit `64004a59d` ships `dash.cooldown_ticks` 24 (dash 10 ticks + 24 = 34 ticks press to press, under the 36-tick
shortest gap between two troopers' rockets).

## Measured (done)
`project/tests/unit/test_player_motion_dash.gd::test_shortest_press_to_press_gap_is_burst_plus_cooldown_and_covers_a_rocket_pair`
presses a fresh dash edge every tick for 200 ticks through `PlayerMotion.step` and asserts the shortest gap between two
accepted presses equals `dash.ticks + dash.cooldown_ticks` (read from the table) and is <= 36. Passed
(`node tools/tests/run_unit.mjs --select=test_player_motion_dash`: 8 passed). The cooldown starts at the burst's last tick
(`PlayerMotionDash.finish`), counts down on the ticks after it, and the first press after it is accepted at tick 10 + cooldown:
no off-by-one, no recovery in between, so 24 gives exactly 34.

## Before (n27, cooldown 40; `evidence/n27-pressure/takes/dash_late_trace_all.md`, pair_dash, 1500 ticks)
| seed | HP at 10 s | HP at end | HP lost after 10 s | presses refused (whole take) |
|---:|---:|---:|---:|---:|
| 3 | 97.6 | 49.1 | 48.5 | 11 |
| 5 | 99.9 | 59.4 | 40.5 | 11 |
| 1 | 98.9 | 95.5 | 3.4 | 13 (all "already mid-dash") |

## After: NOT MEASURED
`node tools/dev/run.mjs pressure_dash_trace -- --out=C:/Users/kazda/kiro/gtai-wt/n23-controls/evidence/n28-keys/dash_trace_after.md --seeds=3,5,1`
was started 17:20 and sat in `mem-budget: waiting` (the run's 8 GB cap was 6.4 to 7.7 GB used by other lanes) until it was
stopped by PID at 17:37. No `dash_trace_after.md` exists. Re-run that command to fill the table.

## Not run (same cause: Godot waited for the RAM cap from 16:44)
- the full unit suite (`node tools/tests/run_unit.mjs`) and the scenario suite (`node tools/tests/run_scenarios.mjs`):
  so "no tape re-pinned" in the decision line rests on the dash test file only; `test_pressure_takes`, `test_bot_dash`
  and the scenarios were NOT run against 24. Run them before merging.
- mutate on `player_motion_dash.gd` (`--max=20`): not run.
