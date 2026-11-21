# Brief a8-green: make HEAD green before the gate (lane `guard`, run n22)

Wall-clock HARD STOP: 05:45 local. Commit by 05:40. Nothing new: this call only fixes and measures.

Before every Godot or test run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Never kill by name.

## Part 1: the red assertion you reported (its own commit)
`project/tests/unit/test_rivet_wheel_pilot.gd:169` still expects alpha 0.5 at 0.5 s; since 371ccf9fe the readout holds full
opacity for 0.6 s. That file is guard's own test: you may edit it now. Change only that expectation to the new contract
(1.0 at 0.5 s; if you want, add one check below 1.0 after the hold, using `WheelReadoutView.HOLD_TICKS`). Then re-run
`node tools/mutate/mutate.mjs --file=project/features/player/wheel_readout_view.gd --max=20` (default mapped tests) and quote
the score; say which survivors are pixels only.

## Part 2: the full suites on the final commit (measure, do not chase new work)
1. `node tools/lint/lint.mjs`
2. `node tools/tests/run_unit.mjs` (the no-arg full run: every file).
3. `"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd` (expect 65 ran, 0 failed; quote the replay_60s hash,
   expect `cbeb734ff9b97c41`).
If anything is red and the cause is in a guard file (allowlist below) fix it in its own commit; if it is outside, stop and report
it with `file:line`, the failing test and the triage line from `build/test-results/unit-triage.json`.

## Allowlist (any other path: stop, report a NEED)
`project/features/player/**`, `project/features/combat/rivet_blast.gd`, `project/features/combat/enemy_rounds.gd`,
`project/features/combat/shot.gd`, `project/features/arena/arena_projectiles.gd`, `project/dev/guard/**`, tests named for these
(`project/tests/unit/test_rivet_wheel*.gd`, `test_wheel_readout*.gd`, `test_player_guard*.gd`, `test_rivet_blast*.gd`,
`test_controls_guard.gd`, `test_shot_round_size.gd`), `build/**`.
Forbidden: everything else, notably `project/features/hud/**`, `project/features/combat/weapons/**`, `project/dev/gauntlet/**`,
`project/features/gauntlet/**`, `project/features/combat/ai/**`, `project/data/tables/enemies.json`, `docs/**`, `JOURNAL.md`,
`REPORT.md`, `evidence/**`.

## Law
Never delete or reword an existing comment. Typed GDScript, warnings are errors. `node tools/gate/quick.mjs` before each commit.
One commit per part, staged per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase,
`reset --hard`, push. Fix lint and format findings in your own edit and go on.

## Report
Commit SHAs, the three suite summary lines verbatim (lint, unit pass/fail/skip, scenarios + replay hash), the mutate score.
