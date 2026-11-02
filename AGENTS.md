# AGENTS.md - RTAI: Uprising (internal id `gtai`)

Every human and agent working here is bound by [`STANDARDS.md`](STANDARDS.md). This file is the
short operational view; when the two disagree, STANDARDS wins. Deviations are written to
[`docs/decisions.md`](docs/decisions.md) as `DEVIATION <RULE-ID>` lines with a re-check trigger.

Public-facing strings say **RTAI** ("Robot Theft A.I."). Code, paths and PoF ids keep `gtai`.

## Commands

Set `GODOT_BIN` to the Godot 4.7.2 console binary first (see `versions.toml`).

| Command | `just` recipe | What it does |
|---|---|---|
| `node tools/lint/lint.mjs` | `just lint` | gdformat, gdlint, file/function size, banned-API grep, `Steam.` grep, canary, achievements validate |
| `node tools/tests/run_unit.mjs` | `just test` | headless import, then GUT over `tests/unit` + `tests/integration` |
| `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` | `just scenarios` | scenario suite (incl. the 60 s replay); exits non-zero on failure, any script error, or unknown args |
| `"$GODOT_BIN" --headless --path project -- --replay=<file>` | | re-runs a `gtai.replay/1` log; exit 0 identical, 1 diverged, 2 unreadable (SIM-05) |
| `node tools/achievements/gen.mjs validate\|emit\|--check` | `just ach` | achievements schema + ACH-04 rules; emits `AchIds` and runtime JSON |
| `node tools/evidence/run.mjs` | `just evidence` | lint + unit tests, then writes `build/evidence/{lint,unit-tests}.json` (`pof.godot-evidence/1`) |
| (stub) | `just parity`, `just export`, `just audit` | land with the native port and the first export ticket |

Install the pre-commit hook once per clone: `git config core.hooksPath .githooks`.

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
