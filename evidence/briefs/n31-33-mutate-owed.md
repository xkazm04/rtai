# n31-33 mutate-owed (builder tag `n31-33`): the three owed mutate scores (evidence only)

Read `evidence/briefs/n31-law.md` (binding). **Evidence only: no product, tool or test edits (the gate is green on `88bc88996`; a new test would leave the final commit ungated). The only tracked change is one appended section in `evidence/n31-ground/mutate.md`. Commit it by path by 06:55. Hard stop 07:00: report and END.** Started 05:59.

## Do (in this order; one mutate run at a time; lane Godot mutex lock `n31-33` around each run)
Use the form in `evidence/n31-ground/mutate.md` (n31-20) and `tools/mutate/README.md`. For each file, find its mapped tests (`node tools/tests/test_map.mjs <path>` or the tests that name its class) and pass them with `--tests=`; `--max=12`; restrict `--lines=` to the lines tonight's commits changed (`git log --oneline ba8e470b0..88bc88996 -- <file>` then `git diff -U0 ba8e470b0 88bc88996 -- <file>` for the hunks) where that leaves >= 8 mutants, else the whole file.
1. `project/features/characters/prop_base.gd` (or wherever `PropBase` lives: `git grep -l "class_name PropBase"`).
2. `project/features/characters/street_patrol_pose.gd` (find the real path the same way).
3. `project/core/render/print_stage.gd`.
If a run passes 15 minutes, let it finish but skip the remaining files when the clock is past 06:40.

## Deliver
Append `## n31-33 owed scores (HEAD <rev>, tests only)` to `evidence/n31-ground/mutate.md`: per file the exact command, `score x% = killed k / (k + s)`, timeouts, invalid, seconds, the survivor list (line + operator), and one line naming the candidate for a pinning assertion. A file not run: say so and why. Commit that one file by path (message `n31-33 ground: mutate scores prop_base / street_patrol_pose / print_stage`). Do not delete anything in Temp you did not create; the mutate tool cleans its own temp worktree (check `ls $LOCALAPPDATA/Temp | grep gtai-mutate` before and after and report leftovers it made).

## Owned
`evidence/n31-ground/mutate.md` (append), `build/n31/n31-33/**`. Everything else: forbidden.

## Report (final message)
The three scores, the commit hash, minutes, leftovers.
