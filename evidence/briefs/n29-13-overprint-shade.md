# Brief n29-13 `overprint-shade`: one optional data value that darkens the lifted wrecks (lane yard, run n29), default unchanged

HARD STOP: {STOP} local (report and END). First commit (code + tests) by {FIRST}. LAST COMMIT started by {LAST} (never after 07:15). Check `date` often. Never let the call end before its commit.

## Setup
Repo worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n29-yard`). Bash with absolute paths. Every shell that runs Godot:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
`--rendering-driver d3d12`; windowed runs `--position 0,1440`. You hold this lane's single Godot slot (`build/yard-godot.lock`, create with noclobber as `overprint-shade ...`, delete when your Godot exits). Godot only through runGodot tools (`tools/tests/run_unit.mjs`, `tools/art/prologue_yard_film.mjs --still`, `tools/mutate/mutate.mjs`) except a plain `--import`. 16 GB cap: `mem-budget: waiting` = wait. Kill only PIDs you started.

## Why
The four wrecks in `arched_line.over_print` (`burnt_pickup`, `press_carcass`, `fallen_fridges`, `scrap_skip`) draw in their own paint over the i55 impression: crisp, but lighter than the n28 look (luminance contrast 55 / 47 / 29 % of i20, `evidence/yard29/impression_props.md`). The plate shows a yellow forklift and white appliances, so the director keeps today's look as the default and gives the owner one value to darken them. The design is done: `evidence/yard29/overprint_grade_design.md` (read it first; follow it).

## Work
1. Code (about 8 lines): optional row key `over_print_shade` (number 0..1, absent = 1.0) read in `project/boot/prologue/prologue_yard_dressing.gd`; schema property in `project/data/schemas/prologue_yard_dressings.schema.json`; `prologue_yard_overprint.gd` `_draw_pieces` passes `Color(s, s, s)` for ground wrecks; `prologue_yard_paint.gd` `wreck` passes `tint` on its skinned branch too (check every caller: default output must not change). Do NOT add the key to any committed row.
2. Tests in `project/tests/unit/test_prologue_yard_overprint.gd`: (a)-(d) of the design note. `node tools/tests/run_unit.mjs --select=test_prologue_yard_overprint,test_prologue_raised_line,test_prologue_yard_paint,test_prologue_yard_dressing`; `node tools/gate/quick.mjs`. Commit.
3. Proof of no change: a 32 px/m mid still at tick 300 at HEAD before your commit vs after (pixel-identical expected: say the max channel difference).
4. The owner's alternative: with a TEMPORARY `"over_print_shade": 0.6` in `arched_line` (and 0.5 if 0.6 is not within 10 % of i20 on the skip), the contrast via `evidence/yard29/prop_contrast.py` and `evidence/yard29/impression_props_shade_mid_32ppm.png` (today | shade 0.6, tick 300) + a 64 px/m crop of the fridges. Remove the temp key (`git diff` of the table empty). Append the numbers to `evidence/yard29/impression_props.md`. Commit.
5. Mutate `--file=boot/prologue/prologue_yard_overprint.gd --max=15 --tests=test_prologue_yard_overprint,test_prologue_raised_line` (12 min budget), tail to `evidence/yard29/overprint_mutate.txt` (append). Commit.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/boot/prologue/prologue_yard_dressing.gd`, `prologue_yard_overprint.gd`, `prologue_yard_paint.gd`, `project/data/schemas/prologue_yard_dressings.schema.json` (the one property), `project/data/tables/prologue_yard_dressings.json` (temp key only, never committed), `project/tests/unit/test_prologue_yard_overprint.gd`, `evidence/yard29/impression_props*`, `evidence/yard29/overprint_mutate.txt`, `build/**`.

## Forbidden
`docs/decisions.md` (no default changes), `project/features/**`, `core/**`, `project/dev/**`, other tests, other worktrees, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, `C:/Users/kazda/kiro/gtai-masters/**`, `C:/Users/kazda/kiro/gtai-art/**`, `hs_err_pid*.log`. No image generation; never `builder.mjs`, `astra.mjs`, `codex`.

## Repo law
Typed GDScript, warnings are errors, files about 200 lines (hard 300), functions <= 40 lines, <= 5 parameters. Stage per path; `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`. Pre-commit hook up to 12 min (hold the slot lock across it). `kill_reel_*.break.test.mjs` failure = stale class cache: `--import`, commit again. Fix lint and format findings in your own edit and go on. LF line endings (`prologue_yard_overprint.gd` shows CRLF-only churn in the tree: commit it as LF).

## Report (final message, then END)
Commit shas; the code diff summary; tests and counts; the no-change proof; the contrast at 0.6 (and 0.5); what you saw in the stills; mutate score; what was not done.
