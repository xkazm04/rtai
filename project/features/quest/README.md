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
  `data/tables/quest_rules.json` (`gtai.quest-rules/2`) is the runtime's whole vocabulary: the
  verbs it plays, the fail-state keyword rules (whole words), the bark state conditions and
  event tags, and the timing. PoF reads it to guard the council (`docs/data-contracts.md`).
- **Facts** (`QuestFacts`): what barks react to: a per-tick world snapshot (soul, madness,
  heat, weapon) and facts recorded from the typed Events while the contract is active.
- **Places** (`QuestPlaces`, `gtai.questMarkers/1`): the words a package names places and
  things with, resolved by the world, plus which places have a payphone and which hold a
  combat encounter. The quest never invents a position.
- **Text** (`QuestText`): symbolic keys (LOC-01) through `tr()`, the `@joke` overlay (LOC-06),
  and the package English as the fallback until the PO pipeline extracts quest text.
- **Runtime** (`QuestSystem`, `QuestRunner`, `QuestObjective`, `QuestWorld`): a `WorldSystem`
  that steps one contract on the fixed tick: offered (the payphone rings at the first beat's
  location, or it begins at once where there is none) -> active (beat i) -> succeeded or
  failed. Verbs: go_to, deliver, steal, hijack, assassinate, kill, survive, defend, escort,
  evade, answer, meet, fight, sabotage. It emits `contract_started` and
  `contract_completed` through the injected bus, caps wanted at `heatPeak` through the world's
  setter, and pays through it. Time is ticks; the runtime draws no random numbers.
  `QuestWorld` is the port: the real systems implement it (quest 1: `boot/collect_call/`
  `CollectCallWorld`, with the payphone router answering `ring_phone`/`phone_answered` and the
  torch `sabotage_done`), tests use `tests/support/stub_quest_world.gd`.
- **Lines** (`QuestLinePlayer`): a beat's `lineIds` queue as subtitles (typed out, then held);
  `when` lines are barks that fire once, the first active tick their conditions hold, and cut
  the queue. A call (answer, or evade at a payphone place) holds its lines until the world's
  router connects it and ends when they have played; a meet plays each ally's lines when met. Timing reads the package's source text, so the replay hash ignores the locale;
  `subtitle()` resolves the words and speaker names through `QuestText`.

Tests: `tests/unit/test_quest_*.gd` (loader, rules, text, runner, objectives, lines) and the
scenario `tests/scenarios/scenario_quest_selftest.gd`, which plays the spike's `_selftest`
fixture headless to completion through `QuestBot` and the stub world, twice (bit-identical)
plus a planted fault, and leaves `quest-selftest.json` in the evidence directory; and
`scenario_quest_collect_call.gd`, which plays the shipped `res://quests/collect-call/` for real:
quest 1's stage (`boot/collect_call/`, heat, Patch's payphone router, the wallet, Dock 9 and
Mertz) through `CollectCallWorld`, `dev/bots/CollectCallBot` playing Rivet, twice plus two
planted faults; `CollectCallRecord.stubbed()` names what is still not the game.
