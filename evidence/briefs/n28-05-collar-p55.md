# Brief n28-05-collar-p55: a rigid hazard collar in the 55 degree bare sprint rows

Lane `keys`, branch `n28-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Check `date` first and often. Commit the art by {COMMIT}. Report and END by {END} at the latest, whatever state you are
in** (the pre-commit hook takes about 12 minutes on this shared machine). Small commits, staged per path,
`git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`, no `commit -a`, no `reset --hard`, never push.
Fix lint and format findings in your own edit and go on.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display). One Godot process at a time in this
lane; free your own by PID, never by name. Never launch Godot raw: go through `tools/dev/run.mjs`, the film tools or
`tools/lib/godot.mjs` (8 GB RAM cap; `mem-budget: waiting` = machine full, not a hang). After new pngs land, a Godot
`--import` before the commit. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`: stale class cache,
`--import` and commit again.

## Why
Owner (last `DECISION n27 verdicts (owner)` line of `docs/decisions.md`): "redraw the collar in the p55 sprint rows". Rivet's
striped neck band is a **rigid hazard collar, never cloth or rope**: a flat orange-and-black band with straight diagonal
stripes, as on every p70 row (`project/features/characters/art/view/p70/rivet_run8.png`) and on the p55 front and back run
rows. In the shipped p55 bare sprint sheet `project/features/characters/art/view/p55/rivet_run8.png` (8 x 8 cells, rows =
facings) several rows draw it as a twisted rope or a knotted scarf; worst in the profile rows (see
`C:/Users/kazda/kiro/gtai-masters/n27/keys/p55_sprint_before_after_64.png`). Also check `p55/rivet_walk.png` and
`p55/rivet_walk8.png` and say whether they have the same fault (fix them only if this call has time after the run sheet).

## How (images: at most 8; count them, report `IMAGES n`)
1. Audit: a contact sheet of the 64 run cells' necks at 4x zoom (a script), and grade each row rigid / rope. Write it to
   `evidence/n28-keys/collar_p55.md`.
2. Round `C:/Users/kazda/kiro/gtai-art/rivet-n28/collar-p55/` with a `STATE.md` updated after every step. For each rope row,
   one image edit through `C:/Users/kazda/kiro/gtai-art/gen.mjs` (image 1 = that row of the shipped sheet laid out landscape
   on a flat key; image 2 = the p70 run row of the same facing as the collar reference): only the collar redrawn as a
   rigid flat hazard collar with straight stripes, the same width and position; nothing else changes. (Known fault: a job can
   stall copying to `./out` after the image exists under `~/.codex/generated_images/`: copy it by hand.)
3. **Composite only the collar**: register each edited cell to the shipped cell and paste back only a mask around the neck
   band (feathered), so every other pixel (helmet, arms, legs, soles) is the shipped one. Then the stride and the drift are
   unchanged by construction: prove it (pixels outside the mask identical, a script) and re-measure anyway.
4. Bars per cell: the band reads as one rigid ring (no twist, no knot, no loose ends) at 64 px/m in the game; stripe colours
   the shipped orange and black (vermilion is Rivet's collar colour; no red, no teal); no seam at the mask edge at 64 px/m.
5. `--import`, provenance lines appended to `steam/ai-provenance/2026-11.jsonl`, `node tools/gate/quick.mjs`, commit:
   "Rivet's p55 sprint rows wear the rigid hazard collar".

## Evidence (after the commit; commit it separately)
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/collar_p55_before_after_64.png`: the fixed rows in the game at tilt 55,
  sprinting 9.3 m/s, before | after at the same tick (render "before" from a temp worktree at your start sha:
  `git worktree add build/wt-before-collar <sha>`, `git worktree remove` afterwards); and the same at 32 px/m.
- Drift: `tools/film/foot_slide.py` on the p55 profile sprint at 32 px/m, before and after (n27 measured 3.83 cm at 64:
  `evidence/n27-keys/p55_sprint_drift.md`, reuse its setup). Must be unchanged within 0.1 cm.
- A 15-25 s 32 px/m tilt-55 1080p60 clip sprinting in 8 directions, `collar_p55_32.mp4` (ffprobe in your report).
- `C:/Users/kazda/kiro/gtai-masters/n28/keys/frames.json` entries (append; keep existing entries).

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/art/view/p55/rivet_run8.png(.import)`, `p55/rivet_walk.png`, `p55/rivet_walk8.png` (only the
collar), `steam/ai-provenance/2026-11.jsonl` (append), `evidence/n28-keys/**`, `C:/Users/kazda/kiro/gtai-art/rivet-n28/**`,
`C:/Users/kazda/kiro/gtai-masters/n28/keys/**`, `build/**`.
Forbidden: every other sheet (p70, armed `_eq_` sheets, other characters), `rivet_motion.json`, code, other tables,
`project/features/combat/**`, `project/boot/prologue/**`, `native/`, other lanes' worktrees, `main`.

## Report (final message)
`IMAGES n`, the per-row audit, which rows were fixed, the outside-mask identity proof, drift before/after, commit shas,
stills/clip + ffprobe line, what `STATE.md` says is next.
