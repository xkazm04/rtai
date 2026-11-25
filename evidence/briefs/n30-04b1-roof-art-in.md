# Brief n30-04b1 `roof-art-in`: roof slab and plume cuts into the repo, and the placement plan (lane yard, run n30). PART B1 (no table edit)

HARD STOP: see the prompt (report and END). ONE COMMIT, started no later than 12 minutes before the hard stop. Check `date` often. Never amend, never rebase.

## Setup
As `evidence/briefs/n30-04b-roof-place.md` "Setup" (env exports, runGodot-only, the lane Godot lock `build/yard-godot.lock` with your tag `roof-art-in`). Read that brief's "Why" and `C:/Users/kazda/kiro/gtai-art/factory-n30/roof-state.md`.

## Work
1. Copy the accepted sources `C:/Users/kazda/kiro/gtai-art/factory-n30/out/roof-{burst,collapsed,feed,shutter-w,shutter-e}.png` and `plumes-a.png` to `tools/art/prologue_yard_sources/n30/` (the tool's default `--sources`). Run `tools/art/prologue_yard_roof.py` (read its header; run from `tools/art` without `-I` as its test does) WITHOUT `--out`, so the cuts land in `project/boot/prologue/art/arched_line/` (`hall_roof_*.png`, `hall_plume_*.png`). Check they are byte- or pixel-equal to `C:/Users/kazda/kiro/gtai-art/factory-n30/cut/` (say which). Red share 0.00 %.
2. Run a plain Godot `--import` through runGodot (`node -e` with `tools/lib/godot.mjs`, or `node tools/godot/check.mjs` won't import: use the import path the repo uses, e.g. `"$GODOT_BIN" --headless --path project --import` only via a runGodot wrapper; look at how `tools/tests/run_unit.mjs` triggers the import) so every new png has its `.import` file.
3. Placement plan (NO table edit: another builder holds the dressings table): a short Python script `evidence/yard30/roof_plan.py` that reads `arched_line.factory_front` from `project/data/tables/prologue_yard_dressings.json` (the five bay pieces: their art, pos, footprint/size, flip) and the cut sizes, and writes `evidence/yard30/roof_plan.json`: for each bay, the slab piece row exactly in the table's piece format (art path, pos in metres, size in metres with ONE shared depth of about 5.5 m so the north edge is straight, flip like its bay, south edge tucked under the bay's roof line by the part-A tuck numbers in roof-state.md, 0.1 to 0.2 m side overlap), and one or two plume rows per bay (no two bays sharing a plume), standing on the slab's fire holes. Read how `PrologueYardPaint.stamps` interprets a piece (anchor, size, flip) before computing positions. The next builder pastes these rows into the table.
4. COMMIT (one): the six sources, the cut pngs + their `.import` (+ any `.uid`), `evidence/yard30/roof_plan.py`, `evidence/yard30/roof_plan.json`. `git commit -m ... -- <paths>` (the pre-commit hook may take 8 to 12 minutes: start it on time). If the hook fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run the import and commit again (never skip the hook).

## Owned files (allowlist). Any other path: stop and report a NEED.
`tools/art/prologue_yard_sources/n30/roof-*.png`, `tools/art/prologue_yard_sources/n30/plumes-a.png`, `project/boot/prologue/art/arched_line/hall_roof_*`, `project/boot/prologue/art/arched_line/hall_plume_*` (+ `.import`), `evidence/yard30/roof_plan.*`, `build/**`.

## Forbidden
`project/data/**` (the table is held by another builder), every other repo path, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, other worktrees, writing in `gtai-art`. No image generation. No `git add -A/./-u`, `git commit -a`, stash, amend, rebase, reset --hard, push, `--no-verify`. Fix lint and format findings in your own edit and go on.

## Report (final message, then END)
Commit sha; cut equality; the plan (depth chosen, per bay slab pos/size, plumes per bay); what was not done.
