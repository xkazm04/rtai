# Brief n19-gfx-11: is a tilt-70 city frame repeatable? Then honest apron sheets

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -20`, `AGENTS.md`, the last 8 lines of `docs/decisions.md` first. You build and measure; the director reviews every diff and frame. Engine polish only: no new art, no colour change to the print.

Write your report as you go to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/tilt-11-REPORT.md` (append after each part). The call stops at 75 min.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time (yours). `--rendering-driver d3d12` for renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name. Never touch other lanes' `gtai-mutate-*` dirs or processes.
- Never push, never read other `n19-*` worktrees. gfx owns `project/features/city/**`, `project/features/police/**`, `native/**`, shaders and look profiles. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`. `node tools/gate/quick.mjs` before each commit. Scratch probes under `build/` only; a probe placed under `project/dev/` for a run is deleted after it (as `build/apron08/shot.py` does).

## What the director found
The apron sheet `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/apron_edge_before_tilt70_32ppm_t150.png` (made by `build/apron08/frames.py` from `build/apron08/yard_{before,after}_*`) shows the east container stack in the yard **two-high over the warehouse roof** in its v34 panel and **one-high** in its v35 panel. But the earlier v34 render of the same seed 91, tick 150, camera (`C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/yard_after_tilt70_32ppm_t150.png`, made in the gen session at v34) draws it one-high. PIL `ImageChops.difference(...).getbbox()`:
- new v35 vs old v34, tilt70 32: `(185, 328, 1262, 361)`: only the bollard strip. Good.
- new v34 vs old v34, tilt70 32: `(0, 0, 1179, 691)`; tilt70 64: `(1234, 354, 1263, 800)`; top 32 and 64: `None` (identical).
So two renders of one generator version, seed, tick and camera differ at tilt 70 and not in top view. Either the before run did not render v34 as it claims (check how `build/apron08/run.py`/`shot.py` produced the "before" phase: which revision, baked or live chunks via `res://dev/n19_apron08_unbaked`, which DLL), or tilt-70 rendering is not repeatable.

## Part A. Repeatability probe (about 30 min)
1. Render HEAD (v35) seed 91 tick 150 tilt70 32 px/m with the same probe three times in a row; diff each pair (bbox + changed pixel count). Same for top 32 once as a control.
2. If the three differ: find which draw differs (the container stack: its texture, its lift/height, its z, an occluder or roof cutaway with temporal state, a per-frame or wall-clock input, an uninitialised buffer, thread timing). Name the file and line. If the cause is in gfx-owned code (`features/city/**`, `native/**`, shaders, look profiles): fix it so the frame repeats exactly, with a unit test or a repeat-render check that fails before and passes after, and a `docs/decisions.md` line. If it is outside gfx (characters = anim, arena/combat = ai): write the spec to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/NEED-tilt-repeat.md` and stop there.
3. If the three are identical: the before run rendered something else. Say exactly what (revision, chunk source, DLL), and whether the gen session's v34 frame or the new one is the true v34 (render v34 again at `77ad43790` in a temp worktree under `%LOCALAPPDATA%/Temp/gtai-gfx-<name>`, its own DLLs built from its `native/` if `git diff --stat 77ad43790 HEAD -- native/` is non-empty, else copy this worktree's DLLs; remove and prune the worktree after).

## Part B. Honest apron sheets (about 10 min)
Re-make `apron_edge_before_{tilt70_32,tilt70_64,top_64}ppm_t150.png` in `C:/Users/kazda/kiro/gtai-masters/n19/gfx/gen/` from a v34 render and a v35 render that differ **only** in the bollard strip (print each sheet's diff bbox; it must sit on the apron rows). Same labels as now. Keep `frames.json` order. Look at each sheet.

## Part C. The gate (about 20 min, only if A and B are done)
Run `node tools/gate/run.mjs --rev=HEAD` once (snapshot gate, no `--reels`). Quote its final line and the `gate.json` path. If red: name what failed with the first error line; fix only gfx-owned faults (one commit each); for anything else write what and where in the report.

## Acceptance
- Any code fix: lint, the changed unit tests, scenarios, parity, bake `--check` green at your last commit; quote each line; mutate the fixed file's changed lines and quote killed/(killed+survived).
- No commit if nothing in the repo changed.

## Report back (short, also in the report file)
A: three-render diffs, cause (file:line) or "the before run rendered X", fix commit or NEED file. B: sheet paths and their diff bboxes. C: gate line and path. Anything not done and why.
