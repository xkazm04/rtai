# n22-street brief 01: the interface skeleton (commit first), then the seeded street

Lane `street`, worktree `C:\Users\kazda\kiro\gtai-wt\n22-street`, branch `n22-street`. Three other lanes
(guard, foes, loop) build against what you commit first, so the interface names below are wire names: use them
exactly and never rename them after the interface commit.

**Wall-clock hard stop: 01:20. Interface commit deadline: 00:50. Street commit deadline: 01:15.**
Commit in small steps. Fix lint and format findings in your own edits and go on. Never amend, never rebase.
No `git stash`, no `git add -A/./-u`, no `commit -a`, no `reset --hard`. Stage per path. Do NOT create git
tags (the director tags). Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/street`
and `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
(`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run). One Godot
process at a time; free your own by PID, never by name. Nobody rebuilds native. Mutate capped:
`node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed>`.

## Allowlist (any other path: stop and report `NEED <owner lane>: <file> <why>` in your final message)
- `project/dev/gauntlet/**` (new), `project/features/gauntlet/**` EXCEPT `project/features/gauntlet/bot/**`
  (that folder belongs to lane loop: never create or edit anything in it).
- `project/data/tables/gauntlet.json`, `project/data/tables/gauntlet_bonuses.json` and their schemas in
  `project/data/schemas/`.
- New tests `project/tests/unit/test_gauntlet_*.gd`, `project/tests/unit/test_stat_mods.gd`.
- Append-only, one line each: `docs/decisions.md`; `project/boot/launch_args.gd` `KNOWN_FLAGS` (only if the
  dev runner or lint really requires the global list; prefer the scene's own `const KNOWN_FLAGS`; if you add a
  line, accept the ratchet with `node tools/debt/debt.mjs --update --accept-regression="<flag> for n22 street"`
  and commit `tools/debt/baseline.json`); translation/string files only if `tr()` keys need a row (name them).
- Forbidden (other lanes): `project/features/player/**`, `project/features/combat/**` (shot, ai, squad,
  fight_areas), `project/features/arena/arena_projectiles.gd`, `arena_dodges.gd`, `enemies.json`,
  `weapons.json`, `combat.json`, `input_actions.json`, `TickInput`, `tools/gauntlet/**`,
  `docs/gauntlet-loop.md`. Reuse arena/combat classes by calling them; never fork or edit them. If a class you
  need lacks a hook, write it as a NEED and work around it in your own files.

## Context
Read first: `AGENTS.md`, `STANDARDS.md` (sections on layers, typing, RNG, sizes), and the design note
`C:\Users\kazda\kiro\gtai\.spark\Spark\ideas\combat-gauntlet.md` ("Scout digest", "Design decisions",
"Design brief": it has the file anchors). Build on: `ArenaSession` (`project/features/arena/arena_session.gd`,
`open`/`open_with_args`/`step`/`tick`/`close`; World + SimLoop + Rivet's controller + `CombatArena`, steps
headless), `arena_walls.gd` props (`wall_high`, `cover_high`, `cover_low` stop shots), `WaveRun` /`PitWaves`
(`project/features/combat/ai/wave_run.gd`), `ArenaTelemetry`, `ArenaArsenal.arm()`, `GhostLocks`,
`InputSource` (`project/core/replay/input_source.gd`), `ArenaWaveCards.Card` / `GhostCard` for card looks.
The dev runner: `tools/dev/run.mjs` (a bare name `gauntlet` is searched in `project/dev`; it checks flags
against the entry's own `const KNOWN_FLAGS`, and a declared `const RUN_TICKS: int` adds `--fixed-fps 60
--quit-after <n>`). Look at an existing dev entry that does this (e.g. `project/dev/bench/quest1_frames.gd`,
`project/dev/arena/`) and copy its pattern.

## Part A: the interface commit (deadline 00:50), one commit, message starting `gauntlet iface:`
A small working skeleton with real signatures; behaviour comes later behind it.
1. `project/features/gauntlet/stat_mods.gd`: `class_name StatMods extends RefCounted`;
   `const STATS: Array[StringName] = [&"hp_max", &"speed", &"damage", &"guard_meter", &"regen"]`;
   `add(stat: StringName, k: float) -> void` (multiplicative: value *= k; an unknown stat is a `Log` error and
   ignored); `value(stat: StringName) -> float` (default 1.0); `to_dict() -> Dictionary` (only stats that moved,
   sorted keys, for the result's `mods`). Fully working, with `project/tests/unit/test_stat_mods.gd`.
2. `project/features/gauntlet/gauntlet_pilot.gd`: `class_name GauntletPilot extends InputSource`, the hook
   lane loop's bot extends. Methods (with sensible no-op defaults): `configure(profile: StringName,
   pick_policy: StringName, seed: int) -> void`, `bind(run: GauntletRun, session: ArenaSession) -> void`,
   `pick(offered: Array[StringName]) -> int` (default: seeded draw for `&"random"`, 0 for `&"greedy"`),
   `profile() -> StringName`. The scene resolves `--bot=<profile>` like this: if
   `res://features/gauntlet/bot/gauntlet_bot.gd` exists (`ResourceLoader.exists`), instantiate it (it will
   extend `GauntletPilot`); else use your own fallback `project/features/gauntlet/gauntlet_walker.gd`
   (`class_name GauntletWalker extends GauntletPilot`: walks forward along the street, aims and fires at the
   nearest enemy; just enough for street's own headless testing). Never name a class from `bot/` in code.
   Write this contract as a doc comment at the top of `gauntlet_pilot.gd`.
3. `project/features/gauntlet/gauntlet_run.gd`: `class_name GauntletRun extends RefCounted`: `seed`, `wave`
   (int, 0 before the first), `picks: Array[Dictionary]`, `mods: StatMods`, `alive: bool`, `profile`,
   `controls`; `to_result() -> Dictionary` producing `gtai.gauntlet-run/1` exactly:
   `{schema, seed, profile, controls, wave_reached, death{wave, by}, waves[{n, seconds, enemies{<id>: count},
   damage_taken, guard_deflects, rolls, form_seconds{<form>: s}, shots, hits}], picks[{wave, offered[3],
   taken}], mods{<stat>: k}}`. `profile` is `"human"` when no bot. A value that was not measured is omitted,
   never 0 (so `death` is omitted while alive, `guard_deflects` is omitted until guard's code exists).
   Add `project/data/schemas/gauntlet_run.schema.json` (JSON schema for the result) so lane loop can validate.
4. `project/data/tables/gauntlet.json` (`"schema": "gtai.gauntlet/1"`, sorted keys) with `segments[]` (at
   least one template now; six in Part B), `budget{base, per_wave}`, `boss_every: 5`, `target_wave_s: 15`,
   `tier_unlock_wave[]` (index = tier-1, the first wave a tier may appear, e.g. `[1, 3, 6, 9, 10]`), and a
   provisional `tier_map{<enemy id>: tier}` for the six existing enemy rows (used until lane foes's `tier`
   column on `enemies.json` is merged; mark it provisional in the schema description). Plus
   `project/data/schemas/gauntlet.schema.json`.
5. `project/data/tables/gauntlet_bonuses.json` (`"schema": "gtai.gauntlet_bonuses/1"`): rows
   `{id, kind: "weapon" | "stat" | "ghost", ref, k, min_wave, weight}`; a key that does not apply is omitted,
   never null (`k` only on stat rows). Seed it already with the full set: at least 8 weapons across guns and
   melee (ids from `weapons.json`; read them, do not edit), the five stats in two strengths (e.g. `+10 %` and
   `+25 %`; `regen` and `guard_meter` too), the four ghost forms (ids from the ghost forms table). Plus its
   schema. Validate both tables the way existing tables are validated (find the table loader/validator and the
   test that checks every table has a schema).
6. `project/dev/gauntlet/gauntlet.tscn` + `gauntlet.gd` (scene root script): declares
   `const KNOWN_FLAGS` = `--seed`, `--bot`, `--pick`, `--waves`, `--result`, `--controls` and `const RUN_TICKS`
   (a sane headless cap, e.g. 60 s of ticks for now; say what you chose). Parses flags (`--bot` absent =
   human; `--pick` default `random`; `--controls` default `legacy`; an unknown value exits non-zero with one
   line), opens an `ArenaSession` (or the minimal world it needs) and, with zero waves implemented, writes a
   valid result to `--result=<abs json>` and quits cleanly. Byte-identical output for the same seed (sorted
   keys, no timestamps, no absolute paths in the JSON).
7. Unit tests: `test_stat_mods.gd`, `test_gauntlet_run.gd` (to_result shape, omitted-not-zero rule).
8. Check: `node tools/dev/run.mjs gauntlet --seed=7 --bot=average --waves=1 --result=<abs path under
   build/dev/>` ends with an `ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh` verdict line; run it twice
   and compare the files (identical); `node tools/lint/lint.mjs`; `node tools/tests/run_unit.mjs --changed`;
   `node tools/gate/quick.mjs` before the commit. A Godot `--import` before committing so every new `.gd`
   has its `.uid` (commit the `.uid` files with the sources).

## Part B: the seeded street (after Part A is committed; deadline 01:15)
A straight street assembled from segment templates in `gauntlet.json` `segments[]`. Each template: `id`,
`length_m` (about 30 m so a 15 s wave fits), side walls, solid cover props (reuse the arena prop kinds
`wall_high`, `cover_high`, `cover_low` so they stop shots through the existing code), enemy spawn points ahead
and on the flanks, and at least one `cover_high` a player can hide behind from a blast. At least six distinct
templates (e.g. plain block, crossing with a zebra, barricade line, parked-car row, narrow alley neck, plaza
with a kiosk). A wall never stands on a zebra crossing (if a template has a crossing, keep props off it, and
add a unit test that checks it for every template). The run's seed picks the order through
`ctx.rng.stream(&"gauntlet")` (or the registry's equivalent: no global randf/randi). `GauntletStreet`
(`project/features/gauntlet/gauntlet_street.gd`): keeps a window of segments (e.g. 3: current, next, the one
behind), adds one ahead when Rivet crosses into a new segment and drops the oldest, so the cost stays flat.
Rivet starts at the first segment with hands only and all ghost forms locked (use `GhostLocks`).
Tests: `test_gauntlet_street.gd` (same seed = same order; two seeds differ; window size stays flat over 50
advances; no prop on a crossing). If the seeded street is not done by 01:15, commit what works with its tests
green and say exactly what is missing.

## Final message
Commits (sha + subject), files, the dev-runner verdict lines, lint/unit/quick-gate results, the two
byte-identical result files' paths, the bot/pilot contract in three lines (for lane loop), every NEED, and
anything left undone.
