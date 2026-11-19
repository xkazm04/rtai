# Brief 07 `walk-slide` (lane move, n19): measure Rivet's foot slide between 1.8 and 2.5 m/s

Before ANY Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/move`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Rendering runs: `--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time.
Never kill processes by name. Commit each step as it lands: this session is stopped at 75 minutes.

## Context
The owner: "the walk slides" between about 1.8 and 2.5 m/s. `project/features/characters/rivet_walk.gd` picks the
walk strip below `RUN_FROM_MPS` (2.5) and the run above it, with a cadence cap (`MAX_CYCLES_S` 2.0 walk,
`MAX_RUN_CYCLES_S` 3.5 run, `CYCLE_CELL` / `RUN_CYCLE_CELL` per pitch). Once the cadence cap bites, the feet stop
keeping up with the ground and slide. **`rivet_walk.gd` belongs to the anim lane** (they re-cut Rivet's walk
strips at x1.5 tonight). This lane MEASURES and PROPOSES; it does not edit `features/characters/**`.
Rivet's speeds come from `project/data/tables/rivet_motion.json` (ours).

## Work, in order (commit each)
1. **A foot tracker** `tools/film/foot_slide.py` (in the manner of `evidence/s15/tools/hold_ride.py`, run with
   `py -3 -I`): from a stride film of Rivet walking on a straight line at a fixed speed, track each planted boot
   (the lowest dark-outline blob of the figure, or the boot pixels against the sprite's own foot pad) across the
   ticks it is planted, and report per speed: ground px/tick, the ride of the planted boot over the ground
   inside each hold (crop px and cm at the film's ppm), mean and max. A boot that is planted should move with the
   ground (ride 0); report the slide as world cm per planted step. Unit-check it on two synthetic frame sets
   (a perfect plant and a known 5 px slide) under `tools/film/` tests if the kit has a pattern for that.
2. **A stride film** (a dev script under `project/dev/rivet_motion/`, declared `RUN_TICKS`, `tools/dev/run.mjs`
   verdict quoted) of Rivet walking at fixed speeds 1.2, 1.8, 2.1, 2.4, 2.6, 3.2 m/s (forced through the motion
   code, not by teleporting), bare-claw and one weapon out, at tilt 70 and 55, 32 and 64 px/m, frames to
   `C:/Users/kazda/kiro/gtai-masters/n19/move/walk/`. Look at the frames.
3. **The table.** Slide per speed, per pitch, per armed/bare. Find where it is worst.
4. **A proposal, built as a pure function and tested here.** Compute, from the strips' own stride length
   (the distance a planted boot travels in one cycle at the art's scale), the cadence that keeps the boot planted
   at each speed, and the change to the anim constants (or a speed-to-cadence curve) that would remove the slide.
   Put the function in `features/player/` (e.g. `stride_match.gd`, pure, unit-tested) so the anim lane can call
   it from one line; prove it with the tracker by a **film-only override** in your dev script (the dev script may
   set the walk's phase rate through a public API if one exists; if none does, say exactly which line in
   `rivet_walk.gd` would call it). Before/after film at the same tick, 32 and 64 px/m.
5. **Write the NEED** into your report in this form, exactly, so the director copies it to JOURNAL:
   `NEED anim: project/features/characters/rivet_walk.gd:<line> <the one-line change> (measured: slide <a> cm -> <b> cm at <speed> m/s, film <path>)`.

## Not yours
`features/characters/**` (anim), `features/combat/**`, `features/arena/**`, city, native, goldens/digests.

## Repo law
AGENTS.md + STANDARDS.md; typed; functions <= 40 lines; files ~200 (hard 300); `Log`; commit `.uid` files.
Stage per path; no stash, add -A, reset --hard; never push; never stage JOURNAL.md or evidence/. Keep doc
comments. Commits `move: ...` with `Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Acceptance (I check after you)
quick gate + lint clean; `run_unit.mjs --changed` green; dev verdict `ok exit 0; SCRIPT ERROR 0; unknown arg 0`;
the table, the before/after frames with an INDEX.md in `gtai-masters/n19/move/walk/`, the NEED line.
