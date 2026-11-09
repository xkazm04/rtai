# Perf LEDGER - lane perf, day run d9 (2026-11-07)

Branch `d9-perf`, cut from main `3982af1a`. Every number here names its build, scene, machine state and
instrument. Host: Ryzen 7 7800X3D (8C/16T), RTX 4090 (+ the AMD iGPU), Windows 11, Godot 4.7.2.
**Host ms are host ms**: nothing here is a Steam Deck or handheld figure (that is the `handheld` lane's).

## n10 night (2026-11-08 21:00 -, branch n10-perf from main 9bbe6d0a)

### Item 1 (it1): the rig cost under combo: a walker's hidden limbs are not posed (d006d70e, a9370647)
Finding: n9's split (below) counted the walker cards as ~8 of 50 people and so priced "skip RigPose under a card" at ~65 us;
but at the rig stress's 8-9 pose steps a tick about 7.6 place a whole-figure card, so nearly every pose step posed limbs
that nothing draws. Change: `CutRig.limbs_cold` (true while a walker's whole-figure card is up: `StreetWalkerCards.hides_parts`);
`RigGait` skips `_solve_leg` (the planted-foot stepping stays: `foot_w` is what the parts land on), `RigPose` skips the
arms; `RigPose.warm_limbs` poses them the step the card goes away and before a kill's `GibCut` / `KillSprawlCut` reads the
parts. The torso, head, gait phase and feet still step: the card reads only those. Also dropped: the head card's double
`_place` under a walker (`frame_of` kept: the walker's `frame_coords` reads the facing), `hide_all` and the crowd
card's scale nudge on a cold rig, the per-step `row_of` / strip format (read off the card).
A/B rig_bench 50 people, `--view=combo`, headless editor binary, interleaved base (the 9bbe6d0a worktree) / head, CONTENDED
(4-12 Godot processes up): `evidence/perf/n10-rig/ab.sh`, `run1/summary.txt`:

| view combo, p50 ms (50 people) | base | head |
|---|---|---|
| r1 | (1.64: an import-cold first run, not counted) | 0.544 |
| r2 | 1.236 | 0.527 |
| r3 | 1.159 | 0.659 |

The target (at most 1 ms p50 at 50 people under combo) is met with margin; p99 base ~1.9-2.6 ms, head 1.1-2.0.
**The pixels:** RigStress at tick 600, combo, windowed d3d12, 1280x720 (`framecmp/_tmp_framecmp*.gd`, the same script
in both trees): head vs base **0 pixels differ** (`framecmp/base.png`, `head.png`). The first head render differed in 5683
pixels: the cream rims came back at the walkers' feet, because `_on_view` re-showed them after the card hid the parts and
`hide_all` no longer runs each step on a cold rig. Fixed (a9370647: on_view keeps a card's parts' rims hidden), a test pins
it. Tests: `test_rig_limbs_cold` (5): a carded rig poses no limb, the card's inputs (phase, facing, head and torso
transforms, feet) stay identical to an always-posed rig, warm_limbs lands within 3 part px / 0.08 rad of it, a gone card
warms on the next step, a kill's cut warms a cold rig, the rims stay hidden. Full unit on d006d70e: exit 0. Owed: the director
reel x3, the evidence gate, a mutation run on the cold path.

### Item 2 (it5): the feed's dead-flip scan runs in C++ (cfdb53e4)
`CitySim.scan_dead_flips` (static, `native/sim_core/src/snapshot.cpp`) finds the rare death flip in the snapshot; `CityFxFeed.native_scan`
picks it when the library has the method, the GDScript loop stays as the no-DLL fallback. Tests: `test_fx_triggers` (the native
scan fires what the script loop fires), `scons tests` 0 failed.
Micro only so far, `evidence/perf/n10-scan/` (debug editor binary, a synthetic 400 people, about 10 Godots up, CONTENDED):
observe ~22 us native (one block 52.6) against 115-423 us script. The SCRIPT ERROR lines at the top of `micro.out.txt` are the scratch `-s`
script compiling before the autoloads exist; none falls inside the timing blocks. **Not a bench number**: the release riot A/B is item 3.
The DLLs are git-ignored: until a merge rebuilds `template_release` with scons, the export silently keeps the script loop.

### Item 3 (it6): the riot release A/B against main 9bbe6d0a: head wins at combo, NOT a quiet run
`node tools/perf/ab.mjs --no-lock --scenes=riotc --pairs=6 --arms=main@exe-windows-bench-main:,head@exe: --out=evidence/perf/n10-riotc`
(`--no-lock` because ab.mjs's own lock is the old n5 path: `gtai-n10/bench.lock` was held by hand around it). Release `windows-bench`
exports (each log `debug_build: false`), main from the 9bbe6d0a worktree with its own DLL (no `scan_dead_flips` in it), head cfdb53e4 with
the new release DLL (the symbol is in it), the same 256 baked chunks (hash lists compared). `riotc` = the new preset: `riot` at `--view=combo`,
the view main boots; the logs say `view: combo`. 400-actor riot, 30 s, 1920x1080, fixed 60 uncapped, arm order alternating, 0 errors, 739 draws on both.
**CONTENDED throughout**: 0-10 other Godots up (`CONTENDED(n)` in the runner's rows), the machine never went quiet this iteration.

| round | frame p50 ms main / head | rigMsP50 main / head |
|---|---|---|
| 0 | 6.15 / 4.78 | 1.740 / 0.983 |
| 1 | 5.60 / 4.70 | 1.678 / 0.950 |
| 2 | 5.72 / 3.59 | 1.652 / 0.753 |
| 3 | 6.75 / 4.86 | 1.648 / 0.932 |
| 4 | 7.01 / 6.35 | 1.750 / 1.060 |
| 5 | 5.32 / 4.66 | 1.587 / 0.964 |

Head is lower in **6 of 6** rounds on both columns: frame p50 median paired delta **-1.14 ms**, rig p50 median 1.665 -> 0.957 ms (-0.72; at most 1 ms in 5 of 6 head rounds, 1.060 in round 4).
**ab.mjs's range rule still prints WASH** (half-spreads 0.85 and 1.38 ms: the contention swings both arms); the claim rests on the paired ordering (sign test two-sided p = 0.03), not on that rule. p99 and worst: no claim.
The two head cuts are not separated: this is items 1 and 2 together.
At the older `riot` preset (`--view=tilt70`), 4 + 6 pairs (`evidence/perf/n10-riot-b1`, `n10-riot-b2`, same exports, CONTENDED): frame p50 head lower in 7 of 10, median -0.56 ms, WASH, not claimed; rig p50 head lower in 10 of 10, median -0.54 ms.
Slip recorded: batch b2 was run as "combo" with `--view=combo` appended to the arms; the preset's own `--view=tilt70` comes first and wins, so b2 is tilt70 (its logs say so) and was renamed. Use the `riotc` preset.
Process CPU and RAM columns: several rounds read NaN (the sampler under load), so no CPU or RAM claim from these runs.

### Item 4, idea 1: the rig feed's fill in C++ (it7): built, measured, reverted, NOT the baseline
Hypothesis: `_fill_feed`'s loop is a dense GDScript scan (n9 table above: 387 us a riot tick, debug); `CitySim.fill_feed_rows` writes RigFeed's ten columns, matching the script's float32 arithmetic. Commit 4f153362, reverted by 409ec9d3 (the code stays in git; `evidence/perf/n10-feed/`). `test_city_feed_rows` compared the native rows with the script's on synthetic and live-sim snapshots.
Micro (`evidence/perf/n10-feed/micro_debug_editor.log`, debug editor binary, synthetic 400 people / 262 rows, about 20 Godot processes up, CONTENDED): ~10 us native vs ~350 us script.
Bench (release `windows-bench`, `riotc` = combo, 400 actors, 6 interleaved pairs, against the export of the previous head, under gtai-n10/bench.lock, CONTENDED 0-6; my own mutation runs were also up; `evidence/perf/n10-feed/riotc/`). Workloads identical (actors 399.79, visible 288.51, full rigs 20, draws 739):

| round | frame p50 before / head ms | rig p50 before / head ms |
|---|---|---|
| 0 | 4.68 / 5.50 | 0.949 / 0.994 |
| 1 | 4.75 / 4.30 | 0.961 / 0.965 |
| 2 | 4.75 / 5.20 | 0.962 / 1.007 |
| 3 | 3.88 / 4.29 | 0.807 / 0.967 |
| 4 | 3.61 / 3.77 | 0.777 / 0.862 |
| 5 | 3.36 / 3.89 | 0.712 / 0.917 |

Frame p50 head lower in 1 of 6; rig p50 head higher in 6 of 6 (median +0.065 ms). **WASH at best: no gain measured, so it is not the baseline.** What this does NOT show: that the fill caused the rise. The rig timer does not contain the fill, and render CPU (0.72 -> 0.79 ms in round 0, higher in 6 of 6) and the C++ sim step (higher in 5 of 6) also rose, and the change cannot touch either. So the whole head process read slower; the A/A control below shows the bench does that with no code change.
The microbench's ~340 us saving did not appear at the bench. It was the debug binary on a synthetic snapshot; the release GDScript loop was never timed, so the micro does not say what the release saves.

### The A/A control (it7): what this bench reads with no change at all
Same code in both arms: the export of cfdb53e4's code from 23:26 against a fresh export at 40fab8c7 (409ec9d3 put the code back, `git diff d0569d17 HEAD -- project native` empty). `riotc`, 6 interleaved pairs, CONTENDED(8-10), my two reels up too (`evidence/perf/n10-feed/aa/`).

| metric | old (per round) | new (per round) | median new - old | new lower in |
|---|---|---|---|---|
| frame p50 ms | 3.94 2.93 2.87 3.70 3.38 3.60 | 3.64 3.44 3.74 3.59 3.63 4.03 | +0.34 | 2 of 6 |
| rig p50 ms | 0.831 0.627 0.614 0.782 0.710 0.766 | 0.756 0.714 0.786 0.753 0.772 0.866 | +0.075 | 2 of 6 |
| sim step ms/tick | 0.135 0.108 0.108 0.126 0.122 0.124 | 0.124 0.119 0.126 0.123 0.124 0.133 | +0.006 | 2 of 6 |
| render CPU ms | 0.584 0.394 0.398 0.516 0.484 0.485 | 0.527 0.451 0.500 0.476 0.506 0.576 | +0.04 | 2 of 6 |

Identical code differs by up to +0.87 / -0.30 ms frame p50 in a single pair, and the median leans the same way the feed A/B did (rig p50 +0.075 here, +0.065 there). **So idea 1's result is inside the bench's floor at this load: not a measured gain and not a measured regression.** The revert stands because no gain was shown, not because the fill was shown slower. Six pairs under CONTENDED(0-10) cannot resolve a frame-p50 effect of about 0.3 ms or smaller; idea 2 below is smaller than that.
Item 3's claim (6 of 6, median -1.14 ms frame p50; rig p50 1.665 -> 0.957) is larger than any single A/A pair's difference (0.87 ms), so the A/A does not undo it, but item 3 was run before this control existed and it is still CONTENDED.

### Item 4 stops (it8): one wash, the next idea below this bench's floor
The stop rule (two washes in a row) was not reached: idea 1 was a wash and idea 2 was not built. The crowd occlusion scan is about 100 us in a debug build; the A/A above shows six contended pairs cannot see that. In the release riot at combo (`evidence/perf/n10-riotc/riotc-head@exe-2.json`, one CONTENDED run, avg frame 3.78 ms) the named shares are rig 0.85 ms per tick, blood 0.51 ms a frame, render CPU 0.48, render GPU 0.28, sim step 0.12. At least about 1.5 ms of the frame has no timer of its own in this bench (more if the render GPU time does not add to the CPU frame). Re-check on a quiet machine.

### Item 3 again (it10): CPU seconds, an instrument this machine's load barely moves
Wall-clock frame times swing with whoever else runs; the CPU seconds a process consumed do far less. `evidence/perf/n10-cputime/cpu_ab.ps1` runs the `riotc` release riot (combo, 400 actors, `--secs=30`, `--fixed-fps 60`, 1681 frames measured, about 8 s of wall time) and reads `GetProcessTimes` after exit, under `gtai-n10/bench.lock`, three arms in a rotating order: main 9bbe6d0a (`windows-bench-main`), head (`windows-bench`, export 00:47, code 40fab8c7), twin (`windows-bench-it6`, export 23:26, the same project and native code as the head: the A/A control). `analyse.py` gives paired medians, a 95 % bootstrap interval and a sign test. `r30/` = 30 rounds, 90 runs, 02:12-02:24, exit 0, 0 SCRIPT ERROR. **Not a quiet run:** other godot/RTAI processes before a run 0-8, median 2 (0 in only 12 of 90 runs; a reel counts as 2 processes), and my own 11 s scons and 15 s export ran during rounds 0-3.

| 30 rounds | main | head | twin | head - main (CI95), lower in | head - twin, the A/A (CI95) |
|---|---|---|---|---|---|
| CPU total s | 8.656 | 7.672 | 7.695 | **-0.914 (-1.062, -0.781), 30 of 30** | +0.031 (-0.102, +0.219), 13 of 30 |
| CPU user s | 7.344 | 6.344 | 6.445 | -0.883 (-1.008, -0.781), 30 of 30 | -0.086 (-0.227, +0.109), 18 of 30 |
| CPU kernel s | 1.430 | 1.422 | 1.398 | -0.039 (-0.086, +0.047), 18 of 30 | +0.102 (-0.023, +0.195), 11 of 30 |
| frame p50 ms | 3.079 | 2.620 | 2.623 | **-0.485 (-0.538, -0.427), 30 of 30** | +0.004 (-0.026, +0.027), 14 of 30 |

The release's own per-system timers, same 30 rounds (medians; each run's log, paired):

| timer | main | head | twin | head - main, lower in | head - twin, lower in |
|---|---|---|---|---|---|
| rig p50 ms | 0.969 | 0.586 | 0.583 | -0.391, 30 of 30 | +0.002, 14 of 30 |
| rig ms a tick | 1.004 | 0.621 | 0.621 | -0.389, 30 of 30 | +0.003, 14 of 30 |
| blood us a frame | 364.6 | 360.3 | 361.9 | -7.1, 19 of 30 | +1.0, 15 of 30 |
| sim step ms a tick | 0.102 | 0.101 | 0.101 | -0.001, 18 of 30 | 0.000, 15 of 30 |
| render CPU ms | 0.359 | 0.358 | 0.359 | -0.003, 17 of 30 | -0.001, 16 of 30 |
| p99 CPU ms | 5.79 | 5.11 | 4.97 | -0.587, 28 of 30 | +0.079, 9 of 30 |

So the rig timer (-0.391) carries most of the frame p50 gain (-0.485); the systems the change does not touch are flat, which is the sanity check the wall-clock runs could not give. **The brief's rig target holds in the shipped build at the riot's 400 actors: rig p50 0.586 ms, at most 1 ms.** main sits at 0.969, so main was already under 1 ms in release: the 1.1-1.4 ms the brief quoted is the debug rig bench at 50 people, a different instrument. The p99 CPU row is not a p99 claim (its A/A is +0.08 with 9 of 30 lower).

**Items 1 and 2 together cut the release riot at combo by 0.485 ms of frame p50 (-15.8 %) and 0.91 s of a run's CPU (-10.6 %), 30 of 30 rounds.** The A/A is inside its own interval on every metric, and the twin beats main by the same amount (p50 -0.444, 30 of 30), so an export's age is not what is being read. Sign test p = 2e-9. The CPU figure includes boot and load.
**This replaces item 3's -1.14 ms** (6 contended wall-clock pairs): the effect is real and less than half that size. The only rounds with no other process up for all three arms are 12 and 13 (`quiet_subset.py r30 0`): p50 -0.463 ms, CPU -0.96 s, lower in 2 of 2, too few to call a quiet A/B but the same size.
What the instrument resolves: the A/A's CI half-width is about 0.03 ms of frame p50 and 0.15 s of CPU at 30 rounds, ten times finer than six wall-clock pairs (about 0.3 ms). What it cannot do: p99 or worst frames (CPU seconds are a sum; the p50 is still a wall-clock statistic that merely stopped swinging at this load), and SMT or cache pressure from other processes still reaches a process's CPU time. The 6-round set beside it (`n10-cputime/riotc-*`, 02:06-02:09, others 6-10) read head - main -0.57 s, p50 -0.41 ms, 6 of 6.

### Item 4, idea 1 again (it10): the C++ feed fill, measured in CPU seconds: KEPT as the new baseline (ef31d9d4)
`4f153362` was reverted at it7 because six wall-clock pairs could not resolve it. The same code, re-applied and exported (`windows-bench-fill`), `cpu_ab.ps1 -ArmSpec head=windows-bench,fill=windows-bench-fill,twin=windows-bench-it6`, 24 rounds, 72 runs, 02:24-02:34, exit 0, 0 SCRIPT ERROR, `evidence/perf/n10-cputime/fill/`. head = the pre-fill export, twin = its A/A. **Not quiet:** others 4-14, median 7, more loaded than r30.

| 24 rounds | head | fill | twin | fill - head (CI95), lower in | twin - head, the A/A (CI95), lower in |
|---|---|---|---|---|---|
| CPU total s | 8.062 | 7.625 | 8.102 | **-0.633 (-0.734, -0.312), 22 of 24** | +0.086 (-0.062, +0.266), 11 of 24 |
| CPU user s | 6.570 | 6.109 | 6.578 | -0.477 (-0.672, -0.141), 18 of 24 | +0.008 (-0.195, +0.281), 12 of 24 |
| frame p50 ms | 2.724 | 2.537 | 2.762 | **-0.235 (-0.302, -0.174), 21 of 24** | +0.044 (+0.011, +0.087), 6 of 24 |

**A real gain: frame p50 -0.235 ms (-8.6 %), CPU -0.63 s.** fill - twin agrees (p50 -0.239 ms, 22 of 24). The A/A is not perfectly flat this time (twin - head p50 +0.044, its interval excludes 0, 6 of 24 lower); the fill's effect is about five times that. The riot was the same in every arm (actors 399.79, visible 288.51) and rig p50 (0.610 / 0.615 / 0.617), sim step and render CPU do not move, so what fell is outside those timers, where the fill sits. Draw calls moved by a hair (739.385 vs 739.355: about 50 draws over 1681 frames), a possible rounding difference in the facing; film compare below.
**The pixels:** the two release exports filmed side by side, 1200 frames at combo (`gtai-n10/tmp/perf/it10_film.sh`, logs and psnr in `evidence/perf/n10-cputime/film/`), ffmpeg psnr: **1192 of 1200 bit-identical at 32 px/m, 1199 of 1200 at 48**. The A/A of the same code differs in 4 frames at 32 (34, 36, 391, 1111). The A/B-only frames (32, 33, 35, 38, 39 at 32 px/m) lie in the opening frames' chunk streaming; four of them differ only in a strip at the screen's top or left edge, and frame 35, looked at (`gtai-masters/n10/perf/frame35-chunk-popin-before-vs-after.png`), has a chunk one arm has not drawn yet, the crowd unchanged. The 0.03 draws-a-frame difference is not attributed to anything measured.
So the micro's direction was right (about 350 us debug) and its size is about 235 us at the release frame, and **the it7 revert was a limit of the instrument, not the idea.** The script loop stays as the no-DLL fallback. Tests carried with the commit: `test_city_feed_rows` (native rows equal the script's); the gates on this head are recorded below when they finish. New baseline: every later idea compares against this export, `windows-bench-fill`.

### The riot on film (it9): what the cut changes on screen, with an A/A control
`evidence/perf/n10-film/`: `film.sh` (main 9bbe6d0a vs this head, city riot, `--view=combo`, 1200 frames at `--fixed-fps 60`, 1280x800, d3d12, debug editor binary, no HUD), `aa.sh` (the same code twice at 32 px/m), `cmp_frames.py`, `psnr*.log`, `ab_only_frames.json`. Instrument: ffmpeg psnr between the two MJPEG captures (a `mse_avg` of exactly 0 means every sample matched); both arms ran side by side, CONTENDED. Masters: `gtai-masters/n10/perf/`.

| 1200 frames | frames that differ | notes |
|---|---|---|
| A/B main vs head, 32 px/m | 48 | chunk pop-in plus the patch below |
| A/B main vs head, 48 px/m | 48 | not split by cause, no A/A at 48 |
| A/A head vs head, 32 px/m | 13 | frames 30-42, 391, 1111 (chunk pop-in) |
| A/A main vs main, 32 px/m | 2 | frames 391, 392 |

Most frames are bit-identical, so the riot at combo draws the same picture with the limbs cold. Of the 48 A/B frames at 32 px/m, 34 appear in neither A/A. 5 of those 34 show nothing a viewer could see (no pixel off by more than 24 in a channel, MSE at most 0.02). 3 are large patches (frames 34, 571, 572, below). **The other 26 are small patches on a figure, at most 40 x 31 px and 295 changed pixels: in 25 of them at least half the changed pixels are cream on main and at most 2 are cream on the head**, for 1-4 consecutive frames; the 26th (frame 137) is 7 non-cream pixels. Example crops: `blob-crop-frame605` and `frame473` in the masters. It is the cream "sticker rim" halo (`RigBuild`): on main the rig draws it under a whole-figure card with no limb over it; `a9370647` hides halos while `StreetWalkerCards.hides_parts`. Frames 34, 571 and 572 (571 is a band across the top edge, 25197 px; 34 spreads over 286 x 455 px) look like chunk streaming, but they were not seen in the A/A runs, so that reading rests on the patch's shape alone. The earlier "0 pixels differ" (`evidence/perf/n10-rig/framecmp`) is true of that one rig-stress frame and does not extend to the riot.

Instrument note: psnr's stats count `n` from 1 and ffmpeg's `select` from 0; a first pass here was off by one and read several real differences as identical.

## n9 night (2026-11-08, branch n9-perf from main da108c13)

### F19 quest-1 freeze: located in the engine (it1, 00:56-01:56)
Machine: the shared PC (RTX 4090 + an AMD iGPU), 2-4 other lanes' Godot processes up the whole time (CONTENDED: freeze
counts only, no timing claims). Windowed D3D12, the editor binary, `res://boot/quest1.tscn -- --autostart`, a run is
frozen when the process uses < 0.05 cores 12-15 s in (`evidence/perf/f19-freeze/hunt2.ps1`; a frozen run also reads
`Responding = false`). All under `evidence/perf/f19-freeze/`.

| step | what | frozen / runs | finding |
|---|---|---|---|
| trace1 | printerr around every main-thread wait in our GDScript (chunk take, save collect, threaded texture gets) + a 30-frame heartbeat (`trace.patch`) | 3 / 7 | every freeze right after Start (frame 0-29), NO traced wait open: not chunk_source / save_worker / load_threaded_get |
| trace3 | + crowd bake and prewarm traces, a per-frame heartbeat, RS frame_pre/post_draw | 2 / 8 | both stop at `CB> cap`: the main thread inside `CrowdBaker._capture` -> `_vp.get_texture().get_image()` |
| fix40 | CrowdReadback (async readback, 827aefe3; atlas md5 identical) | 2 / 4 | still freezes: not the fix (stopped early) |
| trace4 | async readback + traces | 2 / 6 | stops after `HB pf6` / `pf8`, no GDScript wait open: inside the engine's frame |
| nobake | crowd bake skipped (scratch hook) | 1 / 3 | the bake is not needed for the freeze |
| vulkan | `--rendering-driver vulkan` | n/a | crashes at boot in `amdxc64.dll` (the iGPU's driver): no Vulkan arm on this PC (`vulkan-boot-crash.log`) |
| rtsep | `--render-thread separate` | 3 / 8 | not a workaround |
| novsync | `--disable-vsync` (uncapped, ~1 core) | **0 / 8** | the first arm without a freeze (vsync arms ~1 in 3 over ~40 runs; 0 / 8 at p = 1/3 is ~4 % by chance): the freeze is tied to the vsync present path, or to its timing. Next: `--disable-vsync --max-fps 60` and the mailbox mode, to tell the two apart |
| novsync60 | `--disable-vsync --max-fps 60` (the same pacing and CPU as the vsync runs: 0.21-0.28 cores) | **0 / 8** | not timing: with vsync off, 0 of 16 froze across both arms, against ~1 in 3 with it on. The hang follows the D3D12 vsync present (`Present(1, 0)`): a present that never completes blocks the queue, and the next frame fence never signals. Candidate workaround (an owner Call: tearing): vsync off + the 60 fps limiter, or the mailbox mode (untested) |
| mailbox | vsync MAILBOX (`display/window/vsync/vsync_mode=3` via a temporary local override.cfg line, restored after) | **0 / 8** | still vsync-synced (`Present(1, DXGI_PRESENT_RESTART)`, no tearing) and no freeze: **the fix candidate**. Owed: the 40-run acceptance, pacing / CPU A/B vs Enabled, the release export, the real Start click |
| cdb | WinDbg's cdb attached non-invasively to each frozen run (`stacks-cdb-{2,4,6,8}.txt`) | 4 / 8 | **the same main-thread stack in all 4** (below) |
| mb40 (it2) | the fix committed: `display/window/vsync/vsync_mode.windows=3` (mailbox) in project.godot, 06c48c1b; 40 runs | **0 parked / 40**, 1 exited | 39 runs drew at 0.15-0.33 cores. Run 16 read 0 CPU but `thread_cpu.ps1` found **no thread at all** 1 s later (every real freeze kept ~30 waiting threads): the process was gone, with no crash output, at 01:58:48 while my unit run (`--import`) was rewriting this worktree's `.godot/`. hunt2 counted it as a freeze; it now records `exited` / `exitCode` / `kind` and only counts a live 0-CPU process |
| mb40b (it2) | the same commit, hunt2 with exit detection + cdb on any freeze, nothing else run from this worktree | **0 / 40** | 40 / 40 reached quest 1 (`started`), 0.16-0.34 cores, no exit, no freeze (02:09-02:21) |
| rel20 (it2) | the **release** `windows-slice` export of the same tree (`build/export/slice/RTAI-slice.exe`), a **real Start press** (`hunt2.ps1 -Exe ... -PressStart`: Alt tap + SetForegroundWindow + Enter on the focused Start; no `--autostart`) | **0 / 20** | 20 / 20 reached quest 1 (`started` from the log), 0.13-0.24 cores (`rel20.jsonl`, `rel-start-pressed.jpg`). The control arm (a release export on Enabled) ran in it10: 0 / 20, see "F19 it10" |

Frozen main thread (all 4): `ntdll!NtWaitForSingleObject` <- `KERNELBASE!WaitForSingleObjectEx` <- `+0x1389030` <-
`+0x32e7c60` <- `+0x32e8890` <- `+0x33816e0` <- main loop (offsets from the exe's only export, `NoHotPatch`; the official
build ships no PDB). Named from the static disassembly (`disasm-main-thread.txt`, `cdb -z` on the exe):
- `+0x1389030` = the D3D12 driver's **fence_wait**: `ID3D12Fence::SetEventOnCompletion` (vtable slot 9, `+0x48`) then
  `WaitForSingleObjectEx(event, INFINITE, FALSE)`;
- `+0x32e8890` = **`RenderingDevice::_begin_frame`** (references `Condition "!reset" is true.` / `_begin_frame` /
  `servers/rendering/rendering_devi...`); `+0x32e7c60`, called from it, is the per-frame stall that waits for the frame
  slot's fence (`_stall_for_frame`);
- `+0x33816e0` = `RenderingServerDefault::_draw` (`Prepare Render Frame`).

So the freeze is **`_begin_frame` waiting forever for an earlier frame's GPU fence**: the GPU never finishes that frame.
Every other thread is idle (16 WorkerThreadPool threads, D3D12Core's 4 background threads and the NVIDIA driver threads
all in plain waits), so no CPU thread holds it up. The device is not removed (a removed device signals its fences to
UINT64_MAX and the wait would return). Most likely the frame's submission waits on the GPU queue for a semaphore that is
never signalled. Prime suspect: the RenderingDevice texture-upload transfer workers, whose semaphores the frame
submission waits on, at the first frames after Start when the quest's view, fonts and atlases upload. Synchronous
readbacks (`get_image`) hit the same wait first, which is why trace3 caught it there. A game-script fix cannot reach it.
Owed: confirm the semaphore (cdb on the queue's fences, or a 4.7.2 debug template with symbols), then an engine patch
or a script workaround that keeps texture uploads out of the first frames.

### F19 fix (it2, 01:52-): mailbox vsync on Windows
- **Shipped:** `display/window/vsync/vsync_mode.windows=3` (VSYNC_MAILBOX on Windows only; Linux / the Deck keep their
  rows' own vsync). On D3D12 mailbox is `Present(1, DXGI_PRESENT_RESTART)`: still one present per vblank, no tearing,
  the same 0.15-0.33 cores in quest 1 as Enabled (mb40). Checked live (a scratch probe, deleted): the window reports
  mode 3. `test_frame_cap.test_windows_boots_in_mailbox_vsync` pins it (on the old tree the key is absent: -1 != 3).
- **Counts:** Enabled ~2 in 5 (it1, counted from the jsonl files: 17 of 41 runs at 0 CPU (trace1 4/8, trace3 2/8,
  fix40 2/4, nobake 1/3, rtsep 3/8, cdb 4/8, hunt 1/2), plus trace4 2/6 from its logs: 19 / 47). Mailbox:
  **0 parked-fence freezes in 107 valid runs** (it1 8, mb40 39 + 1 exited, mb40b 40, rel20 20): the acceptance
  (0 in 40 windowed `--autostart` runs) is met twice, plus the release build with a real Start press. Even at 1 in 4,
  0 / 107 by chance is ~4e-14. CONTENDED throughout (other lanes' Godots up): counts only.
- **Why mailbox avoids it** (source read, `drivers/d3d12/rendering_device_driver_d3d12.cpp` `swap_chain_resize`):
  Enabled = `Present(1, 0)`, mailbox = `Present(1, DXGI_PRESENT_RESTART)`; both wait for vblank, the only difference
  is RESTART dropping any queued present instead of queuing behind it. So the hang needs a queued present: a frame
  submitted behind a present that the compositor never retires leaves that frame's fence unsignalled and
  `_begin_frame` waits forever. A hypothesis from the source + the counts, not a driver-level proof.
- **Release + real Start:** `--autostart` is debug-only (`quest1_card.gd`), so rel20 presses Start for real
  (`-PressStart`: an Alt tap lets the background shell SetForegroundWindow, then Enter on the focused Start). Two
  first tries failed: hunt2 hid the exported exe's own window (`-WindowStyle Hidden` only hides the console wrapper
  of the editor binary). hunt2 now classifies each run `ok` / `idle` (title still up, the press missed) / `frozen`
  (0 CPU, not responding) / `exited`.
- **The engine bug stays upstream-worthy:** a frame fence never signalled after a `Present(1, 0)` on this PC (RTX 4090
  driver, a hybrid AMD iGPU) is a driver or engine bug; mailbox avoids it. Owner Call: keep mailbox (default) or Enabled.

### F19 it10 (08:27-08:54): the old code freezes in the editor binary, not in the exported builds
The brief asked whether the real Start click and the release export freeze too. rel20 (it2) answered it only on the
fix. it10 ran the control arms on **main da108c13 (vsync Enabled, no fix)**, all with a real Start press
(`hunt2.ps1 -PressStart`: Alt tap + SetForegroundWindow + Enter on the focused Start, no `--autostart`), windowed
D3D12 1920x1080, 20 runs an arm, cdb on any freeze (`F19_CDB=1`), CONTENDED (5-6 Godot processes in tasklist incl. this run's; handheld's
E20b bench held bench.lock; counts only, no timing claims). `evidence/perf/f19-freeze/{relmain,edpress,dbgpress}.jsonl`:

| arm (main da108c13, vsync Enabled, real Start press) | binary | frozen / runs |
|---|---|---|
| relmain: `windows-slice` **release** export (`--export-release`, 326 MB exe, pck embedded) | template_release | **0 / 20** |
| dbgpress: `windows-slice` **debug** export (`--export-debug`) | template_debug | **0 / 20** |
| edpress: the **editor binary** on main's project (`-Project <prof3>/project`, new hunt2 switch) | editor (tools) | **5 / 20** (runs 2, 4, 8, 12, 20) |
| (it1, for reference) the editor binary, `--autostart` | editor (tools) | 19 / 47 |

- **The real Start press freezes too** (5 / 20 in the editor binary): `--autostart` is not the trigger.
- **Neither exported build froze: 0 / 40**, against 5 / 20 in the editor binary (Fisher one-sided p = 0.003; release
  alone 0 / 20 vs 5 / 20: p = 0.024). The freeze follows the editor (tools) binary running the project from its
  `res://` files, not the export templates. What differs is not measured: the editor binary reads every texture from
  `.godot/imported/*.ctex` files instead of one pck, and carries the tools build's extra work, so the uploads that
  race the present land at different moments. 0 / 40 is not proof of 0: the 95 % upper bound on the exported builds'
  rate is ~7 % a run.
- **The stacks** (`stacks-edpress-{2,4,8,12,20}.txt`, all five the same): `WaitForSingleObjectEx` <- fence_wait
  `+0x138905b` <- `_stall_for_frame` `+0x32e80c5` <- `+0x32e95ed` <- `+0x32f0670` <- `+0x35be1c6` <- ... 22 frames down
  through the script call path. it1's four `--autostart` stacks went `_stall_for_frame` <- `_begin_frame`
  (`+0x32e8c77`) <- `RenderingServerDefault::_draw`; these reach the same stall from a synchronous call made by script
  (trace3 caught the crowd bake's `get_image` readback as the first wait after Start). The same root, a GPU fence that
  is never signalled, caught at a different first wait.
- **What it changes:** players of the shipped build were most likely never hit (0 / 40 exported), so mailbox's cost
  (a skipped tick image under load, ~5 per 30 s on a loaded machine; LEDGER "Pacing A/B") is paid by every Windows
  player for a hang seen in the editor binary. Kept as built (DECISION perf/f19-mailbox-scope): a fatal hang that a
  20-run sample cannot exclude outweighs a rare skipped image, and steady pacing removes that for +0.08 core. The
  alternative goes to the owner (Call P-1): mailbox in editor runs only (`vsync_mode.editor=3` instead of
  `vsync_mode.windows=3`; probed at 08:59 in the editor binary: `editor=true`, the window boots in mode 3; the export
  side rests on the docs, as templates carry no `editor` tag; a `-s` probe in a debug export printed nothing, so it is
  not run-verified: `evidence/perf/f19-freeze/scope-probe/`) and Enabled for players.

### World's REQUEST (it2): the card rigs under combo
world (it1): rig_stress p50 at 50 people, combo 1.1-1.4 ms vs top 0.5-0.76 (section 20's provisional 1 ms). Profile
(scratch timers in `CutRig.drive` / `CharacterRigs.step_ticks` in a throwaway worktree of 06c48c1b, 50 people,
600 ticks, top / combo / top / combo, CONTENDED; `evidence/perf/n9-rig-combo/prof.txt`, the patch `prof.patch`):

| us per tick | top | combo |
|---|---|---|
| rig p50 (ms) | 0.81 / 0.72 | **1.26 / 1.21** |
| pose steps | 4800 | 5184 (+8 %: the cards' t_alive == 0 re-drive) |
| clips + springs + hips + gait | 277 / 235 | 325 / 306 |
| RigPose.step | 422 / 359 | 435 / 416 |
| RigTilt.lift_upper | - | 20 / 20 |
| **RigHeadCard.step** | - | **137 / 91** |
| **StreetView.step** (shield, crowd cards, walker cards, Rivet frames) | - | **347 / 233** |
| assign + RigDetail.sync | 118 / 85 | 95 / 93 |

So combo's extra ~0.45-0.5 ms a tick is StreetView.step (~0.23-0.35) + RigHeadCard.step (~0.09-0.14) + the extra
pose steps; the cut rig's own posing is unchanged. And under cards the drawn card shows the figure while the cut rig
still runs its full pose (clips, springs, gait, RigPose: ~0.7 ms) underneath. Levers for it3 (in characters' files,
so REQUESTs with these numbers): (a) break StreetView.step down per card kind and cut its per-tick work (dirty
flags: re-place a card only when its frame or facing changed); (b) skip RigPose for rigs whose parts a card hides
(if the walk phase comes from RigGait alone).

### World's REQUEST, part 2 (it3): StreetView.step per card kind
Hypothesis: combo's extra rig cost sits in one card kind's per-tick work that a dirty flag removes. Scratch timers
(`evidence/perf/n9-rig-combo/prof3.patch`, a throwaway worktree of 54de9b41, 50 people, 600 ticks, combo only;
CONTENDED: my 3 director reels were running). Warm runs (the first run of a process includes the strip loads):

| us per tick (combo) | warm run 1 | warm run 2 |
|---|---|---|
| RiotShieldCard.step | 13 | 16 |
| StreetCrowdCards.step | 12 | 15 |
| **StreetWalkerCards.step** | **157** | **206** |
| - strip_of (row_of + key_of string formats, StreetCopWalk / Fall lookups) | 57 | 75 |
| - re-hiding the hidden parts each tick (hide_all) | 26 | 32 |
| - place (fill_of strings + 3 global setters), ~7.6 cards a tick | 58 | 80 |
| RivetFrames.step | 31 | 39 |
| RigHeadCard._place (rows()[_key] format + global setters) | 66 | 88 |

Prototype (same scratch tree, ABABAB, opt = per-texture fill cache + one `global_transform` set + `street_row`
read before `key_of`): walker place **59 / 66 / 59 vs 81 / 80 / 113 us** (about -20 us a tick), strip_of
unchanged (77-87 vs 75-134, noise). Result: **a wash for the budget**: -20 to -30 us of combo's ~450 us extra (~5 %).
The cost is spread over many small GDScript calls (string formats, meta reads, the `global_*` setters) on every
rig; no single card kind holds it. Skipping RigPose under a whole-figure card saves at most the carded rigs' share
(~8 of 50 here, ~65 us). The real lever is structural (cards placed by one batched pass, or the card placement in
the native sim); not for tonight. The patch for the place() cut is `walker-place.patch` (world owns
street_walker_cards.gd tonight), offered, not required. Not kept on this branch (not my file).

### Pacing A/B on the mailbox default (it3): vsync Enabled vs mailbox vs mailbox + steady
Hypothesis: mailbox (the F-19 fix) could run the loop uncapped at 60 Hz (no queued present to block on) and cost
CPU, or pace worse (a restart drops a queued image); steady (the 60 fps limiter on top) should hold the cadence at
L11's ~+0.07 core. `node tools/perf/ab.mjs --scenes=riot60 --pairs=3 --arms=enab:--vsync=enabled,mbox:--vsync=mailbox,
mbox60:--vsync=mailbox --max-fps=60` (editor binary, windowed D3D12 1920x1080, real time, 60 Hz panel; bench.lock
held by ab.mjs; 02:57-03:03; CONTENDED 2 / 3 enab, 2 / 3 mbox, 1 / 3 mbox60; 0 errors). `evidence/perf/n9-pacing/`.

| riot60, median of 3 (spread) | Enabled (old default, efficient) | **mailbox (new default, efficient)** | mailbox + 60 limiter (steady) |
|---|---|---|---|
| frames in 30 s | 1682 | 1682 (not uncapped: mailbox blocks at 60 Hz too) | 1679 |
| process CPU (cores) | 0.41 ±0.03 | 0.40 ±0.03 (WASH) | 0.49 ±0.02 (+0.08, the limiter's spin, L11 / L15) |
| frame p99 (ms) | 22.5 ±4.2 | 26.9 ±5.6 (WASH) | **18.6 ±1.5** |
| worst frame (ms) | 33.9 | 36.3 | 24.4 |
| tick images skipped (noTick / multiTick) per round | 0/2, 0/2, 0/2 | **13/14, 0/2, 10/12** | 0/0, 0/0, 1/3 |
| working set (MB) | 900 | 846 (WASH, ±33) | 866 |

Reading: mailbox costs nothing in CPU or frame count at 60 Hz, and its uncontended round (r1) paced like Enabled;
in its two CONTENDED(4) rounds it showed 10-13 frames that carried no tick and 12-14 that carried two (a dropped
or doubled tick image: a visible hitch), where Enabled under the same contention showed 0 / 2. Plausible mechanism:
DXGI_PRESENT_RESTART discards the queued image after a late frame, so the sim's cadence and the presented one slip
for a frame. **Small sample (2 contended rounds a side): a signal, not a verdict.** Steady on top of mailbox holds
the cadence (multiTick 0-3, best p99) for +0.08 core. So the F-19 trade is now: mailbox (no D3D12 fence hang, 0 in
107 runs) with an occasional dropped tick image on a loaded machine, unless the player picks steady. Kept as built
(the freeze is worse than a hitch); added to Call P-1 (mailbox default) for the owner, with "steady by default on
Windows" as the one-value alternative (`PlayerSettings` default pacing).

Second run (`evidence/perf/n9-pacing2/`, drive60 + riot60, enab vs mbox, 3 pairs, bench.lock, 03:15-03:22, CONTENDED
in 5-6 of 6 runs per arm): CPU WASH again (drive 0.33 vs 0.29, riot 0.47 vs 0.45); p99 mixed (drive 22.2 vs 23.9 WASH,
riot 27.1 vs **20.9** mbox WIN). Frames that carried no tick per round: drive enab 0 / 0 / 2 vs **mbox 1 / 7 / 14**;
riot enab 1 / 3 / 0 vs mbox 0 / 0 / 6. **Pooled over both runs (9 rounds an arm): no-tick frames Enabled 6, mailbox
51**, mailbox + steady 1 (3 rounds). So the signal holds: on a loaded machine mailbox skips a tick image ~5 times
per 30 s (median), Enabled ~0, at the same CPU; the frame-time tail itself is not worse. Kept as built (Enabled is
the F-19 freeze); steady fixes it for +0.08 core; the owner chooses the Windows default pacing (Call P-1 / P-3).

### Item 4 (it3): the desktop table on world's BC7 (main da108c13 vs n9-world 746c2856)
world's 3e02d3b8 (BC7 for the drawn art, combo default, bikes 6 %) + its it2-it7 commits, vs main. Scratch worktrees
(`gtai-n9/tmp/perf/prof3` = main, `world3` = world's committed tree with its `.godot` imports copied, main's native DLLs:
world's bin DLL carries its uncommitted knock sim). `node tools/perf/ab.mjs --scenes=king,drive70,riot --pairs=3
--arms=main:^--path <prof3>/project,world:^--path <world3>/project` (editor binary, windowed D3D12 1920x1080,
`--fixed-fps 60 --disable-vsync`: one tick a frame, as fast as it can; bench.lock held; 03:06-03:11; CONTENDED 1-2 of
3 per arm; 0 errors). `evidence/perf/n9-bc7-table/`. Median of 3 (spread):

| scene | metric | main (lossless) | world (BC7) | verdict |
|---|---|---|---|---|
| King under combo | p50 / p99 / p99.9 ms | 4.51 / 9.44 / 12.31 | 4.74 / 9.15 / 11.86 | WASH (spread 0.6 / 1.4 / 1.5) |
| King | process CPU, working set | 1.03 cores, 801 MB (±49) | 1.01, **733 MB (±4)** | RAM -68 MB (WASH by the spread rule: main's spread 49) |
| drive70 (drive_dense, 48 px/m) | p50 / p99 / p99.9 ms | 3.04 / 5.58 / 8.38 | 2.62 / **5.14** / 7.41 | p99 WIN -8 % (spreads 0.03 / 0.07), the rest WASH |
| drive70 | GPU ms, VRAM, working set | 0.24, **900 MB**, 839 MB | 0.21, **548 MB**, 840 MB | **VRAM -352 MB (-39 %)**, GPU -0.03 ms WIN, RAM WASH |
| riot (400 actors, 32 px/m) | p50 / p99 / p99.9 ms | 4.91 / 10.85 / 19.69 | 4.72 / 10.52 / 16.67 | WASH |
| riot | VRAM, working set (steady / last) | **899 MB**, 911 / 911 MB | **536 MB**, 835 / 789 MB | **VRAM -362 MB (-40 %)** (world's own A/B: -361), RAM WASH by spread |
| riot | draws | 734 | 736 (+2: the bikes) | not a cost |

(The King's VRAM reads NaN: the arena's FightFrames log has no VRAM field; its working set carries the signal.)
So BC7 is what L4 predicted: VRAM -350..-360 MB on the city scenes with no frame-time cost; the 128 MB traffic-sheet
upload buffer is a 32 MB one (Item 2). Resident RAM moves less than the estimated -96 MB on the desktop (the
working set includes the driver's mapped copy; within the spread). handheld's E16 owns the Deck row.

### L16 (it3): the engine's delta smoothing for mailbox (FrameDeltaSmoother)
Source (Godot 4.7.2 `main/main_timer_sync.cpp`, `DeltaSmoother::smooth_delta`, lines 264-266): "only attempt
smoothing if vsync is selected": `if (vsync_mode != VSYNC_ENABLED) return p_delta;`. So under the mailbox default the
engine hands `World._process` the raw, load-jittered delta, and `SimClock.advance` steps 0 or 2 ticks in some frames:
the mechanism of the pacing A/B's no-tick frames. Hypothesis: the engine's own rule (snap the delta to whole display
intervals, carry the remainder, pass hitches raw) applied in `World._smoothed` under mailbox brings the no-tick
frames back to Enabled's ~0, with no CPU and no pixel (fixed-fps, headless, movie and replay runs never arm it).
Built: `core/clock/frame_delta_smoother.gd` (FrameDeltaSmoother: TOLERANCE 0.35 interval, LONG_S 1 s), `World._smoothed`
(armed only with `--delta-smooth=on`, windowed, not filming, vsync mode MAILBOX; interval = 1 / min(refresh, max_fps)),
`test_frame_delta_smoother` (6; `test_raw_jittered_frames_skip_ticks` shows the raw deltas give 0 / 2-tick frames,
`test_jittered_frames_step_one_tick_each` that the smoothed ones give exactly one). Commit 36234341, default OFF.
A/B (`evidence/perf/n9-dsmooth/`, drive60, `mbox:--vsync=mailbox` vs `smooth:--vsync=mailbox --delta-smooth=on`,
3 pairs, bench.lock, 03:30-03:35, CONTENDED(2) in 6 / 6, my own pre-commit unit run overlapped r1-r2):
no-tick frames mbox 7 / 3 / 1 vs **smooth 2 / 0 / 1**, double-tick 8 / 6 / 2 vs 5 / 2 / 4; CPU 0.28 vs 0.25 (WASH),
p99 23.6 vs 24.7 (WASH). **Direction right, inside the noise (medians 3 vs 1, spread 3): not claimed.** Not yet
proven armed in the bench (no log line). Next: a Log line when armed, then 6+ pairs on a quieter machine, riot60 too;
keep if no-tick frames reach Enabled's level, then default on (still pixel-free: only which frame a tick lands on).

**A/B 2 (it4, `evidence/perf/n9-dsmooth2/`):** drive60 + riot60, arms `enab:--vsync=enabled`, `mbox:--vsync=mailbox`,
`smooth:--vsync=mailbox --delta-smooth=on`, 4 pairs (ABC interleaved), bench.lock held by ab.mjs, 03:44-03:59, CONTENDED
in 2-4 of 4 rounds per arm, 0 errors. Frames that carried no tick, per round:

| scene | Enabled | mailbox | mailbox + smoothing |
|---|---|---|---|
| drive60 | 0 / 0 / 0 / 0 | 17 / 12 / 1 / 0 | 2 / 2 / 3 / 0 |
| riot60 | 1 / 1 / 2 / 0 | 11 / 13 / 3 / 0 | 4 / 0 / 0 / 0 |
| pooled (8 rounds) | **4** | **57** | **11** (-81 % vs mailbox) |
| CPU, median (spread) | drive 0.30 (0.04), riot 0.44 (0.05) | 0.27 (0.01), 0.46 (0.04) | 0.35 (0.08), 0.45 (0.03): WASH |
| p99 ms, median (spread) | 24.5 (3.7), 24.1 (2.0) | 26.6 (4.8), 27.2 (4.7) | 25.9 (4.1), 26.7 (3.8): WASH |

Smoothing beats plain mailbox in 5 pairs, loses 1 (drive r2: 3 vs 1), ties 2 (both 0); with it3's 3 pairs, 7 / 1 / 3.
Per-round spreads overlap (mailbox's own spread is 6-9 frames, it swings with the contention), so ab.mjs calls it WASH;
the pooled count and the pair signs agree, and the mechanism is the engine's own rule for Enabled. Not past the noise
on the per-round median; flipped to the default (7852a8d4) on the pooled count (pixel-free: only which frame a tick lands on),
with the confirmation A/B (`n9-dsmooth3`, off vs the default, on the commit) as the keep-or-drop.
**Confirmation A/B 3 (`evidence/perf/n9-dsmooth3/`, on 7852a8d4, `off:--vsync=mailbox --delta-smooth=off` vs `on:--vsync=mailbox`,
drive60 + riot60, 4 pairs, bench.lock, 04:06-04:16, CONTENDED in 2-4 of 4 rounds per arm, 0 errors):** no-tick frames
drive off 7 / 0 / 0 / 2 vs on **37** / 0 / 2 / 0 (the 37 is a round with a 122 ms stall and 1661 frames: under heavy
contention the deltas leave the tolerance and pass raw), riot off 1 / 0 / 0 / 1 vs on 0 / 0 / 0 / 0; CPU 0.31 vs 0.30,
0.42 vs 0.41 (WASH); riot p99 20.9 vs 19.9 (spreads 1.1 / 0.3, a hint only).
**Verdict over the three A/Bs (19 pairs mailbox vs smoothing): smoothing fewer no-tick frames in 10, more in 3, tied in 6;
pooled 79 vs 53.** A sign test of 10 / 3 is p ~0.09: inside the noise. **DROPPED as a default** (back to `--delta-smooth=on`
as the arm, the commit after 7852a8d4); the `--fixed-fps` guard stays (it keeps the arm out of the goldens). Lesson:
this machine's contention swings mailbox's no-tick count from 0 to 17 per round; a pacing lever needs a quiet machine
or 10+ pairs, not 4.
Caught before the flip: World armed it in ANY windowed mailbox run, including `--fixed-fps` ones (the selftest's look
goldens): a fixed 16.667 ms delta snapped to the 59.94 Hz interval (16.683) would add a sim tick every ~1000 frames.
7852a8d4 arms it only in a real-time window (`LaunchArgs.engine_fixed_fps()`), `test_fixed_fps_is_never_real_time`.

### CityView._process per call (it5): where the riot's 3.4 ms goes
Scratch timers (`evidence/perf/n9-l17/cvprof.patch`, never committed; the rig internals are `n9-rig-combo/prof.patch`),
city_bench windowed d3d12, vsync off, `--fixed-fps 60` (1826 frames = one tick a frame), 6342fcd0, CONTENDED (1-3 other
Godots). Mean us a frame:

| call | riot (tilt70, zoom 1.0) | drive_dense (tilt70, zoom 1.5) |
|---|---|---|
| CityView._process total | 2450-3000 | 1171 |
| before_render (CityCharacters) | 2134-2587 | 987 |
| . rigs.step_ticks (10 full drives a tick) | 1407-1796 | 804 |
| . . gait+ / pose / street / headcard / lift / assign | 324 / 434 / 412 / 113 / 23 / 132 | 218 / 304 / 189 / 98 / 16 / 75 |
| . _fill_feed | 494-569 | 156 |
| . . snapshot / fx_feed.observe / variants | 20 / 125 / 5 | 19 / 71 / 5 |
| . . the loop (5653 floats = ~400 records; **262 rows put a tick**) | 387, of which _put_person 305 (1.2 us a row) | |
| . crowd.observe | 127-149 | 9 |
| _place_camera | 209-275 | 43 |
| . **fx.ground.step** (FxPool: the ground marks) | **127-157** | 2 |
| . fx.step / glow.step | 37-47 / 7-9 | 4 / 2 |
| chunks.update | 85-104 | 122 |
| write_render | 16-25 | 13 |

Reading: the rig step is ~60 % and is spread over dense GDScript math (RigPose / RigArm / RigGait / StreetView: no
allocation or lookup to strip; the cut is a C++ port of the pose step, a multi-session job and the rivet lane's rig
files tonight). The feed is per-row call cost over 262 rows. The one pure-waste item: **FxPool.step re-reads ~14
String-keyed Dictionary values a live particle a tick** (the ground pool holds the riot's casings and ink splats,
90 / 240-tick lives): L17.

### L17 (it5): FxPool reads a cached FxKindRow, not the kind Dictionary
Hypothesis: the ground pool's per-particle cost is the Dictionary lookups (String keys hashed every read), not the
MultiMesh writes; caching the kind's constants once at put cuts fx.ground.step ~40-60 % (-50..-80 us a riot frame,
~1-2 % of the frame: a mechanism win, below the frame-level noise, the L5 precedent). No pixel: the same values and
float ops (`test_fx_pool`: the MultiMesh buffer bit-identical to the verbatim old step over 260 ticks of every kind).
Change: `core/render/fx_kind_row.gd` (new), `fx_pool.gd` (`row_of` replaces `kind_of`; a spawn's `count` particles
share one row). Commit 4b7c1e44.
A/B (scratch timers in `cvprof`, riot tilt70 windowed, fixed 60, arms interleaved by swapping fx_pool.gd, two jobs,
CONTENDED 0-4 other Godots; `evidence/perf/n9-l17/ab-l17.txt`, `ab-l17b.txt`), fx.ground.step us a frame:

| arm | job 1 (3 rounds) | job 2 (3 rounds) | median of all |
|---|---|---|---|
| old (6342fcd0) | 135 / 152 / 135 | 129 / 159 / 145 | **140** |
| L17 (row cache) | 107 / 86 / 97 | 104 / 85 / 101 | **99 (-29 %)**: every L17 round under every old round |
| L17b (+ skip the rewrite of a held particle) | | 111 / 123 / 112 | 112: worse than L17 |

fx + glow (the other two pools) 44-53 -> 31-42 us. **L17 KEPT** (mechanism WIN, -40 us a riot frame; no frame-level
claim: the frame total's spread is ~0.5 ms). **L17b DROPPED** (9944fd7d): the riot's ground pool is mostly moving
casings, so the held check costs more than the skipped writes save.
Test lesson (FRICTION it5): the first test compared `MultiMesh.buffer`, which is EMPTY headless (the dummy renderer
keeps no instance data): the mutation run scored 27 % (`mutate-fx_pool.txt`). `FxPool.mirror` (sized by tests only;
one `is_empty()` a write in the game) now carries what each slot shows; the test compares that.

### L18 (it5): CityResidency.resident_keys() sorted once a change
Found reading ChunkView.update (85-122 us a frame): `resident_keys()` returns `_sorted(_resident.keys())`, a
`sort_custom` with a GDScript lambda over ~70 keys, on every call: ChunkView every frame (`_nearest_undrawn`),
`CityResidency.update` every tick, city_system, the prop lights, the noir lamps and shadows. Hypothesis: the sort is
most of chunks.update's steady cost; cached until adopt / evict / drop, chunks.update falls ~50 %+ on the drive. No
pixel and no sim change: the order is a total order on unique keys, so the cached array is the array a fresh sort
returns (test: row order, the same object until a change, rebuilt on evict / drop / adopt; read only, so no caller can
reorder it). Commit 73f30553.
A/B (cvprof timers, drive_dense tilt70 zoom 1.5, fixed 60, interleaved by swapping city_residency.gd, CONTENDED 3-6
other Godots; `evidence/perf/n9-l17/ab-l18.txt`): chunks.update old 122.4 / 117.9 / 124.9 us vs new 115.6 / 113.7 /
107.4: median 122.4 -> 113.7 (-7 %, -9 us a frame; every new round under every old round). Smaller than hoped: the
sort was ~5-10 us a call, chunks.update's steady cost is the time-sliced chunk build itself (`_slice`, real work while
driving). Plus the per-tick `CityResidency.update` sort (not under these timers). **KEPT** as a small CPU cut (no
pixel, no sim change); no frame claim.

### L19 (it5, refuted before building): copy-on-write in `feed.looks[i] = v`
Hypothesis: `_put_person` writes `feed.looks / face / flags / aim[i]` through another object's packed-array property;
if GDScript does that as get -> copy-on-write -> set-back, each write copies the whole array (262 rows x 3-4 writes a
riot tick). Microbench (`evidence/perf/n9-l17/cow_bench.gd.txt`, headless, 200 x 262 rows, capacity 64 / 512 / 4096):
4 writes through the property 0.129 / 0.130 / 0.135 us a row vs the same 4 writes in a method of the owner 0.120 /
0.117 / 0.112: **no copy** (the cost does not grow with capacity). Refuted; nothing built. The feed's 1.2 us a row is
GDScript call and arithmetic cost, the lever there is native (a sim-side feed fill), not GDScript reshaping.

### L20 (it5): CityOccluders scans packed building positions
Split (cvprof timers, riot, CONTENDED 6): city_occlusion._process 1085 us a frame = the per-rig building query
(`near` -> `collect`) **883**, crowd patches + lift 124, the rig walk 70. collect() read `b.at` off every Bld object of
1-4 chunks (~300 buildings a chunk) for each of ~17 rigs, every frame, to keep those inside a 40 m box. Hypothesis: the
object property reads dominate; a per-chunk PackedVector2Array of the positions (list order, built with the cached
list, cleared with it) scanned instead, a Bld touched only on a hit: -30..-50 % of `near`. No pixel: the same loop
order and the same float32 compares, so the same buildings in the same order (test: `collect` == the reach rule over
`of_chunk`, 40 queries over a 300-building chunk, compared by identity and order; survives the CACHE_MAX reset).
A/B (riot x2 interleaved by swapping city_occluders.gd, CONTENDED 4-6; `evidence/perf/n9-l17/ab-l20.txt`): near old
705 / 652 us vs new 542 / 543 (**-17..-23 %**, ranges apart); occlusion _process 853 / 795 -> 679 / 680 (**~-150 us a
riot frame**). KEPT (mechanism win; the frame total's spread is larger, no frame claim). Next (L20b): the 40 m box is
far looser than what _scan keeps (a building whose drawn area meets a ~1 x 1.8 m body patch): an exact tighter
prefilter could cut most of the remaining ~540 us.

### Gates (it5) on 78e039b7 (L17 + L18)
`node tools/evidence/run.mjs --no-bench` (`evidence/perf/n9-l17/evidence-it5.txt`): lint 15 / 15, unit 1833 / 0,
scenarios 54 / 54, parity bit-exact (mutation caught at 629), selftest look goldens 11 / 11 (worst 0.27),
release-compile 617 / 0. Mutation on fx_pool.gd at 9944fd7d: 90.9 % (10 / 11; the survivor deletes the
RenderingServer call, invisible headless by construction; `mutate-fx_pool-2.txt`).
On 28d8c8f7 (+ L20; `evidence-it5b.txt`): lint, scenarios 54 / 54, parity exact, look goldens 11 / 11 (worst 0.27),
release-compile 617 / 0 PASS; unit 1835 / 0 passed but the stage is marked FAIL by the tree-changed guard (I edited
JOURNAL / REPORT during the run): owed, a clean re-run. L20 on the drive: 3432 body-frames hidden, 5154 crowd patches,
the same as before it.

### L20b (it6): near() keeps only the buildings that can meet the body box
Hypothesis (before building): `_scan` keeps a building only when `body_patch` (the body box grown by the ink line,
intersected with the drawn area) has area. The drawn area shares the ground rect's x-span and bottom (the lift only
raises its top), so a building whose rect does not overlap the box's x-span, or whose ground line is above the box's
top, has no patch at any lift. Filtering those inside `collect` (read off a packed (left, right, bottom) float32
triple per building, built with the cached list) skips `_with_area` + the append + the `body_patch` call for most of
the ~1200 buildings a rig's 4 chunks hold: expected near 540 -> ~150-250 us a riot frame. Exact: the box is grown one
more pixel, float32 values compared in float64, so only zero-area patches are dropped.
Change (6496dbdb): `CityOccluders.near(at_m, body)` / `collect(..., body)`; `CityOcclusion.body_box` (body_patch now
`body_box(...).intersection(area)`); `merge_extra` moved to CityOccluders to keep city_occlusion.gd under 200 lines.
Test (`test_city_occluders`): per body, the buildings with a patch from the filtered query == those from the
unfiltered query, in order, 60 positions + 120 at building edges (touching and +-0.5 px), at tilt70 and at 55 (combo's
taller lift); asserts > 50 patches and > 1000 skipped (not vacuous). 3 planted faults (each edge moved 8 px) caught.
A/B (cvprof timers, L20 vs L20b, 3 interleaved pairs per scene, CONTENDED 0-8 other Godots;
`evidence/perf/n9-it6/l20/ab-l20b.txt`):

| scene | near L20 (us/frame) | near L20b | median | occlusion _process L20 -> L20b |
|---|---|---|---|---|
| riot (tilt70, 17 rigs) | 548 / 652 / 543 | 258 / 241 / 253 | **548 -> 253 (-54 %)** | 686 / 818 / 678 -> 410 / - / 401 |
| drive_dense (tilt70, 9 rigs) | 543 / 719 / 541 | 206 / 193 / 233 | **543 -> 206 (-62 %)** | 700 / - / 698 -> 362 / - / 404 |

Behaviour: drive 3432 hidden body-frames and 5154 crowd patches in every run, riot 0 / 11669 (= L20). KEPT.

### L20c (it6): a column index per chunk
Hypothesis: after L20b each rig still walks ~1200 packed entries (~15 us a rig). Index each chunk's buildings by
128 px screen column (a building under every column its rect's x-span touches); the body box (~80 px wide) reads one
or two columns, merged ascending and deduplicated, then the same exact tests run. Exact: a building that passes the
x test shares a column with the box (floor is monotone, the same float32 values). Expected near -40..-60 %.
Change (700712c7): `CityOccluderCols` (new file), built in `of_chunk`, cleared with the cache. Test: a box over 1-6
columns returns exactly the rule's buildings once each in list order (3 planted faults caught: the column span, the
dedupe, the column range). A/B (L20b vs L20c, 3 pairs, CONTENDED 0-8; `ab-l20c.txt`):

| scene | near L20b | near L20c | median |
|---|---|---|---|
| riot | 231 / 251 / 246 | 124 / 129 / 138 | **246 -> 129 (-48 %)**, ranges apart |
| drive_dense | 212 / 205 / 224 | 184 / 203 / 209 | 212 -> 203: WASH |

Same counts as above in all 12 runs, 0 SCRIPT ERROR. KEPT (riot win; the drive's remaining ~200 us is per-call
overhead or the hit path, not split yet). L20 + L20b + L20c together: the riot's per-rig query **~650 (L20's old
median of 705 / 652) -> ~130 us a frame**, the occlusion `_process` ~800 -> ~280 us. No frame-total claim (its spread is
larger than 0.5 ms under contention).

### Split (it6): city_blood and the occlusion query's remaining cost (cvprof timers, CONTENDED 4-6)
Riot (tilt70, 30 s, fixed 60; `evidence/perf/n9-it6/split/`): `CityBlood._process` = **blood.step 450-496 us a
frame** (BloodFx.step_ticks 347-380, CombatBlood._resolve + the shader parameter 91-101, the leak 2, the splat meshes
6-7) + **CorpseStains.step 140-159** + the kill beat 2-3 + the muzzle pop 2: ~0.6-0.66 ms, which matches the 0.80 ms
NodeSpans row (it4). The drive: blood.step 32, stains 9 (no deaths). BloodFx in the riot: 320 drop slots, **82 live a
tick**, 2 BloodFx stepped a frame (blood + oil): ~2 us a live drop-step. Its cost per drop is `_hit_wall` ->
`BloodMarks.wall_normal` -> `solid.call` (a Callable into `CityBlood._solid` -> the native `sim.cell_at`, 1-3 calls a
drop a tick) plus the Vector2 updates. Next lever (L22, not built): hand BloodFx a direct cell lookup instead of the
Callable chain, and skip the 320-slot walk when `drops == 0`; est. step_ticks -30..-50 % (~-150 us a riot frame); the
exactness test is the same drop / decal sequence over a scripted spray into a wall.
The occlusion query after L20c (per frame): riot 33 chunk calls, **0 candidates, 0 kept** (no rig stands near a
building), near 143 us = per-call overhead (the 4-corner key Dictionary, residency lookups, the timers); drive 13
chunk calls, 139 candidates, 30 kept, near 200 us (the kept path: `_with_area`'s lift lookup, `body_patch`, and the
silhouette of the ~1.9 hidden bodies a frame). Next lever there: a per-frame chunk-key cache in near() (riot) and
the silhouette only once per rig (drive); small (< 0.1 ms each).

### L22 probes (it6): the blood drops' wall check
Ceiling (cvprof, riot, one run an arm, measurement only: the drops fly through walls): with no wall check
BloodFx.step_ticks is 115 us a frame vs 328 with it: **the wall checks are ~210 us (65 %)**. Each check is
`solid.call` -> `CityBlood._solid` -> `CitySimNative.cell_at` -> `_call(&"cell_at", [x, y])` -> `Object.callv`
(a fresh 2-element Array and a Variant dispatch every call). Cells change only on a chunk stamp / clear.
Probe A (`evidence/perf/n9-it6/l22/`): `cell_at` as `_o.call(&"cell_at", x, y)` (the same native method, no Array):
step_ticks old 337 / 413 (+ 327 / 347 / 380 from the split runs) vs new **283 / 294 us** (2 interleaved pairs,
CONTENDED 0-4; ranges apart, about -17 %, ~-55 us a riot frame); live drops 82.1 a tick in every run. **KEPT as L22a
(1d5a65c1)**: test `test_city_sim_native_cells` (native == ref `cell_at` over 4 stamped chunks, past them and off the
map; a planted x / y swap caught); gate on 1d5a65c1 ALL PASS (unit 1838 / 0, scenarios 54 / 54, parity exact, look
goldens 11 / 11, release-compile 618 / 0), the reel 19 / 19 in top, tilt70, combo, 0 SCRIPT ERROR. The bigger cut is a per-cell solid cache in CityBlood invalidated
by the sim's chunk stamp / clear (exact; est. most of the 210 us).

### L22b (it7): a per-cell solid memo for the wall checks: DROPPED (a wash)
Hypothesis: a drop moves a few px a tick and a sim cell is 32 px, so a per-frame `Dictionary[int, bool]` of the cells
already asked (cleared after each blood.step; exact while the map holds still) skips most native `cell_at` calls:
est. -100 us of step_ticks. Built (`evidence/perf/n9-it7/l22b/l22b.diff`: CitySolidMemo + CityBlood, a test that the
memo == the direct answer over a sweep, off the map, and forgets a cleared chunk). A/B (cvprof, riot, 6 interleaved
pairs, CONTENDED 2-9; `ab-l22b.txt`): step_ticks old 343 / 294 / 310 / 333 / 401 / 276, new 265 / 255 / 301 / 386 /
254 / 265 (raw medians 322 -> 265, 5 of 6 pairs better). But the unchanged CorpseStains.step in the same runs swings
with the machine (129-190 us), and **step_ticks / stains** is old 2.01-2.12 (median 2.06) vs new 1.95-2.04 (median 1.97):
~-4 %, ~-13 us, ranges overlapping. The raw -17 % was machine load. The memo's floori + Dictionary.get + the Callable
into `_solid` cost about what L22a's direct `Object.call` costs. **Dropped**; not committed. The remaining wall-check
cost is the GDScript per-drop work itself (a C++ drop step is the lever, not worth it at ~0.2 ms).
Lesson (measurement-honesty): an in-run control (an unchanged system timed in the same frames) is what separates a
lever from the machine; raw medians of 3 pairs on a shared box were not enough here.

### L23 (it7): the corpse soaks measure only the walkers near them: KEPT (4bc6d82c)
Split first (cvprof timers in CorpseStains, riot; `evidence/perf/n9-it7/l23/split-t0.txt`): step 138 us = the feed
scan 39 + `_match` 10.5 + the soak loop 84.5, of which **`_uncovered` 69.5**: 14.8 live soaks x 263 feed rows, every
walker measured for every soak. Hypothesis: sort the walkers by x once a step (native `PackedVector2Array.sort`) and
`bsearch` each soak's CLEAR_M x-window (+1 px for the float32 edge); the same distance test on what is left, and minf is
order-free, so the alpha is bit-identical. Est. -50 us. Change: `StainCover.cover(at, by_x)` (new file: the debt ratchet
keeps corpse_stains.gd at <= 245 lines; it is 244), `CorpseStains._by_x` sorted in `step_bodies`. Test
`test_corpse_stains_cover`: cover == the old full scan over 60 hashed scenes of 0-300 walkers (ties in x every third
scene), at the window's edges (+-0.001 px), with none; the host's `walkers` keep their order.
A/B (cvprof, riot, 4 interleaved pairs, CONTENDED 0-2; `ab-l23.txt`): CorpseStains.step old **141 / 133 / 144 / 135**
vs new **103 / 102 / 106 / 107 us** (median 138 -> 104, **-25 %, -34 us a riot frame**, ranges apart); the control
blood.step 370-406 in both arms. **KEPT**: the new baseline. Mutation (`mutate-l23.txt`, stain_cover.gd at 4bc6d82c):
9 killed / 5 survived (64.3 %); all 5 survivors are equivalent mutants (the two +1 px window margins -> 0, the break's
`>` -> `>=`, and on clear2 `<` -> `<=` and pow 2 -> 3: smoothstep is already 1 at and past CLEAR_M), so every
non-equivalent fault is caught. Reel x3 on 4bc6d82c: 19 / 19 fully down in top, tilt70, combo, 0 SCRIPT ERROR
(`evidence/perf/n9-it7/reel-l23/`).

### L24 (it7): CityOccluders.near without its key Dictionary: KEPT (509580ac)
The it6 counts: the riot's near() finds 0 candidates in 33 chunk calls a frame, so its ~130 us is per-call overhead.
Hypothesis: the 4-element array literal and the `Dictionary[Vector2i, bool]` of corner keys (built, then iterated) plus
`is_resident` + `chunk_at` (two lookups) are most of it; two `range` loops over the corners' chunk span (32 x 32 m < a
128 m chunk: 1-2 a side) give the same keys in the same order (lo / hi are the same float32 corner sums), and
`chunk_at` alone returns null off the residency. Est. -40 us riot. Test (`test_city_occluders`): near == the old
Dictionary walk over 400 queries around the chunk seams with one chunk missing, with and without a body box; a swapped
loop order and a dropped seam row are both caught.
A/B (cvprof, 3 interleaved pairs, CONTENDED 2-6, `evidence/perf/n9-it7/l24/ab-l24.txt`), near us a frame: riot old
**139 / 132 / 156** vs new **97 / 101 / 102** (median -38 us, -27 %, ranges apart; near / crowd+lift, an unchanged
timer in the same frames: 1.28-1.34 vs 1.05-1.06); drive old 206 / 217 / 219 vs new 180 / 210 / 161 (near / crowd+lift
1.72-1.74 vs 1.54-1.56: -10 %). Hidden body-frames and crowd patches identical (riot 0 / 11669, drive 3432 / 5154).
**KEPT**. Gates on 6fed0aad (L23 + L24): ALL PASS (lint 15 / 15, unit 1842 / 0, scenarios 54 / 54, parity exact, look
goldens 11 / 11, release-compile 619 / 0; `evidence/perf/n9-it7/evidence-6fed0aad.txt`); the reel x3 19 / 19, 0 SCRIPT
ERROR (`evidence/perf/n9-it7/reel-l24/`).

### L25 (it7): CorpseStains.step reads the feed through locals: KEPT (6ce43cd0)
The feed scan was 39 us of the 138 (split above): ~3 member reads (`feed.flags[i]`, `feed.pos[i]`, `feed.ids[i]`) a
row over 263 rows. Hypothesis: GDScript resolves a member of another object by name each read; hoisting the packed
arrays into locals (read only: the same arrays, no copy, L19) cuts the scan by half. A/B (cvprof, riot, 3 interleaved
pairs on L23, CONTENDED 2-4, `evidence/perf/n9-it7/l23/ab-l25.txt`): CorpseStains.step **101.5 / 111.8 / 100.0 ->
86.9 / 91.8 / 86.1 us** (median -15 us, -14 %, ranges apart), the blood.step control 375-420 in both arms. The
committed form keeps `feed.ids` a member read on the few dead rows (the debt cap: the file is at 245 lines); the
living rows read exactly as in the measured arm. Test: step's walkers are every living row in feed order and the
death soaks the dead row (a planted wrong-row read caught). CorpseStains.step over it7: **138 -> ~87 us a riot frame**.
Gates on 6ce43cd0 (L23 + L24 + L25): ALL PASS (lint 15 / 15, unit 1843 / 0, scenarios 54 / 54, parity exact, look
goldens 11 / 11 (worst 0.27), release-compile 619 / 0; `evidence/perf/n9-it7/evidence-6ce43cd0.txt`); the reel x3
19 / 19 fully down in top, tilt70, combo, 0 SCRIPT ERROR (`evidence/perf/n9-it7/reel-l25/`).

### L26 (it8): FxPool.step moves each particle through locals: DROPPED (a wash)
Hypothesis: the per-step `pos[i] += vel[i] * dt; vel[i] *= maxf(...)` reads and writes two member packed arrays a
step, recomputes the drag factor a step and checks `mirror.is_empty()` a particle; moving the step into locals (the
same float ops in the same order: bit-identical) and hoisting the factor and the check cuts fx.ground.step ~15 %.
(The read-only arrays `born`, `row_of`, `rot`, `seed_of` can NOT be hoisted: `_swap_out` writes them mid-loop, and a
write through the member while a local shares the buffer would copy the whole array, then read a stale local.)
A/B (cvprof, riot tilt70 windowed, fixed 60, 3 interleaved pairs, bench.lock held, CONTENDED 0-8 other Godots,
`evidence/perf/n9-it8/l26/ab-l26.txt`, arm `l26.diff`), PC.ground.step us a frame / the blood.step control:
cur 81.1 / 93.9 / 90.5 (ratio 0.221 / 0.218 / 0.227), L26 84.8 / 90.3 / 79.9 (ratio 0.225 / 0.217 / 0.226): **a wash**
(ratio medians 0.221 vs 0.225). The step's cost is the three MultiMesh instance writes a particle, not the motion.
Not committed. Kept from it: `test_fx_pool` now steps 0, 1 and 2 ticks (a frame with no tick was not covered).
Rejected without building: one `multimesh_set_buffer` a frame instead of three instance calls a particle: GDScript
would write 16 floats a particle into a packed array (16 indexed stores vs 3 validated native calls, ~the same cost),
and the 2D buffer layout (8-float transform rows) is a new place for a pixel to move.

### L27 (it8): CityFxFeed.observe reads the dead flags through a local: DROPPED (a wash)
Hypothesis (L25's pattern): observe reads `_dead[i]` a person record (~400 a riot tick, 117-120 us); a local copy
of the array (written back once, so a copy only on a frame with a flip) cuts the loop ~10 %. A/B (cvprof, riot, 4
interleaved pairs, bench.lock held, CONTENDED 4-10, `evidence/perf/n9-it8/l27/`), FF.observe us a frame:
cur 120.5 / 114.5 / 120.3 / 117.1, L27 120.9 / 115.7 / 116.3 / 121.4 (control BR.crowd.observe 116-127 in both):
**a wash**. Lesson with L25 and L26: a read of the script's OWN member is already a cheap indexed access; L25 won
because it read members of ANOTHER object (`feed.flags[i]`: a named property get a read). The remaining per-record
cost is the snapshot reads and the int() conversions themselves: the next step there is native, not GDScript.
Not committed.

### Gates (it6)
On 8990b643 (L20, the clean re-run owed from it5; `evidence/perf/n9-it6/evidence-8990b643.txt`) and on 6b75d795
(L20b + L20c; `evidence-6b75d795.txt`): ALL PASS: lint 15 / 15, unit 1835 / 0 and 1837 / 0, scenarios 54 / 54, parity
bit-exact (mutation caught at 629), look goldens 11 / 11 (worst 0.27), release-compile 617 / 0 and 618 / 0. The director
reel x3 (headless, fixed 60, `--quit-after 16000`) on 6496dbdb (L20b): 19 / 19 chapters fully down in top, tilt70,
combo, 0 SCRIPT ERROR (`evidence/perf/n9-it6/reel/`).

### Item 2 (it2): the traffic-sheet split is moot under BC7
n9-world 3e02d3b8 imports the p70 traffic sheet as BC7: `traffic_cards.png-313d05e5...bptc.ctex` = **18,063,412 B**
(4032 x 4480 x 1 B), one upload into a **32 MB** pow2 staging buffer (L9's mechanism), against 128 MB lossless. The
-96 MB the split was for comes with BC7 itself; no texture of the sheet is over 32 MB. Not split (DECISION
perf/traffic-split-under-bc7); `tools/art/split_sheet.py` stays for a lossless build. Owed: the resident-memory A/B
lossless vs BC7 (world's item 1 job, `ab.mjs --scenes=riot,drive70`), read from world's evidence when it lands.

### Item 3 (it2): the frame-pacing option (Call P-3 C)
"Frame pacing: efficient / steady" in the pause card's settings (non-handheld rows; a handheld row keeps its 30 / 40 /
60 cap row), saved as `pacing` in `gtai.player-settings/1`. efficient (default) = the boot cap from FrameCap (none at
60 Hz, the tick rate above 61 Hz); steady = `FrameCap.pacing_cap`: the tick-rate limiter on top of vsync at 60 Hz too
(L10 / L11: p99 ~20 -> ~17 ms, +0.06..+0.09 core). No-op headless and when filming. d6e93b92, tests in
`test_frame_cap`, `test_player_settings`, `test_settings_panel_pad` (the desktop rebind rows moved down one).
Owed: the steady-vs-efficient A/B on mailbox (L11 measured them on Enabled).

## Method (applies to every row)
- **Runner:** `node tools/perf/ab.mjs --scenes=<..> --arms=<name>:<user args>[^<engine args>],... --pairs=N --out=<dir>`.
  It runs each scene once per arm per round, alternating the arm order every round (A B / B A ...), so a
  machine's drift lands on both arms (perf-regression-gating: interleave, never compare to a stored run).
  Takes `C:\Users\kazda\kiro\gtai-n5\bench.lock` (noclobber) for the whole job and stamps each run
  CONTENDED(n) when n other Godot processes were up (`tools/lib/run_ledger.mjs foreignGodot`).
- **Scenes** (`SCENES` in `ab.mjs`; windowed, `--rendering-driver d3d12 --disable-vsync --resolution 1920x1080`,
  the editor binary = a debug build, so GDScript is slower than the release export):
  `king` = `arena.tscn --boss=king --bot=boss --seed=2 --rigs --view=combo --frames=<json> --frames-ticks=1500`
  (FightFrames; the first 1000 ms of wall time cut as warm-up);
  `drive70` = `city_bench.tscn --scenario=drive_dense --zoom=1.5 --view=tilt70 --secs=30` (48 px/m, the in-car camera);
  `riot` = `city_bench.tscn --scenario=riot --zoom=1.0 --view=tilt70 --secs=30` (400 actors, 32 px/m);
  city_bench drops its first 120 frames. `reel` and `drive70h` (headless, CPU only) exist as presets.
- **Metrics** (`tools/perf/stats.mjs`, tests `node --test tools/perf/stats.test.mjs`): frame wall time
  p50 / p99 / p99.9 / worst / mean, 1 % low, hitches over 25 and 50 ms, pacing (|f[i] - f[i-1]| p50/p99),
  draw calls a frame, render-server CPU ms, GPU ms (FightFrames only), and from the process sampler
  (`tools/perf/proc_sample.ps1`, one CIM query a second over the runner's Godot processes, the first 3
  samples = boot dropped): CPU in cores (1.00 = one core busy), peak working set MB, peak threads.
- **Verdict:** per metric, median over runs and spread (max - min); `WIN`/`LOSS` only when B's median
  moves beyond the larger arm spread, else `WASH`. A win on a metric that is load-dependent (ms) is only
  kept when measured with the lock; counts (draw calls) A/B on a busy machine.
- **Keep rule:** a lever is kept only with the look unchanged (look goldens, `top` bit-identical, parity
  bit-exact) and the gates green; a lever that moves a pixel is an owner Call, never a baseline.

## Baseline (main 3982af1a, this morning): the cost of one 60 Hz gameplay frame
10:45-10:50, `evidence/perf/baseline-fixed/ab.json`, `node tools/perf/ab.mjs --scenes=king,drive70,riot,reel --arms=base: --pairs=3`:
windowed D3D12 1920x1080, `--fixed-fps 60 --disable-vsync` (one tick per frame, as fast as it can),
the editor binary (a DEBUG build: GDScript is slower than the release export; the release-export
baseline through `windows-bench` is owed), bench.lock held, 11 of 12 runs UNCONTENDED.
| scene | runs | p50 ms | p99 | p99.9 | worst | pace p99 | >25 ms | draws | render CPU ms | GPU ms | peak RAM MB | contended |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| king (combo, `--boss=king --bot=boss --seed=2 --rigs`, 1500 ticks) | 3 | 3.75 ±0.05 | 7.40 ±1.00 | 10.22 ±7.73 | 10.62 ±11.01 | 2.22 ±0.18 | 0 | 652 | 0.39 | 0.30 | 702 | 1/3 |
| drive70 (drive_dense, tilt70, 48 px/m, 30 s) | 3 | 2.52 ±0.06 | 5.12 ±4.79 | 6.57 ±20.67 | 6.62 ±25.19 | 1.85 ±11.61 | 0 ±5 | 293 | 0.22 | n/m | 771 | 0/3 |
| riot (400 actors, tilt70, 32 px/m, 30 s) | 3 | 4.45 ±0.07 | **14.55 ±0.56** | **27.25 ±0.95** | 28.43 ±1.49 | 10.07 ±0.56 | 2 | 832 | 0.53 | n/m | 834 | 0/3 |
| reel (director, tilt70, pistol, 3600 ticks) | 3 | 4.37 ±0.06 | 10.17 ±0.47 | 14.64 ±2.09 | 23.88 ±1.84 | 3.96 ±0.15 | 0 | 572 | 0.38 | 0.40 | 741 | 0/3 |
(n/m = not measured: city_bench logs no GPU time. Quest 1 is not yet in the runner (`quest1_frames.gd`
writes a summary, no series): owed. CPU in cores is ~1.0 in every uncapped run: one core kept busy;
the process CPU at a 60 fps vsync cap is owed (the sampler is ready).)

**Quest 1 row (it6, 13:13-13:16, owed since the morning; `evidence/perf/l5-feed/ab.json`, the `base` arm = the
scratch project at ee63589c = main + L2 + L3, preset `quest1` = `quest1_frames.gd`, 1200 one-tick frames from the
Dock 9 fight in the play view, windowed D3D12 1920x1080, editor binary, bench.lock held, CONTENDED(4) in 3 of 3 runs
(the rivet lane filming)):** p50 3.63 ±0.01, p99 6.49 ±0.15, p99.9 9.70 ±0.60, worst 18.77 ±1.48 ms, CPU 0.96 cores,
peak RAM 1035 MB (the highest of the five scenes). Draws / render CPU / VRAM are not logged by quest1_frames (n/m).
*(Correction, n9 it9: tick 5800 is the Toner Room dialogue, not the Dock 9 fight, which is near tick 13000 (handheld n9 07:48). The quest1 row measures that dialogue stretch of the city; the comments in quest1_frames.gd and ab.mjs are fixed.)*

## Release-export baseline (it4, at 87155de9): the shipped build vs the editor binary
**Current numbers: the `--screen 0` rerun (11:57-12:00) at the end of this section.** The first table
(11:45-11:49) is kept for the record: its exe arm ran on the other monitor (F8) and is superseded.
`node tools/perf/ab.mjs --scenes=riot,drive70,riot60 --arms=dbg:,rel@exe: --pairs=2` (`evidence/perf/rel-vs-dbg/ab.json`):
the `windows-bench` release export (`--export-release windows-bench`, 256 baked chunks) against the editor
binary on the same presets, 2 pairs interleaved. **CONTENDED: 8-17 other Godots in every run** (my own
evidence run plus the seams lane's), so read the ratios, not the ms; a quiet rerun is owed.
| scene | build | p50 ms | p99 | p99.9 | worst | render CPU ms | CPU cores | peak RAM MB |
|---|---|---|---|---|---|---|---|---|
| riot (fixed 60) | editor (debug) | 6.72 ±0.29 | 13.94 ±2.05 | 18.34 | 22.43 | 0.72 | 1.04 | 851 |
| riot (fixed 60) | release exe | **5.33 ±0.09 WIN** | 14.28 WASH | 23.15 WASH | 25.62 WASH | 0.63 WIN | 0.95 | **681 WIN** |
| drive70 (fixed 60) | editor (debug) | 3.70 ±0.17 | 5.78 ±0.02 | 8.50 | 10.20 | 0.30 | 1.02 | 855 |
| drive70 (fixed 60) | release exe | **2.90 ±0.18 WIN** | **8.41 ±0.35 LOSS** | 12.84 LOSS | 17.00 LOSS | 0.28 | 0.99 | **681 WIN** |
| riot60 (vsync + 60 cap, real time) | editor (debug) | 16.68 | 19.94 | 35.55 | 42.98 | 0.89 | **0.49** | 913 |
| riot60 (vsync + 60 cap, real time) | release exe | 16.68 | 22.31 WASH | 72.39 WASH | 107.14 WASH | 0.87 | **0.41 WIN** | **675 WIN** |
- **Least resources at the player's cap:** the 400-actor riot at 60 fps holds **0.41 of one core** and
  **675 MB** in the release build (debug 0.49 / 913). Draw calls are identical (832 / 293).
- **Boot** (`tools/perf/boot.sh 3`: boot + one city_bench frame + exit, windowed, CONTENDED): exe 2.48 / 2.86 /
  2.90 s, editor 4.27 / 4.35 / 5.54 s: **median 2.86 s vs 4.35 s**.
- **Size:** `RTAI-bench.exe` 109.3 MB (the stock release template: every engine module), `RTAI-bench.pck`
  227.7 MB, the sim DLL 0.4 MB. A custom template without unused modules (3D physics, navigation 3D, XR,
  ...) is the size lever: owed (a template build is ~30-60 min of compile).
- F8 (11:49, RESOLVED 11:55): the release exe's worse drive70 tail above was **a window-placement
  confound, not the build**. The editor binary reads the git-excluded `project/override.cfg` (windows on
  screen 0, the 1920x1080 secondary); the exe has no override.cfg and opened on the primary ultrawide,
  where present blocked: two exe runs there p50 16.6 / 12.0 ms, p99 43.3 / 17.6, worst swap 47 / 28 ms;
  the same exe with `--screen 0`: p50 2.50 / 2.52, p99 4.14 / 4.41, worst 6.2 / 5.5 ms (better than the
  editor's 5.78 p99). Every preset and `boot.sh` now pins `--screen 0` (commit after f60880a1); the table
  above is superseded by the rerun below. Lesson (measurement-honesty): an arm that differs in anything
  but the lever (here the monitor) is not an A/B. Player note: a window on a screen the frame cannot
  present to directly (a different adapter or a scaled mode: unverified which) can cost 10+ ms a frame.

**Rerun with `--screen 0` (11:57-12:00, `evidence/perf/rel-vs-dbg-screen0/ab.json`, 2 pairs, CONTENDED-stamped in
10 of 12 runs but lightly: 0-4 other Godots in 11 of them, 10 in one): the release-export baseline.**
| scene | build | p50 ms | p99 | p99.9 | worst | render CPU ms | CPU cores | peak RAM MB |
|---|---|---|---|---|---|---|---|---|
| riot (fixed 60) | editor (debug) | 5.78 ±0.65 | 9.30 ±0.47 | 12.28 | 13.95 | 0.65 | 1.04 | 898 |
| riot (fixed 60) | **release exe** | **4.08 ±0.10 WIN** | **7.24 ±0.11 WIN** | **8.74 WIN** | **9.65 WIN** | 0.51 | 1.04 | **764 WIN** |
| drive70 (fixed 60) | editor (debug) | 2.95 ±0.19 | 5.63 ±0.21 | 8.73 | 10.88 | 0.25 | 1.03 | 919 |
| drive70 (fixed 60) | **release exe** | **2.46 ±0.07 WIN** | 5.37 WASH | 10.47 WASH | 10.59 WASH | 0.24 | 1.04 | **818 WIN** |
| riot60 (vsync + 60 cap) | editor (debug) | 16.69 | 19.86 | 22.00 | 23.51 | 0.65 | **0.36** | 912 |
| riot60 (vsync + 60 cap) | **release exe** | 16.68 | 20.00 WASH | 23.48 LOSS | 33.61 LOSS | 0.58 | **0.29 WIN** | **758 WIN** |
- The shipped build runs the 400-actor riot frame in **4.08 ms p50 / 7.24 ms p99** (section 20's riot p99
  budget is 7 ms: within 0.24 ms of it on this host) and holds the riot at the 60 fps cap with **0.29 of
  one core and 758 MB**. The debug editor overstates the riot's CPU cost by ~40 % (p50) and its tail by ~30 %.
- Watch: riot60's exe worst frame 33.6 / 24.3 ms against the editor's 23.5: frame by frame it is ONE frame
  over 25 ms in 1684 (run 0, frame 1261; run 1 none over 25), isolated, not a pattern; real-time presented
  frames, not a cost metric. Re-check with more pairs and the perf HUD on the exe.
- **Boot to first frame, same screen** (`tools/perf/boot.sh 5`, `--screen 0`, boot + one city_bench frame + exit;
  `evidence/perf/rel-vs-dbg-screen0/boot.log`): exe 3.95 / 2.55 / 2.41 / 2.69 / 2.58 s, editor 3.98 / 4.29 /
  4.08 / 4.89 / 3.89 s: **median 2.58 s vs 4.08 s**. (The first table's 2.86 vs 4.35 s had the exe on the other screen.)

## Final table n9, quest 1 and the director reel (it10, 09:00-09:07): main da108c13 vs n9-perf dc9ea2fd vs a byte copy
The two brief scenes missing from tonight's tables. `node tools/perf/ab.mjs --scenes=quest1 --pairs=3
--arms=main:^--path <gtai-n9/tmp/perf/prof3>/project,head:,head2:^--path <gtai-n9/tmp/perf/head2>/project`
(`evidence/perf/n9-it10/quest1/` + `quest1.log`), then `--scenes=reel` the same (`reel/` + `reel.log`). Editor binary,
windowed D3D12 1920x1080, fixed 60 uncapped, bench.lock via ab.mjs, 0 errors. head = this branch's project
(project/ unchanged since efa848cb but for comments); head2 = its byte copy (F12's A-vs-A floor). quest1 =
`quest1_frames.gd` from tick 5800 (the Toner Room dialogue), 1200 frames; no draws / GPU / VRAM in that log (n/m).
Quest 1: 9 runs, 3 labelled CONTENDED. Median ± half-spread:

| scene | metric | main | head | head2 (A-vs-A) | verdict |
|---|---|---|---|---|---|
| quest 1 | p50 / p99 / p99.9 ms | 3.43 ±0.80 / 6.50 / 16.19 | 3.32 ±0.34 / 6.91 / 16.59 | 3.56 ±0.05 / 6.23 / 15.15 | WASH (head vs head2 0.24 ms > head vs main 0.11) |
| quest 1 | CPU cores, steady RAM | 1.04, 1068 MB (1067-1069) | 1.02, 1069 (1006-1069) | 0.98, 1006 (1004-1007) | WASH; the RAM is the per-run ~60 MB state seen on the release riot (head 1 / 3 runs low, head2 3 / 3): not a saving |
| reel (director, pistol, tilt70, 3600 ticks) | p50 / p99 / p99.9 ms | 5.89 ±0.74 / 13.45 / 18.39 | 5.63 ±0.27 / 17.20 ±3.83 / 20.65 | 5.71 ±0.19 / 13.31 / 18.03 | WASH (head's p99 spread 3.8 ms; head vs head2 0.08 ms p50) |
| reel | CPU cores, steady RAM, draws, render CPU / GPU ms | 1.00, 817 MB, 526, 0.45 / 0.44 | 1.00, 817, 526, 0.49 / 0.52 | 1.00, 817, 526, 0.44 / 0.51 | WASH; draws vary 523-528 a run in every arm (the reel's frames are not draw-deterministic run to run), the medians agree |

Reel: 9 runs, 8 labelled CONTENDED (2-6 Godots). Reading: tonight's kept CPU cuts sit in the riot's systems (FX,
occlusion, stains, blood), which quest 1's dialogue stretch and the reel barely exercise, so a wash is the expected
result here, and the A-vs-A floor (0.1-0.25 ms p50) leaves no room to claim a ~0.1 ms move. Nothing regressed.

## Final table n9 (it8, 07:28-07:34, PROVISIONAL): main da108c13 vs n9-perf 1365b7f3 vs a byte copy (A-vs-A)
`node tools/perf/ab.mjs --scenes=king,drive70,riot --pairs=3 --arms=main:^--path <gtai-n9/tmp/perf/prof3>/project,head:,head2:^--path <gtai-n9/tmp/perf/head2>/project`
(`evidence/perf/n9-final-1365b7f3/`: ab.json + run.txt). Editor binary (debug), windowed D3D12 1920x1080, fixed 60
uncapped (vsync off: the cost of one gameplay frame), bench.lock held by ab.mjs, arm order rotating, 0 script errors
in 27 runs, **CONTENDED in 25 of 27 runs (1-8 other Godots: the other lanes' gates and reels)**. `head2` = a byte
copy of head's project (its `.godot`, DLLs) in another dir: a head-vs-main move counts only beyond head-vs-head2 (F12).
main = da108c13 = main's project today (`git diff da108c13 main -- project native` is empty). Median ± half-spread:

| scene | metric | main | head | head2 (A-vs-A) | verdict |
|---|---|---|---|---|---|
| King under combo | p50 / p99 / p99.9 ms | 4.51 / 10.31 / 14.64 | 5.10 / 10.19 / 13.28 | 4.14 / 9.03 / 12.67 | WASH (head vs head2 0.96 ms at p50) |
| King | CPU cores, steady RAM | 1.00, 746 MB | 1.01, 790 | 1.01, 790 | WASH (spread 24-32 MB) |
| drive70 | p50 / p99 / p99.9 ms | 3.54 / 6.98 / 14.58 | **2.24 / 4.66 / 9.58** | 2.59 / 6.44 / 12.27 | p50 -1.3 ms vs main but head vs head2 = 0.35: **WASH by F12** (direction: head under main in 3 / 3 rounds, 2.19-2.72 vs 2.67-3.79) |
| drive70 | render CPU / GPU ms, VRAM | 0.30 / 0.25, 916 MB | 0.23 / 0.23, 932 | 0.26 / 0.22, 916 | WASH |
| riot (400 actors) | p50 / p99 / p99.9 ms | 4.84 / 11.32 / 17.73 | 4.26 / 11.31 / 19.32 | 5.67 / 12.63 / 23.20 | WASH (head vs head2 1.4 ms at p50) |
| riot | CPU cores, steady RAM, draws | 1.03, 859 MB, 734 | 1.01, 864, 734 | 0.94, 861, 734 | WASH; draws identical (pixel-free levers) |

Reading: on this contended machine the A-vs-A floor (0.35-1.4 ms at p50) is larger than every CPU lever kept tonight
(L17-L25 sum to ~0.7 ms a riot frame by their own in-run timers: FxPool -40 us, the occlusion query 705 -> ~100 us,
CorpseStains 138 -> 87 us, the blood wall checks -55 us, residency -7 % of chunks.update). So the frame table claims
NO frame-level win; the wins are the mechanism numbers in each L row (in-run controls, ranges apart). The night's
frame-level results stand where they were measured: F-19 (0 / 40 freezes), BC7 VRAM -352 / -362 MB (Item 4).
An earlier run (`evidence/perf/n9-final-it8/`, 07:20, 2 arms) is VOID for head: its r1 head runs carried the
uncommitted L27 arm (FRICTION it8). Owed at the freeze: the same table on the final HEAD, on the release exports
(`@exe` arms, as d9's final table), when the machine is quieter.

## What ships (it9, 08:14-08:22): main vs a trial merge of world's head + this branch, release exports
The Director merges four lanes; world carries BC7 + combo + bikes, this branch the CPU cuts + mailbox. A scratch
trial merge (`gtai-n9/tmp/perf/world3`, commit 6e36e936 = n9-world b888fe20 + n9-perf c18385e4, never pushed: only
JOURNAL.md / REPORT.md conflict, the code auto-merges, lint 15 / 15; world's DLLs copied) exported as `windows-bench`
to `build/export/windows-bench-merge/`. `node tools/perf/ab.mjs --scenes=drive70,riot --pairs=4
--arms=main@exe-windows-bench-main:,merge@exe-windows-bench-merge:` (`evidence/perf/n9-it9/ship-merge/` + `.log`),
16 runs, 0 errors, bench.lock via ab.mjs, CONTENDED(2-8) in 7 of 8 rounds. Median ± half-spread:

| scene | metric | main da108c13 | merge | verdict |
|---|---|---|---|---|
| drive70 | p50 / p99 ms | 2.24 / 4.51 | 2.09 / 3.97 | WASH (merge under main in 3 of 4 rounds) |
| drive70 | VRAM MB | 884 | **528 (-356, -40 %)** | **WIN** (spread 8-16) |
| drive70 | steady RAM MB | 754 | 692 (688-753) | WASH by spread (3 of 4 merge runs at ~690) |
| riot | p50 / p99 ms | 4.50 / 8.54 | 4.37 / 9.07 | WASH (merge under main in 3 of 4 rounds; world adds rig cost, see draws) |
| riot | VRAM MB | 899 | **549 (-350, -39 %)** | **WIN** |
| riot | draws | 734 | 739 | +5 (world's content: bikes / robe; not a perf regression to chase) |

**The pck: install up, download down.** BC7 blocks are stored raw in the pck (343.9 of 411.7 MB are `.bptc.ctex`),
while a lossless `.ctex` is WebP, already entropy-coded. So the install grows and the download shrinks
(`evidence/perf/n9-it9/pck-size.txt`, `python -I tools/perf/pck_download.py <pck>...`: every 1 MB chunk compressed
alone, the way a chunked depot store works):

| build | pck on disk | LZMA, 1 MB chunks | zlib, 1 MB chunks | xz -6, whole file |
|---|---|---|---|---|
| main (lossless) | 217.8 MB | 213.4 MB | 216.0 MB | 210.2 MB |
| merge (BC7) | 411.7 MB (+194) | **154.9 MB (-27 %)** | 168.1 MB (-22 %) | 145.7 MB |

L4 (d9) recorded the install side (+160 MB then) and guessed that depot compression shrinks the download; this
measures it: **a player downloads ~45-60 MB less, installs ~194 MB more, and the GPU holds ~350 MB less.** Which
codec the store uses is not measured here (the two codecs bracket it). NOTE to world (FYI, no work asked).

## Final table n9, the release build, 8 pairs (it9, 08:06-08:14): head under main in 16 of 16 paired rounds; the RAM mode on both
`node tools/perf/ab.mjs --scenes=drive70,riot --pairs=8 --arms=main@exe-windows-bench-main:,head@exe:`
(`evidence/perf/n9-it9/ram-mode/` + `ram-mode.log`). The same exports as it8 (main da108c13 from prof3, head efa848cb;
HEAD c18385e4 differs from efa848cb only in docs and a `dev/` comment, which the export drops). 32 runs, 0 errors,
bench.lock via ab.mjs, **CONTENDED(2-4) in 14 of 16 rounds** (the other lanes' Godots), the arm order alternating
per round. p50 ms per round (main / head):

| scene | r0 | r1 | r2 | r3 | r4 | r5 | r6 | r7 | median | paired diff (median) |
|---|---|---|---|---|---|---|---|---|---|---|
| drive70 | 2.13 / 1.91 | 2.29 / 2.04 | 2.64 / 2.14 | 2.30 / 2.00 | 2.22 / 1.84 | 2.53 / 1.95 | 2.71 / 2.59 | 3.18 / 2.53 | 2.42 / 2.02 | **-0.34 ms (-15 %)** |
| riot | 3.91 / 3.36 | 4.40 / 3.43 | 4.18 / 3.50 | 4.07 / 3.20 | 3.87 / 3.50 | 4.95 / 4.03 | 6.43 / 5.36 | 5.62 / 5.00 | 4.29 / 3.50 | **-0.75 ms (-18 %)** |

Head is under main in **8 of 8 rounds on each scene** (both arm orders), the sign test's two-sided p = 0.008 a
scene. Across tonight's release runs (it8 quiet + this) head is under main in 12 of 12 riot rounds and 12 of 12
drive70 rounds. ab.mjs's range rule still prints WASH (the contention drift across rounds, 1.9 -> 2.6 ms for head
alone, is wider than the gap), so the claim is the paired one: **riot p50 -0.75 ms, drive70 p50 -0.34 ms on the
shipped build, every pair the same way**. The it8 A-vs-A (head vs a byte copy, 0.14 ms on the quiet riot) is under
both gaps. p99 / worst: not claimed (overlap). Draws identical (293, 734): pixel-free.
**The steady-RAM mode (~815 MB vs ~752 MB) shows up on both builds**: main 2 of 16 (drive70 r2 814, riot r3 816;
plus one 687 low), head 1 of 16 (riot r1 816). Over tonight's exe runs: main 8 of 33, head 1 of 50 (Fisher's exact
p = 0.002). So head is NOT immune: the mode is a per-run state (an allocator / driver pool that sometimes keeps
~63 MB more), and head hits it less often. Not claimed as a RAM win: a frequency, not a level. A bisect would need
~20 runs an arm to tell 24 % from 2 %: not worth the freeze hours. Watch item closed as "real on both, rarer on head".

## Final table n9, the release riot at a quieter moment (it8, 07:56-08:01): a riot p50 WIN; the RAM split open
The same three exports, riot only, `--pairs=4` (`evidence/perf/n9-ram-exe-it8/`: ab.json + run.txt), 0-2 other
Godots (CONTENDED(2) in 5 of 12 runs: main 3 of 4, head 1, head2 1; main's two quiet rounds read 3.62 and 4.67), 0
script errors. Per round, p50 ms: **main 3.88 / 4.29 / 3.62 / 4.67, head 3.38 / 3.19 / 3.53 / 3.17, head2 3.50 /
3.52 / 3.59 / 3.35**. Both copies of head sit under every main round (head + head2 3.17-3.59 vs main 3.62-4.67), and
head vs head2 is 0.14 ms (the F12 floor of this run). **riot p50 4.29 -> 3.38 ms (medians, -0.9 ms; by the ranges at
least -0.03, typically -0.5..-1.0)**: in line with the ~0.7 ms of CPU cuts the in-run timers measured (L17-L25).
ab.mjs's own spread rule prints WASH (main's half-spread 0.52); the claim rests on the 8-of-8 ordering and the
small A-vs-A gap, and it is the riot's p50 only: p99 main 8.1-10.8, head 5.8-8.6, head2 6.9-9.2 overlap (not
claimed). GPU 0.38 -> 0.32 ms reads WIN in ab.mjs but head2 0.34: not claimed.
Steady RAM: main 751-754 MB in 4 of 4 quiet riot runs, head 751-756, head2 753-755. **But drive70, quiet, 4 pairs
(08:00, `evidence/perf/n9-drive-exe-it8/`)**: main's steady RAM was 817 MB in r0 (751-756 in r1-r3). Over every exe
run tonight main shows the ~817-821 MB mode in **6 of 17** runs, head and head2 in **0 of 34**: NOT refuted, an open
watch item (a ~65 MB mode only main hits; next: a 2-arm bisect over the branch's commits on drive70 / riot, 8+ runs
an arm, before any claim). drive70 p50 per round: main 2.15 / 2.29 / 2.52 / 2.11, head 1.78 / 1.98 / 2.12 / 1.81,
head2 2.45 / 1.88 / 1.97 / 2.11: **WASH** (ranges overlap; direction: head under main in 4 of 4 pairs, head2 in 2).

## Final table n9, the release build (it8, 07:45-07:53): main da108c13 vs efa848cb vs a byte copy, as shipped
`node tools/perf/ab.mjs --scenes=riot,drive70,riot60 --pairs=3 --arms=main@exe-windows-bench-main:,head@exe:,head2@exe-windows-bench-head2:`
(`evidence/perf/n9-final-exe-efa848cb/`). `windows-bench` release exports, the official 4.7.2 template: main from
prof3 (pck 217.77 MB), head from efa848cb (pck 217.78 MB), head2 a byte copy of head's export dir (F12). 27 runs, 0
script errors, **CONTENDED in 23 of 27 (up to 10 other Godots)**: riot p50 3.4-7.5 ms against d9's quiet 4.08.
Median ± half-spread:

| scene | metric | main | head | head2 (A-vs-A) | verdict |
|---|---|---|---|---|---|
| riot (fixed 60) | p50 / p99 / p99.9 ms | 3.88 / 8.20 / 12.10 | 5.08 / 11.83 / 19.29 | 3.48 / 8.33 / 12.53 | WASH (head's r0 / r1 ran under 2-3 other Godots: 6.67 / 5.08; r2 3.38 under main's 3.86) |
| drive70 (fixed 60) | p50 / p99 ms | 2.08 / 4.13 | 1.97 / 4.22 | 1.82 / 3.46 | WASH |
| riot60 (vsync + 60 cap) | process CPU, cores | 0.38 (0.32-0.40) | 0.32 (0.29-0.34) | 0.30 (0.30-0.38) | WASH by spread (direction: head under main's median in 3 / 3 rounds) |
| all three | steady RAM MB | 816 / 818 / 755 | 752 / 754 / 753 | 751 / 754 / 753 | WASH by spread; **watch**: main is bimodal (5 of 9 runs at 816-821, the rest 750-755), head and head2 751-756 in 18 of 18 |
| riot | draws, VRAM | 734, 883 MB | 734, 899 | 734, 883 | identical draws (pixel-free); VRAM inside its 16 MB step |

So tonight's release build costs what main's does on this host, within a floor this loaded machine sets at
~0.15-1.6 ms p50 (head vs head2). Not claimed, worth a quiet re-run: the steady-RAM split (main's ~820 MB mode never
appeared on head in 18 runs) and riot60's -0.06 core. Owed at the freeze: this table again if HEAD's project
changes, preferably at a quieter moment (`--pairs=5`).

## Final table (it12, 14:39-14:52): this morning's main vs d9-perf HEAD, both as the shipped release build
`node tools/perf/ab.mjs --scenes=riot,drive70,riot60,drive60 --arms=main@exe-windows-bench-main:,head@exe:,head2@exe-windows-bench-head2: --pairs=3 --out=evidence/perf/final-exe`
(`evidence/perf/final-exe/ab.json`). `main` = the `windows-bench` export of main 3982af1a (scratch worktree `perf-base`
moved to it, textures reimported at main's WebP q25 m2, the same 256 chunks: pck 227.70 MB); `head` = the export of
5ad88dab (= HEAD's project: nothing under `project/` changed since; L2 + L3 + L5 + L8 inside, pck 215.21 MB); `head2`
= a byte copy of `head` in another dir: **the A-vs-A arm (F12)**, so a head-vs-main move only counts when it is larger
than head-vs-head2. The official 4.7.2 release template in all three. 3 rounds, arm order rotating, bench.lock held,
CONTENDED(2-8) in 14 of 36 runs (the other lanes' Godots), 0 script errors in 36 runs.
| scene | metric | main | head | head2 (A-vs-A) | verdict |
|---|---|---|---|---|---|
| riot (fixed 60, 400 actors) | p50 ms | 3.85 ±0.09 | 4.08 ±0.50 | 4.39 ±0.77 | WASH |
| | **p99** | 12.53 ±0.90 | **8.09 ±1.03** | 8.71 ±1.06 | **WIN -35 %** (head vs head2 0.6) |
| | **p99.9** | 24.00 ±1.46 | **10.36 ±1.31** | 11.54 ±2.26 | **WIN -57 %** |
| | **worst** | 25.33 ±0.92 | **12.16 ±2.64** | 12.39 ±2.68 | **WIN -52 %** (main over 25 ms in 2 of 3 runs, head never) |
| | draws / render CPU / CPU / working set | 832 / 0.49 / 1.03 / 754 | 832 / 0.52 / 1.01 / 756 | 832 / 0.56 / 1.02 / 756 | WASH |
| drive70 (fixed 60, 48 px/m) | p50 / p99 / p99.9 / worst ms | 2.30 / 4.28 / 5.62 / 6.34 | 2.14 / 4.13 / 5.34 / 5.98 | 2.09 / 3.70 / 5.12 / 5.67 | WASH (all inside the spreads) |
| riot60 (vsync + 60 cap) | CPU cores / p99 / worst / ws MB | 0.34 / 19.43 / 38.5 / 753 | 0.32 / 19.23 / 36.7 / 761 | 0.32 / 18.84 / 25.9 / 756 | WASH |
| drive60 (vsync + 60 cap) | CPU cores / p99 / worst / ws MB | 0.18 / 19.51 / 25.0 / 758 | 0.18 / 19.89 / 23.6 / 755 | 0.18 / 19.72 / 25.0 / 759 | WASH |
| pck | MB | 227.70 | **215.21** | 215.21 | -12.5 MB (L8), pixel-exact |
| **riot60 on a SIMULATED 144 Hz display** (it18, L10) | CPU cores / frames per 30 s / duplicate frames | 0.68 ±0.04 / 4202 / 2450 | **0.39 ±0.03 / 1681 / 0** | (no head2 arm: two copies of one arm differ by 0.03, L11) | **WIN -43 %** |
| **drive60 on a SIMULATED 144 Hz display** (it18, L10) | CPU cores / frames per 30 s / duplicate frames | 0.47 ±0.03 / 4202 / 2451 | **0.29 ±0.02 / 1682 / 0** | | **WIN -38 %** |
| **King under combo, window MINIMIZED** (it18 L12 + it21 L14; editor binary, vsync, 60 Hz panel) | CPU cores / loops per 60 s of sim | 0.73 / 0.75, 4641 / 4633 (`--frame-cap=off` = main's behaviour) | **0.354 / 0.343**, 3613-3639 | shown phase A-vs-A offset 0.04 (L14) | **WIN ~-53 %** (L12 -49 %, then L14 a further ~-0.06 net) |
| **slice title card** (it21 L13; editor binary, windowed, vsync, 60 Hz) | CPU cores | 0.037 / 0.023 / 0.033 (`--menu-idle=off` = main's behaviour) | **0.000 / 0.004 / 0.014** | (ranges apart) | **WIN -88 %**, 0 client pixels differ > 15 |
- **The 144 Hz rows** (`evidence/perf/l10-exe/ab.json`, 16:35-16:42, bench.lock held, 3 rounds, CONTENDED 1-3 of 3 per arm, 0
  errors): one release export of 873070a4 (`build/export/windows-bench-cap/`, official template, pck 215.21 MB), vsync off +
  the limiter at 144 (= main on a 144 Hz display: main has no cap) vs at 60 (= what FrameCap sets on HEAD there). main's own
  export cannot run this arm (its `city_bench` has no `--max-fps` and resets the limiter to 0), so the main column is
  the head exe without the cap: the same code path FrameCap switches. Skipped tick images 0 -> 0, working set WASH;
  frame-time columns are the presented interval (16.7 ms at the cap by design), not a cost.
- **What the day bought on the shipped build:** the 400-actor riot's tail halves (the death frames: L2's soak draw and
  L3's strip prefetch), the rest of the frame is unchanged, and the pck is 12.5 MB smaller. Nothing is slower.
  Power (it18-it21): ~40 % less CPU on > 60 Hz displays (L10), about half the CPU while minimized (L12 + L14), and a
  title card that costs ~nothing (L13); all three are no-ops on this PC's 60 Hz screen in play and headless.
- **The minimized and title rows** are the editor binary (the `windows-bench` export has no slice title, and its
  `city_bench` path is the L10 rows'); the before arm is the same build with the lever's flag off, which is main's code
  path for that lever (the flag skips exactly the new node's work).
- **RAM is bimodal, not a build effect:** a run's working set lands near ~690 MB or near ~755 MB on every arm (riot main
  754 / 691 / 755 vs head 756 / 777 / 693, drive60 main 760 / 696 / 758, head2 759 / 817 / 759): the spread (30-40 MB) is the RAM noise floor of
  this scene, and it is the L9 hypothesis (the number of upload workers depends on thread timing).
- The editor-binary scenes (King, reel, quest 1) are in the morning baseline and the per-lever rows; the code levers that
  touch them (L3 King WASH, L5 microbench) did not move them beyond the F12 floor.

## Levers
| # | lever | hypothesis / expected | change | A/B (median, spread) | verdict | commit |
|---|---|---|---|---|---|---|
| L15 | low-processor mode under the 60 fps limiter at 60 Hz, in play (Call P-3 (b) for ~0 CPU?) | F18 / L14: the limiter's +0.06..+0.09 core (L11) is its last-1 ms `YieldProcessor` spin, skipped in low-processor mode. If that mode keeps the limiter's pacing in play (the city redraws every frame, so every loop still draws), (b)'s steadiness comes at vsync-only CPU. Risk (F18): the sleep path wakes up to ~1 ms late and may not hold the limiter's target. Expected: lpcap CPU <= v60, p99 / skipped ticks = cap. | bench only, no project change: arm `lpcap:--max-fps=60^--path <scratch worktree at e941b5b5>/project`, whose git-excluded `override.cfg` adds `application/run/low_processor_mode=true` (`evidence/perf/l15-lowproc-pace/override-lpcap.cfg`); `v60:` (vsync) and `cap:--max-fps=60` (vsync + limiter) from d9-perf; same build, editor binary, riot60 real time. | `evidence/perf/l15-lowproc-pace/ab.json` (18:08-18:14, bench.lock held, 3 rounds, arm order rotating, CONTENDED(2) in 1 of 9, 0 errors). **The machine was loaded beyond what the Godot count shows** (every arm's p99 ~33-39 ms vs L11's ~17-20 ms on the same scene, skipped tick images 20-42 per 30 s vs 0-2): read only the arm-to-arm order. CPU: v60 0.56 ±0.01, cap 0.57 ±0.04, **lpcap 0.50 ±0.02 cores (the lowest, ranges apart from cap)**. Pacing: p99 v60 38.9 ±3.9, **cap 32.5 ±4.9**, lpcap 37.9 ±5.2 ms; skipped tick images (`multiTick`) v60 42, **cap 20**, lpcap 42; duplicate frames v60 12, cap 2, lpcap 6. So low-processor mode drops the spin's CPU and, with it, the limiter's steadier delivery: lpcap paces like plain vsync. | **DROPPED** (one job, a loaded machine): no free (b). The limiter's steadiness and its spin come together on this engine; Call P-3 stays (a) / (b) / (c) as written. Re-check on an idle machine if a pacing option is built. | none (bench arm) |
| L14 | low-processor mode while minimized (MinimizedCap; from F18) | F18: outside low-processor mode the Windows limiter spins `YieldProcessor()` for the last 1 ms of each frame; minimized, L12 holds the limiter at 60, so ~1 ms of spin a loop = ~0.06 core for nothing (no image is drawn). Expected: the King minimized 0.38 -> ~0.32 cores; on screen untouched; no pixel (nothing is drawn while minimized, and the mode is given back on restore). | `boot/minimized_cap.gd`: on minimize `OS.low_processor_usage_mode` is also turned on (`low_when_minimized`), on restore the old value comes back. `--frame-cap=spin` = L12 only (the A/B arm), `--frame-cap=off` = neither. `test_minimized_cap` +1. | **King under combo, `probe_king.ps1` (10 s shown, then 10 s minimized, thread_cpu), order spin / low / low / spin, built in the scratch worktree at 2d81ee85, lock held, 17:43-17:47, CONTENDED (other lanes' Godots up):** minimized spin 0.408 / 0.484 -> **low 0.354 / 0.343 cores** (median 0.446 -> 0.349, the ranges apart). The shown phase (the same code in both arms: an A-vs-A inside each run) reads 0.360 / 0.357 vs 0.322 / 0.317: a 0.04 arm offset, so **the honest effect is ~-0.06 core (-15 %) minimized, F18's predicted size**, not the raw -0.10. Loops 3613-3639 in all four runs (the same 3600 ticks). `evidence/perf/l14-minimized-low/`. Only 2 pairs: a small, mechanism-backed win. | **KEPT** | ca5817a4 |
| L13 | low-processor mode on the slice's title card (the brief's "low_processor_mode where it fits (menus)") | The slice (`boot/quest1.tscn`, the `windows-slice` main scene) opens on a still title card, but the engine drew and presented the whole frame every vblank. Source (`main/main.cpp` `Main::iteration`, 4.7.2): in low-processor mode a loop draws only when `RenderingServer::has_changed()` (any RS write since the last draw), and `OS_Windows::add_frame_delay` then sleeps the whole gap with no spin (F18). Expected: the title near 0 cores, a hover / focus still redraws at once, no pixel. The pause card: the city view behind it writes shader parameters every frame, so it redraws anyway: expected WASH. | `boot/menu_idle.gd` (MenuIdle, a child of the `Game` autoload beside MinimizedCap): each frame it reads `current_scene as Quest1Game`; while no session has started it turns `OS.low_processor_usage_mode` on and holds the limiter at the tick (`MinimizedCap.cap_when_minimized`), and gives both back on Start. `PAUSED_IDLE = false` (one data value) keeps the pause card out; `--menu-idle=off` = the before, `--menu-idle=lowproc` = no tick cap (A/B arm). Headless / movie: never processes. `test_menu_idle` (5). `quest1_game.gd` untouched (the debt ratchet: it is 272 lines). Probe: `evidence/perf/l13-menu-idle/probe.ps1` (editor binary, windowed D3D12 1920x1080, vsync, 60 Hz panel, process CPU over 8 s; from the head runs on the window is pinned TOPMOST). | **Title, d9-perf HEAD wiring (`title-head.jsonl`, 17:26, lock held, CONTENDED 4-8 other Godots, order off/on/on/off/off/on):** off 0.037 / 0.023 / 0.033 -> **on 0.000 / 0.004 / 0.014 cores** (median 0.033 -> 0.004, -88 %; the ranges do not overlap). Replicated on the scratch build of the first variant (`early-runs.jsonl`, 3 pairs): 0.045 / 0.037 / 0.051 -> 0.010 / 0.006 / 0.008. **Look:** the TOPMOST window grabs of the title, off vs on: 0 client pixels differ by more than 15 (of 1.9 M; `still-h1-{off,on}-title.png`). Working set WASH (619 vs 620 MB). **Pause card (WASH, why PAUSED_IDLE is false):** on 0.175 / 0.152 / 0.203 / 0.142 / 0.141 / 0.182 vs off 0.211 / 0.154 / 0.156 / 0.185 / 0.158 / 0.148 cores. **Play after Start is unchanged:** on 0.17-0.21 vs off 0.15-0.22 cores (the mode is given back). Runs that hit F19 (the quest-1 freeze, both arms and main) are excluded from both arms and listed. | **KEPT (title)**; pause WASH (one value away) | 0f725304 |
| L12 | the frame limiter while the window is minimized (the alt-tabbed player) | F17 (it18, measured first): **a minimized game used MORE CPU than one on screen.** Source (`OS::add_frame_delay`): when the window cannot draw, the loop sleeps `low_processor_usage_mode_sleep_usec` (6900 us) and has no vsync wait, so it runs ~145 loops a second: process, the sim's tick catch-up and the views' `_process`, with no image. Expected with the limiter at the tick while minimized: back to ~60 loops a second, CPU near or under the on-screen figure, the same ticks, no pixel (nothing is drawn while minimized). | `boot/minimized_cap.gd` (MinimizedCap, a child of the `Game` autoload): each frame it compares `window_get_mode() == MINIMIZED` with the last frame; on minimize `Engine.max_fps = cap_when_minimized(current, flag)` (the tick rate, unless a lower cap is set or `--frame-cap=off`), on restore the old value comes back (only if nothing else changed it meanwhile). Headless and `--write-movie`: it never processes. `test_minimized_cap` (3 tests). Probe: `evidence/perf/l12-minimized/probe.ps1` / `probe_king.ps1` (`thread_cpu.ps1` 10 s on screen, then `ShowWindow(SW_MINIMIZE)`, 10 s minimized, in the same run). | Mechanism (riot60, city_bench, before the lever; 2 runs, lock held, 0-2 other Godots): on screen 0.35 / 0.35 -> **minimized 0.56 / 0.61 cores** (+65 %), all on the main thread; 4600 loops in 60 s of sim instead of ~3600. **A/B on the King under combo** (arena, vsync on, 60 s of sim, `--frame-cap=off` = before; order off / on / on / off, lock held, 0 SCRIPT ERROR): minimized **0.73 / 0.75 -> 0.38 / 0.38 cores (-49 %)**; on screen 0.33 / 0.37 vs 0.31 / 0.35 (WASH: the lever does nothing there); loops 4641 / 4633 -> 3637 / 3625 for the same 3593 ticks (last tick 3600 in all four). 2 pairs only (the difference is 10x the spread). Minimized-and-capped (0.38) is still a little over on screen (0.33): the views still step while hidden; pausing on focus loss would be the next cut, but that is a game-design call. | **KEPT** (new baseline): pixel-free by construction (nothing is drawn while minimized; the same ticks), half the CPU for an alt-tabbed player; headless, the tests, the replay, the goldens and every windowed bench that stays on screen cannot see it. Unit 1706 / 0, lint 15/15 at 9a2fcdc8; scenarios + reels in JOURNAL it18. | 9a2fcdc8 |
| L11 | the present mode under a 60 fps limiter at 60 Hz (pacing for less CPU; Call P-3 follow-up) | F15 (it15): at 60 Hz a 60 fps limiter on top of vsync removes the ragged tail (p99 20.4 -> 17.1 ms) for ~+0.1 core. Source read (digest it18): the limiter only `Sleep`s (whole ms, no spin) and the D3D12 fence wait blocks, so no engine path spins. Hypothesis: the extra CPU comes from where the frame work lands relative to the present wait; a mailbox present (`Present(1, DXGI_PRESENT_RESTART)`: still synced, a newer image discards the queued one) paced by the limiter should keep the smooth tail at vsync-only CPU. Expected: `mbx60` p99 ~17 ms at ~0.36 cores (riot). Also re-measure v60 vs v60cap (F15 had 3 contended pairs). On D3D12 `VSYNC_ADAPTIVE` = Enabled (source), so `ada60` is a second copy of `v60cap`: the in-job A-vs-A. | bench only, no project change: arms `v60:` (vsync), `v60cap:--max-fps=60`, `mbx60:--vsync=mailbox --max-fps=60`, `ada60:--vsync=adaptive --max-fps=60` on riot60 + drive60 (editor binary, real time). Mechanism: `tools/perf/thread_cpu.ps1` (new) on one riot60 run per arm, twice (`evidence/perf/l11-present/probe.ps1`, sampled 12-22 s into the run). | `evidence/perf/l11-present/ab.json` (16:16-16:31, bench.lock held, 3 rounds ABBA x 4 arms x 2 scenes, CONTENDED 0-12 in 1-3 of 3 runs per arm, 0 SCRIPT ERROR in 24 runs). **F15 replicates, with a smaller cost:** v60 -> v60cap riot p99 **19.83 -> 16.90 ms**, p99.9 22.6 -> 17.3, worst **35.1 -> 18.4**, skipped tick images 2 -> 0 per 30 s; drive p99 19.78 -> 16.83, p99.9 23.0 -> 17.1; **CPU riot 0.36 ±0.06 -> 0.42 ±0.04 (+0.06), drive 0.22 ±0.08 -> 0.31 ±0.01 (+0.09)**. The A-vs-A (`ada60` = `v60cap`): riot 0.45 vs 0.42, drive 0.28 vs 0.31 cores, so the floor between two copies of the same arm is ±0.03; the limiter's cost is +0.06..+0.09, just above it. **Mailbox:** p99 16.90 / 16.91 ms (= v60cap), CPU 0.41 / 0.29 cores (v60cap 0.42 / 0.31): **WASH**, inside the A-vs-A floor. **Where the extra CPU goes** (`probe-*.json`, 10 s windows): process 0.33 / 0.40 (v60) vs 0.47 / 0.44 cores (v60cap), and **all of the rise is the engine's main thread** ([Godot.exe] start module 0.32 / 0.39 -> 0.45 / 0.43); Godot's worker threads and the driver's own threads (nvwgf2umx, amdxx64) stay under 0.01. Driver code that runs inside `Present` on the main thread is counted there, so engine vs driver is not separated. | **DROPPED** (mailbox no cheaper than the limiter on Enabled). **Call P-3 revised:** the steady pacing costs +0.06..+0.09 core, not +0.1..+0.11 (two jobs now, 6 pairs), and the cost sits on the main thread. No pixel either way; nothing shipped. | none (bench args; `thread_cpu.ps1` in 873070a4) |
| L10 | a frame cap at the sim rate on displays faster than 60 Hz (pacing and power) | F14 (it15 source read): every visible thing steps on the 60 Hz tick: the camera (`CameraRig.follow(tick, ...)`), the cast, the cars, the fx; `SimClock.alpha()` (interpolation) has no reader, and the only per-frame time in a shader is the siren's `TIME`. So on a 120 / 144 / 165 Hz display with vsync on (the project default, no `max_fps`), 50-64 % of the presented frames are a re-render of the same image: full CPU and GPU cost, no new pixel. Expected on a simulated 144 Hz display (vsync off, limiter 144 vs 60): process CPU and GPU busy -50..-60 %, the tick cadence (frames with 0 / 2+ ticks) no worse; at 60 Hz (this PC, both monitors 59.94) a limiter of 60 on top of vsync must not add hitches (the known limiter-vs-vsync beat) or the cap stays off at 60 Hz. No pixel per tick. | bench only first: `city_bench --max-fps=<n>` (was hard reset to 0: the `*60` presets were vsync-capped only, F14) + the tick cadence per frame in BenchStats (`framesNoTick` = duplicate images, `framesMultiTick` = a skipped tick image); ab.mjs carries `frames` / `noTick` / `multiTick`. Arms (riot60, drive60; editor binary, real time): `v60` vsync, `v60cap` vsync + limiter 60, `hz144` vsync off + limiter 144, `hz144cap` vsync off + limiter 60. Then the shipped part: `boot/frame_cap.gd` (FrameCap), set once by the `Game` autoload: limiter = 60 only when vsync is on AND the display reports > 61 Hz AND no explicit `--max-fps` / `--write-movie`; `--frame-cap=off` = the before (`LaunchArgs.KNOWN_FLAGS`); headless and this PC's 59.94 Hz displays: no-op by construction. `test_frame_cap` (4 tests: 144 / 120 / 61.5 Hz capped, 59.94 / 60 / 61 Hz not, vsync off / the flag / an explicit cap kept, headless untouched). | `evidence/perf/l10-cap/ab.json` (15:33-15:48, bench.lock held, editor binary, 3 rounds ABBA x 4 arms x 2 scenes, CONTENDED 0-8 in 2-3 of 3 runs per arm, 0 SCRIPT ERROR in 24 runs; a first job at 15:29 is void: I edited `project/` under it, JOURNAL). **SIMULATED 144 Hz, uncapped -> capped:** riot60 process CPU **0.68 ±0.03 -> 0.42 ±0.03 cores (-38 %)**, drive60 **0.52 ±0.02 -> 0.30 ±0.01 (-42 %)**: WIN; **the King under combo** (`evidence/perf/l10-king/ab.json`, 16:09-16:13, lock held, 3 rounds, engine `--disable-vsync --max-fps 144` vs `60`, CONTENDED 1 of 3 per arm, 0 errors): **0.80 ±0.09 -> 0.47 ±0.04 cores (-41 %)** (its p50 / p99 'LOSS' is the presented interval at the cap, 16.7 ms by design, not a cost); **the shipped release build** (`evidence/perf/l10-exe/ab.json`, it18, windows-bench export of 873070a4, lock held, 3 rounds, 0 errors): riot60 **0.68 ±0.04 -> 0.39 ±0.03 (-43 %)**, drive60 **0.47 ±0.03 -> 0.29 ±0.02 (-38 %)**, duplicate frames 2450 -> 0; frames per 30 s of sim 4201 -> 1682; duplicate frames (`noTick`) **2450 -> 0**; skipped tick images (`multiTick`) 0 -> 0 (the cadence is no worse); draws and working set WASH. GPU ms a frame rises 1.02 -> 2.80 (riot) and 0.62 -> 1.99 (drive): at the lighter load the RTX 4090 clocks down, so a frame's busy time is not its work; GPU energy is not measured and no GPU win is claimed. **At 60 Hz (this PC), vsync -> vsync + limiter 60** (why FrameCap stays off there): CPU riot 0.37 -> **0.48 (+30 %, LOSS)**, drive 0.25 -> 0.30 (LOSS); but the presented p99 20.44 -> 17.11 (riot) and 21.10 -> 17.08 ms (drive), drive p99.9 23.9 -> 19.8 and worst 24.7 -> 20.0, skipped tick images 2 -> 0 and 1 -> 0 per 30 s (riot p99.9 / worst WASH): smoother pacing for ~0.1 core (F15, Call P-3). | **KEPT** (new baseline, the shipped default): on a > 61 Hz display with vsync, ~40 % less process CPU and every duplicate frame gone, the same images per tick (F14: nothing on screen moves between ticks; the siren's `TIME` phase is sampled at 60 Hz instead of 144). On this PC and headless it does nothing, so `top`, the goldens, replay and parity cannot move. The 60 Hz limiter (smoother, +0.1 core) is Call P-3, default off. Real high-refresh hardware is not on this PC: the 144 Hz numbers are a simulation (vsync off + the limiter at 144). | 314632c4 |
| L9 | the render device's transfer-worker staging buffers (RAM) | NEXT 4 (it9): the release exe holds ~690-760 MB working set on a discrete GPU. Source read (4.7.2 `servers/rendering/rendering_device.cpp` `_acquire_transfer_worker`): every texture's initial upload goes through a pool of up to `OS::get_processor_count()` (16 here) transfer workers; each owns a CPU-side (upload heap) staging buffer sized `next_power_of_2(the largest upload it ever took)`, and it is freed only at shutdown (`_free_transfer_workers`). A new worker is made whenever all existing ones are held by other threads, so threaded loads (ResourceLoader threads, L3's prefetch) multiply them. A lossless 3000 x 1500 strip with mips is ~24 MB -> a 32 MB buffer per worker that ever took one. No project setting reaches it (`staging_buffer/max_size_mb` is the other, frame-local pool). Expected: tens to a few hundred MB of the working set; the head build's drive70 +65 MB over main (L3 prefetch, threaded) fits it. Lever: free an idle worker's buffer above 4 MB once its last submit is older than the frame ring; cost a re-allocation on the next large upload (load time only). | engine patch (`tools/perf/template/tw_trim.py`, 31 lines in `rendering_device.{h,cpp}`) on the scratch 4.7.2 tree, MSVC LTO build of the it9 profile; `GTAI_TW_TRIM_MB` (default 4, 0 = stock) and `GTAI_TW_LOG=1` (prints every staging allocation / trim), so ONE binary runs both arms (`ab.mjs` arms take env vars: a third `^` segment). | **Mechanism** (one riot run each, `GTAI_TW_LOG=1`, `evidence/perf/l9-twtrim/mechanism/`): STOCK ends with 4 workers holding 128 + 32 + 32 + 16 = **208 MB of CPU staging** for the whole session; the 128 MB one is ONE texture, the vehicles' `features/vehicles/art/p70/traffic_cards.png` (4032 x 4480, no mips, 69 MB RGBA > 64 MB -> 128 MB), the 32 MB ones are the p70 fall strips (~20-22 MB). **Trim at 4 MB** (`l9-twtrim/`, 18 runs, CONTENDED 2-16 so frame times void; `l9-twtrim-riot/`, riot 4 pairs, 0 contended): Godot's video-memory monitor -160..-220 MB on riot / drive70 / riot60 (WIN), riot60 steady working set 788 -> 574 MB (WIN); but uncontended the riot **p99 was worse in 4 of 4 pairs** (7.77 -> 10.73 ms median) and the steady working set **+60 MB** (746 -> 806, LOSS): every death re-creates a 16-32 MB upload buffer and frees it again (churn). **Trim at 32 MB** (`l9-t32/`, riot + riot60, 3 pairs, CONTENDED 0-4; frees only the outlier): video memory riot 883 -> 771, riot60 851 -> 755 MB (**-96..-112 MB, WIN**), riot60 steady working set 746 -> **686 MB (WIN)**, riot working set WASH, frame times WASH (riot p50 4.24 -> 4.88, slower in 2 of 3 pairs: a cost is not ruled out), CPU at the cap 0.35 -> 0.34 WASH. 0 errors in 44 runs. | **Mechanism FOUND, engine lever NOT a baseline**: the patch needs a custom export template, and on this PC's toolchain a custom template costs ~10 % a frame (L7), far more than the RAM is worth. The 4 MB policy is dropped (churn); the 32 MB policy is the upstream candidate (owner Call P-2: the issue text is in REPORT, not posted). **The same ~96 MB is reachable with the stock engine and no pixel change**: split the p70 traffic sheet so no texture exceeds 32 MB (REQUEST in JOURNAL). | none (engine patch: `tools/perf/template/tw_trim.py`) |
| L8 | the lossless WebP effort of every imported texture (the pck's size) | F10: every texture imports lossless, and a lossless `.ctex` stores WebP lossless (RIFF in the header) at Godot's default effort (`rendering/textures/webp_compression/lossless_compression_factor` 25, `compression_method` 2). Textures are 209 of the 228 MB pck. A higher lossless effort is pixel-free by construction (lossless), costs encode time at import only, and decodes at the same speed. Estimate first (`tools/perf/webp_effort.py`, libwebp via PIL, 30 PNGs spread over the 1221): q25 m2 9.38 MB / 5.6 s encode; q50 m4 -4.5 % / 1.3x; **q75 m4 -5.2 % / 1.7x**; q100 m4 -5.6 % / 3.3x; q75 m5 -6.1 % / 2.9x; q100 m6 -8.4 % / 29x (too slow for every reimport). Expected: pck -5 % (~11 MB), boot and load time WASH, no pixel. | `project.godot` `[rendering]`: `textures/webp_compression/compression_method=4`, `lossless_compression_factor=75.0` (the knee of the curve). The `.import` files do not change; an existing `.godot` keeps its old imports until the textures reimport (delete `.godot/imported/*.png-*.md5`, touch the `.png.import`, `--import`: 31 s for 1214 textures here). | Imported `.ctex` bytes (all 1220): **209.38 -> 196.87 MB (-6.0 %)**, the same on the scratch project and on d9-perf. windows-bench pck 227.71 MB (11:42 export) -> **215.21 MB** (14:05 export of 5ad88dab): -12.50 MB, the ctex delta (12.51 MB) to within 10 kB. **Pixels: `tools/perf/ctex_same.py` decodes every WebP payload of every `.ctex` (6317 payloads: every mip level of 1220 textures) from the old and the new import and compares RGBA bytes: 1220 same, 0 different.** Boot / load time: not A/B'd (decode cost WASH in the estimate: 0.45 vs 0.42 s for the 30-file sample). | **KEPT**: new baseline. A pixel-free 12.5 MB off the pck; costs ~1.7x texture encode at import. | 5ad88dab |
| L7 | a stripped Windows release export template (exe size, boot, RAM) | The official template (109.3 MB) carries 3D physics, Jolt, navigation, XR, networking, video, the 3D import formats and the texture compressors; the game uses none of them (project grep, addons excluded: no physics body/area/ray/shape, no nav, no network, no video, no noise, no mp3; RegEx, ogg, wav used). A template built without them: smaller exe, less to map and initialise at boot, fewer servers ticking (the 2D/3D physics servers step every physics frame even when empty). Expected: exe -40..-60 %, boot -5..-15 %, RAM -10..-30 MB, frame WASH. | Godot 4.7.2-stable source (`gtai-d9x/scratch/godot-src`), deps from the tree's `install_*.py`, `tools/perf/template/strip.py` (SCons profile), MSVC 14.3, no LTO (the official build has LTO: the two templates differ in that too). First build with `disable_3d=yes`: 63.6 MB, but the exe could not parse the scripts that type `QuadMesh` (a 3D primitive mesh resource the 2D MultiMesh crowds use): `disable_3d` stays off; astcenc stays (the static ANGLE links it). Arms: `off@exe:` vs `strip@exe-windows-bench-strip:` (the same pck, md5 equal). Class check (`gtai-d9x/scratch/classprobe`, a 2 kB probe pck that writes `ClassDB.get_class_list()` under each template): official 968 classes, strip 712: 256 removed, none added; **no file under `project/` (game, dev, tests) names any of the 256** (word grep; sanity: MultiMesh added to the list hits 36). | **No-LTO strip, 66.9 MB (-39 %)** (`evidence/perf/l7-strip/ab.json`, 14:12-14:15, bench.lock held, 3 pairs ABBA, CONTENDED 0-4): riot p50 3.50 ±0.08 -> **3.94 ±0.04 ms LOSS (+13 %)**, drive70 2.01 -> **2.19 LOSS (+9 %)**, riot60 CPU 0.26 -> **0.29 cores LOSS**; p99 / p99.9 / worst / render CPU / GPU / draws / VRAM WASH; working set 765 -> 745, 757 -> 744, 754 -> 740 MB (-13..-20 MB, inside the spreads: WASH). 0 errors in 18 runs. Boot (`boot.sh` EXE_B, 7 rounds, lock held, 4 other processes up: CONTENDED): median 2394 vs 2403 ms WASH (spreads 800 / 330 ms). The frame loss is expected from the missing LTO (the official template is a `production=yes` build) rather than from the strip; an LTO build of the same profile (14:17) separates them. | **LTO strip (MSVC `production=yes lto=full`; `production` alone means NO LTO on MSVC, `detect.py`), 74.2 MB (-32 %)** (`evidence/perf/l7-stripl/ab.json`, 14:29-14:33, lock held, 3 pairs, CONTENDED 1-10): riot p50 per pair 3.59 / 4.49 / 3.50 vs **4.51 / 5.59 / 3.98 (slower in every pair, +11..+26 %)**, drive70 2.04 -> 2.22, riot60 CPU 0.26 -> 0.29 cores; working set 754 -> 749, 758 -> **746 (WIN, -12 MB)**, 758 -> 746 MB. Same 712 classes, 0 errors. **Reading: the official Windows template is MinGW-GCC + LTO; an MSVC build of 4.7.2, with or without LTO, is ~10 % slower a frame here, and that hides any strip effect.** | **DROPPED on this toolchain** (no-LTO and LTO): an exe -32..-39 % and ~-10 MB RAM do not pay for a ~10 % frame loss. Retry only with the official toolchain (llvm-mingw / MinGW-GCC + LTO, as the engine's build containers) and an unstripped build of the same toolchain as the A-vs-A. | none (a template is a build artefact) |
| L6 | the render thread model (`--render-thread separate`) | Research (digest, it6): Separate runs the render loop on the WorkerThreadPool; it could take the render CPU (~0.5 ms riot) off the main thread, but the docs still call it experimental and on Forward+ a texture is uploaded on the calling thread in both modes (the strip hitch would not move). Expected: p50 -0..-0.5 ms, more CPU cores, stability risk. | engine arg only (no project change) | `evidence/perf/l5-feed/ab-confirm.json` (13:19-13:22, bench.lock held, 3 rounds, CONTENDED 4-8 in every run): l5sep against l5 (its own code): p50 5.31 vs 5.20, p99 9.36 vs 9.93, p99.9 13.05 vs 14.07, worst 13.95 vs 14.96 ms: all inside the spreads (WASH); **CPU 0.99 -> 1.15 cores (LOSS, spread 0.02)**; draws, render CPU, GPU, RAM WASH. | **DROPPED**: no frame win, +16 % CPU, and an engine mode its own docs call not production-ready. Safe stays. | none |
| L5 | the per-tick snapshot passes (`CityFxFeed.observe` + `CityCharacters._fill_feed`) | F7: on the riot these two passes cost 0.23 + 0.39 ms a tick (debug, scratch spans): `observe` makes one GDScript call per actor record (~400) to find the rare death flip and sweeps all 256 projectile slots for ends; `_fill_feed` allocates a `slice()` (a 14-float PackedFloat64Array) per person in rig range. GDScript's cost is calls and allocations, not arithmetic. Expected: riot p50 -0.15..-0.3 ms (debug), drive and quest 1 ~0 (few people in range), no pixel and no event moves (same events in the same order). | cd227d3f: the death test inlined (a call only on a flip), the end pass walks a sorted live-slot list (`_active`), `_put_person` reads by offset. New unit test: ends fire in slot order and only for the unseen (fails without the sort). Arms: `base:^--path <gtai-d9x/scratch/perf-base>` (ee63589c, the pre-lever project, its own `.godot`), `l5:` (d9-perf). | **Mechanism (13:31, `evidence/perf/l5-feed/out.txt`, headless microbench `micro.gd.txt`: old vs new `observe` in one process on a synthetic riot snapshot, 400 people + 60 projectiles in flight, ~1 death a tick, 8 interleaved blocks of 600 ticks, two processes):** old 201.3 / 208.8 us a tick (block range 178-299), **new 122.8 / 122.0 (range 101-139): -40 %, the ranges do not overlap: WIN**; the per-person `slice()` vs offset read 3.9 vs 2.0 us a tick (negligible). So L5 takes ~0.08 ms off a ~5 ms riot frame (debug), ~1.6 %. **Frame level:** job 1 (`ab.json`, 3 pairs, CONTENDED(4-6) in every run) riot p99 10.47 -> 8.69 and p99.9 15.95 -> 10.69 read WIN, p50 / drive70 / quest1 WASH; job 2 (`ab-confirm.json`, CONTENDED 4-8) p50 5.95 -> 5.20 and p99.9 17.96 -> 14.07 read WIN. **But an A-vs-A (`ab-a-vs-a.json`, the same L5 code in both project dirs, CONTENDED 8-10) read p99 14.27 vs 12.25 "WIN" for the d9-perf dir: the project-dir floor (F12) is as big as those frame moves, so no frame-level win is claimed.** | **KEPT as a small CPU cut, no frame win claimed**: pixel-free (same events, same order; unit test), -80 us a tick of main-thread GDScript on the riot (mechanism measured), frame effect below the noise. Gates in JOURNAL it6. | cd227d3f |
| L4b | BC7 for the street cast + vehicles only (the city's ground and facades lossless); and does BC7 alone remove the first-death hitch? | Call P-1's option (b): most of L4's riot pixel difference sat in the asphalt's print grain (city art), so keeping `features/city/art` lossless should keep most of the VRAM win with less pixel movement. Second question: BC7 loads GPU blocks with no PNG decode, so with BC7 the first-death strip load might be cheap enough that L3 (and its VRAM, F9) could go. Expected: riot peak VRAM ~-25 %; with `--strip-prefetch=off` on the BC7 arm the worst frame near L3's (~18 ms) if the decode was the whole hitch. | second scratch worktree at ee63589c (`gtai-d9x/scratch/perf-bc7cv`, not committed): the 466 `.png.import` under `features/{characters,vehicles}/art` set to BC7, the 246 city ones lossless (23 s reimport, 712 bptc + the city's `.ctex` checked). Arms: `base:` (d9-perf), `nopf:--strip-prefetch=off`, `cv:^--path <cv>`, `cvnopf:--strip-prefetch=off^--path <cv>` | `evidence/perf/l4b-bc7cv/ab.json` (13:09-13:16, bench.lock held, 2 rounds ABBA, 7 of 8 runs uncontended), riot, medians: **peak VRAM base 867, nopf 837, cv 686 (-21 %), cvnopf 629 MB: WIN** (spread <= 44). Worst frame: base 18.0 (12.7 / 18.0), nopf 23.3 (21.6 / 23.3), **cv 19.0 (14.4 / 19.0), cvnopf 23.0 (20.0 / 23.0)**: without the prefetch the BC7 arm keeps the ~20-23 ms first-death hitch, so the PNG decode is NOT the whole hitch (the rest: reading the 4-5 MB `.ctex` + the GPU upload on the main thread). p50 / p99 / draws / CPU / RAM WASH; cv p99.9 17.9 vs 12.2 and GPU 0.44 vs 0.35 ms read LOSS on 2 runs each (tail noise of one run; L4's 2 pairs read GPU WASH): not claimed either way. L3 also costs ~30 MB of VRAM here (837 -> 867). Pixels (13:35, `build/l4blook` method of L4, movie frame 299 at 64 px/m, the lossless arm = perf-base at cd227d3f, A-vs-A floor exact 0 px): riot mean |diff| 3.2/255, 10.3 % of px > 8, **PSNR 26.0 dB (full L4: 24.8)**; the diff map shows the ground and facades exact and the whole difference on the figures' ink outlines (edge pixels, max 248); at x4 by eye the same ink weight and grain (`gtai-masters/d9/perf/l4b-riot64-*`). So the asphalt was NOT most of L4's riot difference (it5's guess, corrected): the figures' edges are. | **OWNER CALL option (b), not a baseline** (pixels move on the characters and the cars). Keeps 55 % of L4's VRAM win (-181 of -329 MB) with the city ground bit-exact. **L3 stays** under any BC7 option: BC7 does not remove the first-death hitch. | none (scratch worktree) |
| L4 | VRAM-compressed (BC7) art for the street cast, the city and the vehicles | F9 + F10: the drawn art sits uncompressed on the GPU (~800-900 MB VRAM on a drive), and each lossless strip is a PNG decode on first use. `compress/mode=2` + `high_quality=true` = BC7 (BPTC) on desktop: 1 B/px instead of 4, loaded as GPU blocks (no decode). Expected: peak VRAM -50..-70 % on the drive and the riot; texture sampling bandwidth down (GPU ms down a little on a 4090, more on an iGPU); the strip decode hitch gone at the root (L3 might become unnecessary); boot/prewarm shorter. Costs: on-disk import 144 -> 304 MB for the 712 textures (BC blocks are not compressed in the pck; Steam's depot compression shrinks the download, not the install), a 73 s reimport, and **pixels move** (BC7 is near-lossless, not bit-exact): an owner Call with close-up stills, never a silent baseline. | the 712 `.png.import` files under `features/{characters,city,vehicles}/art` switched to `compress/mode=2`, `high_quality=true` in a scratch worktree at 2507d642 (`C:/Users/kazda/kiro/gtai-d9x/scratch/perf-before`, not committed); arm `bc7:^--path <that>/project` | `evidence/perf/l4-bc7/ab.json` (12:47-12:48, bench.lock held, 2 pairs ABBA, 7 of 8 runs uncontended; an earlier 3-pair job died at its runner's 10-min limit after 3 runs while it waited for the lock, superseded): **peak VRAM drive70 902 -> 573 MB, riot 883 -> 554 MB (-37 %, spread <= 48): WIN; texture memory 551 -> 191 and 531 -> 186 MB (-65 %): WIN.** Frame p50 / p99 / worst, render CPU, GPU ms (0.24 -> 0.21, 0.46 -> 0.52), draws (293, 832), process CPU and working set: WASH. On-disk import 144 -> 304 MB (pck +160 MB). Pixels (12:56, the same movie frame 299 at 64 px/m from both projects; the run-to-run floor is exact, 0 px): drive mean |diff| 0.94/255, 2.1 % of px > 8, PSNR 29.8 dB; riot mean 3.9/255, 11.7 % > 8, PSNR 24.8 dB, mostly the asphalt's print grain; crops in the masters (`l4-*-lossless-vs-bc7-x2.png`). REPORT Call P-1. | **OWNER CALL, not a baseline** (pixels move). The least-resources lever of the day on this PC: a third of the VRAM, no frame cost. Default kept: lossless (`top` and the look untouched). The switch is one import param per file (a script over `.import`, 73 s reimport). | none (scratch worktree) |
| L3 | the street cast's strips decoded on the frame of a death | Scratch spans inside `city_view._process` (riot, fixed 60, 1826 frames; reverted, numbers in JOURNAL it4): `before_render` 2.24 ms mean, max 22 = `CharacterRigs.step_ticks` (1.33 mean) whose 16-21 ms spikes (frames 4, 91, 174) are all `CutRig.drive -> StreetView.step -> StreetWalkerCards._build`: a synchronous `load()` of the dying person's lossless fall grid (~3000 x 1500 RGBA, 15-28 ms PNG decode) on the main thread, once per row type. Expected: those spikes gone (worst frame down toward the non-death tail), p50 unchanged, a few MB more RAM (strips decoded earlier, never more strips). | `features/characters/street_strips.gd` (StreetStrips): a full rig's card, on its first step, asks `ResourceLoader.load_threaded_request` for its row's fall grid (`StreetWalkerFall.path_of`), and the art's walk grids once; `get_tex` collects it (`load_threaded_get`, or `load()` as before). `test_street_strips`: the same Texture2D object as `load()`. `--strip-prefetch=off` = the before. Top never runs StreetView (a tilt only). | `evidence/perf/l3-prefetch/ab.json`, 3 pairs ABBA in one job, flag arms (off vs on), CONTENDED in 5 of 12 runs (2 other Godots): **riot worst 27.19 ±2.45 -> 17.96 ±1.95 ms: WIN**; p99.9 19.28 -> 17.81 (WASH, spread 2.9), p99 9.95 -> 10.64 WASH, p50 5.15 -> 5.27 WASH, draws 832 = 832, peak RAM 837 -> 853 MB (WASH, spread 31). King (combo, p55 art): WASH on every metric (p50 4.62 vs 4.98 with the pair order reversing it in round 3: noise). Mechanism check (scratch, one riot run): every strip `get` found its texture already decoded (`load()` 0-2 us); a death's StreetView step 15-28 ms -> ~2 ms (the rest is `_build`'s `find_children`). | **KEPT**: new baseline. Unit (street suites) 25/0, lint 15/15; full gates in JOURNAL it4. | 1c115075 |
| L2 | CircleFan's fan build (the corpse soak's one-time draw) | NodeSpans riot (10:52, fixed 60): `draw: corpse_stains.gd` mean 0.70 ms, p99 8.03, max 29.1, while every other row's p99 < 4.4: a soak's single draw builds ~130 engine circle fans point by point in GDScript (~8.5k `_rim()` calls + ~8.3k temporary 3-element Arrays). 17 deaths in 1800 frames = the riot's top 1 %. Expected: the soak draw 5-10x cheaper, the riot p99 down to its non-death tail (~10 ms), no pixel (the same float32 ops). | `features/fx/noir/circle_fan.gd`: a cached float32 unit rim (one multiply + one add a point, the engine's own float32 ops), the index topology cached and sliced, colour runs cached (capped at 64). `test_circle_fan`: every point, colour and index bit-identical to the verbatim old build (40 fans, fractional centres/radii). | NodeSpans (same seed, same 17 deaths): soak draw mean 0.697 -> 0.084, p99 8.03 -> 0.95, max 29.1 -> 3.14 ms. Riot frame, 3 pairs interleaved by swapping the file (CONTENDED 4-7 other Godots, so both arms' p50 rose ~1.5 ms over the baseline): **p99 old 18.25 / 22.16 / 23.05 vs new 12.33 / 11.91 / 11.91: median 22.16 -> 11.91 (-46 %, spread 4.8)**; worst 41.0 -> 30.4 (spread 8.7): WIN; p50 6.92 vs 6.16: WASH; draws 832 = 832. Pixels: 1280x720 riot renders, 510 frames: new vs old differs in 7 frames, old vs old (a rerun) in 17: the warm-up stream (frames 29-43, screen-edge strips: the stream is wall-clock sliced) and 390-391; the 12 deaths' soaks identical. | **KEPT**: new baseline. Unit 39/39 (blood suites), lint 15/15. | 0afd7a88 |
| L1 | renderer + driver | Forward+ on D3D12 pays for 3D clustering a 2D game never uses; Mobile or GL Compatibility could cut render CPU and boot; Vulkan vs D3D12 driver overhead differs. Expected: 0-20 % render CPU, pixel risk (Mobile/GL blend in different precision). | engine args only (`--rendering-method`, `--rendering-driver`), no project change | 3 rounds ABBA, uncapped (table L1). Mobile: King p50 2.82 vs 2.80, p99 6.34 vs 6.40 (WASH), drive70 WASH, riot p50 1.96 vs 1.77 (LOSS), render CPU WASH everywhere, draws equal; King peak RAM 688 vs 724 MB (WIN, -5 %). Vulkan: crashed 8 of 9 runs (F1); the one drive and riot run that lived was 2.5x / 5.4x slower. GL Compatibility: ~2x slower on the King (F2). | **DROPPED**: Forward+ on D3D12 stays. Mobile's RAM saving is too small for its riot loss and a pixel re-bless. | none |

### Table L1 (10:30-10:41, `evidence/perf/l1-renderer/ab.json`; uncapped vsync off, NO fixed fps, so the p50 is mostly frames without a sim tick: see F3; debug editor binary; CONTENDED in 16 of 20 runs, 1-3 other Godots: the other lanes' reel / accent audit / Rivet renders)
| scene | arm | runs | p50 ms | p99 | p99.9 | worst | pace p99 | >25 ms | draws | render CPU | CPU cores | peak RAM MB | contended |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| king | base (Forward+ D3D12) | 3 | 2.80 ±0.08 | 6.40 ±0.54 | 8.91 ±0.89 | 78.65 ±37.22 | 2.65 ±0.17 | 2 ±2 | 640 | 0.36 | 1.01 | 724 ±11 | 3/3 |
| king | mobile | 3 | 2.82 ±0.06 WASH | 6.34 ±0.13 WASH | 9.29 ±0.79 | 11.19 ±2.45 | 2.79 ±0.16 | 0 | 641 | 0.37 | 1.02 | 688 ±5 | 2/3 |
| king | vulkan | 0 | crashed x3 (F1) | | | | | | | | | | |
| drive70 | base | 3 | 1.44 ±0.08 | 3.62 ±1.52 | 5.52 ±3.29 | 13.13 ±12.11 | 2.16 ±2.19 | 0 ±1.5 | 286 | 0.21 | 1.03 | 843 ±12 | 3/3 |
| drive70 | mobile | 3 | 1.46 ±0.03 WASH | 6.53 ±1.71 WASH | 9.32 ±7.75 | 37.66 ±43.55 | 5.71 ±2.77 | 4 ±2.5 | 285 | 0.21 | 0.93 | 766 ±38 | 3/3 |
| drive70 | vulkan | 1 | 3.57 LOSS | 8.80 LOSS | 11.66 | 30.33 | 6.00 | 1 | 289 | 0.23 | 0.63 | 1087 | 1/1 |
| riot | base | 3 | 1.77 ±0.06 | 9.64 ±0.27 | 17.57 ±1.49 | 29.89 ±26.04 | 8.95 ±0.86 | 2 ±1.5 | 827 | 0.45 | 1.01 | 844 ±35 | 3/3 |
| riot | mobile | 3 | 1.96 ±0.07 LOSS | 10.53 ±0.90 WASH | 17.84 ±4.51 | 31.39 ±52.70 | 10.87 ±0.89 | 2 ±4 | 827 | 0.49 | 1.00 | 806 ±45 | 2/3 |
| riot | vulkan | 1 | 9.64 LOSS | 21.50 LOSS | 36.90 | 42.97 | 11.63 | 8 | 836 | 0.61 | 0.52 | 1128 | 1/1 |
(± is half the spread over the runs. "CPU cores" uncapped is ~1.0 everywhere: the uncapped loop keeps one core busy, so it only means something at a frame cap.)

## Tooling built today
- `tools/perf/ab.mjs` + `stats.mjs` + `proc_sample.ps1` (above).
- `--perf-hud` (`project/dev/perf/perf_hud.gd`, PerfHud): the live frame-budget overlay, bottom right:
  the last 240 frames' wall time as bars (amber over 16.7 ms; rules at 8.3 and 16.7 ms), p50 / p99 /
  worst, process and physics ms, render CPU / GPU ms, draw calls, objects, nodes, static and video MB.
  Wired into the dev arena (every `--frames`-capable scene through `FightFrames.attach`) and
  `city_bench.tscn`; `LaunchArgs.KNOWN_FLAGS` has it. Read only (never writes the sim).
- Code levers A/B in one job through a flag arm (it4): the lever reads a launch flag whose `off` value
  is the before (`--strip-prefetch=off`), registered in `LaunchArgs.KNOWN_FLAGS` AND in `city_bench.gd`'s
  own arg list (it rejects unknown args: FRICTION 11:30). No file swap, no class-cache hazard.
- `@exe` arms (it4): `--arms=dbg:,rel@exe:` runs the same preset on the exported `windows-bench`
  release build (`build/export/windows-bench/RTAI-bench.exe`) next to the editor binary; the process
  sampler counts `RTAI*` processes too. bench-kind scenes only (the export drops `dev/bots`, so no King/reel).
- it5: `city_bench` (BenchStats) logs the render GPU ms a frame (`renderGpuMsAvg` / `renderGpuMsP99`, the
  viewport's timestamp queries) and the peak video and texture memory (`vramPeakMb`, `texMemPeakMb`, the
  `Performance` monitors); `ab.mjs` carries both (`gpu`, `vram` in its console rows). Closes the n/m GPU column.
- it5: a project arm needs no runner change: `name:^--path <other project dir>` (the last `--path` wins), so
  an import-setting lever A/Bs from a scratch worktree with its own `.godot` cache (no reimport churn here).
- it18: `tools/perf/thread_cpu.ps1 -ProcessId <pid> [-Seconds 10] [-Delay 0]` (`gtai.thread-cpu/1` JSON): where a
  process's CPU goes, per thread. Two samples of every thread's CPU time, the thread's name (`GetThreadDescription`)
  and the module of its Win32 start address (`NtQueryInformationThread` class 9), grouped by name-or-module: the
  engine's main thread lands on `[Godot*.exe]` / `[RTAI*.exe]`, Godot's own threads on `[msvcrt.dll]` (std threads),
  the GPU driver's on its DLL (`nvwgf2umx.dll` ...). Read-only (query rights). It answers "which thread pays" when
  `ab.mjs`'s process CPU moves (L11).
- n9 it9: `python -I tools/perf/pck_download.py <a.pck> [<b.pck>...]`: the download size of an exported pck as a
  chunked depot store sees it (every 1 MB chunk compressed alone, LZMA preset 6 and zlib 6: the band). Install and
  download move apart once textures are BC7 (section "What ships"). A trial-merge arm: merge the lanes in a scratch
  worktree, export `windows-bench` into `build/export/<dir>/`, and A/B it as `name@exe-<dir>:`.
- Existing instruments reused: `FightFrames` (`--frames=<json>`: per-frame wall, process, flush, draw,
  pump, physics, render CPU/GPU, draw calls, pipeline compiles), `NodeSpans` (`--spans=<json>`: per-node
  `_process` and `_draw` cost: the per-system report), `city_bench.tscn` (`gtai.bench/1`).

## Findings
- **F13 (it12) where the riot's memory sits (release exe, RTX 4090, stock engine; `evidence/perf/l9-t32/` + the L9 mechanism
  log; the split is partly arithmetic, labelled):** Godot's video-memory monitor peaks at 883 MB = textures 531 (`texMemPeakMb`)
  + **transfer-worker staging 208 (L9, logged)** + ~144 other (render targets, MultiMesh / vertex buffers: the remainder,
  not itemised). The monitor counts the CPU-side upload heaps: a trim of them moves it by -112 (32 MB policy) and -222 MB
  (4 MB policy). The process working set (~745 MB steady) = Godot's own allocations ~138 MB (the perf HUD's `mem`,
  `Performance.MEMORY_STATIC`) + the staging pages (resident: the 4 MB trim took riot60's steady set 788 -> 574) + ~400 MB
  of exe image, D3D12 runtime, the GPU driver's user-mode part and its shader cache (the remainder: not split further
  today; a VMMap read is the next tool). **Measured 15:24** (one riot60 run of the head release exe at the 60 fps
  cap, `Get-Process` + the perf counters at t = 22 s, memory only): working set 755 MB = **private 617** + shared / image
  138; commit (private bytes) 1488 MB, mostly never touched. Mapped module images 447 MB over 97 modules: the exe 106,
  the NVIDIA shader compiler `nvgpucomp64` 94, the NVIDIA D3D12 driver `nvwgf2umx` 86, **the AMD iGPU's driver `amdxx64`
  58 (loaded although the game renders on the 4090: D3D12 adapter enumeration)**. So the private 617 = Godot static ~138
  + staging ~208 + ~271 of driver / runtime heaps, thread stacks and audio (not split further). Lesson: on this game the biggest RAM item the project controls is the size of its
  largest texture (it sets a staging buffer per worker), not the total art bytes; the GDScript heap is small.
- F1 (10:27): `--rendering-driver vulkan` without `--gpu-index` crashes at start in `amdxc64.dll` (the
  AMD iGPU's driver) with exit 0xC0000005; `--gpu-index 0` = the RTX 4090 runs. D3D12 (the project's
  driver) picks the 4090 by itself. The shipped exe is on D3D12, so players are not exposed; recorded
  for the handheld lane (an APU-only machine has only the AMD driver).
- F2 (10:31): GL Compatibility on the King fight (one run, 300 ticks, CONTENDED): p50 5.19 ms, p99 10.9,
  against Forward+/D3D12's 2.73 / 5.81 in the same quarter hour: about 2x slower on this host, so it is
  not a candidate here (its value is a GL-only device; that is the handheld lane's call).

- F3 (10:44): **uncapped frame times mostly measure frames without a sim tick.** The riot ran ~400 fps
  uncapped and its frames over 5 ms came every 6-7 frames (gap histogram: 6 x60, 7 x52, 5 x42 of 526),
  i.e. once per 60 Hz tick; the King's p50 2.8 ms is the same artefact. A 60 Hz frame the player sees
  always carries one tick, so from 10:50 every windowed preset runs `--fixed-fps 60 --disable-vsync`
  (one tick per frame, as fast as it can): its wall time is the cost of one gameplay frame. Table L1
  stays valid as an A/B (both arms had the same artefact) but not as the cost baseline.
- F4 (10:49): under `--write-movie` (fixed 60, 1280x800) the King's frame BUSY time read p50 10.7 ms,
  process 8.4 ms on the PerfHud, against 3.75 ms p50 in the fixed-60 baseline: the movie writer's
  run inflates the frame's own work too (PNG encode, cache), so a filmed perf-HUD clip shows its
  numbers RELATIVE (before vs after in the same mode), never as the game's cost.
- F5 (11:03): city_bench renders are not pixel-deterministic run to run (old vs old: 17 of 510 frames
  differ, the warm-up stream at frames 29-43 and 390-391): the stream's time slice is wall-clock. A
  pixel A/B there is judged against an A-vs-A rerun, and an array-identity unit test is the proof.
- F6 (10:52, NodeSpans riot): the steady per-frame owner is `city_view.gd` _process (mean 2.2 ms,
  p99 4.4, max 22 ms); then `city_occlusion.gd` 0.72 ms, `city_blood.gd` 0.57 (p99 2.2). Next lever.

- F9 (12:20, it5 masters, the perf HUD's vram readout, movie mode, CONTENDED): **L3 costs VRAM.** After
  (d9-perf) vs before (main + HUD) on the same frames: King 32 px/m 530 -> 613 MB, drive 32 px/m 802 -> 899,
  drive 48 px/m 777 -> 899. L3 decodes every full rig's fall grid (~18-22 MB RGBA each, uncompressed on the
  GPU) on first sight, not on first death, so strips that never show still sit in VRAM. L3's row measured RAM
  (WASH) but not VRAM: a resource it moved unmeasured. The bench now logs `vramPeakMb`; the measured A/B is L4.
- F10 (12:23, an inventory of every texture `.import`, scratch script): **all 1214 textures import lossless**
  (`compress/mode=0`: PNG/WebP on disk, raw RGBA8 on the GPU), 655 of them mipmapped (+1/3). Resident all
  at once that would be 1.44 GB of VRAM: characters/art 752 MB, city/art 332, vehicles/art 131, weapons 104.
  Biggest single textures: the vehicle traffic card sheets (p70 4032x4480 = 69 MB, p55 38 MB) and ~40
  fall/long-fall grids at 19-22 MB each. A lossless strip is also a PNG decode at load (L3's 15-28 ms).
- F11 (12:34, reasoned, not built): **the mipmaps are live, so dropping them is not free.** The canvas default
  filter is linear without mipmaps (`default_texture_filter=1`), which suggested the 655 mipmapped imports
  (~408 MB if resident) were dead weight; but `PrintStage._ready` sets `TEXTURE_FILTER_LINEAR_WITH_MIPMAPS`
  on the world stage and its children inherit it (and `look_d5_part` / `fx_ink` sample LODs), so the mips
  shape the minified cards. Dropping them moves pixels: a look Call, not a perf baseline. Not pursued.
- F7 (11:27, scratch spans, riot): the rig pose step (`CharacterRigs.step_ticks`, 16-20 full rigs) is
  the riot's largest steady GDScript cost: 1.33 ms mean, p99 2.5 (debug build); `_fill_feed` 0.65
  (`CityFxFeed.observe` 0.23 + the feed loop 0.39), `crowd.observe` 0.14, `chunks.update` 0.10 (max 6.8 =
  one chunk build in the warm-up). Rig code is the rivet lane's today: a lever for after the merge
  (the pose step's rate table or the drive into C++), not touched here.

- F12 (13:29, `evidence/perf/l5-feed/ab-a-vs-a.json`): **a scratch-project arm is not a free A/B.** The same code
  (cd227d3f) from the scratch worktree `perf-base` vs from d9-perf, riot, 3 rounds ABBA, CONTENDED 8-10: p99 14.27
  vs 12.25 ms (beyond the 0.6 spread), p50 / p99.9 / worst WASH, VRAM and RAM equal. Something about the project
  directory (its `.godot` copy, path, file cache) moves the tail by ~2 ms under heavy contention. Consequences: the
  scratch-project rows' VRAM numbers stand (L4 / L4b: 180-330 MB moves; A-vs-A VRAM equal), but a frame-time move
  from a `^--path` arm needs an A-vs-A beside it, or a flag arm in one directory (the L3 way). L5 is judged on its
  mechanism (a microbench) for that reason.

- F14 (it15, source read + the L10 job): **every visible thing steps on the 60 Hz tick.** The camera follows per tick
  (`CameraRig.follow(tick, focus)`), the cast, the cars and the fx step per tick, `SimClock.alpha()` (SIM-08's
  interpolation hook) has no reader, and the one per-frame clock in a shader is the siren's `TIME`. So a frame drawn
  without a new tick is the same image again. The project sets no `max_fps` and leaves vsync on, so a 120 / 144 / 165 Hz
  display renders 2-2.75x the frames for no new pixel. Side finding: `city_bench` reset `Engine.max_fps = 0` in `_ready`,
  so the `*60` presets' engine `--max-fps 60` never applied: those rows were vsync-capped only (numbers stand, label fixed).
  Both monitors on this PC report 59 Hz (`Win32_VideoController`), so every > 60 Hz number here is SIMULATED (vsync off +
  the limiter at the display's rate).

- F15 (it15, `evidence/perf/l10-cap/`): **at 60 Hz, vsync alone presents a ragged tail that a 60 fps limiter on top removes.**
  Vsync-only: presented p99 20.4 / 21.1 ms (riot / drive), 1-3 skipped tick images per 30 s; with `Engine.max_fps = 60` as well:
  p99 17.1 / 17.1 ms, 0 skipped. Reading (not proven): without a limiter the main thread runs ahead and blocks in present, so
  frame starts bunch and an occasional delta crosses two ticks; the limiter spaces the starts. It costs +0.05..+0.11 cores
  (the limiter's `Sleep` wake-ups plus the frame work no longer overlapping the present wait). Kept as Call P-3, not a default.
  **it18 (L11) replication:** 3 more pairs give the same tail (riot p99 19.8 -> 16.9, worst 35 -> 18 ms) for +0.06 (riot) /
  +0.09 (drive) cores against an A-vs-A floor of ±0.03; the rise is all on the main thread (`thread_cpu.ps1`); a mailbox
  present does not make it cheaper.

- F16 (it18, `evidence/perf/l3-prefetch/king-l3-0.json`): the physics frame (`physics_ms`: the physics servers' step plus
  every `_physics_process`) costs **0.015 ms a frame** on the King (mean; max 0.1 ms), 0.3 % of a 5.2 ms frame. A
  dummy-physics-server lever (the game has no bodies, L7) cannot beat the noise: not tried.
- F17 (it18): a minimized window runs ~145 loops a second with no image and more CPU than on screen (L12, kept).
- **F18 (it21, source read, CORRECTS the it18 digest below): the Windows limiter DOES spin.** `OS_Windows` overrides
  `add_frame_delay` (`platform/windows/os_windows.cpp:2630-2675`, 4.7.2): outside low-processor mode it `Sleep`s to one
  `delay_resolution` (= `timeGetDevCaps` `wPeriodMin` x 1000 = 1000 us) short of the target, then **busy-waits the rest
  with `YieldProcessor()`** ("Busy wait for the remainder of time"); only in low-processor mode does it sleep the whole gap
  ("worse frame pacing but more power efficient"). Up to 1 ms of spin per 16.7 ms frame is up to 0.06 core on the main
  thread: the size and the thread of F15's / L11's limiter cost (+0.06..+0.09 core, all main thread). I read
  `core/os/os.cpp` in it18 and missed the override. Lesson: read the platform file before saying "no spin". Lever owed
  (not built today): under MinimizedCap (nothing drawn) low-processor mode would drop the spin for free; on screen it
  trades the spin for Sleep's ~1 ms jitter, so it needs a pacing A/B, not just CPU.
- **F19 (it21, `evidence/perf/l13-menu-idle/{offruns,stall-hunt,pause-head}.jsonl`): quest 1 under `--autostart` FREEZES in
  about 1 run in 4, on this morning's main too.** The quest starts ("started: Rivet is the player's" in the log), then the window
  holds the opening line (Rivet: "Okay", objective 1/6 "Line Stopped"), Esc does not pause, and the process sits at 0.002-0.023
  cores: less than drawing a still card costs (0.03), so the main thread is blocked, not idle. Counts (windowed, editor
  binary): d9-perf with MenuIdle 3 of 10, d9-perf `--menu-idle=off` 4 of 12, d9-perf `--menu-idle=off --strip-prefetch=off`
  (no L3) 1 of 5, **main 3982af1a 1 of 5**; with the window pinned TOPMOST too (so not occlusion). So it is not a perf lever.
  17:39 (`evidence/perf/f19-freeze/`, `hunt.ps1`): a frozen run reads `Process.Responding = false` (a normal run: true) and
  `thread_cpu.ps1` finds **0 CPU on the engine's main thread over 3 s** (process 0.005 cores): the main thread is parked in a
  blocking wait (a deadlock or a wait that never returns), not a slow loop. The waits the main thread can make in our code:
  `features/city/stream/chunk_source.gd` `take()` (`WorkerThreadPool.wait_for_task_completion`), `core/save/save_worker.gd`
  `flush()` / `_collect()` (`Thread.wait_to_finish`; the quest autosaves as it starts), and `ResourceLoader.load_threaded_get`
  (`street_strips.gd` = L3, but L3 off still froze; `city_textures.gd`). Not root-caused (no native stack: the official
  build has no symbols; the session ran out). It is a game bug a player can hit at the first line of the slice;
  REPORT carries it to the owner. Next: `thread_cpu.ps1` + a native stack dump (procdump / `--gpu-validation` off) of a
  frozen run, and the same count on the release export. A CPU number from a windowed quest-1 run must check the run did not freeze.

## Research digest
- Present modes on D3D12 (it18, source read of 4.7.2 `drivers/d3d12/rendering_device_driver_d3d12.cpp`
  `swap_chain_resize`, for L11): `VSYNC_ENABLED` = `Present(1, 0)`; `VSYNC_MAILBOX` = `Present(1, DXGI_PRESENT_RESTART)`
  (still synced to the vblank, but a newer present discards the queued ones, so the queue never holds stale images);
  `VSYNC_DISABLED` = `Present(0, ALLOW_TEARING)`; **`VSYNC_ADAPTIVE` is marked "Unsupported" and falls to `Present(1, 0)`,
  the same as Enabled.** And the limiter (`core/os/os.cpp` `OS::add_frame_delay`): a target advanced by 1e6 / max_fps us
  a frame, clamped to one frame either side of now, slept with `OS_Windows::delay_usec` = `Sleep(us / 1000)` (whole ms,
  truncated; `timeBeginPeriod(1)` at boot). The D3D12 fence wait is `WaitForSingleObjectEx` (no spin). Lessons: on this
  driver an "adaptive" arm is an A-vs-A of "enabled" for free (L11 uses it as the noise floor), and no engine path spins,
  so any CPU a limiter adds is wake-up / scheduling cost or the driver's, which `thread_cpu.ps1` can split.
  **WRONG, corrected by F18 (it21):** the Windows override of `add_frame_delay` spins `YieldProcessor()` for the last
  1 ms of every limited frame; `core/os/os.cpp` is not the path that runs on Windows.
- Frame limiter and pacing (it15): Godot's `Engine.max_fps` docs (stable): limiting the FPS reduces power use; with
  vsync Enabled / Adaptive the refresh rate is the ceiling; on VRR displays a limit a few fps under the refresh cuts input
  lag. The docs' 'Fixing jitter, stutter and input lag' page: jitter is most often a tick-rate vs refresh-rate mismatch;
  interpolation is the fix that makes motion smooth at any refresh, at a latency cost. What it taught here: without
  interpolation a 60 Hz sim shows only 60 images a second at any refresh, so the frames above 60 are pure cost; on a
  120 Hz or VRR display a 60 cap is also the cleanest cadence (2:2 or a 60 Hz VRR refresh), on a fixed 144 Hz display it
  judders the same as uncapped (the same 60 images on a 2-3-2 pattern). Interpolation (SIM-08) is the real smoothness
  lever above 60 Hz: a look change, a Call, not this lane's baseline.
- Godot 4.7.2 source, `servers/rendering/rendering_device.cpp` (`_acquire_transfer_worker`, `_free_transfer_workers`,
  `_submit_transfer_workers`; read it12 for L9): since the 4.4 transfer-worker rework every texture's initial data is
  copied through a per-worker CPU staging buffer of next_pow2(the largest upload that worker took), kept until
  shutdown; the pool grows to the core count under concurrent uploads, and no project setting reaches it
  (`staging_buffer/*` are the frame-local pool). Lesson: on a game with a few huge art sheets, the engine's resident
  CPU memory is set by the single biggest texture times the upload concurrency, not by the art's total size. A
  profile cannot see this (no monitor exposes it); a log line in the engine did (`GTAI_TW_LOG=1` in the L9 patch).
- Godot 4.4 release / dev 3 (godotengine.org, GH-92797): 2D batching came to the RD renderers (Forward+,
  Mobile) in 4.4, so the "Compatibility batches, Forward+ does not" folklore is out of date; the batching
  setting `rendering/2d/batching/uniform_set_cache_size` (default 256) is the knob a maintainer suggested
  raising (GH-98652). Lesson: the renderer choice is an A/B, not a rule; measured above.
- GH-99420 (a user report): Forward+ 2D speed moved between 4.4 dev builds while Compatibility held; 2D
  lights are slow in Compatibility. Lesson: our game has no Light2D nodes (grep), so that cost does not apply.
- Godot renderer docs (4.4): Compatibility is "usually good enough for 2D"; Forward+ for compute.
- Godot docs, "Background loading" (ResourceLoader.load_threaded_request / load_threaded_get /
  load_threaded_get_status): a request decodes on a worker thread and returns the very resource a
  plain load() caches (CACHE_MODE_REUSE), so moving the decode is pixel-free; get blocks only if the
  request is still running. Lesson: a lazy-load hitch is fixed by asking earlier, not by loading
  everything at boot (all fall grids decoded = ~25 x 18 MB raw).
- Size lever research (it4, for NEXT 5): Godot docs "Using the engine compilation configuration editor"
  (Project > Tools: detects the classes a project uses, saves a `.gdbuild` build profile, passed to SCons
  as `build_profile=` when compiling a custom export template; unchecking does nothing without the
  compile) and "Optimizing a build for size" (`optimize=size`, `size_extra` from 4.5, `disable_3d`,
  module switches). Caveat that bites us: detection does not see classes used only from a GDExtension
  (our CitySim) or from runtime-built scripts, so the profile needs a hand review + the full gates on the
  custom template. One community write-up (popcar.bearblog.dev, "How to Minify Godot's Build Size"):
  Windows template 92.8 MB -> 44.0 MB with 3D off -> 33.6 MB with more modules off (one project, not a
  benchmark). Our stock template is 109.3 MB, so the expected gain is ~60-70 MB of exe, plus boot time
  (less to map); the cost is a template compile (~30-60 min) per platform and a CI/export change.
- Render thread model (it6, a research sub-agent over the docs and the engine source, 4.3-master):
  `rendering/driver/threads/thread_model` = Safe (default) or Separate (the render loop on the
  WorkerThreadPool, PR #90268); `--render-thread safe|separate` sets it per run (also in release templates).
  The class reference still marks Separate experimental ("not recommended for use in production"), and
  open issues include a D3D12 Forward+ shutdown error that drops the pipeline cache (#119000: shader
  stutter back on the next run) and glyph-atlas upload races (#122206). From the 4.5 source: on Forward+
  a `texture_2d_create` uploads on the calling thread in both modes, so Separate would NOT move the
  first-death strip upload off the main thread (only `load_threaded_request` does: L3). No measured 2D
  gain found anywhere. Lesson: a one-arm A/B is cheap (an engine arg), but even a win would be a
  stability Call, not a baseline.
- Stripped templates in practice (it9, from building one): the 4.7 source tree ships its own dependency installers (`misc/scripts/install_d3d12_sdk_windows.py`, `install_accesskit.py`, `install_winrt.py`, `install_angle.py`); under Git Bash (`MSYSTEM` set) they install into the tree's `bin/build_deps`, which SCons then finds by the same rule. `disable_3d` is broader than "no 3D nodes": it removes `scene/resources/3d`, including the primitive meshes (`QuadMesh`) a 2D MultiMesh uses, so a 2D game that types `QuadMesh` needs 3D kept or a `build_profile` that names classes instead. The static ANGLE links astcenc. A non-`production` MSVC build has no LTO, and that alone can cost ~10 % frame time against the official LTO template: a template A/B must match `production=yes` or it measures the compiler, not the strip. The engine's own class list (`ClassDB.get_class_list()` from a probe pck run under each template) is the exact removed set to grep the project against.
- Lossless WebP effort (it9): libwebp's lossless `quality` is effort, not loss (0-100), `method` 0-6 trades encode time for size; decoding speed barely moves. Godot exposes both as `rendering/textures/webp_compression/*` and applies them to every lossless `.ctex` at import. Measured knee on this art: q75 m4 (-5..-6 %, 1.7x encode); q100 m6 is -8 % at 29x.
- Registry: `perf-regression-gating` (cost is busy time measured uncapped; interleave base and head;
  the presented interval is a delivery bar, not a cost gate), `render-submission-economy` (counts A/B
  anywhere, ms only on the host; the order of moves: cull, batch, retain, spread bursts, then the look),
  `measurement-honesty` (CONTENDED per run; unmeasured is never zero; no win inside the noise).
