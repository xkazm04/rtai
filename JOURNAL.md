# JOURNAL: lane handheld, night run n9 (2026-11-08)

Branch `n9-handheld` cut from main at da108c13 (d9 merged). Evidence: `evidence/` here and `C:\Users\kazda\kiro\gtai-masters\n9\handheld\`.

## Iteration 1 (BUILD), 00:56-01:56

- 00:57 READ: d9 REPORT (Calls 1-8), the asset delivery `handheld_ui_pad_glyphs_it98.md`, devices.json, decisions tail.
  Order tonight: (1) zoom_k 1.25, (2) compact ghost-form panel, (3) drawn pad glyphs, (4) Linux depot DECISION, (5) BC7 re-measure on world's branch.
- Registry rules applied (from d9, re-read): adaptive-fidelity-tiers (a tier is one data row, default untouched),
  on-device-verification-harness (every number labelled "on the simulator"), perf-regression-gating (interleaved A/B, medians, noise stated).
- 01:00 MILESTONE item 1 (zoom 40 px/m): `zoom_k` 1.25 on every handheld row (`deck_bench_z1` stays 1.0 = the study's A side),
  test `test_every_handheld_row_draws_at_40_ppm`; DECISION handheld/zoom-40. Commit f3297ad2.
- 01:00 MILESTONE item 4 (Linux depot): DECISION handheld/linux-depot in docs/decisions.md and LEDGER section 8, re-check
  trigger "a real Vulkan run on a Deck or a Linux PC". Commit f3297ad2.
- 01:03 Film: city at 40 px/m on the iGPU, `sim.mjs --device=deck --scene=city --movie` (CONTENDED: 3 other Godots; movie
  mode, so the frame numbers are not speed numbers): `gtai-masters/n9/handheld/deck-city-40ppm-1280x800-igpu.mp4`.
- 01:14 MILESTONE item 2 (compact ghost-form card): `devices.json` `hud: compact` on the handheld rows (`DeviceProfile.hud`),
  `GhostFormLayout` (full = the authored constants, tested; compact = chips r 19 at a 50 px pitch, margin 22, card 120,
  one name: the selected ghost's), `GhostChipGlyph` split out of the 200-line HUD file unchanged. 4 ghosts at 1280x800:
  ~386x208 px -> ~250x170 px with the memo paper (30 % x 26 % of the panel -> 20 % x 21 %), about half the area; text
  stays 18 px (cap ~13 px > Valve's 9 px floor, at the 12 px recommendation). Study row `deck_hud_full` = the before.
  Stills (the King, `--device=deck` vs `deck_hud_full`, iGPU, t=18 s, 40 px/m): `ghostpanel-king-deck-before-after-40ppm-1280x800.png`.
  Commit 6ca6d359; DECISION handheld/compact-ghost-panel.
- 01:18 MILESTONE item 3 (drawn pad glyphs): `PadGlyphArt` (features/pad_glyphs: the library atlas copied as delivered,
  36 cells) draws "[A]" / "[RT]" / "[L-stick]" as the ink glyphs on the handheld rows: the quest 1 objective prompt and
  the title / pause controls line (RichTextLabel atlas-region images). Provenance line appended. Stills from a pad-only walk
  (scratch walker, `evidence/n9h/it1/padwalk/`): `glyphs-deck-title-1280x800.png`, `-pause-`, `-quest1-prompt-40ppm-`,
  `glyphs-deck-title-and-prompt-crop-x2.png`. Looked at all: legible, ink look, no reserved colours. Commit b349c3bf.
- 01:23 The ghost card's key hint said "Q" on a pad: now the pad's glyph (LB / RB read from the InputMap for
  power_hauler / power_gearbox), handheld rows only. Commit after b349c3bf.
- FRICTION: `tools/godot/check.mjs` on any script that names an autoload chain reports "Failed to compile depended
  scripts" (also for the untouched `pad_glyphs.gd`): not a real error; the unit run is the truth.
- FRICTION: the evidence run refused a dirty tree (my untracked sim JSONs); `evidence/n9/` already holds another run's
  tracked files, so my evidence moved to `evidence/n9h/it1/`.
- 01:25 READ the other journals: world's NOTE (item 1 landed at 3e02d3b8: combo default, bikes 6 %, BC7 on 772 imports,
  goldens re-blessed). No REQUEST to handheld in rivet / world / perf. Starting item 5 (the Deck re-measure on world's
  BC7 commit) in a detached scratch worktree under my tmp (world's checkout untouched).
- 01:29 GATE the director reel, headless `--quit-after 16000 res://dev/arena/arena.tscn -- --rigs --bot=reel --reel=director`:
  top 19/19, tilt70 19/19, combo 19/19 chapters all down, 0 SCRIPT ERROR each (`evidence/n9h/it1/gates/`), on 956b8dea
  with the compact card and the glyph hint. (First launch went to the boot scene, which ignores --bot: killed my 3 PIDs.)
