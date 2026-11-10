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

## Group A report

Head `14320ad7f` (accepted by the Director). Commits: `8006ad33e` brief; `cf7443dc0` fight frame gate
(A2) + NodeSpans worst_frames; `25a72efe6` Rivet's drawn strips + weapon fx cells load behind the
load (A1); `0c6c36ff8`, `b4bc7a5d4` the warms' tests made to bite; `8517b4e9c` my test restores the
flat default view; `14320ad7f` journal.

Packages:
- A1 partly existed (11-04 perf-city explained the dead time and the load-tracking stalls), the rest
  shipped: the deterministic worst frames were first-use loads: Rivet's rig, one pose step at
  7.8-14.2 ms (ticks 6-8, 258, 1513, 1533: a drawn strip loaded the first time his pose named it)
  and FxView's draw at 11-16 ms (ticks 2019-2034: the rocket's first blast cells). Gate, 6 rounds,
  before = `--strip-prefetch=off` on one build: tick 1513 -5.4..-15.6 ms and ticks 6-7 -6.6..-17.0 ms
  in 6 of 6 rounds, tick 2032 5 of 6 (median about -8 ms); settled worst median 19.7 -> 12.6 ms; film
  2132 of 2132 frames identical (A/B and A/A). Still `gtai-masters/n12/visual/a1-city-fight-frames-off-aa-warm.png`.
- A2 shipped: `node tools/perf/fight_gate.mjs` (city + horde at combo, release; p50 / p99 / worst /
  over 25 ms / CPU s / other processes' cores; A/A twin; paired CI95; `--quiet`). AGENTS.md row,
  decision `perf/fight-gate`. A dev command, not an evidence kind.

Gates at the head: lint 15/15; unit 2211/0; scenarios 55/55 (at b4bc7a5d4); parity bit-exact
(mutation caught at 629); debt ok (+35 dev lines accepted for the probe). Mutation: rivet_strip_warm
92.3 %, weapon_fx_warm 71.4 % (survivors = the log line's counter), weapon_fx_cells 47.1 % (5 survivors
in older code, 4 equivalent on the shipped table). On arrival: lint, scenarios 55/55, parity green;
unit red only from stale DLLs in the worktree (replaced with int-day's build of the same source);
`test_quest_blade` fails alone, passes in the suite (inherited).

Perf: baseline (contended, 6 rounds): city p50 5.36 / 6.38 ms (A/A), p99 11.4 / 12.2, A/A p50 CI
[-0.67, +4.88]; horde p50 5.51 / 5.50, p99 9.8 / 10.5, A/A CI [-0.24, +0.88]. The fix's p50 +0.21
and CPU +0.48 s sit inside the A/A floor (+0.23 / +0.79; CPU includes boot).

Calls for the owner: none (no picture or tuning changed).

Unsure / brief corrections: "p99 8.79 ms / 424 ms" were the r19 city-bench aggregate, not the
fight's log. The city fight at combo read p99 8.6-12.2 ms contended (not judged against 7 ms).
Left as listed items: GhostFormHud redraws every frame (0.21 ms), ViewPitchEase re-dresses every card
(0.29 ms), ~70 triangulation errors at exit, a 0.5-0.65 s OS stall about 4 s after launch, the p55
strips load on a boss swap, `check.mjs` false-fails on scripts that reach the Log autoload.

## Group B (00:00-)

Director amendments (23:40): judge cost by span time of touched nodes, CPU s and frames over 25 ms
against the A/A, never the contended p50 alone; anything that loads art is warmed; keep each
group's report in this JOURNAL; inherited items stay listed.

### B1 victim sync: measure first
- Instrument `dev/bench/sync_probe.gd` (`--sync=<json>`, attached in arena_game after the cast rigs):
  a row per landed hit (struck, kill_landed, wounded: melee lands no struck), closed on the first
  tick the victim's rig draws >= 1 screen px of reaction (offsets through the rig's global
  transform), starts dying, or is taken by a kill cut; peak px, families and a 16-tick trace.
  Mistakes on the way: thresholds first in part px (wrong scale, 10 part px is not 1 screen px
  here); `--armored` without a value zeroes Rivet's hp (Rivet died every 60 ticks: those runs
  were invalid; `--armored=3`); melee had no rows until kill_landed / wounded were heard.
