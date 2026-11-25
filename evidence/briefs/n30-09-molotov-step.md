# n30-09 molotov-step: bring the molotov's run step under 7 cm (lane keys, 0 images)

Launched ~12:31. **Commit a passing fix by 13:05 (or commit the trace only). Report and END by 13:25** (wall clock; `date +%H:%M`
first and often; write both deadlines in your first STATE line). Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch
`n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`, `commit -a`, `reset --hard`. Stage per path (`git commit -- <paths>`:
another builder commits in this worktree at the same time). Fix lint and format findings in your own edit and go on.
**No image generation.**

## Where it stands
`4513bda2a` ships `p70/rivet_run8_eq_molotov.png` (plasma rifle donor, rows 4 and 8 cols 2,6 carry donor legs under a seam) and
`rivet_motion.json` `grid_stride.run_row_k` `p70/molotov/0` 0.98, `/1` 0.98, `/3` 0.96, `/4` 0.99. Read
`evidence/n30-keys/grid_molotov.md` and the round `C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/STATE.md` (scripts in `scripts/`:
`capture28.py`, `solex.py`, `stride.py`, `wire_run.py`, ...). foot_slide turn_090 lane row 0 at 32 px/m: walk hold 0.43/1.56 PASS,
**run step mean 7.28 / max 9.86 cm, bar <= 7** (the plasma rifle donor 6.69/8.93 in the same capture). Planted steps 9.86 + 4.69 cm
vs the donor's 8.93 + 4.45. Data: `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/grid_molotov_run_foot_slide_32.json` and
`grid_plasma_rifle_foot_slide_32.json`.

## Do (two routes at most; stop after two failures and report)
1. Trace (offline, no Godot): map the planted-step ticks (53-93) to the run row and cells the lane shows (which facing row, which
   columns plant), compare those cells' sole x per frame with the donor's (`solex.py`), and the row's run_row_k. Write the trace in
   STATE and in `evidence/n30-keys/grid_molotov.md` (a short "Run step trace" section).
2. Route A (data, preferred if the trace points at travel vs cycle): sweep only the traced row's `run_row_k` (e.g. 0.96 / 0.97 /
   1.00, at most 3 values), one foot_slide capture each, pick the value that passes run step mean <= 7 with walk hold still <= 2.
   Route B (art, if the trace points at a cell): shift that cell's figure by whole px so its planted sole x matches the donor's
   (registration only, alpha moved not repainted), re-measure.
3. Passing: Godot `--import` (art route), pins in `project/tests/unit/test_rivet_grid_stride.gd` updated if a k changed,
   `node tools/tests/run_unit.mjs --select=test_rivet_grid_stride,test_rivet_walk_sprint_fallback`, `node tools/gate/quick.mjs`,
   commit `keys n30: molotov run step under 7 cm (<what changed>)`; then evidence: the new foot_slide json beside the old, the
   table row in grid_molotov.md, and if the art moved, a 64 px/m still of the changed row before|after (same tick) to
   `C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/`. Commit the md.
   Not passing after two routes: commit the trace only and say what you would try next.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot for the lane: lock
`build/n30-godot.lock` (create exclusively with tag `n30-09` + your pid; if it exists and is not yours, wait and do offline work).
Another builder `n30-08` (collar install, `p55/rivet_run8.png`) shares it and has priority: **take the lock per single Godot run
and delete it right after that run**; never hold it while you think or edit. Only through repo tools (runGodot). d3d12, windowed
`--position 0,1440`. `mem-budget: waiting` = machine full, not a hang. Free only your own processes, by PID. No mutate this call.

## Allowlist (anything else: stop and report a NEED)
`project/features/characters/art/view/p70/rivet_run8_eq_molotov.png(.import)`, `project/data/tables/rivet_motion.json` (molotov
run rows only), `project/tests/unit/test_rivet_grid_stride.gd`, `steam/ai-provenance/2026-11.jsonl` (append, only if art moved),
`evidence/n30-keys/grid_molotov.md`, `C:/Users/kazda/kiro/gtai-art/rivet-n30/molotov/**`,
`C:/Users/kazda/kiro/gtai-masters/n30/keys/molotov/**`, `build/**`.
Forbidden: `p55/rivet_run8.png`, `rivet-n30/collar_cells/`, `steam/ai-provenance` while n30-08 is committing (append only your own
line, stage only your own paths), donors (read only), code under `project/features/**`, combat/cast/yard files, `JOURNAL.md`,
`REPORT.md`, `docs/decisions.md`. Never delete anything in Temp or `~/.codex` you did not create.

## Report (short), then END
The trace, the routes tried and numbers (run step mean/max, walk hold), commit shas, stills, STATE Next.
