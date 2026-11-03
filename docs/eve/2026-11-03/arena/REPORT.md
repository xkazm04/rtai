# REPORT - lane arena (branch `e-arena`), evening 2026-11-03

Last code commit: `a08445f`. Everything after it is docs and evidence only.
Gates of record:
- lint 13/13 over 515 files (`evidence/arena/lint-it9.log`, on the branch head)
- unit 569/569, run alone (`evidence/arena/unit-it6-rerun.log`)
- scenarios 24/24 (`evidence/arena/scenarios-it6.log`, "scen exit 0")

`M` below means `C:\Users\kazda\kiro\gtai-masters\eve\arena`. Every path cited was checked on disk at 23:40.

## What works

1. **The arena scene on the real Rivet.** `project/dev/arena/arena.tscn` boots `ArenaStage`, which extends the slice's `CollectCallStage`. So it uses the slice's StagePilot, TopDownMover, CombatArena, bodies and input table, not a stand-in. It is drawn in the D5 ink at 32 px/m by default, with Z for zoom (48/64/128). Areas:
   - hub 18 x 10 m
   - range with 5/10/20/35 m lanes, static, strafing and approaching dummies
   - pit: a wall with two doors, crate low cover, dumpster high cover, a hut
   - course: slalom, corners, corridor, crowd patch
   - powers pad with parked real VehicleService cars

   Frames: `M/frames/arena-range-32.png`, `arena-overview-12.png`, `arena-pit-props-32.png` (before: `arena-pit-32.png`), `arena-course-32.png`, `arena-pad-cars-bots-32.png`, `arena-hub-merged-wide-32.png`.
2. **Stations as data.** Schema `gtai.arena-station/1` (`project/data/schemas/arena_station.schema.json`). The arena loads every `project/data/tables/arena_stations/*.json`, and the shipped file is `arena_stations/arena.json` (range, course, pit, hub).
   - Spawn kinds are `target`, `metal` (electroshock chain), `enemy` and `car`.
   - A row's `"script"` names an `ArenaHook`. The stage builds the hook, steps it, hashes it into the replay, folds it into telemetry and lets it tune its own knobs.
   - Merge plumbing:
     - The pit waves stand down when another lane brings pit enemies.
     - `dev/arena/stations_check.gd` is a merge rehearsal across every lane's files: 9 stations, 4 lanes, 0 problems (`M/merge-rehearsal/it4/report.json`).
     - The full suite also ran 24/24 with every lane's files copied in (`M/merge-rehearsal/it4/scenarios-all-stations.log`).
   - Format guide: `project/features/arena/README.md`.
3. **The live tuning panel** (F1 or `--panel`). It shows every knob a station exposes as a slider and value, with save-to-table (canonical JSON, round-trips byte for byte) and reset.
   - Every change is logged to `user://arena/tuning-log.jsonl`.
   - Knobs can address array rows (`rivet_melee.claw.hits.0.windup_ticks`).
   - Knobs the arena does not apply itself go to the owning lane's hook.
   - Frame: `M/frames/arena-panel-live-32.png` (turn_dps changed live at tick 300).
   - Tests: `project/tests/unit/test_arena_tuning.gd`.
4. **Telemetry: a HUD plus a JSON log per session** (`--telemetry`, F6; also written when `--quit-after` ends a capture). It records:
   - time to kill per target and range, hits/shots and hit rate
   - damage taken, dodges, deaths, knockdowns
   - pit waves, kills, and shots stopped by cover
   - turn rate peak, top speed, input latency in sim ticks
   - car counts

   Logs: `evidence/arena/arena-range-telemetry.json` (44 shots, 18 hits, 41 %, time to kill 0.08 s at 5 m static to 1.0 s at 10 m strafing), `arena-pit-telemetry.json` (2 waves in 12.4 s, 4.2 damage, 5 dodges, 2 shots stopped by cover), `arena-course-telemetry.json`, `arena-city-clip-telemetry.json`.
5. **City proving block, `--arena=city`.** The stations are laid at the generated city's junction (524, 524) with the city's collision, 120 people and the CityView. Spawns that land inside a building are dropped.
   - Frame: `M/frames/arena-city-range-32.png`
   - Clip: `M/clips/arena-city-range-clean-32ppm-20s.mp4`
   - Scenario: `project/tests/scenarios/scenario_arena_city.gd`. Rivet never ends up inside a building, the replay is identical, and a planted fault is caught.
6. **Deterministic recordings.** Scripted bots `--bot=range|course|pit`, each with a scenario that replays identically on a fresh world and catches a planted fault: `scenario_arena_range`, `_course`, `_pit`, `_city`, `_stations` under `project/tests/scenarios/`.
   - Other capture flags: `--start=<area>`, `--clean` (hides the HUD), `--ppm=`.
   - Capture recipe (any lane can use it for its station): `JOURNAL.md`, iteration 1, 21:22.
