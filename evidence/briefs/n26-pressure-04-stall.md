# Brief n26 pressure 04: the stall on seed 9

Hard stop HARDSTOP wall clock (stop, commit what is green, report). Commit deadline COMMITBY.

## Setup, every shell
`export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/pressure` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before any Godot,
test, gate or tool run. One Godot process at a time in this worktree. After new scripts: one `--import` before committing.

## Goal
A gauntlet run that sits without progress until the tick cap. Reproduce it, find the cause, fix it or prove it cannot
recur, and leave a scenario or unit test that FAILS on the cause (check that: run the test against the unfixed code).

## What is known (read these first)
- n23 loop (2026-11-22, rev `548989d7e`): 4 of 30 runs (average-8, average-9, expert-1, expert-9) ended at the
  216000-tick cap. Logs and results in this tree: `evidence/n23-loop/moves/on/logs/<profile>-<seed>/`,
  `evidence/n23-loop/moves/on/runs/average-9.json`, `.../expert-1.json`. The loop journal
  `docs/day/2026-11-22/n23-loop/JOURNAL.md` 07:08 and REPORT line 86: last log lines `wave N tick T block B, 2-3 alive`
  after a timed-out wave; street's later reading (its JOURNAL 08:00, `docs/day/2026-11-22/n23-street/JOURNAL.md`): waves
  32-33 timed out as built, wave 34's whole roster waits on the 40-alive cap, then about 40 hostiles and Rivet deal no
  damage to each other (hp min = max, guard 0, cover 0): a "combat freeze". Suspected (never verified): a move state
  that holds the squad's attack slots / tokens, or the bot looping a move opening (`move opening BLINK on sentry_turret`).
- n24 pressure (`docs/day/2026-11-23/n24-pressure/REPORT.md` "What does not"): "Average seed 9 stall (sentry_turret +
  shield_robot left over)". base-main expert-2 stalled at wave 21 (`evidence/n24-pressure/base-main/`).
- The harder balance since then kills most runs before wave 12, so the stall may no longer show by itself.

## Steps
1. Reproduce: first on today's HEAD (`node tools/dev/run.mjs gauntlet --seed=9 --bot=average --pick=greedy
   --controls=wheel --waves=40 --result=<abs json>`, also seed 8 average and seed 1 / 9 expert). If HEAD does not stall,
   reproduce on `548989d7e` in a throwaway worktree under `%TEMP%` (`git worktree add`, copy `project/native/bin` from
   this worktree, `--import` once; remove the worktree with `git worktree remove` when done), or force the state on HEAD
   with dev flags (e.g. `--wave-timeout=<s>` exists) so the same conditions arise.
2. Find the cause by reading the state at the frozen tick: per hostile its state, token, attack slot, target, distance
   to Rivet, line of sight; the squad's slot counts; the bot's intent. A dev probe under `project/dev/gauntlet/` that
   dumps this is fine. Name the cause with file:line.
3. Fix it in the owning code if it is in `project/features/gauntlet/**`, `project/features/combat/squad/**` or
   `project/features/combat/ai/**` (pressure may touch these for this item only), keep the fix minimal, data-free unless
   a value is the cause. If the cause is the test bot only (it never moves to reach a leftover), fix the bot, and ALSO
   make the run end honestly: a wave with no damage either way for 60 s is reported (result `freeze` field or a log
   line), never read as survival. Say plainly whether a human player could hit the same freeze.
4. A test that fails on the cause: a unit test on the slot/token logic or a scenario under `project/tests/scenarios/`
   (registered like the others) that builds the frozen state and asserts progress. Show it red on the unfixed code
   (temporarily, do not commit the red state) and green after.
5. Runs: `node tools/tests/run_unit.mjs --changed`, the FULL `node tools/tests/run_unit.mjs`, the scenario suite
   (`"$GODOT_BIN" --headless --path project -s res://tests/run_scenarios.gd`). Quest 1 tapes, `replay_60s` and the
   prologue must NOT move. A gauntlet digest that moves gets one `docs/decisions.md` line. `node tools/gate/quick.mjs`
   before each commit. Then re-run the reproducing seeds: no stall.
6. `node tools/mutate/mutate.mjs --file=<the fixed file> --max=20 --lines=<changed lines>`, quote the score.
7. `evidence/n26-pressure/stall/cause.md`: the frozen state, the cause (file:line), the fix, the test, the before/after
   runs. One `docs/decisions.md` line: `- [2026-11-23] DECISION pressure stall: <cause> ... <fix> ... <test>.`

## Allowlist (any other path: stop and report a NEED)
`project/features/gauntlet/**`, `project/features/combat/squad/**`, `project/features/combat/ai/**`,
`project/dev/gauntlet/**`, `project/tests/unit/**` and `project/tests/scenarios/**` (new tests, and the registration list),
`project/data/schemas/gauntlet_run.schema.json` (one optional field), `evidence/n26-pressure/stall/**`,
`docs/decisions.md` (append one line), `project/boot/launch_args.gd` `KNOWN_FLAGS` (append one flag if a new dev flag
is needed), `tools/debt/baseline.json` (only via `node tools/debt/debt.mjs --update`, with
`--accept-regression="<reason> for n26 pressure"` if needed).
Forbidden: `input_actions.json`, `rivet_motion.json`, `project/features/player/**`, `project/features/souls/**`,
`project/features/combat/kills/**`, `ghost_attacks.json`, `ghost_forms.json`, `cast_cards.json`, `project/boot/prologue/**`,
`prologue_stage.json`, any art, balance numbers in any table, root `JOURNAL.md` / `REPORT.md`.

## Law
Typed GDScript, files about 200 lines (300 hard), functions <= 40 lines, <= 5 params, `Log` not print, no global RNG.
Fix lint and format findings in your own edit and go on. Stage per path; `git commit -- <paths>`; no stash, no
`add -A`, no amend, no rebase, no reset --hard, never push. Commit `.uid` with any new `.gd`.

## Report
Repro command and tick, the cause with file:line, the fix, the failing-then-passing test, unit/scenario counts,
mutate score, digests moved, commits, and whether a human could freeze the same way.

## Lessons from call 01 (bind this call)
- Commit BEFORE the long suites: the full scenario suite took 25+ min under machine load and call 01 missed its commit
  deadline with everything staged. Order: change + unit --changed + quick -> commit -> full unit -> scenarios
  (`node tools/tests/run_scenarios.mjs --only=<names>` for the touched ones plus `replay_60s` and quest 1 if the full run
  does not fit) -> fix-up commit if needed.
- The pre-commit hook's tool tests can fail on process-timing checks under load: retry the commit once; do not change
  hook settings or lane env overrides.
