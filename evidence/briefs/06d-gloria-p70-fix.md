# Package 6d (guns lane, n19): gloria p70 left rest cells bounced

Director looked at d798a20b8 (`gtai-masters/n19/guns/gloria/gloria_p70_west.png`, `gloria_p70_nw.png`, and a bbox crop of `rivet_eq_gloria_left.png` (p70) under the mirrored hand-made SE/E/NE cells). p55 and the p70 fire cells are accepted. Two defects in the **p70 rest** `_left` cells, tellable at 64 px/m:

1. **W (cell 1): a yellow visor slit was added on the left of the helmet.** The hand-made E cell it mirrors shows the helmet side (ear disc, no visor). The W cell must keep the mirrored helmet exactly; no correction region may touch the helmet. The visor appears only where its hand-made source facing shows it.
2. **W and NW: the gun region is smeared/soft** (thin ink lost, pale blur over the receiver; NW most visibly) next to the crisp mirrored source. The masked correction must keep the source's ink weight and sharpness. If an EDIT cannot hold it, fall back to the mirrored source pixels for the gun and correct only the parts that are truly asymmetric with a pixel-exact scripted flip of the original sub-region (as in plasma/gatling), and say which.

Do: fix in `tools/art/left_regions/gloria.json` / `tools/art/left_from_right.py` inputs (script cut, no hand edits), re-cut p70 `rivet_eq_gloria_left*.png`, re-shoot `gloria_p70_west.png`, `gloria_p70_nw.png`, `gloria_p70_left_check.png`, and add a bbox-cropped "mirrored source | new left" sheet at 2x for p70 rest + fire (`gloria_p70_left_zoom.png`). Then check rocket_launcher and mini_nuke left cells from 06c the same way yourself (no helmet edits, gun ink as crisp as the source) and fix any with the same fault.

Acceptance: as 06c (metrics, audit unchanged at its count, unit `--changed`, lint, quick gate, one commit per weapon). Report: what changed per cell, which parts are scripted flips vs EDITs.
