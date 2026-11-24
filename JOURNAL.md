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
- 03:08 MILESTONE item 1 main column: batches on a3b3f1466 ended 02:57 / 03:06 (exit 0, 30/30 runs each, ~10 min a
  salt). Median death wave salt 0 / salt 1: novice 5 / 5, average 6 / 5, expert 8.5 / 9; paired floor novice 0.3,
  average 2.6, expert 1.8 (`evidence/n27-pressure/medians/main/{salt0,salt1}/report.md`, `floors.md`, `killers.md`).
  n26's pre-keys numbers were 5/5, 7.5/5, 8.5/9: main moved within the floor. Commit 2ed06f4ac. Godot free for the
  builder from 03:06. Batch manifests say dirty: only the builder's uncommitted dev take edits (`project/dev/gauntlet/*`,
  `tools/gauntlet/pressure_films.mjs`), which the gauntlet runner does not load.
- 03:20 keys posted `MILESTONE keys-order e1c4b73d9` (03:14). Merged into the scratch join tree: detached commit
  e403c4a40 = a3b3f1466 + e1c4b73d9 (10 files; data: `ghost_forms.json` `deploy_slots`). The after-keys batches
  (`evidence/n27-pressure/medians/join.sh keys`) start when the builder frees Godot. Tuner `propose` on main salt 0:
  same one change as n26, `rivet_repair` (`evidence/n27-pressure/medians/main/plan.json`), not applied.
