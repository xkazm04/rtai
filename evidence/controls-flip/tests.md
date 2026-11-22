# Control-mode coverage

## Mode contracts

| Fixture | What it checks |
|---|---|
| `scenario_rivet_pickup` | On legacy, walking takes the empty-grip launcher and interact swaps the same-grip pistols and drops the old one. On wheel, both pistols and the launcher remain available, the floor is empty, and the sidearm shortcut draws the new pistol from hands. |
| `scenario_rifle_rack` | Each mode runs the walk-past and take cases. Legacy leaves the carry null on walk-past. Wheel leaves the wheel on hands with Gloria alone. Taking adds the rifle, and the wheel case explicitly draws it. Both cases fire and check the magazine after switching away and back. |
| `test_controls_guard` | Empty launch options and an unknown mode select wheel. The unknown mode logs a warning. Explicit legacy and wheel still exercise their own mouse and trigger bindings. |
| `test_rivet_wheel_start` | No flags start the player on hands in slot zero, with the stage gun in inventory. The existing drawn-start cases verify the stage gun, magazine and switch timing. |
| `test_controls_guard` replay cases | Saved player tapes restore the recorded mode against the opposite launch option. A tape without mode metadata restores legacy. |
| `quest1_input`, `moves_replay`, `replay_60s` | Quest 1 deliberately switches the playback launch mode before loading the tape. Its final state and the 60-second dummy final state are checked against their original full digests. The movement replay also reloads its recorded controls. |
| `moves_fuzz`, `moves_street`, `ohm_bolt_delay`, `vehicle_doors` | Their feature-specific launch overrides preserve the enclosing controls mode. |
| `test_rivet_wheel_start` arena sidearm case | Drawing the arena's built-in Gloria keeps its original held-fire cooldown. |

## Weapon fixtures

| Scenarios or unit tests | Selection and reason |
|---|---|
| `arena_range`, `arena_city`, `city_scare` | ArenaRangeBot draws Gloria before the range volley. The no-trigger and deaf-city controls use the same bot. |
| `arena_pit`, `arena_squad` | ArenaPitBot draws Gloria on entry, including all five squad seeds and the planted positioning fault. |
| `react_line` | ReactLineBot draws the sidearm before shooting each dummy from four sides. |
| `brutality_kills` | Each weapon recording starts with its named gun or blade and its grip shortcut. The charged claw fixture keeps hands. |
| `moves_replay`, `rivet_cover` | The first movement input draws Gloria so the corner-peek sequence includes an actual shot. |
| `rivet_chainsaw`, `rivet_katana` | ArenaRivetBot selects the carried blade and uses primary for its combo and held grind. |
| `rivet_switch` | The wheel starts the timed switch with the pistol drawn and cycles through hands on the way back to the pistol. |
| `showcase_director` | The director presses the chapter weapon's shortcut during its opening look before attacking. |
| `showcase_reel` | The gun beat can draw its only carried sidearm as well as cycle a multi-weapon loadout. |
| `test_live_melee_weapon` | The katana reach and baton stun cases press the blade's shortcut before holding fire. |
| `test_live_chainsaw` | The held grind, bite lock and plasma spin cases draw the blade they exercise. |
| `test_live_deflect` | The plasma-sword deflection, katana control and rear-shot cases draw the named blade before reaching its active frames. |
| `test_flamer_sway` | The two flamer cases and pistol control select their own grip before sampling the fire line. |
| `test_molotov_windup` | The hold, tap, zero-windup, cursor-distance and fixed-range cases draw the bottle before winding up. |
| `test_no_fire_in_roll` | The free, roll and recovery cases draw the pistol before comparing fire permissions. |
| `test_rivet_cover` | The archived pre-cover stage bytes run with their original legacy pilot. The live corner-peek case draws the sidearm before entering cover. |
| `test_rivet_vault` | The low-cover case selects the sidearm on the vault input, so its held shot can fire after landing. |

## File inventory

| Directory | Changed files |
|---|---|
| `tools/tests/` | `run_unit.mjs`, `run_unit_controls.test.mjs` |
| `project/tests/` | `run_scenarios.gd` |
| `project/addons/gut/cli/` | `gut_cli.gd` registers the forwarded option in GUT's own parser. |
| `project/features/player/` | `controls_mode.gd`, `controls_replay.gd` and its UID, `player_actions.gd`, `rivet_carry.gd`, `rivet_wheel.gd`, `arena_rivet_bot.gd` |
| `project/features/arena/` | `arena_pit_bot.gd` and `arena_range_bot.gd` call the opening sidearm selection. `arena_session.gd` binds the recorder to the session's controls. |
| `project/features/combat/react/` | `react_line_bot.gd` calls the opening sidearm selection. |
| `project/dev/showcase/` | `reel_arsenal.gd`, `reel_director.gd` |
| `project/boot/` | `collect_call/quest1_session.gd` binds the recorder. `quest1_game.gd` and `world.gd` load the recorded settings before opening the playback world. |
| `project/core/` | `clock/sim_loop.gd` copies the recording options when recording starts. `replay/replay_log.gd` retains the optional header across JSON load and save. |
| `project/tests/scenarios/` | `scenario_brutality_kills.gd`, `scenario_moves_fuzz.gd`, `scenario_moves_replay.gd`, `scenario_moves_street.gd`, `scenario_ohm_bolt_delay.gd`, `scenario_quest1_input.gd`, `scenario_replay_60s.gd`, `scenario_rifle_rack.gd`, `scenario_rivet_cover.gd`, `scenario_rivet_pickup.gd`, `scenario_rivet_switch.gd`, `scenario_vehicle_doors.gd` |
| `project/tests/unit/` | `pilot_weapon_fixture.gd` and its UID, `test_controls_guard.gd`, `test_flamer_sway.gd`, `test_live_chainsaw.gd`, `test_live_deflect.gd`, `test_live_melee_weapon.gd`, `test_molotov_windup.gd`, `test_no_fire_in_roll.gd`, `test_rivet_wheel_start.gd` |

Gauntlet's entry selects `wheel` as its own fallback in `project/dev/gauntlet/gauntlet.gd`. Quest 1 and the arena both construct their pilot from `PlayerActions.shipped()`, which reads `ControlsMode.wheel()`.

`project/tests/scenarios/vault_trial.gd` also accepts the archived cover fixture's explicit mode. Its other callers use the launch mode.
