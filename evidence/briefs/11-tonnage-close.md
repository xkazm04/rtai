# Brief 11 (lane anim, tag tonnage-close): close Tonnage's walk measurement and the sheet-loader survivors

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

## TIME BOX
Stop starting new work at 05:45 and have every finished part COMMITTED by 05:55 (wall clock, `date`).
This call is killed with the director session at 06:16. Order of value: 1, 2, 3 (p55 first), 4. A part not
finished by 05:55 is left uncommitted and named in your final message.

## State
Your brief 10 commits d698f9f09 + c07ebf33e put every MEASURED Tonnage walk row under 9 px at 32 px/m. Unmeasured
is not zero: p55 3/4 rows (four) and the p70/p55 straight toward / away rows were never filmed. Mutate on
ghost_sheet left 2 p55 sheet-loading condition survivors (+1 equivalent).

## Do
1. Kill the two p55 load-condition survivors in `ghost_sheet.gd` with a unit test (red on the planted fault,
   say which mutant), commit. Quote `node tools/mutate/mutate.mjs --file=features/souls/ghost_sheet.gd` changed-line score.
2. Film and measure (same `measure_rows.py`, logged-key measure, 110 t, leg 2) the p55 3/4 rows and the straight
   toward / away rows at both pitches. Table appended to `holds_it4.md`.
3. Any row over 9 px: derived midpoints with the existing tool (same rules: own keys only, byte-identical untouched
   cells, drift < 3.0, no retained hold rises), triplet still per row at 64 px/m to
   `C:/Users/kazda/kiro/gtai-masters/n19/anim/tonnage-hold/it5-<pitch>-<row>-midpoints-64ppm.png`, look at each
   derived cell. One commit per pitch, decisions.md line, LEVEL.md numbers.
4. If p55 raised pads in brief 10's midpoints sit flatter than the tilted originals: measure the pad tilt delta per
   midpoint; if a rotation of the pad about its ankle (script, own pixels) fixes it without breaking the bar, do it.

## Report (final message)
Commits; per-row before/after worst/mean/drift; mutate scores; unit count; byte-identical proof; masters paths; not done.
