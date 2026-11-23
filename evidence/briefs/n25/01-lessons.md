# Package 01 `lessons`: the hand lessons arrive one at a time

Wall-clock hard stop **02:15** (check `date`). Commit deadline **02:05**. Stop early when done.

## Goal (owner-facing)
In wave 1 of the prologue, the lessons claw, guard and roll must each show **once, alone, when the player can use it**.
Today (last night's report): the claw prompt fires on Dale's fall (tick ~2195) and guard and roll come 19 ticks later
when the first panic rounds fly, so three cards share the strip within 3 s. The strike lesson before it and the wheel / fire
lessons in wave 2 must keep working as now.

## What I know
- `project/boot/prologue/prologue_prompts.gd`: `offer(id, tick)` marks seen and shows for `HOLD_TICKS` (2 s); `words()` joins every
  active card with " · ". `strike` and `wheel` are not timed out in `step()`.
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

