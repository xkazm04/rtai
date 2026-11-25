# Brief n29-12 `film-tool`: the yard film tool makes 1080p movies through runGodot; roof glow guard pin; a design note for a dusk grade on the over-print layer (lane yard, run n29)

HARD STOP: 06:12 local (report and END). First commit by 05:45. LAST COMMIT started by 06:00. Check `date` often. Never let the call end before its commit.

## Setup
Repo worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). Bash with absolute paths. Every shell that runs Godot:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
**One Godot per lane, shared with builder `gate-lamp`** (it sweeps the gate lamp and renders stills until 06:12): before EVERY Godot launch (tests, movies, the pre-commit hook) take the slot: `set -o noclobber; echo "film-tool $$ $(date +%H:%M)" > /c/Users/kazda/kiro/gtai-wt/n25-yard/build/yard-godot.lock`; if that fails, poll every 30 s (older than 25 min = stale); delete it when your Godot exits. **Never remove a lock that is not yours, never launch Godot without holding it, not even a read-only render.** 16 GB cap: `mem-budget: waiting` = wait. Kill only PIDs you started. Godot only through `runGodot` (`tools/lib/godot.mjs`) or repo tools built on it.

## Work, in order
1. **Film tool.** `tools/art/prologue_yard_film.mjs --movie=<avi>` launches with `--path project`, which fails the 1920x1080 movie check; the last builder worked around it with a throwaway `build/movie.mjs` that calls runGodot with `--path build/prologue-film` (read it, and `evidence/yard29/film.sh`, and find out how `build/prologue-film` is made: `grep -rn prologue-film tools evidence/yard29 project/dev`). Make `prologue_yard_film.mjs` produce a 1920x1080 60 fps movie itself through runGodot (e.g. it prepares/refreshes the film copy and passes its path, or it passes the window override flags that make `--path project` pass the check; pick the smaller change, explain why). Test: a 60-frame movie `--place=mid --tick=1757 --frames=60 --ppm=32 --movie=build/films29/tooltest.avi`, then `ffprobe` (1920x1080, 60/1), delete the .avi. If the tool has a node test beside it, extend it; else no new test. `node tools/gate/quick.mjs`. Commit (`git commit -- <paths>`). Delete `build/movie.mjs` afterwards only if your tool replaces it.
2. **Roof glow guard pin.** The roof glow mutate (`evidence/yard29/roof_glow_mutate.txt`) left one survivor: the `_stage != null` guard in `PrologueRoofGlow._process` (`project/boot/prologue/prologue_roof_glow.gd`). Add a test in `project/tests/unit/test_prologue_roof_glow.gd` that kills it (e.g. a glow built with no stage processes a frame without error and keeps its flicker; or with a stub stage the flicker follows its tick: read how `attach`/`build` take the stage and what `ArenaStage` / `PrintStage` give: `test_no_spec_attaches_nothing` already builds a `PrintStage`). `node tools/tests/run_unit.mjs --select=test_prologue_roof_glow`. Commit.
3. **Design note, read only (no code)**: the four wrecks drawn on the over-print layer (`project/boot/prologue/prologue_yard_overprint.gd`) skip the dusk grade the world pass gives everything else (see `evidence/yard29/impression_props.md`, last section). Find where the world pass's dusk grade is applied (grep `grade` in `project/boot/prologue/**`, the `arched_line.lights.grade` block in the dressings table) and write `evidence/yard29/overprint_grade_design.md`: the exact lines, the smallest change that lets the over-print layer take the same grade behind one optional data key (absent = today's look), its cost, and which tests would pin it. Commit the note.

## Owned files (allowlist). Any other path: stop and report a NEED.
`tools/art/prologue_yard_film.mjs` (+ a `.test.mjs` beside it), `project/tests/unit/test_prologue_roof_glow.gd`, `evidence/yard29/overprint_grade_design.md`, `build/**`.

## Forbidden
`project/data/**` (gate-lamp holds the dressings table), `project/boot/**` code, `docs/decisions.md`, `project/features/**`, `core/**`, `project/dev/**`, other tests, other worktrees, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, `C:/Users/kazda/kiro/gtai-masters/**`, `C:/Users/kazda/kiro/gtai-art/**`, `hs_err_pid*.log`. No image generation; never `builder.mjs`, `astra.mjs`, `codex`.

## Repo law
Typed GDScript, warnings are errors, functions <= 40 lines. Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`. Pre-commit hook up to 12 min (hold the slot lock across it). `kill_reel_*.break.test.mjs` failure in the hook = stale class cache: `--import`, commit again. Fix lint and format findings in your own edit and go on.

## Report (final message, then END)
Commit shas; the film tool change and the ffprobe line; the new test and its result; the design note's one-paragraph summary; what was not done.
