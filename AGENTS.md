# AGENTS.md - RTAI: Uprising (internal id `gtai`)

Every human and agent working here is bound by [`STANDARDS.md`](STANDARDS.md). This file is the
short operational view; when the two disagree, STANDARDS wins. Deviations are written to
[`docs/decisions.md`](docs/decisions.md) as `DEVIATION <RULE-ID>` lines with a re-check trigger.

Public-facing strings say **RTAI** ("Robot Theft A.I."). Code, paths and PoF ids keep `gtai`.

## Commands

Godot is found by `tools/lib/godot.mjs`: `GODOT_BIN`, then `POF_GODOT_BIN`, then a git-ignored
`tools/local.json` (`{"godot": "<path>"}`), then known install paths (incl. `../gtai-spike/tools/godot`),
then `godot` on PATH; it checks the version against `versions.toml` and fails with one line if not
found. Every runner goes through it: timeouts kill the whole process tree (the `_console.exe` spawns
the real engine as a child) and keep the partial log. The shell commands below still need `GODOT_BIN`.

| Command | `just` recipe | What it does |
|---|---|---|
| `node tools/lint/lint.mjs` | `just lint` | gdformat, gdlint, file/function size, banned-API grep, `Steam.` grep, canary, achievements validate |
| `node tools/tests/run_unit.mjs` | `just test` | headless import, then GUT over `tests/unit` + `tests/integration` |
| `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` | `just scenarios` | scenario suite (incl. the 60 s replay); exits non-zero on failure, any script error, or unknown args |
| `"$GODOT_BIN" --headless --path project -- --replay=<file>` | | re-runs a `gtai.replay/1` log; exit 0 identical, 1 diverged, 2 unreadable (SIM-05) |
| `node tools/achievements/gen.mjs validate\|emit\|--check` | `just ach` | achievements schema + ACH-04 rules; emits `AchIds` and runtime JSON |
| `node tools/evidence/run.mjs` | `just evidence` | lint, unit, scenarios, parity, bench; writes `build/evidence/<kind>.json` (`pof.godot-evidence/1`) |
| `cd native && scons platform=windows arch=x86_64 target=template_debug` (and `template_release`, `tests`) | `just native` | builds the CitySim GDExtension (+ `scons tests`: the standalone core tests); then `--import` once so Godot registers it |
| `node tools/tests/run_parity.mjs` | `just parity` | NAT-06 gate: native vs GDScript reference, 1200 steps exact + a planted mutation caught |
| `"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd [-- --check]` | `just bake` | bakes the 256 GTCH chunks (git-ignored) + the golden hash list; `--check` = AST-12 |
| `node tools/bench/run.mjs [--headless]` | `just bench` | exports `windows-bench`, runs the crowded drive + 400-actor riot, judges section 20 |
| `"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=build/evidence/rig-bench.json` | | F-09b rig stress at 50 and 200 people (16 full rigs, the rest baked), judges the section 20 rig cost |
| `"$GODOT_BIN" --rendering-driver d3d12 --path project -s res://dev/showcase/rig_showcase.gd` | | Rivet, cops and peds at 32 and 48 px/m with `look_d4` + the baked crowd atlas -> `build/evidence/frames/` (needs a GPU) |
| `node tools/evidence/run.mjs [--no-parity] [--no-bench] [--bench-headless]` | | also writes `scenario-tests`, `parity`, `bench` evidence |
| `node tools/tests/release_compile.mjs` | | compiles what a release export ships (a temp copy without `tests/`, `dev/`, `addons/gut`); exit 1 names any script that only compiles with dev code present |
| `node --test "tools/lib/*.test.mjs" "tools/lint/*.test.mjs" "tools/tests/*.test.mjs"` | | the Node tooling's own tests (the glob form: `node --test <dir>` fails on Node 24) |
| (stub) | `just export`, `just audit` | land with the first export ticket |

