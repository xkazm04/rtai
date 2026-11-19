# Brief n19-gfx-12: what does the baked crowd contact shadow cost? Then one more quiet heat-3 try

Lane `gfx`, night run n19, NEW session (fresh context). Read `git log --oneline -25`, `AGENTS.md`, the last 8 lines of `docs/decisions.md` first. You build and measure; the director reviews every diff and number. Engine polish only: no art, no colour change.

Write your report as you go to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/cost-12-REPORT.md` (append after each part). The call stops at 75 min. Commit after each part. FREEZE: no commit after 07:25 local.

## Environment (every Godot run)
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/gfx` before every gate or Godot run.
- One Godot process at a time (yours). `--rendering-driver d3d12` for renders; windowed runs take `--position 0,1440`. Kill only your own PIDs, never by name. Never touch other lanes' `gtai-mutate-*` dirs or processes.
- Never push, never read other `n19-*` worktrees. gfx owns `project/features/city/**`, `project/features/police/**`, `native/**`, shaders and look profiles, and may add dev probes under `project/dev/bench/`. Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`. `node tools/gate/quick.mjs` before each commit.

## Background
Item 3A (`268960380`, `1c4183544`) gave the far, baked crowd a contact shadow matching the rigs' rings: `CityCore::set_contact_hips(ped, cop)` in `native/sim_core/src/city_core.h:103` / `render.cpp` (about lines 85-92), and `CitySimRender._contact_hips` in `project/features/city/sim/sim_render.gd` (lines 21, 40, 76-80). Hips of zero fall back to the old round blob (`RL_PED_SHADOWS`, INK_PED). The rig bench (`dev/bench/rig_bench.gd`) could not show its cost: it times rig posing, not the crowd draw, and every run tonight was CONTENDED (6-16 other Godot processes from other lanes and another project). The machine will not go quiet, so the measurement has to cancel the noise itself.

## Part A. An interleaved in-process cost probe (about 45 min)
1. Add `project/dev/bench/crowd_contact_cost.gd` (+ a `_run.gd` or scene if the pattern needs one), following `dev/bench/vehicle_cards_cost.gd` / `bodies_cost.gd`. Declare `const KNOWN_FLAGS` so `tools/dev/run.mjs` checks its flags.
2. One process, the city at heat 3 with a dense crowd at a fixed seed and camera (32 px/m, tilt 70, release-like settings, `--fixed-fps 60`, vsync off), native sim. Alternate blocks of N frames (e.g. 60) between contact ON (the shipping hips) and contact OFF (hips 0 = old blob) and a third arm A' = ON again (A/A floor), in a rotating order over at least 20 rounds. Per arm: the people-layer writer CPU time (native `render` call around the buffer write, and the GDScript reference writer separately if cheap), and the GPU/render time of the frame (`RenderingServer.viewport_set_measure_render_time` + `viewport_get_measured_render_time_cpu/gpu`, or what `vehicle_cards_cost.gd` uses). Count the shadow instances drawn per frame so the cost is per instance too.
3. Report p50 / p95 per arm, the paired ON - OFF delta per round with a CI95 and the A - A' floor next to it. A delta inside the floor is reported as "below the noise floor of X ms", never as zero. Note the number of other Godot processes at start and end (as `tools/bench/run.mjs` does) and label CONTENDED where it applies; interleaving is the point, so the run is still valid evidence of a RELATIVE cost.
4. Run it via `node tools/dev/run.mjs crowd_contact_cost ...` and quote its verdict line. Write the JSON to `C:/Users/kazda/kiro/gtai-masters/n19/gfx/bench/crowd-contact-cost.json`.
5. Lint green (the probe is dev code: it must not be named from boot/core/features). Commit: "Measure the baked crowd contact cost against the blob in one interleaved run".

## Part B. Heat-3 bench, one more quiet try (about 20 min, only after A)
Take the bench lock `C:/Users/kazda/kiro/gtai-n19/bench.lock` (create exclusively; younger than 20 min = another lane holds it, skip Part B; older = stale, delete it), run the heat-3 bench the same way as `C:/Users/kazda/kiro/gtai-masters/n19/gfx/bench-10-REPORT.md` Part A did (same command and flags) with its quiet wait, delete the lock after. If it is still CONTENDED, say so with the counts; do not retry more than once.

## Acceptance
- Lint and `node tools/gate/quick.mjs` green at your commit; quote the lines. No product file changes in this brief (if you find one is needed, stop and write why in the report instead).
- No commit if nothing in the repo changed.

## Report back (short, also in the report file)
A: commit, the arms table (p50/p95 per arm, CPU and GPU), paired delta + CI95, A/A floor, instances per frame, cost per instance, contention counts, JSON path. B: verdict line, CONTENDED or quiet, counts. Anything not done and why.
