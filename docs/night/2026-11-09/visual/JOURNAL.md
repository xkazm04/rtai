# JOURNAL: lane n12-visual, night 2026-11-09/10

Branch `n12-visual` in `C:\Users\kazda\kiro\gtai-wt\n12-visual`, cut from main `812a0b061`. Brief:
`BRIEF.md` beside this file. Scratch logs: `build/n12/` (git-ignored). Godot: the launcher resolves
`gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe` ("known path"; no `tools/local.json`).

## Setup (21:00-)

- 21:03 brief committed alone: `8006ad33e` (the pre-commit hook ran lint: 15/15).
- 21:04-21:08 first `--import`: exit 0, 0 ERROR (`build/n12/import.log`).
- 21:08 `dev/bake_city.gd`: 256 chunks, exit 0, 0 SCRIPT ERROR (`build/n12/bake.log`).
- 21:09 machine: two other lanes' `run_scenarios.gd` were up (pids 31204, 11156). No bench.lock.

## Gates on arrival (head 8006ad33e = main 812a0b061 + the brief)

- lint: 15/15 (the hook, 21:03).
- unit `--fast`: 2175 pass, **1 fail**, 5 skipped: `test_blood_flight.gd:50
  test_the_native_flight_matches_the_script` ("this DLL has the entry"). Cause: NOT the code. The DLLs
  copied into `project/native/bin/` were main checkout's of 2026-11-05 (release md5 b42eac98), built
  before n10's C++ ports: no `step_blood_drops`, `fill_feed_rows` or `scan_crowd_in_rect` in them.
  `native/` has not changed since ab23feaf (03:20); int-day sits at exactly 812a0b061 and its DLLs
  (09:36, release md5 7995c493, the same in n11-hero and n11-tools) carry all three. Copied those in
  (stale pair kept in `build/n12/stale-dll/`); `--select=test_blood_flight` 3/3. Every perf figure
  this lane takes is on the 7995c493 DLL. (Had I not, the riot/city fight would have run the
  GDScript fallbacks of n10's C++ ports, which n10 measured at 0.06-0.24 ms of riot frame p50 each.)
- parity (21:11, after the DLL swap): bit-exact over 1200 steps, planted mutation caught at 629.
- scenarios (21:11-21:20, `node tools/tests/run_scenarios.mjs`): **55/55 pass**, no budget miss
  waved through as CONTENDED (two other lanes' scenario suites were up at the start).
- So on arrival: lint 15/15, unit fast 2176/2176 once the DLL is current (1 red that was the
  environment, not inherited code), scenarios 55/55, parity bit-exact.

## Group A

### What exists (audit, 21:12)
- The 11-04 perf-city lane already took reel chapter 18 apart (`docs/day/2026-11-04/perf-city/REPORT.md`,
  merged 107e84b2d): the "lag" was mostly 3.5 s of dead time between pit waves (Rivet's speed-up took it
  to 0.8 s), plus present-phase stalls that tracked machine load; it landed five pixel-identical fixes
  (floor props printed once and culled, retained ground marks, held-gun art warmed, corpse soaks as one
  CircleFan draw). Owed since then: an uncontended re-check. The brief's "8.79 ms p99 / 424 ms" are the
  r19 **city_bench** aggregate (riot + drives), not the fight's own log.
- Plumbing that exists: `dev/bench/fight_frames.gd` (`--frames`), `node_spans.gd` (`--spans`),
  `evidence/perf/fight.sh` (perf-city's runner, hard-wired to its worktree), `tools/perf/ab.mjs`
  (interleaved A/B, wall clock, city_bench-only for exports), n10's CPU-seconds A/A
  (`evidence/perf/n10-cputime/cpu_ab.ps1` + `analyse.py`, riot only, hard-wired to n10's paths).
  Nothing runs the fight at combo in release with an A/A in one command: that is A2.

### A2 built first (the instrument A1 needs), 21:14-21:22
- `tools/perf/fight_gate.mjs` + `cpu_run.ps1` + `paired.mjs` (+ tests, 20/20 with stats.test).
  Exports windows-showcase as `build/export/fight-gate/RTAI-bench.exe` (the name the ledger's process
  scan counts), runs `city` (fight.sh's chapter-18 args + `--view=combo`, 2100 ticks) and `horde`
  (`--bot=gunplay --weapon=gatling --horde --cam=fight`, 1800 ticks), 1920x1080, d3d12, vsync off,
  `--fixed-fps 60`; arms by flags, first arm + its A/A twin, n10's rotate-and-reverse order; per run
  frame p50/p99/worst/>25 ms (first 1 s dropped) and process CPU s; paired deltas, bootstrap CI95,
  sign test. Waits for the bench slot (acquireBench).
- Smoke (1 round, 21:15-21:18, `build/n12/gate-smoke/`): city p50 10.25 / 9.95 ms, p99 16.1 / 14.6,
  CPU 23.4 / 22.5 s; horde p50 9.96 / 9.94. Both city runs CONTENDED(1).
- Load the ledger cannot see: at 21:20 the machine read LoadPercentage 100; a 3 s sample put rustc
  at 2.5 cores and seven node processes (another project's tsc and vitest workers) at about 0.85
  cores each. None are Godot, so CONTENDED counted 0-1. So cpu_run.ps1 now also reads GetSystemTimes
  over the run and the gate prints "others' cores" per run and per arm.
- A span run of the same export (`--spans`, 21:19) read p50 5.66 ms, CPU 16.4 s: the 10 ms smoke
  figures are inflated by load. No absolute figure tonight is a quiet one unless its load column says so.

### A1 first reading (smoke + spans, contended)
- Settled frame (smoke medians): `_process` 5.2-5.5 ms (sim loop 1.1-1.2 of it), flush 1.9-2.0,
  draw 1.6-1.7, render GPU 0.7-1.1: CPU script work, not the GPU.
- Span means (ms/frame): world 0.80, character_rigs 0.56, prop_occlusion 0.53, view_pitch_ease 0.29,
  draw rig_cast_shadows 0.28, draw fx_view 0.24, draw ghost_form_hud 0.21, rig_depth_sort 0.21,
  arena_rigs 0.19, vehicle_stage_cards 0.19, city_occlusion 0.19, draw fx_ground_mark 0.18.
- Frames over 25 ms: (a) a kill spike at city tick 1512-1513 (`death_bullet on 3, frame 1512`),
  `_process` 22.6 and 26.3 ms in BOTH runs: deterministic; (b) one 285 ms `_process` frame (tick 258)
  and 20-43 ms flush frames in one run only; (c) a 510-640 ms OS-pump stall at tick 26, about 4 s
  after launch, in every run (perf-city's "process-age frame", then 25-95 ms; inside the dropped
  first second, so outside the settled stats); (d) ticks 6-7 `_process` 22-24 ms, in the first second.
- `node_spans.gd` gains `worst_frames` (the 12 frames with the most span time, top 6 labels each) to
  name (a).
- Steady candidates seen on the way (not worst frames): GhostFormHud.sync queues a redraw every frame
  (0.21 ms draw); ViewPitchEase re-dresses every card every frame at a constant mix (0.29 ms).

### A2 baseline (21:21-21:35, `build/n12/gate-baseline/`, export of 8006ad33e + the gate, 6 rounds)
`node tools/perf/fight_gate.mjs --no-export --rounds=6 --out=build/n12/gate-baseline` (A/A only):

| scene | arm | p50 ms | p99 ms | worst ms | >25 ms | CPU s | others' cores |
|---|---|---|---|---|---|---|---|
| city | base | 5.36 | 11.40 | 20.5 | 0 | 16.95 | 9.4 |
| city | base~aa | 6.38 | 12.23 | 24.0 | 1 | 18.63 | 12.0 |
| horde | base | 5.51 | 9.82 | 16.0 | 0 | 13.90 | 8.9 |
| horde | base~aa | 5.50 | 10.54 | 15.3 | 0 | 13.84 | 9.2 |

A/A floor (twin - base, median [CI95]): city p50 +0.132 [-0.673, +4.882] ms, p99 -0.028 [-0.746,
+4.854], CPU +0.72 [-0.20, +7.53] s; horde p50 +0.171 [-0.243, +0.884], p99 +0.250 [-1.956, +2.377],
CPU -0.23 [-1.72, +1.69] s. 10 of 12 city and 9 of 12 horde runs CONTENDED by the ledger; other
processes took 3-15 cores per run. Per run, p50 follows the load: about 4.5-4.9 ms at 3-5 other
cores, 5.8-9.8 ms at 11-15. **At tonight's load six rounds cannot resolve law 7's 0.15 ms**: the
floor is printed beside every figure so a later group cannot mistake noise for cost. Added
`--quiet=<cores>` (wait up to `--quiet-wait` s before each run while the machine is busier).

### A1 cause, named (21:35-21:55, span runs + a temporary split, release export)
- `node_spans` worst frames (two runs, 21:36): tick 1513 `character_rigs.gd` 13.1 / 14.9 ms (also
  ticks 2, 6, 7: 11-15 ms); tick 2032 `draw: fx_view.gd` 11.2 / 16.2 ms; one run only:
  `prop_occlusion` 9-10 ms at ticks 124 / 354.
- A temporary timing split in CharacterRigs.step_ticks (never committed, file restored from
  `build/n12/character_rigs.gd.orig`): selection 12-35 us, acquire 0.5-0.7 ms once at start; the
  spike is ONE drive call, actor 0 = Rivet's own rig: 7.8-14.2 ms at ticks 6-8, 258, 1513, 1533.
- Cause 1: `RivetFrames._set_strip` loads a drawn strip (walk grid, a weapon's equipped / left /
  reload strip) the first time his pose names its path, synchronously, inside the pose step. The
  reel's switch to the plasma rifle after the kill at 1512 is the first armed walk with it.
  (Side bug: `_tex.get_or_add(path, load(path))` ran load() on every swap, the default argument is
  evaluated eagerly.) perf-city's RivetHeldView.warm() warmed the held-gun art; the drawn strips
  came later (n9-n10) and were never warmed.
- Cause 2: WeaponFxArt loads an fx id's frames on its first draw. The reel switches to the rocket
  launcher at about tick 1992 (480 ticks without a kill); its first shot and blast (2019-2034)
  loaded the rocket / blast / scorch / smoke cells inside FxView's draw.
- Fix 1: `RivetStripWarm` (features/characters) lists every shipped strip for the view's art key and
  the carried guns (19 for the reel's four) and asks StreetStrips (perf L3's worker-thread cache)
  to prefetch them from RivetHeldView.warm(); RivetFrames.texture_of reads StreetStrips.get_tex.
  Before = the existing `--strip-prefetch=off`. One run: character_rigs max 13-15 -> 3.2 ms.
- Fix 2: `WeaponFxWarm` loads all 61 fx cells (2.9 MB PNG) into WeaponFxArt's cache at FxView._ready
  (`frames_of` accessor; `WeaponFxCells.ids()`). Before = `--fx-warm=off` (new, in KNOWN_FLAGS).
  One run (others at 15 cores): fx_view draw max 11-16 -> 3.6 ms.
- Not yours to fix tonight, observed: ~70 "Invalid polygon data, triangulation failed" ERRORs at the
  city fight's exit (after the frame log is written); a 500-650 ms OS-pump stall about 4 s after
  launch in every run (in the dropped first second).
- `test_quest_blade` fails when run alone (`--changed` / `--select`), with my change reverted too:
  the slot actions get their keys from input_actions.json at runtime, so the test passes only after
  another test installed them. Order-dependent, inherited; passed in the arrival fast run.

### A1 measured (21:52-22:08, `build/n12/gate-warm/`, intermediate build with a separate `--fx-warm` flag)
`node tools/perf/fight_gate.mjs --no-export --rounds=6 "--arms=off:--strip-prefetch=off --fx-warm=off,warm:" --quiet=10 --quiet-wait=60`
(36 runs, all CONTENDED, others 3-16 cores; the quiet wait often ran out at 60 s).

| city | p50 | p99 | worst | >25 | CPU s | others |
|---|---|---|---|---|---|---|
| off | 4.83 | 8.63 | 19.7 | 0 | 14.54 | 6.7 |
| warm | 5.15 | 9.45 | 12.6 | 0 | 15.09 | 6.6 |
| off~aa | 4.91 | 12.11 | 23.3 | 1 | 14.86 | 7.2 |

Gate verdicts (warm - off): p50 +0.211 [+0.033, +5.240] 1/6 lower, WASH (A/A +0.231); worst -7.26
[-8.90, +2.18] 5/6 lower, WASH by its interval; CPU +0.48 s WASH (A/A +0.79; CPU includes the boot,
where the warm now loads). Horde: nothing moves (one gun, no switch), as expected.
The spike ticks, per round (`build/n12/ticks.py`), warm - off: tick 1513 -15.0 -11.6 -12.0 -11.6
-15.6 -5.4 (6/6; A/A +9.3 +3.4 +1.3 +0.4 +4.3 -1.0); tick 6 6/6 (-7.1..-15.9); tick 7 6/6
(-6.6..-17.0); tick 2032 -14.1 -13.0 -6.2 -8.9 -7.7 +6.7 (5/6; A/A -5.6..+13.7). Settled frames over
16.7 ms, median per run: off 1, off~aa 4, warm 0.
Pixels (`build/n12/film.sh`, MJPEG framemd5, fixed fps, 1280x800, 2132 frames): off vs off2 (A/A)
0 differ, off vs warm 0, off2 vs warm 0.

### Restructure for the debt ratchet (22:12-22:20)
Lint flagged growth in fx_view, weapon_fx_art, rivet_held_view, launch_args, rivet_frames. Kept the
debt flat instead of accepting it: `--strip-prefetch=off` is the before for both warms (no new flag),
the fx frame cache moved into WeaponFxWarm (weapon_fx_art 290 -> 287), RivetFrames calls
StreetStrips.get_tex directly, perf-city's held-gun warm loop moved into RivetStripWarm.warm (same
calls), RivetHeldView.warm() calls both (287 -> 281), fx_view and launch_args untouched. Only
node_spans' +35 dev lines accepted (`--accept-regression`, in cf7443dc0).
- cf7443dc0 the gate; 25a72efe6 the fix. Unit `--changed`: 634 pass, 1 fail = test_quest_blade
  (inherited, order-dependent, see above).
- Re-verified on 25a72efe6's export: logs "warmed 61 weapon fx cells", "prefetching 19 drawn
  strips"; film `head` vs `off` 2132 of 2132 frames identical.

### Mutation and the group's gates (22:30-)
- Mutation on 25a72efe6 (tests test_rivet_strip_warm, test_weapon_fx_warm, test_rivet_held_warm):
  rivet_strip_warm.gd 69.2 % (9 / 13, 4 invalid); weapon_fx_warm.gd **20 % (1 / 5)**: frames_of loads
  lazily, so the cache assertions held with warm() doing nothing; weapon_fx_cells.gd 47.1 % (8 / 17;
  the file is mostly older code). Fixed the fx tests: `loaded()` / `reset()`, the cache full right
  after warm(), empty under `--strip-prefetch=off` and under `--weapon-fx=shapes` (0c6c36ff8; the
  first try was refused by the hook: `OS.get_cmdline_user_args()` in a test is a new direct read).
- Full unit on the working tree of 0c6c36ff8: 2208 / 0 (test_quest_blade passes in the full run).
- Parity at 0c6c36ff8: bit-exact over 1200 steps, mutation caught at 629.
- Masters: `gtai-masters/n12/visual/a1-city-fight-frames-off-aa-warm.png` + `frames.json` (1 entry).
- Mutation at the head (`--json`, build/mutate/): weapon_fx_warm.gd 20 -> **71.4 %** (5 / 7; the two
  survivors are the log line's counter), rivet_strip_warm.gd 69.2 -> **92.3 %** (12 / 13 after
  b4bc7a5d4's tests: warm asks the worker for every strip of a carried gun, none under a flat view or
  the flag; the survivor `or -> and` in the guard is equivalent, a flat view's art key is empty),
  weapon_fx_cells.gd 47.1 % (8 / 17): 5 survivors are older code (read, frame_paths, coloured), the
  4 in ids() are equivalent on the shipped table (no id where the `_0` guard decides anything).
- b4bc7a5d4: StreetStrips.known(path) (read-only) + 3 tests. Unit selection 19 / 19.
- Full unit on b4bc7a5d4: 2211 passed but **8 FLAKY + 1 SCRIPT ERROR caused by my own test**:
  its after_each called ViewMode.select("") = the table default (combo) while the suite runs under
  the flat default, so later straight-down tests (test_shot_lift, test_street_card_sets,
  test_street_quest_cards, test_vehicle_view; riot_shield_card's nil texture) saw a tilt. Fixed in
  8517b4e9c (save / restore ViewMode._shared). Full unit after: **2211 / 0, no FLAKY, no script error**.
- Scenarios at b4bc7a5d4: **55 / 55** (8517b4e9c touches one test file only). Debt ratchet ok, lint
  15 / 15 (hook, every commit).

## Group A closed (23:35). Head 8517b4e9c. NEXT: wait for the Director's Group B dispatch.
The REPORT for Group A was returned to the Director as text (the harness refused a REPORT.md
written by this builder); it can be committed from that text.
