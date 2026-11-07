# JOURNAL: lane handheld (d9, 2026-11-07)

## Iteration 1 (10:21-11:21, BUILD)

- 10:22 read AGENTS, the brief, launch args, the arena, FightFrames (`--frames=` is the frame log I reuse),
  input_actions.json (the pad map). No JOURNAL yet; created. d9-perf has no JOURNAL yet.
- Registry rules applied (game-production): `on-device-verification-harness` (the instrument is part of
  the experiment: the sampler is one PowerShell loop, not a process per sample; phases are different
  populations: boot/prewarm and the first second are cut from the settled stats; "trusting the requested
  rate": the delivered frame time is measured, never Engine.max_fps), `fire-tv-device-realities`
  ("treating the emulator as the device": every number is labelled on the simulator; the 2-CU iGPU and the
  Zen 4 cores bias GPU pessimistic, CPU optimistic, written in the LEDGER caveats), `perf-regression-gating`
  (no bare difference: interleaved rounds, medians, the spread stated; "the reference from another machine":
  the baseline is this PC only; no retry that selects), `adaptive-fidelity-tiers` (software-engineering; the
  `tier` field is the device's fidelity tier, the views read it, desktop = full),
  `controller-latency-instrumentation` (not measured yet; owed: input-to-screen needs a camera, only the
  consumption age is measurable here).
- MILESTONE 10:27 `--device=<id>` profile: `data/tables/devices.json` (+schema), `DeviceProfile`
  (core/platform), applied in `LaunchArgs._ready` before the main scene; desktop row applies nothing.
  6 unit tests. Commit c0c048d2.
- FRICTION `tools/godot/check.mjs res://boot/launch_args.gd` fails "Identifier not found: Log" in
  DeviceProfile: `--check-only -s` on an autoload script does not register the other autoloads. The game run
  and GUT are clean (the profile logs `[INFO] device: profile deck: ...`). Tool artefact, not a bug.
- FRICTION the debt ratchet counts `OS.get_cmdline_user_args()` reads; DeviceProfile takes the value from
  LaunchArgs instead (`DeviceProfile.select(value("--device"))`).
- MILESTONE 10:30 simulator: `tools/handheld/sim.mjs` (Start-Process + ProcessorAffinity + BelowNormal,
  `--gpu-index 1` = the AMD Radeon iGPU, found from `--verbose`), `sample.ps1` (CPU %, RAM, GPU process
  memory), `ab.mjs` (interleaved A/B). Commit f356682c.
- E0 smoke: deck on the iGPU, the director reel 1200 ticks: p50 16.64 ms (vsync 60), render GPU 6.95 ms,
  986 MB private, 587 MB GPU shared, CONTENDED.
- 10:31 E1 renderer A/B running (forward_plus / mobile / compat, deck_bench uncapped, 3 rounds).
- E1 result: Forward+ GPU 6.69 ms (+-0.55) vs Mobile 6.34 (+-0.18) on the iGPU, frame p50 7.45 vs 7.21 uncapped:
  inside the noise, DROPPED. Compatibility went to the RTX 4090 (OpenGL follows the display's GPU): not comparable.
- FRICTION/BLOCKED (10 min) E1b: a private exe copy (`gtai-d9x/handheld-godot/Godot_v4.7.2-stable_win64_hh.exe`) with
  the HKCU DirectX per-app GPU preference "power saving" still rendered OpenGL on the 4090. The registry value is
  scoped to that private path only; remove it at the end of the day
  (`HKCU\Software\Microsoft\DirectX\UserGpuPreferences`, value = that path).
- MILESTONE 10:38 pad audit: radio_next was on Guide (a handheld's system button), reload had no pad button. R3 now
  carries both (as R on the keyboard). L3/R3 prompt labels. Commit 1978ee79. Rumble, aim assist, glyph images: owed.
- MILESTONE 10:41 clips: the King fight (40 s) and the city (25 s) at 1280x800 under `deck` on the iGPU, in
  gtai-masters/d9/handheld (32 px/m: filmed before zoom_k). Looked at the stills: HUD text reads; Rivet at 32 px/m is
  ~25 px tall, ~3 mm on a 7-inch panel.
- E2 suspend: NtSuspendProcess 20 s mid-reel: resume frame 20 057 ms, the sim advanced 1 tick (SimClock clamp), exit 0.
- DECISION zoom: handheld rows `zoom_k` 1.5 (48 px/m on foot); 1.25 the alternative (Call 1). Stills 32/40/48 looked
  at. Applied in CameraRig (world.gd), quest 1's view, the dev arena's default (member init: no line growth for the
  debt ratchet). Commit 58a32c2a. Desktop multiply by 1.0 = exact.
- FRICTION my first compat run wrote its frame log under project/evidence (a relative --out resolved by Godot's cwd);
  lint's layers check caught it; deleted, sim.mjs now resolves --out absolute.
- MILESTONE 10:50 `linux-showcase` export preset: the export stops on the missing CitySim .so
  (`libgtai_sim.linux.template_release.x86_64.so`); the game itself falls back to the GDScript sim without it.
  WSL Ubuntu 24.04 has no g++/scons and no passwordless sudo (not installing into the user's distro); pulling Valve's
  Steam Linux Runtime 3.0 sniper SDK image in Docker Desktop to build the .so against glibc 2.31 (the Deck's runtime).
- 10:52 gates: unit 1698 passed 0 failed; the director reel in top / tilt70 / combo / combo+deck running.
- MILESTONE 10:56 pause on focus-out (HandheldFocusPause, handheld rows only), commit 089afea8 (+ linux-showcase
  preset). FRICTION quest1_game.gd is past the soft cap: any line added there trips the debt ratchet, so the pause
  lives in its own node added by LaunchArgs.
- 10:57 reel top: 19/19 chapters all down, 0 SCRIPT ERROR (evidence/reel-top.log).
- FRICTION the godot-cpp submodule is not checked out in this worktree; the sniper build mounts the main checkout's
  native/godot-cpp read-only (same pinned commit e103d348) and builds in a container copy (nothing written to the repo
  but the git-ignored .so).
- WSLg: Mesa d3d12 Gallium (OpenGL) is there, no Vulkan-on-D3D12 ICD (only lavapipe, CPU): the Linux build in WSL can
  run Compatibility on a chosen adapter (MESA_D3D12_DEFAULT_ADAPTER_NAME), Forward+ only on the CPU rasteriser.
- FRICTION 11:00 the reel tilt70 gate booted while handheld_focus_pause.gd still had the discarded-return parse error
  (fixed 10:55): 2 SCRIPT ERROR, LaunchArgs failed to load. My edit during a gate run, not a regression: invalid run,
  re-run queued after combo/deck. Lesson: never edit project/ while a gate run is live.
- MILESTONE 11:02 the Linux .so (release + debug) built in the sniper SDK container in ~3 min; `linux-showcase`
  exports (292 MB + 396 KB .so). E4: the export runs the city under `deck` in WSLg on the AMD iGPU through Mesa
  GL-on-D3D12 (`GALLIUM_DRIVER=d3d12` needed, else llvmpipe): p50 19.8 ms, p99 38.6. A path proof, not a renderer verdict.
- 11:03 reel combo 19/19, 0 SCRIPT ERROR.
- REQUESTs: none received (perf has no REQUEST for handheld; rivet/seams REQUESTs are to assets). None sent yet.
  Idea for perf (iteration 2 REQUEST): share `tools/handheld/ab.mjs` (interleaved rounds) and the frame-log summary.

- MILESTONE 11:11 gates on the final code: unit 1698 passed 0 failed; lint 15/15; the director reel top 19/19,
  combo 19/19, combo + --device=deck 19/19, tilt70 re-run 19/19, all 0 SCRIPT ERROR (evidence/gates-it1b.log).
  Not run this iteration: `tools/evidence/run.mjs --no-bench` (look goldens, replay, parity): first thing next.

NEXT (iteration 2):
1. `node tools/evidence/run.mjs --no-bench` for top bit-identical (look goldens, replay, parity).
2. A/Bs on the bench lock: deck40 vs deck (CPU % of the pinned threads, GPU busy, as the power proxy);
   handheld_1080 (viewport stretch) vs handheld_1080_native; switch_handheld at 3 threads (does the 30 cap hold?).
3. Live proof of the focus-out pause (a scenario: quest 1 running, send NOTIFICATION_APPLICATION_FOCUS_OUT).
4. Rumble behind a setting + the handheld rows (Input.start_joy_vibration on hit/blast/crash); glyph pad type.
5. NAT-06 parity on the Linux .so inside WSL (the sniper .so on Ubuntu's glibc 2.39 runs: forward compatible).
6. Re-film the King fight + city at zoom_k 1.5 (the clips are 32 px/m) and a 30-90 s combined clip.
7. End of day: delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and that copy.

## Iteration 4 (11:14-12:14, BUILD)
- Read: JOURNAL, git log, d9-perf JOURNAL (one REQUEST to handheld, answered below), d9-rivet / d9-seams journals
  (their REQUESTs go to assets; none to handheld). Registry rules as in iteration 1 (on-device-verification-harness,
  perf-regression-gating: interleaved rounds + medians + spread, CONTENDED stamped; fire-tv-device-realities: every
  number "on the simulator"; adaptive-fidelity-tiers: the handheld tier is data, the desktop row applies nothing).
- FRICTION 11:15 `tools/evidence/run.mjs` refuses a dirty tree: the raw sim frame logs (6.8 MB, untracked) sat in
  evidence/sim. Moved them out of the repo to `gtai-d9x/scratch/handheld/frames/` (the committed summaries keep
  the numbers). Evidence gate re-started 11:16 (log `gtai-d9x/scratch/handheld/evidence-it4.log`).
- ANSWER to perf's REQUEST (tooling share): thanks; the two runners overlap (yours: scene presets + `^<engine args>`
  arms; mine: affinity pin + below-normal priority + the iGPU adapter + `--device=`). I keep `tools/handheld/sim.mjs`
  for the device numbers (the pin and the adapter are the device) and will read `proc_sample.ps1` before growing
  sample.ps1. L2 (CircleFan) is on d9-perf only; I cannot take it into my numbers until the Director merges it, so
  the riot under `deck` on the iGPU stays measured without L2. Lever back to perf: zoom_k 1.5 (the handheld rows)
  shows 1/2.25 of the world area per frame: possibly a CPU/GPU cut (unmeasured; E6 below) that the desktop cannot take
  (the look moves), recorded so perf does not chase it.
- 11:23 evidence gate (on 140c690d): look goldens all ok (11/11 frames, max_far 0.003 vs 0.02), world-lock written,
  then **crashed at release-compile**: `%TEMP%/gtai-release-compile` holds `d9-seams-f6bf436c/` (seams' per-worktree
  version of the tool, their "release-compile clash" item); my older tool refuses a dir without its marker. Not mine to
  fix (seams owns it); once their tool merges, the clash is gone. Re-run with `--no-release`.
- MILESTONE 11:30 rumble (5be5495c): `HandheldRumble` on the Events bus, `rumble` gain per device row (handheld rows 1,
  desktop none), a `deck_bench_z1` study row (zoom_k 1.0) for E6. Glyphs (7bd44dfa): `PadGlyphs` relabels the prompts
  for PlayStation / Nintendo-layout pads under the handheld rows. 22 unit tests in the four touched files pass; lint 15/15.
- FRICTION Godot writes `vendor_id` as a decimal string in `get_joy_info` (itos), not an int: the classifier takes both
  (model knowledge of the engine source; unverified without a pad: no pad on this PC).
- MILESTONE 11:37 evidence gate `--no-bench --no-release` on 9b35dd21 (rumble + glyphs in): lint 15/15, unit 1708/0,
  scenarios 52/52, parity bit-exact over 1200 steps (planted mutation caught at 629), selftest look goldens 11/11
  (worst 0.27), block goldens 5/5, world lock 0.00 %: **top bit-identical** with the device work in
  (`evidence/it4/evidence-run-9b35dd21.log`). Release-compile skipped (the shared temp-dir clash above).
- 11:37 E5/E6 A/B on the bench lock (taken 11:37:45, perf had just released it): city scene, 1200 ticks, 3 interleaved
  rounds of deck / deck40 / deck_bench / deck_bench_z1.
- RESULT 11:45 E5 (`deck40` vs `deck`, city, CONTENDED: 1-4 other Godot runs, bench lock held): both lock to the cap
  (25.05 / 16.63 ms p50); GPU busy 38 % vs 55 % of each second (-31 %), pinned CPU 4.31 vs 5.81 % (-26 %, spread 1.03):
  the 40 Hz mode is a real power cut on the simulator; KEPT as the battery row. E6 (zoom_k 1.5 vs 1.0, uncapped): render
  GPU 8.91 vs 8.88 ms, p50 9.55 vs 9.56: **no difference**; the iGPU frame is fill-bound. DROPPED as a lever.
- CORRECTION to my answer to perf above: the zoom is NOT a CPU/GPU cut (E6 measured none); nothing for perf to take.
- MILESTONE 11:49 reels on 9b35dd21 (run in parallel, 4 Godot): top 19/19, tilt70 19/19, combo 19/19, combo + deck
  19/19, all 0 SCRIPT ERROR (`evidence/it4/reels-summary.log`, logs `evidence/it4/reel-*.log`).
- MILESTONE 11:49 re-filmed at 48 px/m (zoom_k 1.5) under `deck` on the iGPU: the King fight 40 s, the city 30 s, the
  combined set 70 s (`gtai-masters/d9/handheld/deck-set-48ppm-king-city.mp4`), stills at 20 s / 15 s looked at: Rivet
  ~45 px on the 800 px panel, the King and the tell cone read; the ghost-form panel still takes the bottom-left
  (Call 2). frames.json: 13 entries, the new set first. Raw .avi deleted.
- RESULT 11:52 E7 Switch-class budget (3 threads, 30 cap, CONTENDED): the cap holds (p50 33.3, p99 ~37 ms) in the
  reel and the city; city memory ~2.3 GB (RAM + GPU shared) on x86. The CPU is the risk on an A57-class core
  (model-knowledge ratio, not measured).
- FINDING 11:57 rumble live (`HandheldRumble` logs its pulse count on exit): King fight under `deck` 2400 ticks = 1 pulse
  (boss_engaged), director reel 6000 ticks = 0. The bus is thin where a pad should be felt: `player_hit` comes only from
  quest 1's robo-tazer and the pit AI, not from Rivet's damage chokepoint; no fire / blast / crash events. Logs
  `evidence/it4/rumble-*-deck.log`. Owed next: emit `player_hit` where Rivet takes damage (gameplay: Events only, the
  emit is a sim-side fact, so it must not change replay; check the replay/parity gate after).

NEXT (iteration 5):
1. Rumble on every hit Rivet takes. Scouted 12:00: the chokepoint is `CombatArena.damage()`
   (features/combat/combat_arena.gd:174); `player_hit` is emitted only for the robo-tazer (line ~279) and has
   listeners that would move the desktop if it fired on every hit (collect_call_view: Rivet leaks oil; audio_hooks:
   the player_hit cue; quest barks). So do NOT widen `player_hit`: add a new bus signal `rivet_damaged(amount: float,
   weapon: StringName)` (events.json row, emitter features/combat) emitted in `damage()` when the victim is Rivet;
   only HandheldRumble listens, so the desktop has no listener (look, audio, replay unchanged). Also find what the dev
   arena's boss fights use for Rivet's hp (boss_hook reads `r.hp`). Then the evidence gate + reels; live check: the
   King fight's pulse count above 1.
2. E8 fill-rate levers (E6 says the iGPU frame is fill-bound): the handheld tier drawing at a smaller 2D size scaled up
   (stretch viewport, content_scale_size below 1280x800) and the print grain / light passes off on tier `handheld`;
   A/B on `deck_bench` (render GPU ms), stills at 48 px/m to judge the look on a 7" panel.
   Source: Godot's multiple-resolutions doc: viewport stretch renders to a viewport at `content_scale_size` and scales
   it up ("running in lower resolution to increase frames per second"); `canvas_items` renders at the target size; the
   cost is the lost 1:1 sprite-to-screen pixels (https://docs.godotengine.org/en/4.2/tutorials/rendering/multiple_resolutions.html).
   A row field `draw_scale` (content_scale_size = base x draw_scale under viewport stretch) keeps it one data value.
3. `handheld_1080` viewport vs `handheld_1080_native` A/B (iGPU, render GPU ms).
4. A live proof of the focus-out pause (quest 1 running, NOTIFICATION_APPLICATION_FOCUS_OUT sent) as a scenario.
5. NAT-06 parity on the Linux `.so` inside WSL.
6. End of day: delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and that copy;
   the freeze exe.
- RESULT 12:05 E8 (started early from NEXT 2): `draw_scale` on a row (viewport stretch draws at base x scale);
  `deck_bench_ds75` (960x600 scaled to 1280x800) vs `deck_bench`, city, 2 rounds (3/4 CONTENDED, bench lock held):
  render GPU 9.10 -> 5.27 ms (-42 %), frame p50 9.68 -> 5.98. The biggest lever so far on the simulator; NOT the
  baseline yet: the look is unjudged. Unit (device profile, rumble) 13/0, lint 15/15; full gate owed (rows only,
  the desktop never calls apply()).
  -> NEXT 2 becomes: stills of `deck` vs a `deck` + draw_scale 0.75 / 0.85 at 48 px/m, look at them on a 7" scale,
  then a Call for the owner (a/b with the clip) and, if kept, draw_scale on the `deck` rows = the new baseline.
- FINDING 12:08 E8 still (`gtai-masters/d9/handheld/e8-draw-scale-full-vs-075-crop-x2.png`, looked at): 960x600
  scaled up is softer (ink lines, grain) but reads; the framing moved too: the smaller content_scale_size zooms the
  camera 1.33x. Fix first thing next: CameraRig / quest 1 px/m x draw_scale (DeviceProfile.zoom() could return
  zoom_k x draw_scale) so the A/B compares the same view; re-measure (E6 says the zoom itself costs nothing).
- Session end 12:09: tree clean, every change committed; no Godot of mine left running.

## Iteration 7 (12:10-13:10, BUILD)
- Read: JOURNAL, git log -30, the other lanes' journals (no new REQUEST to handheld; perf's tooling REQUEST answered in it4).
- MILESTONE 12:10 (5826e666) E8 framing fix: `DeviceProfile.view_zoom()` = zoom_k x draw_scale under viewport stretch;
  world.gd / quest1_game.gd / the dev arena all read `DeviceProfile.zoom()`; desktop 1.0 (x 1.0 exact). Unit 18/0, lint 15/15.
- 12:11 rows `deck_bench_ds85` (study) and `deck_ds75` (the lever as a 60 Hz play row for the owner's look call).
  Bench lock taken 12:11 (no other Godot up at the start); E8b A/B running: deck_bench / ds85 / ds75, city, 3 interleaved rounds.
- RESULT 12:17 E8b (deck_bench / ds85 / ds75, city, 3 rounds, all CONTENDED 1-3 other Godot, bench lock held): render GPU
  8.91 / 6.69 / 5.31 ms, p50 9.54 / 7.37 / 6.05. **VOID as a same-framing A/B**: see the next FINDING (zoom_k never applied
  in the dev arena, so ds rows ran at 32 x 0.75 drawn = ~43 px/m effective vs 32). Kept in evidence as the record.
- FINDING 12:20 (the big one) the it4 "48 px/m" clips and stills are **32 px/m**: `still-city-48ppm-15.png` is pixel-for-pixel
  the explicit `--ppm=32` still. Cause: the dev arena reads `px_per_m = 32 * DeviceProfile.zoom()` in a member initializer,
  which runs when the main scene is built, before `LaunchArgs._ready` selected the profile (desktop row: 1.0). Quest 1 and the
  city drive (world.gd) read later, so they were right. Fix 4a773812: select in `LaunchArgs._init`. Consequences: **E6 was
  void** (both sides at 32 px/m), E5 is unaffected (both rows at the same zoom), E8 (it6) compared 32 vs ~43 px/m. frames.json
  entries corrected (ppm 32, "mislabelled" note); LEDGER corrected below. Re-measure E6 + E8 (E8c) and re-film at real 48.
- FRICTION 12:21 two parse errors (return value discarded = error) slipped into a sim run because I ran sim before the unit
  test: the run used a broken LaunchArgs (frames void, deleted). Rule for me: `node tools/godot/check.mjs` on every touched
  .gd before any Godot run.
- MILESTONE 12:23 rumble on every hit Rivet takes (31e7b1e6): view-side read of `rivet.hurt_tick` in HudFeed ->
  `HandheldRumble.feel_hurt` (static, a no-op without a rumble row). Not a bus signal: combat_arena.gd is at the 300-line
  hard stop and `player_hit` has desktop listeners. DECISION in docs/decisions.md. Unit 24/0.
- MILESTONE 12:29 focus-out pause proven live (e2f222df): `scenario_handheld_focus_pause` (quest 1 running 30 ticks,
  NOTIFICATION_APPLICATION_FOCUS_OUT propagated from root: paused, world stopped, pad off; planted fault = no handheld
  node: stays live). 1 ran, 0 failed. HandheldFocusPause got `target_quest` (null = current scene) and an is_inside_tree guard.
- MILESTONE 12:20 E8b look stills at real 48 px/m, same framing (`e8b-deck-vs-ds75-48ppm-city-t720*.png`, looked at):
  0.75 is softer (grain, hatched shadows, cracks, Rivet's ink line); and the HUD lays out in 960x600, so the ghost-form
  panel is 1.33x bigger on the panel. DECISION: draw_scale stays a Call (deck_ds75 row), not the Deck baseline.
- 12:24 E8c running (bench lock): deck_bench (z 1.5) / deck_bench_z1 / ds85 / ds75, city, 3 rounds: E6 + E8 re-measured.
- RESULT 12:35 E8c (the valid re-measure; 11/12 CONTENDED, bench lock held 12:24-12:35, released): render GPU deck_bench
  48 px/m 8.12 / z1 32 px/m 9.01 / ds85 6.21 / ds75 5.14 ms; p50 9.19 / 9.65 / 6.78 / 5.88. The zoom is ~10 % CHEAPER at
  48 (less world per frame), not free and not a cost. draw_scale -24 % / -37 %. DECISION (decisions.md): draw_scale stays a
  Call (REPORT Call 5, default = full draw); zoom_k 1.5 kept. LEDGER row E8c.
- RESEARCH 12:36 the Deck's own scaler: gamescope's Scaling Filter (linear / integer / FSR 1.0) in the quick access menu
  acts only when the game renders below 1280x800; our in-engine viewport stretch hides that from it. Alternative recorded in
  the LEDGER (a Deck render-resolution setting: a 960x600 window, the player picks FSR or integer). Untested (no gamescope here).
- 12:35 running: reels top / tilt70 / combo / combo+deck (`evidence/it7/`) and the real 48 px/m King + city films under
  `deck` on the iGPU (the King film's exit line gives the rumble pulse count with the new hurt read).
- Registry rules applied this iteration: perf-regression-gating (interleaved rounds, medians + spread, CONTENDED stamped,
  a void result re-measured, not patched); motion-quality-gating / generative-artifact-gating (judge the look at the same
  framing before keeping a speed lever: E8b caught the framing confound); fire-tv-device-realities (every claim "on the
  simulator"; the Deck's scaler is a device behaviour we cannot see here); adaptive-fidelity-tiers (the lever is a row value).
- MILESTONE 12:39 reels on e2f222df code (4 in parallel): top / tilt70 / combo / combo + deck 19/19, 0 SCRIPT ERROR
  (`evidence/it7/reels-summary.log`). Rumble live under `deck` in the director reel: **4 pulses** (it4: 0): the hurt read works.
- MILESTONE 12:41 the real 48 px/m set under `deck` on the iGPU (after the fix): `deck-set-48ppm-real-king-city.mp4` (70 s),
  `deck-king-48ppm-real-*.mp4`, `deck-city-48ppm-real-*.mp4`, stills at 20 s / 15 s looked at (Rivet ~70 px in the King
  fight; pale Rivet is low-contrast on the pale pavement at 15 s in the city). frames.json 15 entries, the real set first;
  the superseded stills deleted, the it4 clips kept but re-labelled 32 px/m.
- MILESTONE 12:48 evidence gate on 93c1fb69 `--no-bench --no-release`: lint 15/15, unit 1711/0, scenarios 53/53 (with
  handheld_focus_pause), parity bit-exact over 1200 steps (planted mutation caught at 629), look goldens 11/11 (worst
  0.27): **top bit-identical** (`evidence/it7/evidence-run-93c1fb69.log`). Release-compile still skipped (seams' temp-dir clash).
- RESULT 12:52 E9 (handheld_1080 viewport vs native, city, 2 rounds, CONTENDED, bench lock 12:49-12:52): render GPU 9.86 vs
  16.09 ms; p50 16.65 (vsync-locked) vs 17.44 (misses 60). Viewport stretch KEPT on the 1080 rows. LEDGER E9.
- FINDING 12:55 a 1080 row still via --write-movie is not faithful: the movie is 1280x800 (the project base), the window is
  1920x1080 with `aspect=expand` (16:9 -> a 1422x800 base), and the ghost-form panel's left edge was cut in the frame
  ("onnage"). Either the capture crops or the HUD really clips on a 16:9 panel under viewport stretch: unknown. Still
  deleted (not shown as evidence). Owed: a true panel grab (`get_viewport().get_texture().get_image()` at the window size,
  or an OS screenshot of the window) under handheld_1080, and the HUD anchors at 16:9.
- Session end 12:56: every change committed; no Godot of mine running; bench lock released (12:52).

NEXT (iteration 8):
1. The 1080 row's HUD at 16:9: a true window grab under `handheld_1080` (see the FINDING above); if the ghost-form panel
   clips, it is the hud's anchors under viewport stretch + aspect expand: a REQUEST or a handheld-only fix behind the row.
2. draw_scale's HUD side effect (the HUD lays out in the smaller size under viewport stretch): if the owner takes Call 5 b/c,
   the HUD needs its own CanvasLayer at the panel size (or a counter-scale) so only the world draws small.
3. The King fight's rumble pulse count with the hurt read (the sim does not keep the engine log: add `--log=` to sim.mjs
   or read HandheldRumble's exit line from a direct run), and the Switch-class row (E7) re-checked at a real 48 px/m
   (E7 ran with zoom_k unapplied in the arena: its numbers were at 32 px/m; E8c says 48 is ~10 % cheaper, so E7 holds).
4. Re-check E5 is unaffected (both rows at the same zoom, so the ratio stands) and E1/E2/E3 claims in the LEDGER that
   came from the dev arena (all ran at 32 px/m): label them "at 32 px/m" where it matters.
5. NAT-06 parity on the Linux `.so` inside WSL.
6. End of day: delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and that copy;
   the freeze exe (`build/export/windows/RTAI.exe`).

## Iteration 10 (12:56-13:56, BUILD)
- Read: JOURNAL it7 + NEXT, git log -15, the other lanes' journals. **REQUEST from perf** (it5, L4): a BC7 arm on the
  iGPU Deck row (BC7 cut the riot's peak VRAM 883 -> 554 MB on the 4090 at no frame cost; on a shared-memory handheld
  it is RAM back, and the GPU side may move where bandwidth is scarce). Answering it first this iteration (E10).
- 12:58 (8a37f4a9) `sim.mjs --project=<dir>`: an A/B arm can run another checkout's project (import settings differ,
  code identical). Node tests 4/0, lint 15/15.
- 12:58 scratch worktree `gtai-d9x/scratch/hh-bc7` (detached at 8a37f4a9, my .godot cache copied in, native bin +
  override.cfg copied): the 712 `features/{characters,city,vehicles}/art/**/*.png.import` set to `compress/mode=2` +
  `high_quality=true` (perf's arm), `--import` 90 s, 712 `.bptc.ctex` written, 0 errors.
- 13:00 E10 running (bench lock): deck_bench city / city BC7 / king / king BC7, 1200 ticks, 3 interleaved rounds.
- VOID 13:07 E10 (first run): both arms ran THIS checkout. My 8a37f4a9 edit to sim.mjs's `--path` line never applied
  (a Python replace whose pattern did not match, unchecked), so `--project` was recorded but not passed. Caught because
  4513c5ff's new FightFrames texture counter read 529.0 MB in both arms while a direct probe (a scratch SceneTree script,
  GUI, both adapters) showed BC7 working: king_arena 8.4 -> 2.7 MB, boot texture memory 34.5 -> 17.0 MB, format 22 BPTC.
  Fixed (`'--path', projectDir(a)`), evidence renamed `evidence/sim/e10-VOID-both-arms-lossless/` (kept as the record:
  it is still a 6-vs-6 run-to-run noise sample of deck_bench: render GPU city 8.11 / 8.14, King 6.78 / 6.72).
  FRICTION ~12 min. Rule for me: after a scripted edit, grep for the new text before running anything on it.
- 13:15 E10 re-running (bench lock), the same 4 variants x 3 rounds.
- 13:05 frame cap setting (owed in the readiness table): PlayerSettings.frame_cap (0 = the device row's own; 30/40/60),
  saved in settings.json, applied to Engine.max_fps; the pause card's row shows only on a handheld tier. Tests written.
- RESULT 13:27 E10 (valid; bench lock 13:19-13:27, all 12 runs CONTENDED 1-3 other Godot; `evidence/sim/e10-bc7-igpu/`):
  lossless vs BC7 on deck_bench (iGPU, 8 threads, 48 px/m): **city** texture memory 529 -> 184 MB, video 843 -> 482 MB,
  private RAM 1386 -> 898 MB, GPU shared 1007 -> 489 MB, render GPU 8.33 (+-0.07) -> 7.37 (+-0.37) ms (-12 %), p50 9.40 ->
  8.03 (+-1.53); **King** texture 269 -> 123 MB, private 1004 -> 828, GPU shared 643 -> 469, render GPU 6.77 -> 6.66
  (noise), p50 wash. LEDGER E10, commit 1deaad71 (+ `tools/handheld/bc7_arm.mjs`, the arm as a tool, 2 node tests).
- ANSWER to perf's REQUEST (L4): on the iGPU Deck row BC7 is a memory win (~1 GB of a shared-memory device in the city)
  and a small GPU win in the city (-12 %, unlike the 4090), none in the King fight. Look at 48 px/m: the same to my eye at
  2x (mean |diff| 1.2/255). Numbers in my LEDGER E10; a REPORT Call 6 (lossless / BC7 everywhere / BC7 in a handheld
  build only) that pairs with your L4 Call.
- MILESTONE 13:28 NEXT 1 closed: under `handheld_1080` the drawn frame is 1422x800 (16:9 expand) and the ghost-form panel
  is whole (`gtai-masters/d9/handheld/handheld1080-city-48ppm-drawn-16x9-t720.png`, looked at). The it7 crop was Movie
  Maker recording 1280x800 of the 1422-wide canvas. The OS grab (`--grab`, grab_window.ps1) is NOT usable for a 1080
  window here: the secondary monitor is smaller than 1920x1080 (the grab has the taskbar and black in it); deleted.
- 13:29 frames.json: + E10 pair, + the 1080 drawn frame; dropped the three superseded 32 px/m clips (files deleted). 15 entries.
- MILESTONE 13:30 (7d6b64d6) the frame cap setting: unit 13/0 (test_player_settings + test_device_profile). DECISIONs
  bc7 and frame-cap in docs/decisions.md. REPORT: it10 items, Call 6.
- Registry rules applied this iteration: perf-regression-gating (interleaved rounds, the noise stated, a VOID run named and
  re-run rather than patched, the arm verified to differ before reading its numbers: the engine's own counter);
  generative-artifact-gating / motion-quality-gating (a lossy lever's look judged at the same tick and framing, 2x crop);
  adaptive-fidelity-tiers (BC7 as a build-tier lever, not a runtime branch); fire-tv-device-realities (the OS memory
  counter on a UMA adapter did not see texture size: measure inside the engine as well).
- MILESTONE 13:43 evidence gate on 71c4a111 (`--no-bench --no-release`): lint 15/15, unit 1713/0, scenarios 53/53, parity
  bit-exact over 1200 steps (planted mutation caught at 629), look goldens 11/11: **top bit-identical** with the it10 code
  (`evidence/it10/evidence-run-71c4a111.log`). Release-compile still skipped (seams' temp-dir clash).
- 13:37 mutation on player_settings.gd (`evidence/it10/mutate-player-settings.log`): 70 % (7/10). Survivors: line 74
  (mine: apply() -> apply_frame_cap deleted), 38 and 87 (pre-existing). 13:46 a test for 74 added (apply() carries the
  cap); planted by hand (the call -> pass): FAIL "[77] expected to equal [40]"; restored, 4/4 green.
- MILESTONE 13:49 reels on eae1ea23 (4 in parallel, `--quit-after 14000`): top / tilt70 / combo / combo + deck 19/19,
  0 SCRIPT ERROR (`evidence/it10/reels-summary.log`, the per-reel logs beside it).
- Session end 13:50: every change committed; no Godot of mine running; bench lock released (13:27).

NEXT (iteration 11):
1. The it10 gate is green on 71c4a111 and the reels on eae1ea23 (only a test added between): re-run the full gate
   on the next code change.
2. (done 13:49: the reels 19/19 x4 on eae1ea23.)
3. The frame cap in the pause card seen on screen: quest 1 under `--device=deck`, open the pause card (Start on the pad),
   cycle the cap, a still; then read Engine.max_fps in the log.
4. BC7 on the Switch-class row (E10 on `switch_handheld`, the reel and the city, 2 rounds) and on the Linux build in
   WSLg (memory there); the scratch arm stays at `gtai-d9x/scratch/hh-bc7` (detached worktree, BC7 imports, 8a37f4a9
   code + the 4513c5ff FightFrames copy): re-sync its code with `git -C <it> checkout --detach <sha>` then re-run
   `node tools/handheld/bc7_arm.mjs <it>/project` and `--import` if the code under test moves.
5. Mutation: line 74 now caught (it10); re-run mutate.mjs on player_settings.gd for the score with the new test;
   lines 38 and 87 are pre-existing (reduced_motion's fallback, rebind's or).
6. Carried: the draw_scale HUD side effect (if Call 5 b/c), NAT-06 parity on the Linux `.so` in WSL, the King fight's
   rumble count, end-of-day: the HKCU DirectX UserGpuPreferences value and the _hh.exe copy, the freeze exe.

## Iteration 11 (13:50-14:50, BUILD)
- Read: JOURNAL it10 + NEXT, git log -30, decisions tail, the rivet / seams / perf journals: no new REQUEST to handheld
  (perf read my E10 answer at 13:48). Plan: NEXT 5 (mutation score), NEXT 4 (BC7 on the Switch-class row), NEXT 3 (the
  frame cap in the pause card on screen), then the carried items.
- 13:53 NEXT 5: mutate.mjs on player_settings.gd at 9cffebaa, 12 mutants (`evidence/it11/mutate-player-settings.log`):
  **66.7 % (8/12)**; line 74 (mine, it10) now killed. Survivors: 41 (`0.0 -> 1.0`: equivalent, int 1 is not an offered
  cap), 38, 73, 87 (pre-existing). Tests added for 38 (a non-bool reduced_motion falls back off) and 73 (apply() rebinds
  what was saved); 87 left (it would need an unknown action, which logs an engine error).
- 13:53 E11 (bench lock 13:53-14:01): the BC7 arm re-synced to 9cffebaa (the scratch's FightFrames copy dropped: HEAD has
  it), `bc7_arm.mjs` 0 changes (712 already BC7), `--import` 0 errors, 712 bptc.
- FINDING 14:00 (NEXT 3 led here): **a pad could not press any card button.** Godot 4.7.2's default `ui_accept` and
  `ui_cancel` have no pad button (probed with a throwaway SceneTree script: ui_accept = Enter / keypad Enter / Space;
  the d-pad and left stick are on ui_up/down/left/right; Y on ui_select). The title / pause / paid cards are focused
  Buttons: on a Deck the focus moved and Start could not be pressed. Second fault: the pause card's settings rows rebuild
  on each press and free the focused button, so after A on "Toggle" the pad had nothing to move.
- MILESTONE 14:05 (8959a913) `menu_pad` in input_actions.json (A -> ui_accept, B -> ui_cancel), installed at boot on every
  run (DECISION handheld/menu-pad). (47668922) the panel restores the focused slot after a rebuild; a pad button cancels a
  rebind wait; the panel saves to the game's settings path (a test never writes user://settings.json).
  `test_settings_panel_pad` 3/3; planted (the restore -> pass): both walk tests FAIL with focus (-1, -1); restored green.
  Lint 15/15 (the debt ratchet caught +1 line in quest1_game.gd: the save path went into the constructor instead).
- RESULT 14:01 E11 BC7 on `switch_handheld` (`evidence/sim/e11-bc7-switch/`, 7 of 8 CONTENDED): city private + GPU
  shared 2.26 -> 1.38 GB, render GPU -11 %; reel 1.52 -> 1.13 GB; the 30 cap holds in all. E10's ~1.3 GB inference
  measured at 1.38. LEDGER E11, the Switch-class readiness row updated.
- MILESTONE 14:17 NEXT 3 done, live: a scratch pad walk (`gtai-d9x/scratch/padwalk/zz_pad_walk*.gd`, not committed:
  a bare SceneTree loader that loads a Node walker at runtime, because a `-s` script cannot compile against the
  autoloads) under `--device=deck`, pad events through `Input.parse_input_event` only: title focus Start -> A starts
  quest 1 -> Start pauses (focus Resume) -> d-pad -> the cap's Toggle -> A: cap 30, Engine.max_fps 30, focus kept ->
  A: 40 / 40 (`evidence/it11/padwalk-deck.log`). Looking at the first pause still: the card was keyboard-first (WASD
  line, seven keyboard rebind rows) and the focus mark a faint outline at 7 inches.
- MILESTONE 14:21 (955f56cb) the cards pad first on a handheld tier: the controls line from the bound pad buttons
  (`ObjectiveHint.with_keys(..., pad)`), a 4 px ink focus border, the keyboard rebind rows hidden; LaunchArgs installs
  the game's actions at boot under a handheld row (the title card showed `[fire]`/`[melee]` raw: the actions were only
  installed at session start). Desktop unchanged (test: the shipped CONTROLS line, no focus override, 10 rows).
  Stills looked at: `gtai-masters/d9/handheld/padwalk-deck-title-1280x800.png`, `padwalk-deck-pause-cap40-1280x800.png`.
  frames.json: + the two pad stills; - the superseded 32 px/m city clip and still-king-33 (Call 2 now points at the
  48 px/m King still); files deleted; 15 entries.
- FRICTION 14:12-14:18 (~6 min): the gate on 80a4fce9 FAILED lint (debt ratchet) and unit ("tree changed") on my own
  scratch file `project/dev/zz_pad_walk.gd`, created while the gate ran (unit itself 1717/0; scenarios 53/53, parity,
  goldens 11/11 green). Rule for me: no files under `project/` while a gate runs; scratch Godot scripts go in, run,
  and come out between gates.
- Registry rules applied this iteration: on-device-verification-harness (drive the real input path, pad events through
  the Input singleton on the real scene, a still per step, the log as the proof); fire-tv-device-realities (an engine
  default is not a device default: probe it, here `ui_accept` with no pad button); perf-regression-gating (E11
  interleaved, the arm verified to differ by its memory before its frame numbers were read, CONTENDED stated);
  adaptive-fidelity-tiers (the pad-first card behind the handheld tier, the desktop card one condition away);
  motion-quality-gating / generative-artifact-gating (each still looked at before it went into frames.json).
- MILESTONE 14:29 evidence gate on 955f56cb (`--no-bench --no-release`): lint 15/15, unit 1718/0, scenarios 53/53, parity
  bit-exact over 1200 steps (planted mutation caught at 629), look goldens 11/11: **top bit-identical** with the it11
  code (`evidence/it11/evidence-run-955f56cb.log`).
- 14:30 reels on 955f56cb started (headless, `--fixed-fps 60 --quit-after 14000 res://dev/arena/arena.tscn -- --bot=reel
  --reel=director --loadout=pistol --rigs --view=<v>`, + `--device=deck` on combo; perf's command), and mutate.mjs on
  quest1_settings_panel.gd (10 mutants, test_settings_panel_pad).
- MILESTONE 14:32 reels on 955f56cb (headless, perf's command): top / tilt70 / combo / combo + deck **19/19, 0 SCRIPT
  ERROR** (`evidence/it11/reels-summary.log`, 33207d49).
- 14:33 mutate.mjs on quest1_settings_panel.gd at 384adc66 (10 mutants, test_settings_panel_pad;
  `evidence/it11/mutate-settings-panel.log`): **50 % (5/10)**. Survivors: 25 (the row spacing 6 -> 7: cosmetic), 74
  (`queue_free` -> pass: the rows are removed anyway, a leak no test sees), 122 / 123 (`_volume`: pre-existing, tested
  elsewhere, outside this run's test list), 134 (`cap <= 0` -> `<= 1`: equivalent, the caps are 0/30/40/60). Every it11
  line (focused_slot, the restore, the pad cancel, the save path) killed.
- MILESTONE 14:33 (035643c7) B on a pad resumes from the pause card (Quest1Card, pad events only: the keyboard's Esc is
  both ui_cancel and the game's pause toggle and would toggle twice); test, planted (no emit) -> FAIL.
- MILESTONE 14:38 evidence gate on 035643c7: lint 15/15, unit 1719/0, scenarios 53/53, parity bit-exact (planted caught at
  629), look goldens 11/11: **top bit-identical** (`evidence/it11/evidence-run-035643c7.log`). The reels ran on 955f56cb;
  035643c7 adds only Quest1Card's B handler (the reel never opens the card).
- Session end 14:39: every change committed; no Godot of mine running; bench lock released (14:01); scratch dev files
  out of project/.

NEXT (iteration 12):
1. If the 035643c7 gate above is not green, fix that first (`evidence/it11/evidence-run-035643c7.log`).
2. Glyph images for the pad prompts (owed since it4): the `[A]` / `[RT]` text labels are legible but Valve's
   "glyphs match the controller" prefers images; a small drawn set through the asset lane (a REQUEST: ink on paper, the
   Deck / Xbox-style and PlayStation families) behind the handheld rows, or record it as owed with the text labels.
3. The paid and failed cards on a pad (A on Quit / Retry: covered by menu_pad, not yet walked live); the scratch walker
   is at `gtai-d9x/scratch/padwalk/` (copy into project/dev only between gates, never while a gate runs).
4. Carried: NAT-06 parity on the Linux `.so` in WSL; the King fight's rumble count (`--log=` in sim.mjs); the draw_scale
   HUD side effect (if Call 5 b/c); a rumble settings toggle (the pause card has room now on handheld rows).
5. End of day (by 18:30): delete the HKCU DirectX UserGpuPreferences value for
   gtai-d9x/handheld-godot/..._hh.exe and that copy; the BC7 scratch worktree `gtai-d9x/scratch/hh-bc7` (git worktree
   remove); the freeze exe `build/export/windows/RTAI.exe` with the exact command in REPORT.

## Iteration 12 (14:40-15:40, BUILD)
- Read: JOURNAL it11 + NEXT, git log, decisions tail, the rivet / seams / perf journals: no new REQUEST to handheld.
  The 035643c7 gate was green (26654624). Plan: NEXT 4 a rumble setting in the pause card (handheld rows), NEXT 3 the
  paid / failed cards walked live on a pad, NEXT 2 the glyph REQUEST to assets, then the gate + reels.
- MILESTONE 14:52 (690ea895) NEXT 4: a rumble setting in the pause card on a handheld tier: "Rumble: full / half / off"
  (PlayerSettings.rumble 1 / 0.5 / 0, saved; apply() sets `HandheldRumble.player_gain`, which multiplies the device
  row's gain). Desktop card unchanged (the desktop row has no rumble node, the row is handheld-only). Tests: A on its
  Toggle cycles full -> half -> off -> full with the focus kept, half plays a half pulse, off plays none; round trip;
  a bad level (0.7) falls back to full. 19/19, lint 15/15.
- 14:55 mutate.mjs on player_settings.gd at 690ea895 started (36 mutants; `evidence/it12/mutate-player-settings.log`).
  An early survivor was real: line 48 (`else 1.0 -> 0.0`): **every settings file saved before today has no `rumble`
  key**, and that mutant loads it as rumble off. (4bf3ad95) a test for an old file (frame_cap only -> rumble full);
  planted by hand -> FAIL at :79; restored.
- MILESTONE 15:05 NEXT 3 done, live: the failed and paid cards walked on pad events only under `--device=deck`
  (scratch `gtai-d9x/scratch/padwalk2/`, copied into project/dev for the run and removed; no gate was running;
  `evidence/it12/padwalk-deck-cards.log`). The real failure (the quest runner's fail, no checkpoint: Quit only): focus
  Quit, A pressed it. With a checkpoint (`show_failed(true)`): focus Retry, d-pad down Quit, up Retry, A on Retry
  restarted the contract (active, card hidden). The real success: the paid card holds until the closing lines play out
  (780 frames, by design: `lines.busy()`), then focus Quit, A pressed it. FRICTION ~3 min: the first run read the paid
  card 240 frames after the success and saw no card: not a fault, the lines were still playing.
  Stills looked at; `gtai-masters/d9/handheld/padwalk-deck-failed-paid-1280x800.png` (both cards side by side) replaces
  the E8b x2 crop in frames.json (cited nowhere; file deleted); 15 entries.
- DECISION handheld/glyph-images: the pad prompts stay ink text labels (`[A]`, `[RT]`, `[Cross]`) on the handheld rows.
  For a Steam build the glyphs that match whatever pad is in hand come from Steam Input
  (`ISteamInput::GetGlyphPNGForActionOrigin` / `GetGlyphSVGForActionOrigin`, through the Steam backend only, STEAM
  rule): owed with the Steam port. A drawn ink set (below) would replace the bracket text in the game's own style.
  Rejected: our own glyph PNGs drawn now without the Steam origin lookup (they would still be wrong for a pad Steam
  Input remaps).
- REQUEST to assets: `ui_pad_glyphs_v1`, no pitch (flat screen UI, the HUD's ink-on-paper style, ink outline + print
  grain, no teal/blue/red/vermilion). One sheet, each glyph on its own cell, transparent background, ~96 px source
  per cell (shown at 28-40 px on a 7" 1280x800 panel, so a heavy ink line and a large letter/shape): face buttons as
  round keys with the letters A, B, X, Y; the same four round keys with the shapes cross, circle, square, triangle
  instead of letters; shoulder keys LB, RB and the triggers LT, RT (and the plain shapes for a pad that has L1/R1/L2/R2
  and L/R/ZL/ZR: draw the letter text as separate cells: L1 R1 L2 R2 L R ZL ZR); left stick, right stick, a stick
  press (L3, R3); the d-pad (whole, and each arm lit); Start and Select as small pill keys. No maker marks, no logos,
  no brand-specific colours. Why: on the Deck profile the prompts are `[A]`-style text; the handheld tier's
  prompts would read in the game's own drawn style instead. Low priority: after every rivet / seams REQUEST.
- Time correction: the it12 stamps above were estimates and run ahead of the clock; the real times are rumble
  commit ~14:47, the card walk ~14:57, the mutate run 14:45-14:56, 9bbbd091 at 15:00.
- MILESTONE 15:01 mutate.mjs on player_settings.gd at 690ea895 (36 mutants): **66.7 % (24/36)**
  (`evidence/it12/mutate-player-settings.log`). The only survivor on an it12 line (48: an old file's missing `rumble`
  -> off) was killed since by 4bf3ad95 (planted by hand). Pre-existing survivors: 22 / 45 (defaults overwritten by the
  load path), 33 (`or -> and` on the parse guard), 71 / 72 (the save's return/close), **79 (the master-bus volume line
  deleted: no test saw the volume reach the AudioServer)**, 88 / 90 (apply_frame_cap's `> 0` / `>= 0`: equivalent on the
  offered caps and the rows' -1), 96 (rebind's guard).
- FRICTION 15:00 (~1 min): the first gate on 883167c8 refused to start (exit 2, dirty tree: the uncommitted mutate log
  and the gate's own log written inside the worktree). Gate and reel logs now go to `gtai-d9x/scratch/it12/` and are
  copied in after.
- MILESTONE 15:03 reels on 9bbbd091 (headless, perf's command, run during the gate, logs outside the tree): top /
  tilt70 / combo / combo + deck **19/19, 0 SCRIPT ERROR** (`evidence/it12/reels-summary.log`).
- MILESTONE 15:09 evidence gate on 9bbbd091 (`--no-bench --no-release`, log written outside the tree): lint 15/15, unit
  1721/0, scenarios 53/53, parity bit-exact over 1200 steps (planted mutation caught at 629), look goldens 11/11:
  **top bit-identical** with the it12 code (`evidence/it12/evidence-run-9bbbd091.log`).
- MILESTONE 15:11 (ec9dace0) a test that apply() sets the master bus volume (0 -> the -80 dB floor): kills survivor 79;
  planted by hand (the line deleted) -> FAIL at :106 (0 dB, expected -6.02); restored. Test-only, after the gate.
- RESULT 15:14 rumble live under `deck` (headless, 2400 ticks, the boss bot, combo): the King fight **3 pulses**,
  Servo **2** (`evidence/it12/{king,servo}-rumble-deck.log`; the reel had 4 at it7). Sparse but not silent; the exit log
  has no per-kind split, so which were hurts is unmeasured. Seen in both logs: a shader-compiler `ERROR`
  (`custom_samplers ... tex_builtin`) from `kill_char_fx.gd:189` at arena start: combat code, not handheld's; not a
  SCRIPT ERROR (the reel gate counts those). LEDGER readiness row updated.
- Registry rules applied this iteration: on-device-verification-harness (the end cards walked on the real scene, pad
  events through the Input singleton, the quest runner's own fail / success, a still per card, the log as the proof);
  fire-tv-device-realities (the paid card's wait on the closing lines looked like a dead card for 240 frames: read the
  game's own gate before calling a fault); perf-regression-gating (the gate before and after; logs out of the tree so
  the gate's clean-tree check holds); adaptive-fidelity-tiers (the rumble row behind the handheld tier, the desktop card
  one condition away); generative-artifact-gating / motion-quality-gating (every still looked at before frames.json).
- Session end 15:16: every change committed; no Godot of mine running; no bench lock taken this iteration (no number
  kept that needs it); scratch dev files out of project/; scratch at `gtai-d9x/scratch/it12/` and `padwalk2/`.

NEXT (iteration 13):
1. A per-kind pulse count in HandheldRumble's exit log (`rumble: 3 pulses (boss_engaged 1, rivet_hurt 2)`), then the
   King / Servo counts again: is a boss fight's rumble felt enough? (A tiny core change: lint, --changed, the gate.)
2. The glyph REQUEST (`ui_pad_glyphs_v1`): read the asset lane's journal; if served, the glyph cells behind the
   handheld rows (`PadGlyphs` -> a TextureRect in the prompt line), the text labels as the fallback.
3. Mutation survivors left on player_settings.gd (pre-existing): 33 (the parse guard's `or -> and`), 71 / 72 (save's
   store result / close), 96 (rebind's guard); 22 / 45 / 88 / 90 are equivalent or default-overwritten.
4. Carried: NAT-06 parity on the Linux `.so` in WSL; the draw_scale HUD side effect (if Call 5 b/c); rumble on blasts
   and crashes (needs a bus event: a REQUEST to whoever owns combat, not handheld's file).
5. End of day (by 18:30): delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and
   that copy; the BC7 scratch worktree `gtai-d9x/scratch/hh-bc7` (git worktree remove); the scratch dirs
   `gtai-d9x/scratch/{padwalk,padwalk2,it12}`; the freeze exe `build/export/windows/RTAI.exe` with the exact command
   in REPORT.
- MILESTONE 15:20 (36f992dd) NEXT 1 done: the rumble exit log counts pulses per kind. Re-run under `deck` (headless,
  2400 ticks, the boss bot): **King 3 = boss_engaged 1 + rivet_hurt 2; Servo 2 = boss_engaged 1 + rivet_hurt 1**
  (`evidence/it12/{king,servo}-rumble-deck-kinds.log`). FINDING: in a boss fight the pad only answers Rivet being hurt;
  **his own blows landing on a boss never pulse** (no bus event for a hit on a boss; `pedestrian_struck` /
  `actor_knocked_down` are street events). Owed: a "hit landed" pulse (light, 60-80 ms) from a view-side read of the
  boss's hurt tick, as `feel_hurt` does for Rivet (the view reads, never writes the sim), behind the handheld rows.
- MILESTONE 15:24 evidence gate on 36f992dd: lint 15/15, unit 1722/0, scenarios 53/53, parity bit-exact (planted caught
  at 629), look goldens 11/11 (worst 0.27): **top bit-identical** (`evidence/it12/evidence-run-36f992dd.log`).
  15:26 the deck reel on 36f992dd (the only reel with a rumble node; top / tilt70 / combo have none, unchanged since
  9bbbd091): **19/19, 0 SCRIPT ERROR**, rumble `{ rivet_hurt: 3 }` (`evidence/it12/reel-deck-36f992dd.log`).
- Session end 15:27: every change committed; no Godot of mine running; no bench lock taken this iteration; scratch dev
  files out of project/.

NEXT (iteration 13; supersedes the list above, whose item 1 is done):
1. A light "hit landed" pulse when Rivet's blow lands on a boss (a view-side read of the boss fighter's hurt tick, the
   same pattern as `feel_hurt`: the view reads, never writes the sim), handheld rows only; then King / Servo counts
   again (it12: only Rivet's hurts pulse, King 2 in 40 s).
2. The glyph REQUEST (`ui_pad_glyphs_v1`): read the asset lane's journal; if served, glyph cells behind the handheld
   rows (the text labels as the fallback).
3. Mutation survivors left on player_settings.gd (pre-existing): 33, 71 / 72, 96 (79 killed by ec9dace0).
4. Carried: NAT-06 parity on the Linux `.so` in WSL; the draw_scale HUD side effect (if Call 5 b/c); rumble on blasts
   and crashes (needs a bus event from combat: a REQUEST, not handheld's file).
5. End of day (by 18:30): delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and
   that copy; the BC7 scratch worktree `gtai-d9x/scratch/hh-bc7` (git worktree remove); the scratch dirs
   `gtai-d9x/scratch/{padwalk,padwalk2,it12}`; the freeze exe `build/export/windows/RTAI.exe` with the exact command
   in REPORT.
## iteration 13 (15:27, session ends 16:27)
- Read: JOURNAL it12 + NEXT, git log -15, the rivet / seams / perf journals (perf's it12 FYI to handheld: the L9
  instrumented template `gtai-d9x/scratch/godot-src/tw-lto.exe` for upload-buffer memory; no other REQUEST to
  handheld), the asset library journal / queue / catalog: `ui_pad_glyphs_v1` not served yet (NEXT 2 waits).
- MILESTONE 15:34 (7509cf49) NEXT 1: a light `boss_hit` pulse (weak 0.15, strong 0.35, 70 ms: lighter and shorter than
  `rivet_hurt` 0.55 / 120 ms, so a landed hit never cuts a hurt). BossBar._process reads `fight.body.hurt_tick`
  (BossFight.hurt sets it only when a hit takes hp: none in a transition) through `HandheldRumble.feel_landed`, a
  no-op without a rumble row; HandheldRumble keeps one memo per kind (`see(kind, tick)`). Tests +3; planted by hand
  (the bar's line removed) -> FAIL at :108; lint 15/15; the suite 1709/0.
- RESULT 15:37 live under `deck` (headless, 2400 ticks, the boss bot, combo): **King 59 pulses = boss_hit 56 +
  rivet_hurt 2 + boss_engaged 1; Servo 63 = 61 + 1 + 1** (`evidence/it13/*-rumble-deck-hit.log`). The hurt counts are
  it12's exactly (2, 1): the new pulse cut none, and the fight itself did not move. ~1.4 landed hits a second: the
  motor is on ~10 % of the fight. Owed, unmeasured: a fast gun on a boss could chain 70 ms pulses into a buzz (no
  refractory gap yet; one data value if a pad says so).
- ANSWER to perf (their it12 FYI, L9 upload buffers): read. On the deck rows the GPU memory is the APU's shared RAM
  (Deck 16 GB total, the Switch-class budget ~3-4 GB for the game), so ~208 MB of transfer-worker staging held for the
  session is pure overhead there; it adds to E10's finding (BC7 cut ~1 GB of shared memory in the city). Not measured
  on a handheld row this iteration (no export of this branch with the instrumented template; the boss-hit pulse and
  its gate came first). The sheet split is the vehicles owner's change; handheld supports it (a row in LEDGER
  readiness: memory headroom). Owed: one `GTAI_TW_LOG=1` run of the city under `--device=deck` on the iGPU.
- MILESTONE 15:49 evidence gate on cab191e0 (`--no-bench --no-release`; the boss_hit code + the it13 tests): lint
  15/15, unit 1728/0, scenarios 53/53, parity bit-exact over 1200 steps (planted caught at 629), look goldens 11/11
  (worst 0.27): **top bit-identical** (`evidence/it13/evidence-run-cab191e0.log`). The reels on c9b8e1ff (the code is
  7509cf49's; later commits are tests and the journal): **top / tilt70 / combo / combo + deck 19/19, 0 SCRIPT ERROR**;
  deck rumble `{ rivet_hurt: 3 }` (the arena reel has no boss bar, so no boss_hit; `evidence/it13/reel-*`).
- FRICTION 15:40 a first gate (started 15:38) shared the tree while I edited a test and ran `--select` into the same
  `build/test-results/`: killed it (my PID only) and re-ran on a clean commit. Rule kept: no edits under project/ and
  no unit runs while a gate is up; docs drafts go to scratch and land after.
- RESULT 15:57 E12 (supersedes "not measured" in the answer to perf above): perf's L9 instrumented template (their
  `windows-bench-tw` export copied to `gtai-d9x/scratch/it13/tw/`) on the **2-CU Radeon iGPU**, 1280x800, 60 cap, the
  riot 30 s, `GTAI_TW_TRIM_MB=0` (stock) vs 32, 1 run each, memory only: stock holds 128 + 32 + 32 + 32 = 224 MB of
  staging; trim: working set 1304 -> 1128 MB, private 1328 -> 1163, **GPU shared 1006 -> 878 MB (-128)**, dedicated 82
  both. On a shared-memory GPU the outlier buffer is the iGPU's memory: perf's sheet split is worth ~128 MB on a Deck.
  (`evidence/it13/tw-igpu/`; LEDGER E12.) FRICTION 2 min: the release template refuses a scene path
  (`disable_path_overrides`): the bench export boots city_bench by itself, user args only.
- REQUEST to perf (FYI, answer to theirs): E12 above: on the iGPU at 1280x800 the trim takes 128 MB off the GPU's shared
  memory and 176 MB off the working set in the riot; the p70 traffic sheet split carries the handheld case too.
- MILESTONE 16:00 (f0c20255, af40d92d) mutation: player_settings.gd on 20abab6c **86.1 %** (31/36; it12 66.7 %), the :90
  pair killed since by a 0-cap row test (planted: FAIL at :160); left :45 / :72 / :88, equivalent. handheld_rumble.gd on
  cab191e0 **71.1 %** (32/45, 5 invalid); seven killed since by four tests (:62 the live node cleared on exit, :105 the
  player level times the row gain, :108 an equal pulse restarts, :129-141 each bus event plays its kind), each planted
  by hand -> FAIL; left: initial values (:26 :32 :33), the ms rounding (:110), the pad call with no pad (:116).
  Full unit run on af40d92d: **1733/0**. The re-score on af40d92d is running (`gtai-d9x/scratch/it13/mutate-rumble2.log`).
- Registry rules applied this iteration: on-device-verification-harness (the pulse counted on the real boss scenes,
  by kind, through the exit log; the instrumented template run on the iGPU itself, not inferred from the RTX);
  controller-latency-instrumentation (a pulse is a one-frame view read of a sim tick: the boss bar reads hurt_tick the
  frame it changes, no queue); adaptive-fidelity-tiers (the pulse sits behind the rumble row, a no-op on desktop);
  perf-regression-gating (the gate on a clean commit, killed and re-run when I dirtied it; top bit-identical;
  mutation scores quoted, planted faults by hand); fire-tv-device-realities (shared memory is the device's memory: a
  staging buffer that is free on a 24 GB card is 128 MB of a Deck's 16 GB).
- Session end 16:10: every change committed; my mutate.mjs re-score may still run in its own temp worktree (not my
  checkout); no bench lock taken (E12 is memory only, labelled n=1); scratch at `gtai-d9x/scratch/it13/` (tw copy 75 MB).

NEXT (iteration 14):
1. Read `gtai-d9x/scratch/it13/mutate-rumble2.log` (the re-score on af40d92d) and quote it in LEDGER / REPORT.
2. The glyph REQUEST (`ui_pad_glyphs_v1`): read the asset lane's journal; if served, glyph cells behind the handheld
   rows (the text labels as the fallback).
3. A refractory gap for `boss_hit` if needed: log the shortest gap between two landed-hit pulses in ticks (the boss
   bot with a fast gun, `--loadout=`), then decide (one data value).
4. Carried: NAT-06 parity on the Linux `.so` in WSL; rumble on blasts and crashes (a bus event from combat: REQUEST);
   E12 with `--device=deck` once a windows-bench export of this branch exists (bake the chunks first).
5. End of day (by 18:30): delete the HKCU DirectX UserGpuPreferences value for gtai-d9x/handheld-godot/..._hh.exe and
   that copy; the BC7 scratch worktree `gtai-d9x/scratch/hh-bc7` (git worktree remove); the scratch dirs
   `gtai-d9x/scratch/{padwalk,padwalk2,it12,it13}`; the freeze exe `build/export/windows/RTAI.exe` with the exact
   command in REPORT.
- MILESTONE 16:17 NEXT 1 of it14 done early: handheld_rumble.gd re-scored on af40d92d **86.7 %** (39/45; was 71.1 %);
  the 6 left are equivalent: initial values (:26 :32 :33), the `now < _until_ms` boundary and the ms rounding (:108,
  :110: a millisecond), the pad call with no pad on this PC (:116) (`evidence/it13/mutate-rumble-af40d92d.log`).
  it14 starts at NEXT 2. Session end 16:18: everything committed, no Godot or mutate run of mine left.
## iteration 14 (16:19, session ends 17:19 at the latest)
- Read: JOURNAL it13 + NEXT, git log -30, the rivet / seams / perf journals (perf's it15 L10 FYI: `FrameCap.cap_for`
  caps the limiter at the 60 Hz tick on a >61 Hz vsync panel; no new REQUEST to handheld), the asset library journal /
  catalog: `ui_pad_glyphs_v1` still not served (its round 1650 is weapon showcases): NEXT 2 waits again.
- ANSWER to perf (L10 FYI): read. The handheld rows already set `max_fps` explicitly (deck 60, deck40 40, switch 30)
  with vsync on, so on a 90 Hz Windows-handheld panel the deck row renders 60 already; L10 matters for the desktop row
  (no cap) and agrees with ours. When L10 merges, the device row's `max_fps` must win over `cap_for` (set after it, or
  `cap_for`'s `current` argument holds the row's value): a seam for the Director, no edit of either file needed today.
- MILESTONE 16:26 (7ae230b4, 24715868) NEXT 3: measured, then built. The exit log now names the shortest gap between
  two fresh hurts per kind (sim ticks). Live under `deck` (headless, 2400 ticks, boss bot, combo): stock gun King 16 /
  Servo 21 ticks; `--weapon=gatling` / `machine_pistol` **2 ticks** on both bosses, so 70 ms pulses chained into one
  buzz (King gatling 225 pulses in 40 s, Servo 361). Built `REST_TICKS {boss_hit: 8}` (133 ms: at most 7.5 taps/s, 63 ms
  quiet between taps; 0 = before): King gatling 80 played + 145 rested (the same 225 hits: the fight did not move),
  machine pistol 105 + 112, Servo gatling 126 + 236; stock 59 / 63, **0 rested** (it13's counts exactly). Tests +2
  (planted: no rest -> FAIL at :164); lint 15/15. DECISION handheld/boss-hit-rest (docs/decisions.md).
  Evidence: `evidence/it14/*-gap.log` (+ `before/`), `evidence/it14/gaps.sh`.
- FRICTION 16:28 the gate refused the tree (JOURNAL.md uncommitted): committed, re-run.
- MILESTONE 16:36 evidence gate on 890c3f07 (the rest code): lint 15/15, unit 1735/0, scenarios 53/53, parity
  bit-exact (planted caught at 629), look goldens 11/11 (worst 0.27): **top bit-identical**
  (`evidence/it14/evidence-run-890c3f07.log`). Reels on 890c3f07: **top / tilt70 / combo / combo + deck 19/19, 0 SCRIPT
  ERROR**.
- RESULT 16:34 (a8f9019d) **E13, the sim is the same on Linux** (the NAT-06 item carried since it1): the official
  Godot 4.7.2 Linux editor (GitHub release zip, sha512 matched SHA512-SUMS, build ed1daf0bf as on Windows) in WSL
  Ubuntu 24.04, the project copied to the distro's disk with its import cache. Parity on the sniper-built debug `.so`:
  exact over 1200 steps, 3516 floats, planted caught at 629 (Windows: 629). Quest 1 replay recorded on Windows (1800
  ticks, seed 7) -> Linux **identical**; recorded on Linux (3600 ticks, seed 11) -> Windows **identical**. Why it holds:
  `native/SConstruct` builds with `-ffp-contract=off` / `/fp:strict`. Limits: idle input, the debug `.so`, Ubuntu.
- FRICTION 16:38-16:59 (~20 min) E13b (the release `.so`): two bugs of mine and one finding. (1) `wsl.exe -- bash -lc
  '...$r...'` is expanded once by the login shell, so `$r` was empty: put WSL loops in a script file (and
  `MSYS_NO_PATHCONV=1`, or Git Bash rewrites `/mnt/c` to `C:/Program Files/Git/mnt/c`). (2) FINDING: `linux-showcase`
  boots the dev arena (`run/main_scene.showcase`), which never reads `--replay`; both runs played the arena until my
  300 s timeout (exit 124), killed by me (my PIDs only). E13b needs a `linux-slice` export (owed).
- RESEARCH 16:45 Steam Cloud cross-save (LEDGER section 1): one Auto-Cloud root (WinAppDataRoaming) + a Root Override to
  LinuxXdgDataHome for the native build (`user://` = `~/.local/share/RTAI Uprising`); a Steam Flatpak breaks the XDG map;
  Proton keeps the Windows root. Sources: partner.steamgames.com/doc/features/cloud, ctrl.blog flatpak-steamcloud-xdg.
- Registry rules applied this iteration: on-device-verification-harness (the pulse gap measured on the real boss
  scenes before choosing a value; the Linux claim made on a Linux engine, not inferred from the SConstruct flags);
  controller-latency-instrumentation (the rest counts in sim ticks, the game's time, not wall-clock, so 40 Hz rows rest
  the same); adaptive-fidelity-tiers (the rest sits behind the rumble row: desktop never vibrates); perf-regression-gating
  (the gate on a committed tree, re-run when JOURNAL dirtied it; planted fault by hand; reels in four views);
  fire-tv-device-realities (a device ships a different binary: the release `.so` and the export's main scene are the
  device's reality, and the showcase preset is not the game a Deck would run).

- RESULT 17:04 (dab6158a) E13b done early (NEXT 1 below was started this session): a `linux-slice` preset (quest 1 as
  main), exported in 14 s; both editor-recorded logs **diverge at tick 60** through it on Linux, and through
  `windows-slice` on Windows alike: an editor-vs-export difference, not an OS one (E13's editor runs cross the OSes
  identical). The Windows release exe with `--record` + `--quit-after 1800` exits 0 but writes no file, so release vs
  release across the OSes is not measured. FINDING for the Director (SIM-05 is not handheld's code): a replay made in
  the editor does not hold in a shipped build. Cause unmeasured (candidates: `dev/*` excluded from the slice, a
  debug-only path).

NEXT (iteration 15):
1. E13b follow-up: why the release export diverges at tick 60 (bisect: a `windows-slice` copy without the `dev/*`
   exclusion; and why `--record` writes nothing in release: does the World's exit save run on `--quit-after`?). If
   the cause is outside handheld's files, a REQUEST to the Director with the evidence; then release-vs-release on
   Linux, and a save round trip Windows <-> Linux.
2. mutate.mjs on handheld_rumble.gd at HEAD (the rest lines) and quote the score.
3. The glyph REQUEST (`ui_pad_glyphs_v1`): re-read the asset journal.
4. FREEZE prep (by 18:30): the exe `build/export/windows/RTAI.exe` (`"$GODOT_BIN" --headless --path project
   --export-release windows-showcase ../build/export/windows/RTAI.exe`) named in REPORT; delete the HKCU DirectX
   UserGpuPreferences value for `gtai-d9x/handheld-godot/..._hh.exe` and that copy; `git worktree remove` the BC7
   scratch `gtai-d9x/scratch/hh-bc7`; the scratch dirs `gtai-d9x/scratch/{padwalk,padwalk2,it12,it13,it14}`;
   WSL `~/hh14` (1 GB: the project copy, the editor, the export); `build/export/linux/` (292 MB).
