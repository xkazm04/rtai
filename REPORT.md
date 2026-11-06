# REPORT: lane `servo`, night 2026-11-05/06 (Act 2's Servo)

DRAFT (iteration 10, 02:47): to be finalized at 08:40. The exe is re-exported at the freeze; the final gates are still open.

Branch `n7-servo` (from main `763f8fba`, with `n7-king`'s framework merged in at every move; the
last merge was `73543d25`, iteration 10). Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\servo\` (M below),
indexed in `M/frames.json`. Design: `docs/bosses/servo.md`. Journal: `JOURNAL.md`.

## What works (with evidence)
- **The moveset doc first** (`docs/bosses/servo.md`): six attacks (scan_lock + drop_wave, rotor_dash,
  package_carpet, bay_hop, kamikaze, hot dash), each with a telegraph, an active window, a recovery,
  a counterplay and a punish window. Three phases: the depot, rush hour, overtime. How the four
  ghosts and Rivet's weapons play on him.
- **The body**: a cutout rig from Codex part sheets (`tools/art/servo_parts.py`). The 3-row rack
  wings are each one frame (`tools/art/servo_rack3.py`), set 0.94 m apart (`servo.json
  rack.spine_m`) by a heavy 1.5 m central spine of tan steel with stacked plated boxes and its hose cap, the sheet's top view; round hover pads on long arms, walker legs, and a visor head that glows vermilion
  only during a tell. The rack is its own animated layer: drones dock, launch and refill. Phase 3
  blows a wing off. The defeat: a flash, the pads spin down, the body slumps and greys out, the
  drones spill, the visor flickers out in cream.
  See `M/frames/servo_target_vs_game_32ppm_it10.png` and `M/frames/servo_rack_spine_docked_ab_it9.png`.
- **The drone swarm** (`features/bosses/servo/`): flocking on the 60 Hz tick from the
  `servo_swarm` stream, drop rings, a max-alive cap per phase, despawn, parcels (a bomb or a CS
  crate obstacle), and armoured kamikaze dives in phase 3. The drones are shootable. Dent seizes
  the depot's van, Ohm's arc chains through the swarm, and Kerf's blink cuts a line of drones,
  which fall in two halves.
- **The arena**: the depot (loading bays whose doors roll up at rush hour, a conveyor that runs
  from rush hour on, stacked CS crates). Rush hour opens with the depot's shift horn.
- **The framework** (n7-king's) carries Servo: the boss bar and phase marks, the music and stinger,
  `--boss=servo [--phase=N]`, and `--bot=boss`.
- **The full fight by the bot** at 32 px/m: `M/servo_fight_bot_human_32ppm_it10.mp4` (121 s, down at 117 s; keys `M/frames/servo_fight_keys_32ppm_it10.png`). Per attack (48 px/m): `M/servo_attack_*`; the drone wave from the lock to the dodge: `M/servo_drone_wave_scan_drop_dodge_48ppm_it10.mp4`; per phase (32 px/m): `M/servo_p{1,2}_*_32ppm_it10.mp4`, `M/servo_p3_overtime_defeat_32ppm_it12.mp4`; ghosts: `M/servo_ghost_*`. Index: `M/frames.json`.

## Numbers (the bot; `evidence/servo/numbers-it9-spine94/` + `-stand/`, seeds 1-5, CONTENDED wall time, tick-exact)
On the shipped tree (rack.spine_m 0.94); `numbers-it6a/` is the same fight with the wings touching.

| bot | downed | time to kill | took | deaths | rotor dash | hot dash | bay hop |
|---|---|---|---|---|---|---|---|
| dodge | 5/5 | 110-159 s (124) | 16 | 0 | 2/36 | 0/14 | 0/9 |
| human | 5/5 | 116-169 s (134) | 168 | 0 | 17/38 | 5/15 | 2/10 |
| stand | 0/5 (240 s cap) | - | 1398 | 28 | 81/90 | 6/6 | 17/17 |

(it6a, wings touching: dodge 127 s / 62, human 129 s / 128, stand 1/5 / 1388: the gap re-rolls
every wave, so single seeds move both ways; the hit rates hold. n = 5: not called balanced.)
The rotor dash checked against a reading player (it6): every tell read but 18-32 ticks late, it lands
2/40. The human bot's ~40 % comes from its 30 % unread tells (`numbers-it6-read1-*`).

## Calls for the owner
1. Drop rings show from the drone's launch (default) vs only over its hover: `servo.json drone.ring_from_launch`.
2. Should a CS crate landing on Rivet hurt? Today it does not.
3. Drones die to one round (default) vs tougher drones, so that waves land more often.
4. CS crates are solid (default) vs paint only: `servo.json parcels.crates_solid`. Clip: `M/servo_drone_wave_scan_drop_dodge_48ppm_it10.mp4`.
5. Rack depth: 3 rows / 18 cells (default) vs 2 / 12: `servo.json rack.rows` + `cells`. Still: `M/frames/servo_target_vs_game_32ppm_it10.png`.
6. The rotor dash smashes crates in its lane (default) vs crates stop him: `servo.json parcels.dash_smash`.
7. Kamikaze armour: 3 rounds (default) vs 1: `servo.json kamikaze.hp`. Clip: `M/servo_attack_kamikaze_dive_lands_48ppm_it10.mp4`.
8. Dent's van is parked from the start (default) vs none: `bosses.json arenas.depot.parked`. Clip: `M/servo_ghost_dent_van_48ppm_it10.mp4`.
9. Kerf's blink cuts the drones within 0.6 m of its line (default) vs only the one target: `bosses.json servo.kerf_line_m`. Clip: `M/servo_ghost_kerf_cut_halves_48ppm_it10.mp4`.
10. The spine: the wings 0.94 m apart for a 1.5 m spine, the sheet's measure (default) vs touching wings with a 0.56 m column over them (it8): `servo.json rack.spine_m` 0.94 / 0. It moves the drones' launch cells; measured, the fight stays inside the seeds' spread (`evidence/servo/numbers-it9-spine94/`). Still: `M/frames/servo_rack_spine_docked_ab_it9.png` (top row: 0 | 0.94 | 0.94 plated).
11. Docked drones: a cream body in each full rack bay, gaps where drones are out (default) vs the wing art alone (dark bays): `ServoRig.DOCKED_M` 0.34 / 0. The flying drone's full sprite in the bays was tried and rejected (18 rotor crosses: noise at 32 px/m). Still: the same file, bottom row (32 px/m).
12. The spine's tone: tan steel under stacked lighter boxes, sampled from the sheet (default) vs the it9 cream column with a near-white plate: `ServoSpine.STEEL_TONE` true / false (render only). Still: `M/frames/servo_spine_steel_ab_it10.png` (48 px/m before | after | the sheet; 32 px/m before | after).
13. The hover pads hang in front of the wings like the sheet (default) vs beside the wings' front corners (it9): `ServoRig.PAD_OUT_M` / `PAD_AHEAD_M` 2.35 / 2.0 vs 2.6 / 1.2 (render only). Still: `M/frames/servo_pads_ahead_ab_it10.png`.
14. A hazard-striped ledge along each rack wing's front edge, copper and ink like the sheet's rack base (default) vs the plain wing front: `ServoWingBand.ON` (render only). Still: `M/frames/servo_wing_band_ab_it10.png`.
15. The spine's horseshoe rail and the big copper hose loops off its back cap, like the sheet's top view (default) vs the it10 spine (the cap's small loops, no rail): `ServoSpine.HORSESHOE` true / false (render only; subtle at 32 px/m, the loops show beside the cap and the rail along the column). Still: `M/frames/servo_spine_horseshoe_ab_it12.png`.

Exe (exported it10 on f430d3a2, re-exported at the freeze): `build/export/windows/RTAI.exe` in the
worktree (`windows-showcase` preset, boots into the arena). Lines: `RTAI.exe -- --rigs --boss=servo`,
`RTAI.exe -- --rigs --boss=servo --phase=2` (or 3), `RTAI.exe -- --rigs --boss=servo --bot=boss`
(the bot plays; add `--bot-human` for the human-like one). Headless smoke `RTAI.exe --headless
--fixed-fps 60 --quit-after 7400 -- --rigs --boss=servo --bot=boss --bot-human --seed=2`: Servo down at
tick 7036, 188 on Rivet, 0 SCRIPT ERROR, the editor's numbers (`evidence/servo/exe-smoke-it10.json`).

## What does not work / open
- The horn has not been heard (every run was headless or filmed without listening).
- The spine is procedural: since it10 it has the sheet's width and tan steel with stacked boxes, and since it12 a light horseshoe rail and copper hose loops past its cap; the rail's round bottom sits under the torso, and the loops are thinner and less orange than the sheet's. The rack bases' hazard stripes are copper (vermilion is reserved), so they read browner than the sheet's orange.
- The `--boss-cam` clip camera frames Rivet and the boss together; a bay-hop landing ring on a Rivet by the bays can sit under the boss bar in a clip (`M/servo_attack_bay_hop_48ppm_it10.mp4`). In play the camera centres on Rivet, so the ring stays on screen. Measured it12: keeping 3 m round Rivet as well (before the boss's keep_in) changed nothing in that clip: at 48 px/m the screen holds ~11.9 m between the boss bar and the ghost card, and Rivet stood 7.7 m above Servo (7.7 + 3 + 3 = 13.7 m); reverted.
- (Fixed in it12) the clip camera at the phase-3 defeat in the yard's top-left corner: turned sideways, his rack, pads and spill reach ~5 m from his centre, so half the body left the screen at the 3.0 m margin. `BossCam.BOSS_MARGIN_X_M` 5.5 (sideways only; 3.0 vertically) holds him whole; the mid-fight framing did not change in the 12 keys, and at the corner a strip of sidewalk shows. View only, `--boss-cam` only (a framework file: King's clips frame the same unless he stands within 5.5 m of a side edge). A/B: `M/frames/servo_bosscam_xmargin_ab_it12.png`; the clip `M/servo_p3_overtime_defeat_32ppm_it12.mp4`.

## Next steps
- To come.
