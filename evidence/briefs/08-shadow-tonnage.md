# Brief 08 (lane anim, tag shadow-tonnage): contact-shadow triangulation, then Tonnage's last long holds

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor only).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees (READ-only `git -C ../n19-gfx show` is fine), `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md. Typed GDScript, files <= ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
  `Log` not `print`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`.
  Commit `.uid`/`.import` with new files. Quick gate: `node tools/gate/quick.mjs --no-godot`, and prove parse + tests with
  `node tools/tests/run_unit.mjs --changed`.
- Ownership: anim owns `project/features/characters/**`, the ghost render files in `project/features/souls/`
  (ghost_drawn, ghost_sheet, ghost_stride, ghost_recoil, art/view) and `tools/art/**`. Not city/, native/, combat/.
- Art: script-derived cells from Tonnage's OWN shipped cells only (as `tools/art/tonnage_midpoint.py` did for step 5).
  No image_gen in this brief. Tonnage keeps his size; his hit lean is 4 deg (owner verdicts, do not touch).
- Your previous session (crowd-pop) was cut off by the harness at its end; its two commits b472095b6 and 595b5a652
  plus eca41611a are accepted. Nothing of it is owed.

## Part A (do first, small): contact shadow triangulation errors (reported by gfx)
Read `C:/Users/kazda/kiro/gtai-masters/n19/gfx/contact/NEED-anim-triangulation.md` (repro command, the two failing
rings: innermost ring 0.55, radius ~5.7 px, centre ~(17000, 16930) actor-layer px, ticks 634 and 852 of the seed-5 city
arena). Cause: `RigCastShadows._contact` (`project/features/characters/rig_cast_shadows.gd:73`) builds a tiny ellipse at
large absolute coordinates; float precision makes Godot's triangulator reject it.
1. Fix: build the ellipse about local zero and place it with `draw_set_transform(at)` (restore identity after), as gfx
   proposes. Check whether `figure()` (the cast body polygon) has the same exposure: run the observer approach over the
   repro (independent `Geometry2D.triangulate_polygon` on every polygon drawn) and fix it the same way if any fail.
2. Test (first-author, must be RED on the old code): a unit test that the contact rings at the failing centre
   (16961.63, 16930.54), hip 21.04, triangulate (non-empty) through whatever helper the drawing now uses.
3. Evidence under `evidence/shadow-tri/`: the repro run's log before (2 errors) and after (0 errors); a same-tick
   still pair at 64 px/m of a standing rig's contact ink (before/after, pixel diff count; should be ~0) to masters
   `C:/Users/kazda/kiro/gtai-masters/n19/anim/shadow-tri/`. Mutate `rig_cast_shadows.gd` (`--lines=` the changed lines),
   quote killed/(killed+survived). One commit.

## Part B: Tonnage's walk, every hold under 9 px at 32 px/m (brief item 2's bar)
State (read `evidence/tonnage-hold/step5_32ppm.md` and `README.md` first): after the step-5 midpoint the 110-tick leg-2
film's worst holds are C3 18.395 px (9 ticks) and C13 18.32 px; mean 8.911; drift 2.381. The bar is worst hold < 9 px.
1. Measure first on HEAD: every hold over 9 px in the 110-tick film (and a 180-tick film if leg 2 does not cover all 16
   columns), with its column, tick span, ride and the stance jump (cell px) of the transition that causes it
   (`evidence/it13/tools/foot_travel.py`). Write the table to `evidence/tonnage-hold/holds_it4.md`.
2. For each over-bar hold, the same remedy that worked at step 5: a script-derived in-between from Tonnage's own
   neighbouring cells (generalise `tools/art/tonnage_midpoint.py` to take a transition list, do not copy it), placed
   at the stance midpoint, its dwell taken from the two neighbours. Cells that are not touched stay byte-identical
   (prove it). Check BOTH p70 and p55 sheets and the left profile; work the worst first.
3. Re-film at 32 px/m with the same flags, `hold_ride.py` before/after per hold, overall worst/mean/drift. Ship a cell
   only if it lowers that hold without raising mean drift past 3.0 px or any other hold past its old value.
4. Look at every derived cell yourself at 64 px/m beside its two neighbours (no ghosting, no double limb, outline
   unbroken); write the still to `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/` and say what you saw.
5. Tests: extend `tests/unit/test_tonnage_stride.gd` for each new midpoint window (enter/exit boundaries). Mutate
   `ghost_stride.gd` / `ghost_sheet.gd` on the changed lines, quote the score.
6. If 9 px is not reachable for some hold with derived cells, stop at the best measured state, ship what helps, and
   write which hold remains, its number, and why (e.g. needs a drawn key) in `holds_it4.md`. Do not fake the bar.
7. `docs/decisions.md`: one dated DECISION line for Part B's change; update `LEVEL.md`'s Tonnage walk line only with a
   level the numbers support (name the numbers).

## Report (your final message)
Commits (hash + one line each); Part A error counts before/after + pixel diff; Part B per-hold table before/after,
overall worst/mean/drift, which cells were derived, byte-identical proof; mutate scores; unit `--changed` count; every
masters path; anything you could not do and why.
