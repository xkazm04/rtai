# Data contracts

Every persisted or generated format names its schema and version (DAT-07).

| Schema | File | Writer | Reader |
|---|---|---|---|
| `gtai.achievements/1` | `steam/achievements/achievements.json` (+ `.schema.json`) | humans/agents | `tools/achievements/gen.mjs` |
| `gtai.achievements-runtime/1` | `project/data/generated/achievements_runtime.json` | gen.mjs (GENERATED) | AchievementTracker (planned) |
| `gtai.achievements-mirror/1` | `user://device/achievements_mirror.json` | `AchievementMirror` | `NullBackend`, later SteamBackend replay |
| `gtai.events/1` | `project/data/schemas/events.json` (name, emitter, `wired`, typed params; param names are the tracker contract) | humans/agents | gen.mjs emitter wiring, lint `events-registry`, `test_events_contract.gd` |
| `gtai.sim-constants/1` | `tools/gen_constants/sim_constants.json` | humans/agents | gen.mjs -> `SimConst` (.gd) + `gtai::sim` (.h), lint `sim-constants` |
| `gtai.city-district/1` | `project/data/tables/city_district.json` (+ schema) | humans/agents | `CityGen`, lint `data-tables` |
| `gtai.city-textures/1` | `project/data/tables/city_textures.json` (+ schema) | humans/agents | `CityGen` (sizes, solidity), `CityTextures` |
| GTCH v1 | `project/data/generated/city/c_XX_YY.bin` (git-ignored build output) | `dev/bake_city.gd` | `ChunkSource` / `ChunkCodec` |
| golden list | `project/data/generated/city_chunks.sha256` (GENERATED, committed) | `dev/bake_city.gd` | `CityBake.check`, `scenario_city_bake` |
| `gtai.replay/1` | any path (`--record`, tests) | `ReplayLog.save` | `ReplayLog.load_file`, `--replay` |
| `gtai.bench/1` | `build/evidence/bench-<scenario>.json` | `dev/bench/city_bench.gd` | `tools/bench/run.mjs` |
| `gtai.quest/1` | `project/quests/<id>/quest.json` (copied from PoF `games/gtai/quests/<id>/`; the fixture is `project/tests/support/quests/_selftest/`) | PoF `/gta --quest` (contract: PoF `src/lib/games/gtai-quest/types.ts`) | `QuestLoader` (validated at the boundary, DAT-07) |
| `gtai.quest-rules/1` | `project/data/tables/quest_rules.json` (+ schema) | humans/agents | `QuestRules`, lint `data-tables` |
| `gtai.questMarkers/1` | supplied by the world (`QuestWorld.places()`); the fixture is `project/tests/support/quests/places.json` | humans/agents | `QuestPlaces` |
| `gtai.quest-selftest/1` | `build/evidence/quest-selftest.json` (an artifact of `scenario-tests`; its `quest*` numbers are that envelope's metrics) | `scenario_quest_selftest.gd` via `--evidence-dir` | `tools/tests/run_scenarios.mjs`, PoF |
| `gtai.steam-manifest/1` | `steam/manifest.json` | humans/agents | release checklist |
| `pof.godot-evidence/1` | `build/evidence/<kind>.json` (git-ignored) | `tools/evidence/run.mjs` | PoF `readEvidence` |

## `pof.godot-evidence/1` (written for PoF)

Envelope: `schema`, `kind` (`lint` / `unit-tests` / ...), `gameId: "gtai"`, `commit` (full HEAD
SHA at run time), `builtAt` (ISO), `godotVersion`, `status` (`pass`/`fail`), `summary`, and
optionally `counts {passed, failed, skipped}`, `metrics`, `artifacts` (paths relative to
`build/evidence/`). Optional keys are omitted, never null. PoF treats evidence whose `commit`
differs from HEAD as stale, so commit first, then run the writer.
