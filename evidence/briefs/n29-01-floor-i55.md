# Brief n29-01 `floor-i55`: the owner's floor pick, measured and filmed (lane yard, run n29)

HARD STOP: 02:10 local (report and END; you are an in-session builder and die with the director's session). FIRST COMMIT (the tint + test) by 01:45. LAST COMMIT started by 02:02. Check `date` often. Never let the call end before its commit.

## Before anything (every shell that runs Godot)
```
cd /c/Users/kazda/kiro/gtai-wt/n25-yard        # branch n29-yard
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
Step 0: run one `"$GODOT_BIN" --headless --path project --import` (log to `build/n29/import0.log`): the run's first session must import once.
`--rendering-driver d3d12` for renders; windowed runs `--position 0,1440` (never the main display). You own this lane's single Godot slot until you END (another builder in this lane works on images only). Launch Godot only through repo tools (`tools/dev/run.mjs`, film tools, `tools/art/prologue_yard_stills.mjs`, `runGodot`), except the step-0 import. The run sits under a 16 GB cap; `mem-budget: waiting` in a log means the machine is full, not a hang: wait. Kill only PIDs you started, never by name. Never delete anything in Temp you did not create.

## The owner's pick (verbatim)
"floor i55 (browner, closer to the plate)". The n28 lane shipped `arched_line` (the default yard, `project/data/tables/prologue_yard_dressings.json`) with `ground_impression.tint` = `ffffff33` (i20). i55 = `ffffff8c` (alpha 0.55). n28 measured i55 at C* 18.3, Rivet luminance delta 0.153 (n28 bar 0.19, so 80 % of it) and dE2000 24.7: the owner chose it knowing that. We ship it; your job is to say honestly where every bar lands.
Read first: `docs/day/2026-11-25/n28-yard/JOURNAL.md` lines 90-110, `evidence/yard28/floor_sweep.txt`, `evidence/yard28/art_sweep.sh` + `imp_row.py` + `sweep_measure.py` + `readability.py` + `rivet_delta.py` (the measuring kit; copy what you need into `evidence/yard29/` and change its paths to n29 / `build/n29/`), `evidence/briefs/n28-02h-floor-impression-2000.md` (how i20 was chosen).

## The work
1. Set `arched_line.ground_impression.tint` to `ffffff8c`. Nothing else in the table. Update any unit test that pins `ffffff33` (grep `project/tests`). `node tools/godot/check.mjs` on any edited `.gd`, `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`, then commit `git commit -- <paths>` ("Yard n29: floor impression i55 (owner's pick)"). By 01:45.
2. **Bars at the committed row** (real renders, same seed/ticks/cameras as n28's sweep; i20 numbers from the same run for the before column, by rendering a temp worktree at `c649a15d6` or by a temp row edit restored afterwards with `git diff --stat` empty): floor L* C* hue between pools, Rivet luminance delta and dE2000, patrol blue out and in (% of daylight contrast, bar 65), rifle (bar 95 %), pellet (bar 90 %), pool gain (bar +4), cream appliance delta (info). Write `evidence/yard29/floor_i55_bars.md`: a table i20 | i55 | bar | pass/fail, then one honest line on each failure (no tuning to hide it: the owner picked the value).
3. **Pilots on five seeds unchanged:** seeds 7, 3, 11, 21, 42 on `arched_line` with the n28 pilot tool (`project/dev/prologue_yard/` + `evidence/yard28/prologue-yard-pilots-arched.json` for format and the expected rows: end ticks 11701 / 11958 / 10392 / 12158 / 13278, same deaths, same lowest health). A floor tint cannot move them; prove it. Write `evidence/yard29/prologue-yard-pilots-i55.json`. Run all five in ONE Godot process if the tool allows it.
4. **Before / after:** `evidence/yard29/floor_i20_vs_i55_{mid,gate}_32ppm.png` (same tick, hstack, each half labelled with tint and Rivet delta) and `evidence/yard29/floor_i55_64ppm.png` (Rivet standing on the floor between pools). LOOK at each.
5. **Film:** `C:/Users/kazda/kiro/gtai-masters/n29/yard/floor_i20_vs_i55_mid_32ppm.mp4`: 20 to 25 s, i20 left / i55 right, two 960x1080 crops hstacked to 1920x1080, 60 fps, h264 yuv420p, same ticks, Rivet fighting in the mid yard, each half labelled. Use the n28 film path: `build/films28/run.sh` and the `build/prologue-film` override (1920x1080) if they still exist; else `tools/art/prologue_yard_film.mjs` (read its header; `--movie` refuses at 1280x800, so give it a 1920x1080 override.cfg). `ffprobe` it (duration, size, fps). Copy the 64 px/m still beside it. Write/append `C:/Users/kazda/kiro/gtai-masters/n29/yard/frames.json` (array of `{file,title,ppm,before,note}`; the clip first).
6. Commit the evidence (stills, md, json, any evidence/yard29 script) with `git commit -- <paths>`.
7. Only if 10+ minutes remain before 02:02: `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_yard_dressing.gd --max=20 --tests=<the yard test basenames>` with a 12-minute budget; quote killed/(killed+survived) in your report (do not commit its output).

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/data/tables/prologue_yard_dressings.json` (the one tint), `project/tests/unit/test_prologue_*` (only a pin of the tint), `project/dev/prologue_yard/**`, `project/dev/prologue/**` (only if a film tool needs a fix), `evidence/yard29/**`, `build/**`, `C:/Users/kazda/kiro/gtai-masters/n29/yard/**`.

## Forbidden
`project/features/**`, `input_actions.json`, `rivet_motion.json`, `ghost_*.json`, `cast_cards.json`, `core/render/**`, `prologue_stage.json`, every other table, `project/tests/scenarios/**`, other worktrees, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md` (the director writes it), `evidence/briefs/**`, `hs_err_pid*.log`. Never run `builder.mjs`, `astra.mjs`, `codex`, or the image tool.

## Repo law
Typed GDScript, files about 200 lines (hard 300), functions <= 40 lines, <= 5 parameters, `Log` not `print`. Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`. The pre-commit hook can take up to 12 minutes on this shared machine: budget for it. A hook failure in `tools/film/kill_reel_*.break.test.mjs` = stale class cache: `--import`, commit again. Fix lint and format findings in your own edit and go on.

## Report (final message, then END)
Commit shas; the bars table (i20 | i55 | bar); the five pilot rows vs expected; what you saw in each still; ffprobe line of the film; mutate score or "not run"; what was not done.
