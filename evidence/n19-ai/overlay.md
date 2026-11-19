# Arena wave visibility and city station check

## Wave bodies

Pit horde, squad, seed 20261103, 60 Hz, combo, 32 px/m, camera (17, 20). A render-frame observer sampled every distinct sim tick 1 through 1290 from the arena scene. It joined each living ArenaPit.standing fighter to its visible full rig, robot rig or textured fallback sprite by fighter id. Shots below are newly emitted hostile projectiles, attributed by their owner. The HUD letter was sampled at the body anchor in the actor canvas. Rivet and all wave positions, identities, locomotion states and shot events matched at every tick across the two runs.

At b80926cc8, 2232 of 3714 hostile-ticks had no visible rig or replacement body. IDs 9 and 17 fired 5 rounds while undrawn. After the fix, 1482 hostile-ticks drew a full rig and 2232 drew a card. Zero lacked a body and zero had both. The full-rig selector keeps up to 16 people within 14 m of the moving focus. The arena hid its sprite cast and previously supplied no distant representation for wave fighters.

Ranges below cover only ticks when the full rig was absent. The replacement card covers exactly those same ticks at 42fe4a733. Counts include living fighters outside the camera crop. Coordinates are world metres.

| Fighter | Archetype | Ticks without rig | First / last tick | Minimum x, y | Maximum x, y | Shots on those ticks |
|---|---|---|---|---|---|---|
| 1 | contractor | 151 | 98 / 248 | 13.97, 26.71 | 15.75, 31.41 | 0 |
| 2 | contractor | 179 | 98 / 276 | 30.89, 8.57 | 33.15, 11.36 | 0 |
| 3 | contractor | 131 | 98 / 228 | 30.3, 19.1 | 32.95, 21.44 | 0 |
| 4 | contractor | 268 | 98 / 365 | 15.13, 27.97 | 21.44, 32.26 | 0 |
| 5 | contractor | 158 | 495 / 992 | 24.07, 4.03 | 33.38, 10.15 | 0 |
| 6 | contractor | 30 | 495 / 556 | 28.19, 15.62 | 30.58, 16.64 | 0 |
| 7 | contractor | 98 | 495 / 592 | 19.73, 26.8 | 20.33, 30.32 | 0 |
| 8 | contractor | 242 | 495 / 736 | 2.65, 24.57 | 6.23, 27.84 | 0 |
| 9 | contractor | 275 | 495 / 785 | 13.83, 26.97 | 16.87, 31.81 | 505, 512, 768, 775 |
| 10 | contractor | 2 | 495 / 496 | 28.78, 11.08 | 28.78, 11.08 | 0 |
| 11 | contractor | 2 | 1186 / 1187 | 31.3, 16.76 | 31.3, 16.76 | 0 |
| 12 | contractor | 105 | 1186 / 1290 | 17.97, 28.09 | 19.52, 31.12 | 0 |
| 13 | contractor | 105 | 1186 / 1290 | 2.33, 26.59 | 2.45, 31.12 | 0 |
| 14 | contractor | 105 | 1186 / 1290 | 11.85, 26.29 | 12.44, 30.27 | 0 |
| 15 | contractor | 105 | 1186 / 1290 | 32.58, 8.34 | 33.42, 12.64 | 0 |
| 16 | contractor | 105 | 1186 / 1290 | 32.32, 17.55 | 33.48, 21.84 | 0 |
| 17 | contractor | 66 | 1186 / 1267 | 22.34, 24.94 | 22.55, 28.26 | 1261 |
| 18 | contractor | 105 | 1186 / 1290 | 1.75, 25.17 | 3.99, 28.32 | 0 |

### Reported frame at tick 536

The original ae6266c3a label baseline was the projected foot plus (9, 10) pixels. The null-rig filter present at b80926cc8 suppressed five of these six labels. In the one full-rig case the projected foot and the rig origin both measured (982.23, 143.71) px. Full-rig coordinates below are local pixels. Screen columns are pixels in a 1280 x 800 viewport. The new glyph is centered on its card or rig with baseline offset (-6, 6) from the anchor.

| ID / state | Sim x, y (m) | Full-rig node | Foot on screen | Original label baseline | New label anchor | New body | Focus distance (m) |
|---|---|---|---|---|---|---|---|
| 5 / C | 33.22, 8.87 | none | 1159.15, 65.41 | 1168.15, 75.41 | 1159.15, 40.71 | card | 19.57 |
| 6 / C | 29.13, 15.88 | none | 1028, 275.96 | 1037, 285.96 | 1028, 244.35 | card | 14.94 |
| 7 / E | 20.07, 29.4 | none | 738.32, 682.69 | 747.32, 692.69 | 738.32, 653.06 | card | 16.53 |
| 8 / E | 4.04, 26.33 | none | 225.38, 590.19 | 234.38, 600.19 | 225.38, 562.55 | card | 16.11 |
| 9 / E | 14.42, 30.22 | none | 557.36, 707.37 | 566.36, 717.37 | 557.36, 681.71 | card | 16.31 |
| 10 / F | 27.69, 11.48 | 886.23, 367.27 | 982.23, 143.71 | 991.23, 153.71 | 982.23, 120.03 | rig | 13.6 |

## Sparring partners in the street

Matched arena runs use the normal pit bot, squad, seed 20261103, camera (540, 543), tick 697, 32 px/m. Both station frames use the repaired executable at 42fe4a733. Before uses the arena table from the parent of f20a377ac. After uses the committed table at 42fe4a733. The original b80926cc8 runs returned the same station positions and clearances. No other input changed. Distances are from the centre to the closest solid edge, including city cells and arena station boxes. The guard radius is 0.45 m.

