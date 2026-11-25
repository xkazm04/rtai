# Brief b5-prologue-moves (lane foes, run n31): the two moves in the prologue yard, as a NEED ground patch

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 50 min after launch:
report and END.** Commit the patch + evidence by 30 min in.

## Why
Owner (verbatim): "Enemies need two types of movement: 1. Slower backwards movement with ability to shoot
2. Faster (as is) movement in case of urgent retreat or chasing without ability to shoot." The gauntlet has it
(`project/features/combat/squad/foe_gait.gd`, `foe_gait_drive.gd`, enemies.json `fight_speed_k` 0.45,
`danger_m` 4, `gait_min_s` 0.6, `gait_settle_s` 0.25; read them first). The prologue yard has its own squad:
`project/boot/prologue/prologue_panic.gd` `step()`: inside `retreat_gap_m` (8.8) a patrol cop `_escape`s at
`retreat_mps` 6.65 **and still fires**; outside it walks to its mark at 6.65 and fires whenever it has a token.

`project/boot/prologue/**` and `prologue_stage.json` are lane ground's files: **you do NOT commit any change
under them on this branch.** You deliver a patch file ground applies.

## Do
1. In a throwaway worktree (`git worktree add ../gtai-foes-b5 HEAD` under `C:\Users\kazda\kiro\gtai-wt\`,
   detached; remove it at the end with `git worktree remove`), change `ProloguePanic` so each officer has a
   `FoeGait` (reuse the class; do not copy it):
   - Rivet inside the patrol row's `danger_m` (read it from `enemies.json` patrol_cop through the roster/table the
     prologue already loads, or one new `arrival.danger_m` 4.0 in prologue_stage.json if that is simpler) or a
     morale break: TRAVEL, `_escape` at `retreat_mps`, **no round**.
   - Between `danger_m` and `retreat_gap_m`: FIGHT, back away from Rivet at `fight_speed_k x retreat_mps`
     (facing him), may fire.
   - Walking to a mark more than `FoeGait.ARRIVED_M` away or out of weapon range: TRAVEL, no round.
   - `FoeGait.update` with min hold `gait_min_s` and settle `gait_settle_s` (same values as the gauntlet).
   Keep files <= 300 lines, functions <= 40. Quest 1's script and the owner's lines must not change.
2. In the throwaway tree: `node tools/tests/run_unit.mjs --changed` (or `--select=` the prologue tests) and the
   prologue scenarios (`node tools/tests/run_scenarios.mjs --only=<prologue scenario names>` or the scenarios
   command in AGENTS.md); re-pin a prologue digest only inside the patch, with the numbers in the report.
   Measure in one take: shots fired by the yard patrol while Rivet is inside 4 m (bar: 0) and while he is 4-8.8 m
   (bar: > 0, i.e. they still shoot when backing off), main vs patched, same seed and ticks.
3. `git diff` of the throwaway tree -> `evidence/n31/foes/prologue_moves.patch`; check it applies to this branch
   with `git apply --check` (do not apply it). Commit only the patch + `evidence/n31/foes/prologue_moves.md` (the
   numbers, the commands, what ground must re-pin). Append one `NEED ground` line to the lane `JOURNAL.md`? NO:
   the director writes it. Just report.

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot;
lane lock `build/n31/godot.lock` content `b5 <pid>` (wait if another tag holds it, delete yours when done).
Typed GDScript, Log not print, stage per path, no amend/rebase/stash/--no-verify, fix lint and format findings in
your own edit. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, the patch path, test/scenario result lines, the shots table, what ground must re-pin.
