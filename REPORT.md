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
- **Every card of quest 1 on a pad alone** (it11-12): title, pause, failed (Retry / Quit) and paid, walked live under
  `--device=deck` with pad events only (`evidence/it11/padwalk-deck.log`, `evidence/it12/padwalk-deck-cards.log`; still
  `gtai-masters/d9/handheld/padwalk-deck-failed-paid-1280x800.png`). On a handheld tier the pause card offers the frame
  cap (device / 30 / 40 / 60) and the rumble level (full / half / off, it12), both saved.
- **The native Linux build**: the CitySim `.so` built in Valve's Steam Runtime "sniper" SDK container
  (`sh tools/handheld/build_linux_so.sh`), the `linux-showcase` export
  (`"$GODOT_BIN" --headless --path project --export-release linux-showcase ../build/export/linux/RTAI.x86_64`),
  running the city under the Deck profile in WSLg on the AMD iGPU (`tools/handheld/wsl_run.sh`; `evidence/sim/e4-linux-wslg/`).
- Pause on focus-out (the Steam overlay) under a handheld profile, proven live by `scenario_handheld_focus_pause`
  (quest 1 running, the OS focus-out propagated: paused; the planted desktop run stays live).
- Pad rumble under the handheld rows (`HandheldRumble` on the Events bus: Rivet hit, a car strike, a tackle, a boss
  stepping in, a hijack, the whispers; desktop none) and prompts that name a PlayStation / Nintendo-layout pad's own
  buttons (`PadGlyphs`, handheld rows). Since it13 a light pulse when Rivet's hit takes a boss's hp (King fight
  under `deck`, 40 s of the boss bot: 59 pulses = 56 landed + 2 hurts + 1 engaged; it12 had 3). Unit-tested;
  **never felt**: no pad on this PC.
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
- The desktop unmoved with the it7 code in: evidence gate on 93c1fb69 lint 15/15, unit 1711/0, scenarios 53/53,
  parity bit-exact, look goldens 11/11 (`evidence/it7/evidence-run-93c1fb69.log`).

- The fill-rate lever (E8c, same framing, CONTENDED, bench lock): drawing the 2D frame smaller and scaling it to the
  1280x800 panel cuts render GPU on the iGPU 8.12 -> 6.21 ms at 0.85 (-24 %) and -> 5.14 ms at 0.75 (-37 %); the look
  softens (stills looked at; Call 5). The 48 px/m handheld zoom renders ~10 % cheaper than 32 (8.12 vs 9.01 ms).