| ID | Home x, y | Before home clearance / prop | After home clearance / prop | Before standing x, y / closest | After standing x, y / closest | Rivet distance before / after |
|---|---|---|---|---|---|---|
| 3000 | 526, 528.4 | 2.51 m pit/0 | 5.39 m pit/0 | 532.67, 536.87 / 0.66 m pit/11 | 530.36, 535.56 / 1.26 m pit/1 | 6.78 / 9.43 m |
| 3001 | 530, 528.4 | 2.3 m pit/1 | 5.3 m pit/1 | 530.43, 536.15 / 1.31 m pit/5 | 530.11, 536.67 / 0.91 m pit/5 | 9.03 / 9.05 m |
| 3002 | 534, 528.4 | 2.3 m pit/1 | 5.3 m pit/1 | 533.21, 537.71 / 1.46 m pit/11 | 529.43, 535.94 / 0.7 m pit/5 | 5.85 / 10 m |
| 3003 | 537, 528.4 | 2.3 m pit/1 | 5.3 m pit/1 | 531.5, 537.21 / 1.7 m pit/11 | 529.77, 534.75 / 0.45 m pit/1 | 7.57 / 10.38 m |
| 3004 | 538.8, 528.4 | 2.3 m pit/1 | 5.3 m pit/1 | 531.7, 536.23 / 1.2 m pit/11 | 528.84, 535.13 / 0.84 m pit/1 | 7.94 / 10.93 m |

Both runs clustered all five on the approach. At tick 697, all five had a clear line of sight and were within GuardBrain engagement range (12 m) in both runs. The wall move changed the positions where they settled and increased home clearance. Guard 3003 touched pit/1 at tick 697 and moved 2.5 m by tick 1459. Homes and station rules stay as shipped. Both logs report the same five unrelated city spawn drops, all outside this station.

Matched PNGs under the n19/ai masters folder are a6-checks/station-before-a5-t0697.png and a6-checks/station-after-a5-t0697.png.

## Films and selected stills

Rendered from 42fe4a733 with the film kit on D3D12 at (0, 1440), 1280 x 800, fixed 60 Hz, 32 px/m. The close-up uses 64 px/m. Each launch checked that the current worktree project was clean and its HEAD equalled the pinned commit. Street twins use the same camera, pit bot, horde schedule and seed. Only the enemy brain differs. The mixed film uses normal pit waves and shows patrol, riot, SWAT, robot thug and robot gunner alongside the contractor.

| MP4 under n19/ai | Seed | Camera (m) | Labels | Frames | Seconds | Full-rig ticks | Card ticks | Missing body ticks |
|---|---:|---|---|---:|---:|---:|---:|---:|
| films/street-squad.mp4 | 20261104 | 536,544 | on | 1440 | 24 | 2576 | 3507 | 0 |
| films/street-guard.mp4 | 20261104 | 536,544 | on | 1440 | 24 | 3125 | 3427 | 0 |
| films/pit-squad.mp4 | 20261103 | 17,20 | on | 1290 | 21.5 | 1482 | 2232 | 0 |
| films/pit-mixed.mp4 | 20261103 | 14.5,20.5 | off | 2250 | 37.5 | 3402 | 667 | 0 |

Across the four MP4s, all 20,418 living hostile-ticks had exactly one body. The per-fighter counts, positions and shots outside the full-rig pool are in [wave-visibility.csv](wave-visibility.csv). I verified each encoded MP4 with ffprobe. The pose observer recorded every living wave member on every tick of each shot. Production film-probe positions and life flags matched the observer on the film probe collection windows. Guard has no squad archetype and uses G for its baseline locomotion. Counts in frames.json are for the living wave. The 64 px/m entry also gives the crop count.

The [frames.json catalogue](frames.json) has nine stills in viewing order, with relative paths and same-tick guard twins. E is engage, C cover and F flank. Cover uses pale green (#b4e08a), flank gold, engage cream, panic lavender and guard white. Unknown states draw a white question mark. The first city framing put the western flank under the ghost selector. The published camera is 4 m farther west. I inspected each selected PNG at its output resolution. I also moved the mixed-wave camera west to keep the robot gunner clear of the HUD, and removed the preliminary captures and obsolete masters.

The raw before/after render samples are in the masters under a6-checks/ as compressed NDJSON. Each line is [tick, wave, station, Rivet x, Rivet y]. Wave columns are id, archetype, sim xy (m), projected foot xy (px), full-rig local xy (px) or null, full-rig screen foot or null, representation, locomotion letter, fired, metres from rig focus, distance rank and, after the fix, label centre (px, null for an unlabelled shot) and combat action. Station samples list id, standing x/y, clear sight, Rivet distance, closest solid at standing and at home.

## Validation

- Full lint passed all 19 checks over 1,628 GDScript files. The quick gate passed on all eight changed GDScript files. The requested standalone check returned `ok res://features/arena/squad_overlay.gd`.
- The arena rig, squad and squad-budget GUT suites passed 27/27. The new regression test moves a guard outside, inside and back outside the full-rig radius, then kills it. It checks the rig/card handoff and removal.
- The headless scenarios passed 5/5 (arena_city, arena_pit, arena_stations, arena_squad and arena_zebra). The pit and city telemetry and station report matched their A5 baseline files byte for byte.
- Removing the appended squad overlay flag from the final launch_args.gd gives the exact f20a377ac file. Restoring the existing comment raised the debt ceiling for that file from 202 to 203 lines. The baseline records the reason.
- The film kit passed seven shots. The nine retained PNGs and four MP4s matched the verified source files by SHA-256, and the published and committed manifests matched byte for byte.
- The city renderer still logs the pre-existing rig_cast_shadows.gd triangulation diagnostic. Before and after runs also logged resource cleanup diagnostics at shutdown. The published captures completed with zero script errors.
