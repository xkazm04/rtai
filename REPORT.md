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
- Pad rumble under the handheld rows (`HandheldRumble` on the Events bus: Rivet hit, a car strike, a tackle, a boss
  stepping in, a hijack, the whispers; desktop none) and prompts that name a PlayStation / Nintendo-layout pad's own
  buttons (`PadGlyphs`, handheld rows). Unit-tested; **never felt**: no pad on this PC.
- The 40 Hz battery row (`deck40`) measured against `deck` on the city block: GPU busy 38 % vs 55 % of each second,
  pinned CPU -26 % (E5, CONTENDED); the 1.5x handheld zoom costs nothing (E6).
- The desktop game unmoved with all of it in: evidence gate on 9b35dd21 lint 15/15, unit 1708/0, scenarios 52/52,
  parity bit-exact, look goldens 11/11 (`evidence/it4/`).
- The Switch-class budget (3 threads, 30 cap): the cap holds in the reel and the city; ~2.3 GB RAM + GPU memory (E7).
- Clips at 1280x800 on the iGPU at 48 px/m (the handheld zoom): `gtai-masters/d9/handheld/deck-set-48ppm-king-city.mp4`
  (70 s: the King fight, then the city), `deck-king-48ppm-1280x800-igpu.mp4`, `deck-city-48ppm-1280x800-igpu.mp4`;
  the 32 px/m "before" clips `deck-king-1280x800-igpu.mp4`, `deck-city-1280x800-igpu.mp4`.

- The fill-rate lever: drawing the 2D frame at 960x600 and scaling it to the 1280x800 panel cuts render GPU on the iGPU
  9.10 -> 5.27 ms (-42 %, E8, a study row `deck_bench_ds75`); the look is not judged yet (next iteration: stills, a Call).

## What does not work yet
- Rumble is near-silent in the arena: 1 pulse in a 40 s King fight, 0 in the director reel (`player_hit` is not emitted
  where Rivet takes damage). The release-compile step of the evidence gate collides with seams' new temp-dir layout
  (their item; skipped with `--no-release`).

## Calls for the owner
1. **Handheld zoom** (stills: `gtai-masters/d9/handheld/zoom-city-deck-32ppm.png`, `-40ppm`, `-48ppm`, all 1280x800
   = the Deck's panel 1:1). At the shipped 32 px/m Rivet is ~25 px tall, about 3 mm on a 7-inch screen.
   a) 48 px/m (`zoom_k` 1.5): **the default built** for every handheld row; b) 40 px/m (`zoom_k` 1.25): more street in
   view; c) 32 (as desktop). One data value in `project/data/tables/devices.json`. Desktop does not change.
   Try it: `RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --view=tilt70 --device=deck`.
2. **The ghost-form panel on a handheld** (`still-king-33.png`): it covers about a third of the width and a quarter
   of the height of a 1280x800 panel, bottom-left. a) keep; b) a compact handheld panel (owed to the hud work);
   default built: a (nothing changed).
3. **Pad prompts for a PlayStation pad on the desktop too?** Built: only under the handheld rows (the desktop keeps
   the Xbox names: "the desktop must not move"). a) keep handheld-only; b) every run (one condition in
   `PadGlyphs.active_family`). Default built: a.
4. **Rumble on the desktop?** Built: handheld rows only. a) keep; b) a `rumble` value on the desktop row (one data
   value), plus a settings toggle (owed either way). Default built: a.

## Owed / next
- The Linux build: NAT-06 parity on the Linux `.so` (in WSL), a real Vulkan run (needs a Linux PC or a Deck).
- Glyph images per pad type, a PlayStation pad behind Steam Input (Steam's origin glyphs), a rumble settings toggle,
  rumble on blasts and crashes (no bus event), aim assist (a design call), a pad-only
  walk through menus and the dialogue.
- A/Bs: `handheld_1080` viewport vs native stretch; the iGPU frame is fill-bound (E6), so next: a lower 2D draw size
  scaled up (viewport stretch below 1280x800) and the print grain / light passes off on the handheld tier,
  the Switch-class budget at 3 threads.