- (it10) **BC7 textures on the iGPU Deck row** (perf's L4, LEDGER E10, CONTENDED, bench lock): the city's process RAM
  1386 -> 898 MB and the GPU's shared memory 1007 -> 489 MB (~1 GB back on a shared-memory handheld), render GPU 8.33 ->
  7.37 ms (-12 %); the King fight: RAM -350 MB, frame time unchanged. Lossless vs BC7 at 48 px/m look the same to me at
  2x (`gtai-masters/d9/handheld/e10-city-deck-lossless-vs-bc7-48ppm-t720*.png`). Call 6.
- (it10) **A 1920x1080 Windows handheld's HUD fits**: under `handheld_1080` the frame is drawn at 1422x800 (16:9) and
  scaled 1.35x; the ghost-form panel is whole (`handheld1080-city-48ppm-drawn-16x9-t720.png`). The it7 "clipped panel"
  was the movie capture (it records 1280x800 of the 1422-wide canvas).
- (it10) **A frame cap in the pause card on a handheld** (device / 30 / 40 / 60, saved with the settings; the desktop card
  does not show it). (it11) **Seen on screen and walked on the pad**: see below.
- (it11) **A pad could not press any menu button: fixed.** Godot 4.7.2's default `ui_accept` / `ui_cancel` carry no pad
  button (probed on the engine), so on a Deck the title card's Start was focused but A did nothing. A is on `ui_accept`
  and B on `ui_cancel` on every run now (`input_actions.json` `menu_pad`). The pause card kept losing the pad's focus on
  each settings press (its rows rebuild): it keeps it now. Live pad walk under `--device=deck` (pad events only): A on
  Start, Start pauses, the d-pad reaches the frame cap, A cycles it 30 -> 40 and `Engine.max_fps` follows
  (`evidence/it11/padwalk-deck.log`). On a handheld tier the cards are pad first: the controls line names the pad's
  buttons, a thick ink focus mark, no keyboard rebind rows (`gtai-masters/d9/handheld/padwalk-deck-pause-cap40-1280x800.png`,
  `padwalk-deck-title-1280x800.png`, looked at). The desktop card is unchanged (tested). Call 7.
- (it11) **BC7 on the Switch-class row** (E11, CONTENDED, bench lock): the city 2.26 -> 1.38 GB (RAM + GPU shared), the
  reel 1.52 -> 1.13 GB, the 30 cap holds; it10's ~1.3 GB inference measured at 1.38. Part of Call 6.
- (it11) B on a pad resumes from the pause card (pad events only; Esc stays the pause toggle). Reels on 955f56cb:
  top / tilt70 / combo / combo + deck 19/19, 0 SCRIPT ERROR (`evidence/it11/reels-summary.log`); the gate re-run on
  035643c7 green the same way (unit 1719/0, goldens 11/11). Gates on 955f56cb: lint 15/15, unit 1718/0, scenarios 53/53, parity bit-exact (planted mutation caught at 629), look goldens 11/11: **top bit-identical** (`evidence/it11/evidence-run-955f56cb.log`); release-compile still skipped (seams' temp-dir clash).

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
2. **The ghost-form panel on a handheld** (`still-king-48ppm-real-20.png`): it covers about a third of the width and a quarter
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

6. **BC7 texture compression** (perf's Call too; on the handheld it is a memory call more than a speed one). a) lossless
   everywhere: **the default built**; b) BC7 for the character, city and vehicle art in every build (perf's L4); c) BC7
   only in the handheld (Deck / Linux) build, by a build step that rewrites the imports in the export copy
   (`node tools/handheld/bc7_arm.mjs <copy>/project`, then `--import`, then export). Stills:
   `gtai-masters/d9/handheld/e10-city-deck-lossless-vs-bc7-48ppm-t720.png` and `-crop-x2`.

7. **Pad buttons in the menus on the desktop too?** Built: **every run** gets A on `ui_accept` and B on `ui_cancel`
   (without them a pad cannot press Start; no gate sends pad events, so `top`, replay and the goldens cannot move).
   a) every run (built); b) handheld rows only (one `if` in `LaunchArgs._ready`). And on a handheld tier the pause card
   hides the keyboard rebind rows (Steam Input remaps a Deck's pad): a) hide (built); b) keep them for a Windows handheld
   with a keyboard attached (one condition in `Quest1SettingsPanel._build_rows`).

## Owed / next
- (it7) The draw_scale HUD side
  effect (if Call 5 b/c), the King fight's rumble count, the dev-arena experiments E1-E3/E7 re-labelled "at 32 px/m".
- The Linux build: NAT-06 parity on the Linux `.so` (in WSL), a real Vulkan run (needs a Linux PC or a Deck).
- Steam Input's origin glyphs through the Steam backend (and a drawn ink glyph set: REQUEST to assets
  `ui_pad_glyphs_v1`, it12), rumble on blasts and crashes (no bus event), aim assist (a design call); a refractory gap for
  the landed-hit pulse if a fast gun turns it into a buzz (unmeasured).
- A/Bs: `handheld_1080` viewport vs native stretch; the iGPU frame is fill-bound (E6), so next: a lower 2D draw size
  scaled up (viewport stretch below 1280x800) and the print grain / light passes off on the handheld tier,
  the Switch-class budget at 3 threads.
