# REPORT: lane `servo`, night 2026-11-05/06 (Act 2's Servo)

Final (iteration 22, the freeze). Gates on the last code head, dd385a82 (the it19 body, the sim-neutral `parcels.crate_damage` key, and n7-king's optional `rivet_repair_delay_s`, which Servo does not set): lint 13/13, unit 1203/0 (`evidence/servo/unit-it22.log`), scenarios 52 ran / 0 failed (`evidence/servo/scenarios-it22.log`); director reel 19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/servo/director-reel-it22.log`); `tools/evidence/run.mjs --no-bench` all PASS on 8097cdf3: lint, unit 1203, scenarios 52, parity (bit for bit, the planted mutation caught at step 629), selftest (look goldens 11/11, block goldens 5/5) (`evidence/servo/evidence-run-it22.log`; bench skipped, CONTENDED); the bot's numbers at n = 10 (it20; the it22 merge leaves Servo's fight alone: the re-exported exe's smoke gives tick 7036 and 188 on Rivet, the it20 record line for line, `evidence/servo/exe-smoke-it22.json`). Every clip and still is on the it19 body (987c3439), which the final head draws identically (no render change since).

Branch `n7-servo` (from main `763f8fba`, with `n7-king`'s framework merged in at every move; the
last merge was `dd385a82` = n7-king `7b404d71`, iteration 22). Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\servo\` (M below),
indexed in `M/frames.json`. Design: `docs/bosses/servo.md`. Journal: `JOURNAL.md`.

## What works (with evidence)
- **The moveset doc first** (`docs/bosses/servo.md`): six attacks (scan_lock + drop_wave, rotor_dash,
  package_carpet, bay_hop, kamikaze, hot dash), each with a telegraph, an active window, a recovery,
  a counterplay and a punish window. Three phases: the depot, rush hour, overtime. How the four
  ghosts and Rivet's weapons play on him.
- **The body**: a cutout rig from Codex part sheets (`tools/art/servo_parts.py`). The 3-row rack
  wings are each one frame (`tools/art/servo_rack3.py`), set 0.94 m apart (`servo.json
  rack.spine_m`) by a heavy 1.5 m central spine of tan steel with stacked plated boxes and its hose cap, the sheet's top view; octagonal hover pads square to the body on long arms (their rotors blur inside them when he revs for a tell), walker legs, and a visor head that glows vermilion
  only during a tell. The rack is its own animated layer: each full bay holds a docked quad drone (a cream hub and rotor rings on the art's bays, the sheet's look; the flying drone is the same hub and four rotors, a kraft parcel slung under it toward its shadow, which falls into its ring as the same box), drones launch from it, their bays go dark, and refill. Phase 3
  blows a wing off. The defeat: a flash, the pads spin down, the body slumps and greys out, the
  drones spill, the visor flickers out in cream.
  See `M/frames/servo_target_vs_game_32ppm_it19.png` and `M/frames/servo_docked_bays_ab_it16.png`, `M/frames/servo_slung_parcel_ab_it18.png`.
- **The drone swarm** (`features/bosses/servo/`): flocking on the 60 Hz tick from the
  `servo_swarm` stream, drop rings, a max-alive cap per phase, despawn, parcels (a bomb or a CS
  crate obstacle), and armoured kamikaze dives in phase 3. The drones are shootable. Dent seizes
  the depot's van, Ohm's arc chains through the swarm, and Kerf's blink cuts a line of drones,
  which fall in two halves.
- **The arena**: the depot (loading bays whose doors roll up at rush hour, a conveyor that runs
  from rush hour on, stacked CS crates). Rush hour opens with the depot's shift horn.
- **The framework** (n7-king's) carries Servo: the boss bar and phase marks, the music and stinger,
  `--boss=servo [--phase=N]`, and `--bot=boss`.
- **The full fight by the bot** at 32 px/m: `M/servo_fight_bot_human_32ppm_it19.mp4` (121 s, down at 117 s; keys `M/frames/servo_fight_keys_32ppm_it19.png`). Per attack (48 px/m): `M/servo_attack_*`; the drone wave from the lock to the dodge: `M/servo_drone_wave_scan_drop_dodge_48ppm_it19.mp4`; per phase (32 px/m): `M/servo_p{1,2,3}_*_32ppm_it19.mp4`; ghosts: `M/servo_ghost_*`. Index: `M/frames.json`.

## Numbers (the bot; `evidence/servo/numbers-it20/` (dodge, human) + `numbers-it20-stand/`, seeds 1-10 each, CONTENDED wall time, tick-exact)
Re-measured it20 on the shipped tree: seeds 1-5 give the same `boss_fight` record as it9 for
all three bots, so the it10-it19 body work moved nothing in the sim; seeds 6-10 double n.

| bot | downed | time to kill | took | deaths | rotor dash | hot dash | bay hop | kamikaze dive | drop wave |
|---|---|---|---|---|---|---|---|---|---|
| dodge | 10/10 | 110-159 s (130) | 26 | 0 | 4/74 | 1/26 | 1/18 | 5/44 dives | 0 parcel hits |
| human | 10/10 | 116-169 s (137) | 159 | 0 | 33/81 | 8/29 | 6/16 | 6/56 dives | 6 parcel hits |
| stand | 1/10 (240 s cap) | 169 s (the one kill) | 1370 | 56 | 140/159 | 18/19 | 37/39 | 34/54 dives | 346 parcel hits |

(took = damage dealt to Rivet over the whole fight; neither moving bot died in 20 fights. The dodge
bot's 98 on seed 10 is one bay hop, one dash each and a dive. it6a, wings touching: dodge 127 s / 62, human 129 s / 128, stand 1/5 / 1388 (n = 5). n = 10: the
spread is wide (110-169 s), so still not called balanced; it is fair in the sense that the dashes and
hop land 4-6 % and the dives 11 % on a bot that reads its tells, against 88-95 % (dashes, hop) and
63 % (dives) on one that stands.)
Pacing per phase (combat-pacing-and-dramatic-arc), from the same 20 runs: a phase's start is read as
its first own attack's windup (carpet or hop = rush hour, kamikaze or hot dash = overtime), so each
start is an upper bound; the fight records no transition tick. Depot 54 s (dodge 36-88, human
45-75), rush hour 49-52 s (38-73), overtime 28-31 s (19-41): a falling arc, the hottest phase the
shortest. The 88 s depot is dodge seed 1, the 159 s fight.
Rivet's repair delay (it22, n7-king's `bosses.json <id>.rivet_repair_delay_s`, merged; a temporary
data edit on Servo's row, reverted; human bot, seeds 1-10): at 6 s (twice combat.json's 3 s) the
fights match it20 exactly, 0 deaths (`numbers-it22-repair6/`); at 30 s (the schema's top) 6 of 10
fights have a Rivet death (8 in all: seeds 1, 8, 9, 10 one each, 2 and 3 two each) and Servo still
goes down 10/10, slower where Rivet died (seed 2 233 s vs 117 s) (`numbers-it22-repair30/`). The
lever reaches the fight, and the easy band holds up to at least 6 s.
The rotor dash checked against a reading player (it6): every tell read but 18-32 ticks late, it lands
2/40. The human bot's ~40 % comes from its 30 % unread tells (`numbers-it6-read1-*`).

## Calls for the owner
1. Drop rings show from the drone's launch (default) vs only over its hover: `servo.json drone.ring_from_launch` true / false. The default is seen in `M/servo_drone_wave_scan_drop_dodge_48ppm_it19.mp4` (the rings stand on the mark while the drones fly in); the alternative has no clip (it needs a data edit and a re-export).
2. Should a CS crate landing on Rivet hurt? Today it does not (default): `servo.json parcels.crate_damage` 0 vs e.g. 12 (the bomb deals 22). Measured with 12 (`evidence/servo/numbers-it20-crate12/`): the dodge and human bots, seeds 1-10, are identical to 0, since the 0.9 m crate sits inside the 1.6 m ring they already dodge; only a standing Rivet pays (`-stand/`, parcel hits 50/53/43 vs 39/48/32). So it only punishes a player who already missed the ring.
3. Drones die to one round (default) vs tougher drones, so that waves land more often: `servo.json drone.hp` 1 vs 2-3 (drop wave hits today: dodge 0, human 6 parcel hits in 10 fights).
4. CS crates are solid (default) vs paint only: `servo.json parcels.crates_solid`. Clip: `M/servo_drone_wave_scan_drop_dodge_48ppm_it19.mp4`.
5. Rack depth: 3 rows / 18 cells (default) vs 2 / 12: `servo.json rack.rows` + `cells`. Still: `M/frames/servo_target_vs_game_32ppm_it19.png`.
6. The rotor dash smashes crates in its lane (default) vs crates stop him: `servo.json parcels.dash_smash` true / false. The bots' fights smash 3-18 crates each (`numbers-it20/`, `crates_smashed`); in play: `RTAI.exe -- --rigs --boss=servo` and stand behind a CS crate in a dash lane. The alternative has no clip.
7. Kamikaze armour: 3 rounds (default) vs 1: `servo.json kamikaze.hp`. Clip: `M/servo_attack_kamikaze_dive_lands_48ppm_it19.mp4`.
8. Dent's van is parked from the start (default) vs none: `bosses.json arenas.depot.parked`. Clip: `M/servo_ghost_dent_van_48ppm_it19.mp4`.
9. Kerf's blink cuts the drones within 0.6 m of its line (default) vs only the one target: `bosses.json servo.kerf_line_m`. Clip: `M/servo_ghost_kerf_cut_halves_48ppm_it19.mp4`.
10. The spine: the wings 0.94 m apart for a 1.5 m spine, the sheet's measure (default) vs touching wings with a 0.56 m column over them (it8): `servo.json rack.spine_m` 0.94 / 0. It moves the drones' launch cells; measured, the fight stays inside the seeds' spread (`evidence/servo/numbers-it9-spine94/`). Still: `M/frames/servo_rack_spine_docked_ab_it9.png` (top row: 0 | 0.94 | 0.94 plated).
11. Docked drones: a cream hub with four light rotor rings on each full bay of the rack art, over the art's own printed quad drone, the sheet's bays (default, it16) vs the it14 cream squares on the sim's launch cells, up to 0.36 m off the art's bays: `ServoRig.DOCKED_ON_BAYS` true / false (render only); or the wing art alone (dark bays): `ServoRig.DOCKED_M` 0. Still: `M/frames/servo_docked_bays_ab_it16.png` (32 px/m at 2x, then 48 px/m; it14 left, it16 right). Before: Docked drones: a cream body in each full rack bay, gaps where drones are out (default) vs the wing art alone (dark bays): `ServoRig.DOCKED_M` 0.34 / 0. The flying drone's full sprite in the bays was tried and rejected (18 rotor crosses: noise at 32 px/m). Still: the same file, bottom row (32 px/m).
12. The spine's tone: tan steel under stacked lighter boxes, sampled from the sheet (default) vs the it9 cream column with a near-white plate: `ServoSpine.STEEL_TONE` true / false (render only). Still: `M/frames/servo_spine_steel_ab_it10.png` (48 px/m before | after | the sheet; 32 px/m before | after).
13. The hover pads hang in front of the wings like the sheet (default) vs beside the wings' front corners (it9): `ServoRig.PAD_OUT_M` / `PAD_AHEAD_M` 2.35 / 2.0 vs 2.6 / 1.2 (render only). Still: `M/frames/servo_pads_ahead_ab_it10.png`.
14. A hazard-striped ledge along each rack wing's front edge, copper and ink like the sheet's rack base (default) vs the plain wing front: `ServoWingBand.ON` (render only). Still: `M/frames/servo_wing_band_ab_it10.png`.
15. The spine's horseshoe rail and the big copper hose loops off its back cap, like the sheet's top view (default) vs the it10 spine (the cap's small loops, no rail): `ServoSpine.HORSESHOE` true / false (render only; subtle at 32 px/m, the loops show beside the cap and the rail along the column). Still: `M/frames/servo_spine_horseshoe_ab_it12.png`; the loops then grew to 0.55 m in a lighter copper (`ServoSpine.LOOP_R_M` 0.55 / 0.42): `M/frames/servo_spine_loops_ab_it12.png`.
16. The hover pads ring in the sheet's ink and copper hazard stripes (default) vs the it13 cut's copper on mid brown, which read as one brown band at 32 px/m: `ServoRig.PAD_ART` &"pad_hazard" / &"pad" (render only; `tools/art/servo_pad_rim.py` re-inks the installed cut, no image job). Still: `M/frames/servo_pad_hazard_ab_it14.png` (the sheet; 32 px/m before | after; 48 px/m before | after).
17. The legs stand parallel under the torso like the sheet's top view, pad | leg | leg | pad (default) vs splayed out toward the pads, crossing the pad arms (it13): `ServoRig.LEG_SPLAY_M` / `KNEE_OUT_M` 0.25 / 0.2 vs 0.9 / 0.5 (render only). Still: `M/frames/servo_legs_stance_ab_it14.png` (the sheet; 32/48 px/m before | after; the walk's keys).
18. The carried parcel is a kraft box slung under each drone, shown round the hub toward its shadow, and a dropped parcel falls into its ring as the same box over a closing shadow (default, it18) vs the it16 cream square on the hub, nothing seen falling: `ServoDraw.SLUNG_PARCEL` true / false (render only; `PARCEL_M` 0.62, `SLING_M` 0.5). Still: `M/frames/servo_slung_parcel_ab_it18.png` (48 px/m at 2x, it16 left, it18 right; then 32 px/m 1x); clip `M/servo_drone_wave_scan_drop_dodge_48ppm_it19.mp4`.
19. The hover pads hold square to the body, the sheet's octagons, and the rotor's spin-up shows as pale blades inside them on every tell, dash and wind-down (default, it19) vs the it18 pads turning whole with the rotor, a round wheel at 32 px/m: `ServoPad.TURN` false / true (render only). Still: `M/frames/servo_pad_square_ab_it19.png` (48 px/m at 1.5x, it18 left, it19 right, at the scan and dash windups; then it19 at 32 px/m).
20. The pad arms and legs drawn wider than their art, the sheet's chunky blocks (default, it19b: arms 1.6, legs 1.3) vs the art's width, a thin 0.25 m piston at 32 px/m: `ServoRig.ARM_W_K` / `LEG_W_K` 1.6 / 1.3 vs 1.0 (render only). Still: `M/frames/servo_chunky_struts_ab_it19.png` (48 px/m then 32 px/m, both at 1.5x; 1.0 left, it19b right). Every clip is re-shot on it (987c3439).
21. Difficulty band, the same question as King's call C: easy (default: the human-like bot never dies in 10 fights, took 159 on average) vs harder through Rivet's repair delay in this fight, `bosses.json servo.rivet_repair_delay_s` (absent = combat.json's 3 s). Measured (human bot, n = 10, `evidence/servo/numbers-it22-repair6/` and `-repair30/`): 6 s changes nothing (0 deaths); 30 s gives a death in 6 of 10 fights, Servo still downed 10/10. A value between them was not measured. To see it: set the field in `project/data/tables/bosses.json` and run `node evidence/servo/boss_numbers.mjs --seeds=1,2,3,4,5,6,7,8,9,10 --bots=human --tag=<name>`; in play it needs a re-export. No clip.

Exe (re-exported at 07:42 in iteration 22, on dd385a82, the last code head): `build/export/windows/RTAI.exe` in the
worktree (`windows-showcase` preset, boots into the arena). Lines: `RTAI.exe -- --rigs --boss=servo`,
`RTAI.exe -- --rigs --boss=servo --phase=2` (or 3), `RTAI.exe -- --rigs --boss=servo --bot=boss`
(the bot plays; add `--bot-human` for the human-like one). Headless smoke `RTAI.exe --headless
--fixed-fps 60 --quit-after 7400 -- --rigs --boss=servo --bot=boss --bot-human --seed=2`: Servo down at
tick 7036, 188 on Rivet, 0 SCRIPT ERROR, the editor's numbers (`evidence/servo/exe-smoke-it22.json`; the code since 987c3439 is the sim-neutral `crate_damage` key and n7-king's repair delay field, which Servo does not set).

## What does not work / open
- The horn has not been heard (every run was headless or filmed without listening).
- The spine is procedural: since it10 it has the sheet's width and tan steel with stacked boxes, and since it12 a light horseshoe rail and copper hose loops past its cap; the rail's round bottom sits under the torso, and the loops (0.55 m, a lighter copper since it12b) are still thinner than the sheet's. The rack bases' and (since it14) the pads' hazard stripes are copper (vermilion is reserved), so they read browner than the sheet's orange.
- The `--boss-cam` clip camera frames Rivet and the boss together; a bay-hop landing ring on a Rivet by the bays can sit under the boss bar in a clip (`M/servo_attack_bay_hop_48ppm_it19.mp4`). In play the camera centres on Rivet, so the ring stays on screen. Measured it12: keeping 3 m round Rivet as well (before the boss's keep_in) changed nothing in that clip: at 48 px/m the screen holds ~11.9 m between the boss bar and the ghost card, and Rivet stood 7.7 m above Servo (7.7 + 3 + 3 = 13.7 m); reverted.
- (Fixed in it12) the clip camera at the phase-3 defeat in the yard's top-left corner: turned sideways, his rack, pads and spill reach ~5 m from his centre, so half the body left the screen at the 3.0 m margin. `BossCam.BOSS_MARGIN_X_M` 5.5 (sideways only; 3.0 vertically) holds him whole; the mid-fight framing did not change in the 12 keys, and at the corner a strip of sidewalk shows. View only, `--boss-cam` only (a framework file: King's clips frame the same unless he stands within 5.5 m of a side edge). A/B: `M/frames/servo_bosscam_xmargin_ab_it12.png`; the clip `M/servo_p3_overtime_defeat_32ppm_it19.mp4`.

## Next steps
- Listen to the horn and the boss loop in the exe (never heard tonight).
- Play the fight by hand at 32 px/m (`RTAI.exe -- --boss=servo`): the numbers are the bots'.
- If the owner picks a harder band (call 21): bisect `servo.rivet_repair_delay_s` between 6 and 30 s
  with the human bot at n = 10 until about 7 in 10 survive, and ask the framework for a
  `phase_ticks` field in the `boss_fight` telemetry (today a phase's start is read from windups).
- Body: the docked bays, slung parcels and square octagonal pads now match the sheet; what remains
  by the target still is the spine's rail bottom under the torso (the legs and pad arms are wider since it19b, still slimmer than the sheet's blocks).
- The sim's rack cells (the drones' launch points) could move onto the art's bays
  (`servo.json rack.row_dy_m` 0.65, `cell_dx_m` 0.73); it moves the fight's numbers, so it needs a
  re-measure with the bot first.
