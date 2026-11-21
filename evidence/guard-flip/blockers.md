# Wheel default blockers

16 scenarios failed on wheel after Part B. Each row names the observed behavior, merge edit and responsible fixture. Keep the current replay goldens.

| File | What changes under wheel | Pin or edit at merge | Owner |
|---|---|---|---|
| project/tests/scenarios/scenario_arena_city.gd | The range bot starts on hands and its primary does not fire Gloria. | Select Gloria before the first range volley. | Arena range bot and city scenario |
| project/tests/scenarios/scenario_arena_pit.gd | The pit bot holds primary on hands and clears zero waves. | Select Gloria before the pit entry. | Arena pit bot and scenario |
| project/tests/scenarios/scenario_arena_range.gd | The bot fires zero shots and records one hit. | Select the sidearm before holding primary. | Arena range bot and scenario |
| project/tests/scenarios/scenario_arena_squad.gd | The city squad fixture cannot clear five waves with its initial attack inputs. | Select the intended gun in the shared squad fixture before combat. | Squad scenario |
| project/tests/scenarios/scenario_brutality_kills.gd | The rocket fixture starts on hands and records zero rocket gib kills. | Select the requested weapon at the start of each kill-lab recording. | Brutality scenario and kill-lab bot |
| project/tests/scenarios/scenario_city_scare.gd | No gunshots reach the city. | Select the fixture gun before injecting fire. | City reaction scenario |
| project/tests/scenarios/scenario_moves_replay.gd | The recording reaches the corner peek without a fire beat. | Draw the gun before the corner-peek sequence. | Movement replay scenario |
| project/tests/scenarios/scenario_react_line.gd | Zero rounds hit the reaction line. | Select the fixture gun before its first primary input. | Reaction-line scenario |
| project/tests/scenarios/scenario_rifle_rack.gd | The walk-past assertion requires a null carry and the take case assumes immediate rifle equip. | Pin the legacy pickup contract or assert wheel inventory and select the rifle before firing. | Arena rifle rack scenario |
| project/tests/scenarios/scenario_rivet_chainsaw.gd | The mash/held melee action swings the claw. | Select the chainsaw then hold fire for the grind. | Rivet arsenal bot and scenario |
| project/tests/scenarios/scenario_rivet_cover.gd | The corner shot misses the dummy because the tape never draws the gun. | Draw Gloria before the cover tape starts. | Station cover scenario |
| project/tests/scenarios/scenario_rivet_katana.gd | The melee action performs a quick claw strike and the trace reports claw. | Select the katana then drive its combo with fire. | Rivet arsenal bot and scenario |
| project/tests/scenarios/scenario_rivet_pickup.gd | Both same-grip guns remain carried and neither pickup auto-equips. | Pin the legacy swap/drop expectations and add a wheel retain/select case. | Rivet arsenal pickup scenario |
| project/tests/scenarios/scenario_rivet_switch.gd | The first rocket leaves on tick 60 versus the expected pistol-to-rocket tick 68, and cycling includes hands. | Start with an explicit pistol selection and include hands at wraparound. | Rivet arsenal switch scenario |
| project/tests/scenarios/scenario_showcase_director.gd | The pistol chapter finishes with one of two targets down. | Select each chapter weapon before playback. | Showcase director scenario and chapter bot |
| project/tests/scenarios/scenario_showcase_reel.gd | The gun beat kills zero guards in the pit. | Select the ranged weapon at the gun beat transition. | Showcase reel and scenario |
| project/boot/quest1_card.gd:14 | Help still calls right click electroshock. | Choose localized help by control mode. Wheel should say RMB guards and LMB swings or fires. | Quest 1 UI and localization |
| project/tests/unit/test_controls_guard.gd | The default-mode assertion explicitly requires legacy. The raw RMB assertions already select each mode. | Change the default assertion only alongside an approved flip. | Guard |
| project/tests/unit/test_live_melee_weapon.gd | Its setup preselects a blade before binding the carry. Wheel opens on hands. | Explicitly draw the blade through the pilot before holding primary, or pin this fixture to legacy. | Arsenal unit tests, source audit |
| tools/tests/run_unit.mjs | Its parser rejects --controls=wheel and does not forward game flags. A full wheel unit gate is unverified. | Add runner support for a game argument or run the full gate on a flip candidate. | Test tooling |
| project/dev/gauntlet/gauntlet.gd | Street commit a3a06df84 reads ControlsMode.id() at line 30 and validates a supplied switch. Its entry does not itself supply wheel. | Pass --controls=wheel from the launch path or default that entry independently. | Street |

## Binding audit

test_controls_guard.gd (both modes) and test_rivet_wheel_pilot.gd (explicit wheel) construct the only physical right-button mouse events under tests/dev. ArenaRivetBot writes melee action bits for katana and chainsaw. Space is a claw strike under wheel. The deflect scenario uses ArenaArsenalBot, selects a numbered shortcut and uses primary. It passed in both modes.

project/dev/ghost-powers/quest_hauler_rec.gd, quest_crush_rec.gd and quest_ghost_rec.gd inject the first bound keyboard/mouse event for melee (Space). PlayerActions installs keys before mouse buttons. These recorders do not depend on RMB. Form scenarios using decoded melee continue to pass.

scenario_ohm_bolt_delay.gd and scenario_vehicle_doors.gd temporarily replace launch options for their feature checks. The disabled-feature controls in scenario_moves_fuzz.gd and scenario_moves_street.gd also replace options. Their explicit overrides remain intact during wheel runs.

## Film telemetry

- StagePilot._attacks (project/boot/collect_call/stage_pilot.gd:100) increments melee_swings while combo.buffered remains true. A held primary sets that same bit again on each tick. The film's one start became five reported swings on ticks 56–60. Count the difference in combo.starts across both press() and melee.step() so the deferred start is counted once. This line belongs to the attack counter, outside the permitted pilot call sites. Its readers include ArenaClawCops.telemetry (arena_claw_cops.gd:119), scenario_rivet_deflect.gd:54, arsenal_turn_rec.gd:97 and guard_film_beats.gd. At n22-loop commit 9fef9702b, BotCounters.observe_totals reads shots and rolls. There was no per-wave melee_swings reader in that branch's gauntlet files.
- ArenaStage.step (project/features/arena/arena_stage.gd:95–96) culls before super.step updates arena.tick. RivetBlast.burst stamps the ring with that clock at rivet_blast.gd:13. The tick-114 blocked wall burst consequently reports 113 to the film probe and appears one tick old to FightAreasArt, FightScorch and ArenaCombatLights. FightAreas excludes ring timestamps from replay state and the blocked burst dealt zero damage. Damaging wall bursts also pass the arena clock to Fighter.take, which influences repair timing. Advancing the clock inside RivetBlast would also affect correctly timed bursts. Pass the impact tick from the stage/cull path if the event timestamp needs changing.

## Passing movement fixtures with different state

The pit and city runs in scenario_moves_fuzz.gd both pass their own replay. ArenaStage starts with Gloria equipped (arena_stage.gd:75), wheel opens on hands, and moves_fuzz_tape.gd:46 sets fire. These inputs exercise different attacks and WeaponHold serializes the weapon actually drawn. The separate disabled-feature control and the quest street movement digest match legacy.
