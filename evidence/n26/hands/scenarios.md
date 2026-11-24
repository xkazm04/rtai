# Quick claw scenario and unit verification

The baseline suite hit its 25-minute limit after 60 passes. The post-change suite ran through city replay (19 passes) before it was stopped for the serial mutation runs. A separate post-change run passed Quest 1 input, the 60-second replay and the revised arena rake tape.

| Scenario | Before | After |
|---|---|---|
| arena_city | Pass | Pass |
| arena_course | Pass | Pass |
| arena_pit | Pass | Pass |
| arena_range | Pass | Pass |
| arena_squad | Pass | Pass |
| arena_stations | Pass | Pass |
| arena_zebra | Pass | Pass |
| autosave_input | Pass | Pass |
| autosave_resume | Pass | Pass |
| bodies_cop | Pass | Pass |
| bodies_crowd | Pass | Pass |
| bodies_runin | Pass | Pass |
| bodies_tackle | Pass | Pass |
| brutality_kills | Pass | Pass |
| car_knocks_rivet | Pass | Pass |
| city_bake | Pass | Pass |
| city_chase | Pass | Pass |
| city_parity_ref | Pass | Pass |
| city_replay | Pass | Pass |
| city_scare | Pass | Unverified |
| corpse_horde | Pass | Unverified |
| crowd_react | Pass | Unverified |
| enemy_pit | Pass | Unverified |
| enemy_waves | Pass | Unverified |
| ghost_attacks | Pass | Unverified |
| gunplay_fight | Pass | Unverified |
| gunplay_fire | Pass | Unverified |
| handheld_focus_pause | Pass | Unverified |
| human_react | Pass | Unverified |
| moves_fuzz | Pass | Unverified |
| moves_replay | Pass | Unverified |
| moves_street | Pass | Unverified |
| ohm_bolt_delay | Pass | Unverified |
| prologue_checkpoint | Pass | Unverified |
| prologue_handover | Pass | Unverified |
| prologue_pilot | Pass | Unverified |
| quest1_dent | Pass | Unverified |
| quest1_dent_lock | Pass | Unverified |
| quest1_input | Pass | Pass |
| quest1_kerf | Pass | Unverified |
| quest1_keys | Pass | Unverified |
| quest1_ohm | Pass | Unverified |
| quest1_tonnage | Pass | Unverified |
| quest_collect_call | Pass | Unverified |
| quest_selftest | Pass | Unverified |
| react_line | Pass | Unverified |
| replay_60s | Pass | Pass |
| rifle_rack | Pass | Unverified |
| rig_stress | Pass | Unverified |
| rivet_chainsaw | Pass | Unverified |
| rivet_city_fight | Pass | Unverified |
| rivet_city_melee | Pass | Unverified |
| rivet_claw | Pass | Pass |
| rivet_cover | Pass | Unverified |
| rivet_deflect | Pass | Unverified |
| rivet_katana | Pass | Unverified |
| rivet_pickup | Pass | Unverified |
| rivet_switch | Pass | Unverified |
| rivet_throw | Pass | Unverified |
| rivet_vault | Pass | Unverified |
| showcase_director | Unverified | Unverified |
| showcase_reel | Unverified | Unverified |
| souls_powers | Unverified | Unverified |
| traffic_yields_rivet | Unverified | Unverified |
| vehicle_carnage | Unverified | Unverified |
| vehicle_doors | Unverified | Unverified |
| vehicle_drive | Unverified | Unverified |
| vehicle_yield | Unverified | Unverified |

## Digests and coverage

The complete observed replay digests, quest checkpoints and archive failures are in [tapes.json](tapes.json). The only verified combat re-pin is rivet_claw. It still makes seven swings, with five kills and no remaining live shock target. The other passing scenarios use their existing expectations.

The full GUT run at the new settings reported 4,001 passes, four failures and two skips. The four failures had old survival or hit-count expectations. All ten tests in the two corrected files passed on rerun. A separate focused run passed all 25 melee and kill-art tests.

| Existing test file | Tests updated |
|---|---|
| test_melee_lethal.gd | test_claw_boss_owned_mulroney_machines_and_covered_targets |
| test_melee_lethal_pit.gd | test_pit_uses_the_real_hit_direction_and_weapon_on_each_contact |
| test_gauntlet_wave_stats.gd | test_one_round_and_one_claw_contact_are_counted_separately |
| test_player_shock.gd | test_a_full_charge_stuns_arcs_and_kills_the_first_body, test_a_half_charge_stuns_without_a_kill, test_a_mash_and_a_short_hold_never_discharge |

The first two tests continue to cover normal damage or directional shield behavior. The gauntlet count excludes the guard already killed by the rake from subsequent rifle hits. The shock tests use a warden so the opening jab leaves a target for the charged release.