- Runs: `build/n12/sync/run.sh` (13 guns x `--lone` / `--lone --armored=3`, headless fixed fps 900
  ticks), `melee.sh` (5 chapters x patrol / `--riot-victims`), `table.py` -> tables in
  docs/polish/ranged.md (n12 section). Before: guns and kill cuts 1-2 ticks; the fire catch 1-3
  (no direction); **claw wound on a riot cop 20-34**, **katana wound 12**, plasma wound 3.
- Looked at (32 px/m films, `build/n12/sync/film/`): shard kill 342 (star on 343, thrown pale by
  344: the 11-04 late reaction was already fixed by KillShardJolt), plasma kill 335 (in sync; the
  body becomes a cream disc then a gold ring: the human vanishes, art not timing), electro kill 399
  (in sync, convulsing before), claw riot wound (stop froze an unmoved cop, he moved after).
- Cause: `fold` (melee from the front) eases in over 0.25 of 0.5 s: 0.3 px at hit + 3, peak under
  1 px... in screen px 1.1 at hit + 4, peak about hit + 9; and the 4-tick melee stop froze the
  frame before it. stagger the same shape (plasma wound 3 ticks, 2.0 px first frame).
- Fix (723d86db6): ReactPose applies the existing hit-frame snap (n7's electro throw, SNAP_IN 2
  ticks) to any family with `snap_m`; fold / spin 0.15 m, stagger 0.2 m; hit_feel.json melee
  `hold_delay_ticks` 2. Before = `--react-snap=off --wound-hold=off`. After: claw wound 1-2 ticks
  (3.5 px at hit + 2, was 0.3), katana 2, plasma wound 2 (5.2 px, was 2.0). Film A/B
  `claw_riot_wound_snap-ab-32ppm.mp4`: the held frame now shows the thrown cop. Plasma: on film the
  impact disc hides most of the throw (modest).
- Tests: test_react_snap +2 (fold / spin / stagger thrown by the second tick; melee hold delay 2).

### B2 per-weapon camera grammar
- Audit (hit_feel.json `weapons` vs weapons.json hit_class): light, heavy, blast, burn each have
  their odd gun overridden; medium's plasma rifle rides the approved row (I 3, left); shock: the
  ray gun (10 Hz auto) rode the electro gun's single-bolt row (4-tick stop + shake per hit).
- Measured (films, frames whose tick does not advance, target `--armored=6`): ray gun stops at 332
  and 350 mid-stream, none on the 361 kill (the cooldown ate it); Gatling 0; electro 4 stops.
- Fix (b2e1b9a42): `ray_gun` row (hitstop "", shake "", kick 1): no freeze in the stream, the kill
  star holds 6 frames (362). Test test_feel_cam +1 (fails without the row: 8 held ticks).
- Zoom punch: not built (no Impact cell below 2 at 32 px/m for want of it).
- Docs: polish ranged.md / melee.md n12 sections (af66b8713). Masters: 3 clips + 3 stills.
- Gates: unit 2214 / 0, parity bit-exact (00:45).
- Gate (build/n12/gate-b, fresh export of b2e1b9a42 + docs, 3 rounds, before = `--react-snap=off
  --wound-hold=off`), CONTENDED (7 / 9 city, 4 / 9 horde runs; others 4.8-6.8 cores): every paired
  verdict WASH, frames over 25 ms 0 in every arm. City p50 4.71 / 4.67 (on) / 4.67 (A/A), A/A CI
  [-0.53, +0.07]; horde p50 4.94 / 5.03 / 4.79, A/A CI [-0.27, +0.22]. Horde CPU on - off +0.30 s
  [+0.14, +0.66] with the A/A flat: the on arm rendered more frames for the same 1800 ticks
  (1664 / 1634 / 1621 vs 1598 / 1615 / 1613: the stops held later and longer), per frame 7.6-7.7
  ms CPU on vs 7.3-7.6 in the off arms: held stop frames, not per-frame work. Span cost: one
  early-returning call per reacting rig per step; no art loaded, so nothing to warm.
- Mutation react_pose.gd (`--max=20`, tests react_snap, human_react, plasma_wound, melee_wound,
  react_link): 5 % (1 / 20): the sample fell on the file's older pose constants (flinch, cower,
  convulse numbers no test pins) and missed my line; planted by hand (the `_hit_snap` call
  removed): 2 tests fail (electro throw, melee throw). Not a claim for the whole file.
