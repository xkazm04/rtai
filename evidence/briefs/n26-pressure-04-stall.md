# Brief n26 pressure 04: the stall on seed 9

Hard stop HARDSTOP wall clock (stop, commit what is green, report). Commit deadline for the fix + test COMMITBY; the measurement batches of step 8 run after it and their evidence is committed by the hard stop.

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
- **Director's lead (12:25, from the result files):** in every stalled run the frozen wave's `form_seconds` has NO
  `rivet` key and Ohm and Tonnage BOTH accumulate time at once (average-9 wave 40: ohm 423.4 s, tonnage 418.9 s,
  dent 0, kerf 0, hp min = max 137.5; expert-1 wave 33: ohm 498.8 / tonnage 496.35; average-8 wave 40: 284.7 / 531.7);
  the wave before it already shows the switch (dent 0.0, tonnage 0.0 keys appear, rivet gone). Every normal wave logs
  `rivet` seconds. So Rivet is stuck in a ghost FORM (the transformation, or a deploy that never returns him), possibly
  flipping between Ohm and Tonnage, and in that state nobody damages anybody. Check `python` over
  `evidence/n23-loop/moves/on/runs/{average-9,average-8,expert-1}.json` `waves[-3:]`. Since n24,
  `transform_unlocked` is false in the gauntlet (docs/decisions.md "n24 ghost deploy cost"), which may hide the freeze on
  HEAD, but the melee lane is building the earned transformation tonight (a mastered ghost unlocks the form for the
  run), which would bring it back. So: reproduce with the transformation enabled (the dev override, or the
  `transform_unlocked` value in a dev/test-only way), find why the form never ends / why combat stops in it, and fix it in
  the owning code. If the owning code is `project/features/souls/**` (melee lane's) or the player files (keys lane's),
  do NOT edit it: write the cause, a minimal patch as text in `evidence/n26-pressure/stall/cause.md`, and a test that
  fails on the cause marked pending (`pending("NEED melee: ...")`) and report a NEED; a bot-side fix in
  `project/features/gauntlet/**` (the bot never leaves the form) is ours.
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

## Correction to the Director's lead (12:40, read before step 1)
The "no `rivet` key" part is NOT evidence: those rows were filled by `project/features/gauntlet/bot/bot_street_stats.gd`,
which keys `form_seconds` only by the ghost forms (`_begin` seeds `stage.pilot.ghosts.forms.table.order`, line ~62, and
`step` counts `me.form` only when `_forms.has(me.form)`, line ~39), so base-Rivet time is never written there. What IS
evidence: in one frozen wave the bot spent 842 s (average-9 w40), 995 s (expert-1 w33) and 816 s (average-8 w40) settled
in Ohm or Tonnage forms, and the wave before it already shows Ohm time without the wave closing (`seconds` null). So the
bot does sit transformed for most of the frozen wave; whether that is the cause or a symptom (the bot transforms because
nothing else works) is what step 2 must decide. Do not stop at "it is in a form": name why no damage happens either way.

## Step 8 (Director, 14:05): the three medians on the final state (item 5 of the lane), run after your fix is committed
Start these by FIXSTART at the latest, fixed or not (then on whatever HEAD is: say so). They also serve as step 5's
"re-run the reproducing seeds" (seeds 1-10 include average-8/9 and expert-1/9). The tree must be clean of code edits
(evidence and briefs untracked are fine; the batch records `git.dirty`).
```
node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=0 --waves=40 --jobs=1 --out=<abs lane>/evidence/n26-pressure/medians/salt0
node tools/gauntlet/batch.mjs --profile=all --pick=greedy --controls=wheel --seeds=10 --seed0=1 --salt=1 --waves=40 --jobs=1 --out=<abs lane>/evidence/n26-pressure/medians/salt1
node tools/gauntlet/report.mjs --batch=<abs lane>/evidence/n26-pressure/medians/salt0/batch.json
node tools/gauntlet/tune.mjs floor --before=<abs lane>/evidence/n26-pressure/medians/salt0/batch.json --null=<abs lane>/evidence/n26-pressure/medians/salt1/batch.json --out=<abs lane>/evidence/n26-pressure/medians/floors.md
```
(~16 min per batch on today's balance.) Do NOT retune and do NOT run `tune.mjs apply`/`night.mjs`: the owner plays first.
Write `evidence/n26-pressure/medians/medians.md`: per profile the median death wave (salt 0 and salt 1), killers, any
run that hit the tick cap or the freeze report (it must be none after your fix), and the floor from `floors.md`; compare
with main's n24 numbers in `docs/day/2026-11-23/n24-pressure/REPORT.md`. Commit `evidence/n26-pressure/medians/**`
(batch.json, report, floors, medians.md, the runs/*.json; not the per-run Godot logs if they exceed 5 MB in total).
If the second batch cannot finish by the hard stop, stop it, commit the first with a line saying so.
Allowlist addition: `evidence/n26-pressure/medians/**`. Time order inside this call: fix + test + `--changed` + quick ->
commit (COMMITBY) -> step 8 batches -> while nothing else may use Godot, the full unit suite and the scenarios
(`node tools/tests/run_scenarios.mjs --only=<touched>,replay_60s,<quest 1 scenario names>`) run AFTER the batches only if
the hard stop allows; otherwise say "not run" (the Director's gate runs the full suites at 17:25).
