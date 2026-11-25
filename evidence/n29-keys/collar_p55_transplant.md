# p55 sprint collar rows 6 and 8 by mirrored transplant (n29-10)

Brief `n29-10-collar-transplant`. 0 image generations. Sheet `project/features/characters/art/view/p55/rivet_run8.png`
(8 x 8 cells of 209 x 199 px). Scripts in `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/scripts/`
(`tp_pairs.py`, `tp_comp.py`, `tp_judge.py`, `tp_64.py`; masks from `neck.py`), log in that folder's `STATE.md`.

**Result: row 8 fixed (from row 4 mirrored), row 6 rejected (stays the twisted rope).** Rows 3, 6, 7 still wear the rope.

## Step 1: pairs

Alpha IoU of the target cell vs the horizontally mirrored donor cell after the best integer shift (+-14 px), on the
head-shoulder band (top 42 % of the target figure); full-figure IoU at the same shift for reference.

| Target <- donor (mirrored), phase | Mean band IoU | Min band IoU | Mean full-figure IoU | Per cell band IoU (k1..k8) |
|---|---:|---:|---:|---|
| row 6 <- row 2, k | 0.912 | 0.889 | 0.745 | 0.889 / 0.921 / 0.894 / 0.924 / 0.935 / 0.904 / 0.899 / 0.928 |
| row 6 <- row 2, k+4 | 0.905 | 0.881 | 0.736 | 0.904 / 0.924 / 0.884 / 0.936 / 0.881 / 0.899 / 0.895 / 0.920 |
| row 6 <- row 4, k | 0.845 | 0.773 | 0.665 | 0.826 / 0.855 / 0.773 / 0.860 / 0.851 / 0.869 / 0.830 / 0.892 |
| row 6 <- row 4, k+4 | 0.836 | 0.792 | 0.658 | 0.830 / 0.861 / 0.794 / 0.873 / 0.792 / 0.861 / 0.797 / 0.882 |
| row 8 <- row 2, k | 0.800 | 0.701 | 0.667 | 0.701 / 0.833 / 0.803 / 0.835 / 0.811 / 0.808 / 0.807 / 0.800 |
| row 8 <- row 2, k+4 | 0.797 | 0.743 | 0.658 | 0.751 / 0.808 / 0.821 / 0.813 / 0.743 / 0.833 / 0.787 / 0.819 |
| row 8 <- row 4, k | 0.888 | 0.819 | 0.663 | 0.819 / 0.914 / 0.874 / 0.908 / 0.907 / 0.915 / 0.871 / 0.893 |
| row 8 <- row 4, k+4 | 0.879 | 0.809 | 0.652 | 0.809 / 0.897 / 0.874 / 0.894 / 0.865 / 0.908 / 0.872 / 0.910 |

Row 6 <- row 2 (phase k): mean 0.912, every cell >= 0.889. Row 8 <- row 4 (phase k): mean 0.888 (bar 0.85); cell 1 is
0.819 in both phases, so the row passes on its mean and cell 1 is the weakest fit. Phase map per cell = the better of k / k+4
(row 8 cell 7 takes donor cell 3). Row 4 is the better donor for row 8 (row 2: 0.800) and row 2 for row 6 (row 4: 0.845).

## Step 2: registration (row 8, shipped; table from `comp/r8t.png.json`, the final `r8t2` has the same shifts and 4 more px left as target)

| Row 8 cell | Donor cell (mirrored) | Band IoU | Alpha shift (dx,dy) | Neck shift (dx,dy) | Scale | Collar-mask IoU | Seam (mean RGB diff, 2 px ring) | Mask px | Rope px left as target (no donor alpha) |
|---:|---|---:|---|---|---:|---:|---:|---:|---:|
| 1 | r4c1 | 0.819 | (1, 13) | (-1, 11) | 1.0 | 0.539 | 37.6 | 748 | 8 |
| 2 | r4c2 | 0.914 | (2, 14) | (1, 12) | 1.0 | 0.444 | 45.1 | 770 | 5 |
| 3 | r4c3 | 0.874 | (2, 14) | (2, 12) | 1.0 | 0.576 | 41.1 | 682 | 13 |
| 4 | r4c4 | 0.908 | (1, 9) | (3, 11) | 1.0 | 0.396 | 51.5 | 810 | 14 |
| 5 | r4c5 | 0.907 | (1, 12) | (2, 10) | 1.0 | 0.489 | 43.0 | 685 | 3 |
| 6 | r4c6 | 0.915 | (1, 14) | (2, 12) | 1.0 | 0.548 | 52.8 | 771 | 6 |
| 7 | r4c3 | 0.872 | (1, 10) | (2, 8) | 1.0 | 0.558 | 46.2 | 695 | 18 |
| 8 | r4c4 | 0.910 | (1, 8) | (0, 8) | 1.0 | 0.474 | 54.9 | 806 | 15 |

