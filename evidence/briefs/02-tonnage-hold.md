# Brief 02 (lane anim, tag tonnage-hold): land Tonnage's two redrawn walk frames and measure the held-frame ride

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor, never the main display).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Run `node tools/gate/quick.mjs` before each commit.
- Ownership: this lane (anim) owns character and ghost art (`project/features/souls/art/**` for the ghosts' drawn
  sheets, `project/features/characters/**`) and `tools/art/**` scripts for them. Do not edit `features/player/**`,
  `features/combat/**`, `features/city/**`, native, or any sim/replay/parity/bake digest.
- Owner's law for Tonnage (do not change): he keeps his size; his hit lean is 4 degrees (`GhostRecoil.LEAN_BY_FORM`).
  Cell size and scale do not change. Images are never edited by hand: a script under `tools/art/` does every cut/paste.

## Background (what I already checked)
- Tonnage's p70 walk is `project/features/souls/art/view/p70/tonnage_walk8.png`: 2608 x 1150 = 16 columns x 5 rows of
  163 x 230 cells (walk16 on all five facings, timed by `GhostStride` tables). Find the right timing table in code
  (grep `GhostStride`, `TABLES`, `tonnage`).
- n15 measured at 32 px/m (`docs/day/2026-11-11/hero/JOURNAL.md` lines 220-238, `LEVEL.md` row "Planted feet"):
  holds 6,6,3,5,4,6,8,5 ticks, ride mean 8.3 px, **worst 16.1 px** = table steps 1 and 5 (35.0 and 43.5 cell px).
  Command then: `stride_film --film-form=tonnage --ppm=32 --film-every=1 --film-leg=2 --film-frames=48` (dev scene
  `project/dev/rivet_motion/stride_film.tscn`, use `node tools/dev/run.mjs stride_film ...`), then
  `py -3 -I evidence/s15/tools/hold_ride.py build/film/gait32_tonnage 2 48 0,45 70,150,190,222`
  (read the script's docstring for the argument meaning; the crop box args may need adjusting to the film's framing:
  verify the figure box actually contains Tonnage and the band is clear ground). Also `evidence/s15/tools/feet_track.py`.
- The assets lane redrew frames 2 and 6 (0-indexed columns 2 and 6 of the PROFILE row, sheet row index 2 = the
  `3_` prefix is 1-indexed row 3) "nearer their predecessors' stance, so the stance foot's travel splits evenly".
  Delivered, pre-placed in 163 x 230:
  `C:/Users/kazda/kiro/gtai-art/library/keyed/ghosts/tonnage_walk16_70_cells_req221/placed_163x230/3_3.png` and `3_7.png`
  (file names are 1-indexed row_col). **The swap never landed**: I compared them with every cell of the committed
  sheet; the nearest is mean abs diff 30 (not identical). Confirm which row is the profile row and that column
  indexing matches before pasting (look at the cells side by side).
- The left sheet `tonnage_walk8_left.png` (2608 x 645) may mirror or redraw the profile; check whether its profile
  row derives from the right one (if it is a mirror of the same cells, apply the same swap mirrored; if drawn
  separately, leave it and say so). p55 has no delivered cells: leave p55.

## Do, in order
0. **Left over from the previous session**: `project/dev/sim/far_cop_rows.{gd,gd.uid,tscn}` are staged but uncommitted
   (the pre-commit debt check rejected the +198 `dev_loc`). The director accepts that rise: run
   `node tools/debt/debt.mjs --accept-regression="n19 anim: far_cop_rows dev probe (item 1 evidence)"` as
   `tools/debt/README.md` describes, then commit the probe + baseline together (stage per path). Quote the debt line.
1. **Before film + measure** at the committed sheet: the stride_film gait at 32 px/m as above (output to
   `build/film/gait32_tonnage_before`), `hold_ride.py` on it -> `evidence/tonnage-hold/hold_ride_before.txt`. It must
   reproduce roughly the n15 numbers (worst ~16); if it does not, find out why before going on.
2. **Swap script**: `tools/art/tonnage_walk16_swap.py` (or extend an existing pack script such as
   `tools/art/ghost_pack.py` if that is how the sheet is built; reproduce the committed sheet byte-exactly first
   if you go that way). It pastes the two cells into the right sheet positions; every other cell byte-identical
   (the script asserts it). Write a manifest/provenance note for the source cells as the art_src convention requires
   (find how earlier ghost swaps recorded their source: grep `req221` / `tonnage_walk16` under `art_src/`, and
   `steam/ai-provenance/2026-11.jsonl` for a ghost line; add one provenance line per changed shipped PNG if the
   convention requires it).
3. Re-import, **after film** at the same ticks -> `hold_ride_after.txt`. Bar: **worst hold under 9 px at 32 px/m**.
   If the bar is missed, look at which step is still long and whether the `GhostStride` step table for those
   frames should change now that frames 2 and 6 moved (the table was measured on the old frames: re-measure the
   drawn stance foot's position per frame the way the table was built and update the table entries for steps 1-2
   and 5-6 if that is how it was derived). Report both numbers.
4. Also run `feet_track.py` before/after (no net creep) and `feet_trace.py` for a trace image after.
5. **Frames** (scripted, not by hand) to `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/`:
   a 64 px/m before/after still of the profile walk at the same ticks around the swapped frames, the feet trace
   before/after at 32 px/m, and a 10-40 s 32 px/m clip (mp4 or gif) of Tonnage walking after.
   Look at each image yourself and describe what you see (does the redrawn frame read as the same body, same
   colours, no seam, feet planted?).
6. `node tools/tests/run_unit.mjs --changed`; quick gate; commit (the sheet + its .import if changed + the script +
   provenance, one commit; a table change, if any, its own commit with a test that pins the new values).
   If a look golden contains Tonnage's walk frame and moves, re-bless only that golden and name it in the commit.
7. If you changed code (a stride table), `node tools/mutate/mutate.mjs --file=<that file> --lines=<changed lines>`
   and quote the score.

## Acceptance
- hold_ride before and after text files with worst/mean; worst after < 9 px@32 (or an honest miss with the reason).
- Every non-swapped cell byte-identical (script assertion output quoted).
- Frames written and described. Unit tests green, quick gate green.

End your report with: files changed, commits (sha + subject), commands run and their result lines, frame paths.
