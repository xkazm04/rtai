# n31-32 yard-readability (builder tag `n31-32`): n30-yard readability bars, main | HEAD (evidence only)

Read `evidence/briefs/n31-law.md` (binding). **No product, tool or test edits in the live tree; no change to any tracked file except the one new evidence file below. Commit it by 06:50. Hard stop 06:55: report and END.** Started 05:56.

## Why
Item 4 moved yard footprints (`428511fc3`) and drew dark PropBase contact pads (`e1c54b29a` softened them). The n30-yard readability bars must still pass on HEAD; REPORT says "unmeasured". Measure them.

## Method (exactly n30's: read `evidence/yard30/decals_over.md` section "Readability bars", `evidence/yard29/art_sweep.sh`, `evidence/yard29/sweep_measure.py` and what it imports)
- Two arms: before = `ba8e470b0` (main), after = `88bc88996` (HEAD product; later commits are docs/evidence only).
- Each arm renders from its own **overlay project** under `build/n31/n31-32/<arm>/` (n30 did junctions to the project with the changed files taken from git at each rev, because `git worktree add` stalls on this repo). Files that differ between the arms under `project/`: `git diff --stat ba8e470b0 88bc88996 -- project/` (take every changed file from git at that rev into the overlay; for an LFS image use `node tools/film/blob.mjs <rev>:<path>`, never `git show`). If an overlay is not workable in 15 minutes, use `git worktree add` under `%TEMP%\gtai-n31-ground-*` for main only (remove it after) and the live tree for HEAD **without editing it**.
- The day arm needs an `arched_day` row: add it only to **each overlay's own copy** of `prologue_yard_dressings.json` (n30 did the same; the live table stays untouched; `git status project/` must show nothing at the end).
- Captures: `tools/art/prologue_yard_stills.mjs --dusk --dressing=<arched_day|arched_line>` per arm (run with cwd = the overlay so `runGodot` uses its project), then `python -W ignore -I evidence/yard29/sweep_measure.py <dir>` (it reads the table from cwd: run it from the arm's overlay or point it at the arm's table copy).
- Lane Godot mutex per the law (lock `n31-32`). One Godot at a time. Other lanes' gates run 06:15-07:00: `mem-budget: waiting` is normal, note the minutes.

## Bars (report each, both arms)
patrol blue outside retained >= 65 %, patrol blue inside >= 65 %, rifle >= 95 %, pellet (shotgun) >= 90 %, Rivet luminance delta after >= before - 0.01, cops in view per dusk frame (must be > 0, else the pairing is wrong: say so).

## Deliver
`evidence/n31-ground/yard_readability.md`: arms + revs, how the overlays were made, the table (measure | main | HEAD | bar | verdict), cops in view, mem-budget minutes, what was not measured and why. Commit that one file by path (message `n31-32 ground: n30-yard readability bars main | HEAD ...`). If only one arm finished by 06:45, commit what you have and say which arm is missing. Unmeasured is never zero.

## Owned
`build/n31/n31-32/**`, `evidence/n31-ground/yard_readability.md`, a temp worktree under `%TEMP%\gtai-n31-ground-*` you create and remove. Everything else: forbidden.

## Report (final message)
The table, the commit hash, what you ran, minutes, anything you could not do.
