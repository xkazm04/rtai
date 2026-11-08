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

## it12 (23:11-)
MILESTONE f9086894: the muzzle + tracer fix committed (lint hook 212 s, rc 0 read off the commit itself).
FINDING (closes NEXT 2) the katana over the taxi is not a Rivet defect: `ArenaStage._collide` has no cars (`ArenaCars` header: "the arena world is open floor: no traffic, no solids"), so any walk or lunge passes through the powers pad's parked cars. Quest 1's `CollectCallStage._collide` does push him out of them (`ArenaCars.push_out`). Left as built.
DECISION dev/transitions: `--tour-kind=trans` (RivetTransBot: swap while running, roll out of a burst, roll in a reload, roll into a shot, swap in a reload, melee in a burst) and `--tour-kind=bare` (bare walk and run for the clip) on the existing dev tour, rather than a separate scene.
FRICTION (23:18-23:26) the first full unit run went red only on my own half-typed dev bot (load_all parses every script): 1958 passed, 0 failed otherwise. A file edited during a run is part of that run. Re-run needed for a green.
FINDING (23:28, transitions tour pistol + plasma rifle, combo 64 px/m, 0 SCRIPT ERROR, tmp/rivet/tour/trans1) no strip of another weapon, no drawn weapon out of step with the held one, no one-tick strip. One real pop: after every roll the gun stayed away for the 10 RECOVER ticks, so he stood bare-clawed and the gun popped back (`ArenaRigs._rivet_clips` hid it on `phase != FREE`). Fixed: only ROLL hides it. Test: `test_arena_rigs_roll_gun.gd`.
OBSERVED, left: the sim fires during a roll (`StagePilot._fire` has no roll gate), so a held trigger sends shots from the ball. Changing it moves replays and feel; goes to Calls.
FINDING (23:30, quest 1 start to end through the scripted pad, `quest1_clip.gd --rigs --view=combo --ppm=48`, ended at tick 18996, 84 stills, 0 SCRIPT ERROR, tmp/rivet/q1a) nothing clips a door or prop, and the dumpster beats hold. One defect his size made worse: a speaking ghost stands at his facing's own left, which is up the screen when he faces right, so it sat on his head and shoulders (t7440, the Toner Room). Fixed: `GhostApparition.side_of` sends an up-screen side to the screen's left under a tilt. DECISION souls/ghost-voice-side; `--ghost-voice=facing` = the old spot. Test: `test_ghost_apparition_side.gd`.
MILESTONE (23:51) bare walk and run filmed (`--tour-kind=bare`, combo 64 px/m, 0 SCRIPT ERROR) and appended as segment 12: `gtai-masters/n10/rivet/rivet_n10_set_combined.mp4`, 83.6 s (64.6 + 19.0). Looked at frames at 40 s and 72 s. Raw .avi deleted.
FRICTION (23:46) a stills run with only two ticks drew the ghost nearly invisible: the voice's age advances by the ticks since the last drawn frame, so sparse stills fade it. Before and after must use the same dense tick list (q1c, every 240 ticks); it is a harness effect, not a game state.
FRICTION (23:54) the commit hook rejected two 100+ column comments in the new tests after 6 minutes under load; nothing was committed that round.
GATES: full `run_unit` 1966 passed, 0 failed (23:54, on the working tree with these fixes; only three test comment lines changed after it). selected tests 20/0 (23:46). Transitions tour on the fix: 0 bad rows, gun back at tick 37 after the ball ends at 35. Lint runs in the commit hook. NOT run on these commits: `evidence/run.mjs`, scenarios, the director reel x3, `mutate.mjs`; the new tests were not run against the old code.
FINDING (23:59, the tour at 48 px/m, combo: pistol, rocket launcher, katana, flamethrower, gatling; tmp/rivet/tour/c48, 0 SCRIPT ERROR) no mirrored one-hander, no base strip with a weapon. The log's "fire no muzzle" rows are the known ones: the pistol's octant 1 (8 ticks, the same at 64 px/m, the fallback spot in Known and left) and the katana (a blade has no muzzle). Sheet read by eye for the katana only: the taxi row is the arena's no-solids rule again.
NEXT (it13, in order):
1. `node tools/evidence/run.mjs --no-bench` and the director reel in top, tilt70, combo (`--quit-after 40000`) on the head: neither has run on any n10 commit.
2. `node tools/mutate/mutate.mjs --file=features/souls/ghost_apparition.gd --tests=test_ghost_apparition_side` and the same for `features/arena/arena_rigs.gd` with `test_arena_rigs_roll_gun`, and `features/combat/weapons/art/shot_lift.gd`, to back "fails on old code".
3. Item 1 rest: read the 12 unread contact sheets (tmp/rivet/tour/c64b + c64c); the 48 px/m tour for the other 12 weapons (`tmp/rivet/tour_all.sh combo 48 <out> <weapons>`; five are done in tmp/rivet/tour/c48); knock-down and get-up need the city sim (`--arena=city` and a car, as n9 filmed `rivet_knockdown_city_car`).
4. Item 3 rest: `--tour-kind=trans` with a heavy pair and melee (rocket_launcher,katana; molotov,flamethrower); knock-down during a reload on the city.
5. Delete `dev/rivet_motion/rivet_tour*` and `rivet_trans_bot` at the end of the hunt if not worth keeping, and let the debt baseline tighten.
