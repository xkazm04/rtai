# n30-05 molotov-film: the molotov's run beside the stop-gap at 32 px/m, the 64 px/m still, frames.json, decision lines (lane keys)

**Commit by 25 minutes after launch, report and END by 45 minutes after launch** (`date +%H:%M` at start, write both times in
your first line). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). No product file changes.
Never amend, rebase, push, stash, `git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path. Fix lint/format findings
in your own edit and go on.

## Goal
The owner judges by films. The molotov sprints on its own p70 run sheet since `4513bda2a` (evidence `evidence/n30-keys/grid_molotov.md`,
stills `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_64.png`). Make:
1. `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/molotov_32.mp4`: 1920x1080, 60 fps, 15-40 s (check with `ffprobe`): three
   1:1 tiles **stop-gap (before) | n30 | plasma rifle (donor)** at 32 px/m, tilt 70, walk then sprint over 8 facings, the same
   frame index in every tile, over a full-width n30 64 px/m tile, labels burned in. Copy the n29 method exactly: read
   `evidence/n29-keys/films.md` Job 1 and use `evidence/n29-keys/films/capture_film.py` and `compose.py` (copy them into
   `evidence/n30-keys/films/` and adapt paths; do not edit the n29 copies).
2. "Before" (stop-gap) = a temp worktree at `19259b098` (the commit before the molotov sheet): `git worktree add` it under
   `C:/Users/kazda/kiro/gtai-n30/tmp/keys-before` (copy the native DLLs / bake / import cache from this worktree as n29 did,
   and beware the n29 pitfall: a copied `.godot/imported` can hold the new texture for the same path; verify the before tile
   shows the stop-gap's thin held sliver, not the bottle). Remove that worktree at the end (`git worktree remove`), and nothing
   else.
3. A 64 px/m still `molotov/molotov_before_after_64.png`: stop-gap | n30 at the same sprint tick, 1:1, two facings.
4. Look at frames at 3 s and 12 s yourself and write what you saw.
5. `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json` (create or extend; array of `{file, title, ppm, before, note}`, best
   first, paths relative to `n30/keys/`): the molotov clip, the molotov 64 still, `molotov/grid_molotov_64.png`, and the collar
   stills that exist now in `collar/` (`r3c1_64_ingame.png`, `r3c1_4x.png`, any `row<r>_64_ingame.png` / `row<r>_4x.png`).
   Do not remove entries other builders added.
6. `evidence/n30-keys/films.md` (what, how, ffprobe output, what you saw).
7. Append these lines to `docs/decisions.md` (append-only, exact text, one commit with the md):
   `- [2026-11-25] DECISION keys n30 molotov run: rivet_run8_eq_molotov.png (4513bda2a) edited from the plasma rifle's run rows one row per image job (10 images; rows 4 and 8 cols 2,6 on the donor's legs under a seam), so the molotov no longer sprints on the stop-gap; walk hold 0.43 cm (bar 2), run step 7.28 cm vs bar 7 (donor 6.69), shipped 0.28 cm over the bar like the plasma sword (8.29, owner "for now"); rejected: keeping the stop-gap until the step passes. Re-check: a trace of the planted-step cells (ticks 53-93). Alternative = delete the one png.`
   `- [2026-11-25] DECISION keys n30 collar route: p55 sprint collar cells edited one cell per image job at 2x (nearest upscale on a 1024 key canvas) with row 4's cell of the same column as the reference, registered by alpha IoU + seam cost and composited neck-only (0 px outside the mask, alpha identical); row 3 cell 1 first (bf7b78fd6). Rejected: whole-row edits (n29: rope kept, scarf, crescents) and mirrored transplants for the profiles.`
   Commit: `evidence(keys n30): molotov film beside the stop-gap, frames.json, decision lines`.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. Lane lock
`build/n30-godot.lock` (exclusive create with tag `n30-05` + pid; if another tag holds it, wait; delete yours after). Only
through runGodot (the capture scripts). d3d12, windowed `--position 0,1440`. `mem-budget: waiting` = machine full, not a hang.
Free only your own processes, by PID.

## Allowlist (anything else: stop and report a NEED)
`evidence/n30-keys/films.md`, `evidence/n30-keys/films/**`, `docs/decisions.md` (append the two lines only),
`C:/Users/kazda/kiro/gtai-masters/n30/keys/**` (molotov/ and frames.json; read-only for collar/ and vermilion/),
`C:/Users/kazda/kiro/gtai-n30/tmp/keys-before` (temp worktree), `build/**`. Forbidden: every project file, `JOURNAL.md`,
`REPORT.md`, other lanes, Temp or `~/.codex` content you did not create.

## Report (short), then END
Clip path + ffprobe, still path, what you saw at 3 s and 12 s, frames.json entry count, commit sha, temp worktree removed (yes/no).
