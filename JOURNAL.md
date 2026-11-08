# n10 rivet JOURNAL

## it4 (21:01, first real session; it1-3 exited in seconds on billing, see gtai-n10/logs/runner.log)
Brief: defect hunt. Starting with the static audit of the 17 weapons' sheets, then a harness to walk them.

FRICTION (21:10-21:40) the harness cost ~30 min: first import 9 min on the contended machine; a crop bug (canvas px vs the 800x600 image); TaskStop and a too-broad taskkill filter left overlapping batches writing the same files.
DECISION dev/debt: `dev/rivet_motion/rivet_tour*` (211 lines, dev only) raises `dev_loc`, recorded with `debt.mjs --update --accept-regression` (the README's route for a deliberate increase; reason stored under `accepted`). Delete it after the hunt if it is not worth keeping.
FINDING pistol tour log (21:35, combo 64 px/m): at octant 1 the FIRE cell shows ONE tick then the facing cell for the rest of the latch (t263 frame 5, t264-269 frame 1): a pop inside a burst. Cause not yet proven.

## it8 (22:10-)
MILESTONE b3f4d543: the fire-cell pop fixed and committed (the shot's own frame takes the fire cell; a burst keeps the cell within FIRE_HOLD).
FINDING tour 64 px/m, 17 weapons, combo (tmp/rivet/tour/c64b + c64c): logs clean of mirrored one-handers and base-with-weapon; 0 SCRIPT ERROR. Two real defects:
- D1 muzzle: fired up the screen or on the upper diagonals (a third of the aim circle) the facing cell has no point, so the flash sat on his helmet. Fixed in the table (facing cells 3/4, cell 1 where the gun points right; gatling 4 skipped: the back hides it, the right tip is a hose).
- D2 tracer: with D1 alone the flash leaves the gun and the tracer still leaves his middle (two origins, seen in the after frame). ShotLift.to_muzzle pulls a lifted round onto the tip, let go by CONVERGE_M.
KNOWN, not fixed: the one-handers' cell 1 draws the gun at image left, so 45-67 deg shots keep the fallback spot; the molotov's left strip has no throw cell (art, not on the list).
MILESTONE (22:48) the final tour (c64d, pistol + rocket launcher, 0 SCRIPT ERROR): flash and tracer both leave the drawn gun at octants 6 and 7, the rocket's octant 1 flash is on the warhead instead of the road. Frames and frames.json in gtai-masters/n10/rivet.
FRICTION (22:30-) the machine was so contended that a one-file grep took over a minute and the pre-commit lint over 8 minutes: one commit hit its 500 s background limit and was re-run with a longer one.
FRICTION (22:50) the retried commit was rejected by the hook (gdformat on test_shot_lift.gd, a 101-column comment in test_rivet_muzzle.gd); its job still exited 0 because a `git log` ran after the commit. Read the commit's own status, not the job's. Likewise a unit run printed `Godot not usable` (the probe timed out under load), 0 tests, exit 0.
NEXT (it9, in the brief's order):
1. Run the full gate on the head first: `node tools/tests/run_unit.mjs`, then `node tools/evidence/run.mjs --no-bench`; neither has run on these commits. Run `node tools/mutate/mutate.mjs --file=features/combat/weapons/art/shot_lift.gd` to back "fails on old code".
2. Diagnose the katana tour's octant 5 (c64c/katana.png: Rivet drawn on the taxi's roof after the lunge): draw order or a lunge through the car.
3. Item 1 rest: the tour at 48 px/m, knock-down and get-up (not in RivetTourBot), and the walk in quest 1. Read the sheets not yet opened (12 of 17).
4. Item 2: quest 1 has no bot. A `--record` of a real play then `--replay` is the likely route to walk it at 1.65 m; check `scenario_quest_collect_call.gd` for a scripted driver first.
5. Item 3: run `--bot=arsenal` (a switch every 4 s) for swaps; roll into a shot, knock-down during a reload and vehicles still unrun.
6. Item 4: the bare-walk segment in the combined clip.
7. A 32 px/m before/after: the before needs the old table and the old `round_at` restored temporarily, or a worktree at 70e31db9.
FINDING (22:56, for NEXT 2) c64c/katana.png octant 5, zoom in tmp/rivet/tour/c64c/zoom_katana_taxi.png: the strikes carry him from (-25.51, 22.07) to (-27.28, 20.30), 2.5 m, and from the reload columns he is drawn over the taxi's roof with the car around him. The pistol at the same octant stays at (-25.52, 22.07) and never reaches the car. Not known yet whether the sim puts him inside the car's footprint (a lunge ignoring vehicle bodies) or only the draw order is wrong; check his position against the car's rect first.
