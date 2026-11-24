# Brief n28-01-dash: a shorter dash cooldown (40 -> 24 ticks)

Lane `keys`, branch `n28-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Check `date` first and often. Commit the change by 17:20 (the pre-commit hook takes about 12 minutes on this shared
machine: start the commit by 17:05). Report and END by 17:40 at the latest, whatever state you are in.**
Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`, no `commit -a`,
no `reset --hard`, never push. Fix lint and format findings in your own edit and go on. mutate: `--max=20`, changed lines
only, with a `--tests=` subset.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440` (never the main display). Only one Godot process at a time in
this lane; free your own by PID, never by name. Never launch Godot raw: go through `tools/dev/run.mjs`, the test runners,
the gate or `tools/lib/godot.mjs` (they respect the run's 8 GB RAM cap; `mem-budget: waiting` in a log means the machine is
full, not a hang). This worktree has not been imported yet: run one headless `--import` first.
If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`: stale class cache, `--import` and commit again.

## Why
Owner (n27 verdicts, last `DECISION n27 verdicts (owner)` line of `docs/decisions.md`): a shorter dash cooldown, his answer
to "two troopers against the dash". `docs/day/2026-11-24/n27-pressure/REPORT.md` section 2: a dash is 10 ticks plus a
40-tick cooldown (one every 50 ticks); after 10 s in `pair_dash` seeds 3 and 5 the troopers' second rocket comes 36 to 49
ticks after the first, the press for it is refused, and Rivet loses 40.4 and 48.4 HP. Contract between the lanes: the cycle
(dash ticks + cooldown) must be at or under 36 so one dash covers each rocket. Director's pick: **`cooldown_ticks` 24**
(cycle 34, 2 ticks of margin).

## Part A (commit by 17:20)
1. `project/data/tables/rivet_motion.json` `dash.cooldown_ticks` 40 -> 24. Read `project/features/player/player_motion_dash.gd`
   (+ `_stats`, `player_motion_table.gd`) and find out exactly when the cooldown starts counting (after the 10 burst ticks?
   after recovery?) and whether the shortest press-to-press interval really is 34 ticks. If it is longer (an off-by-one, a
   recovery in between), lower the value until the measured shortest interval is 34 and say why in the decision line.
2. A unit test (new or in the existing dash test file, find it: `grep -rln "dash" project/tests/unit`) that drives the dash
   through the sim tick by tick, holds the dash input pressed every tick, and asserts the shortest interval between two
   accepted presses is <= 36 ticks and equals 10 + cooldown_ticks as read from the table (not a hardcoded 34). Fix every
   existing test that pinned 40 or 50 (grep for them).
3. The doc string in `rivet_motion.json` if it names the number; the table's schema if it bounds it.
4. **Tapes, replays and scenarios**: run the full scenario suite (`"$GODOT_BIN" --headless --path project -s
   res://tests/run_scenarios.gd`, or `node tools/tests/run_scenarios.mjs` if present) and the full unit suite
   (`node tools/tests/run_unit.mjs`). Any shipped replay/tape/scenario whose digest moves because it presses the dash: re-pin
   it the way the repo re-pins (find the tool or the pinned value; read how earlier `re-pin` decision lines in
   `docs/decisions.md` did it), and list each one by name in the decision line. Never re-pin anything that does NOT press the
   dash: if something else moves, stop and report it.
5. One line appended to `docs/decisions.md` (append-only, at the end):
   `- [2026-11-24] DECISION n28 keys dash: dash.cooldown_ticks 40 -> <n>: dash 10 ticks + <n> = <cycle> ticks press to press,
   under the 36-tick shortest gap between two troopers' rockets (n27-pressure REPORT section 2), so one dash covers each rocket
   of a pair; <the re-pinned tapes or "no tape moved">; rejected 26 (no margin) and keeping 40 (second press refused).`
6. `node tools/gate/quick.mjs` (or with `--no-godot` if it says so), then commit with a message like
   "Dash cooldown 40 -> 24 ticks so one dash covers each rocket of two troopers". Write the sha in your report.

## Part B (only after A is committed): measure it
1. `node tools/dev/run.mjs pressure_dash_trace -- --out=C:/Users/kazda/kiro/gtai-wt/n23-controls/evidence/n28-keys/dash_trace_after.md --seeds=3,5,1`
   (read `project/dev/gauntlet/pressure_dash_trace.gd` first; it is the pressure lane's tool from n27; do NOT edit it).
   Compare with the n27 trace (`evidence/n27-pressure/takes/dash_late.md` if it exists in this tree; otherwise render the
   before from a temp worktree at `d0ab9d03a`: `git worktree add build/wt-before-dash d0ab9d03a`, run the same command there
   with `--out=.../dash_trace_before.md`, then `git worktree remove build/wt-before-dash`). Report per seed: HP lost after 10 s,
   refused presses, before and after. Write `evidence/n28-keys/dash.md` with the table, the commands and the numbers.
2. `node tools/mutate/mutate.mjs --file=project/features/player/player_motion_dash.gd --max=20 --lines=<the cooldown lines>
   --tests=<the dash test basenames>` and quote killed/(killed+survived).
3. Commit `evidence/n28-keys/dash.md` (+ the trace files) with its own commit.

## Allowlist (anything else: stop and report a NEED line)
`project/data/tables/rivet_motion.json` (dash block and doc only), `project/data/schemas/rivet_motion*.json`,
`project/features/player/player_motion_dash*.gd` (only if a bug forces it), dash unit tests under `project/tests/unit/`,
tests that pin the old cooldown, the pinned digests of tapes/replays/scenarios that press the dash (re-pin only),
`docs/decisions.md` (append one line), `evidence/n28-keys/**`, `build/**`.
Forbidden: every other table (`combat.json`, `enemies.json`, `weapons.json`, `ghost_*.json`), `project/dev/gauntlet/**`,
`tools/gauntlet/**`, `project/features/combat/**`, `project/boot/prologue/**`, `native/`, other lanes' worktrees, `main`.

## Report (final message)
The value shipped and why, the measured shortest press-to-press interval, tests changed, each re-pinned tape by name (or
"none moved"), the commit sha(s), the before/after trace table, the mutate score, anything you could not do.
