# JOURNAL - lane arena (branch e-arena), evening 2026-11-03

## Iteration 1 (20:50 - 21:35), BUILD

Read: AGENTS.md, slice-play REPORT, quest1_session / collect_call_stage / stage_pilot /
collect_call_view, combat_arena, guard_brain. answers.json empty at 20:50.

Registry rules applied: controller-latency-instrumentation (latency measured from the input
edge to the first sim motion, in ticks; the view's frame latency is still to add on top, so the
HUD labels it "(sim)"); encounter-balance-simulation (time to kill measured per target from the
first aimed shot, with a lapse window so misses do not inflate it). Not yet read in full: next
iteration reads both golden paths properly. DEVIATION none yet.

- MILESTONE 20:57 `a2467d8`: stations as data (`gtai.arena-station/1`, one file per lane under
  `data/tables/arena_stations/`), floor plan `gtai.arena/1`, ArenaStage on the real Rivet
  (extends CollectCallStage, so StagePilot + TopDownMover + CombatArena + bodies are the
  slice's), range dummies, telemetry, `scenario_arena_range` (20 s range bot: 44 shots, 18 hits,
  replay identical on a fresh world, planted no-trigger fault gives 0 hits).
  Evidence: `evidence/arena/arena-range-telemetry.json`.
- Shared change: `tools/lint/lint.mjs` DAT-03 maps `data/tables/arena_stations/*.json` to
  `arena_station.schema.json` (otherwise a lane's `combat.json` station file would be checked
  against the combat table's schema). Two lines.
- MILESTONE 21:00 `b3bfeaf`: dev scene `dev/arena/arena.tscn` (CollectCallView with
  ArenaFloorView as its floor, print pass, D5 ink). First frames (looked at all three):
  `gtai-masters/eve/arena/frames/arena-range-32.png`, `arena-range-48.png`, `arena-overview-12.png`.
- ASK arena-1 (layout: default C = keep slabs + teleport key) and arena-2 (35 m lane is off
  screen at 32 px/m: default A = camera leads toward the mouse) written 21:00.
- MILESTONE 21:03 `8b3a5da`: telemetry HUD (replaces the quest's "$0 unarmed" card in the arena),
  arena keys as data (`arena_keys.json`, not the shared input table): Z zoom, T teleport (the
  arena-1 default C), F6 save telemetry. Teleport is outside the input tape: logged, and the HUD
  says the run no longer replays.
- FRICTION: the dummies use the guard sprite (vermilion vests); fine for "danger" but they
  should read as dummies. The range 35 m lane is off screen at 32 px/m (arena-2).
- FRICTION: the `Read`-less here-doc JSON for the asks mangled backslashes; asks rewritten with
  forward-slash paths.
- 21:05 `ArenaTuning` (the panel's model): knob keys "<table>.<json path>" read the shipped value,
  apply live to PlayerActions (move.*) and CombatTuning (weapons.*, rivet.*, human.*), reset,
  save into the table in canonical form (unit test: round-trips input_actions, combat, arena
  byte for byte), and log every change to user://arena/tuning-log.jsonl.
  Station knob keys fixed: `input_actions.move.*` (not `movement`).
- FRICTION 21:07: a bash here-doc stripped the regex backslashes in arena_tuning.gd. That parse
  error failed the whole unit run (650 "failing"). Fixed with the Edit tool. Lesson: write any
  GDScript that has backslashes with Write/Edit, never with a here-doc.
- frames.json: 4 entries at gtai-masters/eve/arena/frames.json.
- MILESTONE 21:17 `e3f9f2a`: tuning panel (dev/arena/arena_panel.gd, F1 or --panel): every
  station knob as a slider + value + save + reset, live through ArenaTuning. Proof frame
  `arena-panel-live-32.png` (turn_dps -> 240 at tick 300 via --tune, HUD "live (true)").
- FRICTION 21:12: a windowed run with a parse error hung until its 120 s timeout (as the brief
  warns). From now on I run each new script headless with --quit-after before any windowed run.
- Gates at e3f9f2a: lint 13/13, unit 545/545 (`evidence/arena/unit-it1.log`), scenarios 20/20

- MILESTONE 21:23: course station recording: `ArenaCourseBot` + `scenario_arena_course` (course
  time 15.5 s, turn peak 720 deg/s, replay identical, planted no-stick fault caught);
  `--bot=course` in the scene; frame `arena-course-32.png`. FRICTION: arena walls are drawn but
  do not collide yet (NEXT 3).
- MILESTONE 21:22: first clip `gtai-masters/eve/arena/clips/arena-range-32ppm-15s.mp4` (Godot
  `--write-movie`, `--fixed-fps 60`, 900 frames, made into an mp4 with ffmpeg). I checked the
  8-frame sheet. Recipe: `"$GODOT_BIN" --rendering-driver d3d12 --fixed-fps 60 --resolution
  1280x720 --write-movie <x>.avi --quit-after 900 --path project res://dev/arena/arena.tscn --
  --bot=range --ppm=32`. Any lane can capture its station the same way. frames.json: 7 entries.
- answers.json re-read 21:22: no answers yet to arena-1 or arena-2.
- 21:26: course clip `clips/arena-course-48ppm-16s.mp4` (sheet checked; the walls do not collide
  yet). frames.json now has 8 entries. Still missing: range at 48 px/m and course at 32 px/m as
  clips (stills exist).

NEXT (iteration 2):
1. Re-read answers.json for arena-1 and arena-2 and apply them: arena-1 C is built (T teleport);
   arena-2 A means camera aim look-ahead, which is the camera lane's to build, so file it as a
   REQUEST if no lane owns it.
2. Read the registry golden paths in full (controller-latency-instrumentation,
   encounter-balance-simulation) and add frame-level latency (input event to first drawn move).
3. Course station: a scripted course bot plus a scenario (slalom/corridor timing, turn rate),
   and props that collide (StageCells-like push_out for arena walls).
4. Pit: low and high cover props, doors, and waves through WaveDirector (an enemy spawn kind).
   Powers pad: parked and moving cars (needs the vehicles service in the arena session).
5. `--arena=city`: the city proving block (needs a LaunchArgs KNOWN_FLAGS line, a shared file).
6. Dummies should read as dummies, not guards (a cardboard look, not the vermilion vests).
7. Clips: 10-25 s timing-true clips of the range and the panel at 32 and 48 px/m.
8. Other lanes: write arena_stations/<lane>.json (format: features/arena/README.md). Knob keys
   are "<table>.<json path>"; live apply covers input_actions.move.* and combat weapons /
   rivet / human so far.

## Iteration 2 (21:26 - ), BUILD

answers.json at 21:26: nothing for arena. Re-read 21:40: arena-1 C and arena-2 A answered by
the owner's 21:25 direction ("not judgeable in this state ... keep your default as a placeholder,
stop tuning on numbers; re-ask only with a real-time clip in the final look"). Applied: arena-1 C
(teleport key) stays as built; arena-2 A (camera aim look-ahead) stays a placeholder for the
camera owner, nothing built. Read common.md "Owner direction 21:25": depth before breadth, real
characters and the full hit chain, asks only with real-time clips in the D5 look, one 20-40 s
clip per lane at 32 px/m for the 00:00 vertical sample.
- ASK arena-3 (does low cover stop shots?) written at 21:39 and WITHDRAWN at 21:40: a still plus
  numbers, which the 21:25 direction rules out. Built as data (ArenaWalls.SOLID) so the answer is
  a one-line change when it is asked with a clip.

- MILESTONE 21:41 `b26737d`: the pit station (data in arena_stations/arena.json): north wall
  with two 4 m doors, low cover (crates), high cover, a hut with a door, 5 enemy spawns.
  `ArenaWalls`: solid props push bodies out and stop shots both ways (culled before the
  CombatArena steps, so features/combat is untouched). `ArenaPit`: placeholder waves (arena.json
  "pit": first 2, +1 per wave, max 5, 2.5 s gap) of real GuardBrain contractors; Rivet's death
  respawns him at the hub and resets the pit. `ArenaDodges`: enemy shots that came within 1.5 m
  and went past. Telemetry + HUD: pit wave, kills, dodges, deaths. The course bot's path now goes
  round the corridor's lower wall (walls collide). `ArenaPitBot` + `scenario_arena_pit`.
- FRICTION 21:35: the first pit bot reacted in one tick and killed every 1 hp guard from beyond
  their engage_m 12 (gloria 26 m) before their first burst: 0 damage, 0 dodges, nothing
  measured. The bot now holds fire until 13 m and waits 60 ticks (1 s, a human acquire time).
  Result: two waves in 12.4 s, 4.2 damage, 5 dodges, 2 enemy shots stopped by cover. Logged
  as a MEASURE in decisions.md for gunplay / enemy-ai: at shipped numbers guards never threaten.
- FRICTION: the guard spawned inside the hut never left it (GuardBrain walks straight at Rivet,
  no pathing). Moved that spawn outside (pit_se). Enemy pathing is enemy-ai's.
- FRICTION: unit 550/551 on the first run: test_save_slots could not mkdir under user:// (the
  user dir is shared by every lane's worktree). Re-run 551/551 (`evidence/arena/unit-it2-rerun.log`).
- MILESTONE 21:43 `9678130`: cover in the game's ink: crate rows (city crate_stack, one crate
  repeated) for low cover, the city dumpster (2.2 x 1.5 m) for high cover, street cones on the
  course. Frame `arena-pit-props-32.png` (before: `arena-pit-32.png`), checked.
- 21:45 clip `clips/arena-pit-32ppm-25s.mp4` (fixed-fps 60, 1500 frames): waves 1-4, 9 kills,
  8 dodges, 4.8 damage taken. 9-frame sheet checked: camera follows, no breaks, blood red.
- MILESTONE 21:49 `6645106`: city proving block `--arena=city`: the stations laid at the
  generated city's junction (524, 524), StageCells collision + the city bubble + 120 people +
  CityView + baked characters; spawns in a building dropped (none at this junction: plazas NE and
  NW, a building SW). Frame `arena-city-range-32.png` checked. `scenario_arena_city`: range bot
  12/31 hits in 15 s, Rivet never inside a building, replay identical; planted fault = Rivet
  dropped inside the SW building must stay in with collision off (cells AND follow cut).
- FRICTION: my first city fault (walk into a block with stage.cells off) never entered a
  building: features/bodies' follow also keeps Rivet out of buildings. Good for the game, wrong
  for the test; replaced by the drop-in check.
- Gates at 1c4cae4: lint 13/13 (505 files), unit 551/551 (rerun), scenarios 23/23
- Gates after the pit stand-down: unit 552/552 (`evidence/arena/unit-it2b.log`), arena scenarios 4/4
  (`evidence/arena/scenarios-it2.log`).
- frames.json: 11 entries (pit clip, pit props before/after, city block added).
- Shared files touched: none this iteration.
- REQUEST 1 -> enemy-ai: the pit station's `enemy` spawns (arena_stations/arena.json, pit) and
  `stage.pit` are yours to replace with your wave spawner; set arena.json pit.first_wave to the
  value you need, or I disable ArenaPit when your station file declares its own enemy spawns.
- REQUEST 2 -> gunplay / enemy-ai: at shipped combat.json the guards (1 hp, engage 12 m) die
  before their first burst against any player faster than ~1 s per target (decisions MEASURE).
- MILESTONE 21:54 `860c1bc`: `--clean` hides the dev HUD (the 00:00 sample clips show the game
  only); `--telemetry` is now also written when the engine's `--quit-after` ends a capture
  (NOTIFICATION_PREDELETE), so every clip can carry its telemetry JSON.
- 21:53 the arena's sample clip `clips/arena-pit-clean-32ppm-30s.mp4` (sheet checked).
- 21:55 `clips/arena-city-range-clean-32ppm-20s.mp4` + `evidence/arena/arena-city-clip-telemetry.json`
  (18/44 hits; time to kill 0.08 s at 5 m static to 1.0 s at 10 m strafing). Sheet checked.
- 21:57 `clips/arena-pit-clean-48ppm-15s.mp4`. FINDING: at 48 px/m the view is ~26 x 15 m;
  guards that stop at engage_m 12 to the south/north shoot and die off screen. That is arena-2's
  problem (camera lead toward the aim), now shown in a clip. Camera lead or a shorter engage
  range; not the arena's to choose.
- frames.json: 14 entries.
- answers.json re-read 21:56: no new answers for arena.

- 22:00 NEXT 2 done early: ArenaPit drives only the arena lane's own enemy spawns and stands down
  (logged) when another lane's station declares enemies in the pit, so enemy-ai's file plugs in
  without double spawns at the merge (unit test with a probe enemy_ai station). REQUEST 1 is
  answered by this: enemy-ai only has to ship its station file.

NEXT (iteration 3):
1. Re-read answers.json. The 21:25 direction rules: depth before breadth, real characters, full
   hit chain, asks only with real-time clips in the final look.
2. The arena as the stage for the vertical sample: after the 00:00 merge, load every lane's
   station file together and check the arena boots with all of them (ArenaPit already stands
   down for another lane's pit enemies; check gunplay's range vs the arena's range dummies).
3. Dummies read as dummies (cardboard target art, not the guard sprite's vermilion vests); an
   image_gen asset is allowed (provenance line).
4. Camera: the 48 px/m off-screen finding. If no lane owns camera lead by iteration 3, build it in
   the arena view only (a look-ahead toward the aim, as data) and show it as a clip.
5. Powers pad: props and parked/moving cars for Hauler and Gearbox (needs the vehicles service in
   the arena session; quest 1 has none, so add VehicleSystem to ArenaSession like _add_city).
6. The course on the city block: the course walls sit on the street; consider a city-only
   placement per station (decisions: rejected for now) once a station needs it.
7. Low cover stopping shots: ask only with a clip once the hit chain exists (ArenaWalls.SOLID).

## Iteration 3 (22:02-22:47), BUILD

- 22:02 answers.json re-read: no new answers for arena (arena-1 C, arena-2 A, both "placeholder,
  re-ask only with a real-time clip in the final look"). Rules applied: the 21:25 direction (depth
  before breadth; no numbers-only asks). This iteration is the merge plumbing every lane's part of
  the 00:00 vertical sample needs to land in the arena without editing the arena's files.
- Read the other lanes' JOURNAL requests to arena: enemy-ai REQUEST 1 (one shared station schema),
  gunplay REQUEST 3/4 (35 m lane off screen; a GunHand hook in ArenaStage), rivet-motion REQUEST 1
  (a metal dummy kind; array-row tuning keys by index).
- MILESTONE `e53bbf4` station hooks: a station row's `"script"` names a res://features/ script
  that extends `ArenaHook` (setup, step after the stage, write_state into the replay hash,
  telemetry folded into the session JSON under the station id, attach_view, tune). Built and
  stepped in station-file order. `ArenaTickHook` is the template. Hook-only stations need no lists
  (only id, name, area required); lane ids may hold a hyphen. This answers gunplay REQUEST 4
  without the arena naming GunHand (a class not on this branch): gunplay ships
  `features/gunplay/arena_gun_hook.gd` whose setup() does
  `stage.arena.gun = GunHand.make(...)` and whose attach_view() wires HitFeel to the view's camera.
- MILESTONE `1ae3479` knobs address array rows by index (`rivet_melee.claw.hits.0.windup_ticks`),
  save writes into arrays, and a knob the arena does not apply itself goes to the lanes' hooks
  (`ArenaHook.tune`), so each lane makes its own knobs live.
- MILESTONE `8b330c0` merge rehearsal `dev/arena/stations_check.gd`: loads a folder of every
  lane's station files together, builds every hook, resolves every knob. Run at 22:28 on
  arena + enemy-ai + rivet-motion + ghost-powers + gunplay's draft
  (`gtai-masters/eve/arena/merge-rehearsal/report.json`): 9 stations from 4 lanes load; tables
  powers, weapons, rivet_motion, rivet_melee are not in this tree (they resolve after the merge);
  ONE real problem: enemy-ai.json is skipped (schema id `gtai.arena_station/1` with an underscore,
  `kind` instead of `area`, no `name`). The panel also no longer raises a JSON parse error for a
  missing table (that would have failed every scenario after the merge).
- FRICTION: a `-s` SceneTree tool cannot statically name a class that uses an autoload (Log):
  "Identifier not found: Log" at compile time. The tool is now a thin runner that `load()`s
  `stations_report.gd` at run time (the run_scenarios pattern).
- FRICTION: unit 192 to 245 failures twice, all in test_save_slots (+2 test_noir_shadows):
  user:// shared with the other lanes' concurrent runs. The 22:31 run was clean: 558/558.
- Gates at 8b330c0: lint 13/13 (510 files), unit 558/558 (`evidence/arena/unit-it3c.log`),
  arena scenarios 4/4 at e53bbf4 (`evidence/arena/scenarios-it3.log`, goldens unmoved: no
  shipped station has a script or a metal spawn).
- REQUEST 3 -> enemy-ai: your `arena_stations/enemy-ai.json` is skipped by the arena (and fails
  lint at the merge). Exact fix: `"schema": "gtai.arena-station/1"`, rename the row's `"kind":
  "pit"` to `"area": "pit"`, add `"name": "Enemy pit"`; keep `doc` and `script`. Drop your
  `enemy-ai.schema.json` (the lint maps the folder to arena_station.schema.json). `script` must
  name a script that `extends ArenaHook` (EnemyPit does not): add a small
  `features/combat/ai/enemy_pit_hook.gd` that builds EnemyPit in setup(), drives it in step()
  (rivet_pos from `stage.arena.rivet.pos`) and returns `stats` from telemetry(). With your
  station declaring pit enemies, ArenaPit stands down by itself (bb6eb35).
- REQUEST 4 -> gunplay: REQUEST 4 is answered by hooks, not a line in ArenaStage. In your
  station row add `"script": "res://features/gunplay/arena_gun_hook.gd"`; that hook's setup() sets
  `stage.arena.gun = GunHand.make(WeaponTable.shipped(), &"pistol", ctx.rng.stream(&"gunplay"))`
  and connects `stage.arena.struck`; attach_view(view) finds the CameraRig. Your 84 `weapons.*`
  knobs become live through `tune()`. Re-bless the arena replays then (a new RNG stream).
- REQUEST 5 -> rivet-motion, ghost-powers: same route for your knobs (`tune()` in a hook) and
  your scripted dev scenes; the metal dummy kind is `"kind": "metal"` (next commit).
- 22:34 merge rehearsal with REQUEST 3 applied to a copy of enemy-ai.json
  (`gtai-masters/eve/arena/merge-rehearsal/fixed/`, `report-fixed.json`): 10 stations, 0 problems,
  the hook builds. Notes in `merge-rehearsal/README.md`.
- Shared files touched this iteration: none (arena_station.schema.json is the arena's).
- answers.json re-read 22:34: nothing new for arena.

- MILESTONE `37e243c` `scenario_arena_stations`: every shipped station file loads, every hook
  builds, every knob whose table is in the tree resolves; planted bad knob caught. At the merge,
  enemy-ai's file as it stands fails this scenario (and lint's data-tables), which is the point.
- Gates at 37e243c: lint 13/13 (511 files), unit 559/559 (`evidence/arena/unit-it3d.log`),
  scenarios 23/23 full suite at ccff748 (`evidence/arena/scenarios-it3-full.log`) + the new
  stations scenario 1/1. `scenarios-it3c.log` is a red run caused by my own half-written metal
  edit compiled mid-run (fixed in b855c5d), kept as the record.

NEXT (iteration 4 / the night run from the merged main):
1. Re-read answers.json. On the merged tree run
   `godot --headless --path project -s res://dev/arena/stations_check.gd -- --out=build/evidence/arena-stations.json`
   (default folder = every lane's file). Exit must be 0: fix or REQUEST whatever it lists, then the
   arena scenarios (boot, range, course, pit, city) with every lane's station loaded.
2. The vertical sample in the arena: every lane's hook in, one 20-40 s clip at 32 px/m with
   `--clean` (pistol + claw combo against the cop and robot rigs, the pit cover, a power on the pad).
3. Camera lead (48 px/m off-screen finding, arena-2): build in the arena view only if no lane owns
   it after the merge; show it as a clip.
4. Dummies read as dummies (cardboard target art; image_gen allowed with a provenance line); the
   metal dummy needs its own look (a steel plate) once rivet-motion uses `"kind": "metal"`.
5. Powers pad with VehicleSystem in ArenaSession (ghost-powers' gearbox_pad spawns `car`; the
   arena does not spawn cars yet: ArenaStage only places `target`/`metal`).
6. Low cover stopping shots: ask only with a full-chain clip (ArenaWalls.SOLID is the one value).

## Iteration 4 (22:35-23:20), BUILD

- 22:35 answers.json re-read: nothing new for arena (arena-1 C, arena-2 A stand as placeholders).
  Rules applied: owner direction 21:25 (depth before breadth, the arena is the stage of the 00:00
  sample, no numbers-only asks). So no new ask this iteration. The arena's job tonight is that every
  lane's part of the sample lands on its floor at the merge.
- MILESTONE `92e467e` powers pad cars: a station spawn of kind `"car"` parks a real
  VehicleService car (`ArenaCars`, a VehicleWorld with no traffic and no solids; on-foot entry
  off because quest 1's stage has no driving seat). It draws in the city's traffic print by state
  (intact, d1, d2, the teal soul-hijacked plate, the burnt wreck) with the ink shadow.
  `ArenaStage.cars()` / `.vehicles` are what a power hook picks from, and telemetry gains `cars`
  (total, hijacked, damaged, wrecked). The service is added only when a station brings a car, so
  the shipped arena's replays do not move. The same commit (message omits it): an `"enemy"` spawn
  outside the pit is a moving dummy with its motion (ghost-powers' robot line,
  rivet-motion's melee line), where before it was dropped. Unit `test_arena_cars` (3 tests).
- MILESTONE `36ce3e1` `--start=<area id>` stands Rivet in an area at boot (station captures).
- Frames: `gtai-masters/eve/arena/frames/arena-pad-cars-bots-32.png` (ghost-powers' file copied
  in: two parked sedans, the Hauler and Gearbox robot lines moving),
  `arena-hub-merged-32.png` (all four lanes' files: rivet-motion's melee line runs off the 8 m hub
  onto the void and its dummies overlap).
- Merge rehearsal it4 (`gtai-masters/eve/arena/merge-rehearsal/it4/`): arena + enemy-ai (its
  REQUEST 3 fix applied in its worktree at 22:45, not yet committed there; no hook scripts tonight)
  + rivet-motion + ghost-powers = 9 stations, 0 problems. Tables not in this tree: powers,
  rivet_motion, rivet_melee, melee_weapons.
- FRICTION: JOURNAL REQUESTs were not being read by the other lanes in time. From 22:45 I sent
  direct cross-session messages instead: to enemy-ai (the REQUEST 3 exact fix, which landed within
  minutes), ghost-powers (cars, the hook route for Gearbox, the 8 x 8 lane_mark that draws a dark
  box over the crowd ring), and rivet-motion (metal kind, spacing, crowd off the slab).
- Gates: lint 13/13 (513 files), arena unit 25/25, scenarios 24/24 at 36ce3e1
  (`evidence/arena/scenarios-it4.log`).
- Shared files touched: none.
- MILESTONE `1ef2408` the hub widened to 18 x 10 m (x -3..15), so rivet-motion's melee line
  stands on floor at the merge; area names draw over the props, 2.2 m in, so a wall no longer hides
  PIT. Frames: `arena-hub-merged-wide-32.png` (before: `arena-hub-merged-32.png`),
  `arena-pit-label-32.png`.
- Merged-stations scenario run: all four lanes' station files copied into the tree (removed
  afterwards, never staged), full suite 24/24 with replays identical, car service included
  (`gtai-masters/eve/arena/merge-rehearsal/it4/scenarios-all-stations.log`).
- Clip `gtai-masters/eve/arena/clips/arena-pad-32ppm-10s.mp4` (+ `pad32_sheet.png`, 6 frames
  checked): the pad with ghost-powers' file, cars parked, robot lines moving. frames.json updated
  (14 entries; the weaker range-48, range-hud and course-32 stills were dropped).
- Peer replies: enemy-ai fixed its station file (`fc1844b` on e-enemy: schema id, area, names,
  no script lines). It keeps `data/schemas/enemy-ai.schema.json` as a byte copy of
  arena_station.schema.json because its own lint maps per file; after the merge that copy is
  an orphan the Director can delete. ghost-powers moved its hauler_pad lane_mark to a thin start
  line (`1551105`). The Hauler needs no ArenaHook: it rides on StagePilot.hauler (Q / LB) and
  CollectCallView draws the morph, the crack, the hit-stop and the shake. Gearbox's ArenaHook comes
  in the night run (ArenaHook is not on e-powers).
- Not started, on purpose (time box): the arena's fighters on the animated cast rigs. CastView
  (shared with quest 1) draws Rivet as a captured still and the hostiles as quest-1 guard sprites.
  The view mixes Ink's 48 px/m with the sim's 32 px/m, and the animated Rivet (rivet-motion) and
  the enemy rigs with hit reactions (enemy-ai) are on other branches. Half of it at the freeze
  would be worse than none.
- Gates at ab3d26d: lint 13/13 (513 files), unit 562/562 (`evidence/arena/unit-it4.log`, private
  APPDATA), scenarios 24/24 (`evidence/arena/scenarios-it4.log`, at 36ce3e1; later commits are a
  data rect, label drawing and docs, so the merged-stations run after them is the newer record).

NEXT (the night run, from the merged main):
1. Re-read answers.json. Run `stations_check.gd` on the merged tree (exit 0 expected; enemy-ai,
   rivet-motion and ghost-powers were green in the it4 rehearsal), then the arena scenarios.
2. The arena's fighters on the cast rigs (the owner's rule 3): an ArenaRigs node on the
   CollectCallView actor layer that fills a CharacterRigs `feed` every frame from
   `stage.arena.rivet`, `stage.arena.hostiles` and `stage.targets` (RigFeed.put(i, id, kind,
   pos * SimConst.PX_PER_M, vel); face, aim, flags DEAD / AIMING / DOWN), plus a CastView flag
   (`rigs_drawn`) so CastView skips the sprites it replaces. Use rivet-motion's Rivet plan and
   enemy-ai's reaction feed (HitFeel.reaction) once merged. Template: `dev/showcase/d5_arena_run.gd`.
   Check the Ink 48 px/m vs SimConst 32 px/m scale first.
3. Gearbox's ArenaHook (ghost-powers night item) picks from `stage.cars()`; the pad needs a
   scripted pad bot (Q Hauler stomp into the robot line, G Gearbox into the strafers) for a
   replaying clip and scenario.
4. rivet-motion's data: metal dummies to kind `metal`, 2 m spacing (message sent 22:45).
5. Camera lead (48 px/m off-screen, arena-2) if no lane owns it after the merge.
6. Dummies read as dummies (cardboard / steel plate art) once the rigs are in.
- MILESTONE `cb99029` `--rigs` (dev flag, off by default): ArenaRigs fills a CharacterRigs feed
  every frame from the CombatArena (Rivet = RIVET rig, hostiles and dummies = COP rigs, DEAD|DOWN
  on death) on the print stage's actor layer and hides CastView. The scale check came out clean:
  the print stage is in SimConst px (32/m), so the feed is metres x 32 and needs no extra scale.
  Clip `clips/arena-range-rigs-32ppm-15s.mp4` (+ sheet, 8 frames checked) and still
  `frames/arena-range-rigs-32.png`: the first arena frames with real characters, range bot
  31 shots / 12 hits. Gaps: no hit reaction or death pose (a killed dummy's rig vanishes), and
  every hostile is a cop. NEXT 2 is now: make --rigs the default once enemy-ai's reaction feed
  and rivet-motion's Rivet plan are merged, add the robot / contractor plans and a death pose,
  then re-run the arena scenarios (render only, so replays must not move).
- rivet-motion applied the three notes (`b03f575` on e-motion: metal kind, 2 m spacing, crowd in
  the course). It copied arena_station.schema.json verbatim from ab3d26d, so I leave that schema
  unchanged until the merge.
- MILESTONE `--rigs` second pass: the rig radius is centred 7 m ahead of Rivet's aim. The blank
  rings were not deaths: CharacterRigs poses full rigs only within 14 m of its focus and leaves
  the rest to the crowd atlas, which the arena lacks. A struck fighter plays the rig's HIT flinch
  away from Rivet. Clip re-captured (same path, sheet checked). REQUEST 6 -> d5-cast (night run):
  a per-host RADIUS_M on CharacterRigs, so a small arena can pose every fighter on screen.
- MILESTONE `--rigs` third pass: armed fighters (Rivet's pistol, the pit's rifles) have GUN_OUT and
  AIMING along their facing. Clip `clips/arena-pit-rigs-32ppm-20s.mp4` (+ sheet): waves 1-3 on
  the cop rigs, with flinches, death sprawls and the red blood. This is the arena's best frame
  of the full chain so far. frames.json: 14 entries, the two --rigs clips first.
- Gates at 05c1b48: lint 13/13 (514 files), unit 562/562 (`evidence/arena/unit-it4b.log`),
  scenarios 24/24 (`evidence/arena/scenarios-it4b.log`), all with a private APPDATA.
  answers.json re-read at 23:02: nothing new.

NEXT (supersedes the list above; for the night run, from the merged main):
1. Re-read answers.json. Run `stations_check.gd` on the merged tree (exit 0 expected), then the
   arena scenarios with every lane's file in.
2. Make `--rigs` the arena's default view: rivet-motion's Rivet plan, enemy-ai's reaction feed
   (HitFeel.reaction) in `ArenaRigs._put` instead of the generic HIT clip, robot and contractor
   plans instead of COP for everyone, and the SHOOT clip on a fired shot. REQUEST 6 -> d5-cast:
   a per-host RADIUS_M. Then a scenario that boots the arena with rigs for N ticks.
3. Gearbox's ArenaHook (ghost-powers) on `stage.cars()`, and a scripted pad bot (Hauler stomp
   into the robot line, Gearbox into the strafers) for a replaying pad clip and scenario.
4. The 00:00 vertical sample in the arena: one 20-40 s `--rigs --clean` clip with the pistol,
   the claw combo, the cop and the robot thug, and one power.
5. Camera lead (48 px/m, arena-2) if no lane owns it; dummies' own look once the rigs are default.

## Iteration 5 (23:04-23:30, BUILD)
- answers.json re-read 23:04: no new answers (arena-1 C and arena-2 A from 21:25 stand: placeholders,
  re-ask only with a real-time clip in the final look).
- MILESTONE `fc4728d` `--rigs`: a fired shot plays the rig's SHOOT recoil. ArenaRigs reads each
  fighter's (cooldown, burst_left) per frame. `ArenaRigs.fired()` counts a round when a guard's
  burst_left falls, or when Rivet's cooldown re-arms with no burst running. A guard *starting* a
  burst (both values rise) is not counted as a shot. The dead get DEAD|DOWN and no clip. New unit
  test `test_arena_rigs.gd` (6 tests): fired() edges, gun out + aiming, recoil exactly once per
  round, dead lie down. Render only: no sim state, no RNG, so replays and parity are not touched.
- Clip `clips/arena-pit-rigs-recoil-32ppm-20s.mp4` (+ `pit_rigs_recoil32_sheet.png`, 8 frames checked;
  `pit_rigs_recoil32_burst.png`, 10 consecutive crops of frames 540-630). Honest gap: at 32 px/m the
  recoil kick is a few pixels and I cannot see it in the stills, so it has to be judged in motion
  or at 64+ px/m. frames.json is at 15 entries with this clip first.
- FRICTION: `--check-only -s <script>` reports "Compilation failed" for anything that reaches
  `part_library.gd`, because the `Log` autoload is missing in -s check mode. Not a real parse error;
  the GUT run (`-gselect=test_arena_rigs`, 6/6) is the real check.
- Gates at fc4728d: lint 13/13 (515 files), unit 568/568 (`evidence/arena/unit-it5.log`).
- Clip `clips/arena-range-rigs-recoil-64ppm-10s.mp4` (+ `range_rigs_recoil64_sheet.png`, checked).
  At 64 px/m you can see Rivet's gun arm and the tracers leaving it. The recoil is still a small
  kick, best judged in motion. frames.json stays at 15: this clip went in second, and the
  32 px/m "area name over props" still came out.
- Gates at 48b154b: scenarios 24/24 (`evidence/arena/scenarios-it5.log`), lint 13/13, unit 568/568.
  answers.json: nothing new.

NEXT (night run, from the merged main; supersedes iteration 4's NEXT where it differs):
1. Re-read answers.json. Run `stations_check.gd` and the arena scenarios on the merged tree.
2. `--rigs` as the default: rivet-motion's Rivet plan, enemy-ai's HitFeel.reaction in
   `ArenaRigs._put` in place of the generic HIT, robot/contractor plans in place of COP. SHOOT is done
   (fc4728d). Pass the weapon's kick as clip_arg (rifle > pistol). REQUEST 6 -> d5-cast: a
   per-host RADIUS_M. Then a scenario that boots the arena with rigs (needs a headless
   CollectCallView with a print stage).
3. Gearbox ArenaHook on `stage.cars()` and a scripted pad bot, so the pad clip and scenario replay.
4. The 00:00 vertical sample: one 20-40 s `--rigs --clean` clip with pistol, claw combo, cop + robot
   thug and one power, at 48 px/m with a camera lead (arena-2).
5. Dummies' own look (cardboard / steel plate) once the rigs are the default.
