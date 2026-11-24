# Brief n27-05 `cost-mutate`: the new yard's frame cost, the command-view mutate score, the floor warmth numbers (lane yard, run n27)

HARD STOP: 08:05 local (stop, write the report, END). LAST COMMIT: 08:00. Every Godot you start must be gone by 08:05 (the lane's final gate starts then). Check `date` often. This is a measuring call: NO product code changes (no `.gd`, no data, no tests). Commit evidence files only.

## Before anything (every shell that runs Godot)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
`--rendering-driver d3d12` for renders; windowed runs `--position 0,1440`. One Godot process at a time in this lane (the mutate run counts as one). Kill only PIDs you started. Never delete anything in Temp you did not create in this call.

## Part 1 (by 07:45): the frame cost of the shipped yard
The same method as `evidence/yard27/frame-cost.md` (call 02: `project/dev/prologue_yard/yard_frame_probe.tscn`, seed 7, 1920x1080 window at `--position 0,1440`, vsync off, `evidence/yard27/frame_stats.py`), under the bench lock `C:/Users/kazda/kiro/gtai-n27/bench.lock` (create it exclusively; if one exists younger than 20 min, wait up to 5 min, then measure anyway and write CONTENDED; older than 20 min = stale, delete it; delete yours right after).
- Arm before: `--yard-dressing=line_fire` with its floor glow off (if the probe or a dev flag cannot turn glow off without a code change, use plain line_fire as shipped and say so).
- Arm after: HEAD as shipped (`raised_line`: floor glow, over-print layer, the new art).
- 3 paired rounds, 45 s per sample, alternate the order (before/after, after/before, before/after). Append a section `## Shipped yard (n27-05)` to `evidence/yard27/frame-cost.md` with the table, the paired p50/p99 mean and 95 % CI and the verdict against the bar: p50 CI upper < 0.5 ms. Commit (`evidence/yard27/frame-cost.md` only, by path).

## Part 2 (start right after Part 1, finish by 08:03): the command-view mutate score at HEAD
`node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_command_view.gd --max=20 --json > build/films27/mutate_cv_final.json 2> build/films27/mutate_cv_final.err` in the background. HEAD must be clean of code changes (it is). Quote killed/(killed+survived) and the survivors' lines in your report. Last night's score was 5/20, the first after-score 9/20 at `5835bbfa0`. If it is still running at 08:03, kill the PIDs you started and report the partial count from the .err file (`[n/20] ... killed|survived`).

## Part 3 (in parallel with Part 2, no Godot): the floor warmth numbers
From frames that already exist (the three-row light sheet sources under `build/films27/` (`ls_*`, `la_*`) or `evidence/yard27/light_before_after_32ppm.png` cells): mean L* and mean hue/chroma of floor pixels (mask out actors and props as well as you can: say how) in a fire-pool core (<= 3 m from a `yard_fire` pool and from a mid-yard pool) against between pools (> 12 m from every pool), n26 light vs HEAD light, mid t2290 and front t2858. Write `evidence/yard27/floor_warmth.txt` (method, numbers, one honest line on what they say). Commit by path. If no usable frame exists without a Godot render, write that and skip; do NOT start a render that collides with Part 2.

## Owned files (allowlist). Any other path: stop, put a NEED in your final report.
`evidence/yard27/**`, `build/**`, `C:/Users/kazda/kiro/gtai-n27/bench.lock` (create/delete yours only).

## Forbidden
`project/**` edits (read only), `tools/**` edits, `docs/**`, `JOURNAL.md`, `REPORT.md`, other worktrees, the Codex image tool, `git stash`, `git add -A/./-u`, `commit -a`, amend, rebase, `reset --hard`. Fix lint and format findings in your own edit and go on. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run a Godot `--import` and commit again (never skip the hook).

## Report and END
By 08:05: what was measured (numbers), what was not, the commits. Then END.
