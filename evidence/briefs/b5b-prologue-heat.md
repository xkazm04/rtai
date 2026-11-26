# Brief b5b-prologue-heat (lane foes, run n31): the yard patch keeps the patrol firing

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 35 min after launch:
report and END.** Commit the measuring script by 15 min in, the new patch + numbers by 30.

## Why
`evidence/n31/foes/prologue_moves.patch` (b5, read `evidence/n31/foes/prologue_moves.md` first) gives the yard
patrol the two moves, but the patrol now fires 14-26 rounds instead of 40-64: `step()`'s
`moving = dist >= _gap and h.pos.distance_to(mark) > FoeGait.ARRIVED_M` makes every officer whose drifting mark
is 0.6 m away TRAVEL (no fire). The owner's complaint is "cops wait to shoot": the yard must not get quieter.
The owner's rule: TRAVEL (no fire) is for chasing, relocating, and urgent retreat; FIGHT (slow, may fire) is
for an enemy fighting. An officer adjusting to its mark while Rivet is in pistol range with a clear line is
fighting, not relocating.

## Do
1. Throwaway worktree `git worktree add --detach ../gtai-foes-b5b HEAD` under `C:\Users\kazda\kiro\gtai-wt\`;
   copy the native DLLs from this worktree's `project/bin/` if the fresh tree lacks them, one `--import`; apply
   the patch (`git apply evidence/n31/foes/prologue_moves.patch`).
2. Commit a measuring script on THIS branch first, `project/dev/foes_n31/yard_rounds.gd` (b5 left its script
   uncommitted: rebuild it from the .md's "Shots" method: the prologue bot, same loop as
   `scenario_prologue_pilot`, count rounds per band by `EnemyAgent.shot_tick` changes, stop when wave one is
   cleared; one Godot process runs all 5 seeds; writes JSON to `--out=`). Lint-clean, <= 200 lines.
3. In the throwaway tree change `step()`: TRAVEL only when Rivet is beyond pistol range, out of sight (if the
   code has a line check), or urgent (danger_m / morale); walking to a mark inside range = FIGHT at
   `fight_speed_k x retreat_mps`, may fire. Keep `--foe-moves=legacy` = main. Keep the new unit test green and
   add one case: an officer walking to a mark 3 m away with Rivet 10 m away in range fires.
4. Bars, same 5 seeds (7, 3, 11, 21, 42), main vs new patch: rounds inside 4 m = 0 on every seed; total yard
   rounds >= 80 % of main's per seed. Then `node tools/tests/run_scenarios.mjs --only=prologue_pilot,prologue_checkpoint,prologue_handover`
   and the prologue unit tests (as in the .md); report whether seed 11 torn_line/plain finishes now.
5. `git diff` (throwaway, against its HEAD) -> overwrite `evidence/n31/foes/prologue_moves.patch`; `git apply --check`
   on this branch; update `prologue_moves.md` (new table, the step() rule, the scenario lines, the re-pin values
   ground needs if the pilot finishes). Commit both. `git worktree remove --force ../gtai-foes-b5b`.

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` before every Godot run; Godot only through runGodot
(`tools/dev/run.mjs`, `run_unit.mjs`, `run_scenarios.mjs`, `tools/godot/check.mjs`). One Godot in the lane:
honour `C:\Users\kazda\kiro\gtai-wt\n23-prologue\build\n31\godot.lock` (yours: content `b5b <pid>`; wait while
another tag holds it, re-check every 30 s; another builder shoots takes in parallel; also take it for check.mjs).
On this branch commit only `project/dev/foes_n31/yard_rounds.gd` (+ its `.uid`) and
`evidence/n31/foes/prologue_moves.{patch,md}`; never `project/boot/prologue/**`, `docs/decisions.md`,
JOURNAL.md, REPORT.md. Do not touch `project/dev/foes_n31/play_take*`, `stalk_*` or `tools/gauntlet/**` (another
builder's). Typed GDScript, Log not print, functions <= 40 lines, stage per path, no amend/rebase/stash/
--no-verify, no `git add -A/./-u`, fix lint and format findings in your own edit and go on. Commit messages end
with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Delete only Temp folders you created.
Report: commits, the rule you chose, the rounds table main | b5 | b5b per seed and band, unit and scenario
lines, whether the pilot finishes, what ground must re-pin, what you could not do.
