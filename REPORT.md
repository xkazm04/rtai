# REPORT: lane handheld (n9, 2026-11-08), DRAFT at 05:06 (to be finished at the 10:30 freeze)

Branch `n9-handheld`, cut from main at da108c13 (d9 merged). Clips and stills:
`C:\Users\kazda\kiro\gtai-masters\n9\handheld\` (`frames.json`, 15 entries, best first). Research, profiles, every
A/B: `docs/handheld/LEDGER.md`. Every number is **on the simulator** (this PC: the 7800X3D pinned to 8 threads, the
CPU's 2-CU Radeon iGPU, below-normal priority), never on a device.

## What works (with evidence)

The owner's picks of 2026-11-07, in the brief's order:

1. **Handheld zoom 40 px/m (h-1 B).** `zoom_k` 1.25 on every handheld row of `devices.json` (f3297ad2, DECISION
   `handheld/zoom-40`, test `test_every_handheld_row_draws_at_40_ppm`). The King arena's boss cam honours it (Rivet
   ~42 px tall at 40 px/m: he is 1.1 m on this branch; rivet's 1.65 m lands on its own branch, ~66 px then).
   Re-filmed on the iGPU at 1280x800: `deck-king-40ppm-compact-1280x800-igpu.mp4`, `deck-city-40ppm-compact-1280x800-igpu.mp4`,
   `deck-quest1-40ppm-glyphs-padfirst-1280x800-igpu.mp4`, the set clip `n9-handheld-set-deck-40ppm.mp4` (63 s, re-cut in it9).
2. **A compact ghost-form card on handhelds (h-3 B).** `hud: compact` on the handheld rows (`DeviceProfile.hud`,
   `GhostFormLayout`; 6ca6d359, DECISION `handheld/compact-ghost-panel`). At 1280x800 the card goes from ~386x208 px
   (30 % x 26 % of the panel) to ~250x170 px (20 % x 21 %), about half the area; text stays 18 px. Legibility measured
   live (`TextProbe` + `dev/handheld/legibility_walk.gd`, 8ea46cd4): every text on the Deck row clears Valve's 9 px
   floor under the strict x-height reading (smallest: the boss count x 9 / cap 12; the 18 px texts x 10 / cap 13).
   Stills: `ghostpanel-king-deck-before-after-40ppm-1280x800.png`, `ghostcard-deck-lb-gap-fixed-crop-x2.png`.
   The desktop card is unchanged (`desktop` row has no `hud`).
   The one text that sat at the floor, the boss bar's phase count "1 / 3", draws at 18 px instead of 16 on the
   compact-HUD rows (it5, DECISION `handheld/boss-count-18`; the desktop stays 16).
3. **The drawn pad glyphs (`ui_pad_glyphs_v1`).** `PadGlyphArt` draws the bracketed pad names as the ink glyphs in the
   quest 1 prompt, the title and pause controls line and the ghost card's key hint, on the handheld rows (b349c3bf,
   DECISION `handheld/drawn-pad-glyphs`, provenance line in `steam/ai-provenance/2026-11.jsonl`). Each cell draws by its
   trimmed ink box (`tools/handheld/glyph_inkbox.py` reproduces the shipped json byte for byte), so LB / RB / Start read
   as tall as the face buttons. The glyphs follow the pad family (Xbox / PlayStation / Nintendo-layout names each draw
   their own face, trigger and menu cells; the Nintendo-layout "+" / "-" and the PlayStation Create came as the asset
   lane's appendix on my REQUEST and are wired, 6e62c562): `glyphs-deck-pad-families-controls.png`. Stills of the title, pause and a quest 1
   prompt: `glyphs-deck-title-and-prompt-crop-x2.png`, `glyphs-deck-quest1-prompt-40ppm-1280x800.png`,
   `legibility-deck-pause-1280x800.png`.
   The keyboard twin `ui_kb_glyphs_v1` is wired too, behind the desktop study row `desktop_kb_glyphs` only
   (ca917066, DECISION `handheld/kb-glyphs-study`): `kbglyphs-desktop-title-prompt-crop-x2.png` (Call 1).
4. **The Linux depot DECISION (h-5 A).** `handheld/linux-depot` in `docs/decisions.md` and the LEDGER: a native Linux
   depot, Proton as the fallback, re-check trigger "a real Vulkan run on a Deck or a Linux PC" (f3297ad2).
5. **BC7 on the Deck row** (world lands BC7 in every build): E16b, under the bench lock, 3 interleaved rounds, world's
   b0f1024e vs this branch: GPU shared memory 1086 -> 600 MB (-45 %), private RAM 1476 -> 991 MB (-33 %), render GPU
   p50 8.53 -> 7.59 ms (-11 %), the frame vsync-locked at 16.6 ms in both (a7b9c6b6, `evidence/n9h/it4/e16b/`). The
   look holds on the handheld panel: `bc7-deck-city-40ppm-lossless-vs-bc7-crop-x2.png` (indistinguishable at 2x).

The research loop since:

- **The pad aim assist, wired and shown live.** The gunplay lane's `AimAssist` (weapons.json: 8 deg cone, 25 m,
  35 % bend) was called nowhere in the shipped game; now `LiveInput` bends the right stick's heading on the handheld
  rows before it is packed (replays record the bent heading) (33f80d56, DECISION `handheld/pad-aim-assist`). Live in
  the King arena on pad events: a 5 deg stick error stays 5 deg beyond 25 m and bends to 3.25 deg inside it on `deck`;
  `desktop` stays raw (7c993d29, `evidence/n9h/it4/aimwalk/`).
- **E18, a slower core: the tool dropped, the estimate tightened.** A Windows job CPU hard cap on the game (45 / 35 /
  25 % of one core, bench lock, 3 rounds) freezes it for 0.2-3.5 s instead of stretching frames, so it cannot find
  where 60 Hz breaks. Kept: E15's 0.53 core is an upper bound (much of it is pacing wait); with the sourced 1.84x
  single-thread ratio the city needs ~0.55-0.92 of one Deck core at 60 Hz (LEDGER E18, 95f119f6).
- **E19, the combo switch on the Deck row costs nothing measurable** (world's branch boots combo): the city in combo vs
  tilt70, uncapped Deck profile, the iGPU, 3 rounds, bench lock (CONTENDED): frame p50 9.21 vs 9.40 ms, render GPU 8.39
  vs 8.38 ms, every delta inside the spread; ~7 ms headroom under 60 Hz. Still: `evidence/n9h/it5/combo/deck-city-combo-t14.png`.
- **The 40 Hz row at 40 px/m** (E17, bench lock, 3 rounds, CONTENDED): GPU busy per second -30 %, pinned CPU -24 %;
  on combo, the view main will play (E17c, it6): -32 % and -26 %. Three views and two zooms agree.
- **E20, the Deck row on what main will be** (this branch + n9-world in a scratch merge; the code merges cleanly, only
  JOURNAL and the debt baseline conflict): `deck`, city combo, the iGPU, 3 rounds, bench lock: vsync-locked 60 both,
  render GPU 8.65 -> 7.69 ms, GPU shared 1055 -> 600 MB, private RAM 1430 -> 991 MB, CPU the same (31222638).
- **The handheld boss cam** (it6, 98cacb86, DECISION `handheld/boss-cam`): on every handheld row the boss fights use
  the tested clip camera (BossCam) that frames Rivet and the boss together on the fight's floor. On the Deck row at
  40 px/m the follow camera showed half the screen as paper past Servo's yard; now the yard fills it with both
  fighters in. The desktop is untouched. Still: `bosscam-deck-servo-before-after-40ppm-1280x800-t900.png`.
- **The boss cam's snap fixed** (it7, 2d6a14a7, DECISION `handheld/boss-cam-band`): proven by a focus log (frame 154,
  Rivet 19.8 m from the King, the focus jumped 76 px as the 20 m switch flipped); the lean now fades on a smoothstep
  between 14 and 28 m (unchanged within 14 m). Over 2700 frames the worst focus move is 11.3 px (King), 14.7 px
  (Servo's charges); the re-filmed King clip (`deck-king-40ppm-bosscam-band-1280x800-igpu.mp4`, iGPU, 0 SCRIPT ERROR)
  has no jump at frame 155 by phase correlation (62 px before). The two 20-24 px "starts" it7 still listed are not the
  camera (it8: the ground band moves 1 px a frame there; the King's car and the telegraph wedge moved).
- **The boss cam eases** (it8, 630f91a7, DECISION `handheld/boss-cam-ease`): the framing's speed jumped up to 15.4 px
  a tick in one tick (King; 14.6 Servo) when a keep-in margin engaged; `CamFollow` caps the change at 3 px a tick,
  brakes without overshoot and matches steady pans. In game: 0 jolts left, the worst lag 28 px (0.7 m, inside every
  margin), a brief faster catch-up (peak 17-21 px a tick). Clips: `deck-king-40ppm-bosscam-ease-before-after-halfspeed.mp4`,
  `deck-king-40ppm-bosscam-ease-1280x800-igpu.mp4`, `deck-servo-40ppm-bosscam-ease-1280x800-igpu.mp4` (the Radeon iGPU
  on its engine log, 0 SCRIPT ERROR).
- **The first prompt names the pad on a handheld** (it9, 2f842523, DECISION `handheld/pad-first`): filming quest 1
  pad-only on the Deck row showed the first prompt as "Walk [W A S D] to the dumpster, hide: [E]" until the stick moved
  (the title card takes the pad's A before the session's input exists), against Valve's rule that the default glyphs
  match the Deck. A handheld row's live input now starts pad-first until a key or the mouse is used; the desktop starts
  on the keys as before. Still `padfirst-deck-quest1-first-prompt-before-after-crop-x2.png`, clip
  `deck-quest1-40ppm-glyphs-padfirst-1280x800-igpu.mp4` (iGPU, 0 SCRIPT ERROR); 4 tests.
- **A Deck picks its own row** (it10, d6df5bc7, DECISION `handheld/deck-auto-pick`): every handheld change sat behind
  `--device=`, and a real Deck launches with no flags, so a Deck player would have got the desktop game. Now a run with
  no `--device=` takes the `deck` row when Steam's `SteamDeck=1` is set (the Steam client sets it on SteamOS) and the
  screen is 1280x800; a docked Deck or a SteamOS desktop keeps the desktop; `--device=desktop` or `SteamDeck=0` opts
  out. The desktop never reaches the screen query (no variable here). Live here: `SteamDeck=1` on the 1920x1080
  screen logs "the desktop row" (the docked case), 0 SCRIPT ERROR (`evidence/n9h/it10/auto-*.log`). Tests 2; Steamworks' `IsSteamRunningOnSteamDeck`
  joins as the first check with the Steam port. A Deck that picked itself opens fullscreen (3d235479, DECISION
  `handheld/deck-fills-screen`: desktop mode's taskbar would cover a 1280x800 window); `--device=` keeps the window.
- **A trackpad no longer flips the prompts on a handheld** (it9, b7621d73, DECISION `handheld/click-flips`): Valve's
  Deck recommendations name pad / keyboard icon flipping as a common problem and say to switch to mouse/keyboard mode
  "only ... if a mouse click event is received". On a handheld row mouse motion (a Deck trackpad in Steam's default
  layout) still aims but keeps the pad glyphs; a click or a key hands them to the keys. The desktop unchanged; 2 tests.
  Shown live (pad walker + one mouse motion, iGPU): `clickflips-deck-quest1-prompt-after-mouse-motion-before-after-crop-x2.png`.
- **The Deck set filmed at combo, the view main plays** (it9, the Radeon iGPU, each run in its own app data, the adapter
  and 0 SCRIPT ERROR on its engine log, movie mode, CONTENDED): the city (`deck-city-combo-40ppm-1280x800-igpu.mp4`,
  20 s: the course bot's hub waypoints walk into a roof in the city block at ~12 s, so it is cut there) and quest 1 Dock 9
  into the Quartermaster (`deck-quest1-dock9-combo-40ppm-1280x800-igpu.mp4`, 45 s: the pad glyphs in the fight prompts,
  the compact card and the dialogue cards clear of each other). The set clip `n9-handheld-set-deck-40ppm.mp4` re-cut
  (63 s, captions) from the eased boss takes, these two and the pad-first quest 1.
- **E20b, the Deck rows on world's near-final head** (it10, e3c54005 merged in a scratch tree; the code merges
  cleanly; bench lock, 3 rounds, all 12 runs CONTENDED): `deck` render GPU 8.89 -> 8.02 ms, GPU memory 1118 -> 601 MB,
  RAM 1493 -> 992 MB; `deck30` the same shape (7.94 ms, 632 MB, 1040 MB) and a third less pinned CPU. LEDGER E20b.
- **E21, the 40 Hz cadence** (it7, 7a6681e2): filmed at each row's own rate, `deck40` steps 1, 2, 1, 2 ticks a frame and
  73 % of its pan steps go 1:2; a new `deck30` row pans as evenly as 60. Battery proxy (bench lock, 3 rounds): GPU busy
  per second 36 % -> 27 % (-25 %) from 40 to 30; CPU the same (the sim ticks 60 Hz either way).
- **The zoom before/after** (it6): `zoom-deck-king-32-vs-40ppm-1280x800-t900.png`,
  `zoom-deck-city-combo-32-vs-40ppm-1280x800-t600.png` (tick-exact, same tick both sides).
- **Legibility on the other rows:** `handheld_1080` every x-height >= 12 px; `switch_handheld` (720p) the boss count's
  digits at cap 10 px, judged legible on a still, everything else >= 9.
- **Simulator tooling:** `grab_window.ps1` reads the game window itself (another lane's window over it was captured
  before, 128c925e); `glyph_inkbox.py`.
- **Research:** Valve's "SteamOS Compatible" label derives from the Deck review (LEDGER section 1); the ARM
  determinism note narrowed (the CitySim is already strict-FP, NAT-07; the engine's own math on an arm64 build is the
  open part, LEDGER section 1).

Gates (it10): at 6f320d24 (the Deck auto-pick) the director reel 19/19 fully down, 0 SCRIPT ERROR in top, tilt70 and
combo; the evidence run `--no-bench` all PASS (lint, unit 1863/0, scenarios 54, parity, look goldens 11/11,
release-compile 620/0, `evidence/n9h/it10/gates/`). 3d235479 (fill_screen) after it: unit --select 24/0, lint 15/15.
Gates (it8): at 8c1acea1 (the boss cam ease) the evidence run `--no-bench` all PASS (lint, unit 1855/0, scenarios 54,
parity, look goldens 11/11, release-compile 620/0, `evidence/n9h/it8/gates/evidence-run-8c1acea1.txt`); the director
reel 19/19 fully down, 0 SCRIPT ERROR in top, tilt70 and combo at 630f91a7 (the shipped-code change; 8c1acea1 adds a
test and a comment); mutation score on `cam_follow.gd` 19/20 (95 %), the survivor then killed by a test.
Gates (it9): at 2f842523 (pad-first) the director reel 19/19 fully down, 0 SCRIPT ERROR in top, tilt70 and combo; at
3928fe2b the evidence run `--no-bench` all PASS (lint, unit 1859/0, scenarios 54, parity (mutation caught at 629), look
goldens 11/11, release-compile 620/0, `evidence/n9h/it9/gates/evidence-run-3928fe2b.txt`); mutation on `live_input.gd`
at 5224bd98: 30.9 % file-wide (21/68: the old sample / aim code is covered by the scenarios, not these unit tests),
the one mutant on the pad-first lines killed (`evidence/n9h/it9/gates/mutate-live_input-5224bd98.txt`).
Gates (it7): at 2d6a14a7 (the boss-cam band, the last shipped-code change before the `deck30` data row) full unit 1847/0 and
the director reel 19/19 fully down, 0 SCRIPT ERROR in top, tilt70 and combo (`evidence/n9h/it7/gates/`).
At 32f498d8 the evidence run `--no-bench` all PASS (lint, unit 1848/0, scenarios 54, parity (mutation caught at 629),
look goldens 11/11, release-compile 619/0, `evidence/n9h/it7/gates/evidence-run-32f498d8.txt`).
Gates (it6): at 4870776c the evidence run `--no-bench` all PASS (lint, unit 1845/0, scenarios 54, parity
(mutation caught at 629), selftest look goldens 11/11, release-compile 619/0,
`evidence/n9h/it6/gates/evidence-run-4870776c.txt`); the director reel 19/19 chapters fully down, 0 SCRIPT ERROR in top,
tilt70 and combo at 98cacb86, the last shipped-code change (`evidence/n9h/it6/gates/`). (Freeze: re-run on the final head.)

## What does not work yet

- The 40 Hz row judders: the 60 Hz tick over 25 ms frames steps 1, 2, 1, 2 ticks a frame, so pans and sprites move
  10, 20, 10, 20 px (E21). The cure (every view drawn between two ticks) is owed; 30 and 60 are even (Call 4).
- Steam Input origin glyphs (a remapped pad) need the Steam backend: owed with the Steam port.
- Nothing here is proven on a Deck: watts, battery hours, Zen 2 single-thread frame times (E18:
  ~0.55-0.92 of one Deck core at 60 Hz, an estimate the simulator cannot pin down), the shader cache's first run, suspend on SteamOS, the Linux build under real Vulkan.

## What blocked, and for how long

- Nothing blocked for long. Friction: warnings-as-errors in scratch walkers (~5 min each time; now checked with
  `tools/godot/check.mjs` first); gdformat writing CRLF on Windows (a replace silently missed, it3); a screen-copy grab
  that captured another lane's window (it2, fixed).

## Calls for the owner

1. **The keyboard glyphs on the shipped desktop?** (`kbglyphs-desktop-title-prompt-crop-x2.png`, `kbglyphs-desktop-title-after.png`.)
   a) keep the text keys (built); b) draw `ui_kb_glyphs_v1` on the desktop (one `glyphs: kb` value on the `desktop` row).
   Try: `RTAI.exe -- --device=desktop_kb_glyphs`.
2. **The pad aim assist for a desktop pad too?** The owner's decision 2 said "pad only", not "handheld only".
   a) handheld rows only (built); b) every pad (`aim_assist: true` on the `desktop` row).
3. **A larger handheld text scale?** Every text clears Valve's 9 px floor on the Deck row; since it5 the one text that
   sat at the floor (the boss count) draws at 18 px on handheld rows, so the smallest is now x-height 10 / cap 13 (the
   pause card's -, + and Toggle). a) keep (built); b) a row-level text scale for every handheld text (owed work, ~half
   a day; re-lays the cards). Still: `count-deck-16-vs-18-crop-x4.png`.
4. **The Deck's battery mode: 40 or 30?** E17: 40 cuts GPU busy -30 %, pinned CPU -24 % against 60; but E21: at 40 the
   60 Hz sim steps 1, 2, 1, 2 ticks a frame and pans judder (73 % of steps uneven), while 30 is even and cuts GPU busy
   a further -25 %. a) 60 by default with the player's 30 / 40 / 60 cap in the pause card (built); b) 30 as the
   recommended battery mode (drop 40 from the cap list until views interpolate); c) 40 by default and build view
   interpolation (owed, days). Clips (each at its own rate, the iGPU): `deck40-king-40ppm-bosscam-40fps-igpu.mp4` vs
   `deck30-king-40ppm-bosscam-30fps-igpu.mp4`. Try: `RTAI.exe -- --boss=king --device=deck40` vs `--device=deck30`.

5. **The boss cam on the desktop too?** The follow camera shows the same paper past Servo's yard on the desktop at
   1280x800 (`evidence/n9h/it6/zoom/servo-desktop-t900.png`). a) handheld rows only (built); b) every row (`boss_cam`
   on `desktop`, or make BossCam the default; moves the shipped boss look, so a world/look-golden question).
   Try: `RTAI.exe -- --boss=servo --device=deck` vs `RTAI.exe -- --boss=servo`.

## Next steps

- The freeze: the final gates, the exe (`build/export/windows/RTAI.exe`, the export line here), this report final.
- A real port: see the LEDGER's port readiness table (Steam Deck: Linux build + Proton check 2-3 days, Verified
  polish 3-5 days; Switch-class: the platform holder's program, an engine port, 3-6 months).
