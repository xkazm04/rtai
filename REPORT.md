# n10 rivet REPORT (draft, it13, 00:35; the freeze session replaces this)

Defect hunt on Rivet at combo. Every performance number here is CONTENDED. Evidence: `C:\Users\kazda\kiro\gtai-masters\n10\rivet\` (`frames.json`, 7 entries, best first).

## Fixed

| # | Defect | Cause | Fix | Test | Evidence |
|---|---|---|---|---|---|
| 1 | A speaking ghost stood on Rivet's head through quest 1's dialogue | Its spot is his facing's own left, which points up the screen when he faces right, onto his 1.65 m figure | `GhostApparition.side_of` sends an up-screen side to the screen's left under a tilt; `--ghost-voice=facing` is the old spot; top view untouched | `test_ghost_apparition_side.gd` (5) | `rivet_ghost_voice_before_after_combo_{48,32}ppm.png` |
| 2 | After every roll he stood bare-clawed for 10 ticks, then the gun popped back | `ArenaRigs._rivet_clips` hid the gun on `phase != FREE`, which includes the recovery | Only the ROLL phase hides it | `test_arena_rigs_roll_gun.gd` (3) | `rivet_roll_recovery_gun_before_after_combo_64ppm.png` (64 px/m only) |
| 3 | A pop inside a burst: the fire cell showed for one tick, then the facing cell for the rest of the latch | The pose ran before the fire latch rose, and a 45 degree shot sits on `GUN_TOL` | `RivetFrames.publish` re-poses on the rising latch; `RivetStrips.FIRE_HOLD` keeps a burst already drawing its cell | `test_rivet_frames.gd` (2) | tour log, pistol octant 1 |
| 4 | Fired up the screen or on the upper diagonals, the flash sat on his helmet | Facing cells had no muzzle point | `tools/art/rivet_muzzle.py` measures facing cells 1/3/4; 158 points in `rivet_muzzle.json`, each checked by eye at p70 and p55 | `test_rivet_muzzle.gd` (2) | `rivet_gun_muzzle_{pistol,rocket}_before_after_combo_64ppm.png` |
| 5 | With 4 alone the flash left the gun and the tracer still left his middle | The tracer starts on the sim line | `ShotLift.to_muzzle` starts a lifted round on the tip and lets go by `CONVERGE_M`; top view untouched | `test_shot_lift.gd` (2) | as above |
| 6 | A shot changed his size: gloria, plasma rifle, mini-nuke and flamer (p70 and p55), machine pistol and electro gun (p55) drew him 11-29 % small on every fire cell, the plasma sword (p70) 21-26 % big on its strike, so a burst popped smaller and back | The cutter scales each action band by a helmet ratio its measure gets wrong; only the blades had a hand `act_k` | `act_k` per strip in `tools/art/rivet_frames.json`, set from the strip's own helmet and read by eye; muzzle table re-measured | `test_rivet_cell_scale.gd` (red on the old strips, helmets 0.71-0.88 / 1.21-1.26; green now) | `rivet_gloria_shot_size_before_after_combo_64ppm.png`, `rivet_plasma_sword_strike_size_before_after_combo_64ppm.png` |
| 7 | With the baton on the left (octants 3-5, p70) he stood 25 px up and about 15 % small | The strip was cut on the baton's tip, which hangs below his feet | `feet_up` per figure in the cut, `RivetStrips.FOOT_PX` 35 | same test, foot line | `rivet_baton_left_before_after_combo_64ppm.png` |
| 8 | A left swing of the baton at p70 drew nothing at all (no strike cell, no arc, no smear) | The three-cell left strip has no strike and `hides_held` kept the smear off | `LEFT_NO_SWING`: under a left strip the game smear runs, as p55's `NO_ARC` already does | same test | same frame (the crescent is a Call below) |
| 9 | The gatling's barrel whirl, the only thing it shows for its spin-up, sat on the ground beside the gun | Its side facing (cell 2) had no muzzle point, so `WeaponFxSpin` used the fallback spot | Cell 2 measured for the gatling (`GUN_FACE_SPIN`) | `test_the_barrels_spin_up_on_the_drawn_gun` | tour log and `gat_pts` strip check (not a before/after) |

## Brief status

1. **Walk all 17 weapons:** done for walk, run, stand, fire, reload and 8 octants. The tour ran for all 17 at 64 px/m and at 48 px/m (arena, combo, 0 SCRIPT ERROR, logs clean of mirrored one-handers and base strips, the only `fire no muzzle` rows are blades, the molotov and the one-handers' octant 1, which are Known). All 17 contact sheets were read by eye (the 12 left over this iteration found defects 6, 7, 8). Knock-down and get-up are not in the tour: the n9 knock film stands, and the strip wins over the reload in `RivetFrames.step`, read in code, not filmed with a gun up.
2. **Quest 1 start to end at 1.65 m:** done once at 48 px/m through the scripted pad (`dev/frames/quest1_clip.gd --rigs --view=combo`, 84 stills every 240 ticks to the end at tick 18996, 0 SCRIPT ERROR). That is stills every 4 s, read as contact sheets plus three full-size crops, so a clip shorter than 4 s can have been missed. Nothing clipped a door or prop in those stills; defect 1 came from this pass. Dialogue framing was checked only in those stills. The `--autostart` boot itself was not run.
3. **State transitions:** the transitions tour ran for three pairs (pistol + plasma rifle, rocket launcher + katana, molotov + flamethrower: swap while running, roll out of a burst, roll in a reload, roll into a shot, swap in a reload, melee in a burst; 0 SCRIPT ERROR). Defect 2 came from it; the heavy pairs found no new one. The other 11 weapons did not run through it. **Entering and leaving vehicles:** in quest 1 and the arena the car button is a logged stub (`StagePilot`, "stub until the vehicles lane's API lands"), so nothing to check there; the free-roam city world does enter and exit through `VehicleService` (`CityVehicleWorld.set_focus` turns `rivet_on_foot` off and on), see below. Knock-down during a reload: see item 1.
4. **Bare-walk segment in the combined clip:** done. `rivet_n10_set_combined.mp4`, 83.6 s; segment 12 starts at 64.6 s. It is appended rather than slotted in as "2" so the n9 captions stay in order, and cops from the pad walk through the shot.

## Closed without a change

- The katana tour's octant 5 (Rivet drawn over the taxi after the lunge) is the arena's own rule: `ArenaCars` documents the pad as open floor with no solids, and `ArenaStage._collide` has no cars. Quest 1's `CollectCallStage._collide` does push him out of them.

## Known and left

- The one-handers' cell 1 (pistol, machine pistol, hand cannon, and ray gun and homing shard, which also got no cell 1 point) keeps the fallback spot for shots at 45-67 degrees. Cell 1 was read on pistol, machine pistol and hand cannon, where it draws the gun at image left, so a tip there would send the tracer across his body. Ray gun and homing shard cell 1 were never read clearly.
- The gatling's back view hides the gun, so that cell keeps the fallback.
- The molotov's left strip has three cells and no throw, so a left throw shows no wind-up. Fixing it needs art or a mirrored hand; neither is on the list.
- Gatling: the tour's 30-tick burst is all spin-up, so its fire cell was not exercised on film (the strip was re-cut and is read by eye; a longer burst needs the dev bot edit I dropped to keep the debt ratchet green).
- After a roll there is still one tick with the bare run frame before the gun shows (tick 36 in the tour log).

## Gates (it13, on `0dae4c8b`; every timing CONTENDED)

- `node tools/evidence/run.mjs --no-bench`: PASS. Lint 15/15, unit 1970 passed 0 failed, scenarios 55 passed, parity bit for bit (planted mutation caught at step 629), selftest (look goldens 11/11, block goldens 5/5), release-compile 630 loaded 0 failed.
- Director reel: top 19 chapters down, tilt70 19 down, 0 SCRIPT ERROR. Combo: see the JOURNAL's last entry (it was still running when this was committed).
- The new tests were run against the old strips: `test_rivet_cell_scale` failed on all seven strips and the foot line, green on the new.

## Not verified

- `mutate.mjs` scores: see the JOURNAL's last entry; it was started on `rivet_strips.gd` only, so `ghost_apparition.gd`, `arena_rigs.gd` and `shot_lift.gd` have no score.
- Vehicles: entry was seen once in the free-roam city (`dev/showcase/vehicle_frame.tscn`, 0 SCRIPT ERROR, frames in `gtai-n10/tmp/rivet/veh1`, not in the masters): he disappears into the car and nothing is left standing. That scene ignored `--view=combo`, so it is not the combo view, and its route never gets out of the car, so **leaving a vehicle was not exercised**.
- Knock-down during a reload was read in code only (`RivetKnock.path_or` wins over the reload path in `RivetFrames.step`); no film with a gun up.
- The gatling's fire cell was not filmed (the tour's burst is all spin-up); its re-measured facing point and whirl were.
- The transitions tour ran three pairs, not all 17 weapons.

## Calls for the owner

- **Shots leave during a roll.** `StagePilot._fire` has no roll gate, so a held trigger fires from the ball with no gun drawn (tour rows "roll into shot"). Built default: left as it is, since a gate changes feel and replays. Alternative: gate `_fire` on `motion.phase != ROLL`. Evidence: `rivet_roll_recovery_gun_before_after_combo_64ppm.png` shows the frames around it; no clip of its own.
- **The baton's left-swing smear (defect 8)** is the game's generic smear: a big pale crescent that wraps behind him, heavier than the thin arcs the right cells draw (`rivet_baton_left_before_after_combo_64ppm.png`, bottom row). Built default: on, since a swing with no read at all is worse. Alternative: empty `RivetStrips.LEFT_NO_SWING` to get the old silent swing, or a drawn left swing, which is art and off the list.
- **The ghost voice's new spot** can overlap a prop on his left (the parked car's corner in the Toner Room, in the frame). Built default: the screen's left. Alternative: `--ghost-voice=facing`.

## Next steps

See the last NEXT in `JOURNAL.md`.
