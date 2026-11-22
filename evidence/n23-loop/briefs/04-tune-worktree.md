# Brief 04 `tune-worktree`: run tuning cycles in an isolated tune worktree, death-wave cycles over three profiles (lane loop, n23)

Updated by session 3 (04:15): street is merged (2b2ff79d4), the death metric, targets.json, the point verdict and the repair/cost/max_alive knobs landed in brief 03 (CHECK `git log --oneline -12`).

Hard stop: 05:53 wall clock (the call is stopped at 75 min). Commit deadline: 05:48.
Fix lint and format findings in your own edit and go on. Commit each step as it lands.

## Goal

The director must tune while Astra works in the lane tree, and batches must never run on a tree that is being edited (two baseline batches tonight ran while files changed under them). `tools/gauntlet/night.mjs` runs a whole cycle (before, null salt, report, propose, apply, confirm, revert) in the CURRENT tree and needs a `n2x-tune-*` branch. Make it run in its own git worktree, and score a cycle by the death wave of all three profiles (brief 03 built the death metric and `tools/gauntlet/targets.json`; CHECK it landed).

## Work, in order (commit each)

0. **Bounded runs score.** The gauntlet now caps a run at 216000 ticks (street's `RUN_TICKS`), and capped average/expert runs cost ~5 min each. The director bounds cost with the batch's `--waves=<N>`. Today `death_score.mjs` `deathScore` returns null for a run that ended by the wave limit (no death, not capped): make it a censored score at `wave_reached` (exactly like a capped run) when the batch's `args.waves` is set and the run reached it; reports and confirm use it; the death-wave report says `censored at the wave limit N` vs `at the tick cap`. Tests. `night.mjs --waves=<N>` passes it to every batch.
1. **`night.mjs --worktree=<abs path> --branch=n23-tune-<k>`**: creates (or reuses, if it is a worktree of this repo on that branch) a git worktree at the given path on a new branch cut from the lane HEAD, prepares it exactly as `tools/gauntlet/ablate.mjs` does (reuse its code: `tools/mutate/worktree.mjs` safety rules, native DLLs, the import-cache seed; move the shared part into a helper both use), runs every step there, writes all outputs to `--out` (an absolute path in the LANE tree under `evidence/n23-loop/`), and leaves the worktree and branch in place (kept commits live there; the director merges the branch). `--remove` deletes it (and `git worktree prune`) when the branch has no commit beyond the lane HEAD. Refuse a path inside the lane tree, an existing non-worktree directory, or a branch that is not `n23-tune-*`. Node tests for argument parsing and refusals (no Godot in the unit tests).
2. **Reuse measured batches.** `night.mjs --before=<batch.json> [--null=<batch.json>]` skips the before (and null) batch and uses the given ones (absolute paths, anywhere under the lane's `evidence/`); refuse a before batch whose table hashes do not match the tune worktree's tables, or a null batch whose seeds/profiles/controls/pick differ from the before batch. The director's first cycle reuses `evidence/n23-loop/base-street/batch.json` + `evidence/n23-loop/base-street-salt1/batch.json` (10 seeds x 3 profiles each). Later cycles chain: a kept cycle's after batch is the next cycle's before. `--after-from=<batch.json>` likewise lets the director hand in an after batch measured with `tools/gauntlet/ablate.mjs --set` and only run confirm/revert. Plus `node tools/gauntlet/tune.mjs sets --plan=<plan.json>` prints the exact `--set=<file>#<pointer>=<value>` arguments (group members expanded, budget units applied) that reproduce the plan's edits, one per line, so `ablate.mjs` can measure a plan without a tune branch. Tests for the refusals and for `sets` on a group edit.
3. **Three-profile cycle.** `night.mjs --profile=all --metric=death`: before batch over all three profiles, null-salt batch over all three profiles, propose against `targets.json` per profile (one change per cycle may serve several profiles; the plan says which), apply, confirm with all three, per-profile verdicts against the same-profile null floor of death waves; a change is kept only when no profile moves AWAY from its target by more than its floor. `--jobs=<1|2>` passed to every batch (the director decides; default 1).
4. **Cycle summary** `night.md`: per profile: death wave median and spread before/after, target, floor, separation (gap and seed share) before/after, the change ledger. One line `cycle <k>: <kept|reverted> <knob> <before -> after>` at the top for the director's JOURNAL.
5. `docs/gauntlet-loop.md`: "A night with runs that end in death": the measured wall time per cycle (from tonight's manifests), how many cycles a night affords.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
- One dry run: `node tools/gauntlet/night.mjs --worktree=<tmp> --branch=n23-tune-0 --profile=all --metric=death --seeds=2 --out=<lane>/build/n23/night-dry --dry-run` prints the steps and the paths; then `--remove` cleans it. `git worktree list` afterwards shows no worktree of yours.
- **No Godot run of yours at all** (no smoke, no run_unit, no mutate): the director has two Godot batches running and the lane may hold only two. Your work is Node-only; `node --test` and lint are enough.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. No Godot process of yours (see Acceptance). Do not touch `evidence/n23-loop/base-street*` or the director's running `tools/gauntlet/ablate.mjs` worktrees under Temp. Never kill a process you did not start. Never touch another lane's worktree.

## Files

Allowlist: `tools/gauntlet/**`, `tools/mutate/worktree.mjs` only to export a helper without changing its behaviour (its tests must stay green), `docs/gauntlet-loop.md`. Any other path: stop and report a NEED. Forbidden: every table, `project/**`, `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-*`, other worktrees.

## Repo law

Staged per path; no stash / add -A / commit -a / reset --hard / amend / rebase / push / `--no-verify`. Small files and functions.

End with: files changed, commits, commands and results, anything not done and why.
