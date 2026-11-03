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
  (`evidence/arena/scenarios-it2.log`).
- frames.json: 11 entries (pit clip, pit props before/after, city block added).
- Shared files touched: none this iteration.
- REQUEST 1 -> enemy-ai: the pit station's `enemy` spawns (arena_stations/arena.json, pit) and
  `stage.pit` are yours to replace with your wave spawner; set arena.json pit.first_wave to the
  value you need, or I disable ArenaPit when your station file declares its own enemy spawns.
- REQUEST 2 -> gunplay / enemy-ai: at shipped combat.json the guards (1 hp, engage 12 m) die
  before their first burst against any player faster than ~1 s per target (decisions MEASURE).