7. **Clips** (all fixed-fps 60; I checked a frame sheet of each), in `M/clips/`:
   - range: `arena-range-32ppm-15s.mp4`
   - course: `arena-course-48ppm-16s.mp4`
   - pit: `arena-pit-32ppm-25s.mp4`, `arena-pit-clean-32ppm-30s.mp4` (the arena's 00:00 sample), `arena-pit-clean-48ppm-15s.mp4`
   - pad: `arena-pad-32ppm-10s.mp4`
   - city: the clip in item 5
   - **`--rigs`** (dev flag): the fighters drawn on the cast rigs, with gun out, flinch, death sprawl, SHOOT recoil and a per-weapon kick from `arena.json` `rig_kick`. Clips: `arena-range-rigs-32ppm-15s.mp4`, `arena-pit-rigs-32ppm-20s.mp4`, `arena-pit-rigs-recoil-32ppm-20s.mp4`, `arena-range-rigs-recoil-64ppm-10s.mp4`, `arena-pit-rigs-kick-48ppm-12s.mp4`. Tests: `project/tests/unit/test_arena_rigs.gd` (7).
   - Owner page: `M/frames.json`, 15 entries, every file present.
8. **Asks answered.**
   - arena-1 C (keep the slabs, add a T teleport key): built.
   - arena-2 A (camera leads toward the aim): kept as a placeholder, nothing built.

   The owner's 21:25 rule applies to both: placeholders, re-ask only with a real-time clip in the final look. Recorded in `JOURNAL.md` and `docs/decisions.md`.

## What does not work / honest gaps

- **Input latency is measured only up to the sim (input edge to first sim motion): 0 ticks.** Frame-level latency (key press to the first *drawn* motion) is not measured. "Unmeasured is never zero": the 0 is the sim part only, and the HUD labels it "(sim)".
- **`--rigs` is not the default view.** The default still draws quest 1's stills and guard sprites. The rigs show:
  - every hostile as a COP
  - a generic HIT flinch, not enemy-ai's reactions
  - nothing past about 14 m from the focus. CharacterRigs has a fixed radius and the arena has no crowd atlas (REQUEST 6 -> d5-cast).
- **The recoil kick is a few pixels.** It cannot be judged in stills at 32 px/m. At 64 px/m the pit guards are off screen. The 48 px/m clip shows both the rifle and the pistol kick, but only at the frame edge.
- **Camera lead (arena-2) is not built.** At 48/64 px/m, guards that stop at engage_m 12 shoot from off screen and die there (`M/clips/arena-pit-clean-48ppm-15s.mp4`).
- **The powers pad has no Gearbox hook and no pad bot.** Cars park and draw by state, but nothing drives them, and no pad scenario replays.
- **The pit enemies are placeholders.** They are GuardBrain guards with no pathing; at shipped numbers they die before their first burst unless the bot holds fire (REQUEST 2 -> gunplay / enemy-ai, MEASURE in `docs/decisions.md`).
- **The dummies still use the guard sprite** (vermilion vests) and do not read as dummies.
- **No scenario boots the arena with rigs** (it needs a headless print stage).
- **Not measured tonight:** bench or perf of the arena scene. The bench lock and the GPU were shared, so no frame-time number is claimed.

## What blocked me, and for how long

- **Shared `user://` across concurrent lanes.** The unit suite came back 443/569 (and 192-245 failures twice in iteration 3), all in tests that write to user:// (save slots, replay log). Re-run alone each time: green. Cost about 15 min over the evening. REQUEST 7 -> int/Director: a user dir per worktree, or run the unit gates one at a time.
- **REQUESTs in JOURNAL were not read in time.** enemy-ai's station file would have failed the merge. I switched to direct messages at 22:45 and the fix landed within minutes. About 20 min lost.
- **Tooling:**
  - A windowed run with a parse error hung until its 120 s timeout.
  - A bash here-doc stripped regex backslashes, and that parse error failed the whole unit run (about 10 min).
  - `-s` check mode reports false compile errors for classes that reach the `Log` autoload.
- **The owner's 21:25 direction** ruled out asks without a final-look clip. So no feel/layout answers came in, and the arena's numbers stay placeholders.

## Next steps (night run, from the merged main)

1. Re-read `answers.json`. On the merged tree run `"$GODOT_BIN" --headless --path project -s res://dev/arena/stations_check.gd -- --out=build/evidence/arena-stations.json` (exit 0 expected), then the arena scenarios. Run the unit gate alone (REQUEST 7). Delete the orphan `data/schemas/enemy-ai.schema.json` (a byte copy of the arena's schema).
2. Make `--rigs` the default: rivet-motion's Rivet plan, enemy-ai's `HitFeel.reaction` in `ArenaRigs._put`, robot and contractor plans in place of COP, a per-host rig radius (REQUEST 6). Add a scenario that boots with rigs.
3. Gearbox `ArenaHook` on `stage.cars()`, plus a scripted pad bot, so the pad clip and scenario replay.
4. Camera lead toward the aim (arena-2). Then the vertical-sample clip at 48 px/m with `--rigs --clean`: pistol, claw combo, cop and robot thug, one power. Judge rifle vs pistol kick in it.
5. Frame-level input latency (input event to first drawn motion) in telemetry.
6. Dummies' own look (cardboard, steel plate for `metal`).
