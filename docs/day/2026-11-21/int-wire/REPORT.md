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

## Test player

Two runs in the first five-seed batch exposed wheel-specific stalls.

* Novice seed 4 held attack with a loaded hand cannon. From wave 6 ticks 1200 to 5400 its shot counter stayed at 24 and the same patrol cop kept its last hit point. The wheel creates the carry before the first weapon grant. Grants now set the bot's repeat-trigger setting on that carry. The human still needs a new press for each semiautomatic shot.
* Average seed 5 selected a flamethrower retained on the heavy grip. The bot read the Gatling assigned to the shortcut and fired from outside the flamethrower's 7 m range. More than 700 shots after wave 13 tick 2400 scored zero further hits. The bot now reads the selected weapon and cycles through the real wheel positions, including older weapons sharing a grip.

With both fixes, novice seed 4 cleared wave 6 in 16.50 s and reached wave 45. Average seed 5 cleared wave 13 in 21.07 s and reached wave 47. Both were alive at the 72,000-tick cap. The regression tests cover repeat firing under both control modes and selection between a flamethrower and Gatling on the same grip.

Novice seed 2 exposed a navigation stall on wave 29. Rivet spent the last 50 seconds squeezed between the loading-bay wall and a crate, with the last gunner across the crate. When both side steps fail, the bot now walks along the opposing faces to the nearer end. A regression test starts at the observed position, restores a firing line and fails with the previous path code. The seed cleared wave 29 and reached wave 44.
