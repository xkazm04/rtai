# n30-10 eq-collar-audit: which of Rivet's weapon strips still wear the collar as rope (lane keys, analysis only, 0 images)

**Commit the audit within 25 minutes of launch; report and END within 35** (`date +%H:%M` first; write both deadlines in your
first line). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash,
`git add -A/./-u`, `commit -a`, `reset --hard`; stage per path with `git commit -- <paths>` (another builder commits in this
worktree). **No image generation, no Godot, no edits under `project/`.**

## Why
Standing rule: Rivet's striped neck band is a rigid hazard collar (a flat ring, straight parallel vermilion / near-black stripes,
dark outline top and bottom), never cloth. The p55 run sheet's rows were fixed in n28-n30 (`evidence/n30-keys/collar_cells.md`).
The director saw at 2x that `p70/rivet_eq_rocket_launcher_left.png` cells 2, 3 and `p70/rivet_eq_mini_nuke_left.png` cells 2, 3
show the band as a knit / twisted rope with frayed edges (a scarf), while `rivet_eq_gloria_left`, `pistol_left`, `katana_left`,
`molotov_left` read as a flat band. We have **8 image edits left** this run; this audit decides where they go.

## Do
1. Find which Rivet strips the game shows in play and how often (read `RivetStrips` / `RivetWalk` / the held-art code under
   `project/features/player/**` and `project/features/characters/**`; `rivet_motion.json`; which ppm folder at the default
   gameplay zoom/tilt, p55 or p70; which strips are aim/idle vs fire/windup/strike). One short table: strip family -> when shown.
2. For every `rivet_eq_*` strip (both `p55/` and `p70/`, skip `_noflash` twins that equal their flash strip except the muzzle)
   and Rivet's `rivet_walk*` / `rivet_run8*` sheets not already fixed: cut the cells (find the cell grid from the code or by
   alpha columns), crop the neck band at 4x, and classify each cell RIGID / ROPE / UNSURE by eye on contact sheets (one sheet per
   strip family, cell index labelled). A metric may help sort (e.g. stripe edge straightness, the band's top/bottom outline
   continuity), but the class is your look; say what you used.
3. Write `evidence/n30-keys/eq_collar_audit.md`: per strip, cells ROPE / UNSURE, in-play weight (from step 1), and a ranked list
   of the **8 cells** that would gain most from a per-cell 2x edit with a rigid reference (most seen first). Name for each a
   reference cell of the same facing that is already rigid. Contact sheets to `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/`.
   Commit `evidence(keys n30): p55/p70 weapon strips collar audit (rope cells ranked)`.

## Allowlist (anything else: stop and report a NEED)
`evidence/n30-keys/eq_collar_audit.md`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/**`, `build/n30-10/**` (scratch).
Read-only: everything else. Forbidden to touch: all art and code, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, other lanes'
worktrees. Never delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
The when-shown table, counts ROPE/UNSURE/RIGID per strip, the ranked 8, the commit sha, contact sheet paths.
