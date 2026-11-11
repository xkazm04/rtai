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
| `node tools/tests/run_unit.mjs --changed` / `--select=<basenames>` / `--test=<name>` / `--fast` / `--all` | | the inner loop: `--changed` maps your diff to the tests that name its classes (falls back to the fast suite, saying why); `--fast` skips the slow tier (`tools/tests/tiers.json`); every run prints a `file:line test - message` digest per failure and the 10 slowest; a failing file is re-run once alone and a fail-then-pass is reported `FLAKY` and appended to `%LOCALAPPDATA%/gtai/flakes.jsonl` (`node tools/tests/flakes.mjs report` lists repeat offenders). The no-arg run (and evidence) still runs everything |
| `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` | `just scenarios` | scenario suite (incl. the 60 s replay); exits non-zero on failure, any script error, or unknown args |
| `"$GODOT_BIN" --headless --path project -- --replay=<file>` | | re-runs a `gtai.replay/1` log; exit 0 identical, 1 diverged, 2 unreadable (SIM-05) |
| `node tools/achievements/gen.mjs validate\|emit\|--check` | `just ach` | achievements schema + ACH-04 rules; emits `AchIds` and runtime JSON |
| `node tools/evidence/run.mjs` | `just evidence` | lint, unit, scenarios, parity, bench; writes `build/evidence/<kind>.json` (`pof.godot-evidence/1`) |
| `cd native && scons platform=windows arch=x86_64 target=template_debug` (and `template_release`, `tests`) | `just native` | builds the CitySim GDExtension (+ `scons tests`: the standalone core tests); then `--import` once so Godot registers it |
| `node tools/tests/run_parity.mjs` | `just parity` | NAT-06 gate: native vs GDScript reference, 1200 steps exact + a planted mutation caught |
| `"$GODOT_BIN" --headless --path project -s res://dev/bake_city.gd [-- --check]` | `just bake` | bakes the 256 GTCH chunks (git-ignored) + the golden hash list; `--check` = AST-12 |
| `node tools/bench/run.mjs [--headless]` | `just bench` | exports `windows-bench`, runs the crowded drive + 400-actor riot, judges section 20 |
| `"$GODOT_BIN" --headless --path project -s res://dev/bench/rig_bench.gd -- --out=build/evidence/rig-bench.json` | | F-09b rig stress at 50 and 200 people (16 full rigs, the rest baked), judges the section 20 rig cost |
| `"$GODOT_BIN" --headless --path project -s res://dev/sim/car_route_trails.gd -- --out=<abs path, no ext> [--seconds=60]` | | the reference sim's real car code on a hand-made map (roads ending at a plaza, a kerb, void): trails at 4 px/m, each U-turn boxed, `.png` + `.json` (U-turns per car and the tile ahead). Run it in two worktrees for a routing before/after |
| `"$GODOT_BIN" --rendering-driver d3d12 --path project -s res://dev/showcase/rig_showcase.gd` | | Rivet, cops and peds at 32 and 48 px/m with `look_d4` + the baked crowd atlas -> `build/evidence/frames/` (needs a GPU) |
| `node tools/evidence/run.mjs [--no-parity] [--no-bench] [--bench-headless] [--no-release]` | | also writes `scenario-tests`, `parity`, `export-audit` (release-compile), `bench` evidence |
| `node tools/mutate/mutate.mjs --file=<project-relative .gd> [--max=N] [--tests=<basenames>] [--json]` | `just mutate` | real mutation testing: plants single-line faults in the file (in a worktree under the OS temp dir, never in your checkout), runs the mapped tests, prints survivors first and killed/(killed+survived). Run it on the file you changed BEFORE claiming "planted faults caught" and quote the score; commit first (it mutates HEAD). See `tools/mutate/README.md` |
| `node tools/tests/release_compile.mjs` | | compiles what a release export ships (a temp copy without `tests/`, `dev/`, `addons/gut`); exit 1 names any script that only compiles with dev code present |
| `node --test "tools/lib/*.test.mjs" "tools/lint/*.test.mjs" "tools/tests/*.test.mjs" "tools/debt/*.test.mjs" "tools/evidence/*.test.mjs" "tools/dev/*.test.mjs" "tools/selftest/*.test.mjs"` | | the Node tooling's own tests (the glob form: `node --test <dir>` fails on Node 24) |
| `node tools/tests/test_map.mjs [<paths>] [--why=<test>] [--history[=600]]` | | what `--changed`/mutate select and why: res:// refs (exact or nearest ancestor dir), tables, class/autoload names plus one dependent hop (`tools/tests/reach_index.mjs`, `reachOf(changed, index)` -> per-test chains); `--why` prints the chain (exit 1 not reached); `--history` replays the last N non-merge commits (FULL share, mean files). dev/ nothing names and tests/scenarios map to no unit tests; autoloads, schemas, support and unreferenced assets stay FULL |
| `node --test "tools/evidence/*.test.mjs"` | | evidence scope (`tools/evidence/scope.mjs`): docs/**, evidence/** and root JOURNAL.md / REPORT.md are inert. `run.mjs` refuses only code dirt, an inert-only dirty tree runs and every summary ends `[inert: N docs/evidence paths uncommitted]`, and import churn fails unit-tests only on code paths. The guard test fails if an evidence-kind tool starts reading an inert root |
| `node tools/dev/run.mjs <entry> [--windowed] [--timeout=<s>] [--result=<file>] [--dry-run] [--quit-after=<n>] [entry flags] [-- verbatim]` | `just dev` | one front door for a dev scene or -s script: a bare name is searched in `project/dev`, and the scene path goes before `--`, flags after. A flag missing from the entry's OWN declared `const KNOWN_FLAGS`/`KNOWN` exits 2 with a did-you-mean and nothing is spawned; an entry with no declared list launches with "flags unchecked: no declared spec". A declared `const RUN_TICKS: int = <n>` adds `--fixed-fps 60 --quit-after <n>` unless given. Log to `build/dev/`; ends with one `tools/lib/dev_verdict.mjs` line (`ok exit 0; SCRIPT ERROR 0; unknown arg 0; result fresh; ...`) to paste into a REPORT |
| `node tools/evidence/cites.mjs <REPORT.md\|decisions.md>... [--all] [--json] [--tracked] [--strict] [--root M=<dir>]` | `just cites` | resolves every backtick path a REPORT or decision line cites (braces, itN..itM, `:L,M`, root aliases declared in the report's prose): MISSING (with a did-you-mean from git ls-files), MISSING-LINE, UNTRACKED (on disk, not committed: dies with the worktree), IGNORED, PATTERN, UNCHECKED (undeclared root); exit 1 on MISSING/MISSING-LINE (+UNTRACKED with --tracked, +UNCHECKED with --strict). Run it at REPORT time instead of re-checking paths by hand |
| `node tools/perf/fight_gate.mjs [--arms=off:<flags>,on:<flags>] [--scenes=city,horde] [--rounds=6] [--quiet=<cores>] [--no-export]` | | the combat frame gate (n12): exports windows-showcase, runs reel chapter 18's city block fight and the arena horde under the Gatling, both at combo 32 px/m, release, 1080p, vsync off, `--fixed-fps 60`; per arm frame p50 / p99 / worst / frames over 25 ms, process CPU s and the cores OTHER processes took (any process, not only Godot); the first arm gets an identical A/A twin, so every table prints its own noise floor, and each other arm is a paired delta per round with a CI95 and a sign test. Before/after = two flag sets on one build. `--quiet` waits before each run while the machine is busier. Writes `build/perf/fight-gate/<stamp>/gate.json` (`gtai.fight-gate/1`); about 2 min a round. Dev command, not an evidence kind: its verdict is relative to its own A/A, and the absolute section 20 limits are the bench's |
| `node tools/tests/run_unit.mjs --failed` | | re-runs only the files that failed in the previous `build/test-results/unit-tests.junit.xml` (exit 2 if there is none). Every red run prints one triage block per failure (cause lines from junit + the ERROR/at:/frame under that test in the log; verdict REACHED by <path> / FULL / UNMAPPED: the map is not exhaustive / UNREACHED (only after an exhaustive referrer walk) / PARSE <file:line>; flake history; paste-ready rerun) and writes `build/test-results/unit-triage.json` (`gtai.unit-triage/1`): read that instead of grepping the log |
| (stub) | `just export`, `just audit` | land with the first export ticket |

Lint's `layers` check: boot/core/features never name a `dev/` or `tests/` class or an unguarded
`res://dev` path (a release export drops them), core never names a features class, and names are
snake_case (LAY-02). Its allowlists in `tools/lint/layers.mjs` only shrink. Test scratch files go
through `TestTmp.dir("<sub>")` (`user://test_tmp/<worktree>/<pid>/`); lint bans raw
`user://test_tmp` and `user://test_save` under `tests/`, because every worktree shares one `user://`.

Install the pre-commit hook once per clone: `git config core.hooksPath .githooks`.

Godot launcher extras (`tools/lib/godot.mjs`): every `runGodot` first runs `--import` when the class
cache is stale (`tools/lib/class_cache.mjs`; once per process, logged, not for `--import` itself), so a
merge no longer leaves scenarios/parity/bench on a stale cache. `node tools/godot/check.mjs <res://path|file>...`
is the safe parse check (`--check-only` for `.gd`, a throwaway load for `.tscn/.tres`; 60 s tree-kill;
exit 0 ok, 1 errors, 2 usage). Every run registers in a machine-wide ledger (`%LOCALAPPDATA%/gtai/runs`,
override `GTAI_RUNS_DIR`; `tools/lib/run_ledger.mjs`). `run_scenarios.mjs` passes `GTAI_CONTENTION`/`GTAI_CONTENTION_FILE`;
a miss of the two wall-clock budgets (city_chase nav 2 ms, rig_stress p50 1 ms) while others run logs
`CONTENDED: <metric> ...` and passes, then those scenarios are re-run alone once the machine is quiet
(`--quiet-wait=<min>`, `--only=<names>`); an idle-machine miss FAILS, a machine that never quiets leaves the
summary saying CONTENDED. `GTAI_BUDGET_SCALE=0.001` (test only) forces the miss. `tools/bench/run.mjs` queues FIFO
behind other runs and `bench.lock` with an ETA (`--wait=<min>`, default 20, then it runs flagged CONTENDED).

Debt ratchet: `node tools/debt/debt.mjs --check` (lint check `debt-ratchet`) fails when a debt metric is worse than `tools/debt/baseline.json`; it names metric, file and old -> new, so shrink or remove what it names. When it prints `tighten:`, run `node tools/debt/debt.mjs --update` and commit the baseline (it only ever tightens; a deliberate rise needs `--accept-regression="reason"`). After a baseline merge conflict run `node tools/debt/merge_baseline.mjs` (the looser of both sides, staged), commit, then `--update`. Details: `tools/debt/README.md`.

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
