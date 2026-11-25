# n30-01 collar-cell-r3c1: the per-cell 2x edit route, proven on row 3 cell 1 (lane keys)

Launched ~11:15. **Commit by 11:45. Report and END by 12:00** (wall clock; check `date`). Work in
`C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`, `reset --hard`.
Stage per path. Fix lint and format findings in your own edit and go on.

## Goal
The owner's pick for Rivet's p55 sprint sheet `project/features/characters/art/view/p55/rivet_run8.png` (8 facing rows x 8 gait
cells, cell 209 x 199 px; rows are 1-based in all notes): rows 3, 6, 7 still wear a twisted rope at the neck instead of the
rigid striped hazard collar (Rivet's neck band is a **rigid hazard collar, never cloth**: a stiff flat ring, crisp dark outline on
its straight top and bottom edges, straight parallel diagonal stripes alternating vermilion and near-black). Rows 1, 2, 5 are
rigid; row 4 was fixed by an image edit in n29 (accepted); row 8 by a transplant of row 4 mirrored.

The route this run: **one cell per image job, at 2x, with row 4's accepted collar (the matching cell, same gait phase =
same column) as the reference image**, then scale back, register, composite neck-only. This call builds the route and does
**row 3 cell 1 only** (1-based: sheet row index 2, column 0) so the director can judge it before the other 25 cells.

## Read first (5 min max)
- `evidence/n29-keys/collar_p55.md` and `evidence/n29-keys/collar_p55_transplant.md` (what failed and why: whole-row edits kept
  the rope or made a knitted scarf/crescent stripes; registration by collar-mask IoU slid onto the visor; seam-cost registration worked).
- n29 scripts to reuse/copy (do not edit them in place): `C:/Users/kazda/kiro/gtai-art/rivet-n29/collar_p55_rows/scripts/`
  (`neck.py` masks, `comp_row.py` key + register + neck-only composite + proof, `tp_comp.py` seam-cost registration, `tp_judge.py` crops).
- Image runner `C:/Users/kazda/kiro/gtai-art/gen.mjs` (usage at its top: `node gen.mjs <roundDir> <jobName>`, reads
  `<roundDir>/jobs.json`, refs from `<roundDir>/refs/`). **Known fault**: a job can stall on the copy to `./out` after the
  image already exists under `~/.codex/generated_images/<session>/`: snapshot that dir's listing before each job
  (`gi_before.txt`), and when a new png appears there, copy it by hand to `out/<job>.png` at once and kill the gen node tree by PID.
  Run gen.mjs detached (`nohup node ... > gen_<job>.out 2>&1 &`) and poll. If the output says usage limit / rate limit: stop
  generating, write `BLOCKED images` in your report.

## Steps
1. Round dir `C:/Users/kazda/kiro/gtai-art/rivet-n30/collar_cells/` with `STATE.md` (one timestamped line per step; a later call
   must be able to resume from it), `refs/`, `scripts/`, `out/`, `comp/`. Base sheet = HEAD's `p55/rivet_run8.png` (copy to `comp/base.png`).
2. Script `scripts/cell_job.py <row> <col>` (1-based row, 1-based col) that writes the refs for one cell job:
   - `refs/r<row>c<col>_2x.png`: the target cell upscaled 2x (418 x 398, LANCZOS or nearest, your pick, say which), centred on a
     1024 x 1024 flat `#00B140` key canvas (note the paste offset in a json beside it).
   - `refs/r4c<col>_2x.png`: row 4's cell of the same column at 2x on the same kind of canvas (the reference collar).
   - optionally `refs/r4c<col>_neck4x.png`: a tight 4x crop of row 4's collar in that cell.
   - appends a job to `jobs.json` (`style` short; prompt: minimal edit of image one, change ONLY the neck band into the rigid
     flat collar of image two: same ring width as image two's at this scale, a crisp dark outline on straight top and bottom
     edges, straight parallel diagonal vermilion/near-black stripes, flat shading; name what is wrong: the twisted rope /
     knitted scarf / crescent stripes / rounded tube; every other pixel unchanged, same canvas, same position, no blur,
     no yellow, no red, no teal, no text). Learn from the n29 prompts in `rivet-n29/collar_p55_rows/jobs.json` and their failures.
