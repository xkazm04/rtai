# Brief b2b-gait-checks (lane foes, run n31): finish item 2's checks (sonnet, 25 minutes)

Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`.
Hard stop: **30 minutes after launch, report and END**; commit as soon as checks pass.

## State
Item 2 (FoeGait: ranged foes FIGHT at 0.45x speed and may fire, TRAVEL full speed and may not) landed in
`a4a7a3537` and `09d6abdba` (files: `project/features/combat/squad/foe_gait.gd`, `foe_gait_drive.gd`,
`arena_squad.gd`, `squad_mind.gd`, `foe_attacks.gd`, `foe_cast_view.gd`, `ai/enemy_motor.gd`,
`ai/enemy_agent.gd`, `ai/enemy_roster.gd`, `enemies.json`, tests `test_foe_gait.gd`, `test_squad_burst.gd`,
`test_arena_squad.gd`). The builder did NOT run the scenarios and did not re-run the full unit suite after
its last fixes. `test_foe_gait.gd` `LEGACY_TRACE` is 0, so the legacy = pre-n31 trace assert never runs.

## Do
1. Full unit suite: `node tools/tests/run_unit.mjs` (read `build/test-results/unit-triage.json` on red).
2. Scenarios: `node tools/tests/run_scenarios.mjs` if it exists, else the AGENTS.md scenario command through a
   runGodot user. On a red scenario caused by the new gait (e.g. `scenario_arena_squad` crowding / cover /
   flank thresholds): read the scenario, decide if the threshold pins the OLD single gait (then re-pin it to
   the measured new value with a comment `n31 foes two moves`) or if the gait broke something real (then
   report it, do not paper over it). Quest 1, the native city sim and the parity digest must not move: if
   one does, STOP and report.
3. Pin `LEGACY_TRACE`: compute the trace digest with the gait in legacy mode at the parent commit
   `ba8e470b0`'s behaviour (the test's own legacy run must equal what main produces: verify by running the
   same trace code in a temp worktree at `ba8e470b0` if the test's helper can run there, e.g. copy the test
   file in; otherwise pin the current legacy value and say it is self-pinned, not main-verified).
4. One commit with the re-pins; if anything moved, append ONE line to `docs/decisions.md`
   (`- [2026-11-25] DECISION foes n31 two moves pins: <what moved, old -> new>`).

## Repo law (read AGENTS.md first)
Typed GDScript, warnings are errors. Stage per path, `git commit -- <paths>`; banned: `git stash`,
`git add -A/./-u`, `git commit -a`, `reset --hard`, amend, rebase, push, `--no-verify`. Message ends with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Fix lint/format findings in your own edit and
go on. Hook fails on `kill_reel_*.break.test.mjs` = stale class cache: Godot `--import`, commit again.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot at a time for the lane: hold `build/n31/godot.lock` (exclusive create, `b2b <pid>`; wait while
another tag holds it; delete yours when done; never delete another's).

## Owned files
`project/tests/**` pins this change moves, `project/tests/unit/test_foe_gait.gd`, scenario thresholds under
`project/tests/scenarios/**` this change moves, `project/features/combat/squad/**` and `ai/**` for a real
bug fix only, one appended `docs/decisions.md` line. Anything else: NEED in your report.
Forbidden: `project/dev/foes_n31/**`, `tools/gauntlet/**` (another builder), everything of other lanes.

## Report
Commits, the unit and scenario result lines, what moved and why, what is red and why.
