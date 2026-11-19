# Brief 10 (lane anim, tag tonnage-diag): Tonnage's 3/4 rows and p55 walk, every hold under 9 px at 32 px/m

## Machine law (every Godot run, every gate)
- Before ANY Godot run or gate in a shell: `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/anim` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`. Windowed runs: `--position 0,1440` (secondary monitor only).
- Only ONE Godot process at a time from this worktree. Free your own processes by PID; never kill by name.
- Never touch `main`, other worktrees, `C:\Users\kazda\kiro\pof`. Never push.
- Repo law: AGENTS.md + STANDARDS.md (typed GDScript, <= ~200 lines/file, <= 40 lines/function, <= 5 params, `Log`).
  Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`. `.uid`/`.import` with new files.
  `node tools/gate/quick.mjs --no-godot` and `node tools/tests/run_unit.mjs --changed` before each commit.
- Art: script-derived cells from Tonnage's OWN shipped cells only, through `tools/art/tonnage_midpoint.py` (extend, do
  not fork). No image_gen. Tonnage keeps his size; hit lean 4 deg (owner verdicts).
- TIME BOX: the director sets it in the launch note below; commit each sub-part as soon as it is green.

## State (your own `evidence/tonnage-hold/holds_it4.md`)
p70 right and left profiles meet the bar (7.12 / 7.02 px). Still over, measured not changed: p70 3/4 left toward 17.53
(mean 7.69), 3/4 left away 21.04 (mean 10.44); the 3/4 RIGHT rows (toward, away) not measured yet; p55 right 31.71,
p55 left 31.59 (8 keys each, cap off).

## Do (worst-visible first)
1. Measure the p70 3/4 right toward / away rows the same way (film leg 2, `--film-turn` per octant). Table to
   `holds_it4.md`. Use the logged-key measure as the judged number (the pixel detector splits unchanged diagonal poses:
   say which you quote).
2. p70 3/4 rows (all four that exceed 9 px): derived midpoints, dwell from both neighbours, untouched cells
   byte-identical, triplet still per row at 64 px/m to `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/`
   (`it4-diag-<row>-midpoints-64ppm.png`), look at each derived cell and say what you saw, re-film, per-hold table.
   Ship only cells that lower their hold without raising mean drift past 3.0 or another hold past its old value.
3. p55 right and left (8 keys): midpoints between every key pair whose hold exceeds 9 px (likely all 8 -> 16), same rules.
   If the p55 step table needs a cap or retime to go with 16 frames, measure the trade (worst vs drift) and pick the
   point that meets worst < 9 with drift < 3.0, else the best measured, and say so.
4. Tests for each new midpoint window in `test_tonnage_stride.gd`; mutate the changed lines of ghost_stride/ghost_sheet;
   one dated `docs/decisions.md` line per sub-part (append only, no blank lines); LEVEL.md Tonnage planted-feet numbers.
5. Commit per sub-part (p70 diagonals; p55). Never leave a half-wired atlas: a sub-part not finished is not committed.

## Report (final message)
Commits; per-row before/after worst/mean/drift; derived cell count; byte-identical proof; masters paths; mutate scores;
unit count; what is not done.

## Launch note (director, 03:25)
TIME BOX: stop and send your final message by **04:35** at the latest (the director session ends 04:54 and takes this
call with it). Order inside the box: part 1 measure (fast), part 2 p70 diagonals, commit; part 3 p55 only if part 2 is
committed before 04:05. A sub-part that is not green by 04:30: leave it uncommitted, delete its scratch atlas, and
report what you measured. The gate on f63f8f094 passed; Godot is free (no other process from this worktree).
