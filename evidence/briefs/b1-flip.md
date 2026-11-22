# Brief b1-flip: runners take --controls, then flip the default to the wheel

Lane `controls`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls`, branch `n23-controls`.
**Hard stop: 02:10 wall clock (check `date`). Commit deadline: 02:05.** Commit each part as it lands; if you run out of time, commit what is green and report exactly what is left.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/controls`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- One Godot process at a time (headless). Never kill processes by name; only your own by PID. Native DLLs and bake are in place: never rebuild native.
- Any windowed run: `--position 0,1440`.

## Read first
`AGENTS.md`, then `evidence/guard-flip/blockers.md` (the exact work list for part 2, with the fix per scenario), `evidence/guard-flip/flip-table.md`, `evidence/guard-flip/wheel-start-drawn.md`. `project/features/player/controls_mode.gd` decides the mode from `LaunchArgs`. Some scenarios already replace launch options temporarily (`scenario_ohm_bolt_delay.gd`, `scenario_vehicle_doors.gd`): reuse that mechanism for pinning.

## Part 1 (commit 1): the runners take the flag
- `project/tests/run_scenarios.gd`: accept `--controls=wheel|legacy` (add to its KNOWN_FLAGS) and make it the mode the scenarios see (it is already a user arg so `LaunchArgs` should see it; verify, and reject any other value with exit 2).
- `tools/tests/run_unit.mjs`: `parseArgs` accepts `--controls=wheel|legacy` (any other value is a UsageError), and forwards it to the GUT Godot invocation after `--` so `ControlsMode` sees it. Node test for the parser (beside the existing `tools/tests/*.test.mjs` for run_unit, or a new `tools/tests/run_unit_controls.test.mjs`): accepts both, rejects `--controls=foo`, forwards to the godot args.
- Check: `node --test tools/tests/<your test>` green; `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd -- --controls=wheel --only=arena_course` runs; `--controls=bogus` exits 2.

## Part 2 (commit 2..n): flip the default
- `ControlsMode.id()` returns `&"wheel"` when no `--controls` is given (unknown value: warn and use wheel). The wheel opens on slot 0 `hands` (check that is what `start_drawn()==false` gives; keep `--wheel-start=drawn` working). `--controls=legacy` stays.
- Make the suite green **without weakening it** (no deleted assertions, no lowered thresholds, no skipped scenarios):
  - A scenario or unit test whose subject is the gun/blade/pickup it names: add an explicit weapon selection at its start (fix column of blockers.md) so it proves the same thing under the wheel. Do it in the shared bot/fixture when several scenarios share one (e.g. the squad fixture, the arena range bot).
  - A test whose subject is the legacy contract itself (same-grip swap and drop; null carry on walk-past: `scenario_rivet_pickup.gd`, `scenario_rifle_rack.gd` walk-past case, `test_controls_guard.gd` default assertion): pin it to legacy explicitly inside the test and add a **wheel twin** test/case that asserts the wheel behaviour (both guns kept; nothing auto-equipped; select to draw). `test_controls_guard.gd`'s default-mode assertion becomes "default is wheel".
  - Replays and tapes: a tape recorded on legacy is replayed on legacy, by a mode stored with or beside the tape (e.g. a `controls` field in the tape/golden metadata, default "legacy" for every existing tape), **not by re-recording**. The 60 s replay and the quest-1 input replay digests must stay byte-identical (`cbeb734ff9b97c41...`, `37bf8deacaad2f48...` prefixes measured last night). A golden moves only with a one-line reason; list every moved digest in your report (expected: none).
- Shipped game: the gauntlet entry already defaults to wheel (`7327c3c3d`); confirm `project/dev/gauntlet/gauntlet.gd` and quest 1 / arena entries now get wheel with no flag.
- Count before and after and put the table in your report and in `evidence/controls-flip/counts.md`: scenarios passing with `--controls=wheel`, with `--controls=legacy`, and with no flag; unit tests (`node tools/tests/run_unit.mjs`, and `--controls=legacy`) in both. Also write `evidence/controls-flip/tests.md`: every pinned, twinned and re-selected test with a one-line reason.
- A full scenario run is ~10+ min; use `--only=` for the inner loop and run the full set at the end in each mode.

## Owned files (allowlist)
`project/features/player/**`, `project/tests/run_scenarios.gd`, `tools/tests/run_unit.mjs` + its node tests, `project/tests/scenarios/**` and their tapes/goldens, `project/tests/unit/**` tests for the files above, the scenario/test bots under `project/tests/**` and `project/dev/**` that the blocker list names (arena bots, kill-lab bot, chapter bot, showcase reel bot), `evidence/controls-flip/**`. A one-line call site elsewhere is OK if you name it in your report.
**Any other path: stop and report a NEED.** Forbidden (other lanes): `project/features/gauntlet/**`, `project/dev/gauntlet/**`, `project/data/tables/gauntlet*.json`, `enemies.json`, `bosses.json`, `project/boot/prologue/**`, `project/features/souls/**`, `project/features/combat/ai/**`, `project/features/combat/squad/**`, `project/features/combat/shot*.gd`, `tools/gauntlet/**`, `test_player.json`. Do not touch `project/boot/quest1_card.gd` in this brief (next brief). Do not edit `combat_arena.gd` beyond one-line call sites.

## Repo law
- Stage per path; one commit per change; no `git stash`, no `add -A/./-u`, no `commit -a`, no `reset --hard`, **no amend, no rebase, never push**.
- Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`, InputMap actions not raw keycodes.
- Run `node tools/gate/quick.mjs` before each commit; **fix lint and format findings in your own edit and go on.** New `.gd` files need their `.uid` committed (run `"$GODOT_BIN" --headless --path project --import` after adding scripts).
- If `launch_args.gd` `KNOWN_FLAGS` needs a new flag: append one line, then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n23 controls"`.
- After the last code commit: `node tools/mutate/mutate.mjs --file=project/features/player/controls_mode.gd --max=20` and quote killed/(killed+survived).

## Report
Files changed per commit (sha), the counts table, the tests list, digests (unchanged or moved with reason), mutate score, what is left.
