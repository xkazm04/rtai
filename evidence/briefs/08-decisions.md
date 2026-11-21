# Brief 08 (lane loop, n22): append the lane's decision lines

Wall-clock: you start about 06:12. **Commit deadline 06:30, hard stop 06:35.** One commit. Never amend, never rebase.

## Goal
Append exactly these four lines, verbatim, to the end of `docs/decisions.md` (append-only, shared by four lanes: do not touch any other line, do not reorder, keep the file's line endings). Before appending, check that each path named in backticks exists (`node tools/evidence/cites.mjs docs/decisions.md` may be slow on the whole file; checking these paths with `ls` is enough). If a path is wrong, fix only that path in the line and say so.

```
- [2026-11-21] DECISION gauntlet-test-player (n22 loop): the test player's profiles (novice, average, expert: reaction ticks, aim error, share of tells read, guard lead, rest and retreat HP) are rows in a new `project/data/tables/test_player.json` with a schema, read by `project/features/gauntlet/bot/`, which reads only sim state and draws from its own stream seeded by the run seed, so a seed, profile, pick and controls replay byte-identically (15 of 15 repeats, `evidence/loop/street-final/determinism.json`). Rejected: constants in the bot script (the tuner and the owner could not see or move them). Re-check when a human playtest disagrees with a profile.
- [2026-11-21] DECISION gauntlet-tuner (n22 loop): `tools/gauntlet/tune.mjs` moves only the table numbers listed in `tools/gauntlet/knobs.json`, one step per knob per night within 0.8-1.25x of the current value and 0.5-2x of the write-once `tools/gauntlet/baseline.json`, applies only on a branch named `n22-tune*`, one commit per change, and keeps a change only when its paired improvement on the same seeds clears an A/A floor; everything else is reverted on that branch. Night 1: two cycles (10 and 30 seeds), ten HP cuts, all reverted as noise (`evidence/loop/tune2-after/tune-ledger.md`). Rejected: tuning on the lane branch, judgement calls on a change inside the floor. Re-check: the floor is built from different seeds and is too strict for a deterministic sim (REPORT Call 1, a null-perturbation floor).
- [2026-11-21] DECISION gauntlet-batch-jobs (n22 loop): `tools/gauntlet/batch.mjs` runs one Godot per job, default 1, capped at 2, because four lanes share the machine and the rule is one Godot per lane; a run that reaches the run tick cap alive is kept as capped, not failed. Rejected: a job per core. Re-check when the loop runs alone on a night.
- [2026-11-21] DECISION gauntlet-profiles-score (n22 loop): measured on 20 shared seeds (`evidence/loop/profiles-20/report.md`), the novice is clearly apart (median wave reached 10.5 against 21 and 24) but average and expert overlap because the 90 s wave timer ends 10 of 20 average and 17 of 20 expert runs; the loop reports timeouts on their own line and asks the owner whether a timed-out wave should end the run (REPORT Call 3). Rejected: changing the timer from the loop (street owns it). Re-check after Call 3.
```

## Files (allowlist; any other path: stop and report)
Edit: `docs/decisions.md` only (append). Read anything. Forbidden: every other path, `REPORT.md`, `JOURNAL.md`, `evidence/**`, `project/**`, `tools/**`, other worktrees. Do not switch branches or merge.

## Machine rules
- **No Godot** (a gate holds the lane's Godot). `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` if any tool needs it.
- `git add docs/decisions.md` only. No `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push. `git status --short` before the commit. Commit message: `docs: loop lane decision lines (n22)`.

## Acceptance (quote)
`git show --stat HEAD` (one file, 4 insertions, 0 deletions) and `tail -c 300 docs/decisions.md`.
