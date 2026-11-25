# Brief n30-02a `decals-over`: floor decals print above the i55 impression (draw order), code + test (lane yard, run n30)

HARD STOP: see the time in the prompt that launched you (report and END). CODE COMMIT started no later than 12 minutes before it (the pre-commit hook takes 8 to 12 min). Check `date` often. Never let the call end before its commit; never amend, never rebase.

## Setup
Worktree `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n30-yard`). Bash with absolute paths. Every shell that runs Godot or a commit:
```
export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
Godot ONLY through repo tools (runGodot): `node tools/art/prologue_yard_film.mjs` (stills, read its header), `node tools/tests/run_unit.mjs`, `node tools/gate/quick.mjs`, `node tools/godot/check.mjs`. **One Godot per lane**: before EVERY Godot launch and around `git commit` take the slot: `set -o noclobber; echo "decals-over $PPID $(date +%H:%M)" > /c/Users/kazda/kiro/gtai-wt/n25-yard/build/yard-godot.lock` (if it exists, poll every 30 s; older than 25 min = stale). Delete it after. Never delete a lock whose first word is not `decals-over` unless stale. `mem-budget: waiting` = machine full, wait. Kill only PIDs you started.

## Why (owner's pick)
"Floor decals drawn over the i55 impression (draw order, not a lower tint)." In `arched_line` (`project/data/tables/prologue_yard_dressings.json`) the floor is drawn by `PrologueFloor._draw` (`project/boot/prologue/prologue_floor.gd`) in the world pass: `ground` layers (layer 0 the tiled `raised_line/floor_tile.png`; **layer 1 `raised_line/floor_stains.png`, 60 x 34 m, untiled: the stains, tyre marks and bay lines**), then `_stage_decals()` (SCORCH marks, since the row has no `decals` key, and ground debris not in `over_print`). The i55 impression (`ground_impression`, tiled `arched_line/floor_tile.png` at tint `ffffff8c`) is drawn LATER on a static over-print CanvasLayer by `PrologueYardOverprint._draw_pieces` (`project/boot/prologue/prologue_yard_overprint.gd`), above the whole world floor, so it hazes every decal. Read `evidence/yard29/impression_props.md` (the n29 finding) first.

## Work
1. The change, one data value so the old order stays one switch: an optional boolean key on a `ground` layer, `"over_impression": true` (absent = false = today). A ground layer with it is skipped in `PrologueFloor._draw` and drawn by `PrologueYardOverprint._draw_pieces` right AFTER the impression and BEFORE the over-print wrecks and spans. Decide with a look whether the SCORCH stage decals must move too (they are stains as well): if yes, a second optional row key `"scorch_over_impression": true` handled the same way; say what you chose. Set the key(s) in `arched_line` only. Schema: `project/data/schemas/prologue_yard_dressings.schema.json` (find the file; add the property). Parse it in `project/boot/prologue/prologue_yard_dressing.gd` (the `Ground` class). Keep files under 200 lines (hard 300), functions <= 40 lines, typed.
   Note: on the over-print layer the decals skip the world print, so they may draw darker or more saturated than before; the ground layer's own `tint`/`wash` values stay as they are in this call (measured in the evidence call), unless a look shows them black and crude: then report, do not tune.
2. Unit test in `project/tests/unit/test_prologue_yard_overprint.gd` (and/or `test_prologue_yard_dressing.gd`): the key parses, the flagged layer is drawn on the over-print node after the impression (the file already has a recording test of the draw order: extend it), and is not drawn by the floor; key absent = today's order.
3. No-change proof for rows without the key: a mid still (`--dressing=raised_line` or another row that has no key, `--place=mid --tick=300 --ppm=32`) at HEAD before your edit vs after: max channel diff 0. And one `arched_line` mid still before | after for the director: `evidence/yard30/decals_over_before_after_mid_32ppm.png` (labelled, side by side). LOOK at it: are tyre marks and bay lines crisper, any decal drawn over a wreck or a belt section (it must stay under them)?
4. `node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`; fix lint and format findings in your own edit and go on. Then commit: `git commit -m "Yard n30: floor decals draw over the i55 impression (ground layer over_impression)" -- <the gd files> <schema> <table> <test files> evidence/yard30/decals_over_before_after_mid_32ppm.png`.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/boot/prologue/prologue_floor.gd`, `project/boot/prologue/prologue_yard_overprint.gd`, `project/boot/prologue/prologue_yard_dressing.gd`, `project/boot/prologue/prologue_yard_paint.gd`, `project/data/tables/prologue_yard_dressings.json` (the arched_line key only), its schema, `project/tests/unit/test_prologue_yard_*.gd`, `evidence/yard30/decals_over*`, `build/**`.

## Forbidden
Every other repo path (`JOURNAL.md`, `REPORT.md`, `docs/**` in this call, `evidence/briefs/**`, `tools/**`), other worktrees (`n23-controls`, `n23-street`, `n23-prologue`), `C:/Users/kazda/kiro/gtai-art/**`. Another builder (`roof-art`) may commit `tools/art/prologue_yard_roof*.py` meanwhile: never stage it. No image generation; never `builder.mjs`, `astra.mjs`, `codex`. No `git add -A/./-u`, no `git commit -a` (always `git commit -m ... -- <paths>`), no stash, no amend, no rebase, no reset --hard, never push, never `--no-verify`. No mutate in this call (the next call runs it).

## Report (final message, then END)
Commit sha; the design (key names, where drawn); scorch moved or not and why; the no-change diff number; what you saw in the arched_line before | after; test names; what was not done.
