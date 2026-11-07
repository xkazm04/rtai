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

## Iteration 4 (11:19-12:19, BUILD)
- Read: JOURNAL, LEDGER, git log, d9-handheld JOURNAL (answered my tooling REQUEST: their runners overlap;
  L2 waits for the merge; lever back: zoom_k 1.5 = a look change, not chased), d9-seams/rivet (no REQUEST to perf).
- Registry rules applied it4: perf-instrumentation (split the owner before fixing: a span per call inside
  the hot _process, then per rig stage, then per drive stage: measure down to the line, never guess),
  render-submission-economy ("spread bursts": a one-off decode moved off the frame, the picture unchanged),
  perf-regression-gating (ABAB, flag arms in one job), measurement-honesty (the spike frames named by index).
- GATE 11:25 director reel at 8ea5ba90 (L2 inside), headless `--fixed-fps 60 --quit-after 14000
  res://dev/arena/arena.tscn -- --bot=reel --reel=director --loadout=pistol --rigs --view=<v>`:
  top 19/19, tilt70 19/19, combo 19/19 chapters all down, 0 SCRIPT ERROR (`evidence/perf/reel-l2/*.log`).
- 11:27 L3 profile (scratch spans, reverted; riot fixed 60, windowed, 1826 frames): city_view _process =
  place_camera 0.25 mean / chunks 0.10 (p99 1.6, max 6.8 = a chunk build at frame ~40) / prop_lights 0.003 /
  before_render 2.24 (p99 4.0, max 22) / write_render 0.03. before_render = _fill_feed 0.65 (fx_feed.observe
  0.23 + the feed loop 0.39 + snapshot 0.03) + crowd.observe 0.14 + CharacterRigs.step_ticks 1.33 (p99 2.5,
  max 20.6). The step_ticks spikes (frames 4, 91, 174: 16-21 ms) are ALL in CutRig.drive ->
  StreetView.step -> StreetWalkerCards._build -> a synchronous `load()` of a ~3000x1500 RGBA lossless fall
  grid on the frame a person dies (15-28 ms PNG decode); the walk grids cost 7-9 ms on first use.
- FINDING F7: the rig pose step (CharacterRigs.step_ticks, 16-20 full rigs) is the riot's biggest steady
  GDScript cost (1.33 ms mean, debug build). Rig code is rivet's today: a candidate for after the merge.