3. Run the one job for row 3 cell 1. **IMAGES cap for this call: 3** (one job + up to two retries with a changed prompt or
   reference). Log `IMAGES n` in STATE.md after every job.
4. Script `scripts/cell_comp.py <row> <col> <raw.png> <base.png> <out.png>`: key the green, scale 0.5 back, register to the shipped
   cell (alpha IoU shift +-6 px, scale 0.97-1.03, then seam-cost refine +-2 px as `tp_comp.py`), composite **neck-only** (mask
   = shipped orange hull + edited collar hull, filled, clipped to the shipped alpha; leave teal-cast donor px as shipped), and
   write `<out>.json` proof: changed px, **changed outside the neck mask = 0**, **alpha identical**, every other cell bit-identical,
   teal px in mask = 0, mask median colours (orange should sit near row 4's 227-241, 85-92, 12-31; dark near 19-36, 5-16, 3-12).
5. Judge stills (to `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/`):
   - `r3c1_4x.png`: 4x nearest of the cell's head/shoulder band: shipped | candidate | row 4 cell 1 (reference), labelled.
   - `r3c1_64_ingame.png`: in game at 64 px/m, the p55 sprint in row 3's facing, before | after at the same tick. Use the
     n29 harness `evidence/n29-keys/films/run_hands.py <outdir> 64 0` (cwd = worktree; read `evidence/n29-keys/films.md` Job 2
     for which beat/tick shows which sheet row; row 3 1-based = harness row 2 0-based). Before = HEAD's sheet; after = the
     candidate installed in the worktree. If the harness frame at that tick does not show column 1, say which cell it shows;
     the in-game still is still the judge of the row's read. Beware the n29 pitfall (stale `.godot/imported` texture: verify
     the before and after frames differ in the neck and only there).
6. If the candidate passes YOUR look check (flat ring, straight stripes, no rope, no visor damage, no seam) and the proof is
   clean: install it as `p55/rivet_run8.png`, Godot `--import` through runGodot (`.import` should not change), append one line
   to `steam/ai-provenance/2026-11.jsonl` (copy the format of the n29 collar lines there), run `node tools/gate/quick.mjs`,
   commit `art(keys n30): p55 sprint collar row 3 cell 1 rigid (per-cell 2x edit, row 4 c1 reference)`. If it fails twice,
   do not install; keep the shipped cell and report what was wrong.
7. Write `evidence/n30-keys/collar_cells.md` (method, the scripts' paths, the proof numbers, IMAGES used, what you saw) and
   commit it.

## Machine law
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- One Godot for the whole lane: take the lock `build/n30-godot.lock` (create exclusively with your tag `n30-01` and your
  shell's pid; wait if it exists and is not yours; delete it after). Godot only through runGodot (the harness, `tools/dev/run.mjs`,
  `tools/godot/check.mjs`, gate tools). Windowed runs `--position 0,1440` (the harness already does). Free your own processes
  by PID, never by name. `mem-budget: waiting` means the machine is full: wait.
- Python: `python -I`.

## Owned files (allowlist; any other path: stop and report a NEED)
`project/features/characters/art/view/p55/rivet_run8.png` (+ its `.import` only if Godot changes it),
`steam/ai-provenance/2026-11.jsonl` (append one line), `evidence/n30-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n30/**`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/**`. The harness copies files into `project/dev/motion/` and removes them: leave
nothing there. Forbidden: `JOURNAL.md`, `REPORT.md`, `docs/decisions.md` (the director writes those), every file of the
combat, cast and yard lanes, other worktrees.

## Report (your final message)
Commits (hash + subject), files, IMAGES used, the proof numbers, the stills' paths, what you saw at 4x and 64 px/m,
what you could not do, and the round STATE's next line.
