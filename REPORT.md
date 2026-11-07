# perf lane - day run d9 (2026-11-07) - REPORT (final)

Branch `d9-perf` (cut from main `3982af1a`). Full numbers, method and every lever: `docs/perf/LEDGER.md`.
Journal: `JOURNAL.md`. Clips and stills: `C:\Users\kazda\kiro\gtai-masters\d9\perf\` (`frames.json`).

## In one paragraph
Nothing on screen changed (every kept lever is pixel-free: `top` bit-identical, goldens, parity, the reels), and the
game is lighter: on the shipped release build the 400-actor riot's slow frames are halved (p99 12.5 -> 8.1 ms, worst
25.3 -> 12.2 ms, never over 25 ms now), the pck is 12.5 MB smaller, a > 60 Hz monitor costs ~40 % less CPU (no
duplicate frames), a minimized game about half the CPU, and the title card ~nothing. The biggest remaining wins
move pixels or need a file in another lane, so they are Calls below (BC7: a third of the VRAM; the traffic-sheet
split: ~96 MB of RAM; steadier 60 Hz pacing for ~0.06 of a core).

## Gates at the freeze (`evidence/perf/gates-it22/`)
- `node tools/evidence/run.mjs --no-bench` at 5f436fc8 (18:02): lint 15/15, scenarios 52 / 0, parity native == GDScript bit
  for bit (1200 steps, planted mutation caught), look goldens 11/11 + block 5/5, world lock holds, release-compile 601 / 0.
  Its unit step read FAIL only because I edited REPORT / LEDGER under it ("tree changed during run": docs, no `project/`
  file); the counts were 1712 / 0. Re-run clean on the committed 72ac1254 (18:04): **unit 1712 passed, 0 failed**.
- Director reel at 72ac1254, headless `--fixed-fps 60 --quit-after 14000`: **top, tilt70, combo 19/19 chapters down,
  0 SCRIPT ERROR** each.
- The engine prints one `shader_compiler.cpp:1329 custom_samplers` ERROR line in every arena run, and the leak count at
  `--quit-after`; both are in this morning's L2 reel logs too (`evidence/perf/reel-l2/`), not from a perf lever.

## The exe for the owner
`build/export/windows/RTAI.exe` (324.5 MB, pck embedded; + `gtai_sim.windows.template_release.x86_64.dll` beside it),
exported 18:05 from 72ac1254 in 22 s, 0 errors (later commits touch docs and evidence only, no `project/` file):
```
export APPDATA=C:/Users/kazda/kiro/gtai-d9x/appdata/perf
"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe
```
Smoke: `build/export/windows/RTAI.exe --headless --quit-after 600` exits 0, the arena opens, 0 SCRIPT ERROR
(`evidence/perf/gates-it22/exe-smoke.log`). To see the levers: run it on a > 60 Hz monitor (L10: Task Manager CPU ~40 %
lower than main's exe), or minimize it (L12 + L14); `RTAI.exe -- --frame-cap=off` gives main's behaviour for both.

## Calls for the owner

(each has a default that is already built; the default is "no change")

### Call P-1: compress the drawn art as BC7 (a third of the VRAM, no frame cost) - default built: lossless (no change)
- **What:** the 712 textures under `features/{characters,city,vehicles}/art` imported as VRAM-compressed BC7
  (`compress/mode=2`, `high_quality=true`) instead of lossless. One import param per file; 73 s reimport.
- **Buys (measured, bench.lock, `evidence/perf/l4-bc7/ab.json`):** peak VRAM drive 902 -> 573 MB, riot 883 -> 554 MB
  (-37 %); texture memory -65 %; textures load as GPU blocks with no PNG decode (Godot docs rate it "fast" to load vs "slow" for
  lossless; its effect on the first-death hitch is NOT measured yet: NEXT).
  Frame times, GPU ms, draws, CPU and RAM unchanged on this PC (a WASH). On a shared-memory handheld that is
  ~330 MB of RAM back (REQUEST to the handheld lane).
- **On a handheld-class iGPU (the handheld lane's E10, answering my REQUEST, 13:27, CONTENDED 1-3, their LEDGER E10):**
  the city's private RAM 1386 -> 898 MB and GPU shared memory 1007 -> 489 MB (about 1 GB back on a shared-memory
  device), render GPU 8.33 -> 7.37 ms (-12 %, unlike the 4090); the King fight saves memory but not GPU time. It pairs
  with their REPORT Call 6 (lossless / BC7 everywhere / BC7 in a handheld build only): one answer can cover both.
- **Costs:** pixels move. At 64 px/m: the drive's mean difference is 0.9/255 (PSNR 29.8 dB), the riot's 3.9/255
  (PSNR 24.8 dB). Per region (measured with option (b), 13:35): the figures' ink outlines carry most of it, not the
  asphalt as I first thought; figures and ink lines read the same to me at x2 and x4.
  The install grows ~160 MB (BC blocks are not compressed in the pck). Look goldens would need a re-bless.
- **Look at:** `gtai-masters\d9\perf\l4-riot64-lossless-vs-bc7-x2.png` and `l4-drive64-lossless-vs-bc7-x2.png`
  (left lossless, right BC7, centre crop x2).
- **Options:** (a) keep lossless (default); (b) BC7 for characters + vehicles only, keeping the city's ground
  and facades lossless: measured 13:16 (LEDGER L4b), riot peak VRAM 867 -> 686 MB (-21 %, about half of (c)'s
  saving), frame times unchanged. Its pixels: the ground and facades exact, the difference only on the figures'
  ink outlines (riot PSNR 26.0 dB vs (c)'s 24.8; by eye at x4 the same: `l4b-riot64-lossless-vs-bc7cv-ink-x4.png`,
  where it sits: `l4b-riot64-frame-and-diff.png`). (b) is not much cleaner than (c) on the figures, so if BC7 at all,
  (c) buys the most; (c) BC7 for all three.
- **Measured on the way:** BC7 does not remove the first-death hitch by itself (worst frame 23 ms without the
  worker-thread strip prefetch, 18-19 ms with it), so the prefetch (kept lever L3) stays whichever option you pick.

### Call P-2: the engine holds ~208 MB of upload buffers on the riot; how to get ~100 MB back - default built: no change
- **Found (L9, measured with a log line inside the engine):** Godot 4.7.2 copies every texture to the GPU through
  "transfer workers", and each one keeps a CPU-side buffer of the next power of two above the largest texture it ever
  uploaded, for the whole session. On the 400-actor riot that is 4 buffers of 128 + 32 + 32 + 16 = 208 MB. The 128 MB
  one comes from a single texture: the vehicles' `p70/traffic_cards.png` (4032 x 4480, 69 MB uncompressed).
- **Options:** (a) no change (default; nothing built changes). (b) Split that traffic sheet so no texture is over 32 MB
  (the size of the street strips, which already need a 32 MB buffer): the same drawn cells, so no pixel moves;
  an **estimate** of about -96 MB of resident memory with the stock engine. Not measured yet: it is in the vehicles code,
  so it is a REQUEST, not mine to edit. (c) Patch the engine to free oversized idle buffers: measured -96..-112 MB of
  device memory and 746 -> 686 MB working set at the 60 fps cap, but it needs our own export template, and on this PC's
  compiler a home-built template is ~10 % slower a frame (L7), so it is not worth it today. (d) Report it upstream to
  Godot with the measurement (outward-facing: only with your OK; nothing posted).
- **Recommended:** (b), plus (d) if you agree to post. Most valuable on handhelds with shared memory, where these buffers
  come out of the same RAM as the game.

### Call P-3: smoother frame pacing at 60 Hz for ~0.1 of a core - default built: no change at 60 Hz
- **Context (L10, kept):** nothing on screen moves between the game's 60 Hz ticks, so on a 120 / 144 / 165 Hz monitor the game
  used to draw the same picture 2-3 times. It now caps itself at 60 fps on such monitors (vsync on): on a simulated 144 Hz
  display that is **-38 % CPU on the riot, -42 % on the city drive, -41 % in the King fight**, and no duplicate frames, with the same images per tick.
  It does nothing on a 60 Hz monitor (this PC), so nothing you have seen changes. `--frame-cap=off` is the before.
- **Found on the way (F15):** on a 60 Hz monitor, adding the same 60 fps limiter on top of vsync makes delivery steadier: the
  slowest 1 % of frames 20.4 -> 17.1 ms, and the 1-3 skipped ticks per 30 s gone. Cost: +30 % process CPU on the riot
  (0.37 -> 0.48 of a core), 0.25 -> 0.30 on the drive.
- **Re-measured at 16:31 (L11, 3 more pairs):** the same steadiness (riot: slowest 1 % 19.8 -> 16.9 ms, worst frame 35 ->
  18 ms) for a smaller cost than first measured: **+0.06 of a core on the riot, +0.09 on the drive** (two copies of the same
  setting differ by up to 0.03). All of it is on the game's main thread. A different present mode (mailbox) gives the same
  steadiness for the same CPU, so there is no cheaper way to (b) on this engine. Evidence: `evidence/perf/l11-present/`.
- **Why it costs that (F18, found 17:20 in the engine's Windows source):** the limiter sleeps to 1 ms before the frame is
  due and then spins the CPU for that last millisecond (1 ms of 16.7 = 0.06 of a core): the measured cost, exactly. The
  engine's low-power mode sleeps instead of spinning but wakes up to ~1 ms late; whether that keeps (b)'s steadiness is a
  later A/B, so (b) may become nearly free. (L14 already uses exactly that mode while minimized, where pacing does not
  matter: ~-0.06 of a core, F18's size, so the mechanism is confirmed; the on-screen pacing A/B is not done.)
- **Tried at 18:08 (L15, one job, a loaded machine):** the limiter in low-power mode during play costs less CPU
  (riot 0.57 -> 0.50 of a core) but paces like no limiter at all (slowest 1 % 32.5 -> 37.9 ms, skipped tick images 20 -> 42
  per 30 s): the steadiness and the spin come together on this engine, so (b) is not free. The options stand as written.
- **Options:** (a) no limiter at 60 Hz (default: least CPU). (b) the limiter at 60 Hz too (steadier delivery). (c) a
  'frame pacing: efficient / steady' option in the settings, default (a). Evidence: `evidence/perf/l10-cap/ab.json`.
- **Recommended:** (c) when a settings screen for it exists; (a) until then. The bigger lever above 60 Hz is drawing
  in-between positions (interpolation), which would make 144 Hz look smoother than 60: a look change, so a later Call.

### FYI F-19 (not a choice, needs an owner): quest 1 can freeze at its first line, on main too
- Found 17:10-17:40 while measuring L13: started with `--autostart`, quest 1 **freezes in about 1 run in 4** (9 of 33 windowed
  runs, editor binary): the picture stops on Rivet's "Okay" line, Esc does nothing, Windows marks the game "not responding",
  and its main thread uses 0 CPU (it is stuck waiting, not busy). It happens on this morning's **main** too (1 of 5), with
  every perf lever switched off, and with the window on top. So it is an existing bug, not a perf change.
- Suspects (the only places the main thread waits on another thread): the city chunk reads (`chunk_source.gd` `take`), the
  autosave thread (`save_worker.gd`, quest 1 saves as it starts), the threaded texture loads. Evidence:
  `evidence/perf/f19-freeze/` (the hunt script, the frozen run's thread split and log), LEDGER F19.
- Not yet checked: whether a real Start click (not `--autostart`) freezes too, and the release export.

## What works: kept on the branch (pixel-free; numbers and A/B method in LEDGER)

- **L10 frame cap at the tick rate on > 61 Hz displays** (15:48): simulated 144 Hz riot 0.68 -> 0.42 cores, drive 0.52 ->
  0.30, the King under combo 0.80 -> 0.47, duplicate frames 2450 -> 0 per 30 s; **on the shipped release build (16:42)
  riot 0.68 -> 0.39 (-43 %), drive 0.47 -> 0.29 (-38 %)**; a no-op at 60 Hz and headless (Call P-3 for the 60 Hz pacing option).
- **L12 the same cap while minimized** (16:52): a minimized game used to spin at ~145 loops a second and cost MORE CPU
  than on screen (riot 0.35 -> 0.58 cores); now the King fight minimized costs **0.73 -> 0.38 cores (-49 %)**, the same ticks,
  nothing on screen changes (`--frame-cap=off` is the before).
  **L14 (17:47):** minimized, the engine now also sleeps instead of spinning (F18): a further **~-0.06 of a core** (King
  minimized 0.45 -> 0.35 raw, 0.04 of that is run-to-run offset); `--frame-cap=spin` is the L12-only before.
- **L13 the title card idles** (17:26): the slice's title card is a still picture but was redrawn 60 times a second;
  it now runs in the engine's low-processor mode (a frame is drawn only when something on it changes, a button's hover
  still redraws at once): **0.033 -> 0.004 cores (-88 %)**, the card pixel-identical. The pause card measured no gain (the
  city behind it redraws anyway), so it is left as it was (one value, `MenuIdle.PAUSED_IDLE`). `--menu-idle=off` is the before.
- L2 CircleFan fan build (riot p99 22.2 -> 11.9 ms), L3 strip prefetch (riot worst 27.2 -> 18.0 ms), L5 snapshot passes
  (-40 % of that pass's CPU, no frame claim), **L8 lossless WebP effort** (14:05): the pck 227.7 -> 215.2 MB
  (-12.5 MB) with every mip of every texture decoding bit-identical; costs ~1.7x texture encode at import.
- Dropped with numbers: L1 renderer/driver, L6 render thread, **L7 a stripped export template** (exe 109 -> 67-74 MB and
  ~-10 MB RAM, but the MSVC build is ~10 % slower a frame than the official MinGW-GCC template, LTO or not).

## Final table: this morning's main vs d9-perf (LEDGER "Final table"; release build unless marked)
| scene | metric | main | d9-perf | verdict |
|---|---|---|---|---|
| riot, 400 actors, fixed 60 | p99 / p99.9 / worst ms | 12.53 / 24.00 / 25.33 | **8.09 / 10.36 / 12.16** | WIN -35 / -57 / -52 % (L2 + L3) |
| riot | p50, draws, CPU, RAM | 3.85 ms, 832, 1.03, 754 MB | 4.08 ms, 832, 1.01, 756 MB | WASH |
| city drive at 70, 48 px/m | p50 / p99 / worst ms | 2.30 / 4.28 / 6.34 | 2.14 / 4.13 / 5.98 | WASH |
| riot / drive at 60 Hz, vsync | CPU cores | 0.34 / 0.18 | 0.32 / 0.18 | WASH (this PC's panel) |
| riot / drive, simulated 144 Hz | CPU cores, duplicate frames | 0.68 / 0.47, 2450 | **0.39 / 0.29, 0** | WIN -43 / -38 % (L10) |
| King under combo, minimized (editor) | CPU cores | 0.73-0.75 | **0.34-0.35** | WIN ~-53 % (L12 + L14) |
| slice title card (editor) | CPU cores | 0.033 | **0.004** | WIN -88 % (L13) |
| pck | MB | 227.70 | **215.21** | -12.5 MB, pixel-exact (L8) |
| boot to first frame | s (release vs editor binary, it4) | | 2.58 vs 4.08 | (no lever moved it; L7 WASH) |

## What does not work / dropped (with numbers in LEDGER)
- **L1** Mobile / GL Compatibility / Vulkan: no win (Vulkan crashed 8 of 9, F1); Forward+ on D3D12 stays.
- **L6** the separate render thread: +16 % CPU, no frame win.
- **L7** a stripped export template: exe -32..-39 %, ~-10 MB RAM, but my MSVC build is ~10 % slower a frame than the
  official MinGW-GCC template. Retry only with the official toolchain.
- **L9** an engine patch that frees the oversized upload buffers: works (-96..-112 MB), but needs a custom template (L7's
  loss). Call P-2 option (b) reaches the same RAM with the stock engine.
- **L11** mailbox present mode: same as the limiter for the same CPU (WASH).
- **L15** low-power mode under the 60 Hz limiter in play: -0.07 core but the limiter's steadier pacing is gone.
- **L13's pause card**: no gain (the city behind it redraws every frame): left off (`MenuIdle.PAUSED_IDLE = false`).
- **L5** gives -40 % of its pass's CPU (microbench) but no frame-level win beyond the noise; kept as a CPU cut only.

## What blocked me (and for how long)
- F19 chase (17:10-17:35, 25 min): runs reading ~0 CPU were quest 1 frozen, not the lever (FYI F-19 above).
- Earlier sessions (JOURNAL): the shared machine (CONTENDED in most runs: numbers are A/B'd in one job with the lock
  held, and an A-vs-A arm sets the floor), a 10-min runner limit waiting on the bench lock (L4, re-run), a void L10 job
  (I edited `project/` under it), `city_bench` rejecting unknown args (11:30).

## Tooling built today (stays; documented in LEDGER "Tooling built today")
- `tools/perf/ab.mjs` + `stats.mjs` (+ test) + `proc_sample.ps1`: interleaved A/B jobs (flag, `@exe`, `^--path` and env
  arms), medians, spreads, WIN / WASH / LOSS against the spread, CONTENDED tagging, bench.lock queueing.
- `--perf-hud` (`dev/perf/perf_hud.gd`): live frame-budget overlay (frame bars, p50 / p99 / worst, process / physics /
  render CPU / GPU ms, draws, objects, nodes, RAM / VRAM).
- `city_bench` additions: GPU ms (timestamp queries), peak VRAM / texture memory, tick cadence per frame
  (duplicate frames, skipped tick images), `--max-fps`.
- `tools/perf/thread_cpu.ps1`: per-thread CPU split by thread name / start module (which thread pays).
- `tools/perf/boot.sh` (boot to first frame), `webp_effort.py`, `ctex_same.py` (every mip of every texture decoded and
  compared), `template/strip.py` + `tw_trim.py` (engine build profiles), the probes under `evidence/perf/l12-*`, `l13-*`,
  `l14-*`, and `evidence/perf/f19-freeze/hunt.ps1`.
- Shared with the handheld lane (REQUESTs both ways in JOURNAL): its E10 / E12 rows were measured with these.

## Next steps
1. F19: a stack of the frozen main thread (procdump / a debug template) and the real Start click; the save worker and
   `chunk_source.take` are the suspects.
2. Call P-3 (b): L15 says low-power mode loses the pacing; the next try is a shorter final spin (an engine change
   upstream: the Windows limiter's 1 ms `delay_resolution`), re-measured on an idle machine.
3. Call P-2 (b): the traffic-sheet split (vehicles' files; REQUEST in JOURNAL), then measure the -96 MB.
4. L7 again with the official toolchain (llvm-mingw + LTO) and an unstripped A-vs-A build.
5. Interpolated drawing above 60 Hz (`SimClock.alpha()` has no reader): smoother on 144 Hz, a look change: a Call.