- 01:31 MILESTONE item 5 (BC7 re-measure, E16 in the LEDGER): world 3e02d3b8 vs this branch, the Deck row, city, iGPU,
  2 interleaved rounds, CONTENDED: GPU shared memory -48 % (1119 -> ~585 MB), render GPU p50 -11 % (8.7 -> 7.7 ms), both
  vsync-locked 16.6 ms. Scratch worktree removed.
- 01:33 GATE evidence run (`tools/evidence/run.mjs --no-bench`, 956b8dea): lint PASS, scenarios 54 PASS, parity PASS
  (mutation caught at 629), selftest PASS (look goldens 11/11, worst 0.27), release-compile 617/0 PASS; unit 1825 passed
  0 failed but marked FAIL "tree changed during run" (I appended JOURNAL mid-run). Re-run on a clean tree below.
- 01:36 Films on the iGPU at 40 px/m: city with the compact card (`deck-city-40ppm-compact-1280x800-igpu.mp4`), quest 1
  with the glyphs (`deck-quest1-40ppm-glyphs-1280x800-igpu.mp4`, the pad walker with `--gpu-index 1 --write-movie`);
  the set clip `n9-handheld-set-deck-40ppm.mp4` (64 s); `frames.json` 11 entries. Raw .avi deleted.
- Looked at: the LB hint glyph on the ghost card reads small (~20x11 px): the shoulder art is a short bar in a square
  cell (the asset lane flagged it). Fix next: per-cell scale (wide glyphs drawn by their ink box, not the cell).
- No REQUESTs to handheld from rivet / world / perf this iteration; none sent.

NEXT (iteration 2):
1. Re-check the clean-tree evidence run's result (started ~01:40, log `C:/Users/kazda/kiro/gtai-n9/tmp/handheld/evidence-run2.log`;
   copy the summary to `evidence/n9h/it1/`); if unit is green, item 1-4 gates are closed.
2. The shoulder / trigger glyph scale: trim each cell to its ink box in `PadGlyphArt` (or a per-cell scale table) so
   LB / RB / LT / RT read as large as the face buttons; re-shoot the quest 1 fold and the King card.
3. The glyph hint in the full card (desktop layout on a handheld with `hud: full`) and the boss cam: check that the
   King / Servo arenas honour `zoom_k` (Rivet looked small at 40 px/m in the King still: measure his px height).
4. Research loop: the Deck at 40 px/m: the combo view's framing at 1280x800; the 40 Hz row on world's BC7 (once on main).
5. REPORT.md at the 10:30 freeze: Calls (glyphs on the desktop too? the keyboard twin `ui_kb_glyphs_v1`; compact card
   on the desktop?), the exe line.
- 01:45 GATE clean-tree evidence run at b345645c: lint, unit 1825/0, scenarios 54, parity, selftest (goldens 11/11),
  release-compile 617/0: all PASS (`evidence/n9h/it1/gates/evidence-run-b345645c.txt`). NEXT item 1 done.
- 01:48 MILESTONE (NEXT item 2): the glyphs draw by each cell's trimmed ink box (`ui_pad_glyphs_v1.json` now holds the
  ink boxes, alpha > 24), fitted to the glyph height and at most 1.5x it wide (`PadGlyphArt.fit`): LB / RB / Start went
  from 0.48 g to 0.8 g tall. Looked at: `glyphs-deck-inkbox-title-prompt-card-crop-x2.png`. Owed: on the folded ghost
  card the LB glyph touches the Madness bar by ~1 px (move the bar 2 px down in the compact layout).
