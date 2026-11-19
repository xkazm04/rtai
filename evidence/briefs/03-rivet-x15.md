# Brief 03 (lane anim, tag rivet-x15): Rivet's knock, strike and base frames strips native at x1.5

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Run `node tools/gate/quick.mjs` before each commit.
- Ownership: lane anim owns `project/features/characters/**` (Rivet's strips in `art/view/p70|p55/`, `rivet_knock.gd`,
  `rivet_strike.gd`, `rivet_frames.gd`, `rivet_res.gd`) and `tools/art/**`. NOT yours: `project/features/player/**`
  (lane move), any `rivet_eq_*` weapon strip, Rivet's gun / muzzle / magazine view files, `rivet_muzzle.json`,
  `weapon_art.json`, `melee_weapons.json` (lane guns). If a player/ call site must change, it may be a ONE-line
  call-site change only, and you name it in your report.
- **Owner's law: x1.5 player size is visual only. Hit boxes, collision, reach, and every gameplay number do not change.**
  Rivet's striped neck band is a rigid hazard collar, never cloth. Images are never edited by hand: scripts under
  `tools/art/` do every cut.

## Step 0 (a director decision on the previous package, do it first, one small commit)
The Tonnage step cap (`GhostStride.MAX_STEP_SHARE`, commit 5b7bebe7d) shipped p70 1.25 and p55 1.0. Both raise the
pose-change drift past the level-3 bar (3 px@32) that p70 met before (2.82 -> 4.04), to buy a worst hold that
still misses its bar. Director's DECISION: ship **p70 = 2.0** (worst 25.42 -> 18.39 px, drift 2.99 < 3: better on the
visible skate without losing the met bar) and **p55 = off (0)** (no cap kept the drift bar's distance smaller and the
clip showed the even p55 skate more). Change only those two values, update `test_tonnage_stride.gd` to pin them,
re-run the p70 110-tick film once at 2.0 to confirm the sweep's number (quote `hold_ride.py` worst/mean), update the
sentence you added to LEVEL.md's Tonnage cell and add one line under the table in
`evidence/tonnage-hold/cap_sweep_32ppm.md` naming the shipped values and why. Append to `docs/decisions.md`:
`- [2026-11-18] DECISION anim/tonnage-walk: GhostStride.MAX_STEP_SHARE p70 2.0, p55 off: the cap that cuts the worst held-frame ride (25.4 -> 18.4 px@32) without lifting pose-change drift over 3 px@32; tighter caps (1.25, even) trade the met drift bar for a worst hold that still misses 9 px; rejected: 1.25/1.0. Re-check when the walk gets drawn in-betweens for steps 1 and 5.`
Quick gate, `run_unit.mjs --changed`, commit.

## Background
- At x1.5 Rivet several one-row strips are still cut at the 110 px figure and scaled up 1.5 in game (blurry ink).
  The method that made the others native is in `project/features/characters/rivet_res.gd`: a strip listed in
  `RivetRes.X15` is cut at `RivetWalk.RES` x 110 (fig_h 165), and every cell-px table that reads it stays in 110
  space through `RivetRes.of(path)`. History: `docs/day/2026-11-10/hero/REPORT.md`, `docs/day/2026-11-11/hero/JOURNAL.md`
  (lines ~21-25: "the 110 cut reproduced IDENTICAL first, cut at fig_h 165, manifest fig_h 165, RivetRes.X15 +2,
  film before/after same ticks"), `LEVEL.md` row "Ink and detail" (it lists what is still 110-upscaled).
- Your targets (anim's share; leave weapon strips to lane guns):
  - `art/view/p70/rivet_knock.png` (990x792) and `p55/rivet_knock.png` — `tools/art/rivet_knock.py` has a fixed
    `FIG_H = 110.0`; sources in `C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/`.
  - `art/view/p70/rivet_strike.png` (489x1232) and `p55/rivet_strike.png` — `tools/art/rivet_strike.py`.
  - `art/view/p70/rivet_frames.png` (2296x124) and `p55/rivet_frames.png` — the base frames strip,
    `tools/art/rivet_frames.py` + `tools/art/rivet_frames.json` (per-row fig_h).
  - Check whether `rivet_walk.png` (the old walk, 428x1024) is still drawn anywhere at x1.5; if it is drawn and
    110-upscaled, add it; if dead, say so and leave it.
  - Any other unarmed Rivet strip still at 110 that LEVEL.md or the code shows (e.g. hide/peek, get-up) — list them,
    take the ones with a source and a script.
- Grids (not one-row strips) like the knock and strike grids may have their own scale path (`RivetKnock`,
  `RivetStrike` in `project/features/characters/`): find how they are drawn (cell size, foot_px, anchor, scale)
  and make the x1.5 cut draw at the SAME on-screen size and anchor as today. The visible change must be sharper ink
  only: same size, same feet, same collar position.

## Do, per strip (one commit per strip pair p70+p55, or per strip if cleaner)
1. Reproduce the committed PNG **byte-exactly (or pixel-exactly)** from its source with the current script at 110.
   If you cannot, stop on that strip, find out why, and report it; do not ship an unreproducible re-cut.
2. Make the scale a parameter (no new fixed constant), cut at 1.5 x the row's own fig_h. Update the manifest /
   the code's scale (X15 list or the grid's own scale constant) so the on-screen size is unchanged.
3. Film before/after at the SAME ticks (`tools/film/compare.mjs` with `--a=<before commit> --b=<after commit>`,
   or `node tools/dev/run.mjs stride_film ...` / `cursor_sweep` / the knock / strike dev films; find the dev entry that
   shows each strip: grep `project/dev` for `knock`, `strike`). Measure: per-crop % difference, figure bbox height
   and foot line before vs after must match within 1-2 px at 64 px/m. Produce a 64 px/m before/after still and a x2 zoom
   per strip to `C:/Users/kazda/kiro/gtai-masters/n19/anim/rivet-x15/`. Look at each and say what you see
   (sharper? same size? same feet? collar in place and rigid?).
4. Unit tests: extend `tests/unit/test_rivet_x15*` (or the knock/strike tests) so the new strips are pinned: texture
   size = 1.5x, on-screen draw size unchanged (scale x texture = old), hit boxes untouched.
5. `node tools/tests/run_unit.mjs --changed`, quick gate, commit. If a look golden contains Rivet knocked / striking /
   in the frames strip and moves, re-bless only that golden and name it.
6. After the last commit: `node tools/mutate/mutate.mjs --file=features/characters/rivet_knock.gd --lines=<changed>`
   (and rivet_strike.gd / rivet_res.gd if changed) and quote killed/(killed+survived).

## Acceptance
- Each target strip: reproduced-at-110 proof (quote the check), new texture size, before/after numbers (bbox, feet),
  64 px/m before/after still + x2 zoom, looked at.
- Tests green, quick gate green, mutate score.
- Update `LEVEL.md`'s "Ink and detail" Rivet cell: move what is now native out of the "still 110 upscaled" list, with
  the evidence paths (do not raise a level number; I will judge that).

End your report with: files changed, commits (sha + subject), commands run and their result lines, frame paths, and a
list of any 110-upscaled Rivet strip you left and why.
