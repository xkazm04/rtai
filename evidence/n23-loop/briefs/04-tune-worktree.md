# Brief 04 `tune-worktree`: run tuning cycles in an isolated tune worktree, death-wave cycles over three profiles (lane loop, n23)

DRAFT by session 2 (02:58). The next director session fills HARDSTOP/COMMITBY and checks the CHECK lines.

Hard stop: HARDSTOP wall clock. Commit deadline: COMMITBY. Commit each step as it lands.

## Goal

The director must tune while Astra works in the lane tree, and batches must never run on a tree that is being edited (two baseline batches tonight ran while files changed under them). `tools/gauntlet/night.mjs` runs a whole cycle (before, null salt, report, propose, apply, confirm, revert) in the CURRENT tree and needs a `n2x-tune-*` branch. Make it run in its own git worktree, and score a cycle by the death wave of all three profiles (brief 03 built the death metric and `tools/gauntlet/targets.json`; CHECK it landed).

## Work, in order (commit each)

1. **`night.mjs --worktree=<abs path> --branch=n23-tune-<k>`**: creates (or reuses, if it is a worktree of this repo on that branch) a git worktree at the given path on a new branch cut from the lane HEAD, prepares it exactly as `tools/gauntlet/ablate.mjs` does (reuse its code: `tools/mutate/worktree.mjs` safety rules, native DLLs, the import-cache seed; move the shared part into a helper both use), runs every step there, writes all outputs to `--out` (an absolute path in the LANE tree under `evidence/n23-loop/`), and leaves the worktree and branch in place (kept commits live there; the director merges the branch). `--remove` deletes it when the branch has no commit beyond the lane HEAD. Refuse a path inside the lane tree, an existing non-worktree directory, or a branch that is not `n23-tune-*`. Node tests for argument parsing and refusals (no Godot in the unit tests).
2. **Three-profile cycle.** `night.mjs --profile=all --metric=death`: before batch over all three profiles, null-salt batch over all three profiles, propose against `targets.json` per profile (one change per cycle may serve several profiles; the plan says which), apply, confirm with all three, per-profile verdicts against the same-profile null floor of death waves; a change is kept only when no profile moves AWAY from its target by more than its floor. `--jobs=<1|2>` passed to every batch (the director decides; default 1).
3. **Cycle summary** `night.md`: per profile: death wave median and spread before/after, target, floor, separation (gap and seed share) before/after, the change ledger. One line `cycle <k>: <kept|reverted> <knob> <before -> after>` at the top for the director's JOURNAL.
4. `docs/gauntlet-loop.md`: "A night with runs that end in death": the measured wall time per cycle (from tonight's manifests), how many cycles a night affords.

## Acceptance

- `node --test "tools/gauntlet/*.test.mjs"` green; `node tools/lint/lint.mjs` green. Fix lint and format findings in your own edit and go on.
- One dry run: `node tools/gauntlet/night.mjs --worktree=<tmp> --branch=n23-tune-0 --profile=all --metric=death --seeds=2 --out=<lane>/build/n23/night-dry --dry-run` prints the steps and the paths; then `--remove` cleans it. `git worktree list` afterwards shows no worktree of yours.
- No Godot run of yours longer than a 2-seed smoke; the director runs the real cycles.

## Machine rules

`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/loop`, `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. At most ONE Godot process of yours; the director runs batches alongside. Never kill a process you did not start. Never touch another lane's worktree.

## Files

Allowlist: `tools/gauntlet/**`, `tools/mutate/worktree.mjs` only to export a helper without changing its behaviour (its tests must stay green), `docs/gauntlet-loop.md`. Any other path: stop and report a NEED. Forbidden: every table, `project/**`, `JOURNAL.md`, `REPORT.md`, `evidence/n23-loop/base-*`, other worktrees.

## Repo law

Staged per path; no stash / add -A / commit -a / reset --hard / amend / rebase / push / `--no-verify`. Small files and functions.

End with: files changed, commits, commands and results, anything not done and why.
