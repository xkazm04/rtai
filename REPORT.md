# REPORT lane keys, run n29 (2026-11-25 01:15 to 09:15)

Branch `n29-keys` from `main` `c649a15d6`; worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`. Builders: Claude sub-agents
started from the director's session (Sonnet for wiring/evidence, Opus for art rounds). Final gate: `node tools/gate/run.mjs --rev=HEAD --reels` on `cbca1a8c9` (all code and art; later commits are docs and evidence only), 06:13 to 06:52: **`gate: PASS`**: PASS lint (19 checks, 2269 files), PASS unit-tests (4238 passed, 0 failed, 2 skipped), PASS scenario-tests (68 passed), PASS parity (bit for bit, mutation caught at step 629), PASS selftest, PASS export-audit (997/0), PASS reels (exit 0); `build/gate/cbca1a8c991f/gate.json`. Run before the 08:45 freeze on purpose: the lane's code and art froze at `e553b6b9e` (06:12), and reels started after 08:45 would end past 09:15. The earlier no-reels gate on `5d956b26e` also passed (`build/gate/5d956b26e27f/gate.json`).
Films and stills: `C:\Users\kazda\kiro\gtai-masters\n29\keys\` (`frames.json`, best first). Images 58/60.

## What works

1. **Gauntlet HUD** (`24fc9c4c3`, tests `568f99552`): the "ATTACK CLAW" box was the bot film's action caption, anchored
   bottom-left over the ghost chip strip; it now sits bottom centre with centred text (`1dcbdd09c`), 0 px overlap with the
   strip at 1080p. Chip number plates are anchored inside the strip's plate and at least 8 px from the screen edge on both
   layouts: chip 1 plate left edge x 7 -> 15 px at 1080p (strip plate starts at 12: the 5 px overhang is gone); in the compact
   layout slot 0 started at x -1.5 (off screen) before. Same-tick pair `hud/hud_pair_1080.png`,
   `hud/hud_pair_same_tick_crop_3x.png` (bond_film_64 seed 1 prefill 16, tick 619, before at `c649a15d6`); the n28 frame pair
   with the caption: `hud/hud_pair_crop_3x.png`. Mutate `ghost_chip_number.gd` lines 26-29: 3/7 -> 7/7 after the anchor tests.
   Handheld (deck 1280x800, compact layout), same tick, from two snapshots whose dev capture accepted the window size
   (product code untouched; `b9c5769bb`): chip 1 plate left edge about -4 px (cut by the screen) -> 9 px, all four plates inside
   the strip; `hud/hud_handheld_pair_crop_3x.png`, `hud/hud_handheld_before.png`, `hud/hud_handheld_after.png`.
   Evidence `evidence/n29-keys/hud.md`.
2. **Plasma sword walks and runs on its own p70 grids, the katana as donor** (walk `3dbef1803`, run `d72d49bd8`; 16 image
   edits, one row per job; row 1 judged first at 64 px/m against the katana and the stop-gap): amber blade in one claw with a
   guard, flat striped collar, the katana's legs. foot_slide 32 px/m walk hold 1.00/1.56 cm (bar 2) PASS; run step
   8.29/9.38 cm (bar 7 mean; the katana donor itself 7.76/9.15). Grids `sword/grid_plasma_sword_64.png`, `_32.png`;
   evidence `evidence/n29-keys/grid_plasma_sword.md`. Clip `sword/plasma_sword_32.mp4` (1920x1080 60/1, 921 frames, 15.35 s): stop-gap | n29 | katana at 32 px/m over the n29 64 px/m tile (samples held 1 s).
3. **Gloria's own walk and run set** (walk `eac8b4e34`, run `ba764e395`, evidence `87e3573a4`; image edits of the pistol's
   sheets, one row per job, brass gun as drawn in n28): `walk_grid.by_weapon.gloria` removed (her own sheet plays first), the
   old long-gun run sheet removed. foot_slide 32 px/m walk hold 0.36/1.56 cm (pistol 1.20), run step 6.54/9.71 cm (pistol
   6.10/8.71); walk cycle 74.7 vs the pistol's 76. Her p55 held strips in brass (`7bb6f9cc0`, `b9ca6bf36`) and the left p70
   strip re-cut so cells 2 and 3 keep the whole muzzle (`7b918750e`, cells 191 -> 215 px, muzzle tips re-measured).
   Clip `gloria/gloria_walk_32.mp4` (1920x1080 60/1, 16.52 s); grids `gloria/grid_gloria_64.png`, `_32.png`;
   strips `gloria/p55_strips_4x.png`, `gloria/gloria_left_p70_cells.png`. Clip beside the pistol `gloria/gloria_vs_pistol_32.mp4` (1920x1080 60/1, 921 frames, 15.35 s): stop-gap | n29 | pistol. Her p55 diagonal flash drawn whole on 224 px cells (`9efd28136`: `RivetGunDiag.HELMET_X["p55/gloria"]` 112.5/79.5/110.0/141.0 = measured +14, body within 1 px per cell, flash scale 1.0 where it was 0.91/0.70): `gloria/p55_diag_flash_64.png` (strip composite as `RivetGunDiag.seat` seats it, not a game capture: `arsenal_turn` has no Gloria attack).
4. **p55 sprint collar, row 4** (`802ecb0c0`): a rigid flat ring with straight vermilion/black stripes, neck-only composite
   (29,057 px changed, 0 outside the neck masks, other rows bit-identical: `evidence/n29-keys/collar_p55_row4_proof.json`);
   `collar/collar_p55_row4_neck_3x.png`. **Row 8** (`56cb77065`, `e553b6b9e`): row 4's shipped rigid collar, mirrored (row 8 is
   the same back-left facing seen from the other side), registered per cell and composited neck-only, 0 images: 5,878 px
   changed, 0 outside the mask, alpha identical, rows 1-7 bit-identical, drift 3.83 cm unchanged
   (`evidence/n29-keys/collar_p55_transplant.md`); `collar/collar_p55_rows68_neck_4x.png` (shipped above new) and
   `collar/collar_p55_all_rows_64.png` (all 8 facings at 64 px/m, before row above after). Rigid now: rows 1, 2, 4, 5, 8. Row 8 in game at 64 px/m, the same tick: `collar/collar_p55_row8_before_after_64.png` (rope -> black/vermilion stripes on a flat ring); clip with rows 4 and 8 `collar/collar_p55_32_r8.mp4` (1920x1080 60/1, 962 frames, 16.03 s, before | after; `bcac5c1fb`). Row 4 in game at 64 px/m, the same tick: `collar/collar_p55_before_after_64.png` (pale soft band -> black/vermilion stripes on a flat ring, body identical); p55 sprint drift 3.83 cm before and after (bar 3.83 +- 0.1); clip `collar/collar_p55_32.mp4` (1920x1080 60/1, 962 frames, 16.03 s, before | after). Films `evidence/n29-keys/films.md`.
5. **Combat's NEED keys served** (red audit rows 12 and 15): the molotov's lit rag and torch flame amber in the item art
   and in Rivet's strips (`0b6814366`, `baf0b209d`, `65578a4be`; held 5860 -> 23 reddish px, pickup 5457 -> 0, 0 px changed
   outside the masks, collar excluded and looked at): `rag/`. The plasma sword's hilt rings steel in Rivet's 12 strips
   (`0906b2f7c`, 0 px outside the mask): `sword_rings/rings_cells_4x.png`. Row 16 (127 weapon item/held files) triaged:
   `evidence/n29-keys/held_red/table.md` (21,610 true-red + 56,649 vermilion px), contact sheet `held_red/contact_4x.png`; the
   crate p70 plank red -> amber wood (`ad4b1377d`, 4371 px, 0 outside the mask); rust speckle and chainsaw marks left.

## What does not

- **p55 collar rows 3, 6, 7 still wear the twisted rope.** Each failed two one-row image edits (rope kept, muddy scarf,
  teal tint, knitted scarf, crescent stripes on a tube); row 6 also failed the mirrored transplant from row 2 (row 2's collar
  sits higher on the chin and crosses the visor: `collar/collar_p55_rows68_neck_4x.png`, top block); rows 3 and 7 are the
  profiles and have no rigid mirror donor. Row 8 at 4x keeps small faults (cell 4 a 2-3 px notch at the helmet, cell 8 a
  light streak). Rejects in `collar/collar_p55_row{3,3b,6,7,8,8b}_rejected_3x.png`,
  `collar/collar_p55_row8b_vs_row4_mirrored_6x.png`. Per the two-routes rule the image route is closed: see Calls.
- Plasma sword run step 8.29 cm against the 7 cm bar (the katana donor's legs: 7.76). One `run_row_k` value cannot fix it:
  a sweep on the lane's octant (`p70/plasma_sword/2`, k 0.94/0.97/1.03/1.06) gave 8.27/8.23/8.31/8.28 cm (`3a758e990`,
  `evidence/n29-keys/grid_plasma_sword.md`); the two planted steps are set by the drawing. Nothing changed in the table.
- HUD at handheld size (not on this branch): chip 1's plate is on screen but clamped right, 3 px from plate 2: it reads
  "12" crowded (`hud/hud_handheld_pair_crop_3x.png`, right half; seen at 07:03, after the last-commit bar). The fix is built
  and tested but NOT applied: `evidence/n29-keys/hud_compact_gap.patch` (`8df5e2302`; see Merge notes). The 1280x800 still
  needed a dev-only capture edit in a snapshot (`bond_film_capture.gd:38` takes only 1920x1080; `--device` missing from the
  gauntlet's `KNOWN_FLAGS`): NEED Director/combat.
- Item 5 (molotov run, stop-gap back-swing): not started; images at 58/60.
- Cast's n28 NEED (the dropped rifle reads mauve-pink): measured, no change. A dropped guard rifle draws
  `showcase/p70/assault_rifle.png` (stock brown wood, hue 26), not `ground_rifle_70.png`; the pink in the 1080p film is the
  brightest grain plus yuv420 chroma on grey (`ab9e1ebe8`, `evidence/n29-keys/ground_rifle.md`, `ground_rifle/before_p70_4x.png`).
- Combat's red audit row 16: only the crate plank recoloured; the rest is a Call (design colours, vermilion danger-or-heat).

## What blocked or slowed you (minutes each)

- Image jobs that never returned (codex 900 s timeouts, files stuck before `out/`): about 45 min of builder time over the night.
- Mutate baseline `--import` timed out at 647 s under load (session 1): 11 min, re-run later.
- `tools/gate/quick.mjs` Godot parse check failing on untouched committed files (`cut_rig.gd`, `test_rivet_windup.gd`): about 5 min.
- Codex image jobs stalling on the copy to `out/` (hand copy each time): a few minutes per job.
- Shared Godot: two builders on one lane Godot through a mutex file (`build/n29-godot.lock`): no clash, some waits.

## Calls for the owner

1. **The p55 collar rows 3, 6, 7**: hand repaint along the shipped centreline using row 4's stripe pattern, or a per-cell
   edit at 2x? Image edits of one row failed twice on each; row 8 was fixed by a mirrored transplant of row 4, which does not
   fit row 6 (from row 2) or the profiles. Stills: `collar/collar_p55_all_rows_64.png` (where the sheet stands),
   `collar/collar_p55_rows68_neck_4x.png`.
2. **Gloria's run row 5 slide factor** `run_row_k p70/gloria/5` 0.64 (own stride vs the bare run; the pistol has no entry): one
   value to drop if her sprint should match the pistol's exactly.
3. **Plasma sword run step** 8.29 cm vs the 7 cm bar: inherited from the katana's legs (no `run_row_k` value fixes it, swept);
   a redraw of the katana's run legs would fix both.
5. **The dropped rifle in video**: its stock is brown wood (no colour-law break); lower its saturation 0.6 -> 0.45 only if
   it should read calmer in encoded films (`ground_rifle/before_p70_4x.png`).
4. **Weapon item art red (combat's audit row 16)**: the mini-nuke's plum-maroon casing and the homing shard's red-orange
   hoses are design colours spread over the whole part, not a one-part mask: keep, steel/amber, or redraw? Contact sheet
   `held_red/contact_4x.png` (#3, #4, #5, #7, #8, #9). The 56,649 vermilion px (ray gun, electro gun, rocket launcher, mini-nuke
   held) need a danger-or-heat call per weapon.

## Merge notes

- Files: `project/features/characters/art/view/{p55,p70}/rivet_*` sheets and strips, `rivet_motion.json` (`run_row_k`,
  `walk_grid.by_weapon.gloria` removed), `rivet_muzzle.json` (gloria rows), the HUD files (`ghost_chip_number.gd`,
  `gauntlet_bot_film.tscn` caption), weapon item art for the molotov (held/pickup/held_55), tests pinning those, decision lines
  (append-only), `steam/ai-provenance/2026-11.jsonl` (append-only).
- Combat recoloured the plasma sword's own held art (rings) in its lane; this lane did Rivet's strips: no file overlap.
- Root `JOURNAL.md` / `REPORT.md`: keep each lane's own on the add/add conflict.
- **Optional, the handheld HUD fix as a patch** (built after the freeze, so not committed as code): `git apply
  evidence/n29-keys/hud_compact_gap.patch` changes `GhostFormLayout.compact()` gap 42 -> 50 and adds
  `test_adjacent_number_plates_keep_a_gap_and_the_first_clears_the_minimum` to `project/tests/unit/test_ghost_chip_number.gd`.
  Proven in a snapshot of `a4608d655`: the test fails on n29 code (plates 1 and 2 2.6 px apart) and passes with it (20/0 over
  chip number, layout, hud tests); gdformat/gdlint clean. 1280x800 frame 20: plate 1-2 gap 3 -> 15 px, strip 32 px wider,
  every plate inside the strip; desktop unchanged (only `compact()` edits). Still: `hud/hud_handheld_gap_patch_crop_3x.png`.
  Apply with a `docs/decisions.md` line (compact gap 42 -> 50; option B `number_dx` rejected). Combat's files are untouched.

## Next steps

1. The p55 collar rows 3, 6, 7 by the owner's pick (hand repaint from row 4, or 2x per-cell edits); row 8's 4x touch-ups.
2. The molotov's own run set (one row per job, the donor's soles fixed by registration); the stop-gap back-swing.
3. Combat's red audit row 16 after the owner's call: the per-weapon danger-or-heat list from `evidence/n29-keys/held_red/table.md`.
4. The compact (handheld) HUD: apply `evidence/n29-keys/hud_compact_gap.patch` if the Director did not at merge (Merge notes), run the quick gate and mutate `ghost_form_layout.gd` on the compact lines.
5. Gloria's p55 diagonal flash in game (needs a dev scene that fires Gloria at p55; `arsenal_turn` has none).

## Builder ledger

| call | model | minutes | result |
|---|---|---|---|
| n29-01-hud | sonnet | 28 | accepted (caption + plates, test) |
| n29-01b-hud-evidence | sonnet | 27 | accepted (same-tick pair, decision lines, mutate 3/7) |
| n29-01c-hud-anchor-test | sonnet | 8 | accepted (mutate 7/7) |
| n29-01d-hud-handheld | sonnet | 2 | bounced: the capture is 1080p-only, not this lane's file |
| n29-02a-sword-row1 | opus | 18 | accepted (row 1 judged at 64 px/m) |
| n29-02b-sword-rows | opus | 57 | accepted (walk sheet, run rows 1-3) |
| n29-02c-sword-run | opus | 30 | accepted (run rows 4-8, wired) |
| n29-03a-gloria-rows-prep | opus | 44 | accepted (prep) |
| n29-03c-gloria-rows | opus | 60 | accepted (prep, walk 8/8) |
| n29-03d-gloria-run-wire | opus | 26 | accepted (walk + run wired) |
| n29-03b-gloria-strips | opus | 30 | accepted (p55 brass, left p70) |
| n29-09-gloria-diag-flash | sonnet | 24 | accepted |
| n29-04c-collar-rows | opus | 44 | accepted-partial (row 4; 3/6/7 rejected) |
| n29-04d-collar-row8 | opus | 6 | accepted rejection (2 images, rope) |
| n29-05-molotov-rag | sonnet | 4 | bounced (missed two files) |
| n29-05b-molotov-rag-strips | sonnet | 15 | accepted |
| n29-06-sword-rings-strips | sonnet | 9 | accepted |
| n29-07-held-red-triage | sonnet | 3 | accepted (table, 1 file) |
| n29-08-films | sonnet | 41 | accepted (3 clips, collar still, drift) |
| n29-11-sword-run-k | sonnet | 9 | accepted rejection (sweep, none passed; my brief named the wrong octant key) |
| n29-12-ground-rifle-stock | sonnet | 3 | accepted (no change needed; my brief named the wrong file) |
| n29-10-collar-transplant | opus | 12 | accepted (row 8; row 6 rejected) |
| n29-13-collar-row8-film | sonnet | 3 | accepted (row 8 still + clip) |
| n29-01e-hud-handheld-snapshot | sonnet | 5 | accepted (1280x800 pair from snapshots; showed the crowded plate 1) |
| n29-14-hud-compact-gap-patch | sonnet | 5 | accepted (patch + failing-then-passing test in a snapshot, 1280x800 still) |

25 calls, about 513 builder minutes; 2 bounced. Images 58/60. What I would brief differently: check that the capture
tool supports the size before briefing a still (the handheld call); give the collar its in-game before|after in the same
call as the art, not a later films call; for an art item that already failed in n28, budget the owner call from the start
instead of a third route; look up which file and key the game actually reads before naming them in a brief (two
session 5 briefs named the wrong ones; both builders caught it).
