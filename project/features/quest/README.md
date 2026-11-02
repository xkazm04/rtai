# features/quest

The quest runtime (F-12): plays a `gtai.quest/1` package, the PoF wire contract in
`src/lib/games/gtai-quest/types.ts`. Ported subsystem by subsystem from the spike's
`game/quest/` (evolve `quest-runtime` f2fa88f). Depends only on `core/` and WorldContext, plus
the `QuestWorld` port it defines (LAY-05); the world is injected, never looked up.

Packages land in PoF's `games/gtai/quests/<id>/quest.json` and are copied into `res://quests/<id>/`.

- **Loader** (`QuestLoader`, `QuestValidator`, `QuestBeatValidator`, `QuestBuilder`): JSON as
  data (the `JSON` class only, SEC-02), every field the runtime reads validated with its JSON
  path, and a typed `QuestPackage` built only when there is no error (DAT-05).
- **Rules** (`QuestRules`, `QuestVerb`, `QuestFailRule`, `QuestCondition`):
  `data/tables/quest_rules.json` (`gtai.quest-rules/1`) holds the verbs the runtime plays, the
  fail-state keyword rules (whole words), the bark condition vocabulary and the timing.
- **Places** (`QuestPlaces`, `gtai.questMarkers/1`): the words a package names places and
  things with, resolved by the world. The quest never invents a position.
- **Text** (`QuestText`): symbolic keys (LOC-01) through `tr()`, the `@joke` overlay (LOC-06),
  and the package English as the fallback until the PO pipeline extracts quest text.
- **Runtime** (`QuestSystem`, `QuestRunner`, `QuestObjective`, `QuestWorld`): a `WorldSystem`
  that steps one contract on the fixed tick: offered (the payphone rings at the first beat's
  location) -> active (beat i) -> succeeded or failed. It emits `contract_started` and
  `contract_completed` through the injected bus, caps wanted at `heatPeak` through the world's
  setter, and pays through it. Time is ticks; the runtime draws no random numbers.
  `QuestWorld` is the port: the real systems implement it at integration, tests use
  `tests/support/stub_quest_world.gd`.
- **Lines** (`QuestLinePlayer`): a beat's `lineIds` queue as subtitles (typed out, then held);
  `when` lines are barks that fire once, the first active tick their conditions hold, and cut
  the queue. Timing reads the package's source text, so the replay hash ignores the locale;
  `subtitle()` resolves the words and speaker names through `QuestText`.

Tests: `tests/unit/test_quest_*.gd` (loader, rules, text, runner, objectives, lines) and the
scenario `tests/scenarios/scenario_quest_selftest.gd`, which plays the spike's `_selftest`
fixture headless to completion through `QuestBot` and the stub world, twice (bit-identical)
plus a planted fault, and leaves `quest-selftest.json` in the evidence directory.
