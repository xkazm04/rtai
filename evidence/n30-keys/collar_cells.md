# p55 sprint collar per cell at 2x: row 3 cell 1 (n30-01)

Brief `evidence/briefs/n30-01-collar-cell-r3c1.md`. Sheet `project/features/characters/art/view/p55/rivet_run8.png`
(8 x 8 cells of 209 x 199 px, rows 1-based). Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md`,
`jobs.json`, `refs/`, `out/`, `comp/`, `scripts/`). **IMAGES 1** (one job, no retry). Result: **row 3 cell 1 rigid,
installed** in `bf7b78fd6`.

## Method
- `scripts/cell_job.py <row> <col>`: the target cell at 2x **NEAREST** (exact pixel doubling, so 0.5 BOX undoes it)
  centred on a 1024 x 1024 `#00B140` canvas (offset 303, 313 in `refs/r3c1_2x.json`), row 4's cell of the same column
  (same gait phase) on the same canvas as image two, a 4x NEAREST crop of row 4's collar as image three; appends the job
  to `jobs.json`. The prompt names the fault (twisted rope / knitted scarf / rounded tube / crescent stripes), asks for
  image two's ring width at this scale, a crisp dark outline on straight top and bottom edges, straight parallel diagonal
  vermilion/near-black stripes, flat shading, every other pixel unchanged, no yellow/red/teal/green.
- `scripts/cell_comp.py <row> <col> <raw> <base> <out>`: key the green; place the raw on the job canvas by the best
  alpha IoU of identity / stretch / centre crop / bbox fit (the job came back **1254 x 1254**, not 1024: bbox fit, IoU
  0.983); cut the 2x cell, 0.5 BOX; register to the shipped cell by alpha IoU (shift +-6, scale 0.97-1.03), then
  +-2 px by seam cost as n29 `tp_comp.py`; mask = shipped rope hull | edited collar hull, filled, clipped to the
  shipped alpha; edited RGB inside the mask (alpha > 128, teal-cast px left as shipped); alpha kept. Writes the sheet,
  `<out>.json` proof, `<out>.cell.png`, `<out>.judge4x.png`. Self-test on the 2x ref itself: 7 edge px change, 0 outside
  the mask.

## Proof (`comp/r3c1.png.json`)
Alpha IoU 0.990, scale 1.0, alpha shift (0, 0), seam shift (0, 0), seam 25.2 (n29 row 8 transplant: 37-55), holes 0,
over head 6 px. Mask 520 px, all 520 edited (none kept as shipped). **Changed 520 px, changed outside the mask 0, alpha
identical, the other 63 cells bit-identical, teal in mask 0**; changes in y 87-114 of the cell (soles untouched).
Mask colours: orange median 247, 87, 4 (row 4 band 227-241, 85-92, 12-31: about 6 redder, 8 less blue), dark median
17, 3, 2 (row 4 band 19-36, 5-16, 3-12: slightly darker). Sheet sha256 `d8aa151a271e40f9e79b5df29f453e5c1914726d6f47ebd156b3d864050c599a`;
Godot `--import` reimported it, the `.import` did not change.

## What I saw
- 4x (`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/r3c1_4x.png`, shipped | candidate | row 4 cell 1): the soft
  orange rope with faint curved stripes is now a flat ring of constant width, dark outline on straight top and bottom
  edges, five straight parallel vermilion/near-black diagonal stripes: the same read as row 4. Helmet, visor, hose arm and
  fist untouched; no seam at either end. Minor at 8x only: under the ring's left end the old rope area is filled with the
  edit's muted shoulder tone, and the ring's right end keeps the rope's slight downward angle.
- 64 px/m (`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/r3c1_64_ingame.png`, before | after, 2x crop + 4x neck):
  `evidence/n29-keys/films/run_hands.py` runs `runs/r3c1_before_64` (HEAD `5114a4441`) and `runs/r3c1_after_64`. The
  harness shows sheet row 3 (0-based 2) at tick 88 (walk beat 0 at 6.75 m/s, **column 1**, the run8 sheet) and tick 1048
  (sprint beat 8 at 9.3 m/s, **column 5**, unchanged). Frame diff (threshold 8) over all 16 ticks: only tick 88 differs,
  653 px in x 917-978, y 437-463 (the neck); the other 15 ticks 0 px, so the import was fresh. The still is tick 88:
  after reads as a stiff striped collar, before as the soft scarf.

## Not done
Drift not re-measured (alpha identical, changes in y 87-114, so the sole band the n27 measure reads cannot move). The
other 25 cells (row 3 c2-c8, rows 6 and 7) are the round STATE `NEXT`.

## Commits
`bf7b78fd6` sheet + provenance line (`steam/ai-provenance/2026-11.jsonl`); hook lint 18 checks passed;
`node tools/gate/quick.mjs`: no changed .gd, no merge clash with n30-cast/combat/yard.
