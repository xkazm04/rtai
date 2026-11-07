# Perf LEDGER - lane perf, day run d9 (2026-11-07)

Branch `d9-perf`, cut from main `3982af1a`. Every number here names its build, scene, machine state and
instrument. Host: Ryzen 7 7800X3D (8C/16T), RTX 4090 (+ the AMD iGPU), Windows 11, Godot 4.7.2.
**Host ms are host ms**: nothing here is a Steam Deck or handheld figure (that is the `handheld` lane's).

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

## Levers
| # | lever | hypothesis / expected | change | A/B (median, spread) | verdict | commit |
|---|---|---|---|---|---|---|
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
- Existing instruments reused: `FightFrames` (`--frames=<json>`: per-frame wall, process, flush, draw,
  pump, physics, render CPU/GPU, draw calls, pipeline compiles), `NodeSpans` (`--spans=<json>`: per-node
  `_process` and `_draw` cost: the per-system report), `city_bench.tscn` (`gtai.bench/1`).

## Findings
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

- F7 (11:27, scratch spans, riot): the rig pose step (`CharacterRigs.step_ticks`, 16-20 full rigs) is
  the riot's largest steady GDScript cost: 1.33 ms mean, p99 2.5 (debug build); `_fill_feed` 0.65
  (`CityFxFeed.observe` 0.23 + the feed loop 0.39), `crowd.observe` 0.14, `chunks.update` 0.10 (max 6.8 =
  one chunk build in the warm-up). Rig code is the rivet lane's today: a lever for after the merge
  (the pose step's rate table or the drive into C++), not touched here.

## Research digest
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
- Registry: `perf-regression-gating` (cost is busy time measured uncapped; interleave base and head;
  the presented interval is a delivery bar, not a cost gate), `render-submission-economy` (counts A/B
  anywhere, ms only on the host; the order of moves: cull, batch, retain, spread bursts, then the look),
  `measurement-honesty` (CONTENDED per run; unmeasured is never zero; no win inside the noise).
