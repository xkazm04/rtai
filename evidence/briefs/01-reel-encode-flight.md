# Brief 01 (lane polish): film encode range, the all-ghosts reel, ghost_flight.gd mutants

Hard stop: 12:55 wall clock (check `date` as you go). Last commit by 12:50. If a part is not done by then,
commit what is green, stop, and say exactly where you stopped.

## Environment (every Godot / gate / film run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n21/appdata/polish`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time. Any windowed run uses `--position 0,1440` (the film tool already does).
- Kill only your own processes by PID, never by name. Nobody rebuilds native.

## Owned files (allowlist; any other path: stop and report a NEED, do not edit it)
- `tools/film/ghost_films.mjs`, `tools/film/ghost_films_plan.mjs`, `tools/film/ghost_films.test.mjs`
- `project/features/souls/ghost_flight.gd` (only if a test reveals a real bug; prefer tests only)
- new or existing `project/tests/unit/test_ghost_flight*.gd` (+ their `.uid`)

## Part A: limited-range yuv420p straight from the tool
`tools/film/ghost_films.mjs` `compose()` encodes with `-pix_fmt yuv420p`, but the movies come out full range
(`yuvj420p` / `color_range=pc`) because the Movie Maker AVI input is full-range MJPEG. Fix it so every `.mp4` the
tool writes is limited range: convert in the filter graph (e.g. `scale=out_range=tv:in_range=pc,format=yuv420p` on
`[out]`) and tag it (`-color_range tv`, plus `-colorspace bt709 -color_primaries bt709 -color_trc bt709` if you
convert to bt709). Stills (png/jpg) stay as they are.
Acceptance:
- `ffprobe -v error -select_streams v:0 -show_entries stream=pix_fmt,color_range,color_space -of default=nw=1 <mp4>`
  prints `pix_fmt=yuv420p` and `color_range=tv` on a movie the tool wrote.
- A Node test in `tools/film/ghost_films.test.mjs` pins the encode arguments (factor the encode argument list into
  an exported pure function if needed so it is testable without ffmpeg). `node --test tools/film/ghost_films.test.mjs` green.
- Brightness is unchanged by eye: blacks are not grey, teal is not washed (compare one poster before/after; save
  both under `C:/Users/kazda/kiro/gtai-masters/n21/polish/scratch/`).
Commit: "Encode ghost films as limited-range yuv420p".

## Part B: the all-ghosts reel from the merged tree
Run `node tools/film/ghost_films.mjs --all --out=C:/Users/kazda/kiro/gtai-masters/n21/polish` with the
**default looks** (each form's `look` from `project/data/tables/ghost_forms.json`: tonnage, dent, ohm spectral,
kerf legacy). First check in `ghost_films_plan.mjs` / `ghost_review.tscn` what `--all` does with no `--look`: it must
use the per-form table default, not force one look on all four. If it forces one look, make the no-`--look` case use
the table default (and pin that with a test) and say so in your report.
Output: `C:/Users/kazda/kiro/gtai-masters/n21/polish/all_ghosts_32.mp4` + `.jpg` poster. Run ffprobe on it and quote
the line. Report the run time.
If the run fails, read the capture logs in `build/ghost-films/all-*`, fix it if the fault is in your owned files,
otherwise report the exact error.

## Part C: kill the surviving ghost_flight.gd mutants
n20 left `project/features/souls/ghost_flight.gd` at 18/29 killed (62.1%); the survivors were the **shadow child**
(deleting/never adding the ground shadow child) and the **overhead scale** (the size applied in the top view).
Read `ghost_flight.gd` and the existing tests that name it (`node tools/tests/test_map.mjs project/features/souls/ghost_flight.gd`),
then add tests that pin: the shadow child exists, its parent, its position/scale/alpha as the code sets them; the
overhead (top view) scale value per pitch. Assert the exact values the code produces now (read them, do not invent).
Then:
- `node tools/tests/run_unit.mjs --changed` green.
- Commit ("Pin ghost flight shadow child and overhead scale").
- `node tools/mutate/mutate.mjs --file=features/souls/ghost_flight.gd --max=20 --lines=<the shadow and overhead lines>`
  and quote killed/(killed+survived). Mutate runs at HEAD, so commit first.

## Repo law (binding)
- AGENTS.md / STANDARDS.md. Typed GDScript, functions <= 40 lines, files about 200 lines, `Log` not `print`.
- Stage per path. No `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push.
- Fix lint and format findings in your own edit and go on (`node tools/gate/quick.mjs` before each commit).
- No sim, replay, parity or bake digest may move. Nothing here should touch gameplay.

## Report back
Files changed, commits (hash + subject), ffprobe line, reel path and duration, test results, the mutate score
line, and anything not done and why.
