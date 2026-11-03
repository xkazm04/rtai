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