- 03:38 builder committed 625b460c7 (03:33): takes `pair_circle`, `pair_dash` (`PressurePair`: two rocket troopers 3 m
  apart, Rivet sprint-circles their midpoint at 10 m, no shots back; dash take dashes across each rocket line
  `dash_read_ticks` after launch), `guard6`, `blade6` (`PressureRifles.near()`: rifles at 6 m, reactive guard,
  shooters and Rivet durable in the dev take so every return is counted), `PressureStreet.widen` (dev only: the
  street's walls are 12 m apart, too close for a 10 m circle), tests `test_pressure_takes.gd`, debt +265 dev_loc
  accepted. Diff read: dev and tests only, no data. Builder now filming.
- 03:53 BUILDER takes 65 $3.22 accepted. Commits 625b460c7 (takes, tests, `--only=` side-by-side films, debt) and
  e7f748ed3 (deflect film over 2380 ticks). Seed 1 numbers: pair circle 7 hits / 8 rockets, down at 7.7 s (HP 0 at
  10 s); pair dash 4 / 26, HP 98.9 at 10 s, 95.5 at the end, 13 dashes. 6 m: guard 78 fired / 46 returned / 9 hit a
  shooter = 19.6 % (curve 24 %), sword 130 / 40 / 8 = 20.0 % (curve 31 %); sword catches ~half the rounds (open).
  MILESTONE items 2 and 3 filmed: `gtai-masters/n27/pressure/trooper_pair_32.mp4` (25.0 s, 1920x1080, 60/1),
  `deflect_6m_32.mp4` (39.67 s), `trooper_pair_64.png`, `deflect_6m_64.png`; frames.json 4 new rows first. I looked
  at both stills and a 20 s frame of each film (`build/n27-check/`): captions readable, rockets on their lines,
  side by side at the same tick; the circle side freezes with "Down at 7.7 s".
  FRICTION builder reports `tools/gate/quick.mjs` parse check fails on `pressure_rifles.gd` (MeleeTable needs autoloads,
  pre-existing line); headless runs and the full lint (19/19) pass. Check at the gate.
- 03:53 after-keys batches launched detached (`join.sh keys`, bash pid 75356) in the scratch tree e403c4a40: import,
  salt 0, salt 1, reports, floor, then `medians/keys/DONE` (~04:15).
- 03:54 BUILDER RUNNING measure since 03:54 (call 2, node pid 28812, brief `evidence/briefs/n27-pressure-02-measure.md`,
  out `.out.txt`): 10-seed table of the four takes with Wilson intervals vs the curve, the sword half-catch cause,
  item 4 mutate (stall lines in `gauntlet_combat.gd` 12-16,18,53-66,120,122,123 and `bot_arena_moves.gd` 7-15,54;
  plus `pressure_pair.gd`). Godot only after `medians/keys/DONE`; it writes `evidence/n27-pressure/godot-free.txt`
  when done with Godot. Hard stop 05:10.
- 03:57 melee has landed its mastery changes without a MILESTONE line yet: 58a1b8d07 (master_at 30, per_boss_cut 3),
  1a6badfc8 (`bond.mastery_free` true), 6522ce667 (bond table, `--mastery-free` flag). The after-keys scratch import
  is a full re-import (slow, ~10+ min); batches follow.
NEXT (session 2, from ~04:15):
  (1) Check `C:/Users/kazda/kiro/gtai-n27/logs/pressure/builder.lock` + last line of `builder-calls.jsonl`: call 2
      `measure` (pid 28812, hard stop 05:10) may still run. Do not start another call while it runs.
  (2) After-keys batches: `evidence/n27-pressure/medians/keys/progress.txt`, `DONE`; then
      `cd evidence && node n27-pressure/medians/killers.mjs main-s0=n27-pressure/medians/main/salt0 keys-s0=n27-pressure/medians/keys/salt0 ...`
      -> `medians/keys/killers.md`, commit `evidence/n27-pressure/medians/keys` (not import.log if large).
  (3) After-melee arm: when `evidence/n27-pressure/godot-free.txt` exists (builder done with Godot), in the scratch tree
      `C:/Users/kazda/kiro/gtai-n27/scratch/pressure-join` merge the melee head that has the mastery commits (grep
      `n23-street/JOURNAL.md` for a MILESTONE; else its latest sha with 1a6badfc8 in it), git -c user.name=... merge
      --no-verify, then launch `join.sh melee` detached (Start-Process bash). Conflicts: melee touches keys'
      `ghost_deploy.gd:54` (one line) — keep both.
  (4) Review call 2 (seed table, mutate scores), log `BUILDER measure ...`. Then item 5: medians.md with the three
      columns (main, after keys, after melee), killer tables per profile, `tune.mjs propose` on the after-melee salt 0.
  (5) Raise the weakest item afterwards (candidates: frames.json needs 8 to 15 rows — add the 6 m single-take stills
      and a guard-vs-blade 64 px/m pair; the pair dash take is hit 4/26 vs n26 arena 0/48: the dash waits 16 ticks
      after launch, not the lock — a "dash on lock" variant could be one flag).
  Commit by 08:00, gate `node tools/gate/run.mjs --rev=HEAD` by 08:15. Remove the scratch worktree at the end.
- 04:12 after-keys salt 0 (scratch e403c4a40) ended 04:04, exit 0: median death wave novice 5, average 6, expert 8.5,
  and all 30 run results are byte-identical to main's salt 0 (`cmp`, 0 of 30 differ): the keys order changes which
  key deploys which ghost, not which ghost the bot deploys. Salt 1 running (bash pid 75356), `DONE` at ~04:13.
  BUILDER RUNNING measure since 03:54 (pid 28812), waits for `medians/keys/DONE` before Godot.
- 04:13 session 1 end. NEXT as written above (04:00).
- 04:20 session 2 start. Builder call 2 `measure` still running (lock pid 28812 = node). No `NEED pressure` in the
  four other n27 journals. MILESTONE item 1 after-keys column: salt 1 ended 04:11, exit 0; all 60 run results
  (salt 0 and 1) byte-identical to main's: median death wave novice 5/5, average 6/5, expert 8.5/9 (salt 0/1).
  `evidence/n27-pressure/medians/keys/{killers.md,floors.md}`, commit e200f9a98.
- 04:22 after-melee arm: scratch tree moved to melee's 4a3ff4b04 (= a3b3f1466 + keys e1c4b73d9 + mastery 58a1b8d07,
  1a6badfc8, 6522ce667; data `master_at` 30, `mastery_free` true, `per_boss_cut` 3). DECISION: use melee's own merge
  commit instead of merging again here (it resolved the one `ghost_forms.json` doc conflict; melee's later commits are
  films). Waiter `medians/wait_melee.sh` (bash pid 41748) starts `join.sh melee` when `godot-free.txt` appears.
