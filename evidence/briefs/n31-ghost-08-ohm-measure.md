# n31 ghost 08 - item 1 for Ohm (and Dent, Kerf): the measure on main, before any change

Builder tag: `g08-measure`. **First commit within 25 minutes; hard stop 50 minutes after launch: commit what passes, report, END.** Never end with a commit in the pre-commit hook (~12 min).
Worktree (cwd): `C:\Users\kazda\kiro\gtai-wt\n25-yard`, branch `n31-ghost`. Read `AGENTS.md`, `git log --oneline -15`, `tools/ghost/deploy_measure.mjs`, `project/dev/ghost_n31/*.gd`, `evidence/n31/ghost/measure-main.md` (the Tonnage tables this extends).

## Why
The lane's item 4: "the same pass over the next ghost": Ohm, then Dent, then Kerf. Each starts with item 1's measure on `main` (the before number). Owner's complaint for every ghost: the hold-to-aim placement marker is unnecessary, the effect is too weak / too instant, the deploy "needs more detailed work".
On main: Ohm (key 4) = hold to aim, release: a full circle `ghost_attacks.json` deploy.ohm `radius_m` 3.5 at the spot (range 9), `bolt_damage` 2, machines stunned. Dent (key 1) = capsule `ram_half_m` 0.9 from Rivet to the spot (range 8), `jab_damage` 1, shove. Kerf (key 3) = one target in a 35 degree cone, range 9, humans 99 / robots 4. All resolve on the release tick (`project/features/souls/ghost_deploy_strike.gd`).

## Do
1. Extend the measure (lane-owned: `tools/ghost/deploy_measure.mjs` + `project/dev/ghost_n31/**`) with `--form=tonnage|ohm|dent|kerf` (default tonnage, every existing output unchanged for tonnage; keep the node test green and add a case for the flag). For a non-Tonnage form, play mode grants and selects THAT form only (the way `ghost_n31_play.gd` `_grant` does Tonnage) so the shipped `GhostDeployBot` deploys it whenever ready; count per deploy WITHOUT replacing the strike: foes hit (connect `arena.struck` / the hit signal and keep hits whose weapon is `deploy_<form>`, one per foe per deploy), kills (`release_kills` or `kill_landed` with that weapon), zero-hit deploys, foes within 9 m of the spot at the release tick (the "group" it could have hit: share = hit / near), and key-down to damage ticks. Lab mode for ohm: the existing 4/8/12 gauntlet cluster shapes, Ohm deployed at the bot's spot: hit and kill share. Dent and Kerf: play mode only.
2. Run on **main** `ba8e470b0` in a temp worktree (`git worktree add <tmp> ba8e470b0`, copy this worktree's `project/dev/ghost_n31/` there plus `project/native/bin/*.dll` if absent, `--import` there, `--root=<tmp>`; remove the worktree after with `git worktree remove`; never delete anything in Temp you did not create). Ohm: lab (per-size 15) + play 10 seeds x 3 waves; Dent and Kerf: play 10 seeds x 3 waves. One Godot process per run, through the tool (runGodot).
3. Write `evidence/n31/ghost/measure-others-main.md`: one table per form (deploys, mean/median hits, kills, zero-hit, share of near foes, key-down to damage), the commands, the JSON paths (`build/n31/ghost/...`). Commit the tool + test + md.
4. If time remains: the same Ohm play run at what-if radii 4.5 and 5.5 (a `--radius` that the Ohm path honours, without changing product code: the dev strike/geometry may filter hits by a larger circle as the Tonnage what-if does).

## Rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/ghost` and `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every Godot-using command. **Lane Godot lock** `build/n31/godot.lock`: wait until absent, write `g08-measure <pid>`, delete yours after; never delete another's. One Godot at a time (another builder may hold it: wait).
- Allowlist: `tools/ghost/**`, `project/dev/ghost_n31/**`, `evidence/n31/ghost/**`, `build/n31/**`, `tools/debt/baseline.json` only via `node tools/debt/debt.mjs --update --accept-regression="n31 ghost measure dev tool"` if the ratchet names your dev folder. NOT `project/features/**` (another builder edits souls), not other lanes' files. Any other path: STOP and report a NEED.
- Typed GDScript, ~200 lines/file (hard 300; split the play file if it grows), <= 40 lines/function, <= 5 params, `Log` not `print`. New `.gd` -> `--import` through runGodot, commit the `.uid`.
- Fix lint and format findings in your own edit and go on. Stage per path, `git commit -m "..." -- <paths>`; no add -A/./-u, stash, amend, rebase, reset --hard; never skip the hook. Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Report
Commits, the tables (paste them), what you could not run, NEED lines.
