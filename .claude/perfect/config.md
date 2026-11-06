---
product: "RTAI: Uprising (gtai) - development & testing toolchain"
stack: "Godot 4.7.2 GDScript (GUT 9.7.1) + C++ GDExtension sim; zero-dependency Node 24 ES-module tooling under tools/; Python asset tools; Windows 11 host shared by many concurrent agent lanes"
vault: []
vault_subdir: Perfect
base_branch: main
wave_size: 3
lot_caps: {godot: 2}
pool_target: 10
round_shape: pool
cooldown_rounds: 2
commit_format: "tools(<context>): <title>"
context_map: .claude/perfect/context-map.json
active_runs_ledger: ""
locale_count: 1
---

# /perfect overlay - gtai

**Focus of this loop (owner steer, 2026-11-06):** perfect the DEVELOPMENT and TESTING tools and techniques,
not the game. The repo is built by AI agent lanes almost 24/7 (3,700+ commits in 5 days, ~15 worktrees),
so the payoff is (a) tooling that stops tech debt from accumulating and (b) tooling that removes the
friction agents hit every iteration. Large custom tooling is in scope.

The context map is provisional and tooling-shaped (`.claude/perfect/context-map.json`), written by the
Director at init - there is no repo-wide `context-map.json`.

## Gates

GODOT_BIN must be exported first (on this machine:
`C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`).

- always: `node tools/lint/lint.mjs` (~35 s) and `node tools/tests/run_unit.mjs` (GUT, headless)
- when `project/tests/scenarios/**` or `tools/tests/run_scenarios.mjs` changed: `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`
- when `native/**` or `tools/gen_constants/**` changed: `node tools/tests/run_parity.mjs`
- when `tools/**/*.mjs` changed: the Node self-tests for tools (none exist at init - see context `tool-selftests`)
- slow: `node tools/evidence/run.mjs --no-bench` (run_in_background; needs a clean tree)
- builder: lint + the unit suite (or the targeted GUT file plus lint when the lot only touches Node tooling)
- visual: none - this loop does not change rendering; a lot that does is out of scope

## Class B

- `docs/decisions.md` (append a dated line, anchored on your own text)
- `project/addons/VENDORS.md`
- `AGENTS.md` command table rows (append a row; never reorder)
- `justfile` (append a recipe)

## Class C

- the git index
- `.claude/perfect/**` and the vault
- `project/data/generated/**`, `project/features/city/sim/sim_constants.gd`, `native/sim_core/src/sim_constants.h` (codegen outputs; regenerate, never hand-edit)
- `STANDARDS.md` (owner text; a builder may propose a rule, the Director writes it as a DEVIATION/DECISION line)
- `.github/workflows/ci.yml`, `.githooks/*` (tree-wide effect on every lane: Director applies)

## Repo law

Read `AGENTS.md` (operational) and `STANDARDS.md` (wins on conflict) before writing anything. Digest:
- Stage per path. Never `git add -A`/`.`/`-u`, never `git stash`, never `reset --hard`, never amend.
- GDScript: typed everything (warnings are errors), ~200 LOC per file (hard stop 300), functions <= 40
  lines, <= 5 params. No `print()` (use `Log`), no raw keycodes, no hardcoded UI text.
- Node tools are zero-dependency ES modules (`tools/**/*.mjs`, Node 24). Shared helpers live in
  `tools/lib/` - reuse `repo.mjs` (`ROOT`, `run`, `godotBin`, `walk`, `git`) before adding a helper.
- Tools never live inside `project/`; debug-only GDScript lives in `project/dev/` (excluded from exports).
- Data is canonical JSON with a schema (`tools/lib/canonical_json.mjs`, `mini_schema.mjs`).
- Commit `.uid`/`.import` with their source; never commit `.godot/` or `build/`.
- No global RNG, no frame delta in sim code.
- This machine is SHARED with live agent lanes: never kill a Godot process you did not start (by PID only),
  respect `bench.lock` / the image lock, write logs under `build/` (never `/tmp/ev.log`).
- Out of scope walls: game behaviour and balance, art, Steam metadata, `native/` sim semantics.

## Context sources

The map is the queue and the name source. No Personas ledger (`.personas/` absent): coverage emission
is skipped. Lane REPORT.md files under `docs/{day,night,eve}/<date>/<lane>/` carry a "What blocked or
slowed the lane" section - that is the primary evidence of tooling friction; cite it.

## Smoke

No app smoke for this loop: verification is running the changed tool against the real repo and against
a planted fault (TST-05 spirit: every new guard proves it can fail).

## Opportunity arcs

- Friction most cited across 20+ lane reports (2026-11-02..05): GODOT_BIN unset -> "import exit -1" /
  stale counts; `-s` parse errors hang Godot with exit 0; stale class cache after merges; evidence run
  refusing a dirty tree; bench lock and machine contention (wall-clock budgets flake, bench never ran);
  shared `user://` and `/tmp` paths racing between lanes; LFS pointers copied as assets; silently ignored
  launch args; files hitting the 300-LOC hard stop; full unit run not fitting the end-of-session window.
- Debt signals at init: `project/dev/` is 17.4k LOC / 189 files (features are 38k); ~200 distinct `--flag`
  strings; A/B "old default one flag away" flags accumulate; 22 DEVIATION lines with re-check triggers
  nobody checks; `evidence/` is 550 MB / 447 entries; the Node tooling has no tests of its own (TST-06).

## Vetoes

- Do not re-propose GUT vs gdUnit4 (settled 2026-11-02, docs/decisions.md).
- CI is defined but not run remotely; do not make remote CI a prerequisite for any direction.

## User taste

- Outcome-value over cosmetic churn: a direction must remove measured friction or prevent a named class
  of debt. Heavy custom tooling is welcome (owner, 2026-11-06).

## Skill improvement log
