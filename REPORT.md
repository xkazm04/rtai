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
   `deck-quest1-40ppm-glyphs-1280x800-igpu.mp4`, the set clip `n9-handheld-set-deck-40ppm.mp4` (64 s).
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
- **The zoom before/after** (it6): `zoom-deck-king-32-vs-40ppm-1280x800-t900.png`,
  `zoom-deck-city-combo-32-vs-40ppm-1280x800-t600.png` (tick-exact, same tick both sides).
- **Legibility on the other rows:** `handheld_1080` every x-height >= 12 px; `switch_handheld` (720p) the boss count's
  digits at cap 10 px, judged legible on a still, everything else >= 9.
- **Simulator tooling:** `grab_window.ps1` reads the game window itself (another lane's window over it was captured
  before, 128c925e); `glyph_inkbox.py`.
- **Research:** Valve's "SteamOS Compatible" label derives from the Deck review (LEDGER section 1); the ARM
  determinism note narrowed (the CitySim is already strict-FP, NAT-07; the engine's own math on an arm64 build is the
  open part, LEDGER section 1).

Gates (latest, it6): at 4870776c the evidence run `--no-bench` all PASS (lint, unit 1845/0, scenarios 54, parity
(mutation caught at 629), selftest look goldens 11/11, release-compile 619/0,
`evidence/n9h/it6/gates/evidence-run-4870776c.txt`); the director reel 19/19 chapters fully down, 0 SCRIPT ERROR in top,
tilt70 and combo at 98cacb86, the last shipped-code change (`evidence/n9h/it6/gates/`). (Freeze: re-run on the final head.)

## What does not work yet

- The boss cam (handheld rows and the dev `--boss-cam` clips) snaps ~60 px in one frame once in the King clip
  (frame 155 of `deck-king-40ppm-bosscam-1280x800-igpu.mp4`; the FAR_M 20 m switch suspected): fix owed (it7).
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
4. **The 40 Hz row as the Deck default?** E17: GPU busy -30 %, pinned CPU -24 % (a battery proxy). a) 60 with the
   player's 30 / 40 / 60 cap in the pause card (built); b) 40 by default.

5. **The boss cam on the desktop too?** The follow camera shows the same paper past Servo's yard on the desktop at
   1280x800 (`evidence/n9h/it6/zoom/servo-desktop-t900.png`). a) handheld rows only (built); b) every row (`boss_cam`
   on `desktop`, or make BossCam the default; moves the shipped boss look, so a world/look-golden question).
   Try: `RTAI.exe -- --boss=servo --device=deck` vs `RTAI.exe -- --boss=servo`.

## Next steps

- The freeze: the final gates, the exe (`build/export/windows/RTAI.exe`, the export line here), this report final.
- A real port: see the LEDGER's port readiness table (Steam Deck: Linux build + Proton check 2-3 days, Verified
  polish 3-5 days; Switch-class: the platform holder's program, an engine port, 3-6 months).
