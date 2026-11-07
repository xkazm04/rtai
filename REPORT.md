# REPORT: lane handheld (d9, 2026-11-07), final at the 18:30 freeze

Every number is **on the simulator** (this PC under a device profile: 8 pinned threads, below-normal
priority, the CPU's own 2-CU Radeon), never a device claim. Details and sources: `docs/handheld/LEDGER.md`.

**The exe for the owner** (exported 17:44 from 0ee1ba66; every commit after it is docs and evidence, `git diff 0ee1ba66 HEAD -- project` is empty, so it is the freeze build):
`build/export/windows/RTAI.exe` (328 MB, PCK embedded, + `gtai_sim.windows.template_release.x86_64.dll`), made with
`"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
(smoke: `RTAI.exe --headless --quit-after 300` exit 0, 0 SCRIPT ERROR). The Deck profile in it:
`RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --view=tilt70 --device=deck` (and `--device=deck40`,
`--device=switch_handheld`).

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
- (it13) **A landed hit on a boss is felt** (`boss_hit`, 70 ms, lighter than a hurt; the boss bar reads the boss's
  hurt tick, view-side): the King fight under `deck` (40 s of the boss bot) 3 -> 59 pulses (56 landed + 2 hurts + 1
  engaged), Servo 2 -> 63; the hurt counts unchanged, so nothing cut and the fight unmoved
  (`evidence/it13/*-rumble-deck-hit.log`). Gate on cab191e0: lint 15/15, unit 1728/0, scenarios 53/53, parity
  bit-exact, look goldens 11/11: **top bit-identical**; reels top / tilt70 / combo / combo + deck 19/19, 0 SCRIPT ERROR
  (`evidence/it13/`). Mutation: player_settings.gd 66.7 -> 86.1 %, handheld_rumble.gd 71.1 -> 86.7 % (the 6 left
  equivalent); the full unit run on af40d92d 1733/0.
- (it13) **E12, perf's upload-buffer trim on the iGPU** (perf's instrumented export, 1280x800, the riot, 1 run per arm,
  memory only): the stock engine holds 224 MB of staging; trimmed, the GPU's shared memory 1006 -> 878 MB and the
  working set 1304 -> 1128 MB. On a Deck that memory is the RAM the game shares with the GPU: perf's traffic-sheet
  split is worth ~128 MB there (`evidence/it13/tw-igpu/`).
- (it14) **A fast gun no longer buzzes the pad** (`boss_hit` rests 8 ticks after a felt one): with the gatling or the
  machine pistol a hit lands on a boss every 2 ticks, so the 70 ms pulses had chained into one buzz (King 225 pulses
  in 40 s); now 80 taps + 145 rested, the stock gun's fight unchanged (59 / 63 pulses, 0 rested)
  (`evidence/it14/*-gap.log`). DECISION handheld/boss-hit-rest.
- (it14) **E13, the sim is the same on Linux**: in WSL Ubuntu with the official 4.7.2 Linux editor (sha512 checked),
  NAT-06 parity on the Linux `.so` is exact over 1200 steps (planted fault caught at 629, as on Windows), and city-block World
  replays cross both ways identical (Windows-recorded 1800 ticks on Linux, Linux-recorded 3600 ticks on Windows):
  a replay made on a Deck runs the same on the PC (`evidence/it14/linux/`; a save file across the two OSes is not tested). Idle input and the debug `.so`.
- (it15) **E13c, editor = release = Windows = Linux**: every replay identical across the four builds (the editor and the
  release `windows-dev` / new `linux-dev` exports for the city-block World; the editor, `windows-slice` and `linux-slice`
  for a quest 1 log), the release `.so` / `.dll` included; a release build records too (Windows seed 13, Linux seed 17,
  each replayed on the other OS identical). it14's "E13b diverges at tick 60" is **withdrawn**: my mislabel (World logs fed
  to the quest 1 slice, a different simulation); no SIM-05 finding (`evidence/it15/`, LEDGER E13c).
- (it15) **E14, a save crosses Windows <-> Linux**: a quest 1 autosave (the real `Save` engine, a scripted input tape)
  written on Windows resumes on Linux at the same state hash and runs +600 ticks to the same hash, and the reverse
  (`dev/save_cross.gd`; a flipped byte is refused). A Deck save resumes on the PC; Steam Cloud's root override is the rest.
- (it15) Gate on 3c96af2c (E13c + E14): lint 15/15, unit 1735 / 0, scenarios 53/53, parity exact (planted caught at 629),
  look goldens 11/11 (worst 0.27) + block 5/5, export-audit 601 / 0: **top bit-identical**; the unit step reads FAIL only for
  "tree changed during run" (I copied two evidence folders in while it ran), no test failed. Reels top / tilt70 / combo /
  combo + deck **19/19, 0 SCRIPT ERROR**. `handheld_rumble.gd` mutation **85.5 %** (53 / 62) on 68c5ee42; the two
  survivors on the gap guard (:103) now killed by a test (planted by hand -> FAIL), the other 7 equivalent.
- (it18) **E15, who pays the CPU on a Deck row** (perf's `thread_cpu.ps1`, the city, the iGPU, bench lock, 1 run per arm):
  the engine main thread carries 0.527 of 0.534 cores at 60 Hz and 0.318 of 0.33 at 40 Hz; the worker pool and the
  driver threads barely show. **E15b**, the control (3 interleaved rounds): pinned to 2 threads (1 core) the Deck
  row still holds 60 at the median (16.66 ms) in every round; the tail (settled frames over 33 ms: 5 / 17 / 4 on one
  core vs 1 / 12 / 4 on four) is inside the contention noise, so my first-round "the tail grows" is withdrawn. So a
  Deck's single-core speed decides a steady 60; whether its spare cores buy a smoother tail needs a quiet machine. *Estimate, not measured*:
  a Zen 2 core does ~1.6-2x less per thread than this Zen 4, ~0.85-1.05 of a Deck core at 60 Hz: tight; the 40 Hz row
  is the margin (`evidence/it18/`, LEDGER E15 / E15b; both CONTENDED or single runs, labelled).

## What does not work yet
- (it15) The slice exe cannot record quest 1: `--autostart` is debug-only (`quest1_card.gd:70`), so a headless release
  exe waits on the title card. By design for a shipped build; a recording from a played (pad-driven) session is untested.
- Nothing on this list has been felt or seen on a real handheld: rumble, the 7-inch legibility, Zen 2 frame times,
  battery hours, SteamOS suspend and the Vulkan path are all simulator or model-knowledge claims.
- Rumble on blasts and car crashes: no bus event to hang it on (owed). Steam Input origin glyphs: owed (Steamworks).
- (it11's release-compile clash with seams' temp dirs is gone: the it15 gate ran export-audit 601 / 0.)

## What blocked, and for how long
- The drawn pad glyph set (REQUEST to assets `ui_pad_glyphs_v1`, it12): **unserved all day** (the asset lane drew Rivet's
  sheets and the weapons first, rightly). The prompts name the pad's buttons in text (`PadGlyphs`); a drawn set is owed.
- Compatibility (OpenGL) on the iGPU: blocked on this PC (E1b: OpenGL takes the monitor's adapter, the RTX 4090).
- A real Vulkan run of the Linux build: blocked (WSLg has no Vulkan-on-D3D12 ICD); needs a Linux PC or a Deck.
- Contention: most numbers ran beside 1-4 other lanes' Godot runs (labelled CONTENDED); the bench lock waits were
  short. Smaller losses, each in JOURNAL as FRICTION (lint on a lane-named dev folder ~6 min, a mutate log name ~13 min).
- Perf's FYI (their it18): `boot/minimized_cap.gd` caps a minimized window at the tick; my rows' `max_fps` 60 / 40 / 30
  stay in charge (cap <= 60), so after the merge a Windows handheld sent to the background stops spinning. Not on this
  branch; nothing to change here.

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

8. **What the Deck runs: a native Linux build or the Windows build under Proton?** (it15: the evidence is logs, no
   still: `evidence/it15/`, LEDGER E4 / E13 / E13c / E14.) The native build is proven on the simulator so far: the
   sniper-runtime `.so` builds, exports (`linux-slice`, 292 MB), runs the city in WSLg, replays identical with the
   Windows editor and release builds, and a save resumes across the two OSes at the same hash. Proton would run the
   Windows build unchanged but turns D3D12 into Vulkan through vkd3d-proton. a) **native Linux depot + Proton as the
   fallback** (the recommendation: Valve recommends Vulkan for battery; one more depot and one more CI export);
   b) Proton only (one build, no Linux depot; D3D12 translated). Nothing is built either way until the Steam port: today both exports
   exist. A real Vulkan run on a Linux PC or a Deck is what decides it (WSLg has no Vulkan here).

## Owed / next (in order)
1. **A real device before any port promise**: a Deck (or a Linux PC with an AMD GPU) for the Vulkan run of the native
   build, Zen 2 frame times at 4-15 W, battery hours, the shader cache's first run, Steam Input's default config, suspend
   on SteamOS. E15 says watch the main thread first.
2. Steam port plumbing (needs Steamworks): Steam Input origin glyphs through the Steam backend, Steam Cloud's root
   override for `user://profile/` (LEDGER section 1), the Linux depot (Call 8).
3. Controller polish: the drawn glyph set (`ui_pad_glyphs_v1`), rumble on blasts and crashes (a bus event first), aim
   assist for twin-stick aiming (a design call), whether the `boss_hit` rest reads as taps on a real pad.
4. The owner's Calls 1-8 decide the handheld defaults (zoom, draw scale, BC7, menus, the Linux build).
5. If a Deck misses 60 on the main thread: profile the main thread on the Linux build (the sim already steps in native
   code), then the 40 Hz row as the shipped battery default.
6. Switch-class: nothing to build until the platform holder's programme and an engine port exist (LEDGER section 7).
