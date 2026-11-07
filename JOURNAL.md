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
