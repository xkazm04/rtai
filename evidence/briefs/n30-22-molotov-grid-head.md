# n30-22 molotov grid at HEAD (64 + 32 px/m), after the run-step fix

Lane keys, run n30. Worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n30-keys`. Launched ~15:50.
**Commit by 16:15. Report and END by 16:25** (wall clock; check `date` often).

## Goal
The owner judges the molotov by "the molotov grid and clip". `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_64.png`
(and `_32.png`) were rendered at 11:30, BEFORE `0e399a732` moved row 1 cols 5, 6 of
`project/features/characters/art/view/p70/rivet_run8_eq_molotov.png` by 1 px (the run-step fix: 7.28/9.86 -> 5.77/6.85 cm).
Re-render the same grid at HEAD with the same tools, as NEW files, and prove what changed. No product file changes.

## Tools (reuse, do not rewrite)
Round scripts in `C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/scripts/`: `capture28.py` (Godot captures through runGodot,
`molotov rows` / `molotov candidate`), `composite.py` (the grid: 8 run facings, stop-gap | new | plasma rifle). Read
`C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/STATE.md` lines from 11:23 on for how they were run, and the scripts' own
arg parsing. If a script only writes to the old paths, copy it to `build/n30-22/` and change only its output paths
(the old files under `molotov/grid_molotov_arena/` and `grid_molotov_64.png` / `_32.png` must stay untouched: REPORT cites them).
Godot `--import` is already current at HEAD (no art changed since 0e399a732); still run one `--import` first if the capture
script warns of a stale cache.

## Deliverables
1. New captures to `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_head_arena/` and new grids
   `grid_molotov_head_64.png`, `grid_molotov_head_32.png` (same layout as the old ones).
2. Proof with numpy/PIL: per cell (facing x column) of the "new" column, changed px old grid vs head grid. Bar: only the
   cells showing row 1 (front facing) cols 5, 6 may differ (a 1 px shift: expect a thin edge outline), every other cell 0 px;
   the stop-gap and plasma-rifle columns 0 px. If other cells differ, find why (render noise? different tick?) and say it.
3. foot_slide re-measure, turn_090 lane row 0 at 32 px/m, the same way STATE.md 11:26 did: molotov walk hold (bar <= 2 cm) and
   run step mean / max (bar <= 7 cm; REPORT quotes 5.77 / 6.85 from n30-09). Quote the JSON path and numbers.
4. Look at `grid_molotov_head_64.png` yourself at the front-facing row (crop it at 2x): bottle in claw, amber flame, soles
   under the body, flat striped collar. Write what you see.
5. Append `## Grid at HEAD (n30-22)` to `evidence/n30-keys/grid_molotov.md`: commands, the per-cell diff table (only
   non-zero cells + a total), foot_slide numbers, paths.
6. `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json`: replace the `molotov/grid_molotov_64.png` entry's `file` with
   `molotov/grid_molotov_head_64.png` and update its title/note (rendered at HEAD after 0e399a732). Keep 15 entries, valid JSON.
7. Commit only the evidence md: `git commit -m "evidence(keys n30): molotov grid at HEAD after the run-step fix" -- evidence/n30-keys/grid_molotov.md`
   (stage it by path first) with the trailer `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Godot rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys` before every Godot run;
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Only through `runGodot` (the capture script / `tools/dev/run.mjs` do). Windowed runs at `--position 0,1440`.
- Lane lock: before each Godot batch create `build/n30-godot.lock` exclusively
  (`set -o noclobber; echo "n30-22 $$ $(date +%H:%M)" > build/n30-godot.lock`), delete it right after. If it exists and is not
  yours, wait (poll 30 s); never delete another's lock. You are the only builder; the director will not run Godot before you END.
- `mem-budget: waiting` = machine full: wait, note the minutes. Free only your own processes, by PID. Never kill by name.

## Repo law
- Allowed to write: `build/n30-22/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_head*`, that
  frames.json, `evidence/n30-keys/grid_molotov.md`. **Any other path: stop and report a NEED.** Other lanes' worktrees
  (n23-street, n23-prologue, n25-yard), `main`, `C:/Users/kazda/kiro/pof`: forbidden. No image generation.
- Stage per path; no `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard.
- Fix lint and format findings in your own edit and go on. Do not delete anything in Temp or masters you did not create.

## Report (your final message)
Commit sha, files written, the diff table, foot_slide numbers, what you saw at 2x, what you could not do, minutes waited.
