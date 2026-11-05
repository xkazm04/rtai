# REPORT: lane `servo`, night 2026-11-05/06 (Act 2's Servo)

DRAFT (iteration 8, 00:50): to be finalized at 08:40. The exe line and the final gates are still open.

Branch `n7-servo` (from main `763f8fba`, with `n7-king`'s framework merged in at every move; the
last merge was `ad428713`). Clips and stills: `C:\Users\kazda\kiro\gtai-masters\n7\servo\` (M below),
indexed in `M/frames.json`. Design: `docs/bosses/servo.md`. Journal: `JOURNAL.md`.

## What works (with evidence)
- **The moveset doc first** (`docs/bosses/servo.md`): six attacks (scan_lock + drop_wave, rotor_dash,
  package_carpet, bay_hop, kamikaze, hot dash), each with a telegraph, an active window, a recovery,
  a counterplay and a punish window. Three phases: the depot, rush hour, overtime. How the four
  ghosts and Rivet's weapons play on him.
- **The body**: a cutout rig from Codex part sheets (`tools/art/servo_parts.py`). The 3-row rack
  wings are each one frame (`tools/art/servo_rack3.py`), with a central spine and its hose cap
  (render only), round hover pads on long arms, walker legs, and a visor head that glows vermilion
  only during a tell. The rack is its own animated layer: drones dock, launch and refill. Phase 3
  blows a wing off. The defeat: a flash, the pads spin down, the body slumps and greys out, the
  drones spill, the visor flickers out in cream.
  See `M/frames/servo_target_vs_arena_rack3_seam_48ppm_it8.png` and `M/frames/servo_spine_ab_48ppm_it8.png`.
- **The drone swarm** (`features/bosses/servo/`): flocking on the 60 Hz tick from the
  `servo_swarm` stream, drop rings, a max-alive cap per phase, despawn, parcels (a bomb or a CS
  crate obstacle), and armoured kamikaze dives in phase 3. The drones are shootable. Dent seizes
  the depot's van, Ohm's arc chains through the swarm, and Kerf's blink cuts a line of drones,
  which fall in two halves.
- **The arena**: the depot (loading bays whose doors roll up at rush hour, a conveyor that runs
  from rush hour on, stacked CS crates). Rush hour opens with the depot's shift horn.
- **The framework** (n7-king's) carries Servo: the boss bar and phase marks, the music and stinger,
  `--boss=servo [--phase=N]`, and `--bot=boss`.

## Numbers (the bot; `evidence/servo/numbers-it6a/`, seeds 1-5, CONTENDED wall time, tick-exact)
| bot | downed | time to kill | took | deaths | rotor dash | hot dash | bay hop |
|---|---|---|---|---|---|---|---|
| dodge | 5/5 | 114-140 s (127) | 62 | 0 | 2/35 | 1/17 | 5/8 |
| human | 5/5 | 121-138 s (129) | 128 | 0 | 15/38 | 5/15 | 0/8 |
| stand | 1/5 | 204 s | 1388 | 25 | 86/95 | 3/3 | 14/14 |

The rotor dash checked against a reading player: every tell read but 18-32 ticks late, it lands
2/40. The human bot's 39 % comes from its 30 % unread tells (`numbers-it6-read1-*`).

## Calls for the owner
1. Drop rings show from the drone's launch (default) vs only over its hover: `servo.json drone.ring_from_launch`.
2. Should a CS crate landing on Rivet hurt? Today it does not.
3. Drones die to one round (default) vs tougher drones, so that waves land more often.
4. CS crates are solid (default) vs paint only: `servo.json parcels.crates_solid`. Clip: `M/servo_drone_wave_scan_drop_dodge_48ppm_it3.mp4`.
5. Rack depth: 3 rows / 18 cells (default) vs 2 / 12: `servo.json rack.rows` + `cells`. Still: `M/frames/servo_target_vs_arena_rack3_seam_48ppm_it8.png`.
6. The rotor dash smashes crates in its lane (default) vs crates stop him: `servo.json parcels.dash_smash`.
7. Kamikaze armour: 3 rounds (default) vs 1: `servo.json kamikaze.hp`. Clip: `M/servo_attack_kamikaze_dive_lands_48ppm_it5.mp4`.
8. Dent's van is parked from the start (default) vs none: `bosses.json arenas.depot.parked`. Clip: `M/servo_ghost_dent_van_48ppm_it5.mp4`.
9. Kerf's blink cuts the drones within 0.6 m of its line (default) vs only the one target: `bosses.json servo.kerf_line_m`. Clip: `M/servo_ghost_kerf_cut_halves_48ppm_it7.mp4`.

Exe: (to come by 08:30) `build/export/windows/RTAI.exe -- --boss=servo`, `-- --boss=servo --phase=2`, `-- --bot=boss --boss=servo`.

## What does not work / open
- The horn has not been heard (every run was headless or filmed without listening).
- The spine is a procedural strap, lighter than the sheet's heavy central body.

## Next steps
- To come.
