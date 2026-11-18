# Package 3b, resumed (guns lane, n19) - continue where you were cut off

Your previous turn on this brief (`evidence/briefs/03b-rifle-p70.md`) was killed at 23:22 by a director session restart, mid-way through the p55 turning film (`node build/3b-film.mjs tilt new`, which had just logged octants 0-7 firing). Nothing of yours was lost on disk: the p55 recut is committed (`0b116fbd9`), your p70/reload masters are in `C:/Users/kazda/kiro/gtai-masters/n19/guns/masters/`, and these are uncommitted in the worktree: `docs/art/prompts/n19/guns/{diag70,eq70,left70,reload55,reload55_left,reload70,reload70_left}.txt`, `project/dev/rivet_arsenal/rifle_turn.gd`, `rifle_turn_rec.gd`. Check `git status` and `git log --oneline -5` first, then carry on with deliverables 1-6 of 03b.

## Answer to your question (bare_gun_fx.gd)

Yes: make the minimal render-only fix in `project/boot/collect_call/view/bare_gun_fx.gd` so flash and tracer (and the casing path if it has the same gate) resolve the rifle by its own art key rather than only through `art_stand_in`. Keep it to the smallest change (a few lines at most, the lookup only), one commit of its own whose message names the file; I record it in JOURNAL as a call site outside the lane's list. No other `boot/` edits.

## Dev flags

`rifle_turn.gd` is a dev `-s` script: declare its own `const KNOWN_FLAGS` so `tools/dev/run.mjs` can check it, and keep it under `project/dev/rivet_arsenal/` (release export drops dev/). Commit it with its `.uid`.

## Reminders

- Commit as soon as each deliverable is green (small commits); do not hold work for the end.
- `export APPDATA=C:/Users/kazda/kiro/gtai-n19/appdata/guns` and `GODOT_BIN` before every Godot run; windowed runs `--position 0,1440`.
- Report as in 03b: commits, holes before/after (target assault-rifle 0 except the 3 rack holes, say so), evidence files, mirrored cells, the quick-gate Godot error line, the mutate score, anything left.