Lint's `layers` check: boot/core/features never name a `dev/` or `tests/` class or an unguarded
`res://dev` path (a release export drops them), core never names a features class, and names are
snake_case (LAY-02). Its allowlists in `tools/lint/layers.mjs` only shrink. Test scratch files go
through `TestTmp.dir("<sub>")` (`user://test_tmp/<worktree>/<pid>/`); lint bans raw
`user://test_tmp` and `user://test_save` under `tests/`, because every worktree shares one `user://`.

Install the pre-commit hook once per clone: `git config core.hooksPath .githooks`.

Debt ratchet: `node tools/debt/debt.mjs --check` (lint check `debt-ratchet`) fails when a debt metric is worse than `tools/debt/baseline.json`; it names metric, file and old -> new, so shrink or remove what it names. When it prints `tighten:`, run `node tools/debt/debt.mjs --update` and commit the baseline (it only ever tightens; a deliberate rise needs `--accept-regression="reason"`). After a baseline merge conflict take either side and re-run `--update`. Details: `tools/debt/README.md`.

## Folder map (STANDARDS section 2)

- `project/` is `res://`. `boot/` composition root, `core/` engine-agnostic infrastructure,
  `features/<name>/` one folder per feature (scene + script + local art), `data/` JSON tables +
  schemas + `generated/`, `tests/` (unit, integration, scenarios, parity, golden, saves, support),
  `dev/` debug-only code (excluded from release exports), `addons/` third-party only (see `VENDORS.md`).
- `tools/` Node + Python tooling (never inside `project/`). `steam/` all Steam metadata.
  `docs/` decisions, determinism, data contracts. `native/` C++ sim (lands with the native port).
- `build/` is git-ignored output: `build/evidence/` is what PoF reads.

## Top rules (the ones agents break first)

1. Stage per path. No `git add -A`/`.`/`-u`, no `git stash`, no `reset --hard`. Commit each task as it lands.
2. Type everything (GDS-01). Warnings are errors; a file that does not parse fails every test.
3. GDScript files about 200 LOC (hard stop 300), functions 40 lines or fewer, 5 parameters max.
4. No `print()`: use `Log`. No raw keycodes: use InputMap actions. No hardcoded UI text: `Loc.t()`/`tr()`.
5. Only `core/platform/backends/steam_backend.gd` may contain `Steam.`. Gameplay emits `Events` only.
6. Data is JSON with a schema and stable string ids; never hand- or AI-written `.tres` balance data.
7. Never `load()` player-editable `.tres/.res/.scn`; never `str_to_var`/`ConfigFile` on external data.
8. Commit `.uid` and `.import` files with their source; never commit `.godot/` or `build/`.
9. No global `randf`/`randi`/`seed()`/`shuffle()`/`pick_random()`: take `ctx.rng.stream(&"system")`.
   No frame delta either: sim code steps on `SimClock.TICK_DT`; only `World._process` reads `delta`.
10. Every new addon needs a `project/addons/VENDORS.md` line and the owner's OK.

## Copy this

**A RefCounted logic class** (`project/core/<area>/<thing>.gd`):

```gdscript
class_name Thing
extends RefCounted

signal changed(new_value: int)

const MAX_VALUE: int = 10

var _value: int = 0


func set_value(value: int) -> void:
	_value = clampi(value, 0, MAX_VALUE)
	changed.emit(_value)


func value() -> int:
	return _value
```

**A unit test** (`project/tests/unit/test_<thing>.gd`, GUT 9.7.1):

```gdscript
extends GutTest


func test_value_is_clamped() -> void:
	var thing: Thing = Thing.new()
	thing.set_value(99)
	assert_eq(thing.value(), Thing.MAX_VALUE)
```

**A data table**: `project/data/tables/<table>.json` with `"schema": "gtai.<table>/1"`, sorted keys,
rows keyed by snake_case `id`, plus `project/data/schemas/<table>.schema.json`.

**A decision line** in `docs/decisions.md`:
`- [YYYY-MM-DD] DECISION <area>: what was chosen, why, what was rejected.`
