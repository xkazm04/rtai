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

## Iteration 5 (12:10-13:10, BUILD)
- Read: JOURNAL it4 + NEXT, git log, d9-rivet / d9-seams / d9-handheld journals: no new REQUEST to perf; rivet has
  not answered the it4 REQUEST (strip loading off the draw frame, F7) yet. Registry rules applied this session:
  measurement-honesty (F9: a lever's row must name every resource it moves; L3's VRAM was unmeasured),
  render-submission-economy (texture residency before draw counts), perf-regression-gating (L4 interleaved,
  arms that differ only in the import settings).
- 12:15 PerfHud "clipping" (NEXT 7) RESOLVED, no code change: `--resolution 1280x720` makes a 1280x720 window
  (canvas 1422x800 under stretch `expand`) while Movie Maker records the project's 1280x800, so the right
  ~140 canvas px fall off the movie. Filmed without `--resolution`, the HUD sits inside (diag logged, reverted).
- MILESTONE 12:21 MASTERS (NEXT 1): King under combo at 32 and 48 px/m, the city drive (drive_dense, tilt70) at 32
  and 48 px/m, before (main 3982af1a + the HUD commit, scratch worktree `gtai-d9x/scratch/perf-before`) vs after
  (d9-perf ce08ac63), side by side, perf HUD, movie mode 1280x800, CONTENDED (2-4 other Godots), 0 SCRIPT ERROR
  in all 8 runs. `C:\Users\kazda\kiro\gtai-masters\d9\perf\` (frames.json 9 entries). Looked at all four end
  stills: same frames; busy time WASH (as the A/B said: L2/L3 aim at the riot); VRAM higher after (F9).
- ce08ac63 city_bench logs render GPU ms; 2507d642 peak VRAM + texture memory (ab.mjs prints gpu / vram).
  Debt ratchet: both accepted with a reason (dev/bench +14 lines of tooling).
- F9 / F10 (LEDGER): L3 costs ~+80-120 MB VRAM; every texture in the game imports lossless (1.44 GB if all
  resident). L4 = BC7 for characters/city/vehicles art, in a scratch worktree (712 imports, 73 s reimport):
  A/B queued behind handheld's bench.lock (held since 12:11).
- FRICTION 12:37 (~10 min lost): the first L4 A/B job was killed by my own background-task limit (10 min) after 3
  runs, because it spent 8 of them waiting for handheld's bench.lock; the lock file it held was mine (pid gone),
  removed by hand. Rerun with a 25-min limit. Lesson: a lock-waiting job needs the long timeout from the start.
- 12:47 quest 1 in the runner (fc90bcd2): preset `quest1` (quest1_frames writes wall_ms). Not yet run.
- MILESTONE 12:48 L4 measured (`evidence/perf/l4-bc7/ab.json`, lock held, 2 pairs): BC7 for the street cast,
  city and vehicles art: peak VRAM drive70 902 -> 573 MB, riot 883 -> 554 (-37 %); texture memory -65 %;
  frame times, GPU, draws, CPU, RAM WASH. Pixels move (BC7): OWNER CALL, default lossless kept.
- F11: mipmaps are live (PrintStage samples LINEAR_WITH_MIPMAPS): dropping them is a look change, not pursued.
- REQUEST to handheld (perf, numbers attached): L4 is a device-budget lever more than a desktop one: BC7 art cuts
  the riot's peak VRAM 883 -> 554 MB and texture memory 531 -> 186 MB at no frame cost on this PC (LEDGER L4).
  On a shared-memory handheld that is ~330 MB of RAM back. The arm is reproducible: a scratch worktree with the
  712 `features/{characters,city,vehicles}/art/**/*.png.import` set to `compress/mode=2` + `high_quality=true`
  (73 s reimport), A/B'd through `ab.mjs` with `bc7:^--path <worktree>/project`. If you have an iGPU/deck row,
  a BC7 arm there would say whether the GPU side moves where bandwidth is scarce (it did not on the 4090).
- MILESTONE 12:56 L4 look: same movie frame from both projects at 64 px/m (floor exact): drive PSNR 29.8 dB, riot
  24.8 dB (the asphalt grain mostly). Looked at both crops: figures and ink read the same. Masters frames.json 11.
  REPORT.md started at the lane root: Call P-1 (BC7, default lossless). DECISION line in docs/decisions.md.
- The scratch worktree `C:\Users\kazda\kiro\gtai-d9x\scratch\perf-before` (detached, 712 import edits, BC7 .godot)
  stays for the next A/Bs (quest 1, the King under BC7); remove it with `git worktree remove --force` at the freeze.

NEXT (iteration 6):
1. L4 option (b): BC7 for characters + vehicles only (city ground lossless): measure VRAM and the riot PSNR alone;
   and BC7's effect on the strip decode hitch with L3 off (`--strip-prefetch=off` on the BC7 arm): if the death
   spike is gone without L3, L3 and its VRAM cost (F9) can go together.
2. Run the new `quest1` preset (base) to fill quest 1's row in the baseline; the King on the release build (owed).
3. riot60's exe worst frame (it4 NEXT 2); `CityFxFeed` fused loop (it4 NEXT 3), measured on the exe.
4. Size lever (custom template, it4 NEXT 5) - research done, the compile not started.
5. Answer REQUESTs (rivet has not answered the it4 strip REQUEST; handheld has the L4 REQUEST).
- GATE 13:01 at edea9a9b: unit full 1698 passed / 0 failed (FLAKY 1: test_character_rigs fresh-corpse hold, rivet's suite, fail-then-pass on the solo rerun; my changes touch no rig code), lint 15/15. Session end.

## Iteration 6 (13:02-14:02, BUILD)
- Read: JOURNAL it5 + NEXT, git log -30, the d9-rivet / d9-seams / d9-handheld journals. No new REQUEST to perf.
  handheld is answering my L4 REQUEST (E10: a BC7 arm on the iGPU deck row, its own scratch worktree, started 13:00);
  rivet has still not answered the it4 strip-loading REQUEST (their it10 notes the drawn figure adds no rig cost:
  rig_bench 50 people p50 0.866 -> 0.78 ms with RivetFrames on). Registry rules applied: measurement-honesty (a 2-run
  tail "LOSS" is not claimed; L4b names VRAM and the hitch both), perf-regression-gating (code lever A/B'd against a
  scratch project at the pre-lever commit, interleaved, no stored run), render-submission-economy (residency first).
- 13:04 scratch worktree `gtai-d9x/scratch/perf-bc7cv` (ee63589c; BC7 .godot copied in, the 246 city imports back to
  lossless, 23 s reimport): L4 option (b).
- MILESTONE 13:16 L4b measured (`evidence/perf/l4b-bc7cv/ab.json`, lock held, 2 rounds, 4 arms, riot): BC7 for the cast +
  cars only: peak VRAM 867 -> 686 MB (-21 %; full L4 was -37 %). BC7 WITHOUT the prefetch keeps the 20-23 ms first-death
  hitch (cvnopf worst 23.0 vs cv 19.0, base 18.0, nopf 23.3): the decode is not the whole hitch, L3 stays under any BC7
  option. LEDGER row L4b.
- 13:12 L5 built (cd227d3f): `CityFxFeed.observe` calls per person only on a death flip (was a call per person a tick)
  and ends projectiles from a sorted live-slot list (was a 256-slot sweep a tick); `CityCharacters._fill_feed` reads the
  snapshot by offset (was a `slice()` alloc per person in range). Same events, same order (new test pins the end order
  to slot order; it fails without the sort). Unit 16/0 (fx + layers), lint 15/15. A/B against a scratch project at
  ee63589c (`gtai-d9x/scratch/perf-base`, the pre-lever baseline for code levers): riot, drive70, quest1, 3 pairs.
- 13:16-13:29 L5 A/B: job 1 (riot/drive70/quest1, 3 pairs) riot p99 10.47 -> 8.69, p99.9 15.95 -> 10.69 "WIN", rest WASH;
  confirm job (riot, + a `--render-thread separate` arm) p50 5.95 -> 5.20, p99.9 18.0 -> 14.1 "WIN". Every run
  CONTENDED 4-10 (rivet filming). Then an A-vs-A (same L5 code from both dirs): p99 14.27 vs 12.25 "WIN" for the
  d9-perf dir alone. FINDING F12: a scratch-project arm carries a ~2 ms tail floor; the L5 frame "wins" sit inside it.
- MILESTONE 13:31 L5 mechanism (headless microbench, old vs new observe in one process, 8 interleaved blocks x2):
  201-209 -> 122 us a tick (-40 %, ranges disjoint); slice removal ~2 us. ~0.08 ms of a 5 ms riot frame: KEPT as a
  pixel-free CPU cut, NO frame win claimed (measurement-honesty). LEDGER L5 + F12.
- L6 `--render-thread separate` (research sub-agent: still experimental in the docs, D3D12 shutdown drops the pipeline
  cache #119000, texture uploads stay on the calling thread on Forward+): vs L5 frame times WASH, CPU 0.99 -> 1.15
  cores LOSS: DROPPED. Quest 1 baseline row filled (p50 3.63, p99 6.49, worst 18.8 ms, 1035 MB, CONTENDED).
- GATE 13:40 at 7bdb9f6e (L5 inside): `node tools/evidence/run.mjs --no-bench` with a lane-private TEMP
  (`gtai-d9x/scratch/perf-gates`): lint 15/15, unit 1699/0, scenarios 52/0, parity bit-exact + planted mutation caught,
  look goldens 11/11 + block 5/5 (top did not move), **release-compile 598/0 (unblocked: the private TEMP is the fix)**.
  Director reel headless `--quit-after 14000` top / tilt70 / combo: 19/19 chapters fully down each, 0 SCRIPT ERROR
  (`evidence/perf/gates-it6/`).
- MILESTONE 13:35 L4b pixels (riot, 64 px/m, same movie frame, floor exact): PSNR 26.0 dB (full L4 24.8); the ground
  and facades exact, the whole difference on the figures' ink outlines; by eye the same at x4. CORRECTION of it5:
  the asphalt was not most of L4's riot difference. Masters frames.json 13 (two l4b stills). REPORT P-1 (b) updated.
- 13:44 DECISION lines (docs/decisions.md): L5 kept without a frame claim, L6 render thread stays Safe, F12 method rule.
- Scratch worktrees now: `gtai-d9x/scratch/perf-before` (BC7 all, 2507d642), `perf-bc7cv` (BC7 cast + cars, ee63589c),
  `perf-base` (lossless, moved to cd227d3f for the A-vs-A; F12: use it only beside an A-vs-A). All three go at the
  freeze (`git worktree remove --force`). Gate scratch: `gtai-d9x/scratch/perf-gates` (private TEMP, reel logs, l4b frames).

NEXT (iteration 7):
1. The final table owed at the freeze: this morning's main vs d9-perf HEAD on the release exe (riot, drive70, riot60,
   drive60; lock held) + the editor King / reel / quest 1, one job, flag-free arms through two exports (main and head),
   with an A-vs-A pair of the head export beside it (F12).
2. Size lever (it4 NEXT 5): clone Godot 4.7.2 source to gtai-d9x/scratch, a `build_profile` + `optimize=size` Windows
   release template; compile at low priority (`start /low`, -j6) and only while no lane holds bench.lock; measure exe MB,
   boot (boot.sh), then the gates on an export made with it. Check first whether anything uses 3D nodes (disable_3d).
3. riot60's exe worst frame (it4 NEXT 2): the exe at vsync + 60 with --perf-hud, find the presented hitch.
4. The King on a release build (owed since it3): a `windows-perf` preset that keeps dev/bots, or a debug export.
5. F7 rig pose step: rivet's files; re-send the REQUEST with the L5 microbench method (calls are the cost) once they answer.
6. REQUESTs: none open to perf. Rivet still owes the it4 strip REQUEST answer; handheld's E10 (BC7 on the iGPU) result
   to read and fold into Call P-1.
- 13:48 handheld's answer to my L4 REQUEST read (their E10, 1deaad71): on the iGPU deck row BC7 gives ~1 GB of shared
  memory back in the city and render GPU -12 %; folded into REPORT Call P-1 (pairs with their Call 6). NEXT 6 closed.
- 13:51 NEXT 2 groundwork: the project's own code and scenes (addons excluded) name no 3D node (no Node3D / Camera3D /
  MeshInstance3D / Sprite3D / Skeleton3D / WorldEnvironment); only ArrayMesh (7, the 2D meshes / MultiMesh) and SubViewport
  (12), both used by 2D. So `disable_3d=yes` is a candidate for the size template; to verify at build time that ArrayMesh
  and MultiMesh survive it (2D MeshInstance2D / MultiMeshInstance2D need them) and that GUT (addons) still loads.
- Session end 13:52 (it6): 7 commits (cd227d3f .. this), gates green at 7bdb9f6e, lock released, no Godot of mine running.

## Iteration 9 by the Director's count (my 7th session; 13:46-14:46, BUILD)
- Read: JOURNAL it6 + NEXT, git log -30, d9-rivet / d9-seams / d9-handheld journals: no new REQUEST to perf. Registry
  rules applied: measurement-honesty (an estimate is labelled an estimate until the real pck is measured; a build that
  differs in more than one thing is not credited to the strip alone), perf-regression-gating (the same pck under both
  templates, interleaved), render-submission-economy (n/a this session: size and boot).
- 13:47 NEXT 2 (size lever) started: Godot 4.7.2-stable source shallow-cloned to `gtai-d9x/scratch/godot-src/godot`;
  the D3D12 (Mesa NIR, PIX, Agility 1.618.5), AccessKit, WinRT and ANGLE deps installed with the tree's own
  `misc/scripts/install_*.py` (into its `bin/build_deps`: MSYSTEM is set in this shell). Usage grep of the project
  (addons excluded): no physics body/area/ray, no navigation, no 3D node, no network, no video, no noise, no mp3;
  RegEx is used (arena_tuning, quest_condition); ogg + wav audio. Profile `tools/perf/template/strip.py`.
- 13:50 compile started: `scons platform=windows arch=x86_64 target=template_release profile=strip.py -j10`, MSVC 14.3,
  BelowNormal priority (children inherit), no LTO (the official build uses production LTO: the template comparison
  carries that difference too, named in the row). This build loads the machine: no bench numbers of mine while it runs.
- 13:55 L8 estimate (pixel-free size lever, `tools/perf/webp_effort.py`): every lossless `.ctex` is WebP lossless
  (RIFF in the header) at Godot's default effort (quality 25, method 2). On 30 PNGs spread over the 1221 (size-sorted):
  q25 m2 9.38 MB / 5.6 s encode; q50 m4 8.96 (-4.5 %, 1.3x encode); q75 m4 8.89 (-5.2 %, 1.7x); q100 m6 8.6 (-8.4 %,
  29x encode); decode bit-exact in every case, decode time WASH. Textures are 209 of the pck's 228 MB.
- 13:58 ab.mjs: an arm `<name>@exe-<dir>` runs `build/export/<dir>/RTAI-bench.exe` (the same pck beside another
  template); boot.sh `EXE_B=<path>` compares two exes.
- 14:01 FRICTION (~1 min): the first link failed: the static ANGLE (angle=yes, ships in 4.7's Windows template) references
  astcenc; astcenc back in, relinked in 30 s: 63.6 MB. The A/B's strip arm then crashed at boot: `Could not find type
  "QuadMesh"`: `disable_3d` also drops the 3D primitive meshes, and the 2D MultiMesh crowds type `QuadMesh` (8 refs).
  My stale bench.lock (the killed job's, pid gone) removed. Rebuilt with 3D kept (5.6 min: the define change rebuilt most
  of the tree): **66.9 MB vs the official 109.3 MB (-39 %)**.
- MILESTONE 14:11 L7 class check (`gtai-d9x/scratch/classprobe`: a 2 kB probe pck whose main scene writes
  `ClassDB.get_class_list()`, run under each template): official 968 classes, strip 712, 256 removed (physics bodies and
  shapes 2D/3D, joints, nav, CSG, GLTF/FBX, ENet/WebRTC/WebSocket, XR, Theora, MP3, FastNoiseLite ...), none added.
  **No file under project/ (game, dev, tests; addons excluded) names any of the 256** (word grep; sanity: adding
  MultiMesh to the list hits 36). Smoke: the strip exe runs the riot headless, exit 0, 0 ERROR lines.
- MILESTONE 14:05 L8 KEPT (5ad88dab): project setting WebP lossless q75 m4; ctex 209.38 -> 196.87 MB, pck 227.71 -> 215.21
  MB; 1220/1220 textures, 6317 mip payloads decode bit-identical (`tools/perf/ctex_same.py`). Reimport here: delete
  `.godot/imported/*.png-*.md5` AND touch the `.png.import` (either alone does not trigger it), 31 s.
- 14:12 L7 A/B started (lock held): official vs strip, the same 14:05 pck (md5 equal), riot / drive70 / riot60, 3 pairs.
- MILESTONE 14:15 L7 no-LTO A/B (`evidence/perf/l7-strip/ab.json`): riot p50 3.50 -> 3.94 ms LOSS, drive70 2.01 -> 2.19 LOSS,
  riot60 CPU 0.26 -> 0.29 cores LOSS, RAM -13..-20 MB WASH, 0 errors. Boot 7 rounds 2394 vs 2403 ms WASH (CONTENDED).
  Reading: the official template is LTO (production=yes); mine was not. 14:17 LTO build of the same profile started
  (production=yes, BelowNormal, -j12); the no-LTO exe kept as `gtai-d9x/scratch/godot-src/strip-nolto.exe`.
- 14:19 FINDING: `production=yes` on MSVC means NO LTO (`platform/windows/detect.py`: "No LTO by default for MSVC,
  doesn't help"); the official Windows templates are MinGW-GCC builds with LTO. No MinGW sysroot on this PC (LLVM only).
  So the closest match is MSVC `production=yes lto=full` (/GL + LTCG): started 14:19 (full rebuild, BelowNormal, -j12).
- GATE 14:22 at 78193069 (L8 inside, `build/evidence-it9.log`, private TEMP): lint 15/15, unit 1699 passed / 0 failed
  (the evidence stamps it FAIL only because I edited LEDGER.md during the run: "tree changed"), scenarios 52/0, parity
  bit-exact + planted mutation caught, look goldens 11/11 (worst 0.27) + block 5/5 (worst 0.22), release-compile 598/0.
  Director reel top / tilt70 / combo started 14:23 (headless, --quit-after 14000, in parallel).
- GATE 14:28 director reel (L8 inside, headless --fixed-fps 60 --quit-after 14000, pistol, --rigs): top / tilt70 / combo
  19/19 chapters fully down each, 0 SCRIPT ERROR (`evidence/perf/gates-it9/reel-*-chapters.txt`).
- 14:26 L7 LTO build (MSVC production=yes lto=full, 6.8 min): **74.2 MB** (LTO inlines: +7 MB over no-LTO; official 109.3).
  Same 712 classes as the no-LTO strip (probe), riot smoke exit 0 / 0 ERROR. A/B official vs stripl started 14:29.
- MILESTONE 14:33 L7 LTO A/B (`evidence/perf/l7-stripl/ab.json`, lock held): riot p50 slower in every pair (3.59/4.49/3.50
  vs 4.51/5.59/3.98), drive70 2.04 -> 2.22, riot60 CPU 0.26 -> 0.29; RAM -8..-12 MB. **L7 DROPPED on MSVC** (LEDGER,
  DECISION line): the official template is MinGW-GCC + LTO, and an MSVC 4.7.2 build is ~10 % slower a frame here with or
  without LTO, which hides any strip effect. REPORT got a kept / dropped summary.
- Cleaned: `build/export/windows-bench-strip*` removed (the exes stay in `gtai-d9x/scratch/godot-src/strip-{nolto,lto}.exe`).
  `build/export/windows-bench` is now a 14:05 export of 5ad88dab (L8 inside, pck 215.2 MB).
- Scratch kept: `gtai-d9x/scratch/godot-src` (4.7.2 source + deps + MSVC objects, ~several GB: remove at the freeze unless
  the MinGW retry runs), `gtai-d9x/scratch/classprobe` (the ClassDB probe pck + official/strip class lists),
  `gtai-d9x/scratch/perf-l8` (the q25 ctex copies for ctex_same.py). perf-base now carries the L8 project setting
  (uncommitted, scratch) and q75 imports: for an F12 A-vs-A that is fine (same pixels), but it is no longer "lossless q25".

NEXT (iteration 10):
1. The final table owed at the freeze (it6 NEXT 1): this morning's main (3982af1a) vs d9-perf HEAD on the release exe
   (riot, drive70, riot60, drive60; lock held) + the editor King / reel / quest 1, with an A-vs-A pair (F12). Main needs
   a scratch worktree at 3982af1a: copy perf-base's `.godot` and the 256 baked chunks in, `--import`, export windows-bench
   to a second dir, `@exe-<dir>` arm (ab.mjs now takes it).
2. L7 retry only if cheap: llvm-mingw (the engine's own build containers use it / MinGW-GCC) + `lto=full`, with an
   UNSTRIPPED build of the same toolchain as the A-vs-A; otherwise leave L7 dropped.
3. riot60's exe worst frame (presented hitch) with --perf-hud; the King on a release build (a `windows-perf` preset).
4. RAM: the release exe sits at ~750 MB with ~850 MB VRAM on a discrete GPU: read `Performance` static vs video memory
   and the resource list to find what the CPU side holds (possible lever: textures kept in RAM after upload).
5. Answer REQUESTs (none open to perf at 14:35).
- Session end 14:36 (it9): 9 commits (3302a019 .. this), gates green at 78193069 (L8), reel 19/19 x3, lock released,
  no Godot / scons of mine running.

## Iteration 12 by the Director's count (14:37-15:37, BUILD)
- Read: JOURNAL it9 + NEXT, git log -30, the rivet / seams / handheld journals: no REQUEST open to perf. Registry rules
  applied: measurement-honesty (the final table carries a head-vs-head A-vs-A arm, the F12 floor), perf-regression-gating
  (one interleaved job, the same machine state for both builds), perf-instrumentation (L9's mechanism is measured by
  a log line in the engine, not inferred from the working set alone).
- 14:38 NEXT 1 (final table): scratch `perf-base` moved to main 3982af1a (project.godot reverted, detached), the 256
  chunks copied (the generator is unchanged since main), textures reimported at main's WebP q25 m2 (24 s; ctex 203 MB
  vs head 191 MB by `du -m`), `windows-bench` exported to `build/export/windows-bench-main/` (pck 227.70 MB, matches
  it4's main). `windows-bench-head2` = a copy of the head export (A-vs-A). Job 14:39: riot / drive70 / riot60 / drive60,
  arms main / head / head2, 3 rounds, lock held (`evidence/perf/final-exe/`).
- 14:42 NEXT 4 (RAM): source read of 4.7.2's RenderingDevice: each transfer worker (up to 16 = the core count) keeps a
  CPU staging buffer of next_pow2(its largest upload) until shutdown. L9 hypothesis in the LEDGER before building; patch
  `tools/perf/template/tw_trim.py` applied to the scratch tree (env-gated: one binary, two arms); `ab.mjs` arms take
  env vars (third `^` segment). Build waits for the A/B to end (no contention of my own numbers).
- MILESTONE 14:52 final table (`evidence/perf/final-exe/`, 36 runs, lock held, CONTENDED 2-8 in 14): main vs head on the
  release exe: riot p99 12.53 -> 8.09, p99.9 24.0 -> 10.4, worst 25.3 -> 12.2 ms (head vs head2 A-vs-A: 8.09 vs 8.71,
  10.4 vs 11.5, 12.2 vs 12.4: the win is 5-7x the floor); drive70, riot60, drive60 WASH on every metric; pck -12.5 MB.
  Working set bimodal (~690 or ~755 MB) on every arm, run to run: the RAM noise floor. LEDGER "Final table" (200256f5).
- 14:53-14:57 L9 build: the patched 4.7.2 template (MSVC production + lto=full, the it9 strip profile; 3.9 min, the
  header change recompiles the renderer) -> `build/export/windows-bench-tw/` (the head pck) + `scratch/godot-src/tw-lto.exe`.
- MILESTONE 14:59 L9 mechanism (one riot run each, GTAI_TW_LOG=1, `build/tw/riot-{stock,trim}.log`): STOCK ends with 4
  workers holding 128 + 32 + 32 + 16 = **208 MB of CPU staging** for the session (the 128 MB one = the vehicles'
  `p70/traffic_cards.png`, 4032 x 4480 = 69 MB RGBA, ~92 MB with mips: the biggest texture in the game); TRIM frees all
  four after load and re-creates 16-32 MB only on the death frames' strip uploads (then frees them again); end state
  ~1.3 MB. 0 errors, the riot completes.
- FRICTION 15:00 (~2 min): the sampler logs the PEAK working set only, which keeps the load spike in both arms and would
  hide a steady-state release: job stopped (my stale lock removed, pid gone), `procStats` now also gives the steady
  median (`wsMb`) and the last sample (`lastWsMb`); job restarted 15:01 (`evidence/perf/l9-twtrim/`).
- 15:05 L9 trim-at-4-MB job 1 (`evidence/perf/l9-twtrim/`, 18 runs, lock held, CONTENDED 2-16 in every run: frame times
  unusable): Godot's video-memory monitor -200 MB on all three scenes (riot 867 -> 661, drive70 902 -> 680, riot60
  883 -> 661, spreads <= 30: WIN); riot60 steady working set 788 -> 574 (WIN), drive70's working set WASH.
- 15:08 L9 riot rerun (`evidence/perf/l9-twtrim-riot/`, 4 pairs, 0 contended): VRAM 867 -> 708 WIN, but **p99 worse in
  all 4 pairs** (11.7 / 10.7 / 8.5 / 9.2 vs 9.3 / 7.6 / 7.2 / 7.8 ms; median 7.77 -> 10.73, inside the 1.6 spread by
  the rule, so "WASH" by the verdict, a loss by the pair pattern) and **steady working set +60 MB** (746 -> 806 LOSS).
  Reading: trimming at 4 MB churns: every death re-creates a 16-32 MB upload buffer (allocation + fresh page faults)
  and frees it a few frames later. The 4 MB policy is DROPPED. Next arm (no rebuild, env only): GTAI_TW_TRIM_MB=32
  frees only the outlier (the 128 MB traffic-sheet buffer), the strip-sized ones stay. Job 15:09 (`l9-t32/`).
- MILESTONE 15:13 L9 trim at 32 MB (`evidence/perf/l9-t32/`, riot + riot60, 3 pairs, CONTENDED 0-4): video memory riot
  883 -> 771, riot60 851 -> 755 MB (WIN), riot60 steady working set 746 -> 686 MB (WIN), riot WS WASH, frames WASH (riot
  p50 4.24 -> 4.88, slower in 2 of 3 pairs: not ruled out). Verdict: mechanism found, engine lever not a baseline (custom
  template = ~10 % frame on MSVC, L7). LEDGER L9, DECISION line (83d33c0e), REPORT Call P-2.
- REQUEST to Director (vehicles art has no lane today; seams owns the sim bike only): split
  `features/vehicles/art/p70/traffic_cards.png` (4032 x 4480, 69 MB RGBA, no mips) into sheets of <= 32 MB (e.g. three
  4032 x 1494 rows, the same cells, `vehicle_cards.gd` reads the sheet index). Why: Godot 4.7.2 keeps a CPU upload buffer of
  next_pow2(the largest texture) per transfer worker for the whole session; this one sheet makes a 128 MB buffer (L9,
  measured). Expected (estimate, not measured): about -96 MB resident on any scene that loads the p70 cars, no pixel moves.
  The p55 sheet (2240 x 4480, 38 MB) makes a 64 MB buffer under combo; the same split takes it to 32 MB. perf can measure
  it the same hour with `GTAI_TW_LOG=1` on `gtai-d9x/scratch/godot-src/tw-lto.exe` (an instrumented template).
- REQUEST to handheld (FYI + tooling): L9's numbers matter most on your shared-memory deck row: the stock engine holds
  ~208 MB of upload buffers on the riot (four workers; 128 MB from one texture). The instrumented template is
  `C:/Users/kazda/kiro/gtai-d9x/scratch/godot-src/tw-lto.exe` (copy it over a windows-bench export's RTAI-bench.exe;
  `GTAI_TW_LOG=1` prints every staging allocation; `GTAI_TW_TRIM_MB=32` frees the outliers; MSVC build, ~10 % slower a frame,
  so compare memory with it, never frame time against the official exe). `ab.mjs` arms now take env vars (third `^`).
- 15:17 masters: `perf-set-combined.mp4` (69 s, 61.5 MB: King 32, drive, riot L3 off/on, King 48; before vs after with the
  perf HUD), looked at frame by frame (4 stills, one per segment: all four play, HUD readable; the riot HUD clips at the
  right edge, the known it4 issue); frames.json 14 entries (the combined clip second).
- 15:18 LEDGER F13: where the riot's memory sits (video-memory monitor 883 = textures 531 + staging 208 + ~144; working set
  ~745 = Godot static ~138 + staging + ~400 exe / D3D12 / driver, the remainder not split).
- Scratch state now: `gtai-d9x/scratch/perf-base` is at main 3982af1a (q25 imports, the 256 chunks): the "main" side for
  any later main-vs-head job; `build/export/windows-bench-main/` its export; `build/export/windows-bench-tw/` = the head pck +
  the L9 instrumented template (also `gtai-d9x/scratch/godot-src/tw-lto.exe`); the scratch Godot tree carries the L9 patch
  (uncommitted there; `tools/perf/template/tw_trim.py` re-applies it to a clean 4.7.2 tree). windows-bench-head2 removed.

NEXT (iteration 13):
1. If the Director serves the traffic-sheet REQUEST (or rivet/seams touch the vehicles art): measure it the same hour:
   `GTAI_TW_LOG=1` on windows-bench-tw (expect the 128 MB worker gone: 208 -> ~112 MB staging) + the ab.mjs RAM job
   (riot60 steady working set, the video-memory monitor), stock template for the frame side.
2. RAM remainder (~400 MB of the working set not itemised): VMMap / `Get-Process` private vs image vs mapped on the exe at
   the cap; the D3D12 shader cache and the driver's share. Possible lever: `rendering/rendering_device/pipeline_cache`.
3. L7 / L9 on the official toolchain only if cheap (llvm-mingw + LTO, with an unpatched build of the same toolchain as the
   A-vs-A); otherwise both stay dropped.
4. At the freeze: export `build/export/windows/RTAI.exe` (windows-showcase), REPORT final; remove the scratch worktrees
   (perf-before, perf-bc7cv, perf-base) and `gtai-d9x/scratch/godot-src` (several GB) unless NEXT 3 runs.
5. REQUESTs: none open to perf (read the journals first).
- 15:21 L9 mechanism on the city drive (one stock run, `GTAI_TW_LOG=1`, memory only, no timing claimed;
  `evidence/perf/l9-twtrim/mechanism/drive-stock.log`): the same end state as the riot, 4 workers at 128 + 32 + 32 + 16 =
  208 MB, the 128 MB one made at load. Every city scene pays it, not only the riot: the traffic-sheet REQUEST covers both.
- 15:24 NEXT 2 partly done: LEDGER F13 now carries a measured working-set split (private 617 + image 138 MB; modules: exe 106, NVIDIA compiler 94 + driver 86, the AMD iGPU driver 58 loaded too).
- Session end 15:21 (it12): 8 commits (200256f5 .. 5473af6a), no new REQUEST to perf in the rivet / seams / handheld journals; lock released, no Godot / RTAI / scons of mine running; project/ untouched this session (tools + docs + evidence only), so the it9 gates at 78193069 still cover the game.

## Iteration 15 by the Director's count (15:24-16:24, BUILD)
- Read: JOURNAL it12 + NEXT, git log -20, the rivet / seams / handheld journals: no REQUEST open to perf; the Director has not
  answered the traffic-sheet REQUEST. Registry rules applied: measurement-honesty (the 144 Hz case is labelled SIMULATED: both
  monitors here run 59.94 Hz), perf-instrumentation (a cadence counter in the bench, so "smooth" is counted, not argued),
  render-submission-economy (a frame that shows no new tick is pure waste: count it before cutting it).
- FINDING 15:26: seams' branch edits `features/vehicles/art/p70/traffic_cards.png` (the sim bike row) + `vehicle_cards.gd`, so
  the sheet is seams' file today, not unowned. REQUEST to seams (redirected from the Director, same text as it12): when the
  sim bike row lands, cut `p70/traffic_cards.png` (4032 x 4480, 69 MB RGBA) into sheets of <= 32 MB (and p55 likewise),
  same cells, `vehicle_cards.gd` picks the sheet by row. Why (measured, L9): Godot 4.7.2 keeps a CPU upload buffer of
  next_pow2(largest texture) per transfer worker for the whole session: this one sheet makes a 128 MB buffer on every city
  scene (riot AND drive, `evidence/perf/l9-twtrim/mechanism/`). Expected about -96 MB resident, no pixel. perf measures it
  the same hour it lands (`GTAI_TW_LOG=1`, `build/export/windows-bench-tw/`). If seams has no room today, it stays a Call.
- FINDING F14 15:27: no view reads `SimClock.alpha()`; the camera follows per tick; so at > 60 Hz vsync every extra frame is a
  duplicate image. And `city_bench` hard-resets `Engine.max_fps = 0`, so the `*60` presets' `--max-fps 60` never applied:
  they were vsync-capped only (their numbers stand, the label was wrong). L10 hypothesis in the LEDGER before building.
- 15:29 L10 job 1 started (`evidence/perf/l10-cap/`, riot60 + drive60, 4 arms x 3 rounds, editor binary, lock via ab.mjs).
- FRICTION 15:31 (~4 min lost, job 1 void): I wrote `boot/frame_cap.gd` + the `Game._ready` call while job 1 ran on this
  worktree; the 4th run loaded the new `game.gd` against a class cache without `FrameCap` (5 SCRIPT ERROR) and the
  discarded-return warning was an error too. Job stopped (my stale lock removed, no process left), `apply()` returns void,
  `--import`, `test_frame_cap` 4/4. Job 2 restarted ~15:33 from zero (`evidence/perf/l10-cap/`). Rule for myself: no edit
  under `project/` while a job of mine runs on this tree. Job 1's three clean runs (kept in this entry only): riot60 vsync
  0.43 cores 1683 frames 0 dup; vsync + limiter 60 0.52 cores; SIMULATED 144 Hz 0.64 cores, 4200 frames of which 2449
  (58 %) showed no new tick.
- 15:31 research (LEDGER digest): Godot's `Engine.max_fps` docs + the jitter/stutter page; source read of 4.7.2's
  `OS::add_frame_delay` (the limiter sleeps with `Sleep(ms)` on Windows: no spin, ~1 ms granularity) .
- REQUEST to handheld (FYI, a lever for your device rows): L10 caps the frame limiter at the 60 Hz tick when the display is
  faster than 61 Hz and vsync is on (`boot/frame_cap.gd`, set once by the `Game` autoload; `--frame-cap=off` = the before).
  A 90 Hz handheld panel renders 90 frames for 60 images today: the cap is -33 % of the frames there with no new pixel lost
  (nothing on screen moves between ticks: F14). Your `--device=` profiles may want to set it explicitly (the decision
  function is `FrameCap.cap_for(refresh_hz, vsync_on, current, flag)`, pure, unit-tested).
- MILESTONE 15:48 L10 job 2 (`evidence/perf/l10-cap/ab.json`, 24 runs, lock held, CONTENDED 0-8 in 2-3 of 3 per arm, 0 SCRIPT
  ERROR): SIMULATED 144 Hz uncapped -> capped: riot60 0.68 -> 0.42 cores (-38 %), drive60 0.52 -> 0.30 (-42 %), duplicate
  frames 2450 -> 0 per 30 s, skipped tick images 0 -> 0; GPU ms a frame rises at the lower load (the 4090 clocks down): no
  GPU claim. At 60 Hz, vsync + limiter 60 vs vsync: p99 20.4 -> 17.1 (riot), 21.1 -> 17.1 ms (drive), skipped ticks 2 -> 0,
  but CPU +30 % (0.37 -> 0.48): F15, Call P-3 (default: no limiter at 60 Hz).
- DECISION 15:50 (also `docs/decisions.md`): FrameCap caps at the tick only on > 61 Hz + vsync; the 60 Hz limiter is Call P-3;
  rejected a project-wide `max_fps=60` (it would cap the headless tests, the replay, the uncapped bench).
- FRICTION 15:51-15:55 (~4 min): lint's debt ratchet failed (city_bench 201 lines, +1 direct cmdline read, +9 dev lines):
  city_bench trimmed to 200 (the default comes from `.get`; first `.to_int()` on a Variant and then an `as String` cast both
  are warnings-as-errors: `str()`), FrameCap no longer reads the cmdline (`--fixed-fps` with the cap only paces wall time),
  the +9 dev lines accepted in the baseline with the reason. The A/B ran the earlier `"--max-fps": "0"` default spelling:
  the same behaviour.
- GATE 15:56 at 314632c4: lint 15/15, unit 1703 passed / 0 failed (load_all clean), windowed riot smoke with FrameCap live
  (59.94 Hz: no-op, no log line) exit 0, 182 frames, 0 duplicate / 0 skipped, 0 SCRIPT ERROR. Scenarios + the director reel
  top / tilt70 / combo running (15:57 / 15:59).
- COMMITS: 813b7976 (bench tooling), 314632c4 (FrameCap).
- GATE 16:08 at c46b80c1 (FrameCap inside): scenarios 52 ran / 0 failed (replay_60s identical), release-compile 599 loaded /
  0 failed (private TEMP: the shared `%TEMP%/gtai-release-compile` belongs to another lane's run), director reel top / tilt70 /
  combo 19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/perf/gates-it15/`). Evidence `--no-bench` at c46b80c1 (private TEMP): lint 15/15, unit 1703 / 0, scenarios 52, parity bit-exact + planted mutation caught, look goldens 11/11 (worst 0.27) + block 5/5 (worst 0.22): `top` unmoved, export-audit 599 / 0: all PASS.
- REQUESTs read 16:00: handheld's E12 (FYI: the L9 trim on the iGPU takes 128 MB off shared GPU memory, 176 MB off the working
  set): it backs the traffic-sheet REQUEST (now to seams). Nothing else open to perf.

NEXT (iteration 16):
1. Freeze prep: at 18:30 export `build/export/windows/RTAI.exe` (windows-showcase) and name the command in REPORT; REPORT final
   with the L10 row in the final table (the simulated 144 Hz case: main has no cap, head does); remove the scratch worktrees
   (perf-before, perf-bc7cv, perf-base) and `gtai-d9x/scratch/godot-src` (several GB) plus `gtai-d9x/scratch/tmp-perf`.
2. L10 on the release exe and the King: re-export windows-bench (FrameCap + the bench's `--max-fps`), riot60 / drive60
   hz144 vs hz144cap `@exe`; King under combo with engine `--disable-vsync --max-fps 144` vs `60` (the arena never resets
   the limiter). Expect the same ~40 %.
3. L11 (Call P-3 follow-up): why a 60 fps limiter on vsync costs +0.1 core and whether another present mode gets the
   smooth p99 for less: `--vsync=mailbox` / `adaptive` and the limiter at the display's exact rate (59.94) vs 60, ABAB on
   riot60 + drive60, counting `multiTick` and the presented p99.
4. If seams serves the traffic-sheet split: `GTAI_TW_LOG=1` on windows-bench-tw (expect 208 -> ~112 MB staging) + the RAM job.
- Session end 16:09 (it15): 5 commits (813b7976 .. this); L10 KEPT as the new baseline; lock released, no Godot of mine running; scratch build logs removed.
- MILESTONE 16:13 L10 on the King (`evidence/perf/l10-king/ab.json`, combo, editor binary, lock held, 3 rounds, CONTENDED 1 of
  3 per arm, 0 errors): SIMULATED 144 Hz uncapped -> capped 0.80 -> 0.47 cores (-41 %): the same cut as the city scenes. NEXT 2's
  King half is done; the release-exe half stays.
- Session end 16:15 (it15, final): lock released, no Godot of mine running (the reels / GUT up at 16:10 are another lane's).

## Iteration 18 by the Director's count (16:15-17:15, BUILD)
- Read: JOURNAL it15 + NEXT, git log -12, the rivet / seams / handheld journals: no new REQUEST to perf (handheld's E12 FYI
  was answered in it15; seams has not answered the traffic-sheet split). Registry rules applied: measurement-honesty (L11
  re-runs v60 vs v60cap as a replication of F15 before any new arm is believed), perf-regression-gating (no `project/` edit
  while a job of mine runs on this tree), render-submission-economy (a present mode that drops a stale image instead of
  blocking is the cheap way to pace).
- 16:16 L11 HYPOTHESIS (written before the numbers): F15 found that a 60 fps limiter on top of vsync smooths p99 (20.4 -> 17.1
  ms) but costs +0.1 core. Source read (4.7.2 `core/os/os.cpp` `OS::add_frame_delay`, `platform/windows/os_windows.cpp`
  `delay_usec`): the limiter adds 16 667 us a frame to a target and `Sleep(ms)` (truncated to whole ms; `timeBeginPeriod(1)`
  at boot, no spin), the D3D12 fence wait is `WaitForSingleObjectEx` (no spin). Nothing in the engine spins, so the +0.1
  core is either the driver (present blocking vs not) or noise in a CONTENDED 3-pair job. Arms: `v60` vsync, `v60cap` vsync
  + limiter 60 (the F15 replication), `mbx60` mailbox + limiter 60 (present never blocks; the limiter paces; the newest
  image wins at each vblank), `ada60` adaptive + limiter 60 (tears only on a late frame). Expected: mbx60 keeps v60cap's
  p99 (~17 ms) at v60's CPU (~0.36 cores); ada60 = v60cap. If v60cap's CPU rise does not replicate, F15's cost was noise.
- 16:16 L11 job started (`evidence/perf/l11-present/`, riot60 + drive60, 4 arms x 3 rounds ABBA, editor binary, lock via
  ab.mjs; 3 other lanes' Godots up: CONTENDED expected on most runs).
- ANSWER to handheld (their it-ANSWER on L10, "the device row's max_fps must win over cap_for"): it already does in
  either order, no seam to fix. `FrameCap.apply` passes `Engine.max_fps` as `current`, and `cap_for` returns `current`
  untouched whenever it is not 0 (`project/boot/frame_cap.gd:18`, unit-tested "an explicit cap is kept"). So a row
  that sets 60 / 40 / 30 before `Game._ready` is kept, and a row that sets it after overwrites the 60. The one case to
  avoid: a row that means "uncapped" by writing 0 *before* the Game autoload on a > 61 Hz panel gets 60. No deck row does.
- 16:20 TOOL: `tools/perf/thread_cpu.ps1` (per-thread CPU by thread name / start-address module; `Process.StartAddress`
  reads 0 without elevation, so it asks `NtQueryInformationThread` class 9). Smoke-tested on a node process and
  for 2 s on my own job's riot run (16:19, a few ms of sampler CPU inside a measured run: noted, not removed).
  Commit 873070a4 (+ LEDGER tooling and the D3D12 present-mode digest).
- FINDING 16:21 (source): on D3D12, `VSYNC_ADAPTIVE` is "Unsupported" and = `Present(1, 0)`, the same as Enabled; so the
  `ada60` arm IS `v60cap` run again: L11 has a free A-vs-A of the limiter arm inside the same job.
- MILESTONE 16:31 L11 done (`evidence/perf/l11-present/ab.json`, 24 runs, lock held, CONTENDED 0-12 in 1-3 of 3 per arm, 0
  SCRIPT ERROR). F15 REPLICATES with a smaller cost: v60 -> v60cap riot p99 19.83 -> 16.90, worst 35.1 -> 18.4 ms, CPU
  0.36 -> 0.42 (+0.06); drive p99 19.78 -> 16.83, CPU 0.22 -> 0.31 (+0.09). The free A-vs-A (ada60 = v60cap) differs by
  0.03 cores: the floor. Mailbox + limiter = v60cap on pacing and CPU (0.41 / 0.29 vs 0.42 / 0.31): WASH. L11 DROPPED.
- 16:32-16:34 mechanism probe (lock held, `probe.ps1`, 4 riot60 runs, `thread_cpu.ps1` 10 s each): v60 0.33 / 0.40, v60cap
  0.47 / 0.44 process cores; the whole rise is the main thread ([Godot.exe] 0.32 / 0.39 -> 0.45 / 0.43); the driver's own
  threads < 0.01. Driver code inside Present on the main thread counts as main thread: engine vs driver not split.
- 16:35 LEDGER L11 row + F15 replication note; REPORT Call P-3 re-measured paragraph (+0.06..+0.09 core, mailbox no cheaper).
- 16:34 NEXT 2 (L10 on the release exe): `windows-bench` exported at 873070a4 to `build/export/windows-bench-cap/` (10 s,
  exit 0; pck 215.21 MB), job `evidence/perf/l10-exe/` running (riot60 + drive60, hz144 vs hz144cap @exe, 3 pairs).
- MILESTONE 16:42 L10 on the release exe (NEXT 2 closed; `evidence/perf/l10-exe/ab.json`, windows-bench export of 873070a4,
  lock held, 12 runs, CONTENDED 1-3 of 3 per arm, 0 errors): SIMULATED 144 Hz uncapped -> capped riot60 0.68 ±0.04 -> 0.39
  ±0.03 cores (-43 %), drive60 0.47 ±0.03 -> 0.29 ±0.02 (-38 %), duplicate frames 2450 -> 0, skipped tick images 0 -> 0,
  working set WASH. LEDGER L10 row + two rows in the final table (main column = the head exe without the cap: main's
  city_bench has no `--max-fps`, so it cannot run the arm; said so in the table); REPORT kept-list updated.
- FINDING F16 16:45: physics_ms on the King = 0.015 ms a frame (0.3 %): a dummy physics server is not worth a lever.
- FINDING F17 16:46 (`evidence/perf/l12-minimized/probe-{a,b}-*.json`, riot60 before any change, lock held): minimized
  costs MORE than on screen: 0.35 / 0.35 -> 0.56 / 0.61 cores, all main thread, 4600 loops in 60 s of sim (no vsync
  wait when the window cannot draw; the engine's 6.9 ms low-processor sleep is the only pacing). L12 HYPOTHESIS (before
  building): the limiter at the tick while minimized -> ~60 loops, CPU <= on screen, same ticks, no pixel.
- MILESTONE 16:52 L12 KEPT (9a2fcdc8): `boot/minimized_cap.gd` (MinimizedCap, child of Game), `test_minimized_cap` (3).
  King under combo minimized, off / on / on / off: 0.73 / 0.38 / 0.38 / 0.75 cores (-49 %), on screen WASH, same 3593
  ticks, loops 4640 -> 3630. Unit 1706 / 0, lint 15/15. DECISION (also docs/decisions.md): cap while minimized, never
  pause (pausing on focus loss changes the game: a design call, not perf's); `--frame-cap=off` turns off L10 and L12 together.
- 16:56 gates for 9a2fcdc8 started (headless reels top / tilt70 / combo + scenarios, logs in `gtai-d9x/scratch/gates-it18/`);
  no `project/` edit while they run.
- REQUEST to handheld (FYI, two things for your rows): (1) L12 (9a2fcdc8, `boot/minimized_cap.gd`): a minimized window
  had no vsync wait and spun ~145 loops a second (King 0.73 cores minimized vs 0.33 on screen); it now caps at the
  tick while minimized (0.38). Your device rows set `max_fps` 60 / 40 / 30 already, and `cap_when_minimized` keeps any
  cap <= 60, so the rows are untouched; on a Windows handheld that is alt-tabbed / sent to the background this is
  the battery case. (2) `tools/perf/thread_cpu.ps1 -ProcessId <pid>`: per-thread CPU by thread name / start module
  (engine main thread vs Godot workers vs the GPU driver); use it if a device row's CPU moves and you need to know who pays.
- GATE 17:00 at 9a2fcdc8 (L12 inside; `evidence/perf/gates-it18/`): director reel top / tilt70 / combo 19/19 chapters fully
  down, 0 SCRIPT ERROR; scenarios 52 ran / 0 failed (replay_60s 3600 ticks, final cbeb734ff9b97c41, identical); unit 1706 /
  0; lint 15/15. NOT run this session: `evidence/run.mjs --no-bench` (goldens + parity + export-audit): L12 is a no-op
  headless by construction (`set_process(false)`), so the goldens / parity cannot move, but the freeze session runs it.
- Session end 17:01 (it18): commits 873070a4 .. this (thread_cpu tool, L11 dropped, L10 release-build numbers, L12 kept,
  docs); lock released; no Godot of mine running; `build/export/windows-bench-cap/` kept (the release export of 873070a4).

NEXT (iteration 19 = the freeze session, 18:30 freeze, 18:40 REPORT):
1. Gates on HEAD first: `node tools/evidence/run.mjs --no-bench` (private TEMP: the shared `%TEMP%/gtai-release-compile`
   may belong to another lane) -> goldens 11/11 + block 5/5, parity exact, export-audit; it covers L12 for the goldens.
2. Export `build/export/windows/RTAI.exe` (`"$GODOT_BIN" --headless --path project --export-release windows-showcase
   ../build/export/windows/RTAI.exe`, mkdir first) and name it in REPORT with the exact command line.
3. REPORT final: the L10 / L12 rows (simulated 144 Hz -43 / -38 % release build; minimized -49 %), Call P-3 revised
   (+0.06..+0.09 core, mailbox no cheaper), the final table vs main, what does not work (L1, L6, L7, L9 engine patch,
   L11), the open REQUEST to seams (traffic-sheet split, unanswered), the tooling list (ab.mjs, stats, proc_sample,
   thread_cpu, perf HUD, NodeSpans reuse, probes).
4. Optional, if time: a masters still/clip pair for L12 is not possible (nothing is drawn minimized); instead add the
   `thread_cpu` minimized-vs-shown numbers as a frames.json `note` line? No: frames.json is images only. Skip.
5. Clean-up at the freeze: remove the scratch worktrees `gtai-d9x/scratch/perf-before`, `perf-bc7cv`, `perf-base`
   (`git worktree remove`), `gtai-d9x/scratch/godot-src` (several GB; L7 / L9 are dropped), `scratch/tmp-perf`,
   `scratch/gates-it18`, `scratch/l11.log`, `scratch/l10exe.log`, `scratch/export-cap.log`.

## Iteration 21 by the Director's count (17:02-18:02, BUILD)
- Read: JOURNAL it18 + NEXT, git log -15, the rivet / seams / handheld journals: no new REQUEST to perf. Registry rules
  applied: measurement-honesty (an outlier was chased to a cause before a number was believed; F18 corrects my own it18
  digest; the L13 win is quoted against its spread, the pause card's wash is recorded), perf-regression-gating (the gate
  ran on a committed tree with no `project/` edit while it ran; L13 was built in the scratch worktree meanwhile),
  runtime-observation-evidence (every arm's still was looked at; screen grabs on the shared monitor proved useless until
  the window was pinned TOPMOST), render-submission-economy (a still card should cost no submissions at all).
- GATE 17:02-17:15 at bf6398e1 (NEXT 1 of it18 closed; `evidence/perf/gates-it21/`, private TEMP): lint 15/15, unit
  1706 / 0, scenarios 52, parity bit-exact + planted mutation caught, look goldens 11/11 + block 5/5, export-audit 600 / 0.
- L13 HYPOTHESIS (before building, from the brief's "low_processor_mode where it fits (menus)"): the slice's title card
  is a still frame drawn every vblank; in low-processor mode `Main::iteration` draws only on a RenderingServer write.
  Expected: title near 0 cores, no pixel; pause card WASH (the city view writes shader params every frame).
- FINDING F18 17:20 (source, `platform/windows/os_windows.cpp:2630-2675`): the Windows `add_frame_delay` override spins
  `YieldProcessor()` for the last `delay_resolution` (1 ms) of each limited frame: F15 / L11's +0.06 core. My it18 digest
  ("no engine path spins") read `core/os/os.cpp` only: WRONG, corrected in the LEDGER.
- FRICTION 17:10-17:35 (25 min): one "on" run read 0.01 cores in PLAY. Chased it: 2 of 9 on-runs, then 3 of 6 OFF runs,
  then main 3982af1a (1 of 5) and `--strip-prefetch=off` (1 of 5), and with the window pinned TOPMOST: the same freeze.
  FINDING F19: quest 1 under `--autostart` freezes ~1 run in 4 at Rivet's "Okay" line, Esc dead, 0.002-0.023 cores
  (blocked, not idle), on main too: not a perf lever, not L13 / L3. In the LEDGER and REPORT.
- MILESTONE 17:38 L13 KEPT (0f725304): `boot/menu_idle.gd` (MenuIdle, a child of Game; reads `current_scene as
  Quest1Game`, so `quest1_game.gd` (272 lines, debt ratchet) is untouched), `test_menu_idle` (5). Title off 0.037 / 0.023 /
  0.033 -> on 0.000 / 0.004 / 0.014 cores (-88 %, lock held, CONTENDED 4-8), 0 client pixels differ > 15; pause WASH ->
  `PAUSED_IDLE = false`. Unit 1711 / 0, lint 15/15, release-compile 601 / 0. Headless / movie: never processes, so the
  goldens / reels / parity cannot move (same argument as L12; the freeze session's gate covers it). DECISION in
  docs/decisions.md.
- 17:39 F19 hunt (`evidence/perf/f19-freeze/hunt.ps1`, head, TOPMOST, lock held): run 1 normal (0.18 cores), run 2 FROZE:
  `Process.Responding` false, `thread_cpu` 0.005 cores total and 0 on the main thread over 3 s (blocked in a wait).
  Main-thread waits in our code: `chunk_source.take` (WorkerThreadPool wait), `save_worker` flush (`Thread.wait_to_finish`;
  quest 1 autosaves at start), `load_threaded_get`. Not root-caused. REPORT "FYI F-19" for the owner.
- REQUEST to seams (FYI, your lane takes the merge seams and small asks; the Director decides who owns it): F19 above.
  Quest 1 under `--autostart` freezes ~1 run in 4 at Rivet's "Okay" line, main 3982af1a included (1 of 5), main thread
  parked in a wait. Repro: `evidence/perf/f19-freeze/hunt.ps1 -Runs 6` (stops at the first freeze, writes the thread split).
  I am not touching the save / stream code (not perf's, and not root-caused).
- GATE 17:43 at 2d81ee85 (L13 inside; `evidence/perf/gates-it21/reels-summary.txt`): director reel headless top / tilt70 /
  combo 19/19 chapters all down, 0 SCRIPT ERROR. With the 17:15 evidence run at bf6398e1 (all PASS) and L13 a headless
  no-op, the branch is gated; the freeze session re-runs `evidence/run.mjs --no-bench` on its HEAD.
- 17:44 L14 HYPOTHESIS (from F18, before the numbers): MinimizedCap also turns low-processor mode on while minimized
  (nothing is drawn, so no pixel), so the limiter sleeps the whole gap instead of spinning its last 1 ms. Expected: the
  King minimized 0.38 -> ~0.32 cores (-0.06, F18's size); on screen unchanged. Built in the scratch worktree
  `perf-before` at 2d81ee85 (`--frame-cap=spin` = L12 only); A/B `probe_king.ps1` spin / low / low / spin, lock held.