The brief's +-6 px search on the collar-mask IoU alone was tried first (`tp/r68_judge.png`, `r68s`, `r68o`): it slid the
donor collar onto the helmet and visor (seams, shards, a doubled visor edge), because the rope hull and the rigid
ring differ in shape (mask IoU 0.24-0.56 at any shift). Fixed registration: start at the alpha shift, search +-2 px,
pick the lowest seam cost (mean RGB difference on a 2 px ring just outside the mask + holes + donor collar landing above
the rope or beside it). Scale 0.95-1.05 was allowed only if it raised the mask IoU by >= 0.03 and lowered the cost: no
cell took it (all 1.0). The rope hull keeps every orange component inside the neck band (the first pass kept only the
largest and left a rope remnant at cell 3's left end).

## Step 3-4: composite and identity proof

Inside the union of row 8's rope hull and the shifted donor collar hull (clipped to the alpha): the mirrored donor's
pixels; outside: row 8 unchanged. Rope px with no donor alpha (3-18 per cell, edge pixels) and 4 donor px with a teal
cast are left as the shipped pixel (never painted).

- `comp/r8t2.png.json` (= the shipped sheet): changed 5878 px, **changed outside mask 0**, **alpha identical**, **teal in mask 0**.
- Rows 1-7 bit-identical; row 8 changes only in y 70-124 of the 199 px cells (soles at y 196).
- Mask colours: orange median 241, 87, 12 (mean 237, 88, 17); dark median 19, 5, 3. These are row 4's own shipped
  collar pixels (n29 row 4: about 234, 85, 23 / 36, 16, 12 by the earlier measure); my orange mask is the stricter
  `neck.collar_mask`, so its median sits slightly redder than the brief's 225-234 / 23-39 band. No new colour was made.
- sha256 `1b061c3d70f60a2d5c650284b55fd7de6eea56c28cc49c3bcf535168592e5c0f`; `--import`: the `.import` is unchanged.

## Step 5: what I saw

- Row 8 (4x, `collar_p55_rows4568_judge_4x.png` bottom pair, and `collar_p55_rows68_neck_4x.png` bottom pair): a flat
  ring with straight black/vermilion diagonal stripes, the same collar as row 4 (above it in the judge). Cells 1, 2, 3, 5,
  6, 7 clean. Small faults at 4x only: cell 4 a 2-3 px notch where the helmet meets the ring's left end, cell 8 a light
  vertical streak on the helmet just right of the ring, a few ragged px at the ring's left end on 5 and 7.
- At 64 px/m (`collar_p55_all_rows_64.png`, `..._cell2.png`, 0.785 x the sheet, LANCZOS): row 8 reads as one stiff flat
  ring, no seam step, no doubled edge, no hole visible. Accepted.
- Row 6 (`collar_p55_rows68_neck_4x.png` top pair = shipped above, the rejected candidate below; not shipped): REJECTED.
  Row 2's mirrored ring sits higher on the chin than row 6's rope; any registration either crosses the visor's lower-left
  corner (doubled edge) or, once the hull caught the orange visor glow, swapped in row 2's yellow visor; the stripes there
  also read curved in that 3/4 front view. Row 6 stays the shipped rope.

## Drift

Re-measured with the n27 setup: `build/h27/meas.py` (the n27 `hands_slide.py`) on copies of the n27 v0.98 takes
(`build/h27/v0.98/p55_64`, `p55_32`: the per-tick live-arena transforms) against the new sheet. All 16 segments per zoom
are identical to the n27 measurements: **p55 64 px/m sprint profile 3.09 / 4.56, mean 3.83 cm** (n27: 3.83), p55 32 px/m
2.31 / 3.00, mean 2.66. The measure reads only the strip's alpha (sole band), which is bit-identical, so equality is
expected. Not a fresh live capture (the capture scene lives outside the project tree, `build/hands/used_capture_source/`).

## Stills

`C:/Users/kazda/kiro/gtai-masters/n29/keys/collar/`: `collar_p55_rows68_neck_4x.png` (row 6 shipped | rejected candidate,
row 8 shipped | new, all cells, 4x nearest), `collar_p55_all_rows_64.png` (all 8 rows, cell 1, before row above after row,
at 64 px/m size, shown 3x), `collar_p55_all_rows_64_cell2.png` (same, cell 2), `collar_p55_rows4568_judge_4x.png`
(rows 4, 5, 6, 8, shipped above new).

## Commits

Sheet + provenance `56cb77065`, then `e553b6b9e` (4 teal-cast donor px left as the shipped outline; superseding
provenance line). `git commit` hook (lint 18 checks) passed both times; `node tools/gate/quick.mjs`: no changed .gd.
