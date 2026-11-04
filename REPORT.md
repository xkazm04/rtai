# REPORT: lane rivet-arsenal (branch `n-rivet-arsenal`), night run 2026-11-04

Final for the night (iteration 10, 07:20-08:10; iteration 11 added the n-weapon-art merge to ceee3a88, which makes Gloria draw her own art, and the long guns beside the helmet). The branch tip carries the merged n-gunplay (b11fa9e2) and n-weapon-art (ceee3a88) work; nothing is pushed.

**This file (iteration 17, the REPORT phase, 08:40)** is the lane-root copy of `docs/night/2026-11-04/rivet-arsenal/REPORT.md`. It adds two sections at the end: **Blocked** and **Next steps**. Iterations 12-16 changed no code: `git diff 8a7fd9a1..HEAD -- project tools` is empty, so the gates of record below describe this tip exactly. At 08:40 I checked every `M\` and `E/` path this report cites, and all of them exist.

**Read first:** call 1 (quest 1 on the cast rigs), then the owner page `M\frames.json` top to bottom (newest and best first).

**Scope (the owner, 00:05):** "Equiped design on player". Rivet holds, carries and uses every weapon, in the live game.

**Status:** the evening's motion and melee are wired into the live game (arena, city proving block, quest 1). All six grip classes are held, aimed, fired or swung, reloaded and switched on Rivet's cast rig, with weapon-art's parts where they exist. Pickups and drops work in the live fight. The feel numbers are measured on the live pilot. Quest 1 runs on the cast rigs only behind the dev flag `--rigs` (call 1).

**Paths:**
- `M` = `C:\Users\kazda\kiro\gtai-masters\n4\rivet-arsenal\` holds the owner page `M\frames.json`, `M\clips\` and `M\frames\`.
- `E` = `evidence/rivet-arsenal/` in this worktree holds the logs, the telemetry and `FEEL-NUMBERS.md`.

## After 09:00 (extension, iteration 18)
- **Fixed: the long guns and tubes on the helmet at 64 px/m** (the 08:40 open flaw). The cause, measured on the real rig (`test_rivet_aim_clear`): **aimed**, the barrel line started 0.3 of the way to the gun shoulder and ran 47 px off the helmet's centre, inside its 78 px half-width. The BESIDE 0.85 shift partly hid this by pushing the weapon to the far side, off the claw. Now the line starts 0.42 out (`RigGrip.GUN_SIDE_BY`), the helmet leans 24 part px off the stock while aiming (`RigGrip.head_lean`), and BESIDE is 1.0. The line is 90 px off the helmet's centre. The weapon lies along the claw arm, the helmet is clear, and the stock sits on the collar and shoulder. Commits 97b91ffb and 09ef1958.
  - Clip: `M\clips\arena-pit-aimed-long-guns-off-helmet-ab-64ppm.mp4` (before | after, 13 s). Detail sheet: `M\frames\arena-pit-aimed-long-guns-off-helmet-ab-64ppm-3x.png`. These are frames.json entries 4 and 5; they replace the two clips of the superseded code.
  - Tried and refuted, not committed: a shoulder-carry claw pose for the **unaimed** carry. The A/B render was near identical, because Rivet aims in almost every pit frame and the carried claw already hangs 170 px out.
- **The city melee at 48 px/m, following Rivet** (the 04:00 readability rule): `M\clips\city-block-melee-katana-chainsaw-48ppm-follow.mp4` (11 s, `--arena=city --rigs --bot=arsenal --loadout=katana,chainsaw,electro_baton --ppm=48`, 0 script errors). The katana and the chainsaw drop cops who stand alone, and the aftermath stays in frame. The hub's lab-cop rows (the first 840 frames) are cut. This is now frames.json entry 1; the 32 px/m 2x-crop version moved to entry 2, and the cannon/ray/flamer cycle fell off the 15. Stills: `M\frames\city-block-melee-kills-48ppm.png`.
- **The long guns in the live city at 48 px/m:** `M\clips\city-block-long-guns-aimed-48ppm-follow-x2.mp4` (17 s, `--loadout=plasma_rifle,rocket_launcher --ppm=48`, 0 script errors), frames.json entry 3. The aimed-line fix holds on the city block: the weapon lies along the claw arm and the helmet is clear. The pistol/rifle/rocket/molotov arena cycle fell off the 15.
- **The pistol, the flamethrower and the molotov in the live city at 48 px/m** (iteration 19): `M\clips\city-block-pistol-flamer-molotov-48ppm-follow-x2.mp4` (19 s, `--arena=city --rigs --bot=arsenal --loadout=hand_cannon,flamethrower,molotov,pistol --ppm=48`; the pistol took the one-hand slot, 2 waves, 3 kills, 0 deaths, 0 script errors, code of 09ef1958), frames.json entry 4. The flamer's tank rides on Rivet's back with the hose to the nozzle, and the molotov's lit rag shows in the wind-up. With entries 1 and 3, every grip class now has a 48 px/m follow clip in the live city. Sheet: `M\frames\city-block-pistol-flamer-molotov-48ppm-sheet.png`; 2x detail: `...-48ppm-2x.png`. The superseded 08:00 beside-head sheet left the 15.
- **The one-hand guns in the live city at 48 px/m**: `M\clips\city-block-one-hand-guns-48ppm-follow-x2.mp4` (30 s: the machine pistol, then the hand cannon, each a separate run with `--ppm=48`; 0 script errors), frames.json entry 5. It replaces the 32 px/m kinetic-held entry. Brass lands on the pavement, and a cop goes down in red blood by the kerb car. Flaws: in the machine pistol's aftermath Rivet stands over the corpse, and at about 25 s a cop at point-blank overlaps his body (call 14).
- **Gates of record, now 09ef1958:** lint 13/13 (720 files), unit 823/823 exit 0, scenarios 38/38 exit 0 (`E/it18-lint.log`, `E/it18-unit.log`, `E/it18-scenarios.log`). Render only: no replay or parity golden moved. No bench.

## Gates of record
| Gate | Result | Where |
|---|---|---|
| **iteration 11 (the tip's code, 8a7fd9a1: the n-weapon-art merge 552add84 + long guns beside the helmet)** | lint 13/13 (719 files), unit 821/821 exit 0, scenarios 38/38 exit 0 | `E/it11-lint.log`, `E/it11-unit.log`, `E/it11-scenarios.log`. The lint log shows a first red run (a long comment line and `_process` over 40 lines). It was fixed before the commit, and the pre-commit hook passed 13/13 on 8a7fd9a1. Evidence run on the same code (`E/it11-evidence.log`, `--no-bench`): lint PASS, scenarios 38 PASS, parity bit-exact (mutation caught at step 629) PASS. Unit shows 821 passed, 0 failed, but the runner flags it FAIL because I edited REPORT and JOURNAL during the run ("tree changed during run"); this is not a test failure. The selftest has look goldens 11/11 and block goldens 5/5, but exits 1 on the accent audit: the same NEW findings as in iteration 10 (48 px/m vermilion on vehicles 8 px, 64 px/m vermilion on cop 28 px), gunplay's blood-flicker class. The rows below are iteration 10's. |
| lint | 13/13 (717 files) | 37dbfeab and c55b6984 (the last code change: the bot slides round props; the rivet scenarios 9/9 on it, `E/it10d-rivet-scenarios.log`; no other scenario or unit test drives that bot) |
| unit | 814/814, exit 0 | 8a1537df (the branch tip's code), `E/it10e-unit.log` |
| scenarios | 38/38, exit 0, incl. scenario_rivet_claw, _switch, _pickup, _throw, _deflect, _chainsaw, _katana, _city_fight and the new _city_melee | 8a1537df, `E/it10e-scenarios.log` |
| evidence run | lint, unit 814, parity bit-exact (mutation caught at step 629) PASS. Scenarios 36/37 in that run: scenario_rivet_deflect failed because the run overlapped the bot edit; it was fixed in 37dbfeab and passes in the scenario row above. The selftest has look goldens 11/11 and block 5/5, but exits 1 on the accent audit: the known blood-flicker vermilion class, the same findings as on n-gunplay (gunplay's) | 4cc6e8a0, `E/it10-evidence.log` |
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
- Since 17cd8409 the held kinetic guns use weapon-art's re-toned `held_small` part under 56 px/m. Before that they printed as one dark lozenge at 32-48 px/m. Seen on the city block at 32 px/m: `M\clips\city-block-kinetic-held-32ppm-x2.mp4` (a nearest-neighbour 2x crop) and `M\frames\city-block-kinetic-held-32ppm-3x.png`.
- Since the n-weapon-art merge of iteration 10 (8465d548), every held weapon but three (molotov, plasma sword and flamethrower, which already print light) uses `held_small` under 56 px/m: the long guns, both tubes (incl. the empty tube) and the melee weapons. Seen on the city block at 32 px/m in a live fight (plasma rifle, ray gun, rocket launcher, electro gun; 3 waves, 7 kills, 8 switches, 0 deaths, 0 script errors): `M\clips\city-block-long-guns-held-32ppm-x2.mp4` and `M\frames\city-block-long-guns-held-32ppm-3x.png`. The rocket tube reads light with its warhead. The electro gun still prints mostly dark at 32 px/m (weapon-art's call 14). The teal tip next to a long barrel is Rivet's torch forearm, his one doctrine teal; it shows when the off arm rides the barrel.
- Since 8a7fd9a1 (iteration 11) the long guns and both tubes ride **beside the helmet**, not across his face. Before, weapon-art's 32 px/m claw lineup (tick 394) showed the rocket launcher, the mini-nuke and the plasma rifle lying along the claw straight over his head, with the nuke covering the face: seen from above, the claw closes just in front of the helmet.
  - The held view now shifts a two-hand-long or shoulder weapon sideways until its axis clears the helmet on the gun side (`RivetCarryAngle.beside_head`, BESIDE 0.85).
  - A long gun that is carried but not aimed eases across the front of the body (ACROSS_RAD 1.2).
  - Same-tick before and after: `M\frames\arena-pit-long-guns-beside-head-ab-32ppm-3x.png`. In motion: `M\clips\arena-pit-tubes-beside-head-32ppm-x2.mp4`. Looked at: the helmet and the vermilion collar read beside the tube in every frame. Superseded after 09:00 by the aimed-line fix (see "After 09:00").
  - It is render only, with `test_rivet_carry_angle` 6/6 (the planted BESIDE 0 fails 2).
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
- On the city block (since 37dbfeab): with a melee weapon drawn, the arsenal bot closes into claw reach and swings there. Before that, it held gun reach and cut air (407 swings, 0 hits in 15 s). The live fight: `M\clips\city-block-melee-katana-chainsaw-baton-32ppm-x2.mp4` (30 s, 3 waves, 5 cops dead in red blood, 0 deaths, 0 script errors) and `M\frames\city-block-melee-32ppm-3x.png` (the chainsaw grind, the katana pinning a cop on a kerb car). Close-up at 64 px/m: `M\clips\city-block-melee-64ppm.mp4` (10 s, 2 kills) and `M\frames\city-block-melee-64ppm-2x.png` (the baton, the katana over a dead cop, the chainsaw grind as a cop falls). Scenario: scenario_rivet_city_melee (2 guards in 30 s, the replay identical, the planted stand-off drops none).
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
- The thrown and hose classes on the city block: `M\clips\city-block-molotov-burn-32ppm-x2.mp4` and `M\frames\city-block-molotov-burn-32ppm-3x.png`. The run is 30 s: 2 waves, 4 cops dead in red blood, 0 deaths. The clips show the flamer carried on its back tank, the molotov's lit rag and throw, a guard ablaze next to the plasma sword, and two cops dead by a kerb car. Its "before" (`...-x2-before.mp4`, the same seed) stalls pressed on a crate after wave 1. Close-up at 64 px/m: `M\clips\city-block-flamer-molotov-64ppm.mp4` (10 s of a 4-kill run) and `M\frames\city-block-flamer-molotov-64ppm.png`, showing the hose's flame stream with the tank on Rivet's back and a guard ablaze.
- City proving block: `--arena=city --bot=arsenal --loadout=...`. Three live fights: the kinetic guns (`city-block-kinetic-held-32ppm-x2`), the long guns and the tube (`city-block-long-guns-held-32ppm-x2`: 3 waves, 7 kills) and the melee weapons (`city-block-melee-katana-chainsaw-baton-32ppm-x2`: 3 waves, 5 kills).
- Quest 1: `--rigs`. Clips: `M\clips\quest1-rigs-dock9-fightcam-32ppm.mp4` (8.3 s: both cop waves die in red blood) and, at 64 px/m, `quest1-rigs-dock9-fightcam-64ppm.mp4`. In the second, Rivet with Gloria drops a cop into his blood above the dialogue box. It was shot with the dev fight camera, `quest1_clip.gd --cam=fight --ticks=13580-13860`.

## Calls for the owner
1. **Quest 1 on the cast rigs by default.** Today this is opt-in `--rigs` (debug builds; it loads `dev/arena/arena_rigs.gd`). The alternative is the sprite cast. Clips: `quest1-rigs-dock9-fightcam-32ppm`, `quest1-rigs-dock9-fightcam-64ppm`. If yes, the Director promotes ArenaRigs' feed into features/ at the merge.
2. **The first claw jab drops a human cop** (hp 1 doctrine), so the full combo only plays on tougher bodies. The alternative: light claws stagger and only the slam kills. Clips: `arena-motion-claw-32ppm-it7`, `arena-claw-shock-64ppm`.
3. **One-hand held_scale 1.5** (the pistol slightly oversized so the claw does not hide it) vs true size. Stills: `frames/held-pistol-scale15-64ppm-3x.png` vs `held-pistol-scale1-64ppm-3x.png`.
4. **The switch:** number keys plus the wheel or d-pad cycle; no radial menu (`arena-arsenal-cycle-*`).
5. **Pickups:** auto-take only into an empty slot or the same gun; a swap needs `interact`.
6. **The shoulder launcher** is held over the shoulder (the only shape built) vs at the hip. Since 8a7fd9a1 the tube rides beside the helmet. The other option for long guns at rest is to carry them along the claw (ACROSS_RAD 0, one value in `rivet_carry_angle.gd`) rather than across the chest. Before and after: `frames/arena-pit-long-guns-beside-head-ab-32ppm-3x.png`.
7. **The charged shock:** hold after the jab. A full charge kills the first human; the chained bodies are stunned (`arena-claw-shock-64ppm`).
8. **The electro baton:** a stun stick (a cop drops on the second strike) vs a killer.
9. **The chainsaw:** a committed 3-bite grind on a tap vs hold-only (`arena-chainsaw-grind-64ppm`).
10. **The plasma sword's finisher:** a full spin vs a thrust (`arena-plasma-sword-claw-cops-64ppm`).
11. **The deflect window:** any slash's active ticks, no parry button (`arena-plasma-deflect-64ppm-quarter-speed`).
12. **The flamer hose sway** (0.14 rad / 52 ticks) vs none (`arena-flamer-sway-64ppm` vs `arena-flamethrower-tank-64ppm`).
13. **The molotov's 14-tick wind-up** vs a throw on the press (`arena-molotov-windup-64ppm` vs `arena-molotov-throw-64ppm`).

14. **Melee bodies overlap the art.** A cop in claw contact stands 1.2 m from Rivet. The drawn rigs are wider than the sim bodies (Rivet radius 0.6 vs about 0.84 drawn half-width; cop 0.45 vs about 0.64), so in a chainsaw grind the bodies overlap on screen. The options:
    - accept it as a brawl read;
    - grow the human sim radius toward the drawn size. That is a `combat.json` value and moves every lane's fights, so it is a Director call at the merge.

    Clip: `arena-chainsaw-grind-64ppm`. A ring wide enough to clear the art (about 1.5 m) makes the claw whiff, so it was not taken.

## Open / known flaws
- The arsenal bot's melee walk-in on the city block is a straight line that slides round a prop in the way (c55b6984), not a nav path. This lifted the flamer, molotov and sword run from 2 to 4 kills in 30 s, but a building corner can still hold it. It affects the bot only: a player walks round.
- The claw cops still read crowded in the chainsaw grind at 64 px/m. There was no enemy-ai lane tonight, so this lane added a stand-off to its own station (d6618606): the cops keep 1.25 m from Rivet and 1.0 m apart, and a cop just hit is not moved. The drawn rigs are wider than the sim bodies, so in contact they still overlap (call 14). scenario_rivet_chainsaw's ">= 3 kills" bar is met only because two hp-4 cops stand stacked and one grind kills both. A wider spacing separates them and drops the count to 2. The bar was left unchanged.
- At 64 px/m quest 1's dialogue box covers the lower third. The dev fight cam (`quest1_clip.gd --cam=fight`) now lifts the framed point above it (a67bff25).
- No boss rig: quest 1's boss, Mertz, keeps the cast view's drawing under `--rigs`.
- Display latency (swapchain + monitor) is UNMEASURED.
- FIXED after 09:00 (09ef1958; see "After 09:00"): the plasma rifle clipping the helmet's rim at 64 px/m. The cause was the aimed line starting under the helmet (GUN_SIDE 0.3), not the carry pose. Diagonal aims still lay the stock over the collar and gun shoulder, which reads as a shouldered weapon.

## Blocked
- Nothing blocked the lane for more than a few minutes; JOURNAL has no BLOCKED entry. The FRICTION that cost time:
  - The arena dev args (`--ppm`, `--loadout`, `--bot`, `--shot`) only parse when `res://dev/arena/arena.tscn` is passed as the scene. This cost two wasted renders (01:xx-02:05 and again at 05:xx).
  - The arena range dummies go unexposed after a hit, so the claw combo needed its own cop station. That cost about 15 minutes (01:13).
  - The REPORT's form-feed trap: a Windows path such as `M\frames` written through a shell string turns `\f` into byte 0x0C. It cost about 10 minutes.
- Time: iterations 12-16 (about 08:00-08:40) were short pre-freeze or stabilize sessions. The full gates take about 10 minutes on the loaded machine and could not finish before the 08:30 freeze, so no code moved after 8a7fd9a1.
- No bench was taken (bench.lock was never held); this lane added no sim cost.

## Next steps
1. **The Director:** call 1, quest 1 on the cast rigs by default, is the lead call. If the answer is yes, promote ArenaRigs' feed from `dev/arena/` into `features/` at the merge.
2. Done after 09:00: the long guns beside the helmet (see "After 09:00").
3. **The arsenal bot's melee walk-in:** a nav-grid path instead of the straight line that slides round props.
4. **Call 14** (the human sim radius vs the drawn rig width) and the scenario_rivet_chainsaw ">= 3 kills" bar stay for the owner and the Director.
5. **A boss rig for Mertz** under `--rigs`, and a measurement of display latency (swapchain + monitor).
6. **The untracked `evidence/rivet-arsenal/*` scenario outputs** at the tip are regenerated by every scenario run. They were left untracked on purpose (see JOURNAL iteration 13).
