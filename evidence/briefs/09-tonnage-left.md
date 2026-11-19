# Brief 09 (lane anim, tag tonnage-left): placement test for the shadow fix, then Tonnage's p70 left profile

## TIME BOX (hard)
This session must be fully committed by **03:25** wall clock (check `date`). The director's session ends at 03:39 and
takes this call with it. Commit each part as soon as it is green. At 03:15, whatever part you are in: stop starting new
work, commit what is proven, write the rest as "not done" in your report.

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor only).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md (typed GDScript, <= ~200 lines/file, <= 40 lines/function, <= 5 params, `Log`).
  Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`. `.uid`/`.import` with new files.
  `node tools/gate/quick.mjs --no-godot` and `node tools/tests/run_unit.mjs --changed` before each commit.
- Art: script-derived cells from Tonnage's OWN shipped cells only. No image_gen. Tonnage keeps his size, hit lean 4 deg.

## Part A (10 min): the shadow fix's test must catch placement
Your c07cab306 test passes on 7/7 mutants of the changed lines (mutate 0/7): it checks ring shape only. Extend
`tests/unit/test_rig_cast_shadows.gd` so a probe records WHERE each polygon lands (e.g. route the transform through a
small overridable `_place(at: Vector2)` the probe captures, or capture the draw transform), and assert: contact rings are
centred at the given `at`, figures at the feet, and the transform is restored to identity after (a following draw is
not offset). Re-run `node tools/mutate/mutate.mjs --file=features/characters/rig_cast_shadows.gd --lines=<changed lines>`
and quote killed/(killed+survived); explain any survivor that is equivalent. One commit.

## Part B: Tonnage p70 LEFT profile, every hold under 9 px at 32 px/m
Your `evidence/tonnage-hold/holds_it4.md`: p70 left worst 18.401, mean 9.504 (its own 16 drawn keys, own stance
positions). Same remedy as the right profile: measure every hold over 9 px (film leg 2, turn 180, same flags), derive
midpoints with `tools/art/tonnage_midpoint.py` (extend its transition list for the left sheet, do not fork it), dwell
from both neighbours, untouched cells byte-identical, look at every derived cell at 64 px/m beside its neighbours
(write the triplet still to `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it4-left-midpoints-64ppm.png`, say
what you saw), re-film, per-hold before/after table appended to `holds_it4.md`. Ship only cells that lower their hold
without raising mean drift past 3.0 or another hold past its old value. Boundary tests in `test_tonnage_stride.gd`,
mutate the changed lines of ghost_stride/ghost_sheet. Amend the existing Tonnage walk DECISION with ONE new dated line
in `docs/decisions.md` (append only, no blank line) and the LEVEL.md planted-feet cell for Tonnage with the numbers.
If time is left before 03:15 only: measure (do not change) the p70 3/4 toward and 3/4 away rows the same way and add
their worst/mean to `holds_it4.md`.

## Report (final message)
Commits; Part A mutate score before/after; Part B per-hold before/after, worst/mean/drift, byte-identical proof,
masters paths; mutate scores; unit count; what is not done.
