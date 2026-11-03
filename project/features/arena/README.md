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
- `ArenaKeys`: the arena's dev keys from `data/tables/arena_keys.json` (never in TickInput).

Run: `"$GODOT_BIN" --rendering-driver d3d12 --path project res://dev/arena/arena.tscn -- [--ppm=48]
[--bot=range] [--shot=<png> --shot-tick=<n>] [--telemetry=<json>]`. Keys: Z zoom (32/48/64/128),
T teleport to the next area, F6 save telemetry, F1 tuning panel (next).
