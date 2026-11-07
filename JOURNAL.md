# JOURNAL - lane perf, day run d9 (2026-11-07)

Branch `d9-perf`, cut from main `3982af1a`. Ledger: `docs/perf/LEDGER.md`. Evidence: `evidence/perf/` +
`C:\Users\kazda\kiro\gtai-masters\d9\perf\`.

## Iteration 3 (10:21-11:21) - the first live session (iterations 1 and 2 died on billing in 4-8 s)

- 10:25 read: STANDARDS section 20 (budgets), AGENTS, the decisions tail, the n8 view JOURNAL's King-fight
  bench (it9-it10: `--frames=<json> --frames-ticks=1500`, top/combo alternated, CONTENDED), the d6
  perf-city REPORT (5 pixel-identical fixes, the present-phase hitches, the 4 s process-age stall,
  swapchain 3 -> 4 rejected). Existing instruments: `FightFrames` (arena `--frames`), `NodeSpans`
  (`--spans`), `city_bench.tscn` (`gtai.bench/1`), `quest1_frames.gd`, `tools/bench/run.mjs` (the
  exported windows-bench release, judged against section 20).
- Registry rules applied: perf-regression-gating (cost measured uncapped, vsync off; A and B interleaved
  in one job so drift lands on both, no stored cross-machine baseline; the settle window cut; no win
  claimed inside the spread), render-submission-economy (a draw-call count is load-independent, so it
  A/Bs on a busy machine; ms are host ms only, never device ms; order of moves: cull, batch, retain,
  spread bursts, then the look), measurement-honesty (CONTENDED stamped per run, unmeasured != 0).
- 10:30 machine: another lane's headless director reel (pid 48568, combo) was up; bench.lock free.
- 10:23 built `tools/perf/ab.mjs` + `tools/perf/stats.mjs`: interleaved A/B over scene presets (king,
  reel, drive70, riot, drive70h), arms = extra user args, ABBA order, bench.lock, CONTENDED per run,
  p50/p99/p99.9/worst/pacing/over25 + draws/render CPU/GPU, verdict WIN/LOSS only beyond the spread.
- 10:24 smoke (1 run each, CONTENDED(2-4), debug editor binary, windowed d3d12 1920x1080 vsync off):
  king combo p50 2.78 / p99 6.00 / worst 11.2 ms, 640 draws; drive70 1.35 / 3.20 / 69.5, 285 draws;
  riot 1.79 / 9.34 / 31.4, 828 draws. The riot's p99 9.34 is over section 20's 7 ms (debug build: owed
  a release-export check before calling it a regression).
- FRICTION 10:26: editing a .gd that names a NEW class_name while my A/B ran on this worktree would
  break its later runs (class cache): reverted the hooks to a patch, re-applied after, ran --import.
  Rule for me: no project edits while a job runs here; tools/ and docs/ only.
- 10:27 FINDING F1: `--rendering-driver vulkan` crashes in amdxc64.dll (the AMD iGPU driver) at start,
  also with `--gpu-index 0` inside the A/B (one standalone probe with --gpu-index 0 ran on the 4090):
  enumeration is flaky on this host. D3D12 picks the 4090 itself.
- 10:31 FINDING F2: GL Compatibility, King 300 ticks, 1 run: p50 5.19 / p99 10.9 vs Forward+ 2.73 / 5.81:
  ~2x slower here. The first compat run inside the A/B hung > 2 min with no log (not reproduced).
- 10:33 the King frame split (smoke, mean ms after the first second): wall 3.14 = _process 1.28 +
  flush (queued _draw) 1.07 + RS draw 0.77; sim loop 0.09, physics 0.002, GPU 0.23. GDScript canvas
  work is ~2/3 of the frame: the next lever comes from NodeSpans (`--spans`) on the King and the riot.
- 10:28 built `tools/perf/proc_sample.ps1` (CPU cores, peak working set, threads of the runner's Godot
  processes; one CIM query a second) + `--perf-hud` (PerfHud, dev/perf). Node tests 8/8.
- 10:41 L1 renderer A/B done (3 rounds ABBA, king/drive70/riot, uncapped; LEDGER table L1): Mobile WASH
  on King + drive70, LOSS on riot p50 (1.96 vs 1.77), King RAM -5 %; Vulkan crashed 8/9 (F1) and was
  2.5-5x slower in the runs that lived. DROPPED: Forward+ D3D12 stays. No DECISION line (nothing changed).
- 10:44 FINDING F3: uncapped frames mostly carry no sim tick (riot ~400 fps, the >5 ms frames every 6-7
  frames = once per 60 Hz tick). Presets now run `--fixed-fps 60 --disable-vsync` = the cost of one
  gameplay frame. Committed 6b5b1428 (tools/perf), 85f7308c (--perf-hud; looked at it on the King
  fight at combo 1280x800 frame 230: bottom right, clear of the ghost card and the boss bar).
- 10:50 baseline-fixed running: king, drive70, riot, reel(3600 ticks, tilt70) x3, base only.
- 10:50 BASELINE (fixed 60, debug editor, 11/12 UNCONTENDED; LEDGER "Baseline"): king p50 3.75 / p99 7.40;
  drive70 2.52 / 5.12; riot 4.45 / 14.55 / p99.9 27.3; reel 4.37 / 10.17.
- 10:52 NodeSpans riot: `draw: corpse_stains.gd` p99 8.03, max 29.1 ms (the soak's one-time CircleFan
  build); city_view.gd the steady owner (2.2 ms mean). LEVER L2 hypothesis written before building.
- MILESTONE 11:06 (0afd7a88) L2 KEPT: CircleFan from a cached float32 unit rim + index topology +
  colour runs; bit-identical arrays (test). Soak draw p99 8.03 -> 0.95; riot p99 22.16 -> 11.91 ms
  interleaved (CONTENDED 4-7, spread 4.8); p50 wash. Pixels: new vs old 7/510 frames differ, old vs
  old 17/510 (F5: city_bench's stream is wall-clock sliced): inside the scene's own noise.
- FRICTION 10:58: no code-level A/B switch for L2: interleaved by swapping the file between runs (no
  class change, so no cache trouble). Owed: a `--ab-*` style flag pattern for code levers.
- Registry rules applied it3: perf-regression-gating (interleaved ABAB, fixed-step cost not the
  presented interval, the movie-mode numbers called relative), render-submission-economy (retain:
  the soak is already retained, so the lever was the one-off build cost of the retained picture;
  the picture is the invariant: arrays proven identical, not "looks the same"), measurement-honesty
  (CONTENDED stamped; the city_bench pixel compare judged against an A-vs-A rerun, not against zero).
- 11:08 GATE unit full no-arg at 0afd7a88: 1692 passed / 0 failed (`evidence/perf/unit-0afd7a88.log`).
  Lint 15/15 at every commit (the hook). `node tools/evidence/run.mjs --no-bench` running at 0d3b0d56.
- REQUEST to handheld (tooling share, answer welcome either way): `tools/perf/ab.mjs` (interleaved A/B,
  scene presets king/drive70/riot/reel at fixed 60, arms with `^<engine args>` so a device profile is
  just engine args, e.g. `deck:^--resolution 1280x800 --rendering-method mobile`), `proc_sample.ps1`
  (CPU cores + peak RAM of the run) and `--perf-hud` (dev arena + city_bench) are on d9-perf. And:
  L2 (0afd7a88, CircleFan) cut the riot's death spikes ~8x on this host's CPU: it is a pure CPU win,
  so it should carry to a Deck-class CPU too; please take it into your device numbers. Send me any
  lever that wins on your profile and I will A/B it here.

NEXT (iteration 4):
1. (done 11:17, green except release_compile: see GATE above.)
2. Director reel 19/19 in top, tilt70, combo with `--quit-after 14000` at the L2 head (combat must not regress).
3. Lever L3: `city_view.gd` _process (riot mean 2.2 ms, p99 4.4, max 22) = chunks.update + prop_lights.update
   + sim.write_render (native) + fx/glow/ground/lights/markers.step + noir: NodeSpans splits it no further,
   so add a span inside (or read the code: what runs per tick for 400 actors) and A/B the smallest fix.
   Also `city_blood.gd` (p99 2.2) and `city_occlusion.gd` (0.72 mean).
4. A code-lever A/B switch: arms swap a file today; build `--ab-<lever>` flags or a worktree pair so
   code levers interleave without hand swaps.
5. The release-export baseline (`windows-bench` export + the same presets on the exe) and quest 1 in the
   runner; the process CPU % at a 60 fps vsync cap (sampler ready); boot time to first frame; pck size.
6. Masters: King fight + city drive before/after clips with --perf-hud (movie numbers RELATIVE, F4),
   frames.json in `C:\Users\kazda\kiro\gtai-masters\d9\perf\`.
- GATE 11:17 `node tools/evidence/run.mjs --no-bench` at 0d3b0d56 (L2 inside): lint ok, unit ok, scenarios
  52 ran / 0 failed (city_chase missed its wall budget under contention and passed re-judged alone),
  parity exact (max_abs_diff 0, planted mutation caught at step 629), selftest ok, look goldens 11/11 ok.
  BLOCKED (minutes, not mine): the run then died in `release_compile` on
  `%TEMP%\gtai-release-compile` (created by another worktree, no marker): the seams lane's item
  (their 6e49a298 makes the dir per worktree + process); the release-compile evidence comes with their merge.
  Log: `evidence/perf/evidence-0d3b0d56.log`. Director reel x3 views still owed (NEXT 2).
