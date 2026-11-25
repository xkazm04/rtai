# Brief n30-03c `shadow-film`: a 32 px/m film where Rivet's span shadow is actually on screen (lane yard, run n30)

HARD STOP 16:40 (report and END). LAST COMMIT started by 16:28. Commit each finished part as soon as its checks pass. Check `date` often. Never amend, never rebase, never `--no-verify`.

## Setup
Worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n30-yard`). Bash with absolute paths. Every shell that runs Godot or a commit:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
Renders `--rendering-driver d3d12`, windowed `--position 0,1440`. Godot ONLY through repo tools that use runGodot (`node tools/art/prologue_yard_film.mjs`, `node tools/dev/run.mjs`, `node tools/tests/run_unit.mjs`). Lane Godot slot `build/yard-godot.lock` (write your tag `shadow-film` + pid, create it noclobber, poll 30 s, older than 25 min = stale) around EVERY Godot launch and every `git commit`; another builder (`mouth-fade`) shares the slot. Table lock `build/yard-table.lock` (tag `shadow-film`) before any edit of `project/data/tables/prologue_yard_dressings.json`, released after you restore it.

## Where it stands
Span shadow (item 3) is in: `project/boot/prologue/prologue_span_shadow.gd` (`step()` fades `_level` up while `on_body(feet)`; `strength()` = current alpha), row key `arched_line.span_shadow` in the dressings table. Still at 64 px/m exists (`evidence/yard30/span_shadow_before_after_64ppm.png`, a stand probe). The 32 px/m film `C:/Users/kazda/kiro/gtai-masters/n30/yard/span_shadow_before_after_32ppm.mp4` (mid, seed 7, ticks 1757..3256) is a MISS: Rivet fights beside the S span's foot, the blot never shows. `project/dev/prologue_yard/yard_film.gd` hardcodes `--seed=7` (line 55) and centres the camera on a named place (`yard_camera.gd` PLACES).

## Work
1. Find a window (Godot, ONE headless process): a small dev probe under `project/dev/prologue_yard/` (or a flag on `yard_pilot_rows.gd`) that runs the bot pilot for seeds 7,3,11,21,42 on `arched_line` and logs, per tick, Rivet's feet and the span shadow's `strength()`; print the runs of ticks where strength >= 0.5 (seed, first tick, last tick, mean feet). Pick the longest run, prefer >= 3 s (180 ticks) and Rivet moving (walking over the span beats standing). If no run reaches 1.5 s on any seed, say so and use the longest. Save the list to `evidence/yard30/span_shadow_windows.txt`.
2. Film: add a `--seed` flag (default 7, so every existing call is unchanged) and, if the window is off-frame for every place, a `--at=x,y` camera centre (metres) to `yard_film.gd` (+ its KNOWN_FLAGS; `yard_camera.gd` if needed). The window plus about 3 s either side, 15..40 s total. Before = HEAD with `arched_line.span_shadow` removed by a temporary table edit (table lock; restore byte-identical, `git diff --quiet` that file), after = HEAD. Render both 32 px/m 1920x1080 avi through `prologue_yard_film.mjs --movie`, hstack two 960x1080 crops centred on Rivet's mean feet (label each half "before: no span shadow" / "after: span shadow"), encode h264 yuv420p crf 20 60 fps to `C:/Users/kazda/kiro/gtai-masters/n30/yard/span_shadow_before_after_32ppm.mp4` (replace the miss). `ffprobe` it. Extract one frame inside the window from the hstack to `evidence/yard30/span_shadow_film_frame.png` and LOOK at it: the dark blot must be visible on the span beside Rivet in the right half and absent in the left. If it is not visible, say so plainly.
3. Update the entry `span_shadow_before_after_32ppm.mp4` in `C:/Users/kazda/kiro/gtai-masters/n30/yard/frames.json` (valid JSON; note = seed, ticks, camera, what it shows). Delete the scratch avi files you made.
4. Checks: `node tools/godot/check.mjs` on every .gd you touched; `node tools/lint/lint.mjs` (fix lint and format findings in your own edit and go on); `node tools/dev/run.mjs` dry-run of yard_film with the new flag if handy. COMMIT the dev tool change + `evidence/yard30/span_shadow_windows.txt` + `evidence/yard30/span_shadow_film_frame.png` (+ `.uid` of any new .gd), `git commit -m "Yard n30: span shadow film window ..." -- <paths>`.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/dev/prologue_yard/**` (+ new `.gd`/`.uid`/`.tscn` there), `project/data/tables/prologue_yard_dressings.json` (temporary edit only, restored, never committed changed), `evidence/yard30/**`, `C:/Users/kazda/kiro/gtai-masters/n30/yard/**`, `build/**`.

## Forbidden
`project/boot/**` code, `project/features/**`, `project/boot/launch_args.gd`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, `docs/**`, other worktrees (`n23-controls`, `n23-street`, `n23-prologue`), `C:/Users/kazda/kiro/gtai-art/**`. No image generation. No `git add -A/./-u`, no `git commit -a` (always `-- <paths>`), no stash, no amend, no rebase, no reset --hard, never push. Kill only PIDs you started.

## Report (final message, then END)
Commit shas; the windows found (seed, ticks, seconds); the chosen window; ffprobe line; what the frame shows (blot visible yes/no); files; what was not done.
