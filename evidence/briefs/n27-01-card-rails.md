# Brief n27-01 `card-rails`: Mulroney's card film, then heavy rails on the six blocking conveyor sections (lane yard, run n27)

HARD STOP: 04:05 local (stop work, write the report, END). LAST COMMIT: 04:00. Commit Part A by 03:25 at the latest; start Part B right after. Check `date` often. If something is not done at 04:00, commit what passes and say what is missing.

## Before anything (every shell that runs Godot)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
Run ONE `"$GODOT_BIN" --headless --path project --import` first (the class cache may be stale). `--rendering-driver d3d12` for anything that renders; windowed runs `--position 0,1440`. One Godot process at a time; kill only the PIDs you started, never by name.

Read `AGENTS.md` (top rules) and `docs/day/2026-11-23/n26-yard/REPORT.md` (what the last night of this lane left). The film driver used last night is `build/films26/films.sh` (git-ignored, director-run): it shows how `res://dev/prologue_yard/yard_film.tscn` is run through the 1080p capture profile `build/prologue-film` with `--write-movie`. Copy what you need into a new `build/films27/films.sh`; outputs to `build/films27/` and masters to `C:/Users/kazda/kiro/gtai-masters/n27/yard/` (create it).

## Part A: Mulroney on his card in the prologue (wiring is already on this branch, a3b3f1466; check and film it)
`project/boot/prologue/prologue_command_view.gd` `_process` now hides the vector dress `PrologueCommanderDress` when `CastCards.current(&"sergeant_mulroney")` is non-null and calls `FoeCastView.set_pump(boss, progress, progress == 0.0)`. The marker and pump sound stay keyed on `_dress.pump`.
1. Verify on the seed-7 pilot, `line_fire` yard, tilt 70: the card pumps (both pump rows), the 1.6 m marker shows above him on each rack, the sound plays, and there is ONE Mulroney (no vector figure drawn over or under the card). Check `fired_this_tick`: is `progress == 0.0` true exactly on the discharge tick? Read `prologue_shotgun.gd` `pump_progress` and say in the report; if it is wrong, fix it inside `project/boot/prologue/**` with a unit test.
2. A dev-only flag so the film can show the old vector figure: add `--cast-card=off` (or similar) to `project/dev/prologue_yard/yard_film.gd` `KNOWN_FLAGS` that makes `CastCards.current(&"sergeant_mulroney")` null for that run, if `cast_cards.gd` offers an override (read `project/features/characters/cast_cards.gd`; do NOT edit it, it is cast's). If no override exists, render the "before" from a temporary detached worktree at `de3d369bb` (before the wiring) at the same tick: `git worktree add <tmp> de3d369bb`, copy `native` DLLs as needed, and REMOVE the worktree afterwards; say which way you took.
3. Films (LOOK at frames before you call it done):
   - `pump_card_32ppm_before_after.mp4`: left the vector figure, right the card, same ticks, 32 px/m, tilt 70, 1920x1080 at 60 fps (hstack of two 960-wide crops is fine), 15 to 30 s around his first two blasts (last night's `--place=commander --tick=6100`). Labels in the frame.
   - `pump_card_32ppm.mp4`: the card alone, full 1920x1080, 15 to 25 s.
   - `pump_card_64ppm_t<tick>.png`: mid-rack, card on, marker visible.
   - `ffprobe` each mp4 and quote the line (codec, size, fps, duration).
4. Commit any code (flag, fix, test) with `node tools/gate/quick.mjs` green first.

## Part B: heavy rails where the conveyor blocks, thin torn belt only in the gaps
The owner's pick: "Heavy rail sections where the conveyor blocks, thin torn belt only in the gaps."
Today the six colliding rows in `project/data/tables/prologue_yard_dressings.json` `dressings.line_fire.layout.cover` with ids `conveyor_door, conveyor_feed, conveyor_turn, conveyor_return, conveyor_bend, conveyor_tail` use thin slanted belt art (`feed_slope`, `outer_bend`, `return_slope`, `inner_bend`, `tail_slope`). Collision is the AXIS-ALIGNED box `at +- size_m/2` (`prologue_yard.gd` around line 108; `rotation_deg` turns only the drawing). So the thin slanted strip lies across a 5.4 x 1.2 m box and does not show what blocks. Rule: **what blocks looks raised (frame, rollers, legs, a drop shadow) and fills its collision box; what lies in a gap looks flat on the floor.**

Do it with the art already in the repo, no generated images:
- Put the chunky rail art (`res://boot/prologue/art/line_fire/straight_west.png`, `straight_east.png`, `bent_rail.png`, `torn_end.png`: see them at 32 px/m in the left half of `evidence/yard26/line_join_32ppm.png`) on the six cover rows, drawn to fill the collision box (no rotation; positions and sizes unchanged, so collision is unchanged). Use `torn_end` at the line's free ends (door, tail) and mix west/east so it does not repeat.
- Keep and if needed re-place the thin belt / fold / fray / loose roller pieces and oil drags ONLY in the gaps between the boxes, as non-colliding floor dressing (debris rows), so the line still reads as one torn S from the hall front.
- If the rail art lacks a drop shadow or legs in the game, use the `shadows` mechanism the row already has (read `prologue_yard_dressing.gd`), not new art.

**The measured bar (state your numbers in the report).** At 32 px/m, seed 7, tick 6000, tilt 70, 1920x1080:
1. Each blocking section's drawn body (rail frame, not shadow) covers at least 80 % of its collision box's on-screen rectangle (5.4 m x 1.2 m = about 173 x 38 px at 32 px/m, the y size scaled by the tilt projection you find in the camera code), measured with a mask from the frame.
2. Luminance contrast: the mean luminance difference between the rail body and the floor ring 0.5 m around it is at least as large as the same measure for Rivet's body against his floor in the same frame. Measure both with a small Python (PIL/numpy) script under `tools/art/` or `build/` (git-ignored is fine for a one-off; a repo tool needs a test) and give both numbers.
3. The thin gap belt's contrast is clearly lower than the rails' (say by how much): the eye must tell blocking from walk-over.
Save `evidence/yard27/rails_read_32ppm.png` (left before = HEAD before your change, right after; same tick and camera) and `evidence/yard27/rails_read_64ppm.png` (a close-up at 64 px/m of two blocking sections and the gap between them). LOOK at them. If a section still reads like loose belt, iterate before you commit.

**The pilot.** Art only, collision unchanged: the prologue pilot result on seeds 7, 3, 11, 21, 42 with `line_fire` must stay byte-identical to the current pin; run them (see how the n26 report got `evidence/yard26/prologue-yard-pilots.json`; `project/dev/prologue/newgame_pilot.gd` or the existing pilot test) and write `evidence/yard27/prologue-yard-pilots.json` with per seed: finished, deaths, lowest health, end tick. Quote them. `tools/art/prologue_yard_cut_test.py` (if it covers these rows) and the layout unit tests stay green.

**Films for Part B:** `rails_32ppm_before_after.mp4` (mid yard, `--place=mid`, 20 to 25 s, 32 px/m, left before right after, labelled) and `rails_64ppm.png` to the masters folder. ffprobe the mp4.

## Then
- `node tools/gate/quick.mjs` green, commit Part B (data row + any evidence + test changes), one commit per part.
- After committing any code change: `node tools/mutate/mutate.mjs --file=<the main changed .gd> --max=20 --lines=<your changed lines>` and quote killed/(killed+survived). Skip it if it would run past 03:55.
- Write `C:/Users/kazda/kiro/gtai-masters/n27/yard/frames.json`: array of `{ "file", "title", "ppm", "before", "note" }`, best first, for what you rendered.

## Owned files (allowlist). Any other path: stop and put a NEED in your final report.
- `project/boot/prologue/**`, `project/data/tables/prologue_yard_dressings.json` (the `line_fire` row only), `project/data/tables/prologue_stage.json` (only if needed), `project/tests/unit/test_prologue_*`, `project/dev/prologue/**`, `project/dev/prologue_yard/**`, `tools/art/prologue_yard_*`, `evidence/yard27/**`, `build/**` (ignored), `C:/Users/kazda/kiro/gtai-masters/n27/yard/**`, the `.uid` files of new scripts there.
- `project/boot/launch_args.gd` `KNOWN_FLAGS` only if a game-side flag is needed (append one line; then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n27 yard"` and commit `tools/debt/baseline.json`).

## Forbidden
`project/features/**` (cast, melee, keys, pressure own it, including `cast_cards.gd` and `foe_cast_view.gd`), every other `project/data/**` table, other worktrees, `JOURNAL.md`, `REPORT.md`, `docs/decisions.md` (the director writes decision lines), the Codex image tool (no generated images in this call).

## Repo law
Typed GDScript, files about 200 lines (hard 300), functions 40 lines or fewer, 5 parameters at most, `Log` not `print`. Stage per path; commit with `git commit -- <paths>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. If the pre-commit hook fails in `tools/film/kill_reel_*.break.test.mjs` (`mkdirSync(undefined)`), the class cache is stale: run a Godot `--import` and commit again; never `--no-verify`. After new art or scripts, `--import` before committing (`.uid` / `.import` files go in with their source).

## Report (final message, then END)
Commits (sha, one line each), what you saw in every frame you looked at, the ffprobe lines, the `fired_this_tick` answer, the measured bar numbers (coverage %, rail contrast, Rivet contrast, gap belt contrast), the five pilot rows against the pin, the mutate score, and what was not done.
