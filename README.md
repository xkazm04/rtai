# RTAI: Uprising

Internal id `gtai`. A top-down open-city crime sandbox where a factory robot goes rogue.
Godot 4.7.2 (GDScript + a C++ GDExtension later), shipping on Steam.

- **Rules:** [`STANDARDS.md`](STANDARDS.md) (authoritative), with the operational view in [`AGENTS.md`](AGENTS.md).
- **Decisions and deviations:** [`docs/decisions.md`](docs/decisions.md).
- **Pins:** [`versions.toml`](versions.toml).

## Setup

```sh
git config core.autocrlf input          # every clone and worktree (GIT-02)
git lfs install
git config core.hooksPath .githooks      # pre-commit runs the lint job
pip install "gdtoolkit==4.5.0"
export GODOT_BIN=/path/to/Godot_v4.7.2-stable_win64_console.exe   # or POF_GODOT_BIN
"$GODOT_BIN" --headless --path project --import
```

## Evidence for PoF

PoF reads game-written evidence (`pof.godot-evidence/1`). One command writes it:

```sh
node tools/evidence/run.mjs
```

It runs the lint job and then the unit tests headless, and writes:

- `build/evidence/lint.json` (+ `lint.log`)
- `build/evidence/unit-tests.json` (+ `unit-tests.junit.xml`, `unit-tests.log`)

Each file names the current `git rev-parse HEAD`, so **commit first, then run it**. PoF treats
evidence from another commit as stale. The writer refuses a dirty tree; `--allow-dirty` overrides
that and says so in every summary. It exits 0 only when every kind passes. `build/` is
git-ignored; point PoF at this repo with `POF_GAME_ROOT_GTAI` (or its `engine.root`).

## Other commands

| What | Command |
|---|---|
| Lint job | `node tools/lint/lint.mjs` |
| Unit tests (import, load every script, GUT) | `node tools/tests/run_unit.mjs` |
| Scenario suite | `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` |
| Achievements | `node tools/achievements/gen.mjs validate\|emit\|--check` |

`just lint|test|scenarios|ach|evidence` are shortcuts for the same commands.
