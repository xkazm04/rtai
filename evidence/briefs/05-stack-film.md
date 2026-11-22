# Brief 05 (street lane, n23): stacked waves on film, the owed-pick counter, the timer warning

Hard stop: 05:55 wall clock (check `date`). Commit deadline: 05:45 (Part A first; if B or C cannot be committed by then, report them unfinished). Parts A, B, C in order, each committed before the next. Write your final report BEFORE any mutate run; mutate is the last step and capped (`--max=20`, changed lines). Never run more than 5 full gauntlet runs in this call; a sweep that does not fit is reported, not waited on.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
Anything that renders: `--rendering-driver d3d12`; any window `--position 0,1440` (secondary screen, never the main display). One Godot process at a time. Never kill processes by name; only a PID you started. Read `tools/README.md` for the film kit (`tools/film/film.mjs`, `compare.mjs`, `sheet.mjs`).

## What exists
Commit `e24cc3847` made a timed-out wave stack: `project/features/gauntlet/gauntlet_waves.gd` schedules the next wave over the live ones when `wave_timeout_s` (90, `gauntlet.json`) runs out, `max_alive` 40 delays spawns, picks are owed until the street is clear (`owed_total`, `owed_index`, `owed_remaining`, `pick_wave()`), the HUD (`project/dev/gauntlet/gauntlet_hud.gd`) shows `GAUNTLET__WAVE_STACK` with the alive count. Problem: in 6 bot runs so far no wave ever timed out (bots clear in 10 to 20 s), so stacking has never been seen live or on film.

## Part A: a seed that stacks, on film
1. Add a dev-only launch flag `--wave-timeout=<seconds>` to `project/dev/gauntlet/gauntlet.gd` (`KNOWN_FLAGS` there; if `tools/dev/run.mjs` or lint's `launch-flags` needs it in `project/boot/launch_args.gd` `KNOWN_FLAGS`, append one line and accept the debt rise with `node tools/debt/debt.mjs --update --accept-regression="--wave-timeout for n23 street"`). It overrides only `GauntletStreet.timeout_ticks` for that run; absent = the table's 90 s. The result file records it as an optional top-level `wave_timeout_s` (only when the flag was given; describe it in `project/data/schemas/gauntlet_run.schema.json` and keep `tools/gauntlet/test_run_schema.py` green: run it).
2. Find a run where 2 and then 3 waves are alive at once: first try the REAL 90 s timer with `--bot=novice` on seeds 1 to 3 (no `--waves` limit); if none stacks, use `--wave-timeout=12` (or the shortest that still makes the point) with `--bot=average --seed=7`. Say which one you used, plainly. Record in `evidence/street/stacking-seeds.md`: seed, bot, timer, the ticks at which 2 and 3 waves were alive (from the `wave %d tick %d block %d, %d alive` log line), `timed_out` rows, `spawn_delayed` counts, death wave and `death.by`, and whether the result has a valid `death` (the run must end in death, not `capped`).
3. Run the same command twice and `cmp` the two result files (byte-identical; quote it).
4. Film it at 32 px/m, tilt 70, 1080p60, 20 to 40 s, starting a few seconds before the first stack, so the HUD shows `2 alive` and later `3 alive` and the new wave visibly arrives over the survivors: `C:/Users/kazda/kiro/gtai-masters/n23/street/stack/stack-seed<seed>-32.mp4` (use `tools/film/film.mjs` if it can drive the gauntlet scene with flags, otherwise the gauntlet scene windowed with a frame dump, whatever the kit supports; read `tools/README.md`). Pull three stills from it (1 wave, 2 alive, 3 alive) and LOOK at them: is the HUD readable, are both waves' enemies on screen? Report what you see.
Commit A.

## Part B: "pick 2 of 3"
When more than one pick is owed, `project/dev/gauntlet/gauntlet_pick_view.gd` shows a counter under the caption: `tr("GAUNTLET__PICK_OF")` with `{"index": waves.owed_index, "total": waves.owed_total}` (add the key to `project/data/loc/en.po`; no hardcoded text). Hidden when only one pick is owed. Unit test in `project/tests/unit/test_gauntlet_pick_view.gd`: three owed picks show 1 of 3, 2 of 3, 3 of 3 in order, one owed pick shows no counter. Check how the offers skip a wave whose offer is empty (`_next_offer`); the counter must not show "4 of 3" or skip numbers silently (if a wave's offer is empty, count only the waves that get an offer, and test it). A still of the pick screen with the counter at 32 px/m (`--pick-view` exists) to `C:/Users/kazda/kiro/gtai-masters/n23/street/stack/pick-counter.png`; look at it.
Commit B.

## Part C: the wave timer warns in its last 10 s
The gauntlet HUD's wave timer turns to a warning colour when 10 s or less are left before the next wave is stacked on (amber is allowed for heat/overload; use amber, not vermilion and not red, and not teal). It needs the time left: expose it from `GauntletWaves` (e.g. `seconds_left(tick) -> float` from `_next_wave_tick`; -1 when no timer runs). Unit test: 11 s left = normal colour, 10 s = warning, no live wave = normal. A still with the warning colour visible to `C:/Users/kazda/kiro/gtai-masters/n23/street/stack/timer-warning.png`.
Commit C.

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green.
- `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` summary line, unchanged pass count (quest 1 and the 60 s replay untouched).
- `node tools/debt/debt.mjs --check`; on `tighten:` run `--update` and commit the baseline.
- New `.gd` files: `"$GODOT_BIN" --headless --path project --import` once and commit the `.uid`.
- Last: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_waves.gd --max=20 --lines=<your changed lines>`; quote killed/(killed+survived).

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
`project/dev/gauntlet/**`, `project/features/gauntlet/**` except `bot/`, `project/data/loc/en.po` (your keys only), `project/data/schemas/gauntlet_run.schema.json` (your optional field only), one appended line in `project/boot/launch_args.gd` `KNOWN_FLAGS` if needed, `project/tests/unit/test_gauntlet_*.gd`, `evidence/street/**`, `C:/Users/kazda/kiro/gtai-masters/n23/street/**`, `tools/debt/baseline.json` through the debt tool, `.uid` files of new scripts.
Forbidden: `project/features/player/**`, `project/features/gauntlet/bot/**`, `tools/gauntlet/**` (run its test, never edit it), `project/data/tables/enemies.json`, `combat.json`, `gauntlet_bonuses.json`, `project/data/tables/gauntlet.json` numbers, `project/features/combat/**`, `project/features/souls/**`, tapes and goldens, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.

## Notes from the director (n23 03:34-04:40 call)
- `C:/Users/kazda/kiro/gtai-masters/n23/street/` holds only films, stills and `frames.json`. Put capture scripts, logs, patches and JSON results under `build/street/` (git-ignored) or `evidence/street/` (committed notes), never in gtai-masters.
- Mutate: run it from this worktree exactly as `node tools/mutate/mutate.mjs --file=<project-relative .gd> --max=20 --lines=<a-b>`; it makes its own temp worktree at HEAD (commit first). Do not pass a scratch or root directory; the last call failed with "is the repo root" that way.
- Never run more than 5 full gauntlet runs; prefer `--wave-timeout` short runs for the stacking proof once one real 90 s novice attempt (seed 1) has been tried.
