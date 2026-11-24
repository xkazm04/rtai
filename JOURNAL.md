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
- 04:30 call 2 interim `takes/seeds.md` (10 seeds): guard6 share 25.1 % [21.1, 29.6] (curve 24.3 % inside), blade6
  27.2 % [22.7, 32.3] (curve 30.6 % inside); blade6: 650 of 1300 rounds hit Rivet mid-swing, every seed exactly 65.
  pair_circle down 10/10 at 7.1-7.7 s, 70/80 hits; pair_dash 43/248 "hits" but HP 97.6-100 at 10 s: the take counts
  every HP drop, so the dash "hits" are grazes, not rockets. Brief 03 (`evidence/briefs/n27-pressure-03-films.md`)
  splits direct/splash/HP lost, re-cuts the pair film, re-encodes deflect_6m_32 (108 MB, 21.9 Mb/s), frames to 8+.
  Item 5 levers noted: novice deaths are the wave 5 war machine's `stomp` (enemies.json weapons: damage 48, splash 48 in
  3.5 m, cooldown 1.2 s, `alt_telegraph_s` 0.8) in 15 of 20 runs; `gauntlet.json` rivet repair 10/s after 3 s.
- 05:10 BUILDER measure 75 $1.31 accepted (stopped at the 75 min cap after its last commit). Commits cca975316 (10-seed
  table, `pressure_seeds` dev script, sword half-catch measured), 8e8d00a5e0 (mutate). MILESTONE item 4: mutate
  `gauntlet_combat.gd` stall lines 14/15 killed (93 %; survivor line 18 initial `_last_damage_tick`, overwritten when
  a wave goes live: equivalent), `bot_arena_moves.gd` 7-15,54 3/4 (75 %; survivor line 13 input index 0->1 with one
  input: equivalent), `pressure_pair.gd` 6/12 (50 %; two cheap kills named, given to call 3)
  (`evidence/n27-pressure/mutate/scores.md`). Sword half-catch, measured: the shipped sword is single-swing, 33 ticks
  (8+6+19), deflecting only in the 6 active ticks; blade6's pairs are 18 ticks apart, so the second round of every
  pair lands mid-swing (650/1300, 65 every seed); of swung rounds 51.4 % return (pass ratio 0.5). The take's cadence,
  not the deflect rule. Three `gtai-mutate-*` temp dirs exist; owners unknown, left for the merge cleanup.
- 05:06 after-melee arm started (godot-free 05:06), scratch 4a3ff4b04; salt 0 from 05:07.
- 05:10 BUILDER RUNNING films since 05:10 (call 3, node pid 57264, brief `evidence/briefs/n27-pressure-03-films.md`,
  out `.out.txt`, hard stop 06:12). Godot only after `medians/melee/DONE`; writes `godot-free-3.txt` when done.
- 05:25 MILESTONE item 1 after-melee column (scratch 4a3ff4b04, salts ended 05:15 / 05:23, exit 0, 30/30 each):
  median death wave salt 0 / 1: novice 5 / 5, average 8 / 5, expert 8.5 / 9 (main: 5/5, 6/5, 8.5/9; after keys
  identical to main). 20 of 30 salt 0 results differ from main (mastery changes the bot's runs). Average salt 0 +2
  waves but salt 1 +0 and the null floor is 3.6: no separation. Novice still dies to the wave 5 war machine's stomp
  (16 of 20 runs). `medians/melee/{killers.md,floors.md,compare_s0.md,compare_s1.md}`.
- 05:25 item 5: `tune.mjs propose` on after-melee salt 0 -> `medians/melee/plan.json`, 2 changes, NOT applied:
  `rivet_repair` (repair_per_s 10 -> 12.5, repair_delay_s 3 -> 2.4; expert 8.5 vs target 20) and `budget.per_wave`
  16 -> 13 (average 8 vs target 12). DECISION: measure each as a what-if arm (`tools/gauntlet/ablate.mjs`, a temp
  worktree at 4a3ff4b04, the branch never changes) so the owner reads a number per proposal, not a proposal alone.
  `medians/whatif.sh` (bash pid 36048) waits for call 3 to free Godot (`godot-free-3.txt` or pid 57264 gone), then
  repair arm, budget arm, compare, killers -> `medians/whatif/DONE` (~06:35).
- 05:27 call 3 working (uncommitted: pressure_pair direct/splash split via the rocket's `landed` signal, film caption,
  seeds text, test, films tool). Diff read so far: dev and tests only.
NEXT (session 3, from ~05:42):
  (1) `gtai-n27/logs/pressure/builder.lock` + last `builder-calls.jsonl` line: call 3 `films` (pid 57264, hard stop
      06:12). Wait; then review: commits (dev/tests/tools only), new pair table in `takes/seeds.md` (direct/splash/HP
      lost, dash-count reason), ffprobe both masters (1080p 60/1, 15-40 s, deflect_6m_32 no longer 108 MB), LOOK at
      every still in `gtai-masters/n27/pressure/frames.json` (8-15 rows, best first), mutate `pressure_pair.gd` score
      vs 6/12 (`mutate/scores.md` 3b). Log `BUILDER films <min> <$> <verdict>`.
  (2) What-if arms: `medians/whatif/progress.txt`, `DONE` (~06:35; bash pid 36048 starts when call 3 frees Godot).
      Commit `medians/whatif/{progress.txt,DONE,killers.md,compare.md,compare.html,repair/,budget/}` (+ *.out.txt).
      If ablate failed (see `whatif/repair.out.txt`), say so plainly; do not fake.
  (3) Optional call 4 (only if it ends by 07:50): weakest item. Candidate: a `blade6` cadence arm with pairs >= 33 ticks
      apart as a second row (NOT a retune: a measured contrast showing the sword's single-swing commitment), filmed;
      or a 64 px/m clip of the dash crossing. Keep Godot free for the gate from 08:00.
  (4) Gate `node tools/gate/run.mjs --rev=HEAD` started by 08:15 with no builder and no what-if running.
  (5) REPORT.md: medians table three columns (main / after keys / after melee, salt 0 and 1, floors), killer table per
      profile (novice: wave 5 war machine stomp 16/20; levers: stomp damage 48, splash 48 in 3.5 m, cooldown 1.2 s,
      `alt_telegraph_s` 0.8; rivet repair 10/s after 3 s), the two tuner proposals with what-if numbers, the takes
      (pooled 6 m shares inside the curve intervals; pair circle down 10/10 at ~7.5 s; dash alive 10/10), mutate
      scores, calls for the owner (sword 33-tick commitment beaten by 2 rounds 0.3 s apart; the stomp at wave 5).
      `node tools/evidence/cites.mjs REPORT.md`. Remove scratch worktree `gtai-n27/scratch/pressure-join` at the end
      (`git worktree remove`).
- 05:38 call 3 first commit a382890e5 (05:33): pair damage split via the rocket's `landed` (burst inside Rivet's
  radius = direct): pair_circle direct 9/80, splash 61/80 (he dies to blasts beside him, not rockets on his body);
  pair_dash direct 1/248, splash 42/248, HP 97.6-100 at 10 s; 13 dashes = one per two-rocket volley (presses in
  cooldown counted). Tests now assert hp_at_10s, the split summing to HP lost, the radius pull from both sides.
  Diff read: dev/tests/tools/evidence + debt baseline. Films still to come.
  BUILDER RUNNING films since 05:10 (pid 57264, hard stop 06:12). What-if waiter pid 36048 waiting on it.
- 05:39 session 2 end. NEXT as written at 05:26.
