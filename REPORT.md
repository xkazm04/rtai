# n10 rivet REPORT (draft, it12, 23:55; the freeze session replaces this)

Defect hunt on Rivet at combo. Every performance number here is CONTENDED. Evidence: `C:\Users\kazda\kiro\gtai-masters\n10\rivet\` (`frames.json`, 7 entries, best first).

## Fixed

| # | Defect | Cause | Fix | Test | Evidence |
|---|---|---|---|---|---|
| 1 | A speaking ghost stood on Rivet's head through quest 1's dialogue | Its spot is his facing's own left, which points up the screen when he faces right, onto his 1.65 m figure | `GhostApparition.side_of` sends an up-screen side to the screen's left under a tilt; `--ghost-voice=facing` is the old spot; top view untouched | `test_ghost_apparition_side.gd` (5) | `rivet_ghost_voice_before_after_combo_{48,32}ppm.png` |
| 2 | After every roll he stood bare-clawed for 10 ticks, then the gun popped back | `ArenaRigs._rivet_clips` hid the gun on `phase != FREE`, which includes the recovery | Only the ROLL phase hides it | `test_arena_rigs_roll_gun.gd` (3) | `rivet_roll_recovery_gun_before_after_combo_64ppm.png` (64 px/m only) |
| 3 | A pop inside a burst: the fire cell showed for one tick, then the facing cell for the rest of the latch | The pose ran before the fire latch rose, and a 45 degree shot sits on `GUN_TOL` | `RivetFrames.publish` re-poses on the rising latch; `RivetStrips.FIRE_HOLD` keeps a burst already drawing its cell | `test_rivet_frames.gd` (2) | tour log, pistol octant 1 |
| 4 | Fired up the screen or on the upper diagonals, the flash sat on his helmet | Facing cells had no muzzle point | `tools/art/rivet_muzzle.py` measures facing cells 1/3/4; 158 points in `rivet_muzzle.json`, each checked by eye at p70 and p55 | `test_rivet_muzzle.gd` (2) | `rivet_gun_muzzle_{pistol,rocket}_before_after_combo_64ppm.png` |
| 5 | With 4 alone the flash left the gun and the tracer still left his middle | The tracer starts on the sim line | `ShotLift.to_muzzle` starts a lifted round on the tip and lets go by `CONVERGE_M`; top view untouched | `test_shot_lift.gd` (2) | as above |

## Brief status

1. **Walk all 17 weapons:** partly done. The tour (walk, run, stand, fire, reload in 8 octants) ran for all 17 in the arena at combo, 64 px/m, 0 SCRIPT ERROR; the logs show no mirrored one-hander and no base strip with a weapon. Five of the 17 contact sheets were read by eye (pistol, rocket launcher, molotov, flamethrower, katana). At 48 px/m five weapons ran (pistol, rocket launcher, katana, flamethrower, gatling), logs equally clean, 0 SCRIPT ERROR, only the katana's sheet read by eye. **Not done:** 48 px/m for the other 12, the same walk in quest 1, knock-down and get-up (a car's knock exists only on the city sim; the arena has none).
2. **Quest 1 start to end at 1.65 m:** done once at 48 px/m through the scripted pad (`dev/frames/quest1_clip.gd --rigs --view=combo`, 84 stills every 240 ticks to the end at tick 18996, 0 SCRIPT ERROR). That is stills every 4 s, read as contact sheets plus three full-size crops, so a clip shorter than 4 s can have been missed. Nothing clipped a door or prop in those stills; defect 1 came from this pass. Dialogue framing was checked only in those stills. The `--autostart` boot itself was not run.
3. **State transitions:** partly done. One pair (pistol, plasma rifle) ran through swap while running both ways, roll out of a burst both ways, roll in a reload, roll into a shot, swap in a reload, melee in a burst, at 64 px/m: no strip of another weapon, no drawn weapon out of step with the held one, no one-tick strip; defect 2 came from this. **Not run:** the other 15 weapons through it, knock-down during a reload (read in code only: the knock strip wins), entering and leaving vehicles (the pilot's car key is a stub in the arena and quest 1, so there is nothing to walk there).
4. **Bare-walk segment in the combined clip:** done. `rivet_n10_set_combined.mp4`, 83.6 s; segment 12 starts at 64.6 s. It is appended rather than slotted in as "2" so the n9 captions stay in order, and cops from the pad walk through the shot.

## Closed without a change

- The katana tour's octant 5 (Rivet drawn over the taxi after the lunge) is the arena's own rule: `ArenaCars` documents the pad as open floor with no solids, and `ArenaStage._collide` has no cars. Quest 1's `CollectCallStage._collide` does push him out of them.

## Known and left

- The one-handers' cell 1 (pistol, machine pistol, hand cannon, and ray gun and homing shard, which also got no cell 1 point) keeps the fallback spot for shots at 45-67 degrees. Cell 1 was read on pistol, machine pistol and hand cannon, where it draws the gun at image left, so a tip there would send the tracer across his body. Ray gun and homing shard cell 1 were never read clearly.
- The gatling's back view hides the gun, so that cell keeps the fallback.
- The molotov's left strip has three cells and no throw, so a left throw shows no wind-up. Fixing it needs art or a mirrored hand; neither is on the list.
- After a roll there is still one tick with the bare run frame before the gun shows (tick 36 in the tour log).

## Not verified

- Full `run_unit` 1966 passed, 0 failed, on these fixes before they were committed (only test comment lines changed after it). Lint passes through the commit hook.
- No `evidence/run.mjs`, scenario suite or director reel has run on any n10 commit, so the gates the brief names are still open.
- The new tests were not run against the old code and `mutate.mjs` was not run, so "fails on old code" is reasoned from the diff, not observed.

## Calls for the owner

- **Shots leave during a roll.** `StagePilot._fire` has no roll gate, so a held trigger fires from the ball with no gun drawn (tour rows "roll into shot"). Built default: left as it is, since a gate changes feel and replays. Alternative: gate `_fire` on `motion.phase != ROLL`. Evidence: `rivet_roll_recovery_gun_before_after_combo_64ppm.png` shows the frames around it; no clip of its own.
- **The ghost voice's new spot** can overlap a prop on his left (the parked car's corner in the Toner Room, in the frame). Built default: the screen's left. Alternative: `--ghost-voice=facing`.

## Next steps

See the last NEXT in `JOURNAL.md`.
