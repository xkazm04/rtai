# JOURNAL n15-tools (night 2026-11-10 -> 11-11)

Branch `n15-tools`, cut from main `5c5c03611`. APPDATA=C:/Users/kazda/kiro/gtai-n15/appdata/tools.

## Session 1 (21:59 - 23:29), iteration 1, BUILD

- 22:00 read: brief, n11 tools REPORT (Calls, Next steps), tools/README.md, AGENTS.md. No JOURNAL before.
- 22:03 MILESTONE t-1 defect proven before the fix: `node tools/tests/run_unit.mjs --select=test_city_spawn_plan_turns,test_city_spawn_plan`
  -> 2 failing: `[2, 2, 3, 2] != [2, 3, 2, 3]` and `[8] expected to equal [10]` (a full kind gave the
  next kind two turns in a row). Fix `_turn += q + 1` (city_spawn_plan.gd:41) -> 9 passed.
  Codex's n11 test landed unchanged (copied from the PoF day folder, never edited there).
- 22:05 scenarios with the t-1 fix: `node tools/tests/run_scenarios.mjs` -> `scenario-tests: 55 passed`
  (city_replay ok): t-1 moves no replay golden (and there is no committed replay hash: the replay
  scenarios record and replay in one build).
- 22:06 t-2 rule in `tools/codex/factory.mjs`: `review --verdict=accepted*` on a machine-rejected task
  needs `--overrule="<reason>"` (>= 20 chars), the ledger row keeps `overrule.machine_why` + `reason`;
  `overrule <id> --reason=` for tasks accepted before the rule; `ledger` totals list every overrule.
  `node --test tools/codex/factory.test.mjs` -> 26 pass (3 new). Commits d720e22da (t-1), 7ef39b42e (t-2).
- 22:09 NATIVE REBUILD #1 (this lane only): car_route.cpp + sim_constants.h (t-4), `scons
  platform=windows arch=x86_64 target=template_debug` and `template_release` both exit 0, `scons tests`
  -> `sim_core tests: 0 failed`. View lanes keep their DLLs: the shipped city's traffic does not
  change (see t-4 audit below).
- 22:15 t-4 finding: the tile painter's grid (PERIOD 8, a 3x3 junction box, one road row per street)
  puts only road of the lane's own orientation or a junction ahead of every lane, up to the void
  past the city edge, and every junction exit at 16 m is road of its own orientation. So the two
  t-4 defects can not fire in the shipped city; they bite on any other map. Test
  `tests/integration/test_city_lane_grid.gd` audits all 256 chunks for it.
- DECISION t-4/table: the four tuned distances live in `tools/gen_constants/sim_constants.json`
  (group `car_route`, schema `gtai.sim-constants/1`), not `data/tables/`: it is the NAT-08 single source
  both sims are generated from (`SimConst.CAR_*` and `sim_constants.h`), lint fails on drift, and
  a `data/tables` row would need a native loader and could drift between the two sims.
- 22:12 t-1 mutate run #1 killed by my own 10-min background limit at 32/39 (FRICTION: restarted with a 30-min
  limit at 22:19). Survivor it showed before dying: line 21 `rioters > 0 -> > 1` is killable (a riot of one
  with a ped present) -> new test `test_a_riot_of_one_counts_the_ped_already_there` (fe5dccda0).
- 22:15 t-4 tests fail on the old rules (old two conditions restored by hand, constants kept):
  `run_unit --select=test_sim_car_route_t4` -> 3 failing (kerb U-turn: `[2] expected to equal [0]`; sideways
  exit: `[1] expected to equal [2]`); all 5 pass on the fix. 22 pass across the five route/spawn files.
- 22:17 parity after t-4 (new DLLs, rebuild #1): `node tools/tests/run_parity.mjs` -> `native == GDScript
  reference bit for bit over 1200 steps (40 snapshot checks, 3502 floats); planted mutation caught at step 629`.
  New `final_sha_a/b` in parity-result.json: 94b2865f7f17d778 both. Scratch worktree
  `C:/Users/kazda/kiro/gtai-n15/scratch-tools-before` (detached d720e22da = t-1 only, n15-hero's old DLLs via
  wt_init) -> 94b2865f7f17d778 both: t-4 moves nothing. Same scratch at 5c5c03611 (main) -> 9cd5579a4027df85,
  counters [149,70,23,6,100,148..] vs [149,70,22,6,102,145..]: t-1 is what moves the city sim (spawn order).
- 22:21 item 5 lint: `report()` prints every failing test name (parsed from the spec reporter's "failing
  tests:" section; `--test-reporter=spec` pinned so Linux CI prints the same), then 40 issue lines, then
  `... N more not shown: all M lines in build/lint/<check>.txt`. Real run with a temporary 45-failure
  file in tools/gate (deleted after): `FAIL tool-tests / 45 failing test(s): / FAILED
  tools\gate\zz_n15_demo.test.mjs:3:30 n15 demo failure 0 ...` (45 FAILED lines) and `... 1232 more not
  shown: all 1272 lines in build/lint/tool-tests.txt`. The old cap printed 40 lines of passing output.
- 22:29 t-1 mutate #2 (fe5dccda0, 595 s): `score 64.1% = killed 25 / (killed 25 + survived 14)`; every
  survivor read and equivalent (10 initialisers :10-11; :21 x2 rioter slot never read; :29, :31 zero-want kind
  skipped). The riot-of-one test killed :21 `> 0 -> > 1` ([15/39] killed). Overrule recorded with
  `node tools/codex/factory.mjs overrule n11t-fac-city-spawn-plan --ledger=C:/Users/kazda/kiro/gtai-masters/n15/tools/codex-ledger.jsonl
  --reason=...` (n15 ledger seeded with the 3 n11 rows of that task, copied verbatim); `ledger` lists it under
  `overruled_machine_rejects`. Decision 324833c98.
- 22:24 item 4a: morning merge resolves a baseline.json conflict (looser side per file, both reasons) and
  says so; real throwaway-repo test passes (83 merge tests). Commit 565bd083b. Item 4b (real native/gates/
  reels run on a scratch integration worktree) NOT done yet: gates floor is 90 min, reels 65.
- 22:30 NATIVE REBUILD #2: HW 80 -> 132 (t-5), debug + release exit 0, `sim_core tests: 0 failed`.
  test_sim_hash_window failed on HW 80 (`Expected [ARRAY([])] to contain value: [0]: promoted actor
  (1.0, 0.0) at 256 m`; `[40] expected to be > than [64]`), passes on 132. Parity exact, digest
  94b2865f7f17d778 unchanged. Commit 0ba5b1e91.
- 22:33-22:36 t-5 cost under the bench lock (created noclobber, deleted after), CONTENDED (hero/combat Godot
  live): 5 paired parity rounds, A = scratch d720e22da (HW 80), B = this tree (HW 132), same final state
  in all 10 runs. native B-A per step sorted -3.7 4.3 5.8 6.9 7.9 us (median +5.8 us); GDScript reference
  -406.7 276.1 342.0 383.1 679.9 us (median +0.34 ms). `evidence/t5_ab.tsv`.
- 22:40 item 6 FOUND, reproduced without loading the shared machine: a `--require` preload that delays every
  node start (`C:/Users/kazda/kiro/gtai-n15/flake/slow_start.cjs`, `SLOW_MS=2500 NODE_OPTIONS="--require ..."`)
  stands in for load. Runs: morning_run.test.mjs 2 fail / 2 pass (`/before the hang/` missing: the child was
  killed by the 1.8 s step timer before its node had started; `ENOENT ... grandchild.pid`: killed before the
  grandchild existed); check_baked.test.mjs 7/7 pass (not the cause, it was beside morning_run in the n11
  06:38 run); step_guard.break.test.mjs 3 fail / 12 pass (same shape: `command must start before the external
  kill`, `grandchild must actually have started`, `guard waited 7689 ms for a descendant's log handle`).
  CAUSE: fixed wall-clock budgets that silently contain one or two cold node starts (0.1 s idle, seconds
  beside Godot). FIX (morning_run): `tools/lib/node_start.mjs` measures this node's cold start now and
  `budgetMs(base, starts)` adds 3x per start, so the race is gone rather than the timeout raised blindly.
  After: plain 4/4 (6.3 s), slow start 2.5 s 4/4 (61.6 s); merge suite 86/86. Also a REAL bug found on the
  way: `defaultRun` passed `minutes * 60000` raw to spawnSync, so a limit that is not whole ms (1000.5 ms)
  threw ERR_OUT_OF_RANGE; now `Math.ceil`; its test fails on the old file, passes on the new.
  NOT YET: the 3 step_guard.break tests (same cause; their late-write check needs its delay to scale too).
