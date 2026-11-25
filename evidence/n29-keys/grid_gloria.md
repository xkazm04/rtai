# Gloria at tilt 70: own walk and run grids (pistol donor), n29-03

Owner's pick: "Gloria's own walk and run set". Until now she walked on the bare stride with the brass gun on the palm (`walk_grid.by_weapon.gloria: "bare_claw_p70"`). Both grids were made by image edits of the pistol's p70 sheets, one row per job. The brass gun is drawn as on the n28 strips, held in one claw, with the other claw free.

## Commits
- `eac8b4e34` "keys n29: Gloria walks on her own p70 grid (pistol donor)". It contains:
  - `rivet_walk_eq_gloria.png` (732x1512, the pistol size), which replaces the old long-gun walk.
  - `git rm` of the old long-gun `rivet_run8_eq_gloria.png` and its `.import`. Only `evidence/arsenal/matrix_after_11.json` and provenance named it.
  - In `rivet_motion.json`, `walk_grid.by_weapon.gloria` is deleted. Her grip `one_hand` maps to family `pistol`, which is not `gloria`, so her fallback is `bare_claw`. The doc's n27 note was retexted.
  - The old gloria `armed_cycle_cell` 86.7, `run_row_k` `p70/gloria/{0,3,4}` and `walk_profile_travel` 26, 32.5 were dropped with their 5 pins. They were replaced by 74.7 (pistol 76.0) and 22.0, 32.0.
  - `test_rivet_walk_held_only.gd` was rewritten to the new truth:
    - she is not held-only at p70;
    - she walks on `rivet_walk_eq_gloria.png`;
    - p55 is untouched;
    - the pistol keeps its grid;
    - the cold start reads the table.
  - Provenance line.
  - Tests: `run_unit --select` (every_weapon, held_only, grid_stride, sprint_fallback) gave 24 passed. `--changed` gave 926 passed, 0 failed.
- `ba764e395` "keys n29: Gloria runs on her own p70 grid (pistol donor)". It contains:
  - `rivet_run8_eq_gloria.png` (1552x1568, the pistol size, rows at s0.95) and its `.import`.
  - `run_row_k` `p70/gloria/5` 0.64 and its pin. Row 8's own travel is 29.67 against 46.5 for the bare run, under the own-vs-bare rule. The pistol donor's row 8 measures the same 29.67 and has no octant-5 entry. **The director should check this one value.**
  - The held-only test pins her sprint to her own run8.
  - Provenance line.
  - Tests: `--select` 24 passed, `--changed` 1158 passed, 0 failed.
- Neither commit touches code, so no mutation run was made.
- `quick --no-godot` was ok on both test files. The hook's lint passed 19/19 both times.

Round: `C:/Users/kazda/kiro/gtai-art/rivet-n29/gloria_walk/` (`STATE.md`, `jobs.json`, `scripts/`, `keep/`, `final/`).

## Walk rows (s1.0; bars from `scripts/prep_row.py`, sole x from `scripts/solex.py`)

| Row | dome w | dome x | sole y | sole x max | leg IoU min | lead | travel own / donor | tone post | tries | note |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 0.73 % | 1.91 % | 1 | 1.5 | 0.874 | 4/4 by soles | -18.33,18.33 / -18.67,18.67 | 0.04 | 1 | muzzle squeezed inside the cell (`muzzle_in.py`) |
| 2 | 0.0 % | 1.72 % | 2 | 1.2 | 0.865 | 3/4 (col 2 near zero, boots match by eye) | 26.0,-26.0 / 26.33,-26.33 | 0.04 | 1 | |
| 3 | 0.68 % | 3.0 % | 2 | 2.2 | 0.926 | 4/4 | 45.33,4.0 / 44.0,4.0 | 0.08 | 2 (try 1: codex timeout) | |
| 4 | 0.0 % | 1.77 % | 2 | 1.5 | 0.902 | 4/4 | -34,34 / -32.67,32.67 | 0.04 | 2 (try 1: stopped at the cut-off) | |
| 5 | 0.0 % | 0.75 % | 1 | 0.5 | 0.964 | 4/4 | 18,-18 / 18.33,-18.33 | 0.05 | 3 (timeout; gun cut at the right edge; short-gun retry) | |
| 6 | 0.0 % | 1.52 % | 0 | 1.5 | 0.960 | 4/4 | -16,16 / -15.33,15.33 | 0.26 | 2 (try 1: gun cut at the left edge) | |
| 7 | 0.0 % | 1.37 % | 2 | 0.9 | 0.939 | 4/4 | 29.33,36 / 30,36 | 0.03 | 2 (try 1: gun cut at the left edge) | muzzle squeezed inside |
| 8 | 0.0 % | 0.8 % | 2 | 0.5 | 0.930 | 4/4 | -13,13 / -13.33,13.33 | 0.06 | 2 (try 1: timeout) | muzzle squeezed inside |

## Run rows (s0.95)

