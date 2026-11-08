# n10 rivet REPORT (draft, it8, 22:50; the freeze session replaces this)

Defect hunt on Rivet at combo. Every performance number here is CONTENDED, and no gate has been run on the head yet (see "Not verified").

## Fixed

| # | Defect | Cause | Fix | Test | Evidence |
|---|---|---|---|---|---|
| 1 | A pop inside a burst: the fire cell showed for one tick, then the facing cell for the rest of the latch | The pose ran before the fire latch rose, and a 45 degree shot sits on `GUN_TOL` | `RivetFrames.publish` re-poses on the rising latch; `RivetStrips.FIRE_HOLD` keeps a burst already drawing its cell | `test_rivet_frames.gd` (2) | tour log, pistol octant 1 |
| 2 | Fired up the screen or on the upper diagonals, the flash sat on his helmet | Facing cells had no muzzle point, so the flash took the fallback spot | `tools/art/rivet_muzzle.py` measures the guns' facing cells 1/3/4; 158 points in `rivet_muzzle.json`, every new point checked by eye at p70 and p55 | `test_rivet_muzzle.gd` (2) | `gtai-masters/n10/rivet/rivet_gun_muzzle_{pistol,rocket}_before_after_combo_64ppm.png` |
| 3 | With 2 alone the flash left the gun and the tracer still left his middle | The tracer starts on the sim line | `ShotLift.to_muzzle` starts a lifted round on the tip and lets go by `CONVERGE_M`; top view untouched | `test_shot_lift.gd` (2) | as above |

## Brief status

1. **Walk all 17 weapons:** partly done. The tour (walk, run, stand, fire, reload in 8 octants) ran for all 17 in the arena at combo, 64 px/m, 0 SCRIPT ERROR. The logs show no mirrored one-hander and no base strip with a weapon. Five of the 17 contact sheets were read by eye (pistol, rocket launcher, molotov, flamethrower, katana). **Not done:** 48 px/m, the same walk in quest 1, knock-down and get-up.
2. **Quest 1 start to end at 1.65 m:** not done. `--autostart` only presses Start and I found no bot that plays quest 1 in the arena's `--bot` list.
3. **State transitions:** read in code only, nothing run. A roll clears `gun_out`, so it draws the roll cell. The knock strip wins over a reload in `RivetFrames.step`. Vehicles not examined.
4. **Bare-walk segment in the combined clip:** not done.

## Known and left

- The one-handers' cell 1 (pistol, machine pistol, hand cannon, and ray gun and homing shard, which also got no cell 1 point) keeps the fallback spot for shots at 45-67 degrees. Cell 1 was read on pistol, machine pistol and hand cannon, where it draws the gun at image left, so a tip there would send the tracer across his body. Ray gun and homing shard cell 1 were never read clearly.
- The gatling's back view hides the gun, so that cell keeps the fallback (a flash above his head reads right there).
- The molotov's left strip has three cells and no throw, so a left throw shows no wind-up. Fixing it needs art or a mirrored hand; neither is on the list.

## To check

- Katana tour, octant 5: after the lunge Rivet is drawn on the taxi's roof. Not diagnosed: it could be a draw-order bug or a lunge that ignores the car.

## Not verified

- No full `run_unit`, `evidence/run.mjs` or director reel on these commits; only lint (hook) and the three selected test files, 13 + 23 passing.
- The new tests were not run against the old code, and `mutate.mjs` was not run, so "fails on old code" is reasoned, not observed.
- The 32 px/m before/after the brief asks for does not exist yet; the frames are 64 px/m.

## Calls for the owner

None yet.

## Next steps

See the last NEXT in `JOURNAL.md`.
