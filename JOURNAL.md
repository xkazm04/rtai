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
