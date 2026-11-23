# Package 01 `lessons`: the hand lessons arrive one at a time

Wall-clock hard stop **02:15** (check `date`). Commit deadline **02:05**. Stop early when done.

## Goal (owner-facing)
In wave 1 of the prologue, the lessons claw, guard and roll must each show **once, alone, when the player can use it**.
Today (last night's report): the claw prompt fires on Dale's fall (tick ~2195) and guard and roll come 19 ticks later
when the first panic rounds fly, so three cards share the strip within 3 s. The strike lesson before it and the wheel / fire
lessons in wave 2 must keep working as now.

## What I know
- `project/boot/prologue/prologue_prompts.gd`: `offer(id, tick)` marks seen and shows for `HOLD_TICKS` (2 s); `words()` joins every
  active card with " Â· ". `strike` and `wheel` are not timed out in `step()`.
- `project/boot/prologue/prologue_encounter.gd` `_fight()` (~line 104): guard is offered on `patrol.squad.shot_tick == tick`,
  claw on any officer's `swing_tick == tick`, roll when a hostile shot heads at Rivet within 5 m.
- Readers of `prompts.active(...)`: `prologue_pistol.gd`, `project/dev/bots/prologue_bot.gd:94`, `project/dev/prologue/prologue_film.gd:78`
  (`guard_lesson` clip), `prologue_stills.gd`, unit tests `test_prologue_battle.gd`, `test_prologue_pistol.gd`, `test_prologue_encounter.gd`.

## What to build
1. The strip shows **one lesson at a time**. A lesson whose trigger fires while another card is up is not shown and not marked
   seen; it is shown on the next real trigger after the strip is clear (plus a short gap, e.g. 0.5 s). That is
   "when the player can use it": the card always appears on a live threat.
2. Order the wave-1 hand lessons: claw first; **guard only after the claw card has run its time**; **roll only after the first
   catch-pole catch** of Rivet by a warden (find the warden pole catch in the prologue's patrol/panic code; if there is no
   event, add a tick field the way `swing_tick` / `shot_tick` are done, inside the prologue files). If a lesson's trigger never
   comes again, it is not shown. Make the gap and the order one data value each (the `prompts` part of `prologue_stage.json`,
   which this lane owns, or consts in `prologue_prompts.gd`).
3. Keep strike / wheel / fire behaviour. Keep `active(id)` semantics for the readers above (update the bot, film and stills
   readers if they relied on the overlap). The pilot bot must still finish with 0 deaths.
4. Unit tests (`project/tests/unit/test_prologue_prompts.gd`, new or extend): a second offer while a card is up does not show
   and does not consume the lesson; guard is refused before claw has expired; roll is refused before the catch; each id shows
   once; `words()` never joins two lessons.
5. The pilot result JSON (`--result=`) must list the prompt history with each lesson's shown tick and end tick, so the director
   can check that no two intervals overlap. Add that if it is not there.

## Acceptance (run all, quote results)
- `node tools/dev/run.mjs prologue --bot --seed=7 --result=<abs path under build/dev>` twice: verdict line `ok exit 0; SCRIPT ERROR 0 ...`,
  the two result files byte-identical (`cmp`), 0 deaths, end card reached; list each lesson's [shown, end] ticks: no overlap, each once.
- `node tools/tests/run_unit.mjs --changed` green; the prologue scenarios, then the full scenario suite once
  (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`): all pass, the 60 s replay unchanged.
  If the prologue scenario must be re-pinned, add one `docs/decisions.md` line `- [2026-11-23] DECISION prologue: ...`.
- `node tools/gate/quick.mjs` green before the commit. Commit message `prologue: lessons one at a time (...)`.
- mutate on `project/boot/prologue/prologue_prompts.gd` with `--max=20`; quote the score.
- Film: add a clip id `lessons` to `project/dev/prologue/prologue_film.gd` and `capture/film.ps1` that starts ~1 s before Dale's
  fall and runs ~35 s (or ends 2 s after the roll card if that is later, cap 40 s), 1920x1080, 60 fps, 32 px/m, tilt 70, seed 7,
  the way the existing clips are taken. Render it to `C:/Users/kazda/kiro/gtai-masters/n25/path/lessons.avi`, convert with
  ffmpeg to `lessons.mp4` (H.264, yuv420p, crf 20), delete the .avi. Also one 1920x1080 still per lesson card while it is up
  (`lesson-claw.png`, `lesson-guard.png`, `lesson-roll.png`) in the same folder. Quote the mp4's `ffprobe` duration.
  Commit the film entry change as its own commit.

## Final message
Files changed, commit shas, the lesson [shown, end] table from the pilot, the test/scenario/mutate lines, the film path and
duration, and anything left.

## Repo law and lane rules (bind every step)

- Before EVERY Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n25/appdata/path` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  Anything that renders: `--rendering-driver d3d12`; any windowed run: `--position 0,1440` (never the main display).
  One Godot process at a time (you are the only Godot user of this lane while you run). Free your own processes by PID, never by name.
- AGENTS.md and STANDARDS.md are law. Typed GDScript, files about 200 lines (hard 300), functions <= 40 lines,
  <= 5 parameters, `Log` not `print`, no raw keycodes, UI text through `Loc.t()`/`QuestText` as the prologue already does.
  RNG only through the registry; sim steps on `SimClock.TICK_DT`.
- Fix lint and format findings in your own edits and go on (`node tools/lint/lint.mjs`, gdformat). Run
  `node tools/gate/quick.mjs` before each commit.
- One commit per change, staged per path (`git add <path>`; `git commit -- <paths>` is fine). Banned: `git stash`,
  `git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push. Commit `.uid` files with new `.gd`. After new
  scripts or art, run a Godot `--import` before committing.
- Mutate is capped: `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
- Every shipped scenario and tape outside the prologue stays byte-identical; quest 1's scripts, lines and rules do not change;
  the native sim and parity digest do not move; the 60 s replay stays `cbeb734ff9b97c41`.
- **Owned paths (allowlist)**: `project/boot/prologue/**` EXCEPT the yard lane's scenery files (`prologue_yard*.gd`,
  `prologue_floor.gd`, `prologue_props.gd`, `prologue_bodies.gd`, anything under `project/boot/prologue/art/**`); the
  non-scenery parts of `project/data/tables/prologue_stage.json` (beats, checkpoints, prompts, enemy placement; NOT its `yard`
  block or `yard_size_m`) and its schema; `project/data/tables/prologue_lines.json` (never change the owner's text);
  `project/dev/prologue/**`, `project/dev/bots/prologue_bot.gd`, `project/tests/unit/test_prologue_*.gd`,
  `project/tests/scenarios/scenario_prologue_*.gd`; plus whatever the package names. Shared append-only, one line each:
  `docs/decisions.md`, `project/boot/launch_args.gd` `KNOWN_FLAGS` (then
  `node tools/debt/debt.mjs --update --accept-regression="<flag> for n25 path"`), `tools/debt/baseline.json` via the debt tool only.
  **Any other path: stop and report it as a NEED in your final message; do not edit it.**
- **Forbidden** (other night lanes are editing them): `project/features/player/**`, `project/features/souls/**`,
  `project/features/gauntlet/**`, `project/features/combat/kills/**`, `project/data/tables/combat.json`,
  `project/data/tables/input_actions.json`, the numbers of any EXISTING row of `enemies.json` / `weapons.json`,
  character art, the yard lane's scenery files listed above, any other worktree.
- Do not invent story, characters, lines or quest content. The owner's lines are verbatim.
- Colour law: red is blood only; vermilion only for danger, objectives and Rivet's collar; teal only for souls; amber for heat.
- If you are about to run out of time: commit what is green, and say in the final message exactly what is left.
