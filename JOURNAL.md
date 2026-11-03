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