NEXT (iteration 2), updated: (2) done but the 1 px touch; (3) the boss cam's zoom at 40 px/m; (4) research loop; (5) REPORT.
- 01:51 The 1 px touch: compact Madness bar 104 -> 106, card 120 -> 122 (still 48 % of the full card's area); tests green.
  Not re-filmed (session end): the next iteration's first still should confirm the gap.
NEXT (iteration 2), final: (a) one still of the folded card to confirm the LB / bar gap; (b) the boss cam's zoom at
  40 px/m (Rivet looked small in the King stills: measure his px height vs the city); (c) research loop: the 40 Hz row
  and the combo framing at 1280x800 on main once world's BC7 merges; (d) REPORT.md at the freeze with the Calls
  (glyphs and the compact card on the desktop too? the keyboard twin `ui_kb_glyphs_v1`), and the exe line.

## Iteration 2 (BUILD), 01:51-02:51

- 01:53 READ: JOURNAL NEXT, the other journals: no REQUEST to handheld (world uses my `bc7_arm.mjs` for its BC7 step).
  Registry rules applied: on-device-verification-harness (numbers labelled "on the simulator", a probe that reads the
  live tree, cross-checked on pixels), adaptive-fidelity-tiers (a bigger text scale stays a row value / a Call).
- 01:57 (a) Still of the folded card (King, `--device=deck`, iGPU, quiet): the LB glyph now clears the Madness bar by
  ~5 px (`gtai-masters/n9/handheld/ghostcard-deck-lb-gap-fixed-crop-x2.png`). (b) The boss cam honours `zoom_k`: Rivet
  measures ~42 px tall in the King arena at 40 px/m = 1.1 m x ~38 px/m (he looks small because he is 1.1 m: rivet's
  1.65 m lands on its branch, ~66 px then). Nothing to fix on my side.
- 02:04 MILESTONE the runtime legibility probe (owed since d9, LEDGER section 6): `TextProbe` + `legibility_walk.gd`
  (quest 1 under `deck` on pad events: title, quest HUD, pause) measure each text's cap and x-height ink px from the
  glyph cache; the draw_string sizes from a reviewed table. Deck: nothing below 9 px under the strict x-height reading
  (smallest: the boss count x 9 / cap 12, the 18 px texts x 10 / cap 13); every cap >= 12. Matches the pixels of the
  King still. Commit 8ea46cd4 (debt ratchet: dev_loc +241 accepted with a reason).
- FRICTION: a `-s` SceneTree script cannot name autoloads (`Log`) at compile time: split into a launcher + a Node
  walker (the pad walker's pattern). Headless GUT's window is ~64x40, so the viewport stretch reads 0.05: the probe
  takes the stretch as a parameter in tests.
- 02:12 MILESTONE E17 (LEDGER section 8): `deck` 60 vs `deck40` at 40 px/m, city, iGPU, 3 interleaved rounds, bench lock
  held, all CONTENDED: GPU busy per second -30 % (54 -> 37 %), pinned CPU -24 %; confirms d9's E5 at the new zoom.
  FRICTION: `ab.mjs` ignores `--out` (writes `evidence/sim/<name>/`): moved by hand to `evidence/n9h/it2/e17/`.
- 02:15 Legibility on the other rows: `handheld_1080` all >= x 12; `switch_handheld` (base x 0.9) the boss bar count
  "1 / 3" draws at 14 px = x 8 / cap 10 (digits only: its smallest character is the cap, 10 px); everything else >= 9.
  The walk now scales the draw_string table by the window stretch. Commit 4723a988.
- 02:17 Research: Valve's "SteamOS Compatible" label (May 2025) is derived from the Deck review, pass/fail, no extra
  testing: the Deck review gates every SteamOS handheld (LEDGER section 1, sources).
- frames.json (gtai-masters/n9/handheld): 13 entries; added the card-gap crop and the probed pause card (it replaces
  the it1 pause still, file deleted, LEDGER reference updated).
- No REQUESTs to handheld in rivet / world / perf this iteration; none sent.

NEXT (iteration 3):
1. The keyboard twin `ui_kb_glyphs_v1` as an owner Call: refactor `PadGlyphArt` into a glyph set (atlas + cell map;
   the kb map: "W A S D" -> move_keys, "mouse" -> aim_mouse, E / F / Q / Esc / Space / Shift -> key_*), drawn on the
   desktop only behind a study row or flag (desktop default unchanged); trim the kb cells to ink boxes like the pad's;
   stills of the title card and the quest 1 prompt; provenance line. Gates: lint, full unit, reel x3.
2. The Switch-class 720p boss count (x 8): an owed note or a row-level text scale; decide by a still.
3. Re-take E16 (BC7) under the bench lock once world's commit is on main; the combo framing at 1280x800 on main.
4. REPORT.md at the freeze: Calls (kb glyphs on the desktop? a larger handheld text scale? the 40 Hz battery row as
   the Deck default?), the exe line, frames.json check.
- 02:20 FRICTION (fixed): `sim.mjs --grab` found my process but copied the screen rectangle, so another lane's quest 1
  window lying over mine was saved as "the King on switch_handheld" (caught by looking: keyboard prompts, wrong scene).
  `grab_window.ps1` now reads the window itself with PrintWindow (PW_CLIENTONLY | PW_RENDERFULLCONTENT), the screen
  copy only as the fallback; re-grabbed: the right window. The it1 / it2 deck stills were checked: they show the
  compact card (this branch only), so they are mine. Commit 128c925e.
- 02:21 The Switch-class 720p boss count judged on the re-grabbed still: "1 / 3" reads at ~10 px digits: no change.
- 02:23 Gates this iteration: lint 15/15, full unit 1829/0, tools/handheld node tests 6/6. No shipped code changed in
  it2 (dev probe, a test, the grab script, docs), so the reel / evidence gates of it1 (b345645c, 956b8dea) still stand.

NEXT (iteration 3), refined for item 1 (the keyboard twin): the desktop labels come from `ObjectiveHint.key_name`
(`OS.get_keycode_string`, "LMB" / "RMB") and `with_keys(..., false)` ("[W A S D]", "[mouse]"); the kb cell map:
"W A S D" -> move_keys, "Up Left Down Right" -> move_arrows, "mouse" -> aim_mouse, LMB / RMB -> mouse_left / _right,
E F Q R G P -> key_*, Escape -> key_esc, Space / Shift / Ctrl / Tab -> key_*, 1-4 -> key_1..4. The title card would
use `with_keys(CONTROLS_PAD, false)` when the kb glyphs are on. Gate it off by default (a devices.json field on a
desktop study row, or a launch flag in KNOWN_FLAGS); the desktop default must not move.
