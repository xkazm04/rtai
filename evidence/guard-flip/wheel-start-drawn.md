# Wheel start comparison

Measured at `e58e503bff339c7232be8302cee2d266b9049a27` on 2026-11-21. Each column covers the same 65 headless scenarios. Legacy used the stock runner with default launch arguments. The two wheel runs used the a6 scratch runner with `--wheel-start` added to its accepted arguments. Both used `--controls=wheel`, with the start value shown below.

| Controls | Passed | Failed | 60 s replay | Quest 1 input replay (first 16 hex digits) |
|---|---:|---:|---|---|
| Legacy (default flags) | 65 | 0 | `cbeb734ff9b97c41` | `37bf8deacaad2f48` |
| Wheel + hands | 49 | 16 | `cbeb734ff9b97c41` | `37bf8deacaad2f48` |
| Wheel + drawn | 60 | 5 | `cbeb734ff9b97c41` | `37bf8deacaad2f48` |

## Scenario differences

Pass with drawn after failing with hands

`arena_city`, `arena_pit`, `arena_range`, `arena_squad`, `brutality_kills`, `city_scare`, `moves_replay`, `react_line`, `rivet_cover`, `showcase_director`, `showcase_reel`.

Fail with drawn

`rifle_rack`, `rivet_chainsaw`, `rivet_katana`, `rivet_pickup`, `rivet_switch`.

New failures compared with hands

None.

## Per-scenario results

| Scenario | Legacy | Wheel + hands | Wheel + drawn |
|---|---|---|---|
| `arena_city` | ok | FAIL | ok |
| `arena_course` | ok | ok | ok |
| `arena_pit` | ok | FAIL | ok |
| `arena_range` | ok | FAIL | ok |
| `arena_squad` | ok | FAIL | ok |
| `arena_stations` | ok | ok | ok |
| `arena_zebra` | ok | ok | ok |
| `autosave_input` | ok | ok | ok |
| `autosave_resume` | ok | ok | ok |
| `bodies_cop` | ok | ok | ok |
| `bodies_crowd` | ok | ok | ok |
| `bodies_runin` | ok | ok | ok |
| `bodies_tackle` | ok | ok | ok |
| `brutality_kills` | ok | FAIL | ok |
| `car_knocks_rivet` | ok | ok | ok |
| `city_bake` | ok | ok | ok |
| `city_chase` | ok | ok | ok |
| `city_parity_ref` | ok | ok | ok |
| `city_replay` | ok | ok | ok |
| `city_scare` | ok | FAIL | ok |
| `corpse_horde` | ok | ok | ok |
| `crowd_react` | ok | ok | ok |
| `enemy_pit` | ok | ok | ok |
| `enemy_waves` | ok | ok | ok |
| `ghost_attacks` | ok | ok | ok |
| `gunplay_fight` | ok | ok | ok |
| `gunplay_fire` | ok | ok | ok |
| `handheld_focus_pause` | ok | ok | ok |
| `human_react` | ok | ok | ok |
| `moves_fuzz` | ok | ok | ok |
| `moves_replay` | ok | FAIL | ok |
| `moves_street` | ok | ok | ok |
| `ohm_bolt_delay` | ok | ok | ok |
| `quest1_dent` | ok | ok | ok |
| `quest1_dent_lock` | ok | ok | ok |
| `quest1_input` | ok | ok | ok |
| `quest1_kerf` | ok | ok | ok |
| `quest1_keys` | ok | ok | ok |
| `quest1_ohm` | ok | ok | ok |
| `quest1_tonnage` | ok | ok | ok |
| `quest_collect_call` | ok | ok | ok |
| `quest_selftest` | ok | ok | ok |
| `react_line` | ok | FAIL | ok |
| `replay_60s` | ok | ok | ok |
| `rifle_rack` | ok | FAIL | FAIL |
| `rig_stress` | ok | ok | ok |
| `rivet_chainsaw` | ok | FAIL | FAIL |
| `rivet_city_fight` | ok | ok | ok |
| `rivet_city_melee` | ok | ok | ok |
| `rivet_claw` | ok | ok | ok |
| `rivet_cover` | ok | FAIL | ok |
| `rivet_deflect` | ok | ok | ok |
| `rivet_katana` | ok | FAIL | FAIL |
| `rivet_pickup` | ok | FAIL | FAIL |
| `rivet_switch` | ok | FAIL | FAIL |
| `rivet_throw` | ok | ok | ok |
| `rivet_vault` | ok | ok | ok |
| `showcase_director` | ok | FAIL | ok |
| `showcase_reel` | ok | FAIL | ok |
| `souls_powers` | ok | ok | ok |
| `traffic_yields_rivet` | ok | ok | ok |
| `vehicle_carnage` | ok | ok | ok |
| `vehicle_doors` | ok | ok | ok |
| `vehicle_drive` | ok | ok | ok |
| `vehicle_yield` | ok | ok | ok |
