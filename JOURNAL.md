# JOURNAL n27 lane `pressure` (2026-11-24)

Branch `n27-pressure`, worktree `gtai-wt/n23-loop`, cut from `main` `a3b3f1466`. Director: Opus; builder: Claude Sonnet 5.5
(`gtai-n27/tools/builder.mjs`). Continues `docs/day/2026-11-23/n26-pressure/`.

## Session 1 (02:45 to 04:15, BUILD)

- 02:45 start. Read n26 REPORT/JOURNAL. No builder lock, no calls yet. No `NEED pressure` from tonight's lanes.
- 02:47 Godot `--import` once (exit 0, `build/import-n27.log`).
- 02:50 MILESTONE item 1 started: median batches on main `a3b3f1466` (salt 0 then salt 1; profile all, greedy, wheel,
  10 seeds, 40 waves), detached pid 58928 (bash) running `evidence/n27-pressure/medians/main/run.sh`; progress in
  `evidence/n27-pressure/medians/main/progress.txt`, `DONE` marker when both end (~32 min by n26's pace). Holds the lane's
  Godot until then.
- 02:50 DECISION pressure schedule: the builder's first call (takes for items 2 and 3) writes code while the batch holds
  Godot, and starts Godot only after `medians/main/DONE`. The batch runs gauntlet code only; the builder touches
  `project/dev/gauntlet/**` and `tools/gauntlet/pressure_films.mjs`, which the gauntlet runner does not load.
  After-keys / after-melee medians run in a detached scratch worktree (no merge of other lanes into this branch).
- 02:48 BUILDER RUNNING takes since 02:48 (call 1, brief `evidence/briefs/n27-pressure-01-takes.md`, node pid 81032,
  out `evidence/briefs/n27-pressure-01-takes.out.txt`): items 2 and 3 takes + films; hard stop 04:05, commit by 03:40,
  Godot only after `medians/main/DONE`.
- 02:55 scratch worktree for the join medians: `C:/Users/kazda/kiro/gtai-n27/scratch/pressure-join` (detached at
  a3b3f1466; native bin, `data/generated/city` and the `.godot` import cache copied from this worktree). Keys/melee get
  merged there (detached commits, never on this branch). Remove it at the end (`git worktree remove`).