- 22:47 SERVED combat REQUEST (n15-combat JOURNAL line 24-27): `node tools/film/compare.mjs <shot> --a=.. --b=..
  --at=.. --out=.. --victim=<kind>` now passes `--victim` to both sides' film plan, which checks the kind in each
  tree. Proof (planning, no Godot while my gates hold the lane's one Godot): both sides plan with
  `game args: --victim=cop/head_swat`; `--victim=cop/nope` -> `film: unknown victim cop/nope in ... known: ...`.
  Test in `tools/film/victim.test.mjs` (6/6). A real compare film with a victim is still owed (after the gates).
  For combat: merge n15-tools for it, or cherry-pick the compare.mjs commit (pure Node, no sim change).
- 22:47 item 6 part 2: the 3 step_guard.break tests budget their cold node starts (`budgetMs`, waitFor limit,
  guard limit, the held-log threshold). One review catch on the way: scaling the grandchild's late write to the
  bare limit made it beat the kill on a QUIET machine (3 of 3 plain runs failed `grandchild executed code after
  the guard timeout`): `taskkill /T` itself takes a few hundred ms, which the old 1 s margin covered; the late
  write is now limit + 1 s. Runs after: plain 15/15 x3; slow start 2.5 s 15/15 (116.7 s; was 3 failing).
  Not yet: a run on Linux (WSL) and a loop under real load; check_baked never failed in any run (7/7 slow).
- 22:57 t-1 look goldens: the 22:41 gate on 1af97f018 (killed by me by PID 77364 after selftest, to free
  Godot) had lint PASS, unit `2507 passed, 0 failed, 2 skipped`, scenarios 55 PASS, parity PASS, selftest FAIL
  (look 0/11 worst 24.20, block 0/5 worst 18.18). Bisect in the scratch tree: main 5c5c03611 11/11 + 5/5;
  d720e22da (t-1 alone) 0/11 24.20 + 0/5 18.18 = HEAD's numbers -> t-1 moves them, t-4/t-5 do not. Re-blessed
  16 goldens (look_golden.tscn --bless, both sites), one accent row `blood_flicker_vehicles_64` (4 px flicker,
  frame looked at: no car near the spray). selftest after: exit 0, 11/11 + 5/5 worst 0.00. Stills:
  gtai-masters/n15/tools/golden-{d4-48ppm,block-d4-32ppm}-before-after.png (looked at: same scenes, other
  crowd, cops blue, blood red). Commit eb65c8b05.
- 23:01 item 6 on Linux (WSL Ubuntu, Node v24.14.0 at ~/node24, script gtai-n15/flake/wsl_run.sh): plain 28/28;
  slow start 2.5 s 19/20 -> my own new rounding test had the same flaw (1000.5 ms limit holding a node start);
  fixed with budgetMs; after: Windows slow 1/1, Linux slow 20/20, plain 0 fail; still fails on the old
  morning.mjs (the rounding bug).
- 23:04 item 7 started: control subagent (Opus, background) writes test_sim_hash.gd from the Codex brief
  (`pof-codex/runs/n11t-fac-sim-hash/brief.md`) in the scratch tree `C:/Users/kazda/kiro/gtai-n15/scratch-tools-before`
  checked out at the Codex task's base 812a0b061. Pair it with ledger row n11t-fac-sim-hash (review tokens 64833,
  178 s, iteration 44). Then: mutate sim_hash.gd in the scratch tree with that test, record
  `factory control sim_hash --tokens --secs --tests --killed --mutants --changed --ledger=gtai-masters/n15/tools/codex-ledger.jsonl`
  (seed the n15 ledger with the 3 n11 sim-hash rows first, verbatim).
- 23:06 MILESTONE gate on eb65c8b05 (`node tools/gate/run.mjs --rev=HEAD --timeout=40`): `gate: PASS` - lint all 16
  (debt-ratchet included), `unit-tests: 2507 passed, 0 failed, 2 skipped`, `scenario-tests: 55 passed`, parity bit
  for bit (planted caught at 629), selftest look 11/11 + block 5/5 worst 0.00, `release-compile: 667 loaded, 0
  failed`. Commits after it (8b209a8a1 test-only, 868e02462 / 13d033439 docs) were linted by the hook. Reels NOT run.

NEXT: (1) read the gate result for eb65c8b05 (selftest must pass after the re-bless); run the REEL gate
(`node tools/reel/run_reels.mjs` or `node tools/gate/run.mjs --rev=HEAD --reels`) on the latest commit.
(2) Finish item 7 (control result -> mutate -> `factory control`). (3) Codex testers for t-1, t-4, t-5 through
`npx tsx scripts/codex/dispatch.ts run <task.json>` from C:/Users/kazda/kiro/pof (ids n15t-..., discard after;
task.json shape: pof-codex/runs/n11t-break-check/state.json `.task`). (4) item 4b: morning.mjs native/gates/reels
for real on a scratch integration worktree (needs ~2.5 h: gates floor 90 min, reels 65) - start it early in a
session, remove the worktree and branch after. (5) a real `compare.mjs --victim` film for combat.
(6) REPORT.md: extend the draft. Scratch tree `C:/Users/kazda/kiro/gtai-n15/scratch-tools-before` is mine
(detached, wt_init'd from n15-hero); remove with `git worktree remove --force` at the end of the night.
- 23:07 item 6 sweep: lint's whole tool-test set (`tools/{film,merge,codex,gate}/*.test.mjs`) with every node start
  delayed 1.5 s: `tests 449, pass 449, fail 0` (74.5 s; log gtai-n15/flake/slow_all.log). No other timing-shaped
  test found by this method (it does not cover filesystem-clock races; none suspected).
- 23:08 item 4b started for real: scratch integration worktree `C:/Users/kazda/kiro/gtai-n15/scratch-integ` on
  new branch `n15t-scratch-integ` at 5c5c03611 (wt_init from this tree), `morning.mjs --lanes=n15-tools,n15-hero,
  n15-combat --date=2026-11-11 --steps=merge,debt,native --debt-reason=...` (log gtai-n15/flake/morning_4b.log).
  gates and reels steps on the same worktree next session (`--steps=gates,reels --resume`?), then remove the
  worktree and the branch (`git worktree remove --force`, `git branch -D n15t-scratch-integ`).
- 23:12 MILESTONE item 4b, part 1 (real, not fakes): `morning.mjs --worktree=C:/Users/kazda/kiro/gtai-n15/scratch-integ
  --lanes=n15-tools,n15-hero,n15-combat --date=2026-11-11 --steps=merge,debt,native` -> `merge: green` (each lane
  merged, JOURNAL/REPORT moved under docs/day/2026-11-11/<lane>/, no code conflict between the three lane tips
  at 23:08), `debt: green`, `native: green` (scons debug + release in that worktree; NATIVE REBUILD #3 is the
  scratch one, not this tree), `DONE at 76ed5809 on n15t-scratch-integ. Nothing was pushed`. Log
  gtai-n15/flake/morning_4b.log. The baseline auto-resolve did not fire (no baseline conflict tonight); it is
  proven on the throwaway-repo test only. Part 2 (gates, reels: needs Godot ~2.5 h) next session with
  `--steps=gates,reels`; then remove worktree + branch.
- 23:14 FRICTION (mine): the control agent's "no gtai-gate- process" check matched its own polling shells (their
  command lines contain the pattern), so it waited past my gate's end; told it to proceed. Next time: match on
  Godot process names plus the snapshot path, never on a bare substring a poller repeats.
