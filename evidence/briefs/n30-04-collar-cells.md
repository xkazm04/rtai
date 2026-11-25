# n30-04 collar-cells: rows 3, 7, 6 and row 8's touch-ups by the proven per-cell 2x route (lane keys)

Launched ~11:15. **Commit each finished row (or every 4 accepted cells) as soon as its proof and your look pass; last commit
by 12:12. Report and END by 12:24** (wall clock; `date +%H:%M` often). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls`
(branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path.
Fix lint and format findings in your own edit and go on. Keep the round `STATE.md` current (a later call resumes it).

## Where it stands
Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` (`STATE.md`, `scripts/cell_job.py`, `scripts/cell_comp.py`,
`jobs.json`), evidence `evidence/n30-keys/collar_cells.md`. Row 3 cell 1 shipped `bf7b78fd6` (1 image, 61 s; registration IoU
0.990, 0 px outside the mask, alpha identical). **Director's verdict on r3c1 (4x and 64 px/m in game): accepted** - flat ring,
straight parallel vermilion/near-black diagonal stripes, dark outlined edges, the same read as row 4. Keep exactly that bar.

## Order and caps
1. Row 3 cells 2-8 (right profile; reference = row 4 cell of the same column).
2. Row 7 cells 1-8 (left profile).
3. Row 6 cells 1-8 (left/front three-quarter; row 4 is the back three-quarter: if the first two cells of row 6 fail, try the
   row 2 cell of the same column MIRRORED as the reference, n29 found row 2 the closer shape for row 6; say which you used).
4. Row 8 touch-ups: cell 4 (a 2-3 px notch where the helmet meets the ring's left end) and cell 8 (a light vertical streak on
   the helmet just right of the ring), same route (target = the shipped row 8 cell, reference = row 4's cell).
Two jobs in flight at most (each its own gen.mjs, hand-copy rule, stop each tree by PID). Before each cell's composite, use the
current sheet (HEAD + your accepted cells) as base so composites stack. **At most 30 images this call**; per cell one retry;
a cell that fails twice keeps the shipped cell: list it and move on. Usage-limit answer: stop, `BLOCKED images`.

## Per cell bars (all of them, before the cell is accepted)
Proof json: changed outside the neck mask 0, alpha identical, all other cells bit-identical, teal in mask 0, registration
alpha IoU >= 0.97. YOUR look at the 4x judge still (shipped | candidate | reference): a flat ring, straight parallel stripes,
dark outline top and bottom, no rope/twist/crescent/knit, no damage to visor, helmet, arms, no seam, no new yellow/red/teal.
Write one STATE line per cell (accepted / retry / kept shipped, why).

## Per row, before its commit
- A row contact still `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/row<r>_4x.png` (shipped row above, new row below, 4x of
  the head/shoulder band) and look at it.
- In game at 64 px/m: the harness `evidence/n29-keys/films/run_hands.py <outdir> 64 0` (as in n30-01; runs under
  `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/runs/`): before (r3c1 run already exists for HEAD bf7b78fd6's base: reuse
  `runs/r3c1_after_64` as "before" for row 3; make one before run for rows 6-8 from the HEAD at your start) | after, the
  tick(s) where the row shows; still `row<r>_64_ingame.png`. Frame diff: only the row's ticks change, only in the neck window.
  To save Godot time you may run ONE after-run covering several finished rows.
- Install, Godot `--import` (`.import` unchanged), one provenance line per commit in `steam/ai-provenance/2026-11.jsonl`
  (format of the n30-01 line), `node tools/gate/quick.mjs`, commit `art(keys n30): p55 sprint collar row <r> rigid (per-cell 2x
  edits, cells ...)`. Append the row's table (cell, IoU, mask px, changed, colours, verdict) to `evidence/n30-keys/collar_cells.md`
  in the same or a following commit.

## At the end (if time; else leave the exact commands in STATE Next)
Drift re-measure: the n27 setup as in `evidence/n29-keys/collar_p55_transplant.md` "Drift" (`build/h27/meas.py` on the n27 v0.98
takes against the new sheet); bar 3.83 +- 0.1 cm at 64 px/m. Note it in the md.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Lane lock
`build/n30-godot.lock` (exclusive create with tag `n30-04` + pid; if another tag holds it - the molotov builder `n30-03` works
in this worktree - wait; delete yours after). Only through runGodot. Free only your own processes, by PID.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p55/rivet_run8.png` (+ `.import` only if Godot changes it),
`steam/ai-provenance/2026-11.jsonl` (append), `evidence/n30-keys/collar_cells.md`, `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/**`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/**`, `build/**`. The harness's temp files in `project/dev/motion/`: leave nothing.
Forbidden: `rivet_run8_eq_molotov.png`, `rivet-n30/molotov/`, `evidence/n30-keys/grid_molotov*`, `evidence/n30-keys/vermilion*`
(other builders), `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, combat/cast/yard files, other worktrees. Never delete anything in
Temp or `~/.codex` you did not create.

## Report (short), then END
IMAGES n, the per-cell table (accepted / kept shipped), commit shas, the stills you made, drift if measured, STATE Next.
