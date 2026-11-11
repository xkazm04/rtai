# REPORT n15-tools (session 7, 05:30; later sessions extend it)

Branch `n15-tools` from main `5c5c03611`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n15\tools\` (`frames.json`),
`evidence/` in this tree, JOURNAL.md for every command and its output.

## The owner's Calls

| Call | Built | Test (fails before, passes after) | Numbers / frames |
|---|---|---|---|
| t-1 CitySpawnPlan turns | `_turn += q + 1` (d720e22da) | `test_city_spawn_plan_turns.gd` (`[2,2,3,2] != [2,3,2,3]`, 8 of 30 turns for 10); Codex's n11 test landed unchanged | moves the city sim (parity final digest 9cd5579a -> 94b2865f) and the 16 look/block goldens: re-blessed eb65c8b05, before/after stills in masters |
| t-2 overrule with a reason | `factory.mjs review --overrule=` / `overrule <id> --reason=` (7ef39b42e) | 3 factory tests | city_spawn_plan: 25/39 killed, all 14 survivors equivalent (named in decisions.md), 25/25 killable; recorded in the n15 ledger |
| t-4 car routing | U-turn only on T_VOID, exits honour orientation, 18/2.5/13/16 m in `sim_constants.json` group `car_route`, GDScript + C++ (fe5dccda0); the dead-end tiles are one data value `CAR_DEAD_END_TILES` (41505c09f, shipped 1 = t-4) | `test_sim_car_route_t4.gd` 3 of 5 fail on the old rules; `test_city_lane_grid.gd` audits 256 chunks; the route tests pass 21/0 at mask 1, 241 and 65 | parity exact; final digest unchanged: the old rules never fire in the generated city. Film (city street, 32 px/m, t300-900): 0 of 1024000 pixels differ. **On a hand-made map** (`res://dev/sim/car_route_trails.gd`, real reference-sim car code): before 3 U-turns at a plaza and 1 at a kerb, after all 7 at void; a car drives across the plaza into the building behind it (`t4-hand-map-trails-before-after-4ppm.png`): Call c-2 |
| t-5 hash window | HW 80 -> 132 cells (528 m), both sims (0ba5b1e91) | `test_sim_hash_window.gd` (empty query at 256 m on HW 80) | CONTENDED (8-15 other Godot processes), bench lock held, with an A/A twin: native +9.0 us/step median on 52 us (+17 %), GDScript ref +0.63 ms on 4.43 ms (+14 %), B slower in 6/6 rounds, A/A median -1.8 us / -0.14 ms (`evidence/t5_aab.tsv`). Cause: `CitySimHash.build` walked all HW*HW cells each step (6400 -> 17424); **made O(actors) in both sims (session 4, parity exact, digest unchanged): now B is faster than the old HW 80 build in 6/6 rounds, native -4.0 us/step, ref -0.27 ms (`evidence/t5_aab_build.tsv`)**; session 5: the dead total sentinel and the unobservable cell sort removed (DECISION sim/hash-build-order; the Codex tester's plant showed the sort never shows), a 4th Codex tester file pair (9 tests, the touched-cell clear planted out fails 7), mutate on 4af7cf1fa **15/15** (`evidence/mutate_sim_hash_build_4af7cf1fa.log`; 13/15 and 14/15 before, survivors equivalent) |

Native rebuilt by this lane at 22:09 (t-4), 22:30 (t-5), 02:05 (c-2 mask; comment-only regen after), 02:55 (hash build), 03:10 (the hash's dead
total sentinel deleted) and 03:51 (the hash's cell sort removed; again after a comment edit), debug + release,
`sim_core tests: 0 failed`; parity bit for bit after each, final digest 94b2865f7f17d778.

## Parity and replay

No replay or parity golden is committed: both gates compare two runs of one build, so nothing needed a
re-bless. Parity stays bit-exact. What moved: t-1 changes the city sim's spawn order (and so the selftest
crowd: look goldens re-blessed with a decisions line). t-4 and t-5 move nothing measurable (same final digest).

## Tools changed

- `tools/style/launch_flags.mjs`, lint check `launch-flags` (88b42ec2d; lint is now 18 checks; combat's FRICTION): every
  `LaunchArgs.value/has("--x")` (or a same-file `const NAME = "--x"`) outside tests names a flag in `KNOWN_FLAGS`; a
  missing one is "" on every run and `has()` false, which gave combat a byte-identical before/after. Example, planted in
  `boot/arena_args.gd`: `project/boot/arena_args.gd:30: LaunchArgs.value("--impact-follow") reads a flag not in
  KNOWN_FLAGS`; the repo, hero and combat tips are clean.
- `tools/film/film.mjs --rev=<commit> [--native=donor]` (3f5f17ccc): films a commit in compare's snapshot, so a queue
  of films runs one commit while the tree is edited. A live-tree film prints its uncommitted `project/` paths. The side
  resolver moved to `tools/film/side.mjs`, because a dynamic import of compare from film deadlocked. Example: `film.mjs
  arena --rev=HEAD --stills=300` -> `film: --rev=HEAD films snapshot 0e67967e ...`, `film: PASS`.
- `node tools/reel/run_reels.mjs` with no args (2f051cd65): the reel gate into `build/reels` (it was exit 2).
- `tools/merge/preview.mjs --lanes=<a,b,c> [--base=main]` (7bda4d18c): what the morning merge will meet, with no
  worktree (merge-tree in lane order; it writes git objects only). Each conflict is sorted into what morning resolves
  (JOURNAL, REPORT, baseline) and the code it stops on, and lane pairs with code clashes are listed. Example:
  `--lanes=20c1dafb1,n15-combat` -> `STOP on project/dev/frames/quest1_clip.gd` (my own clash, fixed in decdd8331).
- `tools/merge/clash.mjs`, run by the pre-commit hook on every commit (392d0ec85, 6a36a3f74; session 7): it warns, and
  never blocks, when the staged commit makes a NEW code conflict with a sibling lane (worktree branches with the same
  `n15-` prefix; `GTAI_MERGE_LANES=<a,b>|off`). It runs merge-tree twice per lane, about 0.4 s, and writes objects only.
  Example (a temp index staging an edit of combat's `--rivet-windup=off` line): `merge-clash: WARNING this commit makes
  project/features/characters/cast_flags.gd conflict with n15-combat ...`. A lane without it runs
  `node <n15-tools>/tools/merge/clash.mjs --repo=.` on a temp copy of its own index.
- `tools/dev/flag_index.mjs` (ea02a8898, 89925653b; session 7, hero FRICTION: `--ohm-hand=sim` launched unchecked,
  giving a 0.0 % before/after): `dev/run.mjs` checks an entry with no declared KNOWN_FLAGS against every flag literal
  in our GDScript (name read; for exact reads such as `arg == "--x=sim"`, the value too). `film.mjs` uses the same
  index after its `--`. Example: `node tools/dev/run.mjs cursor_sweep --dry-run -- --rigs --rivet-windup=of` -> `run:
  unknown flag --rivet-windup=of ... (did you mean --rivet-windup=off?)`, exit 2, nothing spawned. `--any-flag`
  skips the check. The lanes' recorded runs give 0 false refusals. Linux (WSL Ubuntu, Node 24, clone of ddbf98840):
  dev + film + merge + gate tests 556, pass 554, fail 0, skipped 2.
- `dev/frames/quest1_clip.gd --still-lead=<ticks>` (cab8a0d4a; default 120, 0 = the old jump): see Served.
- `res://dev/sim/car_route_trails.gd --tier=a` (6254f741e): the hand-made car map in tier A (cells filled from each tile's
  kind, hash built each tick, `dead_at_tick` per car). Example: `bash evidence/c2_tier_a/run.sh` -> 4 runs exit 0, tier B
  default == `evidence/t4_trails/after.json` exactly, mask 1 tier A car 0 `dead_at_tick 3022`.
- `evidence/merge/resolve_hero_x_combat.py <conflicted> <out>` (f2c75f9a4): writes the union for the two hero x combat
  conflicts, refuses if a side changed shape. Example on the 03:17 tips: both files pass gdformat, gdlint, the function cap.
- `tools/style/uid_files.mjs`, lint check `uid-files` (eacf0de3f; lint is now 17 checks): every own `.gd` in the index has
  its `.uid` there. My own 6b9d2a900 shipped a dev script without its `.uid`; Godot wrote it inside the gate's snapshot
  and every kind failed INVALID. Example: over `git ls-tree 6b9d2a900` -> `FAIL project/dev/sim/car_route_trails.gd:
  its .uid is not in the index`.
- `tools/film/blob.mjs` (f059cfc44, hero's FRICTION): `node tools/film/blob.mjs <rev>:<path> --out=<file>` writes the
  real bytes of an LFS asset at a commit (`122 bytes, LFS object, smudged`), where `git show` writes the pointer.

- `project/dev/sim/car_route_trails.gd` (6b9d2a900, AGENTS.md line): the reference sim's real car code on a hand-made map
  (roads ending at a plaza, a kerb, void), trails at 4 px/m, each U-turn boxed, `.png` + `.json`. Run it in two worktrees
  for a routing before/after. Example: `--out=.../before` on d720e22da -> U-turns `tile_ahead` 7, 0, 7 / 7, 4, 0 / 0, 0, 0.

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
- `project/core/render/texture_threads.gd` (c3f80513d, item 6): **the scenario_rig_stress flake's cause, fixed**. Godot's
  headless (dummy) renderer keeps textures in a RID owner that is not thread-safe; StreetStrips' prefetch and
  CityTextures decoded textures on loader threads. Repro (`evidence/dummy_texture_race/`): 4 worker threads, headless:
  `Initializing already initialized RID`, `Parameter "t" is null`, segfault, 2 of 2 runs; d3d12 or main thread only:
  0. Headless now loads in place; real renderers keep the worker decode, so no frame moves. Six sightings since 11-03.
- `tools/debt/merge_baseline.mjs` CLI (e33dcf6a4): the looser-of-both baseline, staged, inside a conflicted merge.
- `tools/lib/godot_stop.break.test.mjs` (7f10f84b2, item 6): on Linux a zombie grandchild counts as dead (was a 1-in-4
  Linux flake). Item 6 found three timing-shaped causes in all: cold node starts, the Linux mtime tick, the zombie.
- `tools/dev/run.mjs` + `entries.mjs` (5cda754c0): `const NEEDS_WINDOW: bool = true` in an entry or its parent -> refused
  headless (`run: res://dev/selftest/look_golden.tscn renders frames ... add --windowed`), exit 2, nothing launched.
- `tests/parity/city_parity.gd`: `final_sha_a/b` in the parity result.
- `tools/gate/precommit.mjs` + `tools/lint/scope.mjs` (c5ac2442a, 112b0a12e; hero's FRICTION "each commit took ~1.5
  min"): the hook hands lint the staged list; a commit wholly under `project/` runs gdformat + gdlint over its staged
  `.gd` and the tool tests only when it stages a file they read (`join(ROOT, ...)` literals, plus `project/dev/`,
  `project/data/`, `project.godot`, found by an fs trace: `tools/lint/fs_trace.mjs`). Example (real commit, scratch
  worktree): `lint: all 15 checks pass over 1 staged of 1428 GDScript files` in 4.6 s, against 88 s for the full lint.
  An empty commit skips lint when `git write-tree` = `HEAD^{tree}` (1.9 s). Gates always lint everything.
- `tools/evidence/run.mjs` (3fc7109a9; hero's FRICTION, a mid-run edit poisoned the selftest): each kind that finishes
  after a code path changed (new porcelain line, or size/mtime of a path dirty at the start) is failed with
  `INVALID: the tree changed while <kind> ran (<n> code path(s): ...)` and a pointer to `tools/gate/run.mjs`.

Gates on 27756d838 (`node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`, session 5, after native rebuild #7: the
hash build without its sentinel and sort, the Codex hash-build tests, `--tier=a`): PASS - lint 17/17 over 1433 files, unit
2542/0, scenarios 55, parity bit for bit (planted caught at 629), look 11/11 + block 5/5 worst 0.00, release-compile 668/0,
reels top/tilt70/combo OK (`build/gate/27756d838873/gate.json`, git-ignored; JOURNAL 04:22).

Gates on 6f7422812 (`node tools/gate/run.mjs --rev=HEAD`, session 4, after the c-2 mask and native rebuild #4): PASS -
lint 17/17, unit 2532/0, scenarios 55, parity bit for bit (planted caught at 629), selftest look 11/11 + block 5/5
worst 0.00, release-compile 668/0. Reel gate on d2226608d (same code and frames; only the dev script's `.uid`, a Node
tool and docs came after): top, tilt70, combo OK (combo 328 s). Commits after 6f7422812 are docs only.

Gates on c3f80513d (`node tools/gate/run.mjs --rev=HEAD`, after the flake fix): PASS - lint 16/16, unit 2531/0,
scenarios 55 (rig_stress clean; its p50 budget CONTENDED, not judged), parity exact, selftest look 11/11 + block 5/5
worst 0.00, release-compile 668/0. Commits after it are docs/JOURNAL/REPORT only. The reel gate has not run since
ad2f0a5c1 at that time (since run on d2226608d, above).

Gates on 52dc72d4 (`node tools/gate/run.mjs`): PASS - lint 16/16, unit 2530/0, scenarios 55, parity exact,
selftest look 11/11 worst 0.00, release-compile 667/0. Reel gate on ad2f0a5c1: top, tilt70, combo OK (280-286 s each).
Commits after 52dc72d4 are Node tools, their tests and docs (linted by the hook); the final commit gets a full gate + reels.

## Codex (n15)

Totals: 4 tasks dispatched (all testers, `n15t-break-spawn-plan`, `-car-route`, `-hash-window`, `-hash-build`; meter 36 % at
the first dispatch), 0 executor tasks, 32 tests landed, 0 defects found, all four discarded; ledger rows this night: 1 overrule with its
written reason (t-2, city_spawn_plan) and 1 control (sim_hash, the fourth paired module). No Codex run for the c-2 mask
(02:21 JOURNAL: one-line predicate, the break tests now follow it, no slot to run a round before the stop).

- Testers for t-1/t-4/t-5 (n15t-break-spawn-plan, -car-route, -hash-window): 23 tests, 0 defects found, all
  landed (4576f2b08); with the old rules planted by hand 5 fail (t-4/t-5) and 4 fail (t-1). Review split two
  files under the size cap. Codex caught a wording error in my brief (TURN_LEAD is before the lane).
- Item 7, sim_hash control (fourth paired module): Opus alone 46819 tokens, 14 tests, mutate 14/15 on the same
  15-of-91 sample; Codex 162 s + Claude review 64833 tokens -> `claude_tokens_saved: -18014` on this module.
  The control's 730 s are inflated by my wait bug (stated in the ledger row).
- Tester for the O(actors) hash build (n15t-break-hash-build, session 5, 144 s, 5593 tokens out): 9 tests with a naive
  oracle and a fresh-hash comparison on every query, 9/0; planted: no touched-cell clear -> 7 fail; no cell sort -> 0
  fail, which showed the sort is unobservable, so it went (both sims, parity exact). Review split the 240-line file in two
  plus `tests/support/sim_hash_oracle.gd` (test bodies unchanged). accepted-after-revision (d195c73df).

## Morning merge, run for real (item 4)

**Every step has now run for real.** Third run, 01:50-01:59, on the scratch integration (n15-tools with the flake fix +
hero + combat + the hero x combat resolution): `morning: gates: scenario-tests pass: scenario-tests: 55 passed`, unit
2582/0, lint 16/16, parity exact, selftest look 11/11, release-compile 674/0, `morning: gates: green`, then
`morning: export: green` (RTAI.exe 650 MB + the release DLL; boots headless and quits at tick 300 with exit 0, two engine
ERROR lines not compared against main), `morning: DONE at 71f0d5b1 ... Nothing was pushed` (`evidence/morning_s4_gates_export.log`).
Scratch worktree and branch removed.

Second real run, 01:03-01:22 (fresh scratch integration of the three tips, `--steps=merge,debt,bake,gates,export`):
the baseline auto-resolve **fired for real** (`tools/debt/baseline.json conflicted merging n15-hero: took the looser
of both sides ...`), then the merge **stopped on a real hero x combat code conflict** (see Merge notes). Its baseline
advice failed the merge commit's ratchet, so `node tools/debt/merge_baseline.mjs` now does the looser-of-both merge by
hand (e33dcf6a4, real run: `debt-ratchet: ok`). Resumed: merge, debt and **bake green (first real bake step)**; the
gates step printed its per-kind lines for real (`morning: gates: unit-tests pass: unit-tests: 2581 passed, 0 failed,
2 skipped`, lint, parity, selftest, export-audit pass) and stopped on `scenario-tests fail: ... scenario_rig_stress`,
the flake fixed below. (The export step first ran for real in the third run, above.)

`morning.mjs` merge, debt, native (23:08-23:12) and gates, reels (23:48-00:10) on a scratch integration worktree of
all three lanes' 23:08 tips: every step green, `DONE ... Nothing was pushed`. Integrated: unit 2529/0, scenarios 55,
parity exact, look 11/11 + block 5/5 worst 0.00, reels 3/3. Worktree and branch removed. The baseline auto-resolve
did not fire (no baseline conflict tonight): proven on its throwaway-repo test only.

## Served for the builders

combat: `--victim` through compare (b8fccb958), extras as chapters + `--feel` (ba6f38838, d60ff5894), lint function
size stops at the body (26f18e5ef), `test_quest_blade` no longer depends on test order (5e41c66bc), `tools/dev/run.mjs`
refuses a rendering entry headless (`const NEEDS_WINDOW`, 5cda754c0). A real victim
film: `film-victim-head-swat-64ppm-t337-367.png`. hero (FRICTION lines, no REQUEST): the slow pre-commit hook and lint
on empty commits (c5ac2442a, 112b0a12e), the evidence run reading a mid-edit tree (3fc7109a9), `git show` writing
the LFS pointer for a PNG (`tools/film/blob.mjs <rev>:<path>`, f059cfc44: real run `122 bytes, LFS object, smudged`). Builders can take them
before the merge: `git cherry-pick 39431687d c5ac2442a 3fc7109a9 112b0a12e` (Node only; clean on both tips at 00:59).
Not served: hero's `stride_film --film-fire` on one-row strips (hero's own dev scene; its cursor_sweep workaround is
the right film).

Session 6 (from FRICTION lines, no REQUEST open):
- combat "a dev flag read through `LaunchArgs.value()` that is not in KNOWN_FLAGS is always empty": lint `launch-flags`
  (88b42ec2d), above.
- combat "I edited a .gd while a film queue ran; 4 queued films died with SCRIPT ERROR": `film.mjs --rev=<commit>`
  (3f5f17ccc) films that commit in compare's snapshot. Proven with a parse error planted in the live tree:
  `--rev=HEAD` PASS (t300 checked by eye), the live-tree run FAIL, naming the uncommitted path first.
- combat "two quest1 films of one build differ by ~250k px at t13708 when `--stills` starts elsewhere": reproduced
  (64306 of 1024000 px at 1280x800, 32 px/m). The camera lines up in both frames. What differs is view state that
  moves only on drawn frames (Rivet's rig pose, the portrait fade, blood, ped poses), and the recorder drew nothing
  between stills. Now the 120 ticks before each still are drawn (cab8a0d4a, 20c1dafb1; dev recorder only;
  `--still-lead=0` = the old way): 10947 px (1.1 %). A 600-tick lead gives 10357, no better: what remains (the soul
  companion, some blood) is created only when a drawn frame sees the event. **Reduced, not removed:** an A/B pair still
  uses one `--stills` list, which compare.mjs does. `gtai-masters/n15/tools/quest1-still-lead-t13708-jump-vs-lead-32ppm.png`.
- hero "`node tools/reel/run_reels.mjs` with no args exits 2": the bare command is now the reel gate (`build/reels`,
  2f051cd65), as the night brief names it.

Session 7:
- hero 05:06 "`--ohm-hand=sim`, which CastFlags never reads ... `flags unchecked: no declared spec` let it through":
  `tools/dev/flag_index.mjs` (above). On hero's tree, `--ohm-hand=sim` gets `did you mean --ghost-ohm-hand?`.
- the n15 merge-clash lesson, my own (quest1_clip.gd at 04:48): `tools/merge/clash.mjs` in the hook (above).
- found while building the index: **`--rivet-walk-armed=off` and `--rivet-stride=off` had done nothing since
  c8d71e34a** (2026-11-09, n11 hero's function-size split routed only `--rivet-walk=`, `--rivet-swipe` and `--rivet-bob`
  into `CastFlags._walk`). The 2026-11-08 rivet REPORT lists `--rivet-walk-armed=off` as one of the owner's befores in
  the exe. Fixed in 05e519be8, test first (`test_cast_flags` failed on 2 of 7 walk befores, now 42/0 over the walk
  suites). The defaults are unchanged, so no golden moved. Film, with the same flag on both sides and only the routing
  changed: `gtai-masters/n15/tools/rivet-stride-off-flag-dead-vs-fixed-arena-t1200-{32,64}ppm.png` (A: his legs
  step toward the walk; B: along the aim). Any n11-n15 before/after that used these two flags compared identical
  frames.

## Calls for the owner

- **c-1 Codex as a first-author test writer.** The fourth paired module, sim_hash: Claude's review of Codex's tests cost
  64833 tokens, an Opus control writing them alone 46819, both at 14/15 on the same mutants (`claude_tokens_saved: -18014`).
  As adversarial TESTERS tonight Codex cost little review (23 tests, none rewritten, two files split for size) and
  caught a wording error in my brief. Recommend: Codex for testers of finished fixes, Claude for first-author unit tests.
  Alternative: keep both (one data value: the factory's `pick`). Evidence: gtai-masters/n15/tools/codex-ledger.jsonl.
- **c-2 what a car does where a road ends at a plaza, a kerb or a building.** t-4 as you chose it (U-turn only at the
  city edge or an unloaded tile) drives the car across the plaza and into the building behind it, turning 18 m before the
  void; the old rule turned 18 m short of the plaza. Invisible in the shipped city (0 of 1024000 pixels differ: the
  generated grid never ends a road there), so it matters for a hand-made map only. Now one data value,
  `CAR_DEAD_END_TILES` in `tools/gen_constants/sim_constants.json` (then `node tools/gen_constants/gen.mjs` + `just
  native`): **1** shipped (t-4), **241** the pre-t-4 rule (reproduced tick for tick), **65** void or a building (drive
  over a kerb or plaza, turn before a building). Recommend **65**: a car may cross a plaza but never a building. Kept at
  1 tonight because 1 is your Call. Side by side: `gtai-masters/n15/tools/c2-dead-end-mask-241-1-65-4ppm.png`.
  **In tier A it is worse** (`car_route_trails.gd --tier=a`: the hull meets solid 1 m cells, 6254f741e): at 1 the two
  eastbound cars cross the plaza and end pinned on the building, one is killed after 20 s stuck; at 65 they U-turn
  inside the plaza and nobody dies (`gtai-masters/n15/tools/c2-tier-a-mask-241-1-65-4ppm.png`, `evidence/c2_tier_a/`).

## Gates on this branch

Final gate on decdd8331 (all of session 6's code; `node tools/gate/run.mjs --rev=HEAD --reels --timeout=40`):
lint 18/18, unit 2542/0 (2 skipped), scenarios 55, parity exact (planted fault caught at step 629), selftest look 11/11, release-compile
668/0, reels top/tilt70/combo OK: `gate: PASS`. After it come only Node tools (merge preview, which passes the full
pre-commit lint, tool tests included; Linux 896/0 on c1e7fb183) and docs.

## Not done yet

- The exported exe's two boot ERROR lines (a headless shader `custom_samplers` condition, `N resources still in use at
  exit`) are OLD: a release export of main 5c5c03611 and one of n15-tools 88b42ec2d, same boot smoke (`RTAI.exe
  --headless --fixed-fps 60 --quit-after 300`, exit 0 both), give the same 20 log lines apart from one timing and the
  leak counts (main 100 resources / 662 ObjectDB, this branch 102 / 630): `evidence/exe_boot/`. Not fixed (engine-side
  headless shader path; out of this lane's list).

- t-5 cost on a quiet machine (every number tonight is CONTENDED; the sign is 6/6, the size soft).
- quest1 stills still depend on the `--stills` list for about 1.1 % of a frame (the soul companion, some blood): view
  state that a drawn frame creates when it sees an event. Removing that means the view being a pure function of the
  sim at a tick, which is game-side work. Until then, an A/B pair uses one stills list. The companion part is
  `GhostFormView._process` (`project/features/souls/ghost_form_view.gd:137`): it ages the apparition by at most 4 ticks
  per drawn frame, so its 204-tick life counts frames, not ticks. That is the view lanes' code, and in play it only
  matters during a hitch, so it was left unchanged.

## Next steps

- c-2: if the owner picks 65 (or 241), change the one value, regenerate (`node tools/gen_constants/gen.mjs`), `just
  native`; the route tests follow the value (21/0 at 1, 241 and 65); parity's final digest does not move.
- Drop `test_noir_shadows` from `morning.mjs`'s known-flake advice after a few clean nights (same race as rig_stress).
- Done in session 7: the merge check is in the hook (`tools/merge/clash.mjs`). Next, show its warning in `tools/gate/quick.mjs` too.
- End of night: remove this lane's leftovers: `gtai-n15/scratch-tools-before` (worktree), branch
  `n15t-control-sim-hash`, and the mutate worktree `%TEMP%/gtai-mutate-6bd4df1a` (`git worktree remove --force`).

## Merge notes (draft)

- First run `node tools/merge/preview.mjs --lanes=n15-tools,n15-hero,n15-combat`. At 04:50 it said: tools clean;
  hero only JOURNAL, REPORT and baseline (morning resolves them); combat STOP on `cast_flags.gd` and `rivet_res.gd`
  (the hero x combat pair below).
- quest1 stills: after this merges, `dev/frames/quest1_clip_rec.gd` draws 120 ticks before each still. A compare
  of a commit from before the merge against one after it runs each side's own recorder, which mixes the old jump with
  the lead. Film both sides with `-- --still-lead=0`, or compare two post-merge commits. Arena, city and weapon
  films are untouched.
- Merge n15-tools FIRST. It changes the sim (t-1 spawn order, t-4, t-5 HW, the c-2 mask at its t-4 value) and the
  native sources (`car_route.cpp`, `sim_constants.h`): the DLLs are git-ignored, so rebuild both after the merge
  (`just native` debug + release, then `--import`). Hero and combat keep working on their own DLLs until then: their
  view does not read the routing.
- Hero and combat need NO replay re-bless: no replay golden is committed (`git ls-files` holds only the 17 look
  goldens; the replay scenario records and replays inside one run). Look goldens: the integrated tree of all three
  lanes at 23:08 (morning.mjs on a scratch worktree) passed look 11/11 and block 5/5 at worst 0.00 on this lane's
  re-blessed goldens. If hero or combat re-bless a look golden after 23:08 on main's spawn order, re-bless that one
  once on the integrated tree (`look_golden.tscn --bless`) with one decisions line.
- Order: n15-tools first (sim + DLLs), then n15-hero, then n15-combat. At 23:08 the three merged clean; at 01:03 (a
  real `morning.mjs` run on a scratch integration) **hero and combat conflict** on two files, both plain unions:
  `project/features/characters/cast_flags.gd` (hero routes `--ghost-*` to `_ghost()` with `--ghost-soul-line=off`;
  combat routes `WINDUP_FLAGS` to `_windup()` with `--rivet-left-strike=off`/`--rivet-blade-left=off`: keep both
  `elif` branches and both helper functions) and `rivet_res.gd` `X15` (hero's 37 p70/p55 strips + combat's 6 blade
  left sets: keep both lists). The resolution that passed gdformat, gdlint, a Godot parse check and lint 16/16:
  `evidence/merge_hero_x_combat_686fcb828.diff`. Re-checked at 03:17 on the then tips (hero 88077fb80, combat 7778d347a,
  `git merge-tree` in order): the same two conflicts, nothing new. `python evidence/merge/resolve_hero_x_combat.py
  <conflicted file> <out>` writes the union (it refuses if a side changed shape); its output on those tips passed
  gdformat, gdlint and the 40-line function check (`evidence/merge/hero_x_combat_resolution.diff`). The baseline conflict beside them: `node tools/debt/merge_baseline.mjs`
  (then commit), not "take either side", which fails the merge commit's ratchet.
