# Brief 03 (lane loop, n22): the tuner

Wall-clock: you start about 02:06. **Commit deadline 03:10, hard stop 03:20**. Small commits; never amend, never rebase.

## Context (read, do not re-derive)
Read first: `docs/gauntlet-loop.md`, `tools/gauntlet/batch.mjs`, `tools/gauntlet/report.mjs` and their tests (landed in the previous call), `project/features/gauntlet/bot/` (the test player). Design: `C:\Users\kazda\kiro\gtai\.spark\Spark\ideas\combat-gauntlet.md` (read only).

The owner's rule for the tuner, verbatim intent: the loop **tunes numbers itself**, at most 20 % per number per night and at most 2x from the first night's value, on its own branch, every change listed. New mechanics, skills and weapon effects are only proposed, never switched on. It never edits code.

## Goal: `tools/gauntlet/tune.mjs`
Subcommands, all pure Node, no network:
- `propose --batch=<batch.json> [--target-s=15] [--profile=average] --out=<plan.json>`: reads the batch (and the report's per-wave and per-enemy numbers: import report.mjs's functions, do not re-implement them), finds **measured misses** (a wave whose `average` median seconds misses 15 s by more than 20 %; a profile spread that collapsed, e.g. novice and expert reaching the same median wave; an enemy that is the killer in more than X % of deaths; a bonus whose take-vs-decline difference is beyond the noise in either direction), and proposes changes to **table numbers only**, each tied to its miss in one sentence with the numbers ("wave 6 median 31 s against 15 s: shield_robot present in 9/10 of those waves, median 9.1 s to kill: shield_robot.hp 12 -> 10"). At most one change per knob per night; at most N changes per plan (`--max=6` default), largest miss first.
- The knobs it may touch are listed in `tools/gauntlet/knobs.json` (you write it): each knob = `{id, file (repo-relative table path), pointer (JSON pointer into the table), kind: int|float, min, max}` for enemy hp and damage (`enemies.json` rows and their weapons block), weapon damage and cooldown (`weapons.json`), the guard block of `combat.json`, `gauntlet.json` `budget.base` / `budget.per_wave`. Read the real tables on this branch to fill the pointers; a pointer that does not resolve is reported and skipped, never invented. A knob for a table or row that does not exist yet (another lane's) is listed with `"pending": true`.
- **Clamps**: every proposed value is clamped to `0.8..1.25` of tonight's value (the value in the file now) **and** `0.5..2.0` of `tools/gauntlet/baseline.json`. `baseline.json` (`gtai.gauntlet-baseline/1`: `{created, git_sha, values{<knob id>: number}}`) is written on the first run that finds it absent and **never overwritten** (refuse with one line if asked; a new knob is appended to it with its current value, existing values never change). Int knobs round toward the unclamped direction but stay inside the clamp; a change that rounds to no change is dropped.
- `apply --plan=<plan.json>`: refuses unless the current git branch name starts with `n22-tune` (one line: "tuner applies only on its own branch"), refuses on a dirty tree outside `evidence/` and `build/`, edits only the JSON values named by the plan (keep key order and the file's formatting style: re-serialise like the repo's table writer does; check a round-trip on an untouched table is byte-identical before writing), then runs the tables' schema validation (find how the repo validates tables: `tools/data_lint/` or the unit tests) and commits each change as its own commit `tune(n22): <knob> <before> -> <after>: <miss>` staging only that file.
- `confirm --before=<batch.json> --after=<batch.json> --plan=<plan.json> [--revert]`: for each change, did its miss shrink beyond the noise (paired by seed: same seeds, same profile, same pick mode; use `tools/perf/paired.mjs` `paired`/`bootCi` and an A/A noise floor from the before batch)? Verdict `kept` / `reverted` / `noise`. With `--revert`, it reverts the commits of `reverted` and `noise` changes with `git revert --no-edit <sha>` (never reset). Writes `<dir>/tune-ledger.json` and `tune-ledger.md`: every change, before, after, baseline, the miss, the confirming number with its CI, the verdict.
- `tools/gauntlet/tune.test.mjs` (`node:test`): clamp math (20 % per night, 2x total, both directions, int rounding), baseline write-once, a pointer that does not resolve is skipped, propose on the fixtures finds a planted miss and ties it to its numbers, confirm labels a planted improvement `kept` and a planted nothing `noise`, `apply` refuses on the wrong branch (test with a temp git repo under the OS temp dir, cleaned up). Do not touch the real repo's branches in tests.
- `docs/gauntlet-loop.md`: fill the tuner section (what it may touch, the clamps, the branch, the ledger, how to undo).

## Files you may create or edit (allowlist; any other path: stop and report a NEED)
`tools/gauntlet/**`, `docs/gauntlet-loop.md`, `evidence/loop/**`. You read the tables; you do not edit any table in this call (the director runs `apply` on the tune branch later).
Forbidden: everything under `project/` (other lanes own the tables and code), every other worktree.

## Acceptance (quote results)
1. `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` clean (fix lint and format findings in your own edit and go on).
2. `node tools/gauntlet/tune.mjs propose --batch=build/gauntlet/fixture-batch/batch.json --out=build/gauntlet/fixture-batch/plan.json` (rebuild the fixture batch with batch.mjs `--from` first if missing): quote the plan's change list.
3. `node tools/gauntlet/tune.mjs apply --plan=...` on this branch (`n22-loop`) refuses with its one line.

## Repo law
Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push, do not merge or switch branches in this worktree. No network. End with a short report: files, commits, numbers, NEEDs, what you could not do.

## Machine and state notes (added 01:50)
- Before any Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop`. You should not need Godot in this call at all: the director runs Godot batches in this lane meanwhile, so **do not start Godot** (one Godot per lane). Node tests and lint only.
- n22-street, n22-guard and n22-foes heads are merged into this branch now (street runs real waves; `gauntlet.json` budget, `enemies.json` tiers and the four new rows `rocket_trooper`, `shield_robot`, `sentry_turret`, `war_machine` exist). Fill knobs.json from the tables as they are now.
- The director may commit merge or journal commits on this branch while you run; never stage a path you did not edit (`git add <path>` only), and before each commit run `git status --short` and stage only your own files.
- If `node tools/mutate/mutate.mjs` applies to a .mjs file it does not: mutate is for GDScript; skip it.
