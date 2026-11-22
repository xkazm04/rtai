# All four moves disabled

The seed-7 average gauntlet bot reached wave 10 in both runs. The raw result JSONs matched byte for byte (7,072 bytes).

| Gauntlet run | SHA-256 of result JSON |
|---|---|
| Same-roster baseline `c7f139b95` | `2d60b987de723daafb7cb3424c334c8a42ae0f4cd776b478aeb14e7ca414555f` |
| Ohm fix `a8a060feb`, all four rows disabled | `2d60b987de723daafb7cb3424c334c8a42ae0f4cd776b478aeb14e7ca414555f` |

The baseline used `build/dev/m1-ohm-prologue-baseline`. The post-fix run used `build/dev/m4-all-off` with the same 12-archetype roster. Its combat table differs from the shipped table in exactly four `enabled` fields, so the squad and bonus draw loaded the same disabled rows. Both commands used `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=10 --result=<absolute.json>`. Both exited 0 with a fresh result and zero script errors. Local results are `build/dev/m4-before.json` and `build/dev/m4b-all-off.json`.

| Scenario at `a8a060feb` | Configuration | Result | Exit |
|---|---|---|---:|
| `replay_60s` | All four on | `3600 ticks, 184 events, 142 input changes, 60 checkpoints, final cbeb734ff9b97c41` | 0 |
| `replay_60s` | All four off | `3600 ticks, 184 events, 142 input changes, 60 checkpoints, final cbeb734ff9b97c41` | 0 |
| `ghost_attacks` | All four on | `run_scenarios: 1 ran, 0 failed` | 0 |
| Full suite | All four on | `run_scenarios: 65 ran, 0 failed` | 0 |

The focused runs used the headless `res://tests/run_scenarios.gd` entry with `--only=replay_60s` or `--only=ghost_attacks`. The full run used the same entry with no filter. Godot logged object and resource cleanup diagnostics at shutdown after both the ghost scenario and full suite had reported success.
