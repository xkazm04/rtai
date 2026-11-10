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
