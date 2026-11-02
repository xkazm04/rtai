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
| `gtai.quest-rules/2` | `project/data/tables/quest_rules.json` (+ `project/data/schemas/quest_rules.schema.json`) | humans/agents | `QuestRules`, lint `data-tables`, **PoF's quest guard** (see below) |
| `gtai.questMarkers/1` | supplied by the world (`QuestWorld.places()`): markers (optional `phone`), vehicles, actors, `encounters`; the test stubs are `project/tests/support/quests/places.json` and `collect_call_places.json` | humans/agents (the city lane, at integration) | `QuestPlaces` |
| `gtai.quest-selftest/1` | `build/evidence/quest-selftest.json` and `quest-collect-call.json` (artifacts of `scenario-tests`; their numbers are that envelope's `quest*` and `collectCall*` metrics) | `scenario_quest_selftest.gd`, `scenario_quest_collect_call.gd` via `--evidence-dir` | `tools/tests/run_scenarios.mjs`, PoF |
| `gtai.steam-manifest/1` | `steam/manifest.json` | humans/agents | release checklist |
| `pof.godot-evidence/1` | `build/evidence/<kind>.json` (git-ignored) | `tools/evidence/run.mjs` | PoF `readEvidence` |

## `pof.godot-evidence/1` (written for PoF)

Envelope: `schema`, `kind` (`lint` / `unit-tests` / ...), `gameId: "gtai"`, `commit` (full HEAD
SHA at run time), `builtAt` (ISO), `godotVersion`, `status` (`pass`/`fail`), `summary`, and
optionally `counts {passed, failed, skipped}`, `metrics`, `artifacts` (paths relative to
`build/evidence/`). Optional keys are omitted, never null. PoF treats evidence whose `commit`
differs from HEAD as stale, so commit first, then run the writer.

## `gtai.quest-rules/2` (the quest runtime vocabulary, read by PoF)

`project/data/tables/quest_rules.json` is everything the quest runtime (`features/quest/`) can
play, and the source PoF's quest guard reads so the council never emits what the game lacks.
Canonical JSON (sorted keys, LF), validated by its schema in lint `data-tables`; every row has
an `id` and a `doc`. A `gtai.quest/1` package is playable when:

- **Verbs:** every `beats[].objective.verb` is a `verbs[].id`. Per row, `needs_target` means
  `objective.target` must be a tag the world resolves (`steal`/`hijack`: a vehicle; `kill`,
  `assassinate`, `escort`: an actor); otherwise the target is prose and is not read.
  `needs_location` means `objective.location` must name a place in the world's places table
  (`gtai.questMarkers/1`), and `needs_encounter` that the place holds an encounter. Places are
  the world's contract, not this table's: PoF can check verbs and tags, the game checks places.
- **Bark tags:** every `lines[].when[]` tag is either a bare `event_tags[].id` (it holds for
  `tuning.event_window_s` after its `fact`, which names the typed `Events` signal it comes from,
  or `quest:<verb>_done` for the contract's own objective), or `<kind>:<value>` with `kind` a
  `conditions[].id` and `value` in its `values`; `heat` takes `pattern` instead
  (`heat:>=2`). A line's tags are ANDed.
- **Fail states:** each `difficulty.failStates[]` phrase is matched against `fail_rules` on
  whole words (first rule whose every keyword group has a hit wins). An unmatched phrase only
  warns: the runtime cannot detect it. `arrived_hot` is a gate, not a failure.

A new verb, condition value or event tag is a row here plus its handler in `features/quest/`
(and, for an event tag, its signal in `events.json`), with a unit test; the schema id changes
when a row's shape does.
