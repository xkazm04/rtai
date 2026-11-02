# Data contracts

Every persisted or generated format names its schema and version (DAT-07).

| Schema | File | Writer | Reader |
|---|---|---|---|
| `gtai.achievements/1` | `steam/achievements/achievements.json` (+ `.schema.json`) | humans/agents | `tools/achievements/gen.mjs` |
| `gtai.achievements-runtime/1` | `project/data/generated/achievements_runtime.json` | gen.mjs (GENERATED) | AchievementTracker (planned) |
| `gtai.achievements-mirror/1` | `user://device/achievements_mirror.json` | `AchievementMirror` | `NullBackend`, later SteamBackend replay |
| `gtai.events/1` | `project/data/schemas/events.json` | humans/agents | gen.mjs, lint `events-registry` |
| `gtai.steam-manifest/1` | `steam/manifest.json` | humans/agents | release checklist |
| `pof.godot-evidence/1` | `build/evidence/<kind>.json` (git-ignored) | `tools/evidence/run.mjs` | PoF `readEvidence` |

## `pof.godot-evidence/1` (written for PoF)

Envelope: `schema`, `kind` (`lint` / `unit-tests` / ...), `gameId: "gtai"`, `commit` (full HEAD
SHA at run time), `builtAt` (ISO), `godotVersion`, `status` (`pass`/`fail`), `summary`, and
optionally `counts {passed, failed, skipped}`, `metrics`, `artifacts` (paths relative to
`build/evidence/`). Optional keys are omitted, never null. PoF treats evidence whose `commit`
differs from HEAD as stale, so commit first, then run the writer.
