# Brief n27-02 `warm-light`: warmer, larger fire and lamp light at ground shade 0.81 (lane yard, run n27)

HARD STOP: 04:53 local (stop work, write the report, END). LAST COMMIT: 04:48. Commit Part A (the place) by 04:05; the light change by 04:33. Check `date` often.

## Before anything (every shell that runs Godot)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
`--rendering-driver d3d12` for renders; windowed runs `--position 0,1440`. One Godot process at a time; kill only PIDs you started. Film driver: `build/films27/films.sh` (from call 01); capture profile `build/prologue-film`; masters to `C:/Users/kazda/kiro/gtai-masters/n27/yard/` and append to its `frames.json`.

## The owner's pick (verbatim)
"keep 0.81 and get the mood from warmer, larger fire and lamp light". `ground_shade` stays 0.81 in the `line_fire` row of `project/data/tables/prologue_yard_dressings.json`. The mood must come from amber light, not from darkness.

## Part A: a `front` place for the film (small, first)
Add `front` to `--place` in `project/dev/prologue_yard/yard_film.gd` (and `yard_camera.gd`): the camera on the hall front, centred about x 26, y 3 (the burst bays and the conveyor door), so the plate can be compared with the hall front at 32 and 64 px/m. Commit.

## Part B: the light
What exists: `line_fire.lights` (`grade` dusk with `paper_level` 0.92; kinds `yard_fire` ffb43b r 8.5 m i 0.37, `yard_lamp` ffe2aa r 6 m i 0.39; eight pools), `project/boot/prologue/prologue_yard_lights.gd`, the light layer it installs into. Last night's metric: `evidence/yard26/dusk_contrast.py` (patrol blue, rifle round, pellet: contrast at dusk as a % of daylight contrast; shipped 69.2 / 124.5 / 96.2 %).
1. FIRST render the before frames from HEAD unchanged (same ticks and cameras as the after frames): seed 7, tilt 70, 1920x1080, at `gate` t6400, `mid` t2290, `front` t2858, 32 px/m, plus `front` at 64 px/m. Keep them in `build/films27/`.
2. Make the light warmer and larger, all in data where possible: a deeper amber fire colour (amber, never red or vermilion: hue about 30 to 40 degrees), fire radius about 12 m and lamp radius about 9 m, intensity raised until the pools read as warm light on the floor at 32 px/m; add fire pools mid-yard where the plate has them: at the toppled welding arm's cable (exists), at the burnt pickup (`burnt_pickup` x 43.2 y 17.4), at the scrap skip (x 46 y 26), and one at the torn conveyor tail (x 32.2 y 20.6). Lamps may get a softer, wider falloff. If the light layer caps the pool count or radius, say so and stay inside the cap.
3. **The bar (measure, state numbers):** with `dusk_contrast.py` extended (keep it a tool in `evidence/yard27/` or `tools/art/`) measured both OUTSIDE the pools and INSIDE a fire pool: patrol blue >= 65 % of daylight contrast in both places (the n26 floor), and blue must still read as blue in a pool (hue of a patrol cop's uniform sample inside a fire pool stays within 200 to 250 degrees); rifle round >= 100 %, pellet >= 90 %, ice-blue enemy large round (if one is in the prologue, else say so) >= 90 %. If a pool pushes a value under its floor, lower that pool's intensity, not the others'.
4. Frame cost under the bench lock: create `C:/Users/kazda/kiro/gtai-n27/bench.lock` exclusively (if it exists and is younger than 20 min, wait up to 10 min, then report CONTENDED and measure anyway noting the load; older than 20 min = stale, delete). Use `project/dev/prologue_yard/yard_frame_probe.tscn` like `evidence/yard26/frame-cost.md`, three paired rounds before/after (before = a temporary copy of the row values via a dev-only flag, or by checking out the old row into a git-ignored build copy of the project; your choice, say which), release template if it starts the probe (last night it did not: try once, record the error). Delete the lock afterwards. Write `evidence/yard27/frame-cost.md`. Bar: p50 increase under 0.5 ms (CI upper bound).
5. Seed-7 pilot result must stay byte-identical (light is render only); run it and quote the end tick.
6. Commit: data row, the tool, evidence. `node tools/gate/quick.mjs` green first.

## Films and stills (LOOK at every one; name what you see)
- `evidence/yard27/light_before_after_32ppm.png` (gate | mid | front, before row above, after row below, labelled).
- Masters: `light_mid_32ppm_before_after.mp4` (mid, 20 to 25 s, hstack 960 crops, labelled), `light_front_64ppm.png` (after), `light_front_32ppm_before_after.png`. ffprobe each mp4 (h264 1920x1080 60 fps, duration).

## Owned files (allowlist). Any other path: stop and put a NEED in your final report.
`project/boot/prologue/**`, `project/data/tables/prologue_yard_dressings.json` (the `line_fire` row only), `project/tests/unit/test_prologue_*`, `project/dev/prologue/**`, `project/dev/prologue_yard/**`, `tools/art/prologue_yard_*`, `evidence/yard27/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n27/yard/**`, `.uid` files of new scripts there.

## Forbidden
`project/features/**` (including the light layer if it lives there: if it needs a change, NEED), every other `project/data/**` table, other worktrees, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, the Codex image tool.

## Do not
- Never delete anything in `%TEMP%` / `AppData/Local/Temp` you did not create in this call (other lanes' pre-commit and mutate dirs live there). Mutate and other temp dirs you start: remove only those by exact name.
- `tools/debt/baseline.json` only through `node tools/debt/debt.mjs --update --accept-regression="<reason> for n27 yard"` (dev lines are allowed tonight).

## Repo law
Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, 5 parameters at most, `Log` not `print`. Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. Pre-commit failing in `tools/film/kill_reel_*.break.test.mjs` = stale class cache: Godot `--import`, commit again; never `--no-verify`. After committing code, `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_lights.gd --max=20 --lines=<changed lines>` if you changed it (skip past LAST COMMIT - 10 min).

## Report (final message, then END)
Commits, the new light values, the bar numbers (outside / inside pool, each against its floor), the frame-cost table and verdict, what you saw in each frame, ffprobe lines, seed-7 end tick, what was not done.
