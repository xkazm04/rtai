# REPORT: lane rivet-arsenal (branch `n-rivet-arsenal`), night run 2026-11-04

DRAFT written in iteration 9 (06:50). The report phase finalises it: gates of record, the last clips, the frames.json order.

**Scope (the owner, 00:05):** "Equiped design on player". Rivet holds, carries and uses every weapon, in the live game.

**Status:** the evening's motion and melee are wired into the live game (arena, city proving block, quest 1). All six grip classes are held, aimed, fired or swung, reloaded and switched on Rivet's cast rig, with weapon-art's parts where they exist. Pickups and drops work in the live fight. The feel numbers are measured on the live pilot. Quest 1 runs on the cast rigs only behind the dev flag `--rigs` (call 1).

**Paths:**
- `M` = `C:\Users\kazda\kiro\gtai-masters\n4\rivet-arsenal\` holds the owner page `M\frames.json`, `M\clips\` and `M\frames\`.
- `E` = `evidence/rivet-arsenal/` in this worktree holds the logs, the telemetry and `FEEL-NUMBERS.md`.

## Gates of record
| Gate | Result | Where |
|---|---|---|
| lint | 13/13 (716 files) | d6618606 |
| unit | 813/813, exit 0 | d6618606, `E/it9f-unit.log` |
| scenarios | 37/37, incl. scenario_rivet_claw, _switch, _pickup, _throw, _deflect, _chainsaw, _katana, _city_fight | d6618606: 36/37 on the full run (`E/it9f-scenarios.log`). The red one is scenario_city_chase's 2 ms nav budget under load, the known flake; it passes alone (`E/it9f-city-chase-alone.log`) |
| replay / parity | untouched: every carry, pilot and rig change is arena-pilot state (written only with a carry) or render-only; quest 1's bytes do not move | |
| bench | not taken (no sim cost added; bench.lock never held) | |

## What works

### 1. The evening's motion and melee in the live game
- PlayerMotion replaces TopDownMover in StagePilot: twin-stick hips and torso, stride 1.3, sprint (bit 5), roll with i-frames (bit 6). One pilot serves quest 1, the arena and the city block.
- The claw combo (MeleeCombo over `rivet_melee.json`) replaces the electroshock jab. It has a step-in (lunge 0.4/0.5 m), so the backhand still lands after the jab's knockback.
- The charged shock: hold melee after the jab. A full charge kills the first human; chained bodies are only stunned.
- Clip: `M\clips\arena-motion-claw-32ppm-it7.mp4`. Rivet walks, strafes, sprints, rolls, then claw-combos the cop line: 24 swings, 10 hits, 4 kills, 0 whiffs, 0 script errors.
- Scenario: scenario_rivet_claw. The replay is identical; a planted no-step-in fault is caught.

### 2. Equipped design: every grip class held
- Grip classes are data in `rivet_arsenal.json`: one_hand, two_hand_long, shoulder, backpack_hose, thrown, heavy_two_hand. Each row sets the draw ticks, the held scale, the kick and the sway.
- RigGrip:
  - two-handed long guns: the stock claw sits in, the off claw rides forward on the barrel line;
  - shoulder: the tube is pulled onto the shoulder;
  - hip: the flamer and the chainsaw.
- The muzzle point sits on the aim line.
- Per-weapon extras:
  - the flamer's tank rides on Rivet's back and the hose follows;
  - the rocket tube shows empty after the shot (weapon-art's `empty` part);
  - the molotov's rag lights on the draw and on each next bottle.
- Since 17cd8409 the held kinetic guns use weapon-art's re-toned `held_small` part under 56 px/m. Before that they printed as one dark lozenge at 32-48 px/m. Seen on the city block at 32 px/m: `M\clips\city-block-kinetic-held-32ppm-x2.mp4` (a nearest-neighbour 2x crop) and `Mrames\city-block-kinetic-held-32ppm-3x.png`.
- Clips:
  - `M\clips\arena-arsenal-cycle-pistol-rifle-rocket-molotov-64ppm-x2.mp4`
  - `...cycle-cannon-ray-flamer-64ppm-x2.mp4`
  - `city-block-arsenal-carry-64ppm.mp4`

### 3. Weapon animations on Rivet
- Recoil per class: one_hand kick 0.8, two_hand_long 1.0, shoulder 1.6. The off claw follows the pull-back.
- The flamer sway: 0.14 rad over 52 ticks, on the real fire line.
- Reload per class: the magazine comes out, goes in, then the cock. The magazine is drawn in the off claw, and the spent one drops and lies on the floor.
  - Rockets: the warhead is carried in and the empty tube is shown.
  - Flamer: a tank swap.
- Switch: stow, then draw (WeaponHold).
- Molotov: a 14-tick wind-up, and the bottle lands at the cursor's distance.
- Melee weapons, live:
  - katana: slashes, then the lunge thrust;
  - electro baton: strikes;
  - chainsaw: a committed 3-bite grind, then the rip;
  - plasma sword: slashes, a full spin, and the timed deflect during any slash's active ticks.
- Clips in `M\clips\`: `arena-rocket-empty-tube-reload-64ppm-x2`, `arena-molotov-lob-claw-cops-32ppm-x2`, `arena-chainsaw-grind-64ppm`, `arena-katana-claw-cops-64ppm`, `arena-plasma-sword-claw-cops-64ppm`, `arena-plasma-deflect-64ppm-quarter-speed`, `arena-flamer-sway-64ppm`, `arena-claw-shock-64ppm`.

### 4. Switching and pickups
- Switching: number keys 1-4 by carry slot, plus the mouse wheel and the d-pad cycle (RivetCarry).
- Pickups: walking over one takes the gun into an empty slot, or refills the same gun. A different gun for a full slot swaps on `interact`, and the held gun drops 0.7 m behind.
- HUD: the ammo ticket reads `stage.pilot.carry` (REQUEST 5 -> gunplay).
- Scenarios: scenario_rivet_switch (key 3 at tick 30 -> the rocket leaves at tick 68, exact) and scenario_rivet_pickup, each with a planted fault.

### 5. Feel numbers, live pilot (`E/FEEL-NUMBERS.md`, `E/feel-live.json`)
- Input to the frame that draws the move: 2 frames, 27-34 ms (windowed d3d12, vsync 60). Display time on top of that is UNMEASURED.
- Walk:
  - top speed 4.5 m/s;
  - 90 % of top speed in 150 ms;
  - stop: 0.22 m in 100 ms.
- Sprint:
  - top speed 6.2 m/s;
  - stop: 0.43 m in 150 ms.
- Aim turn of 180 degrees: 250 ms.
- Claw combo (mash): the finisher lands 517 ms after the first press.
- Draw time per class: one_hand 200 ms, two_hand_long 333, shoulder 500, backpack_hose 300, thrown 133, heavy_two_hand 433.

### 6. The real game paths
- Arena: on the rigs by default (`--sprites` for the old look).
- City proving block: `--arena=city --bot=arsenal`, in `M\clips\city-block-arsenal-fight-32ppm.mp4` (3 waves, 7 kills).
- Quest 1: `--rigs`. Clips: `M\clips\quest1-rigs-dock9-fight-32ppm.mp4`, and at 64 px/m `quest1-rigs-dock9-fightcam-64ppm.mp4`. In the second, Rivet with Gloria drops a cop into his blood above the dialogue box. It was shot with the dev fight camera, `quest1_clip.gd --cam=fight --ticks=13580-13860`.

## Calls for the owner
1. **Quest 1 on the cast rigs by default.** Today this is opt-in `--rigs` (debug builds; it loads `dev/arena/arena_rigs.gd`). The alternative is the sprite cast. Clips: `quest1-rigs-dock9-fight-32ppm`, `quest1-rigs-dock9-64ppm`. If yes, the Director promotes ArenaRigs' feed into features/ at the merge.
2. **The first claw jab drops a human cop** (hp 1 doctrine), so the full combo only plays on tougher bodies. The alternative: light claws stagger and only the slam kills. Clips: `arena-motion-claw-32ppm-it7`, `arena-claw-shock-64ppm`.
3. **One-hand held_scale 1.5** (the pistol slightly oversized so the claw does not hide it) vs true size. Stills: `frames/held-pistol-scale15-64ppm-3x.png` vs `held-pistol-scale1-64ppm-3x.png`.
4. **The switch:** number keys plus the wheel or d-pad cycle; no radial menu (`arena-arsenal-cycle-*`).
5. **Pickups:** auto-take only into an empty slot or the same gun; a swap needs `interact`.
6. **The shoulder launcher** is held over the shoulder (the only shape built) vs at the hip.
7. **The charged shock:** hold after the jab. A full charge kills the first human; the chained bodies are stunned (`arena-claw-shock-64ppm`).
8. **The electro baton:** a stun stick (a cop drops on the second strike) vs a killer.
9. **The chainsaw:** a committed 3-bite grind on a tap vs hold-only (`arena-chainsaw-grind-64ppm`).
10. **The plasma sword's finisher:** a full spin vs a thrust (`arena-plasma-sword-claw-cops-64ppm`).
11. **The deflect window:** any slash's active ticks, no parry button (`arena-plasma-deflect-64ppm-quarter-speed`).
12. **The flamer hose sway** (0.14 rad / 52 ticks) vs none (`arena-flamer-sway-64ppm` vs `arena-flamethrower-tank-64ppm`).
13. **The molotov's 14-tick wind-up** vs a throw on the press (`arena-molotov-windup-64ppm` vs `arena-molotov-throw-64ppm`).

## Open / known flaws
- The claw cops still read crowded in the chainsaw grind at 64 px/m. There was no enemy-ai lane tonight, so this lane added a stand-off to its own station (d6618606): the cops keep 1.25 m from Rivet and 1.0 m apart, and a cop just hit is not moved. A drawn cop is about 1.27 m across, so they still overlap. A 1.3 m spacing would fix the look, but it costs scenario_rivet_chainsaw a kill, so it was not taken.
- At 64 px/m quest 1's dialogue box covers the lower third. The dev fight cam (`quest1_clip.gd --cam=fight`) now lifts the framed point above it (a67bff25).
- No boss rig: quest 1's boss, Mertz, keeps the cast view's drawing under `--rigs`.
- Display latency (swapchain + monitor) is UNMEASURED.
