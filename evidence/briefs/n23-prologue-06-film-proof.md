# Brief n23-prologue-06 - the film entry, the death proof, and the tests that catch faults

Lane `prologue`, night run n23. Same worktree and branch. The prologue plays end to end (calls 01-05). This is the last code call of the night: **the last commit is by 08:00, hard**. After that the director runs the gate and the films.
**Hard stop: <HH:MM>. Last commit by <HH:MM>.** Check `date` as you go.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/prologue` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- One Godot process at a time; kill by PID only; never rebuild native; windowed runs `--rendering-driver d3d12 --position 0,1440` (secondary monitor, never the main display). Headless `--import` after new scripts; commit `.uid` files.

## A. The film entry (the owner judges the prologue by one unbroken film)
A dev entry the director can run after the freeze that records the pilot's full playthrough as a movie: 1920x1080, 60 fps, 32 px/m, tilt 70, from the first line to the end card, in one take. Use Godot's `--write-movie <abs path>.avi --fixed-fps 60` with the pilot driving (the bot is deterministic, so the film is the same run as the headless pilot). The camera follows Rivet as in play; the HUD, prompts, lines and end card are visible. Put it in `project/dev/prologue/` (e.g. a `--prologue-film` flag on the dev entry, or a `prologue_film.gd` -s script; declare its flags). Plus a **clip mode**: `--clip=<first_kill|guard_lesson|pistol_pickup|mulroney_order>` that starts the movie a few seconds before that moment and stops 10-20 s later (same pilot run, just a recording window by tick). The pilot should read as human: it walks, faces, strikes and guards with brief pauses; it plays the lines through (it does not skip them).
Acceptance: run the film entry once yourself at a SHORT window (e.g. `--clip=first_kill`) to `C:\Users\kazda\kiro\gtai-masters\n23\prologue\scratch\film-test.avi`, check it is 1920x1080 and plays, extract one frame (ffmpeg if on PATH) and look at it. Do not run the full film (the director does, after the gate). Write the exact command lines for the full film and each clip into your report.

## B. Death and checkpoints (brief item 7: "Dying restarts the current beat, not the prologue")
Prove it in a scenario: `project/tests/scenarios/scenario_prologue_checkpoint.gd` (extends `Scenario`) that drives Rivet to die once in wave 1 and once in wave 2 (e.g. a test-only hook that sets his health to zero at a fixed tick, or a `--bot=dier` pilot mode that stands still), and checks: after each death the beat restarts at its checkpoint (Rivet at the beat's start, the beat's enemies respawned fresh, lines already shown are not replayed unless the beat's own lines start it, the pistol state right for beat 2), the result file counts `deaths`, and the pilot then finishes the prologue. Headless, deterministic, under about 20 s wall.

## C. Tests that catch faults
Mutation on `project/boot/prologue/prologue_game.gd` scored 1 killed / 10 sampled earlier tonight (most of its lines only run through the pilot). Raise unit coverage of the prologue's rule files with fast unit tests (`project/tests/unit/test_prologue_*.gd`) that pin the beat sequence (talk -> wave 1 -> talk -> wave 2 -> out -> phone -> channel -> end), the gate rule, the pistol removal, the order/exposure timing and the checkpoint restore. Then run `node tools/mutate/mutate.mjs --file=project/boot/prologue/prologue_game.gd --max=20` and `--file=project/boot/prologue/prologue_battle.gd --max=20` on a clean tree at HEAD and quote killed/(killed+survived) for each (or the exact error line).

## Tests
`node tools/tests/run_unit.mjs --select=<basenames>`; `node tools/lint/lint.mjs`; `node tools/gate/quick.mjs` before each commit; the scenario suite once at the end (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`, quote the summary line: every existing scenario must still pass).

## Owned files (allowlist). Any other path: stop and write `NEED <lane>: <file> <why>` in your report
- `project/boot/prologue/**`, `project/dev/prologue/**`, `project/dev/bots/prologue_*`
- `project/data/tables/prologue_*.json`, `project/data/schemas/prologue_*.schema.json`
- `project/tests/unit/test_prologue_*.gd`, `project/tests/golden/prologue/**`, `project/tests/scenarios/scenario_prologue_*.gd`
- append-only, one line each: `project/boot/launch_args.gd` KNOWN_FLAGS (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 prologue"`), `docs/decisions.md`
- Forbidden (other lanes, read-only): `enemies.json`, `bosses.json` (except the `mulroney` entry), `project/boot/collect_call/**`, `project/boot/quest1*`, `project/features/**` (all of it), `combat.json`, `gauntlet*.json`, `input_actions.json`, `test_player.json`, `quest_rules.json`, `tools/**`, every existing tape and golden.

## Law
- AGENTS.md and STANDARDS.md bind. Typed GDScript; files about 200 lines (hard 300; split into new `prologue_*.gd` files before you hit it); functions of 40 lines or fewer; at most 5 parameters. `Log`, not print. UI text through `tr()`. No global RNG; sim on `SimClock.TICK_DT`.
- Colour law: red is blood only; cops blue; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat/overload.
- Fix lint and format findings in your own edits and go on.
- Stage per path. No `git add -A/./-u`, no `commit -a`, no stash, no amend, no rebase, no reset --hard, never push. One commit per working piece. Do not commit `JOURNAL.md`, `REPORT.md` or `evidence/briefs/**`.
- Shipped scenes, quest 1, the 60 s replay and every existing tape stay byte-identical. Do not invent story or lines.
- When you are done, make sure no Godot or shell you started is still running (kill by PID).

## Report at the end
Commits (sha + subject), files, commands with result lines, mutate scores, the film and clip command lines, what is left, any NEED.