- Scenarios at af66b8713: 55 / 55.

## Group B report

Commits: `05dca662e` Group A report kept in this JOURNAL; `723d86db6` B1 melee / heavy wounds
answer on the hit frame (+ SyncProbe); `b2e1b9a42` B2 the ray gun's camera row; `af66b8713` polish
docs (sync table, cells); this journal commit.

Packages:
- B1 victim sync: partly existed, partly shipped. Measured first, every Rivet weapon lethal and
  non-lethal (SyncProbe, headless fixed fps): guns and kill cuts 1-2 ticks; the homing shard's
  11-04 late reaction was already fixed (KillShardJolt: star on the kill tick, body thrown by the
  next); electro and plasma kills are in sync. Over 2: the melee wounds on armoured victims (claw on
  a riot cop 20-34 ticks: the fold drew 0.3 px at hit + 3 and the stop froze the unmoved body;
  katana 12) and the plasma rifle's wound (3). Shipped: fold / spin / stagger take the existing
  hit-frame snap (0.15 / 0.15 / 0.2 m) and the melee stop starts 2 ticks after the hit, so it holds
  the thrown frame: claw wound 1-2 ticks (3.5 px at hit + 2), katana 2, plasma wound 2 (5.2 px, was
  2.0). The fire catch stays 1-3 ticks (no direction by design). Before `--react-snap=off
  --wound-hold=off`. Melee claw-wound Victim sync 2 -> 4 (melee.md 1-5 scale);
  `claw_riot_wound_snap-ab-32ppm.mp4`, `plasma_wound_snap-ab-32ppm.mp4`.
- B2 per-weapon camera grammar: mostly existed (per-class rows and per-weapon overrides). The one
  gap: the ray gun (10 Hz stream) rode the electro gun's shock row, so its stream froze every 18
  ticks and the stop cooldown ate its kill's stop. Shipped a ray_gun row like the Gatling's: no
  freeze, the kill star holds 6 frames (was 1); `ray_gun_stream_kill_stop-ab-32ppm.mp4`. Zoom punch
  not built: no Impact cell below 2 at 32 px/m for want of it.

Gates at the head: lint 15/15 (every commit); unit 2214 / 0; scenarios 55 / 55; parity bit-exact
(mutation caught at 629); debt ok (SyncProbe's dev lines accepted). Mutation: react_pose.gd 5 % on a
20-mutant sample of its older pose constants; my changed line planted by hand is caught by 2 tests;
the ray gun row's test fails without the row. Inherited, still listed: test_quest_blade (fails
alone), check.mjs autoload false-fail.

Perf (gate, 3 rounds, CONTENDED, others 4.8-6.8 cores): all paired verdicts WASH; frames over 25 ms
0 in every arm; city p50 4.71 off / 4.67 on (A/A 4.67, CI [-0.53, +0.07]); horde 4.94 / 5.03 (A/A
4.79, CI [-0.27, +0.22]); horde CPU +0.30 s = the extra held stop frames (per-frame CPU inside the
A/A). No new per-frame work beyond an early-returning call; no art loaded.

Calls for the owner:
1. Melee wound throw: fold / spin 0.15 m and stagger 0.2 m snaps (built) vs none
   (`--react-snap=off` or the human_reactions.json snap_m keys removed). It also adds the throw to a
   hand cannon wound on armour.
