# Builder n31-melee-01a-volumes (opus): measure "the blade passes through and nothing happens" (player weapons)

Read `evidence/briefs/n31-common.md` first: it is binding. Tag: `01a`. Launched ~21:05.
HARD STOP: commit each finished part by 25 min into the call; report and END by 22:05 at the latest.
This item MEASURES only. Do not change any game rule, table or view in this call (the current tree = main = the "before").
Another builder (`01b`) works in `project/dev/melee_n31/foe_reach*`, `play_baseline*`, `tools/melee/foe_reach*`,
`tools/melee/play_baseline*`: do not touch those. Your files: `project/dev/melee_n31/blade_volume*` (+ helpers
named `blade_*`), `tools/melee/blade_volume*`, their tests, `evidence/n31-melee/01-volumes/**`.

## The owner's complaint
"Melee weapons are visible smashing through enemies and nothing happened." We need a number for it.

## What is known (verify by reading before relying on it; paths under project/)
- Hit test: `features/player/player_melee.gd:_land` (~line 85): from `arena.rivet.pos` (Rivet's centre, not the
  blade), `to.length() <= h.reach_m + f.radius_m` and `dir.dot(facing) >= h.cone_dot`.
- When: `features/player/melee_combo.gd:lands()` (~line 109): only on `tick_in == windup` (the FIRST active tick);
  the chainsaw re-tests every `grind_ticks` while held.
- Drawn: `features/player/melee_swing.gd` (blade angle per clip time: anticipation, the cut starts CUT_TICKS=2
  before the hit tick, overshoot through active+recovery), `features/player/rivet_swipe_view.gd` (crescent radius
  clamped to `ARM_MIN_M` 1.1..`REACH_MAX_M` 1.35 m, drawn only when `RivetSwipe.needs_arc`), the drawn blade in
  `melee_weapon_view.gd` / `MeleeSmearView` (grip + `length_m`). Rows: `data/tables/melee_weapons.json`,
  `rivet_melee.json`.
- Existing tools to reuse/learn from: `tools/film/swing_measure.gd` + `swing_table.mjs` (a live arena driven per
  tick), `tools/film/film.mjs` (shots, probe.json), `project/dev/kill_lab/**`.

## Build
1. `project/dev/melee_n31/blade_volume.gd` (+ `.tscn`, helpers in that folder): a dev scene that, for each melee
   weapon (claw/hands, chainsaw, electro_baton, katana, plasma_sword), runs the REAL arena + views at fixed 60 Hz
   with a ring of dummy humans at 12 angles x 5 distances (0.8, 1.4, 2.0, 2.6, 3.2 m) about Rivet (one dummy per
   swing if dummies would shield each other or die - your call, document it); Rivet swings once facing 0 deg.
   Per tick of the swing, read the DRAWN geometry from the view nodes as drawn that frame (the blade segment grip
   to tip in world metres, and the swipe crescent polygon when on) - not from the data rows. A dummy is
   "drawn-overlapped" when the blade segment or crescent intersects its body circle (radius_m) on any frame of the
   swing. "Hit" = the sim registered a hit on it. Plus a MOVER: a dummy walking across the swing at 1.4 m/s, timed
   to enter the arc after the hit tick (late), several timings.
   Output per weapon: drawn-but-no-hit count, hit-but-not-drawn count (of the 60 ring cells), the tick window in
   which the blade is drawn cutting vs the tick(s) the hit is tested, the mover result.
   Validate ONE weapon's geometry against a real 64 px/m frame: render one frame with the measured blade segment
   and crescent overlaid as thin lines (dev overlay) and LOOK at it - the lines must sit on the drawn blade. Save
   `evidence/n31-melee/01-volumes/overlay_check_<weapon>.png`.
2. `tools/melee/blade_volume.mjs` (Node, runs the scene through runGodot; `--rev=<sha>` via the film snapshot
   pattern if cheap, else live tree): writes `evidence/n31-melee/01-volumes/<label>/volumes.json` and one polar
   plot PNG per weapon (both volumes laid over each other: drawn = cream outline, hit = filled translucent; cells
   drawn-no-hit in vermilion, hit-not-drawn in ice blue) plus a combined sheet. Draw the plot in Godot or with
   `tools/film/png.mjs`/ffmpeg.
3. Tests: a GUT unit test for the pure geometry (segment/crescent vs circle overlap, drawn/hit set compare) and a
   node --test for the mjs summary logic.
4. Run it on the current tree (label `before`). Per-weapon table in `evidence/n31-melee/01-volumes/before.md`.
5. IN PLAY (only if 1-4 are committed with >= 15 min left): the same count in real gauntlet play. Read
   `project/dev/gauntlet/gauntlet.gd` and `features/gauntlet/bot/**` (read only) to see how the bot plays melee;
   add a dev probe under `project/dev/melee_n31/blade_play*` that runs the gauntlet (waves 1-4, seed 7, katana;
   then plasma_sword, claw) and counts swings whose drawn blade overlapped a living enemy with no hit registered.
   Output `evidence/n31-melee/01-volumes/before/play.json`.

## Acceptance
- volumes.json + polar PNGs for 5 weapons on the before tree; overlay check frame shows the lines on the blade
  (say so and name the file).
- Tests pass (`node tools/tests/run_unit.mjs --select=<your test basenames>`), lint clean on your files.
- Commits: part 1+3, part 2+4, part 5 if reached.
- Report: the before table (weapon, drawn-no-hit, hit-not-drawn, cutting tick window vs hit tick, mover), and the
  exact command a later call uses to re-run it on HEAD for the after.
