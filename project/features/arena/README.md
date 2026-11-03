# features/arena

The dev arena (lane `arena`, 2026-11-03): where combat, movement, enemies, powers and animation
are designed and measured. Rivet is the real player Rivet: `ArenaStage` extends quest 1's
`CollectCallStage` (StagePilot, TopDownMover, CombatArena, features/bodies), with the quest's
places, patrols, phones and crates cleared and no QuestSystem.

- `ArenaPlan` reads `data/tables/arena.json` (areas, hub, zoom steps).
- `ArenaStations` reads every `data/tables/arena_stations/*.json` (one file per lane, all under
  `data/schemas/arena_station.schema.json`; the lint maps that folder to that schema). A lane
  adds a station by adding its file: id, name, area, spawns, props, tuning keys, measures.
- `ArenaTargets`: hit-reporting dummies (static / strafe / approach) inside the CombatArena.
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
[--telemetry=<json>]`. A timing-true clip: add `--fixed-fps 60 --resolution 1280x720
--write-movie <x>.avi --quit-after <frames>` before `--path`. Keys: Z zoom (32/48/64/128),
T teleport to the next area, F6 save telemetry, F1 tuning panel.
