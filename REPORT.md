# REPORT n15-tools (draft, session 2, 00:20; later sessions extend it)

Branch `n15-tools` from main `5c5c03611`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n15\tools\` (`frames.json`),
`evidence/` in this tree, JOURNAL.md for every command and its output.

## The owner's Calls

| Call | Built | Test (fails before, passes after) | Numbers / frames |
|---|---|---|---|
| t-1 CitySpawnPlan turns | `_turn += q + 1` (d720e22da) | `test_city_spawn_plan_turns.gd` (`[2,2,3,2] != [2,3,2,3]`, 8 of 30 turns for 10); Codex's n11 test landed unchanged | moves the city sim (parity final digest 9cd5579a -> 94b2865f) and the 16 look/block goldens: re-blessed eb65c8b05, before/after stills in masters |
| t-2 overrule with a reason | `factory.mjs review --overrule=` / `overrule <id> --reason=` (7ef39b42e) | 3 factory tests | city_spawn_plan: 25/39 killed, all 14 survivors equivalent (named in decisions.md), 25/25 killable; recorded in the n15 ledger |
| t-4 car routing | U-turn only on T_VOID, exits honour orientation, 18/2.5/13/16 m in `sim_constants.json` group `car_route`, GDScript + C++ (fe5dccda0) | `test_sim_car_route_t4.gd` 3 of 5 fail on the old rules; `test_city_lane_grid.gd` audits 256 chunks | parity exact; final digest unchanged: the old rules never fire in the generated city. Film (city street, 32 px/m, t300-900): 0 of 1024000 pixels differ at t300/600/900, before = a worktree at d720e22da with the pre-t-4 DLL (`t4-city-street-32ppm-before-after-*` in masters) |
| t-5 hash window | HW 80 -> 132 cells (528 m), both sims (0ba5b1e91) | `test_sim_hash_window.gd` (empty query at 256 m on HW 80) | CONTENDED, bench lock held: native +5.8 us/step median, GDScript ref +0.34 ms/step (`evidence/t5_ab.tsv`) |

Native rebuilt twice tonight by this lane (22:09 t-4, 22:30 t-5), debug + release, `sim_core tests: 0 failed`.

## Parity and replay

No replay or parity golden is committed: both gates compare two runs of one build, so nothing needed a
re-bless. Parity stays bit-exact. What moved: t-1 changes the city sim's spawn order (and so the selftest
crowd: look goldens re-blessed with a decisions line). t-4 and t-5 move nothing measurable (same final digest).

## Tools changed

- `tools/lint/lint.mjs`: every failing tool test is named; issues past 40 go to `build/lint/<check>.txt` (path + count printed).
- `tools/merge/morning.mjs`: a `tools/debt/baseline.json` conflict merges to the looser side per file and says so; limits rounded to whole ms.
- `tools/lib/node_start.mjs`: timer tests budget their cold node starts (the flake's cause; reproduced with a start-delay preload, fixed on Windows and Linux).
- `tools/codex/factory.mjs`: t-2 overrule.
- `tools/film/compare.mjs`: `--victim=<kind>` to both sides (combat's REQUEST).
- `tools/film/shots.mjs` + `film.mjs`/`compare.mjs` (combat's REQUESTs, ba6f38838): the director's extras are
  chapters (`chapter:electro_baton_left`, `chapter:katana_cam`), and `--feel=auto|on|off` before the `--`.
  Example: `film.mjs chapter:electro_baton_lft --dry-run` -> `did you mean electro_baton_left?`.
- `tools/film/compare.mjs` (70ebf0634): refuses a commit side whose `native/` differs from HEAD (its snapshot would run
  this tree's DLLs); `--native=donor` for view-only changes.
- `tools/style/check_gd.mjs` (26f18e5ef, combat's FRICTION): the function-size count stops at the body; a column-0
  doc comment of the next function no longer counts (2 of 5 new tests fail on the old rule).
- `tools/merge/gate_lines.mjs` (725845086): the morning gates step prints one line per evidence kind, STALE when written
  for another commit. Example (real evidence): `morning: gates: unit-tests pass: unit-tests: 2529 passed, 0 failed, 2 skipped`.
- `tools/selftest/run.mjs` (7abcded29): an accent debt row is "unseen" only when neither site saw it, and it is no longer
  a delete order (the integrated run told us to delete a row its own block run had counted).
- `tools/lib/dev_verdict.mjs` (4eae1a978, item 6): result-freshness slack 2 ms -> 1 s. Linux stamps files up to 6.66 ms
  before `Date.now()`; a selftest tool test failed 3/3 on WSL, 0 after.
- `tools/lib/godot_stop.break.test.mjs` (7f10f84b2, item 6): on Linux a zombie grandchild counts as dead (was a 1-in-4
  Linux flake). Item 6 found three timing-shaped causes in all: cold node starts, the Linux mtime tick, the zombie.
- `tests/parity/city_parity.gd`: `final_sha_a/b` in the parity result.

Gates on eb65c8b05 (`node tools/gate/run.mjs`): PASS - lint 16/16, unit 2507/0, scenarios 55, parity exact,
selftest 11/11 + 5/5, release-compile 667/0. Reel gate on ad2f0a5c1: top, tilt70, combo OK (280-286 s each).

## Codex (n15)

- Testers for t-1/t-4/t-5 (n15t-break-spawn-plan, -car-route, -hash-window): 23 tests, 0 defects found, all
  landed (4576f2b08); with the old rules planted by hand 5 fail (t-4/t-5) and 4 fail (t-1). Review split two
  files under the size cap. Codex caught a wording error in my brief (TURN_LEAD is before the lane).
- Item 7, sim_hash control (fourth paired module): Opus alone 46819 tokens, 14 tests, mutate 14/15 on the same
  15-of-91 sample; Codex 162 s + Claude review 64833 tokens -> `claude_tokens_saved: -18014` on this module.
  The control's 730 s are inflated by my wait bug (stated in the ledger row).

## Morning merge, run for real (item 4)

`morning.mjs` merge, debt, native (23:08-23:12) and gates, reels (23:48-00:10) on a scratch integration worktree of
all three lanes' 23:08 tips: every step green, `DONE ... Nothing was pushed`. Integrated: unit 2529/0, scenarios 55,
parity exact, look 11/11 + block 5/5 worst 0.00, reels 3/3. Worktree and branch removed. The baseline auto-resolve
did not fire (no baseline conflict tonight): proven on its throwaway-repo test only.

## Served for the builders

combat: `--victim` through compare (b8fccb958), extras as chapters + `--feel` (ba6f38838, d60ff5894), lint function
size stops at the body (26f18e5ef), `test_quest_blade` no longer depends on test order (5e41c66bc). A real victim
film: `film-victim-head-swat-64ppm-t337-367.png`. hero: no REQUEST.

## Calls for the owner

- **c-1 Codex as a first-author test writer.** The fourth paired module, sim_hash: Claude's review of Codex's tests cost
  64833 tokens, an Opus control writing them alone 46819, both at 14/15 on the same mutants (`claude_tokens_saved: -18014`).
  As adversarial TESTERS tonight Codex cost little review (23 tests, none rewritten, two files split for size) and
  caught a wording error in my brief. Recommend: Codex for testers of finished fixes, Claude for first-author unit tests.
  Alternative: keep both (one data value: the factory's `pick`). Evidence: gtai-masters/n15/tools/codex-ledger.jsonl.
- **c-2 t-4 is invisible in the shipped city** (0 of 1024000 pixels differ; `t4-city-street-32ppm-before-after-*`): the
  generated grid never puts a kerb or plaza ahead of a lane. Kept as built (owner's Call); it matters for any hand-made map.

## Not done yet

- t-5 cost under the bench lock (CONTENDED only). The `bake` and `export` morning steps were not run for real.

## Merge notes (draft)

- Merge n15-tools FIRST. It changes the sim (t-1 spawn order, t-4, t-5 HW) and both DLLs (rebuild them: `just native`).
- Hero and combat need NO replay re-bless: no replay golden is committed (`git ls-files` holds only the 17 look
  goldens; the replay scenario records and replays inside one run). Look goldens: the integrated tree of all three
  lanes at 23:08 (morning.mjs on a scratch worktree) passed look 11/11 and block 5/5 at worst 0.00 on this lane's
  re-blessed goldens. If hero or combat re-bless a look golden after 23:08 on main's spawn order, re-bless that one
  once on the integrated tree (`look_golden.tscn --bless`) with one decisions line.
- Order: n15-tools first (sim + DLLs), then hero and combat in either order (no code conflict among the three at 23:08).
