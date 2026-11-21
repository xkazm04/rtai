# n22-street brief 05: a street that reads as a street, bodies out of walls, two more templates

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. Briefs 01 to 04 are
committed (read `git log --oneline -25` first). Never rename anything from the interface commit.

**Wall-clock hard stop: 04:40 (stop working, write the final message). Commit deadline: 04:33.** Commit each item when
it works. Fix lint and format findings in your own edits and go on. Never amend, never rebase. No `git stash`,
no `git add -A/./-u`, no `commit -a`, no `reset --hard`, no tags, no merges. Stage per path; never stage
`JOURNAL.md` or `evidence/briefs/**`. Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for rendering, `--position 0,1440` on any windowed run: never the main display).
One Godot process at a time; free your own by PID. Mutate: `--max=20 --lines=<changed>`.

## Allowlist (any other path: stop that item and report `NEED <owner lane>: <file> <why>`)
`project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/**`, `gauntlet.json`,
`gauntlet_bonuses.json` + schemas, `project/tests/unit/test_gauntlet_*.gd`, `evidence/street/**`, one appended
line in `docs/decisions.md` per decision, `C:\Users\kazda\kiro\gtai-masters\n22\street\`.
Forbidden: `project/features/player/**`, `project/features/combat/**`, `project/features/souls/**`,
`project/features/arena/**` (reuse, never edit), `enemies.json`, `weapons.json`, `combat.json`,
`input_actions.json`, `TickInput`, `tools/**`. No new art files: dress with art the repo already ships
(city tiles, kerbs, sidewalks, building edges, props the city or arena already draws). Never generate images.

## Order and priority
Items 0 and 1 are fixes and come first. Item 2 is what the owner will see in the morning films, so it comes
before the two extra templates (six templates already meet tonight's minimum). The five-wave film is re-shot
in the next brief, not by you; leave the film script able to run unchanged.

## What the director saw in the six segment stills (36cbb7405)
All six read as the same corridor: pale road, black slabs for walls, dumpsters and crate stacks. A player
cannot tell a loading bay from a kiosk plaza. The film (`gauntlet_waves4-5_32.mp4` at 21 s) also shows the
war machine's wreck debris drawn over the bottom wall and blood splashed on the wall tops in most stills. In `segment_alley_neck_32.png` a dead cop lies drawn over the
bottom wall (a body knocked into the wall's footprint).

## Items, in order
0. **Lane loop's NEEDs (serve first, one commit each).**
   a. `death.by` was absent on a death (loop's `evidence/loop/batch-street-1/runs/average-4.json`, wave 9, in
      `C:\Users\kazda\kiro\gtai-wt\n22-loop`, read only). Every death names its killer: the enemy row id of
      the last hostile whose hit took Rivet's hp to 0 (read the damage event the arena already emits; if the
      source is a blast or unknown, `by` = the weapon id or `"unknown"`), `"timeout"` for the 90 s timeout.
      Never absent when `death` is present. Unit test: a death by a cop records `by: "<cop row id>"`.
   b. A per-wave counters hook for the pilot: add to `GauntletPilot` (interface class: ADD only, rename
      nothing) `func wave_counters() -> Dictionary: return {}`; at each wave close street merges the returned
      int/float keys into that wave's row (only keys the schema knows: `guard_deflects`, and loop may also fill
      `rolls`/`form_seconds` only where street did not measure them; street's own measure wins), then calls
      `pilot.reset_wave_counters()` (also added, empty). Document it in the class comment. Unit test with a
      stub pilot returning `{guard_deflects = 3}` -> the wave row has `guard_deflects: 3`; the default pilot
      leaves the key absent.
   c. **Health bar unreadable (director, film still at 12 s of `gauntlet_waves1-3_32.mp4`, Health 96/100):**
      the bar shows an ink-filled frame with only a small cream square at its right end, so a nearly full
      bar looks nearly empty. The fill must be the larger part at high hp, clearly distinct from the empty
      part (shipped palette, no teal, no red). Re-check at 100, 50 and 10 hp in a still. One commit.
1. **Bodies never rest inside a wall.** (The same film shows a dead cop lying fully beyond the bottom wall,
   in the void outside the street, at 12 s of `gauntlet_waves1-3_32.mp4`: knocked through the wall.) When a hostile dies inside or overlapping a solid prop's footprint,
   its resting place is pushed to the nearest free point on the road side (street code only: the place
   where street owns the hostile's spawn/clamp; if the body's position is owned by combat code, report
   `NEED foes` with the line and leave it). Unit test with a hostile killed against a `wall_high`.
   Must not change the 60 s replay or any scenario outside the gauntlet.
2. **Dressing that tells the templates apart.** The side walls become street edges: a sidewalk strip with a
   kerb, building fronts (or the city's existing wall/facade art) behind it, using shipped art only; draw it
   in `gauntlet_floor.gd` (or a sibling) from per-template data in `gauntlet.json` (`dressing` key: e.g.
   sidewalk width, edge style id, decals). Each template gets one recognisable feature (the loading bay's
   dock edge, the kiosk plaza's open square, the alley's narrow brick walls, the barricade line's road
   barriers, the crosswalk's paint). Collision stays exactly as today (dressing is paint, not solid), so
   results stay byte-identical: prove it with seed 7 (cmp against a run at the commit before).
   No wall on a zebra crossing. Colour law: no teal, no red except blood, vermilion only for danger.
3. **Re-take the stills** (`segment_<id>_32.png` for all six (eight if item 5 lands), 1080p, tilt 70, 32 px/m, the gauntlet HUD
   visible). FIRST copy the six existing `segment_<id>_32.png` to `segment_<id>_before_32.png` (they are the
   before, taken at the same camera by 36cbb7405); the re-takes use the same still script, tick and camera.
   Look at each still yourself and describe it.
4. Mutate on the changed street file, `--max=20`, quote the score.
5. **Only if time remains before COMMITBY: two more templates** (8 total): e.g. `underpass` (pillars as `cover_high`) and `market_stalls`
   (`cover_low` rows), each with at least one `cover_high` a player can hide behind from a blast, flank and
   ahead spawns. Unit test that every template has >= 1 `cover_high`, >= 3 spawns, no prop on a crossing.
   This changes the street order for a seed: record the new seed-7 hash and re-run the two-run byte compare. Re-take their two stills.


## Final message
Commits, files, test counts, byte-compares, every still with what you saw, mutate score, NEEDs, undone.
