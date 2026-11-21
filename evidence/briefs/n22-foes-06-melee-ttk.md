# Brief n22-foes-06 (resume): the claw column of the time-to-kill table measured at reach

Follow-up to brief 05, same session (`--resume`). Cwd `C:\Users\kazda\kiro\gtai-wt\n22-foes`, branch `n22-foes`.

## Clock
START = the time you read this; write it down. **Commit by START+25 min and never after 06:00. Hard stop START+30 or 06:00, whichever is earlier.** Fix lint and format findings in your own edit and go on. Do not stop to ask; decide, list decisions in your report.

## Environment
`export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/foes` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot run. One Godot at a time in this lane; kill only your own PIDs.

## The gap
`evidence/foes/ttk.md` has a `claw` column that is `-- / --` on all ten rows, because `FoeTtkTrial.DISTANCE_M` = 8 m also applies to the claw, which reaches about 1.6 m (+ body radius). The owner's controls put hands melee in wheel slot 0, so this is the column the gauntlet needs most.

## Do
1. In `project/dev/enemy_ai/foe_ttk_trial.gd` (owned, dev only): for `MeleeTable.CLAW`, place Rivet at the claw's real strike distance (its `reach_m` from the melee table + the enemy's `radius_m`, minus a small margin so every swing is in reach; read the numbers, do not hard-code 1.6), front and rear as for guns. Guns stay at 8 m. Record the distance used per weapon in `ttk.json` (`distance_m` per column, or a `melee_distance_m` key) and fix the note line in `ttk.md` ("Both fighters stay 8 m apart, including for bare-claw swings") to say what is true.
2. Re-run `node tools/dev/run.mjs foe_ttk --out=<abs evidence/foes/ttk.json>` and regenerate `ttk.md`. Expect the claw to one-hit every human (tier 1-2) and the front/rear gap to show on the turret, shield robot and war machine. If the claw is still a timeout anywhere, say why in the report (cause read from code, not guessed).
3. Lint (`node tools/lint/lint.mjs`), `node tools/gate/quick.mjs`, commit `foes: time to kill with the claw at its reach` (stage per path: the trial file, `evidence/foes/ttk.json`, `evidence/foes/ttk.md`, and the runner if touched).

## Files
Only `project/dev/enemy_ai/foe_ttk*.gd` and `evidence/foes/ttk.*`. Any other path: stop and report `NEED <lane>: <file> <why>`. Forbidden: other lanes' files, `project/features/**`, `project/data/**`, `docs/**`, `JOURNAL.md`, `REPORT.md`.

## Law
No game number changes. Typed GDScript, `Log`, functions <= 40 lines, <= 5 params, file <= 300 lines. Stage per path; no stash / add -A / commit -a / reset --hard / amend / rebase / push. No mutation run needed (dev tool).

Report: commit sha, the new claw column (front / rear per row), lint and quick-gate lines.
