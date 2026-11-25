# n30-06 collar-leftovers: the 4 kept rope cells and row 8's two touch-ups (lane keys)

Launched ~11:38. **Last commit by 12:12. Report and END by 12:24** (wall clock; `date +%H:%M` often). Work in
`C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Same law, Godot rules, lock (`build/n30-godot.lock`, tag
`n30-06`; the film builder `n30-05` shares it: wait, never delete its lock), allowlist and forbidden list as
`evidence/briefs/n30-04-collar-cells.md`: read that brief first, it binds this call except where this file says otherwise.

## Where it stands
Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md` NEXT lines, `scripts/cell_comp.py` with the visor guard
and the row-band limit, `jobs.json` incl. ready jobs `r8c4`, `r8c8`). Rows 3 (8/8), 7 (6/8), 6 (6/8) shipped
(`0b1a1cd27`, `47aed0529`, `6ba1b9d68`), evidence `evidence/n30-keys/collar_cells.md`. Director accepted rows 3, 6, 7 on
`row7_4x.png` and `row67_64_ingame.png`.

## Do
1. **r7c3, r7c4** (both broke into pieces at the front end of the ring, by the fist): one more job each with a prompt that
   names the front end ("the ring passes behind the raised fist / forearm: keep it one unbroken band up to where the arm covers
   it, no pieces, no gaps") and, if it helps, a second reference: an accepted neighbour of the same row (r7c2 or r7c5, from the
   current sheet) at 2x. Max 2 images per cell.
2. **r6c2, r6c6**: reference = row 2's cell of the same column MIRRORED (n29: row 2 is the closer shape for row 6) plus the
   accepted r6c1/r6c5 as the style reference; prompt names the front-end fault (r6c2: no dark bar up the shoulder, ring mostly
   vermilion/black alternating not mostly dark; r6c6: no wedge or notch at the front end). Max 2 images per cell.
3. **r8c4** (2-3 px notch where the helmet meets the ring's left end) and **r8c8** (a light vertical streak on the helmet just right
   of the ring): jobs ready. For r8c8, check the composite mask covers the streak; if the streak lies outside the collar hull,
   widen the mask for this cell only by the streak's px and say so (still 0 px changed outside the declared mask; alpha identical).
   Max 2 images per cell.
**At most 12 images this call.** A cell that fails twice keeps the shipped cell (list it).

## Before each commit
The 4x row stills (`row7_4x.png`, `row6_4x.png`, `row8_4x.png` regenerated from the new sheet) and, once for all changed rows,
one in-game 64 px/m after-run with the frame diff (only those rows' ticks, only the neck window). Note which changed cells the
harness never shows. Provenance line, `--import`, `node tools/gate/quick.mjs`, commit
`art(keys n30): p55 sprint collar leftovers (cells ...)`; append the table to `evidence/n30-keys/collar_cells.md` (commit).
Drift only if the alpha changes (it must not).

## Report (short), then END
IMAGES n, per cell accepted / kept, commit shas, stills, STATE Next.
