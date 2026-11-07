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
- Pause on focus-out (the Steam overlay) under a handheld profile, proven live by `scenario_handheld_focus_pause`
  (quest 1 running, the OS focus-out propagated: paused; the planted desktop run stays live).
- Pad rumble under the handheld rows (`HandheldRumble` on the Events bus: Rivet hit, a car strike, a tackle, a boss
  stepping in, a hijack, the whispers; desktop none) and prompts that name a PlayStation / Nintendo-layout pad's own
  buttons (`PadGlyphs`, handheld rows). Unit-tested; **never felt**: no pad on this PC.
- The 40 Hz battery row (`deck40`) measured against `deck` on the city block: GPU busy 38 % vs 55 % of each second,
  pinned CPU -26 % (E5, CONTENDED). (E6, "the 1.5x zoom costs nothing", was VOID: see below.)
- The desktop game unmoved with all of it in: evidence gate on 9b35dd21 lint 15/15, unit 1708/0, scenarios 52/52,
  parity bit-exact, look goldens 11/11 (`evidence/it4/`).
- The Switch-class budget (3 threads, 30 cap): the cap holds in the reel and the city; ~2.3 GB RAM + GPU memory (E7).
- **Correction (it7):** the it4 clips named `*-48ppm-*` are really **32 px/m**: in the dev arena (the King fight, the
  city block, the reel) the profile's zoom was read before `--device` was selected, so `zoom_k` never applied there
  (quest 1 and the city drive were right). Fixed (4a773812, the profile is selected in `LaunchArgs._init`); frames.json
  corrected. The real 48 px/m set (it7, the Deck profile, 1280x800, the iGPU):
  `gtai-masters/d9/handheld/deck-set-48ppm-real-king-city.mp4` (70 s: the King fight, then the city),
  `still-king-48ppm-real-20.png`, `still-city-48ppm-real-15.png`.
- The gates on the it7 code (e2f222df): director reel 19/19 chapters, 0 SCRIPT ERROR in top, tilt70, combo and
  combo + `deck` (`evidence/it7/reels-summary.log`); rumble in the reel under `deck`: 4 pulses (it4: 0).

- The fill-rate lever (E8c, same framing, CONTENDED, bench lock): drawing the 2D frame smaller and scaling it to the
  1280x800 panel cuts render GPU on the iGPU 8.12 -> 6.21 ms at 0.85 (-24 %) and -> 5.14 ms at 0.75 (-37 %); the look
  softens (stills looked at; Call 5). The 48 px/m handheld zoom renders ~10 % cheaper than 32 (8.12 vs 9.01 ms).

## What does not work yet
- Rumble on every hit Rivet takes is in (it7: the view reads his hurt tick; no sim change); its live pulse count is
  owed. The release-compile step of the evidence gate collides with seams' new temp-dir layout
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

5. **Draw the handheld frame smaller?** (`gtai-masters/d9/handheld/e8b-deck-vs-ds75-48ppm-city-t720.png` and its
   `-crop-x2`: left the full 1280x800 draw, right 960x600 scaled up, the same framing.) a) full draw: **the default
   built** (the Deck profile already has headroom: 8.1 ms of a 16.6 ms frame on a GPU weaker than a Deck's);
   b) 0.85 (-24 % GPU, a light softening); c) 0.75 (-37 % GPU, the grain, hatching and ink line go soft, and the HUD
   lays out in 960x600 so the ghost-form panel draws 1.33x bigger). One value (`draw_scale`) per row; try c:
   `RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --view=tilt70 --device=deck_ds75`.

## Owed / next
- The Linux build: NAT-06 parity on the Linux `.so` (in WSL), a real Vulkan run (needs a Linux PC or a Deck).
- Glyph images per pad type, a PlayStation pad behind Steam Input (Steam's origin glyphs), a rumble settings toggle,
  rumble on blasts and crashes (no bus event), aim assist (a design call), a pad-only
  walk through menus and the dialogue.
- A/Bs: `handheld_1080` viewport vs native stretch; the iGPU frame is fill-bound (E6), so next: a lower 2D draw size
  scaled up (viewport stretch below 1280x800) and the print grain / light passes off on the handheld tier,
  the Switch-class budget at 3 threads.
