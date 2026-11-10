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