2. The melee stop freezes 2 ticks after the hit (built, the light guns' rule) vs on the hit tick
   (`--wound-hold=off`, which also reverts the light guns' and the Gatling's; or hit_feel.json
   melee `hold_delay_ticks` removed).
3. The ray gun's stream without per-round stops (built) vs the shock class's stop and shake on
   every round (remove hit_feel.json's ray_gun row).

Unsure / brief corrections: the brief's "known late" homing shard was already fixed on main
(KillShardJolt), and the electro / plasma complaints are not timing: the plasma kill and wound
draw a cream disc that covers the human at 32 px/m (an art read of backlog item 1, not touched).
The katana wound was measured by the probe but not filmed. The non-lethal gun rows before the fix
were not measured (the first `--armored` runs zeroed Rivet's hp).

## Group C (00:50-)

- 00:52 selftest on arrival (ae253e8bf): look goldens 11/11 worst 0.00, block 5/5 worst 0.00,
  world lock 0.00 %.

### C1 ink line weight on impact
- First seam: the hit flash's tinted part material (print_part `hit_edge` on tinted levels, a level
  stamped by ReactLink). Two findings: (1) an early `return` in print_part's fragment moved EVERY
  look golden at rest (worst 0.00 -> 1.99 / 2.00, all looks incl. d1) although no material set
  hit_edge; reverting only the shader restored 0.00; restructured without the return (body in an
  else): 0.00 again. (2) The seam is dead in the arena and the city fight: with ReactLink on,
  ArenaRigs feeds no HIT clip, so no rig is tinted there (A/B 0 of 400 frames differed for pistol,
  plasma, hand cannon; 0 of 200 claw). The tint path was reverted entirely.
- Shipped seam (41d415a1b): InkHit pulses the struck rig's card (the drawn figure under combo,
  raw) with ink_line.gdshader: the art as is plus an ink ring of `ink_edge_px` on both sides of
  the alpha edge, wobbling on a 3-texel lattice of the figure, eased back (quadratic) over the
  class's flash_ticks, then the card's own material back. First cut inked a stray dash above the
  head (the next row of the walker grid): the ring is clamped to the card's frame cell (material
  per level and grid). Data: ink_edge_px per class (light 1, medium / shock / melee / slice 1.5,
  heavy / melee_heavy / ram 2, blast / slam 2.5, burn / chain 1), required by the schema.
- Films (data 0 vs shipped, same build; `build/n12/sync/film/ink-*`): differing frames pistol 18
  (4 a hit), plasma 9, claw 52, hand cannon 0 (its hits are one-shot kills: the kill cut takes the
  rig). Looked at 4x: claw on a riot cop a heavy wobbling rim through the stop (f75-f80), gone by
  f81; pistol a darker outline f333-f335. At 1x the claw reads, the 1 px light class is subtle.
- Cost: InkHit.step 0.22 us a frame at rest, 7.7 us with 4 struck cards, 36 us with 16 (headless
  debug micro-bench); the shader's 8 taps only on the struck card's pixels. First-use spike found
  in the films' pipeline log (149 ms at the claw's first hit, tick 76): InkHit.warm (RivetHeldView
  .warm, 61de78acd) compiles it at the load; after, tick 76 at 43 / 42 ms (the film's pace).
- The plasma disc (Group B) is not this seam (it is the weapon's impact FX, not the card): no
  cost estimate for a smaller disc from here.

### C2 plate misregistration shock
- look_profiles.json's world verm / teal shifts move nothing: every profile's world verm and teal
  plates are 0 (doctrine). The plates that print off register are the D5 overlay's ink ghost
  (ink_mis), vermilion pass (verm_mis) and colour plate (plate_mis), live at 32 px/m (amount 0.5).
- Built (f35a6a874): PlateShock (core/render; one in flight + 20-tick cooldown, quadratic ease),
  kicked by FeelCam from the class row (`plate_shock_px` / `plate_shock_ticks`), advanced on the
  sim tick, added by LookOverlay to its plates and written back once at the end.
- Measured on the rocket's kill (32 px/m, frames 363-376 differ): 3 px -> 21 of 1.02 M px change
  > 24 levels (mean 0.27); 6 px -> 37 (mean 0.33); 3 px at 64 px/m -> 2129 (mean 0.37), a faint
  doubled band along a kerb line. Two iterations without a visible gain: shipped OFF
  (plate_shock_px 0 everywhere, ticks kept). A call for the owner.
- Goldens after every shader / overlay change: 0.00 / 0.00 (with the shock on in data and off).

### Gates at the head (61de78acd)
- Goldens 11/11 and 5/5 worst 0.00, world lock 0.00 %; unit 2226 / 0; parity bit-exact (629).
- Fight gate (build/n12/gate-c, 3 rounds, before `--feel=off`, so it also drops the stops and
  kicks), CONTENDED (others 6.1-7.8 cores): every verdict WASH, frames over 25 ms 0 in every
  arm; city p50 5.03 off / 4.71 on (A/A 4.94, CI [-0.08, +0.40]); horde 4.73 / 4.85 (A/A 4.75, CI
  [-0.36, +1.09]); per-frame CPU on 6.8-8.6 ms vs off 6.8-8.0 and A/A 7.0-9.0.
- Mutation: ink_hit.gd 44 -> 68 % (17 / 25; survivors: Pulse defaults and guard edges no table
  row reaches), plate_shock.gd 64 -> 72 % (18 / 25; survivors: static initial / reset values the
  code overwrites before use), after 81186beed's tests (exact levels and px, reset, meta clean-up,
  the warm's guards and its sprite freed, the shock's guard edges and cooldown edge).
- Scenarios at 81186beed: 55 / 55.

## Group C report

Commits: `41d415a1b` C1 the struck figure's ink line (InkHit + ink_line.gdshader, data);
`f35a6a874` C2 the plate shock, shipped off (PlateShock, data at 0); `61de78acd` the ink line's
shader compiled behind the load; `81186beed` tests made to bite; this journal commit.

Packages:
- C1 ink line weight on impact: shipped, default ON. The struck figure's card wears an ink ring
  of the class's `ink_edge_px` (light 1, medium / shock / melee 1.5, heavy 2, blast 2.5 screen px)
  on both sides of its outline, wobbling on a 3-texel lattice of the figure, eased back over the
  class's flash_ticks (4-10). Local to the struck figure: no full-frame flash. The visible gain is
  the claw on a riot cop (a heavy rim through the stop, `ink_line_claw_riot-ab-32ppm.mp4`, still
  frames 73-83); the 1 px light class is subtle at 1x (`ink_line_pistol-ab-32ppm.mp4`). Kills
  taken by a kill cut (hand cannon, rocket, cuts) show none: the rig is gone. Not done: the
  world-print radius for heavy / blast (time; the struck figure first). Before: ink_edge_px 0
  (or `--feel=off`).
- C2 plate misregistration shock: built, shipped OFF. A blast (blast / slam / ram rows) knocks
  the D5 overlay's existing off-register plates (ink ghost, vermilion pass, colour plate) along
  the blow and they settle over 10 ticks (ram 8): one in flight, 20-tick cooldown, started from
  FeelCam (so off under `--feel=off` and reduced motion), no new colour, no luminance change.
  Peak shift tried: 3 and 6 screen px. On the rocket's kill at 32 px/m nothing reads (21 / 37 px of
  1.02 M change by more than 24 levels); at 64 px/m a faint doubled band on a kerb line (2129 px).
  The world print's own vermilion / teal plates are 0 (doctrine), so the shifts look_profiles.json
  carries move nothing. Data plate_shock_px 0 in every row; the call below turns it on.

