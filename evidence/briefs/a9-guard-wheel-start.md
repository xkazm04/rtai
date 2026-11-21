# Brief a9-wheel-start: the owner's alternative as one flag (lane `guard`, run n22)

Wall-clock HARD STOP: 05:55 local. Commit by 05:50. If it is not committed green by 05:50, restore every file you touched with
`git checkout -- <path>` (per path) and delete new untracked files you created, so the tree is clean: the lane's gate runs at
06:15 and refuses a dirty tree. Report what you measured either way.

Before every Godot or test run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Never kill by name.

## Why
The wheel opens on hands. You measured (a6) that 16 scenarios fail under `--controls=wheel`, most because a stage hands Rivet a
gun and the tape holds `fire` while the wheel is still on hands. The owner must choose: open on hands (tonight's default) or open
on the weapon the stage hands Rivet (hands stays slot 0 and is one scroll away). Give him the alternative as one launch flag,
OFF by default, and measure it.

## Part 1: the flag (its own commit)
`--wheel-start=hands|drawn`, default `hands` (absent = hands = exactly today's behaviour, byte for byte). Declare it in
`project/boot/launch_args.gd` `KNOWN_FLAGS` (one appended line, shared file, append only; accept the ratchet with
`node tools/debt/debt.mjs --update --accept-regression="--wheel-start for n22 guard"`). Read it once in `ControlsMode` (or a
small static beside it in `project/features/player/`). Under `drawn`, `RivetWheel.bind` / its first `_sync` selects the weapon
Rivet already holds (`arena.rivet.weapon`, hands when empty) instead of HANDS, without counting a switch and without showing the
readout. Untouched-wheel hash neutrality (af073cf1c) must still hold under both values. Unit tests: absent flag = hands;
`drawn` with a stage pistol opens on the pistol and `weapon_prev` reaches hands; legacy ignores the flag.

## Part 2: measure (no commit needed; numbers in your report)
Re-run your a6 scratch scenario runner under `--controls=wheel --wheel-start=drawn`: scenarios passed / failed, the names of
those still failing, the 60 s replay hash and the quest 1 input replay hash (expect `cbeb734ff9b97c41` and `37bf8deacaad2f48`).
Then the stock suite (default flags) must still say `65 ran, 0 failed` with `cbeb734ff9b97c41`, and
`node tools/tests/run_unit.mjs --changed` green. Copy the measurement table to `evidence/guard-flip/wheel-start-drawn.md` and
commit that file on its own (only if Part 1 is committed).

## Allowlist (any other path: stop, report a NEED)
`project/features/player/**`, `project/boot/collect_call/stage_pilot.gd` (call site only, if unavoidable), one appended line in
`project/boot/launch_args.gd`, `tools/debt/baseline.json` (through the debt tool only), new tests
`project/tests/unit/test_rivet_wheel_start*.gd`, `evidence/guard-flip/wheel-start-drawn.md`, `build/**`.
Forbidden: everything else, notably `project/data/**`, `project/features/hud/**`, `project/features/combat/**`,
`project/dev/gauntlet/**`, `project/features/gauntlet/**`, `docs/**`, `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Law
Never delete or reword an existing comment. Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions
<= 40 lines, <= 5 params; `Log` not `print`; no global RNG. `node tools/gate/quick.mjs` before each commit. One commit per part,
staged per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`, `--amend`, rebase, `reset --hard`, push. Fix lint and
format findings in your own edit and go on. `node tools/mutate/mutate.mjs --file=<the file holding the start logic> --max=20
--lines=<your changed lines>` if time allows before 05:50 (skip it rather than miss the commit).

## Report
Commit SHAs + files, the flag's exact spelling, the measurement table (legacy / wheel+hands / wheel+drawn: passed / failed,
replay hash, quest 1 hash), the still-failing names under `drawn`, mutate score if run, and `git status --short` at the end
(must show no tracked modification).
