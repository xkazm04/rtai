# Brief 06 (street lane, n23): decision lines, one pinned counter, mutation scores

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. This is a short call: no new behaviour, no films. Write your final report BEFORE the mutate runs; mutate is last and capped.

## Setup for every Godot run
`export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/street` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
One Godot process at a time. Never kill processes by name; only a PID you started.

## Part A (~5 min): decision lines
Append these four lines at the END of `docs/decisions.md`, one line each, exactly in the house form (`- [YYYY-MM-DD] DECISION <area>: what was chosen, why, what was rejected.`). Append only; touch no other line.
- `- [2026-11-22] DECISION gauntlet-stack (n23 street): when the 90 s wave timer runs out ("on_timeout": "next_wave") the next wave spawns on top of the survivors and the timer restarts; the boss wave may also arrive on top of an unfinished wave, because that is the pressure the owner asked for ("the next wave starts on top of what is left, until Rivet dies"). Rejected: holding the boss wave until the street is clear.`
- `- [2026-11-22] DECISION gauntlet-picks (n23 street): no pick screen while waves are stacked; when the block is clear every pick owed since the last pick is given, one after another, with a "Pick n of m" counter that counts only waves whose offer pool is not empty. Rejected: dropping the picks of timed-out waves.`
- `- [2026-11-22] DECISION gauntlet-cap (n23 street): max_alive = 40 live gauntlet hostiles across all waves; extra roster members wait and spawn in roster order as slots open, counted per wave as spawn_delayed; the run tick cap is 216000 (one hour) and a run that hits it writes capped: true. Rejected: dropping the delayed members.`
- `- [2026-11-22] DECISION gauntlet-dev-timer (n23 street): the dev launch flag --wave-timeout=<s> (gauntlet entry only, result field wave_timeout_s only when given) exists to film and test stacking, because no bot run timed out on the real 90 s timer. Shipped play never sets it.`
Commit A (docs only).

## Part B (~15 min): pin the first counter value
Mutation of `project/features/gauntlet/gauntlet_waves.gd` left one survivor: `owed_index = 0` in `_clear_block()` changed to `1` is not caught. Add one assertion (or one small test) in `project/tests/unit/test_gauntlet_pick_view.gd` or `project/tests/unit/test_gauntlet_wave_timer.gd` that pins the first owed pick after a stacked block to index 1 of its total (for example, with 3 owed picks, the first offer reads `owed_index == 1` and `owed_total == 3`, the caption "Pick 1 of 3"). Test code only; no product change. Prove it kills that mutant: `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_waves.gd --max=20 --lines=<the line of owed_index = 0>` after committing, and quote killed/(killed+survived). Commit B.

## Part C (mutation scores for tonight's other main files)
Commit first (it mutates HEAD in its own temp worktree). Run each, from this worktree, exactly in this form, and quote killed/(killed+survived), timeouts and survivors (file:line, mutation) in your report:
1. `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_composer.gd --max=20`
2. `node tools/mutate/mutate.mjs --file=project/features/combat/shot_draw.gd --max=20`
3. `node tools/mutate/mutate.mjs --file=project/features/gauntlet/gauntlet_draw.gd --max=20 --lines=<the lines of offer_count and _eligible>`
If a survivor is a real gap and a one-assertion test kills it in under 10 minutes and before COMMITBY, add it (test files for those classes only), commit, and say so. Otherwise just report it.

## Acceptance checks (quote results in your report)
- `node tools/gate/quick.mjs` clean. Fix lint and format findings in your own edit and go on.
- `node tools/tests/run_unit.mjs --changed` green.

## Commit
Staged per path (`git add <path>`; never `-A`, `.`, `-u`, `commit -a`, stash, amend, rebase, reset --hard, push). End messages with
`Co-Authored-By: GPT-6.2 Astra <noreply@openai.com>`.

## Allowlist (edit only these)
the end of `docs/decisions.md` (append four lines), `project/tests/unit/test_gauntlet_pick_view.gd`, `project/tests/unit/test_gauntlet_wave_timer.gd`, the existing unit tests of `GauntletComposer`, `ShotDraw` and `GauntletDraw` (find them with `node tools/tests/test_map.mjs <path>`), `evidence/street/**`.
Forbidden: every product file (`project/features/**`, `project/dev/**`, `project/boot/**`, `project/data/**`), `tools/**`, tapes and goldens, JOURNAL.md, REPORT.md. Any other path: stop and report a NEED.

## Notes from the director
- Scratch (logs, mutate progress) goes under `build/street/` (git-ignored). Nothing goes to gtai-masters in this call.
- Mutate: do not pass a scratch or root directory; it makes its own temp worktree at HEAD.
