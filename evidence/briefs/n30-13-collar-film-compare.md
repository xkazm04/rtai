# n30-13 collar-film-compare: the p55 collar clip through the shipped film tools (lane keys, 0 images, no product files)

Launched ~13:12. **Commit by 13:42, report and END by 13:47 (hard: the session that runs you ends at 13:54).** `date +%H:%M`
first. Work in `C:/Users/kazda/kiro/gtai-wt/n23-controls` (branch `n30-keys`). Never amend, rebase, push, stash, `git add -A/./-u`,
`commit -a`, `reset --hard`; stage per path with `git commit -- <paths>` (builder n30-12 commits p70 strip art in this worktree:
never stage its files). **No edits under `project/`, no image generation, no sheet swaps in the worktree.**

## Why a second route
n30-11 (route 1) failed: the bare-hands harness `run_hands.py` copies `hands_arena.*` from `C:/Users/kazda/kiro/gtai-masters/n26/...`,
and `gtai-masters/n24` and `n26` were deleted at ~12:56 (not by this lane). Do not try to rebuild that harness. Use the shipped
film kit (read `tools/README.md` "tools/film/film.mjs" and the compare section): `compare.mjs` films two commits in snapshots
(`--rev`), same tick, no worktree swap, and re-imports stale assets itself.

## Do
1. Find a shot (`tools/film/shots.mjs`) where Rivet sprints and turns through facings for 15-40 s, ideally the right, left and
   front-left three-quarter facings (sheet rows 3, 7, 6 of `p55/rivet_run8.png`). `--view=tilt` is the view whose art is `p55`
   (`project/data/tables/view.json`); `combo` / `tilt70` draw p70 and do NOT show this sheet. Use `--dry-run` first.
2. `node tools/film/compare.mjs <shot> --a=5114a4441 --b=HEAD --view=tilt --ppm=32 --res=1920x1080 --movie ...` (check the exact
   flags compare accepts; if compare makes no side-by-side movie, film each side with `film.mjs <shot> --rev=<sha> --movie` and
   put them side by side with ffmpeg, before left, labelled "before 5114a44" / "after n30"). Output to
   `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/collar_p55_rows367_32.mp4`, 1920x1080, 60 fps, 15-40 s. Plus a 64 px/m
   still pair at the same tick of a sprint frame showing a changed row (`--ppm=64 --stills=<t>`), `collar_p55_64_compare.png`.
3. ffprobe (width, height, r_frame_rate, duration, nb_frames). Look at 3 frames with the Read tool (does Rivet sprint in a changed
   facing? collar before = twisted rope, after = flat striped ring?). If the shot never shows rows 3, 6, 7 in a sprint, say so.
4. Put the clip first in `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json` (`file`, `title`, `ppm` 32, `before`
   "5114a4441", `note`; keep 8-15 entries), write `evidence/n30-keys/films.md` section "Collar rows 3, 6, 7 clip (compare)" with
   the commands, ffprobe, what you saw, and the route 1 failure in one line. Commit `evidence(keys n30): collar rows 3, 6, 7 clip at 32 px/m`.

## Godot
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot for the lane: lock
`build/n30-godot.lock` (create exclusively with tag `n30-13` + your pid; n30-12 takes it for short arsenal runs: wait if it is held,
take it per film and delete it right after). Films run through runGodot (the film tools do). `mem-budget: waiting` = machine
full, not a hang. Free only your own processes, by PID. Snapshots under `%TEMP%/gtai-film-<sha>` are the tool's: leave them.

## Allowlist (anything else: stop and report a NEED)
`evidence/n30-keys/films.md`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/**`, `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json`,
`build/n30-13/**`. Forbidden: all of `project/`, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md`, other worktrees. Never delete
anything in Temp or `~/.codex` you did not create.

## Report (short), then END
Shot and commands, ffprobe line, what you saw in 3 frames, commit sha, what is owed.
