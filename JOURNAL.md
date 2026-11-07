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