Gates at the head: look goldens 11/11 and block 5/5 worst 0.00 (on arrival, and after every
shader / overlay change once the early-return regression was fixed), world lock 0.00 %; lint
15/15; unit 2226 / 0 (at 61de78acd; later commits are tests, 18 / 18); scenarios 55 / 55; parity
bit-exact (629); debt ok (react_link +2, hit_feel +2, rivet_held_view +1 accepted with reasons).
Inherited, still listed: test_quest_blade alone, check.mjs autoload false-fail.

Perf: InkHit.step 0.22 us a frame at rest, 7.7 us with 4 struck cards, 36 us with 16 (headless
debug); the ring's 8 taps only on struck cards' pixels. First-use spike found and warmed: 149 ms
at the first struck card -> 43 ms (the film's pace). Gate (3 rounds, before `--feel=off`, which also
drops stops and kicks; CONTENDED, others 6.1-7.8 cores): all WASH, frames over 25 ms 0 in every arm,
city p50 5.03 / 4.71 (A/A 4.94, CI [-0.08, +0.40]), horde 4.73 / 4.85 (A/A 4.75, CI [-0.36, +1.09]),
per-frame CPU inside the A/A spread. C2 costs nothing while off (no uniform written at rest).

Calls for the owner:
1. The struck figure's heavier ink line (built ON): the class widths above, or narrower, or none
   (`ink_edge_px` 0 per class row in hit_feel.json; `--feel=off` drops it with all camera feel).
2. The plate shock (built OFF): plate_shock_px 3 on blast / slam (2 on ram) turns it on; it only
   reads at arena zoom and faintly. A stronger read would need the shock to raise the overlay's
   ghost strength for its ticks (a darkening of the page: closer to a flash), not built.

Unsure / corrections: the brief's seam list did not include the one that works in the arena
(the drawn card); the hit-flash tint it implies never runs there. look_profiles.json's plate
shifts carry no plate at world level. The plasma disc is the weapon's impact FX, not this seam.
