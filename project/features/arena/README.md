# features/arena

The dev arena (lane `arena`, 2026-11-03): where combat, movement, enemies, powers and animation
are designed and measured. Rivet is the real player Rivet: `ArenaStage` extends quest 1's
`CollectCallStage` (StagePilot, TopDownMover, CombatArena, features/bodies), with the quest's
places, patrols, phones and crates cleared and no QuestSystem.

- `ArenaPlan` reads `data/tables/arena.json` (areas, hub, zoom steps).
- `ArenaStations` reads every `data/tables/arena_stations/*.json` (one file per lane, all under
  `data/schemas/arena_station.schema.json`; the lint maps that folder to that schema). A lane
  adds a station by adding its file: id, name, area, spawns, props, tuning keys, measures.
  Only id, name and area are required; the lists are optional.
- Station hooks: a station row's `"script": "res://features/<lane>/<hook>.gd"` names an
  `ArenaHook` (copy `arena_tick_hook.gd`). The stage builds it after setup and calls `setup`,
  `step` (every tick, after the stage), `write_state` (replay hash), `telemetry` (folded into the
  session JSON under the station id), `attach_view` (the dev view) and `tune` (the live panel's
  knobs for that lane's tables). A lane wires its weapon, enemies or power without editing the
  arena's files. Paths outside res://features/ or scripts that do not extend ArenaHook are dropped.
- Tuning keys address array rows by index: `rivet_melee.claw.hits.0.windup_ticks`.
- Merge rehearsal: `godot --headless --path project -s res://dev/arena/stations_check.gd --
  --dir=<folder of every lane's station files> --out=<report.json>` loads them together, builds
  every hook and resolves every knob; exit 1 on a skipped file, a broken hook or a bad knob path.
- `ArenaTargets`: hit-reporting dummies (static / strafe / approach) inside the CombatArena.
  Spawn kinds that become dummies: `target`, `metal` (also the CombatArena's metal: the
  electroshock chain and the arc see it) and `enemy` outside the pit (a lane's robot line or
  melee line, a dummy until that lane's hook brings a brain). `enemy` in the pit = ArenaPit.
- `ArenaCars`: spawn kind `car` parks a real VehicleService car (the powers pad: Gearbox picks
  from `ArenaStage.cars()`, a Hauler ram hits it). Drawn in the city's traffic print by state
  (teal soul plate, damage, wreck). No traffic, on-foot entry off. The service exists only when a
  station brings a car, so the shipped arena's replays do not move. Telemetry `cars`.
- `ArenaTelemetry`: shots, hits, hit rate, time to kill per dummy, damage taken, input-to-motion
  latency (sim ticks), peak turn rate, top speed, knockdowns -> `gtai.arena-telemetry/1`.
- `ArenaRangeBot`: the range's scripted player (scenario `scenario_arena_range`: replays identical).
- `ArenaCourseBot` / `ArenaPitBot`: the course's and the pit's scripted players
  (`scenario_arena_course`, `scenario_arena_pit`: replay identical, planted faults caught).
- `ArenaWalls`: props of kind `wall_high`, `cover_high`, `cover_low` are solid boxes: bodies are
  pushed out, shots (Rivet's and the enemies') stop in them. `door`, `cone`, `lane_mark`,
  `firing_line` are paint. The floor draws low cover as the city's crates, high cover as its
  dumpster.
- `ArenaPit`: the pit's placeholder waves (`arena.json` "pit": first_wave, grow, max_wave, gap_s)
  at the pit station's `enemy` spawns, real GuardBrain contractors. The enemy-ai lane's wave
  spawner replaces it.
- `ArenaDodges`: enemy shots that came within 1.5 m of Rivet and went past (telemetry `dodges`).
- City proving block: `--arena=city` lays every station at `arena.json` "city".base (a junction
  of the generated city), with its collision (StageCells + bodies), people and CityView; a spawn
  inside a building is dropped and logged (`scenario_arena_city`).
- `ArenaKeys`: the arena's dev keys from `data/tables/arena_keys.json` (never in TickInput).

Run: `"$GODOT_BIN" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn -- [--ppm=48]
[--bot=range|course|pit] [--arena=city] [--panel] [--shot=<png> --shot-tick=<n>]
[--telemetry=<json>] [--start=<area id>] [--clean]`. A timing-true clip: add `--fixed-fps 60 --resolution 1280x720
--write-movie <x>.avi --quit-after <frames>` before `--path`. Keys: Z zoom (32/48/64/128),
T teleport to the next area, F6 save telemetry, F1 tuning panel.
