# Gauntlet integration on int-n22

## Street squad comparison

The street keeps its existing squad. After the blast commit `4d5a0c3e7`, I ran average seed 1 with greedy picks and default controls. I repeated it with a plain `ArenaSquad`, `set_route_map(map)` on each streamed window, and the run's damage multiplier applied once to hits on squad members. Both headless runs exited 0 with fresh results and zero script errors.

| Average seed 1 | Existing street | Candidate |
|---|---:|---:|
| Wave 9 clear, seconds | 14.98 | 70.92 |
| Wave 9 damaging contacts | 10 | 59 |
| Wave reached at timeout | 22 | 15 |
| Result SHA-256 prefix | `63037e9ccf61` | `79f780350f62` |

Waves 1–8 matched. Wave 8 awarded the 25% damage card. Wave 9 included a shield robot. Street's adapter multiplies that robot's damage factor at spawn and again on every step. Foes now calculates directional armour at impact. Removing the adapter therefore changes combat as well as routing. The merged test `test_spawned_hostile_takes_scaled_damage_and_armour_still_applies` exposes the mismatch after one step (1.5625 versus the expected 0.25). The candidate was discarded under the seed-preservation condition.