- 23:17 item 7 control (Opus subagent, same brief as Codex's n11t-fac-sim-hash, scratch tree at 812a0b061): 14 tests,
  `unit-tests: 14 passed, 0 failed, 0 skipped`, harness: 46819 tokens, 730634 ms, 12 tool uses. The 730 s are
  INFLATED by my self-matching wait check (it sat waiting for a gate that had ended): do not record them as the
  control's cost without saying so. Its file is saved at `C:/Users/kazda/kiro/gtai-n15/control/test_sim_hash_control.gd`
  (Codex's n11 test is `project/tests/unit/test_sim_hash.gd` on main; the control was never shown it).
  Suspects it named: none real; `hstart[HW*HW]` sentinel unread (unkillable), window 1 cell lopsided (deliberate).
  NOT recorded in the ledger yet: `factory control` needs killed/mutants -> mutate sim_hash.gd with the control
  test alone (in a scratch tree at 812a0b061 with the file committed on a throwaway branch, or copy it into this
  tree under a temporary name; HW 132 here vs 80 there changes no comparison).

NEXT (session 2, updates the 23:04 NEXT): (1) reel gate on this branch's latest commit. (2) item 7: mutate the
control test -> `factory control sim_hash --tokens=46819 --secs=<say inflated, or re-measure> ... --ledger=
gtai-masters/n15/tools/codex-ledger.jsonl` (the 3 n11 sim-hash rows and the 3 city-spawn-plan rows are already
seeded there). (3) item 4b part 2: `morning.mjs --worktree=C:/Users/kazda/kiro/gtai-n15/scratch-integ ... --steps=gates,reels`
(merge/debt/native done at 76ed5809), then `git worktree remove --force` it and `git branch -D n15t-scratch-integ`.
(4) Codex testers for t-1/t-4/t-5 (dispatch.ts, ids n15t-). (5) real `compare --victim` film for combat.
(6) REPORT.md is a draft: extend it. Scratch trees of mine: gtai-n15/scratch-tools-before (detached), gtai-n15/scratch-integ.

## Session 2 (23:17 - 00:47)
- 23:18 reel gate started on ad2f0a5c1 (`node tools/reel/run_reels.mjs --out=build/reels`, log gtai-n15/flake/reels_s2.log;
  the lane's one Godot slot).
- 23:30 SERVED combat REQUESTs (n15-combat JOURNAL lines 65 and 78), commit ba6f38838: `film.mjs`/`compare.mjs`
  name the director's extras (`chapter:electro_baton_left`, `chapter:katana_cam`, ...: `chapterIds` reads the
  loop in `ReelChapters.extras()`), and `--feel=auto|on|off` (auto = the old rule; compare passes it to both
  sides; a `-- --feel=` is refused, the game reads the first one). Proof: `film.mjs chapter:electro_baton_left
  --feel=on --dry-run` plans `--chapter=electro_baton_left ... --cam-lock=spawn --feel=on`; `chapter:electro_baton_lft`
  -> `did you mean electro_baton_left?`. Tests `tools/film/feel_chapter.test.mjs` 8/8, film suite 180/180, lint 16/16.
  A real film with these flags is owed (Godot slot held by the reels).
- 23:22 Codex testers dispatched (meter 36 %, read from ~/.codex/sessions): `npx tsx scripts/codex/dispatch.ts run
  gtai-n15/codex/<id>.json` for n15t-break-car-route (t-4), n15t-break-hash-window (t-5), n15t-break-spawn-plan
  (t-1), base ed8ac8cc9. Law added: never launch Godot (my reels hold the lane's one slot); I run their tests.
  FRICTION (mine): first launch died on `copyIgnored.from` written with backslashes inside a JS heredoc
  (`C:Userskazdakirogtai-wt\n15-tools`); `discard` cannot clean a run with no state.json, so I removed the 3
  worktrees + `codex/n15t-*` branches by hand (`git worktree remove --force`, `git branch -D`) and relaunched.
  hash-window: 7 tests, 5021 tokens out; spawn-plan: done; car-route: running.
- 23:24 item 7 prep: scratch tree gtai-n15/scratch-tools-before on throwaway branch `n15t-control-sim-hash`
  (f4d4acab5 = 812a0b061 + the control test + a scratch-only debt accept: the hook refused the 211-line file).
- 23:26 item 6 loop under load (reels running): `gtai-n15/flake/loop_load.sh` = lint's tool-test globs +
  tools/lib, 9-10 s a run, runs 1-3 fail=0.
- 23:26 reel gate: `[1/3] top OK, 280 s`.
- 23:32 MILESTONE reel gate on ad2f0a5c1 (`node tools/reel/run_reels.mjs --out=build/reels`): `top: OK; code 0`
  (280 s), `tilt70: OK; code 0` (284 s), `combo: OK; code 0` (286 s). Every chapter `N/N down`.
- 23:33 Codex testers (t-1/t-4/t-5) run by me: `run_unit --select=<3 files> --no-rerun` -> `23 passed, 0 failed`.
  No tester found a defect. Bite check by hand (planted, restored with cp/checkout, tree clean after):
  old t-4 rules + HW 80 -> `5 failing (12 passed, 5 failed)` (4 car-route, 1 hash window);
  `_turn += 1` -> `4 failing (2 passed, 4 failed)` in the spawn-plan tester. Review changes: split the
  300-line car-route file and the 233-line hash file in two each (tests unchanged; the 300 was at the
  hard stop and both raised the debt ratchet); spawn-plan landed unchanged. Codex caught a wording error
  in MY brief: the turn fires CAR_TURN_LEAD BEFORE the new lane, not past it (it followed the code: right).
  Thrown away: nothing. Commit 4576f2b08. Dispatcher ledger: car-route accepted-after-revision (181 s, 6736
  tokens out), hash-window accepted-after-revision (140 s, 5021), spawn-plan accepted (98 s, 3859); all
  three discarded.
- 23:40 MILESTONE item 7: mutate of sim_hash.gd with the control test alone (scratch branch
  n15t-control-sim-hash f4d4acab5 at 812a0b061, `--max=15 --tests=test_sim_hash`, the same 15-of-91
  sample Codex's runs used): `score 93.3% = killed 14 / (killed 14 + survived 1)`, 332 s; survivor
  `sim_hash.gd:22 delete hcount.fill(0)` (no control test builds twice; Codex's reviewed test had the same
  survivor at c52cceb1 until 5af34a16 killed it). Recorded: `factory control sim_hash --tokens=46819
  --secs=730 --tests=14 --killed=14 --mutants=15 --changed=0` in gtai-masters/n15/tools/codex-ledger.jsonl,
  notes say the 730 s are INFLATED (my wait bug). Ledger pair: Codex 162 s + review 64833 tokens / 178 s
  vs control 46819 tokens: `claude_tokens_saved: -18014` (Codex cost Claude MORE on sim_hash). Log
  gtai-n15/control/mutate_control_15.log.
- 23:43 FRICTION (mine, a bug I shipped in ba6f38838): every `compare.mjs` refused `film: --feel must be
  auto, on or off, got undefined` (compare plans each side with flags that lack film's DEFAULTS). Fixed
  d60ff5894 + a test through `filmFlags` -> `plan`. My 8 tests never planned through compare.
- 23:44 t-4 film started: `compare.mjs city --a=gtai-n15/scratch-tools-before (detached d720e22da = t-1 only,
  the hero lane's pre-t-4 DLL, md5 42f81158) --b=HEAD (DLL 1dec60a1) --at=300,600,900 --clip=300-900 --ppm=32`.
  A rev snapshot would have been a false before: snapshots copy THIS tree's (post-t-4) DLLs.
- 23:46 MILESTONE t-4 film (real run, compare above): `side A pass`, `side B pass`, `t300/t600/t900 UNVERIFIABLE:
  the two sides are identical (0 of 1024000 pixels differ)`, clip 300-900 (10 s, 32 px/m). Looked at t600:
  plaza, two cars on the road, cops blue, blood red; same picture both sides. Identical is the claim here
  (the old rules never fire in the generated city, `test_city_lane_grid`); compare's UNVERIFIABLE is its
  rule for an unchanged pair. Masters: `t4-city-street-32ppm-before-after-t{600.png,300-900.mp4}` +
  frames.json rows. No 64 px/m close-up: nothing differs to close up on. Removed my 2 temp film checkouts
  (gtai-film-4576f2b08848 from the failed 23:43 run, gtai-film-d60ff5894fb0); the other 5 are other lanes'.
- 23:47 tool fix (70ebf0634): `compare.mjs` refuses a commit side whose `native/` differs from this tree's HEAD
  (`git diff --quiet <sha> HEAD -- native` exit 1), before making the 1.7 GB snapshot; `--native=donor` for a
  view-only change. Real: `compare.mjs city --a=d720e22da --b=HEAD ...` -> exit 2, `compare: native/ at
  d720e22da (d720e22d) differs from this tree's HEAD, but its snapshot would run this tree's DLLs ...`,
  nothing launched. Tests `tools/film/native_side.test.mjs` 4/4, film suite 185/185.
- 23:48 item 6 parallel loop under load (4 copies x 5 runs of the lint tool-test globs + tools/lib, while
  reels/films/other lanes ran): 20 of 20 runs `fail=0` (14-29 s each). With session 1's slow-start runs on
  Windows and Linux, no flake reproduces after the node-start budgets (1af97f018, 5830ee44a, 8b209a8a1).
- 23:48 item 4b part 2 started for real: `morning.mjs --worktree=gtai-n15/scratch-integ --lanes=n15-tools,
  n15-hero,n15-combat --date=2026-11-11 --steps=gates,reels --timeout=90` (dry run first: `would run gates`,
  `would run reels`), log gtai-n15/flake/morning_4b_part2.log, on 76ed5809e (merge of the 23:08 lane tips).
- 23:50 SERVED combat FRICTION (n15-combat JOURNAL "lint function-size count includes the NEXT function's doc
  comment"), commit 26f18e5ef: `tools/style/check_gd.mjs longFunctions` counted a column-0 `##` line as body;
  now a column-0 comment never extends a function. Proof: `tools/lint/func_size.test.mjs` 5/5; with the old
  line restored by hand 2 of 5 fail (`the next function's doc comment is not counted ...`); lint `ok gd-size`.
  For combat: `cast_flags apply` measures 40 again after a merge of n15-tools (or cherry-pick 26f18e5ef, Node only).
- 23:51 combat REQUEST `test_quest_blade` registers its input actions itself: edit made (`_actions.install()`
  before `ObjectiveHint.with_keys`), NOT committed yet: the Godot slot is held by 4b's gates; verify with
  `run_unit --select=test_quest_blade` alone, then commit.
- To combat: all three earlier REQUESTs are served on n15-tools (ba6f38838 extras + --feel, d60ff5894 the
  compare fix for it, b8fccb958 compare --victim earlier); none needs Godot or the sim to cherry-pick.
- 23:53 Linux check of tonight's new Node tests (WSL `-d Ubuntu`, Node v24.14.0; note: the default WSL distro is
  NVIDIA-Workbench, which has no ~/node24: pass `-d Ubuntu`): 17/18, `resolveSide asks before making a snapshot`
  failed with `HEAD is neither a worktree nor a commit git knows` (this worktree's .git link is a Windows path).
  Fixed d1331a320: the test injects the rev lookup. After: WSL 18/18, Windows film suite 185/185.
- 23:54 4b part 2: gates step at scenarios `[55/55] vehicle_yield ok` (all 55 ok so far), parity/selftest next.
- 23:55 MILESTONE item 4b part 2, gates step for real: `morning: gates: green` on gtai-n15/scratch-integ 76ed5809e
  (n15-tools + n15-hero + n15-combat at their 23:08 tips). Its build/evidence: lint `all 16 checks pass over 1428
  GDScript files`, `unit-tests: 2529 passed, 0 failed, 2 skipped`, `scenario-tests: 55 passed`, parity `bit for bit
  over 1200 steps ... planted mutation caught at step 629`, selftest look goldens `11/11 ... (worst 0.00)` and block
  `5/5 (worst 0.00)`, `release-compile: 668 loaded, 0 failed`. So the t-1 re-blessed goldens hold with the other
  two lanes merged on top (as of 23:08); the selftest also lists stale accent debt rows to delete
  (blood_flicker_cop_48, ..._vehicles_vermilion_48), not a failure. `morning: reels: running` next.
- 00:01 item 4 tool add (725845086): `morning.mjs` gates step prints one `morning: gates: <kind> <status>: <summary>`
  line per pof.godot-evidence/1 kind after the run (green or red), STALE for a kind written for another commit
  (`tools/merge/gate_lines.mjs`). Proven read-only on scratch-integ's real build/evidence (76ed5809e): 6 kinds,
  e.g. `morning: gates: unit-tests pass: unit-tests: 2529 passed, 0 failed, 2 skipped (GUT, headless)`. The 4b run
  in flight started before it, so no real morning run has printed it yet. Tests 5/5 Windows + WSL; merge 89/89.
  (FRICTION, mine: a `[\/]` regex in a test fake lost a backslash on the way through my shell; used basename.)
- 00:01 4b part 2 reels: `top` view at chapter 19/19.
- 00:10 MILESTONE item 4b DONE (real, never on fakes): `morning.mjs ... --steps=gates,reels --timeout=90` on
  scratch-integ 76ed5809e -> `morning: gates: green`, `morning: reels: green` (`top OK, 281 s`, `tilt70 OK, 284 s`,
  `combo OK, 296 s`), `morning: DONE at 76ed5809 on n15t-scratch-integ. Nothing was pushed; main was not touched.`,
  exit 0 (log gtai-n15/flake/morning_4b_part2.log). With part 1 (23:08-23:12): merge, debt, native, gates, reels
  all ran for real once. Evidence JSON + reels log kept in gtai-n15/flake/integ_evidence/ (59 files). Then
  `git worktree remove --force gtai-n15/scratch-integ` and `git branch -D n15t-scratch-integ` (was 76ed5809e): gone.
  Not run: the bake and export steps (not asked by the brief; bake is a city re-bake, export is a stub step).
- 00:13 SERVED combat REQUEST `test_quest_blade` (5e41c66bc): `run_unit --select=test_quest_blade`: without the fix
  `1 failing (4 passed, 1 failed)` `[weapon_slot_2] ... to contain '[2]'` (combat's exact symptom), with it
  `5 passed, 0 failed` (re-run after a line-length fix). Test-only change.
- 00:17 MILESTONE a real `--victim` film (owed since 22:47): `film.mjs weapon:pistol --victim=cop/head_swat
  --on=kill:1+30 --ppm=64` -> `film: fire at 333; kill at 337`, `film: PASS` (film.json victim cop/head_swat; the log
  holds `lone victim cop/head_swat` once). Sheet t337-367 looked at: the SWAT, blue, falls and lies in red blood,
  rifle beside him. Masters `film-victim-head-swat-64ppm-t337-367.png` + frames.json row (5 rows now).
- 00:18 DECISION tools/compare-native written to docs/decisions.md (refuse by default, --native=donor, worktree for a true before).
- 00:16 gate started on 52dc72d4 (`node tools/gate/run.mjs --rev=HEAD --timeout=40`, no reels: reels were green on
  ad2f0a5c1 and every commit since is tools-, test- or docs-only), log gtai-n15/flake/gate_s2_head.log, results
  build/gate/52dc72d4173f/. Scratch renders deleted (build/film/t4_city, victim; copies in masters).

NEXT (session 3): (1) read build/gate/52dc72d4173f/gate.json (lint, unit, scenarios, parity, selftest,
release-compile); if the session cut it, re-run `node tools/gate/run.mjs --rev=HEAD --timeout=40` and remove the
snapshot after (`--clean`, or `git worktree remove --force <TEMP>/gtai-gate-52dc72d4173f`). (2) Read hero/combat
JOURNALs for new REQUEST tools / FRICTION (combat's are all served as of 00:13; hero has none). (3) Raise the weakest
items: t-5 cost under the bench lock (gtai-n15/bench.lock, noclobber; only when nothing heavy runs; else stays
CONTENDED); a real morning run that prints the new `morning: gates: <kind>` lines (on a fresh scratch integration,
gates step only, ~25 min; then remove it); the stale accent debt rows the selftest names (blood_flicker_cop_48,
blood_flicker_cop_block_64, blood_flicker_vehicles_48, blood_flicker_vehicles_64, blood_flicker_vehicles_vermilion_48:
find whose table, ask before deleting another lane's rows). (4) Before freeze: reel gate on the final commit if any
project/ change lands; REPORT.md final (draft is current to 00:20). (5) End of night: `git worktree remove --force
C:/Users/kazda/kiro/gtai-n15/scratch-tools-before` and `git branch -D n15t-control-sim-hash` (the control branch).
- 00:20 the integrated selftest's "debt rows no longer seen (delete them)" names 5 rows of
  project/data/tables/accent_debt.json, all owner d5-city, all the blood-splat gate-boundary FLICKER class whose own
  docs say it "moves between zooms and layers from run to run" (incl. my blood_flicker_vehicles_64, 22:57). One quiet
  run is not proof: KEPT. Each row's doc already names its real exit (an audit that compares same-frame captures).
  NEXT item (3)'s "stale accent rows" is therefore closed: do not delete them.
- 00:19 tool fix (7abcded29): the selftest's accent "debt rows no longer seen (delete them)" was judged at the junction
  alone, but rows carry no site: it named blood_flicker_vehicles_64 while the block run of the same selftest counted
  it (`64 px/m blood on vehicles: 4 px`). Now `unseenDebtRows` over both sites' offenders, and the note says "seen
  at neither site this run (a flicker row goes only after several quiet runs)", not "delete them". Test with the
  integrated run's own offender strings. CORRECTION: that commit message says "6/6 (Windows, WSL)"; WSL was 5/6
  then (the next entry's bug); 6/6 on both after 4eae1a978.
- 00:21 MILESTONE item 6, a second timing flake FOUND and fixed at its cause (4eae1a978): `tools/lib/dev_verdict.mjs`
  called a result stale when its mtime + 2 ms < launch time. Linux (WSL Ubuntu /tmp, 2000 writes) stamps a file up
  to 6.66 ms BEFORE the `Date.now()` taken ahead of the write (kernel coarse clock), so a fresh result read stale
  depending on the tick's phase: `tools/selftest/run.test.mjs` "runWorldLock: exit 0, no errors, a fresh ok result
  holds" failed 3 of 3 on WSL, 0 on Windows. Slack -> 1000 ms (film.mjs FRESH_SLACK_MS's rule; a stale file is
  minutes old). After: WSL 3 runs `pass 13 fail 0`; Windows lib/lint/selftest/dev/evidence 255/255. CI runs Linux:
  every dev_verdict user (dev run, selftest stages) could have flaked there. Other mtime checks: export 2 s, film 1 s:
  fine.
- 00:24 item 6 sweep of the WHOLE Node tool list on WSL Ubuntu (Node 24; AGENTS list + film/merge/codex/gate):
  `tests 825, pass 819, fail 4`. Three are WSL-only artifacts, not CI: this worktree's .git link is a Windows path
  (`mainCheckout names the repo...`, `real docs/decisions.md: exactly one MISSING`, `--history=N prints the replay
  figures`: `fatal: not a git repository: .../C:/Users/kazda/kiro/gtai/.git/worktrees/n15-tools`). The fourth is a
  real Linux flake: `tools/lib/godot_stop.break.test.mjs:175 timeout must kill the grandchild too`, 1 of 4 alone.
  Cause: kill(-pid, SIGKILL) works, but the orphaned grandchild stays a ZOMBIE until init reaps it, and
  `process.kill(pid, 0)` succeeds on a zombie. Fixed in the test (7f10f84b2): on Linux `/proc/<pid>/stat` state Z
  counts as dead; no wait (the watchdog grandchild self-exits at 4 s, a wait could fake a pass). After: WSL 8 of 8,
  Windows 17/17. Item 6 tally tonight: three timing-shaped causes fixed (node starts, Linux mtime tick, zombie).
- 00:26 MILESTONE gate on 52dc72d4 (`node tools/gate/run.mjs --rev=HEAD --timeout=40`): `gate: PASS` - lint 16/16,
  `unit-tests: 2530 passed, 0 failed, 2 skipped`, `scenario-tests: 55 passed`, parity bit for bit (planted caught at
  629), selftest look 11/11 worst 0.00, `release-compile: 667 loaded, 0 failed`. Snapshot removed. Commits after it
  (7abcded29 selftest, 4eae1a978 dev_verdict, 7f10f84b2 test, docs) are Node-tools/tests only, linted by the hook;
  reels last ran green on ad2f0a5c1 (no project/ game code changed since, except test_quest_blade.gd and the 5 Codex tests).

NEXT (session 3, replaces the 00:16 NEXT): (1) Read hero/combat JOURNALs for new REQUEST tools / FRICTION; combat's
are all served as of 00:13 (tell them through this JOURNAL: ba6f38838+d60ff5894 extras/--feel, 26f18e5ef lint size,
5e41c66bc quest_blade). (2) Weakest items: t-5 cost under the bench lock (gtai-n15/bench.lock, noclobber; only when
nothing heavy runs; else it stays CONTENDED); a real morning gates run printing the new `morning: gates: <kind>` lines
(fresh scratch integration, `--steps=merge,gates`, ~30 min, then remove worktree + branch). (3) Sweep the remaining
Node tool tests on WSL for Linux-only failures: run the list from a real Linux clone (`git clone` into WSL ~/ so git
works; /tmp is wiped) to clear the 3 git-link artifacts. (4) Before freeze: full gate + reel gate on the final commit;
REPORT.md final (draft current to 00:28). (5) End of night: `git worktree remove --force
C:/Users/kazda/kiro/gtai-n15/scratch-tools-before`, `git branch -D n15t-control-sim-hash`. The accent flicker rows
stay (00:20).
- 00:31 MILESTONE item 6 on a REAL Linux clone (WSL Ubuntu, Node 24, `git clone --no-local --branch n15-tools` into
  ~/n15t_clone at 9db143ecc; hooks off for the clone only): the whole Node tool list (AGENTS list + film, merge,
  codex, gate) `tests 825, pass 823, fail 0` (2 skipped). So the 3 failures of the 00:24 /mnt/c run were the
  worktree's Windows .git link, not code. Clone removed. NEXT item (3) is done.
- 00:30 item 4: `gate_lines.test.mjs` now drives `STEP_RUNNERS.gates` itself (fake run, green and red): it prints the lines both ways; 6/6 Windows + WSL.
- 00:33 SERVED combat FRICTION 22:05 (look goldens through `tools/dev/run.mjs` headless drew nothing), 5cda754c0: an
  entry (or the res:// script it extends, one hop) may declare `const NEEDS_WINDOW: bool = true`; run.mjs then refuses
  it headless, exit 2, nothing launched: `run: res://dev/selftest/look_golden.tscn renders frames (const NEEDS_WINDOW)
  and headless draws nothing: add --windowed ...`. city_selftest.gd declares it (so look_golden, accent_audit,
  world_lock inherit). Parse check ok on all four; dev tests 113/113; debt dev_loc +1 accepted with that reason.
  This touches project/dev: the final commit's gate must include it (selftest uses these scenes).
- 00:35 selftest on 5cda754c0+ HEAD (after NEEDS_WINDOW; `node tools/selftest/run.mjs`, windowed): exit 0, look goldens 11/11
  worst 0.00, block 5/5 worst 0.00, world lock holds. First real run of 7abcded29: `seen at neither site this run (a
  flicker row goes only after several quiet runs): blood_flicker_cop_48, blood_flicker_cop_block_64,
  blood_flicker_vehicles_48, blood_flicker_vehicles_vermilion_48` (4 rows; blood_flicker_vehicles_64 is no longer
  named: the block site saw it). Log gtai-n15/flake/selftest_s2.log.

NEXT (session 3; the 00:26 NEXT stands, with these changes): item (3) Linux sweep DONE (00:31, 825/823/0 on a real
clone). The final commit needs a full gate (`node tools/gate/run.mjs --rev=HEAD --reels`): project/dev/selftest
changed at 5cda754c0 (selftest passed on it at 00:35, unit/scenarios/reels not re-run since 52dc72d4).

## Session 3 (iteration 3, 00:36-02:06)

- 00:37 read JOURNAL, git log, hero/combat journals. Combat: no new REQUEST tools since 00:13 (all served). Hero has
  three unserved FRICTION lines: (a) 00:29 "each commit took ~1.5 min (the hook copies a 5336-file snapshot)", which
  stopped its five-commit loop at the session end; (b) 00:08 the hook ran a full lint on each of ten EMPTY commits;
  (c) 23:30 `evidence/run.mjs`'s selftest read its live, mid-edit tree (INVALID run); (d) 22:44 `stride_film
  --film-fire` never draws a one-row strip (worked around with cursor_sweep). Serving (a)-(c) ahead of the list.
- 00:40 measured the hook's cost: it is lint, not the snapshot. `node tools/lint/lint.mjs` 88 s on 1428 .gd
  (tool-tests alone 35 s; gdformat + gdlint about 50 s in 200-file batches); the export is about 2 s.
- 00:50 SERVED hero (a)+(b), c5ac2442a: `tools/lint/scope.mjs` + `lint.mjs --scope=<file>`; the hook passes the staged
  list. A commit whose non-inert staged paths are all under project/ runs gdformat + gdlint over its staged .gd only
  (per-file tools) and the tool tests only when it stages a file a tool test reads (`join(ROOT, '<path>')` literals:
  today only factory.test's city_spawn_plan.gd); every whole-tree check runs; anything outside project/ = full lint;
  gates always full. Empty commit: skipped only when `git write-tree` = `HEAD^{tree}` (the break tests' "an empty
  list is never a reason to skip" stands: it still runs lint). Tests: scope.test 6, precommit.test +2, staged_tree
  break test relaxed to "only --scope added"; gate+lint tests 166/0.
  PROVEN on real commits in a scratch detached worktree (gtai-n15/scratch-hook, removed after; probe commits
  unreachable): `lint: all 15 checks pass over 1 staged of 1428 GDScript files` real 4.3 s (forms_lineup.gd comment
  edit); `--allow-empty`: `pre-commit: nothing staged, the index tree is the HEAD tree: lint skipped` 1.9 s. Earlier
  probes failed for real reasons, which shows the narrowed hook still bites: a line added to a dev file -> FAIL
  debt-ratchet (dev_loc); an over-long comment -> FAIL gdlint; a line inserted in city_spawn_plan.gd -> tool-tests
  ran (an input) and factory.test's fixture line numbers failed. The commit of this change itself (tools/ staged)
  ran the full lint: 2m09s contended.
  TELL hero: after the Director merges n15-tools, a commit of strips/manifest/.gd under project/ takes ~4 s, not ~90 s.
- 00:54 TO hero (FRICTION 00:29 "each commit took ~1.5 min"): served on n15-tools c5ac2442a, Node-only (tools/lint,
  tools/gate, tools/README; no project/ file): `git cherry-pick c5ac2442a` in n15-hero makes each strip commit
  (PNG + manifest .json + .gd under project/) lint in ~4 s instead of ~90 s, and an empty commit skip lint. The
  Director's merge brings it anyway. Also 3fc7109a9 (Node-only): `evidence/run.mjs` now marks a kind INVALID, naming
  the paths, when the tree changed while it ran (hero 23:30); `tools/gate/run.mjs --rev=HEAD` runs the same kinds on a
  snapshot so you can keep editing.
- 00:54 hero FRICTION 22:44 (`stride_film --film-fire` never draws a one-row strip): NOT served: it is hero's own dev
  scene (project/dev/rivet_motion) and the walk legs draw the eq grids by design; hero's cursor_sweep STAND-leg
  workaround is the right film for single-row strips.
- 00:54 combat FRICTION (session 4): quest1 films differ by ~250k px at t13708 when the --stills list starts at a
  different tick. `tools/film/compare.mjs` passes one stills list to both sides by construction, so its pairs are safe;
  only hand-made pairs from two `film.mjs` runs can hit this. Not changed tonight.
- 00:55 CORRECTION to the 00:54 TO hero: `git cherry-pick c5ac2442a` alone CONFLICTS in tools/lint/lint.mjs on
  n15-hero (it builds on item 5's lint change). Use `git cherry-pick 39431687d c5ac2442a 3fc7109a9` (checked with
  `git merge-tree` against the n15-hero and n15-combat tips at 00:55: all three apply clean, in that order, on both).
- 00:57 hole found in my own 00:50 change, closed (112b0a12e): the `join(ROOT, ...)` literal rule missed real-tree
  reads that go through tool code. An fs trace of lint's tool-test run (`node --import ./tools/lint/fs_trace.mjs
  --test <the four globs>`, now committed; 470/470 pass under it) listed project/project.godot,
  data/tables/view.json, dev/frames/film_probe.gd, dev/showcase/reel_chapters.gd (film, feel_chapter, native_side)
  besides factory's city_spawn_plan.gd. Now any staged project/dev/, project/data/ or project.godot path runs the
  tool tests (`scope.mjs INPUT_PREFIXES`; test with the traced list). So the 00:50 4.3 s proof on a dev/ file would
  now run tool tests. Re-proven on a features/ commit (scratch worktree, removed): body_plan.gd comment + baton.png
  -> `gdformat + gdlint over 1 of 1428 .gd; tool-tests skipped` `lint: all 15 checks pass over 1 staged of 1428
  GDScript files` real 4.6 s. That is the shape of hero's strip commits (PNG + art .gd/.json under features/).
- 00:59 TO hero and combat (replaces the 00:55 line): `git cherry-pick 39431687d c5ac2442a 3fc7109a9 112b0a12e`
  (all Node tools; `git merge-tree` against both tips at 00:59: clean in that order). A commit of PNGs + features/
  .gd lints in ~5 s; one that stages project/dev/ or project/data/ also runs the tool tests (~35 s more).
- 01:01 MILESTONE hero FRICTION (c) PROVEN on a real run: scratch detached worktree at 3fc7109a9 (wt_init from this
  tree; removed after), `node tools/evidence/run.mjs --no-parity --no-bench --no-selftest --no-release`, a comment
  edit to project/dev/ghost-forms/forms_lineup.gd 25 s in (during lint, 00:53:02). Result, exit 1:
  `FAIL lint: lint: all 16 checks pass over 1428 GDScript files; INVALID: the tree changed while lint ran (1 code
  path(s): project/dev/ghost-forms/forms_lineup.gd) ... use tools/gate/run.mjs (a snapshot)`, and the same INVALID on
  unit-tests (2530 passed) and scenario-tests. Before this change lint and unit would have read PASS. Log
  gtai-n15/flake/evid_poison.log. (Unit's older applyChurn also calls the edit "import churn": wording only.)
- 01:02 FINDING (flake, not fixed): the same run's `scenario_rig_stress` FAILED on `Parameter "t" is null`
  (dummy `texture_2d_initialize`), GDScript frame `rig_head_card.gd:154 _build` <- `step` <- `cut_rig.drive`, in the
  ungated COMBO pass, with ~7 Godot processes of other lanes running. Fifth sighting (n11 hero it11 + it16 under
  `RivetFrames._set_strip`/`place`; world 11-08; d5-combat 11-03): always a texture `load()` on a cache miss, always
  on a busy machine, always passes alone. The null image means the .ctex read failed inside Godot; the cause
  (a file lock by another process? an engine race?) is not found tonight. Log gtai-n15/flake/evid_poison_scenarios.log
  (lines 420-443). NEXT candidate for item 6: reproduce with a loop of rig_stress under load + Process Monitor on
  .godot/imported/*.ctex opens.
- 01:03 item 4, a fresh REAL morning run (scratch worktree gtai-n15/scratch-integ2, new branch n15t-scratch-integ2 at
  main 5c5c03611, wt_init from this tree; `morning.mjs --lanes=n15-tools,n15-hero,n15-combat --date=2026-11-11
  --steps=merge,debt,bake,gates,export --timeout=40`; log gtai-n15/flake/morning_s3.log). Two firsts:
  (1) the baseline auto-resolve FIRED for real: `morning: tools/debt/baseline.json conflicted merging n15-hero: took
  the looser of both sides per metric and file ...`, merge committed, hero's JOURNAL moved.
  (2) MERGE NOTE FOUND: `STOPPED: merging n15-combat conflicted on 3 file(s): project/features/characters/
  cast_flags.gd, project/features/characters/rivet_res.gd, tools/debt/baseline.json`. hero and combat both edited
  cast_flags.gd (hero: `--ghost-` -> `_ghost()` with --ghost-soul-line=off; combat: WINDUP_FLAGS -> `_windup()` with
  --rivet-left-strike/--rivet-blade-left) and rivet_res.gd X15 (hero: 37 p70/p55 strips; combat: 6 blade left sets).
  Both are unions; resolved in the scratch (keep both dispatch branches + both helper funcs; keep both X15 lists),
  gdformat/gdlint clean, `tools/godot/check.mjs` ok on both.
- 01:08 the baseline beside a code conflict: the stop's advice ("take either side, then --update") FAILED the merge
  commit (`FAIL debt-ratchet`: the side taken did not cover the other side's growth; --update only tightens). Fixed
  e33dcf6a4: `node tools/debt/merge_baseline.mjs` (inside a conflicted merge) writes and stages the looser of both
  sides, the same merge the auto-resolve does; the stop's advice names it, plus `--accept-regression` if the merged
  tree is worse than both. Real run: `merge_baseline: tools/debt/baseline.json = the looser of both sides per metric
  and file, staged (6 metrics)`, then `debt-ratchet: ok`, merge commit `lint: all 16 checks pass over 1444 GDScript
  files`. Test with a real throwaway repo (code + baseline conflict); merge tests 91/91. tools/debt/README + AGENTS
  line updated. I did NOT make the morning merge resolve the baseline when code also conflicts: its break tests
  require "touch nothing when a code file conflicts" (tried it, reverted).
- 01:10 resumed (`--resume`, log gtai-n15/flake/morning_s3b.log): `merge: green` (combat had a newer tip: merged
  again clean), `debt: green`, `bake: green` (FIRST real bake step: `ok exit 0; SCRIPT ERROR 0` via tools/dev/run.mjs
  `res://dev/bake_city.gd`, chunks matched the hash list), gates running.
- 01:16 TO hero and combat: your branches conflict with each other (not with n15-tools) on
  project/features/characters/cast_flags.gd (both added a flag dispatcher) and rivet_res.gd (both appended to X15).
  Both are unions; the Director's recipe and a tested resolution are in REPORT merge notes and
  evidence/merge_hero_x_combat_686fcb828.diff. Adding more to either file tonight grows the conflict, not its kind.
- 01:16 rig_stress flake, HYPOTHESIS (to test): in Godot's dummy renderer (headless) `texture_2d_initialize` reads
  `DummyTexture *t = texture_owner.get_or_null(p_texture); ERR_FAIL_NULL(t)`: the null `t` is the texture looked up
  by RID, not the image. The dummy owner is not thread-safe (the RD renderers' is), and the game creates textures on
  worker threads (`StreetStrips.prefetch`/`prefetch_fall` since d9 perf L3, `CityTextures` via
  `load_threaded_request`) while the main thread `load()`s others (rig_head_card._build, RivetFrames._set_strip). A
  race there loses a RID: exactly the five sightings (headless only, a texture load, more on a busy machine, passes
  alone). Repro written (not run yet: the Godot slot is the morning gates'): gtai-n15/flake/race/ (standalone
  project; `race.gd` makes ImageTextures on N worker threads while the main thread makes 20000;
  `-- --threads=4` vs `--threads=0`). If it reproduces, the fix is the game's, not a timeout: no worker-thread
  texture decode under the dummy renderer (StreetStrips.enabled(), CityTextures), with a test override so the
  prefetch tests still bite.
- 01:22 MILESTONE item 4 gates lines PROVEN on a real morning run (scratch-integ2, `--resume`, log
  gtai-n15/flake/morning_s3b.log): `morning: merge: green`, `debt: green`, `bake: green`, then one line per kind:
  `morning: gates: lint pass: lint: all 16 checks pass over 1446 GDScript files`, `unit-tests pass: 2581 passed, 0
  failed, 2 skipped`, `parity pass: ... bit for bit over 1200 steps ... planted mutation caught at step 629`,
  `selftest pass: ... look goldens 11/11 ...`, `export-audit pass: release-compile: 673 loaded, 0 failed`,
  `scenario-tests fail: ... 1 of 55 failed (scenario_rig_stress.gd)` -> `STOPPED: the gates are red`. The export
  step therefore did not run (still never run for real). The red was the rig_stress flake again, now under
  `StreetStrips.get_tex` (street_strips.gd:32, a main-thread load()).
- 01:23 MILESTONE item 6 rig_stress flake: CAUSE PROVEN with a standalone repro (gtai-n15/flake/race, kept in
  evidence/dummy_texture_race/): headless, 4 worker threads making ImageTextures beside the main thread: 2 of 2 runs
  `Initializing already initialized RID` + `Parameter "t" is null` (3-4 per run) + SEGFAULT (exit 139); headless
  main thread only: 2 of 2 clean (20000 made); d3d12 with 4 threads: 2 of 2 clean. The dummy renderer's texture RID
  owner is not thread-safe. Fixed at the cause, c3f80513d: `TextureThreads.allowed()` (false under the headless
  display server) guards StreetStrips.prefetch and CityTextures' threaded requests; headless loads in place. First
  try put the guard in StreetStrips.enabled(): test_weapon_fx_warm failed (WeaponFxWarm reads enabled() as the
  --strip-prefetch flag for a main-thread warm): moved into prefetch(). `--select=test_weapon_fx_warm,
  test_rivet_strip_warm,test_street_strips` 20/0 (new test: headless asks no worker, loads on first use). The
  scoped hook caught my unformatted test in 2.8 s. DECISION render/texture-threads in docs/decisions.md.
- 01:27 full gate on HEAD started (`node tools/gate/run.mjs --rev=HEAD --timeout=40`, log
  gtai-n15/flake/gate_s3_head.log).
- 01:29 TO hero and combat: the scenario_rig_stress `Parameter "t" is null` flake (it hit hero in n11 twice and the
  integrated gates tonight) is FIXED at its cause on n15-tools c3f80513d (headless never decodes textures on a
  loader thread; real renderers unchanged, so no frame or golden moves). `git cherry-pick c3f80513d` applies clean
  on both your tips (merge-tree, 01:29); it adds project/core/render/texture_threads.gd (+.uid).
- 01:31 the same race explains the OTHER long-known flake: `test_noir_shadows::test_only_shadow_commands_with_a_length_
  are_swept` "fails intermittently (Parameter "t" is null, an engine texture error)" in several older lane docs
  (docs/day|night/*, grep test_noir_shadows); it builds CityTextures, whose loader-thread requests now load in place
  headless (c3f80513d). Not yet proven by absence (a flake needs many quiet runs); morning.mjs's red-gates advice
  still names it as a known flake: drop that after a few clean nights, not tonight.
- 01:48 MILESTONE gate on c3f80513d (the flake fix; `node tools/gate/run.mjs --rev=HEAD --timeout=40`, log
  gtai-n15/flake/gate_s3_head.log): `gate: PASS` - lint 16/16, `unit-tests: 2531 passed, 0 failed, 2 skipped`,
  `scenario-tests: 55 ran, CONTENDED: rig_stress.rigMsP50 1.036 > 1.000 (4 other runs); budget not judged` (no
  texture error), parity bit for bit (planted caught at 629), selftest look 11/11 + block 5/5 worst 0.00, world lock
  0.00 %, `release-compile: 668 loaded, 0 failed`. Removed my gate snapshots (c3f80513d, eb65c8b05, 1af97f018); the
  3 left in the worktree list are n15-combat's (54297457d, 5bdad7a0c, 896c5c30d: `git branch --contains`): not mine.
- 01:49 scratch-integ2 (branch n15t-scratch-integ2) is KEPT for the next session: it holds the hero x combat
  resolution (686fcb828), combat's newer tip, and n15-tools merged again at 71f0d5b1c (with the flake fix).

NEXT (session 4): (1) Read hero/combat JOURNALs for REQUEST tools / FRICTION (served up to 01:29; cherry-pick lists
in the 00:59 and 01:29 entries). (2) On gtai-n15/scratch-integ2 run the last two morning steps for real:
`node tools/merge/morning.mjs --worktree=C:/Users/kazda/kiro/gtai-n15/scratch-integ2 --lanes=n15-tools,n15-hero,
n15-combat --date=2026-11-11 --steps=gates,export --resume --timeout=40 --debt-reason="n15 scratch integration"`
(APPDATA tools; ~15 min): proves the integrated scenarios green with the fix and the export step (never run for
real). If --resume refuses because merge state says gates is next, that is what is wanted. Then `git worktree remove
--force C:/Users/kazda/kiro/gtai-n15/scratch-integ2` and `git branch -D n15t-scratch-integ2`. (3) Reel gate on the
final commit (`node tools/reel/run_reels.mjs`; c3f80513d touched project/). (4) t-5 cost under the bench lock only if
nothing heavy runs (else CONTENDED stays). (5) REPORT final: Calls (c-1, c-2), merge notes (order tools -> hero ->
combat, the conflict recipe, the flake fix). (6) End of night: `git worktree remove --force
C:/Users/kazda/kiro/gtai-n15/scratch-tools-before`, `git branch -D n15t-control-sim-hash`.

## Session 4 (iteration 7, 01:49 - 03:19), BUILD

- 01:50 read JOURNAL, git log, hero/combat journals: no new `REQUEST tools` or FRICTION since 01:29 (hero 00:59 FRICTION
  = evidence/run.mjs on the live tree, already served by 3fc7109a9 + `tools/gate/run.mjs`; combat "none new").
- 01:50 started NEXT (2): `node tools/merge/morning.mjs --worktree=C:/Users/kazda/kiro/gtai-n15/scratch-integ2
  --lanes=n15-tools,n15-hero,n15-combat --date=2026-11-11 --steps=gates,export --resume --timeout=40
  --debt-reason="n15 scratch integration"` (APPDATA tools; log gtai-n15/flake/morning_s4.log).
- 01:58 MILESTONE integrated gates GREEN with the flake fix (scratch-integ2 = n15-tools 71f0d5b1c + hero + combat +
  the hero x combat resolution; log gtai-n15/flake/morning_s4.log): `morning: gates: scenario-tests pass:
  scenario-tests: 55 passed (headless)` (the step that stopped at 01:22 on rig_stress), `unit-tests pass: 2582 passed,
  0 failed, 2 skipped`, lint 16/16 over 1447 files, parity bit for bit (planted caught at 629), selftest look 11/11,
  `export-audit pass: release-compile: 674 loaded, 0 failed`, `morning: gates: green`. Export step started (first real run).
- 01:59 MILESTONE item 4 DONE for real, every step: `morning: export: green`, `morning: DONE at 71f0d5b1 on
  n15t-scratch-integ2. Nothing was pushed; main was not touched.`, exit 0 (export log: `[ DONE ] savepack`;
  build/export/windows/RTAI.exe 649691976 B + gtai_sim.windows.template_release.x86_64.dll). Boot smoke of that exe
  (`RTAI.exe --headless --fixed-fps 60 --quit-after 300`): exit 0; 2 engine ERROR lines (a headless shader
  `custom_samplers` condition, `101 resources still in use at exit`), not compared against a main export. Log kept:
  evidence/morning_s4_gates_export.log. Scratch worktree removed (`git worktree remove --force` deregistered it but
  hit Permission denied: my shell's cwd was inside; dir removed after) and `git branch -D n15t-scratch-integ2`.
- 02:00 t-4 on a HAND-MADE map (c-2 said "invisible in the shipped city"): new dev tool
  `project/dev/sim/car_route_trails.gd` drives the real reference-sim car code (CitySimCars, tier B, 3 cars x 60 s) on
  a map whose roads end at a plaza (E), a kerb (N) and void (W, S); run in this tree and in scratch-tools-before
  (d720e22da, the old rule). U-turns (evidence/t4_trails/{before,after}.json): BEFORE 3 at the plaza (tile 7), 1 at
  the kerb (4), 5 at void; AFTER 7, all at void. SEEN (`gtai-masters/n15/tools/t4-hand-map-trails-before-after-4ppm.png`):
  after t-4 the east car drives across the whole plaza and into the building block behind it, the north car through
  the kerb into the block, both turning 18 m before the void. That is the comment's rule taken literally, and it is
  wrong for a dead-end street on a hand-made map. The owner should judge it: c-2 rewritten. Building the alternative as
  one data value next (a tile mask in sim_constants.json car_route; default = t-4 as built, so nothing moves).
- 02:08 MILESTONE c-2's alternative is ONE data value: `CAR_DEAD_END_TILES` (sim_constants.json car_route, int, a bit per
  T_* code; gen.mjs -> SimConst + sim_constants.h; `CitySimCarRoute.dead_end(t)` and `dead_end` in car_route.cpp; a
  junction never is). Shipped 1 = t-4 as built. NATIVE REBUILD #4 (this lane only): scons debug + release exit 0,
  `scons tests` + `sim_core tests: 0 failed`; `run_parity.mjs`: bit for bit, planted caught at 629, final_sha_a
  94b2865f7f17d778 (unchanged). `run_unit --select=test_sim_car_route_t4,test_sim_car_route_break,
  test_sim_car_route_break_exits,test_city_lane_grid` 18/0 (new test: the mask keeps T_VOID, never a road or junction,
  shipped 1). Proof by the trails tool with the GDScript constant edited in place (restored after; `git diff` clean):
  mask 241 U-turns == before.json (the pre-t-4 build) exactly, mask 1 == after.json exactly, mask 65 turns before
  blocks (6) and void only. SEEN `gtai-masters/n15/tools/c2-dead-end-mask-241-1-65-4ppm.png` (3 panels).
  The generated doc string first broke gdlint's 100 columns in sim_constants.gd (quick gate caught it): shortened.
- 02:11 the t-4 tests hard-coded "a kerb/plaza/block ahead is no dead end", so the owner's flip would have needed test
  edits: test_sim_car_route_t4 (independent formula `(CAR_DEAD_END_TILES >> tile) & 1`) and the Codex break test
  (via `dead_end`) now follow the mask. Proof, SimConst edited in place and restored: `run_unit --select=
  test_sim_car_route_t4,test_sim_car_route_break,test_sim_car_route_break_exits,test_sim_car_route` mask 1: 21/0,
  mask 241: 21/0, mask 65: 21/0. Dropped my own `CAR_DEAD_END_TILES == 1` pin for the same reason.
- 02:12-02:15 t-5 cost again, now with an A/A twin (bench lock created noclobber, deleted after; CONTENDED: 8-15 other
  Godot processes at each run start, column 6). `evidence/t5_aab.sh 6` -> `evidence/t5_aab.tsv`: per round one
  parity run (1200 steps, both sims) each of A = scratch-tools-before d720e22da (HW 80, pre-t-4), A2 = A again,
  B = n15-tools aded9845b (HW 132), order rotated. GDScript reference step: B-A 0.639 1.038 0.612 0.489 0.394 0.915 ms
  (median +0.63 ms on 4.43 ms, +14 %, B slower 6/6), A2-A median -0.14 ms (2/6 positive). Native step: B-A 15.3 12.9
  5.7 9.5 8.5 5.5 us (median +9.0 us on 52 us, +17 %, 6/6), A2-A median -1.8 us (1/6). Sign test 6/6: p = 0.031.
  The A/A spread (max |0.41| ms, |9.2| us) overlaps B-A's smallest round, so the size is soft; the sign is not.
  Cause, read: `CitySimHash.build` walks all HW*HW cells for its prefix sums every step (6400 -> 17424). B-A also
  holds t-4 (route code, same tile reads). Native +9 us/step is 0.05 % of a 16.7 ms frame.
- 02:18 SERVED hero FRICTION (n15-hero JOURNAL "`git show <rev>:<png> > file` writes the LFS pointer"): new
  `node tools/film/blob.mjs <rev>:<path> [--out=<file>]` reads the blob and runs a pointer through `git lfs smudge`.
  Real run: `blob.mjs HEAD~5:project/addons/gut/gui/arrow.png --out=build/blob_proof/arrow.png` -> `wrote ... (122
  bytes, LFS object, smudged)`, PIL opens it (20x20 LA), byte-identical to the checkout, where `git show` of the same
  spec prints `version https://git-lfs...`; a plain blob says `plain blob`; a missing path exits 1 naming git's error;
  usage exit 2. `tools/film/blob.test.mjs` 3/3 (throwaway repo, no inherited git env). tools/README line.
- 02:21 Codex tester for the c-2 mask: NOT dispatched, by choice. The change is a one-line predicate whose default is
  the t-4 behaviour Codex's 23 break tests already attack (now mask-relative, 21/0 at three values), and the Godot slot
  is the final gate's until ~02:50; a tester round (write, run, review) would not land before the 03:19 stop.
- 02:21 TO hero: your 02:1x FRICTION (`git show <rev>:<png>` writes the LFS pointer) is served on n15-tools f059cfc44:
  `node tools/film/blob.mjs <rev>:<path> --out=<file>` (Node only; `git cherry-pick f059cfc44` adds tools/film/blob.mjs,
  its test and a tools/README line).
- 02:27 gate on d2226608d (`node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`, log gtai-n15/flake/gate_s4_head.log):
  lint PASS; unit 2532/0, scenarios 55, parity exact (caught at 629), selftest look 11/11 + block 5/5 worst 0.00,
  release-compile 668/0, but every Godot kind FAILED `INVALID: the tree changed while <kind> ran (1 code path(s):
  project/dev/sim/car_route_trails.gd.uid)`. MY slip: 6b9d2a900 committed the .gd without its .uid, Godot wrote it in
  the snapshot, and the 3fc7109a9 guard caught it (the guard working as built). Fixed fc599f172 (the .uid).
- 02:33 so it cannot recur: lint check `uid-files` (tools/style/uid_files.mjs, wired in lint.mjs): every own project .gd
  in the INDEX has its .gd.uid in the index (addons exempt; outside git: not judged). Reads the index, so the hook
  judges the commit. Real runs: over `git ls-tree 6b9d2a900` -> `FAIL project/dev/sim/car_route_trails.gd: its .uid
  is not in the index`; over fc599f172 -> ok; a staged probe .gd in this worktree -> FAIL naming it (unstaged and
  deleted after, status clean). `tools/lint/uid_files.test.mjs` 2/2. AGENTS lint row names it.
- 02:35 uid-files over the other tips (`git ls-tree -r <rev> project` into `uidCheck`): n15-hero 4a6238732 ok,
  n15-combat 11a460e80 ok, main 5c5c03611 ok. The new check does not turn a merge red tonight.
- 02:43 MILESTONE reel gate on d2226608d (same gate run): `top: OK; code 0`, `tilt70: OK; code 0`, `combo: OK; code 0`
  (combo 328 s); `gate: FAIL` only for the INVALID kinds above.
- 02:52 MILESTONE gate on 6f7422812 (`node tools/gate/run.mjs --rev=HEAD --timeout=40`, log
  gtai-n15/flake/gate_s4_head2.log): `gate: PASS` - `lint: all 17 checks pass over 1430 GDScript files`, `unit-tests:
  2532 passed, 0 failed, 2 skipped`, `scenario-tests: 55 passed`, parity bit for bit (planted caught at 629), selftest
  look 11/11 worst 0.00, `release-compile: 668 loaded, 0 failed`. Both my gate snapshots removed
  (`removeSnapshot`; `git worktree list` holds neither).
- 02:53 `node tools/evidence/cites.mjs REPORT.md`: 35 paths, 34 ok, 1 UNCHECKED (the word INVALID in a quoted message).
  Masters `gtai-masters/n15/tools/frames.json` 8 entries, every file referenced (plus the ledger); scratch trail renders
  in gtai-n15/flake/trails deleted (the JSONs and scripts are in evidence/t4_trails/).

NEXT (session 5): (1) Read hero/combat JOURNALs for REQUEST tools / FRICTION (served up to 02:21: hero's LFS FRICTION
-> blob.mjs f059cfc44). (2) Weakest item = t-5's cost (+9 us native, +0.63 ms ref per step, all from
`CitySimHash.build` walking HW*HW = 17424 cells). Make build O(actors) in BOTH sims with byte-identical hcount/hstart/
hidx for every occupied cell (count live actors per cell keeping a touched-cell list, zero last step's touched cells,
assign starts over the touched cells in ascending cell index, fill); query only reads occupied cells' starts. Prove:
parity bit for bit + final_sha_a 94b2865f7f17d778 unchanged, `test_sim_hash*` green, `evidence/t5_aab.sh 6` again
(A = scratch-tools-before HW 80, B = new build): the B-A delta should fall toward 0. Native rebuild #5 = say so in
JOURNAL. Mutate sim_hash.gd after (`tools/mutate/mutate.mjs --file=features/city/sim/sim_hash.gd`, commit first).
(3) Full gate + reels on the final commit (`node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`), remove the
snapshot after (`removeSnapshot`). (4) REPORT final at 07:40. (5) End of night: `git worktree remove --force
C:/Users/kazda/kiro/gtai-n15/scratch-tools-before` (holds an untracked copy of dev/sim/car_route_trails.gd: mine) and
`git branch -D n15t-control-sim-hash`.
- 02:55 scoped NEXT (2), read only: `sim_hash.gd` `build` does `hcount.fill(0)` + a prefix loop over all HW*HW cells +
  two CAP loops; `query` reads `hstart[c]` only through `for k in hcount[c]`, so an empty cell's start is never used.
  No GDScript outside sim_hash.gd reads hcount/hstart; native twins are `hash.cpp` + `city_core.h` (`hstart_`,
  `hcount_`). Plan: keep a touched-cell list; zero last step's touched cells (not `fill`); count; sort the touched
  list ascending (k <= CAP actors); starts over it in that order; fill. hitems comes out in the same (cell asc, id asc)
  order as the counting sort, so query order and parity hold by construction; `hstart[hw*hw]` = total as now.
- 02:52-03:00 NEXT (2) DONE early: hash build O(actors) in both sims (`sim_hash.gd` touched-cell list, `Array[int]`
  because PackedInt32Array.append's bool fails warnings-as-errors; `hash.cpp` + `htouched_`/`htouched_n_` in
  city_core.h, first build memsets). NATIVE REBUILD #5 (this lane only): debug + release exit 0, `sim_core tests: 0
  failed`. `run_parity.mjs`: bit for bit, planted caught at 629, final_sha_a = final_sha_b = 94b2865f7f17d778
  (unchanged). `run_unit --changed` 1285/0 (incl. the four test_sim_hash* files). Cost (`t5_aab.sh 6`, bench lock,
  CONTENDED 2-9 others; `evidence/t5_aab_build.tsv`; A = HW 80 old build): B-A native -6.0 -6.6 -6.3 -1.9 -0.8 -0.9 us
  (median -4.0 on 48 us; A/A median -2.1), GDScript ref median -0.27 ms on 4.20; B faster 6/6 in both. The wider
  window now costs nothing measurable. DECISION sim/hash-build in docs/decisions.md. Not yet: mutate of sim_hash.gd,
  full gate on this commit (next session).
- 03:01-03:07 mutate on the O(actors) build (`tools/mutate/mutate.mjs --file=features/city/sim/sim_hash.gd --max=15
  --tests=test_sim_hash,test_sim_hash_break,test_sim_hash_break_order,test_sim_hash_window`, on 2229fdd98; log
  evidence/mutate_sim_hash_build_2229fdd98.log): `score 86.7% = killed 13 / (killed 13 + survived 2)`, 329 s,
  checkout clean after. Survivors, both judged equivalent: `:9 var hgx: int = 0 -> 1` (build() reassigns hgx before
  any query); `:41 hstart[hw * hw] = s -> hstart[hw / hw]` (the sentinel is a DEAD STORE nothing reads; writing the
  total into cell 1's start moves cell 1's items past the others in hitems, and fill and query read the same start, so
  results are equal unless all 512 slots are tier A in the window). Planted by hand against a new test: still 3/3, so
  not killable short of a full CAP. Next: delete the dead sentinel in both sims (and the +1 array size).
- 03:08 new test `test_the_window_corners_and_a_rebuild_keep_every_actor_in_its_cell` (window cell 1, the last cell,
  a move then rebuild leaves the old cell empty). Planted by hand: the touched-cell clear removed -> 12 of 20
  sim_hash tests fail (incl. this one's file), restored after (`git status`: only the test file).
- 03:09 TO hero and combat: n15-tools changed the sim again (hash build O(actors), native rebuild #5); parity's final
  digest is unchanged and nothing you film reads it: keep your DLLs.

NEXT (session 5; replaces the 02:53 NEXT): (1) Read hero/combat JOURNALs for REQUEST tools / FRICTION (served to
02:21). (2) FIRST: full gate + reels on HEAD (`node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`, APPDATA
tools): the last PASS (6f7422812) predates the hash-build sim change 2229fdd98; remove the snapshot after
(`removeSnapshot` from tools/lib/snapshot.mjs). (3) Delete the dead `hstart[hw * hw]` sentinel (and the +1 sizes) in
sim_hash.gd + hash.cpp/city_core.h if nothing reads it (`grep -rn "hstart" project native`), native rebuild #6,
parity, mutate again. (4) REPORT final at 07:40 (Calls c-1, c-2; merge notes: tools first, rebuild DLLs). (5) End of
night: `git worktree remove --force C:/Users/kazda/kiro/gtai-n15/scratch-tools-before` (an untracked copy of
dev/sim/car_route_trails.gd there is mine) and `git branch -D n15t-control-sim-hash`.

## Session 5 (03:09-04:39)

- 03:09 read JOURNAL, git log, hero + combat JOURNALs: no new REQUEST tools / FRICTION for me since 02:21 (hero's
  new FRICTIONs are their own sheet tools; combat's LFS FRICTION = blob.mjs, served f059cfc44).
- 03:09-03:11 NEXT (3): deleted the dead `hstart[hw * hw]` total sentinel (and the +1 array sizes) in sim_hash.gd and
  hash.cpp/city_core.h (`grep -rn hstart project native`: no reader outside build/query). NATIVE REBUILD #6 (this lane
  only): template_debug + template_release + `scons tests` exit 0, `sim_core tests: 0 failed`. `run_parity.mjs`: bit
  for bit over 1200 steps, planted caught at 629, final_sha_a = final_sha_b = 94b2865f7f17d778 (unchanged).
  `run_unit --select=test_sim_hash*` 20/0.
- 03:12-03:16 mutate on 0736f3496 (`tools/mutate/mutate.mjs --file=features/city/sim/sim_hash.gd --max=15 --tests=test_sim_hash,
  test_sim_hash_break,test_sim_hash_break_order,test_sim_hash_window`; evidence/mutate_sim_hash_build_0736f3496.log):
  `score 93.3% = killed 14 / (killed 14 + survived 1)`, 242 s, checkout clean. Survivor `:8 var hgx: int = 0 -> 1`:
  equivalent (build() sets hgx before any query reads it). The sentinel survivor of 2229fdd98 is gone with the code.
- 03:16 gate started on 0736f3496 (`node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`, background, log
  gtai-n15/flake/gate_s5_head.log).
- 03:17 merge preview (`git merge-tree --write-tree`, main + tools + hero 88077fb80 + combat 7778d347a in order): tools
  and hero merge clean except JOURNAL + baseline (morning.mjs handles both); combat conflicts on the same two code files
  as at 01:03, cast_flags.gd and rivet_res.gd. New `evidence/merge/resolve_hero_x_combat.py` writes the union (refuses if
  a side changed shape); on these tips its output passes gdformat --check, gdlint, `longFunctions` = [] (apply 40 lines).
  `evidence/merge/hero_x_combat_resolution.diff`. REPORT merge notes point to it.
- 03:19 CORRECTION: the four times above were first written as guesses (03:12-03:35); the real ones come from the commit
  and file times (`git log --date=format:%H:%M:%S`, `ls --time-style`): 0736f3496 03:11:08, mutate log 03:16:11, resolver
  03:16:55, f2c75f9a4 03:17:30. f2c75f9a4's message says "03:35 tips": the tips were read at 03:17.
- 03:18-03:21 Codex TESTER for the O(actors) hash build: `npx tsx scripts/codex/dispatch.ts run
  gtai-n15/codex/n15t-break-hash-build.json` (base f2c75f9a4; laws as n15t-break-hash-window: never launch Godot, never
  change game code). `status: done`, 9 tests, 240 lines, openQuestions none. REVIEW (every line read): an independent
  oracle (alive/tier/px/py + SimConst, sorted cell row, column, id) AND a fresh-hash comparison on every query; attacks
  vacated cells, death/revival, tier 0<->1/2, camera jumps of 4 x HW cells (same index, other place), 512 cells; no
  randomness (patterned ids), so no RNG law issue. What review changed: (1) split into two files + a support class
  `project/tests/support/sim_hash_oracle.gd` (SimHashOracle: place/point/origin/build/expected/check(t, ...)), because
  240 lines would raise the debt ratchet's files_past_soft_cap; test bodies unchanged except `_x(` -> `_o.x(` (my first
  plain replace mangled two test NAMES, `each_build` -> `each_o.build`; redone with word-boundary regex, diffed against
  Codex's original). (2) the doc lines. Not yet run (Godot slot = the gate).
- 03:19 dev tool: `res://dev/sim/car_route_trails.gd --tier=a` (c-2's unfilmed half): cars spawn tier A, the map's 1 m
  cells are filled from each tile's kind (road/junction lane, kerb/plaza walk, block building, void void), the hash is
  built each tick around the map centre, and each row records `dead_at_tick` (a tier A car stuck 20 s dies). Default
  (tier B) unchanged. Not yet run (Godot slot).
- 03:25 gate on 0736f3496 (log gtai-n15/flake/gate_s5_head.log), evidence kinds: `lint: all 17 checks pass over 1430
  GDScript files`, `unit-tests: 2533 passed, 0 failed, 2 skipped`, `scenario-tests: 55 passed`, parity bit for bit
  (planted caught at 629), selftest look 11/11 + block 5/5 worst 0.00, `release-compile: 668 loaded, 0 failed`. Reels
  running.
- 03:46 MILESTONE gate on 0736f3496 (the hash-sentinel delete): `PASS reels: exit 0`, `gate: PASS` (build/gate/
  0736f3496b5e/gate.json); my snapshot removed (`removeSnapshot`; the 6 gtai-gate-* left in `git worktree list` are
  other lanes', e.g. 7778d347a = combat's tip: not touched).
- 03:46 Codex tester run by me: `run_unit --select=test_sim_hash_build_break,test_sim_hash_build_break_moves --no-rerun`
  -> `9 passed, 0 failed`. Bite check (planted by hand, `git checkout --` after, status clean): (a) the touched-cell
  clear removed -> `7 failing (2 passed, 7 failed)`; (b) `_touched.sort()` removed -> 9/9 PASS. (b) is no gap in the
  tests: query walks cells row-major and reads each cell's own start, so the touched list's order never shows; nothing
  else reads hitems (`grep -rn "hitems" project native`). So the sort is dead work in both sims: removing it next.
  Thrown away: nothing. No defect found.
- 03:47 c-2 in TIER A (`bash evidence/c2_tier_a/run.sh`, all exit 0, constants restored): tier B default re-run ==
  evidence/t4_trails/after.json (`cars equal: True`). Tier A, U-turns (tick, tile ahead) per car:
  241: car0 (1417 plaza, 2484 void, 3573 plaza), car1 (945 plaza, 2132 kerb, 2973 void), car2 3 x void.
  1 (shipped): car0 NONE, dead_at_tick 3022 (stuck 20 s against the block at the plaza's far edge); car1 NONE, alive,
  sitting behind it; car2 3 x void. 65: car0 (1657 block, 2918 void), car1 (1185 block, 2480 block), car2 (2 void,
  3592 block); nobody dies. SEEN the 3 panels + a crop of mask 1's plaza (both eastbound trails end at the block edge).
  Masters `c2-tier-a-mask-241-1-65-4ppm.png` (frames.json now 9). This strengthens c-2's recommendation (65).
- 03:50-03:53 the dead sort removed in both sims (`_touched.sort()`, `std::sort` + `<algorithm>`; comments say "first
  met first"). NATIVE REBUILD #7 (this lane only; once more after a comment-only edit so the DLLs match the source):
  debug + release + `scons tests` exit 0, `sim_core tests: 0 failed`. `run_parity.mjs` (both builds): bit for bit,
  planted caught at 629, final_sha_a 94b2865f7f17d778 (unchanged). `run_unit --select=` the six sim_hash files 29/0.
  DECISION sim/hash-build-order in docs/decisions.md. Codex dispatcher ledger: `record n15t-break-hash-build --verdict
  accepted-after-revision` (144 s, 5593 tokens out), then `discard`.
- 03:54 TO hero and combat: n15-tools changed the sim again (hash build, native rebuild #7); parity's final digest is
  unchanged and nothing you film reads it: keep your DLLs.
  (times 03:46-03:54 checked against `git log --date=format:%H:%M:%S`: 6254f741e 03:49:13, d195c73df 03:50:31,
  4af7cf1fa 03:53:03.)
- 03:54-03:59 mutate on 4af7cf1fa with all six sim_hash test files (`tools/mutate/mutate.mjs
  --file=features/city/sim/sim_hash.gd --max=15 --tests=test_sim_hash,test_sim_hash_break,test_sim_hash_break_order,
  test_sim_hash_window,test_sim_hash_build_break,test_sim_hash_build_break_moves`;
  evidence/mutate_sim_hash_build_4af7cf1fa.log): `score 100.0% = killed 15 / (killed 15 + survived 0)`, 310 s,
  checkout clean (was 14/15 on 0736f3496, 13/15 on 2229fdd98).
