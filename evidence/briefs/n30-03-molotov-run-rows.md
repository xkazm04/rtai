# n30-03 molotov-run-rows: the molotov's own p70 run sheet, one row per image job (lane keys)

Launched 11:09. **Commit what passes by 12:05 (rows wired only if all 8 pass; otherwise commit nothing under project/ and keep the round resumable). Report and END by 12:22** (wall clock; `date +%H:%M` often).
Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash,
`git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path. Fix lint and format findings in your own edit and go on.
Never end with finished, passing work uncommitted; keep the round `STATE.md` current (each step with the time) so a
later call resumes it.

## Goal (owner's pick)
"The molotov run set, one row per job": the molotov walks on its own p70 grid since n28 (`347783a4c`,
`p70/rivet_walk_eq_molotov.png`, edited from the plasma rifle's) but **sprints on the stop-gap** (`RivetWalk.path_of` lets
the bare run answer the sprint when a weapon has a walk sheet and no `rivet_run8_eq_<weapon>.png`). Make
`project/features/characters/art/view/p70/rivet_run8_eq_molotov.png` by image edits of the donor's run rows
(`p70/rivet_run8_eq_plasma_rifle.png`), **one row per job**, the molotov in the claw as drawn in the molotov walk sheet
(lit rag AMBER, not red: n29 `0b6814366`/`65578a4be`), the **donor's soles fixed by registration**.
Ship the sheet (which flips the molotov off the stop-gap) **only when all 8 rows pass**; until then keep the passing rows in
the round dir, nothing under `project/`.

## What is known (read, 10 min max)
- n28 molotov round `C:/Users/kazda/kiro/gtai-art/rivet-n28/molotov/STATE.md` (tail): the full-sheet run edit drew row 1's
  legs 30 % short and its soles x-shifted 10-16 px off the donor (run step 10.9 cm vs bar 7); a whole-cell shift to match
  the soles moved the dome 6-24 % (fail); the donor-legs-under-a-seam (`fix_row1.py`, SEAM 0.82) passed (6.03 cm) but was
  never shipped. Lesson: per-row jobs at a large scale hold the legs better; registration = fit each edited cell to the
  donor cell (alpha IoU shift/scale) so the soles land on the donor's.
- The n29 plasma sword round is the method to copy: `C:/Users/kazda/kiro/gtai-art/rivet-n29/plasma_sword/` (`STATE.md`,
  `scripts/mkjobs_rows.py`, `mkrefs_row.py`, `prep_row.py` bars, `solex.py`, `eye.py`, `assemble.py`, `finish_tone.py`,
  `wire_data_any.py`, `prov.py`, `capture28.py`, `composite.py`). Run rows laid out at scale >= 0.90 (8 x 194 x 0.95 fits a
  1536 frame) or two 4-cell halves at 1.0. Copy the scripts into your round; do not edit the n29 round.
- Image runner `C:/Users/kazda/kiro/gtai-art/gen.mjs` (usage at its top). Known fault: the png lands under
  `~/.codex/generated_images/<dir>/` and the copy to `out/` stalls: snapshot that dir listing before each job, hand-copy the
  new png at once, stop that gen node tree by PID. Other lanes generate too: a png that is not a running Rivet with a molotov
  is not yours (leave it). Two jobs in flight at most. Usage-limit answer: stop, `BLOCKED images`.

## Bars per row (same as the plasma sword)
dome <= 3 %, sole y <= 2 px, **sole x within 3 px of the donor per cell**, leg IoU >= 0.80, same lead, tone post <= 2; eye
check of a 4x crop: the molotov bottle in ONE claw as in the walk sheet, rag amber, collar a flat rigid striped ring (never
cloth), no rifle remnant, no extra hand, no red element (red = blood only), no teal. One retry per row; a row whose legs fail
twice takes the donor's legs under a seam (n28 `fix_row1.py` style, say so); if the arms/bottle fail twice, stop that row
and report it (two failed routes = stop). **At most 12 images this call**; count in STATE (`IMAGES n`).

## Wiring (only with all 8 rows passing; needs Godot)
Assemble, `wire_data_any.py molotov plasma_rifle <final>` (its run part), pins in `project/tests/unit/test_rivet_grid_stride.gd`
(keep <= 200 lines) and the fallback test `project/tests/unit/test_rivet_walk_sprint_fallback.gd` (the molotov is probably
its example of "walk sheet, no run sheet": move the pin to a weapon that still has no run8 or to a fixture; read it first),
provenance via `prov.py` into `steam/ai-provenance/2026-11.jsonl` (append), Godot `--import` (capture tools do NOT reimport),
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` (if its Godot parse check fails on files you did not touch:
`--no-godot` and say so), commit: `keys n30: molotov runs on its own p70 grid (plasma rifle donor, one row per job)`.
Then evidence (separate commit): `capture28.py molotov` rows + candidate to `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/`,
foot_slide turn_090 lane row 0 at 32 px/m: **walk hold <= 2 cm, run step mean <= 7 cm** (plasma rifle donor 6.69/8.93 beside),
`grid_molotov_64.png` (8 run facings: stop-gap | new | plasma rifle), `evidence/n30-keys/grid_molotov.md`.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot for the
lane: the lock `build/n30-godot.lock` (create exclusively with your tag and pid; if it exists and is not yours, wait; delete
yours after). Only through repo tools (runGodot). d3d12, windowed `--position 0,1440`. `mem-budget: waiting` = machine
full, not a hang. Free only your own processes, by PID.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_run8_eq_molotov.png(.import)`, `project/data/tables/rivet_motion.json`
(molotov rows only), `project/tests/unit/test_rivet_grid_stride.gd`, `project/tests/unit/test_rivet_walk_sprint_fallback.gd`,
`project/tests/unit/test_rivet_walk_every_weapon.gd` (only if a molotov pin there needs it), `steam/ai-provenance/2026-11.jsonl`
(append), `evidence/n30-keys/grid_molotov*`, `C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/**`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/**`, `build/**`.
Forbidden: `p55/rivet_run8.png` and `rivet-n30/collar_cells/` (another builder), the donors (read only), the molotov's walk
sheet and item art, other weapons' art, code under `project/features/**`, `weapons.json`, combat/cast/yard files, `JOURNAL.md`,
`REPORT.md`, `docs/decisions.md`. Never delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
IMAGES n, the rows table (bars per row, retries, donor legs where), commit shas, foot_slide numbers if measured, still paths,
STATE `Next`.
