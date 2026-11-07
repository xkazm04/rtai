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

## Levers
| # | lever | hypothesis / expected | change | A/B (median, spread) | verdict | commit |
|---|---|---|---|---|---|---|
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

## Research digest
- Godot 4.4 release / dev 3 (godotengine.org, GH-92797): 2D batching came to the RD renderers (Forward+,
  Mobile) in 4.4, so the "Compatibility batches, Forward+ does not" folklore is out of date; the batching
  setting `rendering/2d/batching/uniform_set_cache_size` (default 256) is the knob a maintainer suggested
  raising (GH-98652). Lesson: the renderer choice is an A/B, not a rule; measured above.
- GH-99420 (a user report): Forward+ 2D speed moved between 4.4 dev builds while Compatibility held; 2D
  lights are slow in Compatibility. Lesson: our game has no Light2D nodes (grep), so that cost does not apply.
- Godot renderer docs (4.4): Compatibility is "usually good enough for 2D"; Forward+ for compute.
- Registry: `perf-regression-gating` (cost is busy time measured uncapped; interleave base and head;
  the presented interval is a delivery bar, not a cost gate), `render-submission-economy` (counts A/B
  anywhere, ms only on the host; the order of moves: cull, batch, retain, spread bursts, then the look),
  `measurement-honesty` (CONTENDED per run; unmeasured is never zero; no win inside the noise).
