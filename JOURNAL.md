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