| Row | facing | dome w | dome x | sole y | sole x max | leg IoU min | lead | travel own / donor | tone post | tries | fit |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | front | 1.47 % | 1.11 % | 2 | 0.5 | 0.932 | 8/8 | 2.0,4.33 / 1.67,4.0 | 0.08 | 1 | FITH=1 FITMIX=0.7 |
| 2 | front right | 1.56 % | 2.14 % | 2 | 1.0 | 0.946 | 8/8 by soles | 46.67,48.33 / 46.33,48.67 | 0.03 | 2 (try 1: cell 8 leaned, dome x 15 %) | FITH=1,8 FITMIX=0.4 |
| 3 | right | 2.9 % | 2.99 % | 2 | 1.5 | 0.850 | 8/8 | 70,65.33 / 69,65.33 | 0.28 | 1 | FITH=2,4,5,8 FITMIX=0.7 |
| 4 | back right | 0.0 % | 1.48 % | 2 | 1.5 | 0.952 | 8/8 | -2.67,2 / -2.33,2 | 0.06 | 1 | plain |
| 5 | back | 0.72 % | 0.72 % | 2 | 1.0 | 0.947 | 8/8 | 3,-2.67 / 3.67,-2.67 | 0.03 | 1 (short-gun prompt, right edge) | plain |
| 6 | front left | 1.61 % | 1.84 % | 2 | 1.5 | 0.949 | 8/8 | 45,44.67 / 45.67,45.67 | 0.03 | 1 (short-gun prompt) | FITH=4 FITMIX=0.7 |
| 7 | left | 0.79 % | 1.15 % | 2 | 1.0 | 0.939 | 8/8 | 62.67,64.33 / 62.33,64.67 | 0.02 | 1 (short-gun prompt) | plain |
| 8 | back left | 2.34 % | 0.83 % (col 5: 0 after the seam) | 2 | 0.5 | 0.952 | 8/8 | -13.0,46.33 / -13.33,46.0 | 0.1 | 2 + seam | FITH=1,2,3,5,7 FITMIX=0.7 |

**Row 8 needed a seam.** Both tries drew cell 5 with a different lean:
- try 1: dome x 7.08 %, sole x -4.4 px;
- the retry: dome x 3.41 %, sole x -2.1 px.

Following the brief's route for a row that fails twice, cell 5 takes the pistol's legs under a seam (`scripts/seam_cell.py`: the `fix_row1.py` blend, seam at 0.82 of the donor figure height, feather 6). The other 7 cells are the retry's. At 3x the seam is not visible (`rivet-n29/gloria_walk/tmp/seam8_cmp.png`).

Eye check (4x, every row):
- a brass Gloria in one claw, the other claw free;
- no pistol remnant;
- a flat, rigid, striped orange and black collar;
- no teal (0 px in every row).

The red pixel counts are the dull rust shading on the legs, mean about (114, 54, 43); there is no red element.

The gun-hue median of the pixels that differ from the donor reads 29-37°. It is diluted by the fringe, because the brass sits where the pale pistol was. The gun is brass by eye.

## foot_slide

Legs film, turn_090 lane, row 0, 32 px/m, in cm. Files: `gtai-masters/n29/keys/gloria/grid_{gloria,pistol}_foot_slide_32.json`.

| | Walk hold mean / max | Walk step mean / max | Run hold mean / max | Run step mean / max |
|---|---|---|---|---|
| Gloria (own walk + own run8) | 0.36 / 1.56 | 21.45 / 24.43 | 0.89 / 1.56 | 6.54 / 9.71 |
| Pistol (donor) | 1.20 / 1.56 | 22.17 / 26.59 | 0.67 / 1.56 | 6.10 / 8.71 |

Walk hold 0.36 cm is under the 2 cm bar (pass). Run step mean 6.54 cm is under the 7 cm bar (pass), 0.44 above the pistol's. The run step max (9.71) is over 7 cm; so is the pistol's own max (8.71). Those are donor legs, so this is a family number. In the turn_090 lane (octant 0), `run_row_k` is 1, as for the pistol.

## Stills and clip
- Composites, built from the shipped sheets at in-game size: `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/grid_gloria_64.png` (1680x9592) and `grid_gloria_32.png` (904x5160). They show walk 8 facings x 4, then run 8 facings x 8, each as stop-gap | new | pistol.
- Row judge crop: `gtai-masters/n29/keys/gloria/walk_rows_judge_64.png`.
- Legs film: `gtai-masters/n29/keys/gloria/grid_{gloria,pistol}_arena/rows/`.
- In-game candidate: `grid_gloria_arena/candidate_32/` (991 frames) and `candidate_64/` (16 samples). This is `capture28.py gloria candidate`: the boulevard, the 8-direction lap at walk, then at sprint, tilt 70, `--fixed-fps 60`.
- Clip: `C:/Users/kazda/kiro/gtai-masters/n29/keys/gloria/gloria_walk_32.mp4`, from candidate_32. ffprobe: h264, 1920x1080, 60/1, 991 frames, 16.52 s, 41.3 MB.
- Stills: `gloria_walk_32_stills.png` (t250 walk | t800 sprint).
- The 64 px/m capture is samples only, not a clip.

IMAGES: over n29-03a/c/d, 5 + 12 + 9 = 26 launched and 22 received. The other 4 were 3 codex timeouts and 1 job stopped at a cut-off. This call (n29-03d): 9 launched, 9 received.
