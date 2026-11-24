# Brief n28-07b `lights-commit`: apply the verified lights-test diff and commit it (lane yard, run n28)

HARD STOP: 23:50 local (report, END). LAST COMMIT started by 23:30. If the commit has not succeeded by 23:45: `git checkout -- project/tests/unit/test_prologue_yard_lights.gd`, report, END.

## Before anything
```
export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/yard
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
cwd `C:/Users/kazda/kiro/gtai-wt/n25-yard`. No gate runs now (the reel gate ended at 22:52). One Godot at a time. `mem-budget: waiting` = the machine is full; wait, it is not a hang. Never run `builder.mjs`, `astra.mjs`, `codex`. Never stage anything but the one file.

## Do exactly this
1. `git apply C:/Users/kazda/AppData/Local/Temp/lights-test.diff`. The previous call wrote it and verified it: `check.mjs` ok; `run_unit.mjs --select=test_prologue_yard_lights,test_prologue_raised_line,test_prologue_yard_dressing` gave 22 passed, 0 failed. `git diff --stat` must show only `project/tests/unit/test_prologue_yard_lights.gd`, with 6 lines added and 2 removed.
2. Skip `quick.mjs`: the pre-commit hook runs the same checks. Commit at once:
   `git commit -m "Yard n28: the yard lights test reads the shipped default (arched_line: two hall-mouth pools), gate fix after the default switch" -m "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>" -- project/tests/unit/test_prologue_yard_lights.gd`
   Run it in the foreground with a long timeout (up to 25 min). The hook can take about 12 minutes on this machine.
3. If the hook fails:
   - In `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: run `"$GODOT_BIN" --headless --path project --import` and commit again.
   - In the `tools/merge/step_guard.break.test.mjs` or `morning_run.break.test.mjs` timing tests, it is machine contention: run that one file with `node --test <file>` and quote the result, then commit again once.
   - A timeout while the hook prints `mem-budget: waiting` is contention: commit again once.
   - Never `--no-verify`, never amend.

## Allowlist
`project/tests/unit/test_prologue_yard_lights.gd` only. Any other path: stop, report a NEED.

## Report (final message, then END)
The commit sha (`git log --oneline -1`) and the hook's last lines, or why it failed.
