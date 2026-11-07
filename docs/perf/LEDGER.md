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

**Quest 1 row (it6, 13:13-13:16, owed since the morning; `evidence/perf/l5-feed/ab.json`, the `base` arm = the
scratch project at ee63589c = main + L2 + L3, preset `quest1` = `quest1_frames.gd`, 1200 one-tick frames from the
Dock 9 fight in the play view, windowed D3D12 1920x1080, editor binary, bench.lock held, CONTENDED(4) in 3 of 3 runs
(the rivet lane filming)):** p50 3.63 ±0.01, p99 6.49 ±0.15, p99.9 9.70 ±0.60, worst 18.77 ±1.48 ms, CPU 0.96 cores,
peak RAM 1035 MB (the highest of the five scenes). Draws / render CPU / VRAM are not logged by quest1_frames (n/m).

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
| L8 | the lossless WebP effort of every imported texture (the pck's size) | F10: every texture imports lossless, and a lossless `.ctex` stores WebP lossless (RIFF in the header) at Godot's default effort (`rendering/textures/webp_compression/lossless_compression_factor` 25, `compression_method` 2). Textures are 209 of the 228 MB pck. A higher lossless effort is pixel-free by construction (lossless), costs encode time at import only, and decodes at the same speed. Estimate first (`tools/perf/webp_effort.py`, libwebp via PIL, 30 PNGs spread over the 1221): q25 m2 9.38 MB / 5.6 s encode; q50 m4 -4.5 % / 1.3x; **q75 m4 -5.2 % / 1.7x**; q100 m4 -5.6 % / 3.3x; q75 m5 -6.1 % / 2.9x; q100 m6 -8.4 % / 29x (too slow for every reimport). Expected: pck -5 % (~11 MB), boot and load time WASH, no pixel. | `project.godot` `[rendering]`: `textures/webp_compression/compression_method=4`, `lossless_compression_factor=75.0` (the knee of the curve). The `.import` files do not change; an existing `.godot` keeps its old imports until the textures reimport (delete `.godot/imported/*.png-*.md5`, touch the `.png.import`, `--import`: 31 s for 1214 textures here). | Imported `.ctex` bytes (all 1220): **209.38 -> 196.87 MB (-6.0 %)**, the same on the scratch project and on d9-perf. windows-bench pck 227.71 MB (11:42 export) -> **215.21 MB** (14:05 export of 5ad88dab): -12.50 MB, the ctex delta (12.51 MB) to within 10 kB. **Pixels: `tools/perf/ctex_same.py` decodes every WebP payload of every `.ctex` (6317 payloads: every mip level of 1220 textures) from the old and the new import and compares RGBA bytes: 1220 same, 0 different.** Boot / load time: not A/B'd (decode cost WASH in the estimate: 0.45 vs 0.42 s for the 30-file sample). | **KEPT**: new baseline. A pixel-free 12.5 MB off the pck; costs ~1.7x texture encode at import. | 5ad88dab |
| L7 | a stripped Windows release export template (exe size, boot, RAM) | The official template (109.3 MB) carries 3D physics, Jolt, navigation, XR, networking, video, the 3D import formats and the texture compressors; the game uses none of them (project grep, addons excluded: no physics body/area/ray/shape, no nav, no network, no video, no noise, no mp3; RegEx, ogg, wav used). A template built without them: smaller exe, less to map and initialise at boot, fewer servers ticking (the 2D/3D physics servers step every physics frame even when empty). Expected: exe -40..-60 %, boot -5..-15 %, RAM -10..-30 MB, frame WASH. | Godot 4.7.2-stable source (`gtai-d9x/scratch/godot-src`), deps from the tree's `install_*.py`, `tools/perf/template/strip.py` (SCons profile), MSVC 14.3, no LTO (the official build has LTO: the two templates differ in that too). First build with `disable_3d=yes`: 63.6 MB, but the exe could not parse the scripts that type `QuadMesh` (a 3D primitive mesh resource the 2D MultiMesh crowds use): `disable_3d` stays off; astcenc stays (the static ANGLE links it). Arms: `off@exe:` vs `strip@exe-windows-bench-strip:` (the same pck, md5 equal). | (pending) | (pending) | (pending) |
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
- Registry: `perf-regression-gating` (cost is busy time measured uncapped; interleave base and head;
  the presented interval is a delivery bar, not a cost gate), `render-submission-economy` (counts A/B
  anywhere, ms only on the host; the order of moves: cull, batch, retain, spread bursts, then the look),
  `measurement-honesty` (CONTENDED per run; unmeasured is never zero; no win inside the noise).