- 11:33 L3 built: `StreetStrips` (features/characters/street_strips.gd): a worker-thread
  `ResourceLoader.load_threaded_request` of each full rig's fall grid when its card is first stepped
  (+ the art's walk grids once); `get_tex` returns the same Texture2D as load(). `--strip-prefetch=off` =
  the before. Top untouched by construction (StreetView only runs under a tilt).
- FRICTION 11:30: city_bench validates its own user args: a new A/B flag must also go into its KNOWN list
  (first L3 job died on the off arm; lock released by hand: it was mine, pid 37580 gone).
- MILESTONE 11:36 (1c115075) L3 KEPT: riot worst 27.19 -> 17.96 ms (WIN beyond the 2.45 spread), p50/p99/p99.9
  and the King WASH, draws equal, RAM +16 MB (WASH). Mechanism checked (scratch): each death's card step
  15-28 ms -> ~2 ms, every strip found decoded. `evidence/perf/l3-prefetch/ab.json`. DECISION line in docs/decisions.md.
- 09e6c713 `@exe` arms in ab.mjs (the release-export baseline); presets king60/drive60/riot60 (vsync + 60 cap:
  CPU cores and RAM at the player's cap).
- GATE 11:41 at 1c115075: unit full 1697/0 (`evidence/perf/unit-1c115075.log`); director reel top/tilt70/combo
  19/19 chapters all down, 0 SCRIPT ERROR (`evidence/perf/reel-l3/`). Lint 15/15 (debt ratchet: city_bench's
  new flag line paid for by a shorter usage comment).
- REQUEST to rivet (perf, numbers attached; answer welcome in your JOURNAL): your whole-figure frames and the
  equipped sheets (one per weapon) are big textures. On the riot, a lazily `load()`ed ~3000x1500 lossless
  strip cost 15-28 ms on the main thread the first time it showed (a visible hitch at every first death:
  LEDGER L3). Please load Rivet's sheets at the loading screen or ask for them on a worker thread before
  they show (`StreetStrips.prefetch(path)` / `get_tex(path)` on d9-perf 1c115075 does exactly that: same
  Texture2D, no pixel moves), never on the frame a weapon is first drawn. And the rig pose step is the riot's
  largest steady GDScript cost (`CharacterRigs.step_ticks` 1.33 ms mean debug, F7): keep per-step work behind
  once-per-card guards. I will A/B your branch's King fight and the reel when you say it is ready.
- 11:45-11:49 RELEASE BASELINE (LEDGER "Release-export baseline", `evidence/perf/rel-vs-dbg/`, CONTENDED 8-17):
  windows-bench exported at 87155de9 (256 chunks baked first). Release vs editor: riot p50 5.33 vs 6.72 (WIN),
  RAM 681 vs 851 MB; drive70 p50 2.90 vs 3.70 WIN but p99 8.41 vs 5.78 and worst 17.0 vs 10.2 LOSS (F8);
  riot at vsync + 60 cap: 0.41 cores vs 0.49, 675 vs 913 MB. Boot+1 frame: exe 2.86 s vs editor 4.35 s.
  exe 109.3 MB + pck 227.7 MB.
- FRICTION 11:46: `--export-release` templates refuse a scene path (disable_path_overrides): the bench export
  boots city_bench itself; @exe arms now drop the scene. And evidence/run.mjs fails on an untracked file in
  evidence/ (twice, ~4 min): scratch output goes to build/ while it runs, and no tracked edits during it.
- GATE 11:52 `node tools/evidence/run.mjs --no-bench` at 87155de9: lint ok, unit 1697 / 0 failures, scenarios 52
  ran / 0 failed, parity exact (max_abs_diff 0), look goldens 11/11 ok (top unchanged). release_compile BLOCKED
  again on %TEMP%\gtai-release-compile (not mine; seams' per-worktree fix lands with their merge).
- 11:54 F8 chased: NodeSpans on the exe vs the editor (drive70) showed the exe's SCRIPTS cheaper while its frames
  were 4x slower, swap up to 47 ms. Cause: the exe has no override.cfg, so its window opened on the primary
  ultrawide where present blocked (p50 12-17 ms); with `--screen 0` the same exe: p50 2.50, p99 4.1-4.4.
  F8 RESOLVED as a placement confound; every preset + boot.sh pin `--screen 0`.
- MILESTONE 12:00 RELEASE BASELINE (rerun, `evidence/perf/rel-vs-dbg-screen0/`): release exe riot p50 4.08 / p99 7.24
  / p99.9 8.74 / worst 9.65 (all WIN vs the editor's 5.78 / 9.30 / 12.28 / 13.95); drive70 p50 2.46 vs 2.95 WIN, tail
  WASH; riot at the 60 cap 0.29 cores vs 0.36, 758 vs 912 MB. Watch: riot60 exe worst 33.6 ms (presented hitch).
- Registry rules applied (late it4): measurement-honesty (an arm that differs in more than the lever is not an
  A/B: the monitor was a hidden second variable; the superseded table kept, marked), perf-regression-gating
  (the build under test is the shipped build: debug overstated the riot's cost ~40 %).

NEXT (iteration 5):
1. Masters (owed deliverable): King fight + city drive clips with `--perf-hud`, before (main 3982af1a: a worktree
   or `--strip-prefetch=off` for L3; L2 has no flag) / after, 32 px/m + a 48 or 64 close-up, frames.json in
   `C:\Users\kazda\kiro\gtai-masters\d9\perf\`; numbers in movie mode are RELATIVE (F4).
2. riot60's exe worst frame (33.6 / 24.3 ms at the cap): run the exe with --perf-hud at vsync + 60, find the hitch.
3. Next CPU lever (F7 split, unowned files): `CityFxFeed.observe` 0.23 + the feed loop 0.39 ms (no slice per
   person, fused kind filter) - small; measure on the exe (`rel@exe` vs a second export) since debug overstates.
   The big one is the rig pose step (F7, rivet's files): REQUEST sent; after their merge.
4. Quest 1 in the runner (quest1_frames.gd writes no series) and the King/reel on a release build (a bench
   export that keeps dev/bots, or a `windows-perf` preset): the King's release number is unmeasured.
5. Size lever: a custom export template without unused modules (exe 109 MB): research the 4.7 build profile
   (`build_profile` / the engine compilation configuration editor) and the compile time first.
6. release_compile: re-run the evidence once seams' per-worktree temp dir lands (blocked twice today, not mine).
- 12:06 MASTERS started: `C:\Users\kazda\kiro\gtai-masters\d9\perf\riot-l3-off-vs-on.mp4` (+ off/on singles, the end
  still, frames.json 3 entries): the riot with --perf-hud, L3 off vs on, 1280x720 movie mode. Looked at the end
  still: same scene both sides; HUD worst 18.9 vs 13.8 ms (RELATIVE, F4). The HUD's right edge clips at 1280 px
  (the vram readout): a PerfHud placement fix is owed. The King + city drive pair (before = main) is still NEXT 1.
- Boot rerun on one screen (12:02): exe median 2.58 s vs editor 4.08 s (LEDGER). Size research in the digest.
- 12:12 FRICTION: PerfHud clips on the right in a 1280-wide movie (window 1280x800). Sizing the panel to its widest
  line did NOT fix it (still clipped: the viewport rect and the drawn space disagree, likely the stretch mode
  / content scale): reverted, owed with a look at `get_viewport_rect()` vs `get_visible_rect()` under the stretch.
- NEXT addendum: 7. PerfHud clipping (above), before the King/drive masters are filmed (NEXT 1).
