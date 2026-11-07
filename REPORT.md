# REPORT: lane handheld (d9, 2026-11-07), in progress

Every number is **on the simulator** (this PC under a device profile: 8 pinned threads, below-normal
priority, the CPU's own 2-CU Radeon), never a device claim. Details and sources: `docs/handheld/LEDGER.md`.

## What works (with evidence)
- `--device=deck|deck40|handheld_1080|switch-handheld` (devices.json, one row per device; no flag = desktop, untouched).
- The simulator: `node tools/handheld/sim.mjs --device=deck --scene=reel|city|king|servo` (affinity, iGPU, frame log,
  CPU/RAM/GPU memory), `ab.mjs` (interleaved A/B), `--suspend=12:20` (a Deck-style freeze).
- The director reel on `deck` + iGPU: vsync-locked 16.6 ms; uncapped ~7.4 ms (render GPU 6.7 ms on 2 CUs, a Deck
  has 8); ~0.95 GB private RAM, ~0.6 GB GPU memory (`evidence/sim/`).
- A 20 s freeze mid-fight resumes cleanly: the sim advances 1 tick over it, exit 0 (`evidence/sim/e2-suspend-deck-reel.json`).
- Every action on the pad: radio and reload moved to R3 (radio sat on the Guide button, which a handheld keeps).
- **The native Linux build**: the CitySim `.so` built in Valve's Steam Runtime "sniper" SDK container
  (`sh tools/handheld/build_linux_so.sh`), the `linux-showcase` export
  (`"$GODOT_BIN" --headless --path project --export-release linux-showcase ../build/export/linux/RTAI.x86_64`),
  running the city under the Deck profile in WSLg on the AMD iGPU (`tools/handheld/wsl_run.sh`; `evidence/sim/e4-linux-wslg/`).
- Pause on focus-out (the Steam overlay) under a handheld profile.
- Clips at 1280x800 on the iGPU: `gtai-masters/d9/handheld/deck-king-1280x800-igpu.mp4`, `deck-city-1280x800-igpu.mp4`.

## Calls for the owner
1. **Handheld zoom** (stills: `gtai-masters/d9/handheld/zoom-city-deck-32ppm.png`, `-40ppm`, `-48ppm`, all 1280x800
   = the Deck's panel 1:1). At the shipped 32 px/m Rivet is ~25 px tall, about 3 mm on a 7-inch screen.
   a) 48 px/m (`zoom_k` 1.5): **the default built** for every handheld row; b) 40 px/m (`zoom_k` 1.25): more street in
   view; c) 32 (as desktop). One data value in `project/data/tables/devices.json`. Desktop does not change.
   Try it: `RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --view=tilt70 --device=deck`.
2. **The ghost-form panel on a handheld** (`still-king-33.png`): it covers about a third of the width and a quarter
   of the height of a 1280x800 panel, bottom-left. a) keep; b) a compact handheld panel (owed to the hud work);
   default built: a (nothing changed).

## Owed / next
- The Linux build: NAT-06 parity on the Linux `.so` (in WSL), a real Vulkan run (needs a Linux PC or a Deck).
- Rumble, glyph images per pad type, aim assist (a design call), a pad-only
  walk through menus and the dialogue.
- A/Bs: `deck40` vs `deck` (CPU/GPU busy as the power proxy), `handheld_1080` viewport vs native stretch,
  the Switch-class budget at 3 threads.
