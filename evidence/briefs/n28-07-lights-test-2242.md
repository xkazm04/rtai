# Brief n28-07 `lights-test`: re-pin one unit test to the shipped default yard (lane yard, run n28)

HARD STOP: 23:20 local (stop work, write the report, END). LAST COMMIT started by 23:08. Check `date` often. You are an in-session builder: the hard stop is absolute. If the commit cannot start by 23:08: restore the file to HEAD (`git checkout -- <path>`), report, END.

## Before anything (every shell that runs Godot)
```
export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
cwd `C:/Users/kazda/kiro/gtai-wt/n25-yard` (branch `n28-yard`). **One Godot per lane: the director's gate (node pid 46392, reel gate) may still be running. Before your first Godot launch, wait until `tasklist //FI "PID eq 46392"` shows no node.exe (poll every 60 s; write the code edit meanwhile).** Kill only PIDs you started. 8 GB memory cap: `mem-budget: waiting` = wait. Never run `builder.mjs`, `astra.mjs` or `codex`. Never stage `hs_err_pid*.log`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Why
Commit 5519b3e11 switched `prologue_stage.json` `yard.dressing` to `arched_line`. The gate (`build/gate/5519b3e118ce/unit-tests.json`) has one failure:
`res://tests/unit/test_prologue_yard_lights.gd:75 test_pools_land_at_each_fixture_in_world_pixels_and_hold_through_the_fight: [yard_hall_mouth] expected to equal [yard_fire]: burst_door`.
The test installs the DEFAULT yard's lights (`yard.dressing.lights`) but reads the expected pools from the `line_fire` row. arched_line's pools are the same eleven ids at the same `at`, but `burst_door` and `collapsed_wall` are kind `yard_hall_mouth` (the burning hall mouth), `conveyor_door` stays `yard_fire`.

## The change (exactly this)
In `project/tests/unit/test_prologue_yard_lights.gd`, `test_pools_land_at_each_fixture_in_world_pixels_and_hold_through_the_fight`:
1. Read the expected row from the stage's default dressing, not a hard-coded id: `var dressing_id: String = str(stage.raw["yard"]["dressing"])` (check the real key path in `prologue_stage.json` line ~580 and in `PrologueYard.from_stage`), then `table.raw["dressings"][dressing_id]["lights"]`. Then the fixture loop tests whatever ships.
2. Counts for the shipped default: assert `dressing_id == "arched_line"` with a message, then `yard_fire` 1 (conveyor door), `yard_hall_mouth` 2 ("burst door, collapsed wall"), `yard_fire_mid` 4, `yard_lamp` 3, `yard_lamp_gate` 1. Keep the `step(11701, ...)` / active / dropped asserts.
3. Do not touch `test_dusk_registers_the_grade_and_decodes_both_inks_from_the_row` (it resolves `line_fire` explicitly and passes).
4. `grep -rn "yard.dressing\|from_stage" project/tests/unit` for any other test that installs the default yard and compares it to a named row; the gate reported only this one failure, so change only what fails.

## Checks (quote each result line in your report)
- `node tools/godot/check.mjs res://tests/unit/test_prologue_yard_lights.gd`
- `node tools/tests/run_unit.mjs --select=test_prologue_yard_lights,test_prologue_raised_line,test_prologue_yard_dressing`: all pass.
- `node tools/gate/quick.mjs`, then `git commit -- project/tests/unit/test_prologue_yard_lights.gd` with message `Yard n28: the yard lights test reads the shipped default (arched_line: two hall-mouth pools), gate fix after the default switch`. The pre-commit hook can take about 12 minutes: budget for it. A hook failure in `tools/film/kill_reel_*.break.test.mjs` = stale class cache: run `"$GODOT_BIN" --headless --path project --import`, commit again. A hook failure in `tools/merge/step_guard.break.test.mjs` or `tools/merge/morning_run.break.test.mjs` timing tests is machine contention, not this change: re-run that one file with `node --test <file>` once and quote the result; if it passes alone, commit again. Never `--no-verify`.

## Owned files (allowlist). Any other path: stop and report a NEED.
`project/tests/unit/test_prologue_yard_lights.gd`, `build/**`.

## Forbidden
Data tables (no `prologue_yard_dressings.json` or `prologue_stage.json` edits), all other lanes' files (`project/features/**`, `input_actions.json`, `rivet_motion.json`, `ghost_*.json`, `combat.json`, `enemies.json`, `weapons.json`, `cast_cards.json`, `project/dev/gauntlet/**`), tools, art, other worktrees, the Codex image tool.

## Repo law
Stage per path; `git commit -- <path>`; no `git add -A/./-u`, no `git commit -a`, no stash, no amend, no rebase, no reset --hard, never push. Typed GDScript, functions of 40 lines or fewer. Fix lint and format findings in your own edit and go on.

## Report (your final message)
The diff, each check's result line, the commit sha, anything else you saw fail. Then END.
