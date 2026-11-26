# Brief b4q-hot-flag (lane foes, run n31): call B playable behind `--foe-fire=hot`

Worktree (cwd) `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n31-foes`. **Hard stop 45 min after launch:
report and END. Commit part 1 by 25 min in.** Never end with a commit sitting in the pre-commit hook (it can take
10-12 min on this machine: start the last commit no later than 30 min in).

## Why
The owner's complaint: "cops are just waiting until I come closer to start shooting". The lane's final setting
(HEAD, enemies.json squad: `max_shooters_share` 0.5, `own_weapon_damage` pistol 3 / rifle 2 / cannon 8) holds the
damage rail; setting B (measured at `c825715e8`: share 0.75, pistol 1.5, rifle 1.5, cannon 8) answers the complaint
better (idle 53 -> 43 %, never-fired 308 -> 255 of ~1050) but misses the +-15 % damage rail by 0.6 point on 20
seeds. B goes to the owner as a call; he must be able to PLAY it: `gauntlet.tscn -- --pick-view --foe-fire=hot`.
Default (no flag) stays bit-for-bit HEAD.

## Do
1. Data + code (commit as one):
   - `project/data/tables/enemies.json` squad gets `"fire_presets": {"hot": {"max_shooters_share": 0.75,
     "own_weapon_damage": {"cannon": 8, "pistol": 1.5, "rifle": 1.5}}}` (sorted keys) and a one-sentence mention in
     the table's `doc`; `project/data/schemas/enemies.schema.json` describes `fire_presets` (object of objects with
     those two optional keys, same bounds as the squad keys).
   - `project/features/combat/ai/enemy_roster.gd`: read the presets in `_squad`; a public
     `apply_fire_preset(name: String) -> bool` that overrides `max_shooters_share` and the listed `own_damage`
     entries (unknown name: `Log.warn`, returns false, changes nothing). `shipped(path, production)` applies
     `LaunchArgs.value("--foe-fire")` only when `production` is true and the value is non-empty (the dev pit and
     the prologue are untouched; note the `max_shooters` setter resets the share: apply AFTER `_squad`). Keep the
     file under 230 lines; functions <= 40 lines.
   - `project/boot/launch_args.gd` `KNOWN_FLAGS`: append ONE line `"--foe-fire",  # n31 foes: =hot, call B (share
     0.75, pistol/rifle 1.5 Rivet hp); default off` after the `--foe-moves` line. Then
     `node tools/debt/debt.mjs --update --accept-regression="--foe-fire for n31 foes"` and stage
     `tools/debt/baseline.json` with it.
   - `project/dev/foes_n31/play_take.gd` KNOWN_FLAGS + `take_args.gd` (`"--foe-fire": ok = s in ["hot"]`) so the
     take tool can pass it; `tools/gauntlet/play_takes.mjs` passes it through if it has a generic pass-through,
     otherwise add `--foe-fire=hot` as a per-side option only if it is <= 15 lines with its node test.
   - GUT test `project/tests/unit/test_enemy_roster_fire_preset.gd` (with its `.uid` from a Godot `--import`):
     shipped production roster has share 0.5 / pistol 3; after `apply_fire_preset("hot")` share 0.75, pistol 1.5,
     rifle 1.5, cannon 8; unknown name returns false and changes nothing.
   - Checks before the commit: `node tools/godot/check.mjs` on the changed .gd files; `node tools/lint/lint.mjs`;
     `node tools/tests/run_unit.mjs --changed` (quote the result line). Fix lint and format findings in your own
     edit and go on.
2. Proof the flag IS setting B (commit the result file): one waiting-probe run, seed 3, average profile, on HEAD
   with `--foe-fire=hot`, compared with the same run of `rev:c825715e8` without the flag. Read
   `tools/gauntlet/waiting.mjs` arg parser first; if it has no way to pass a game flag, add a `--game-flag=<f>`
   pass-through (<= 15 lines + node test). Bar: the per-seed numbers (damage w1-4, shots, never-fired) are
   identical; if not, find why (a read order, the setter) before anything else. Result into
   `evidence/n31/foes/hot-flag-proof.md` (both result lines, the command). If the probe cannot take one seed
   quickly (> 12 min), use one `play_takes.mjs` headless-free run instead and compare its take JSON means, and
   say so.
3. Mutate only if time remains: `node tools/mutate/mutate.mjs --file=project/features/combat/ai/enemy_roster.gd
   --lines=<your changed lines> --tests=test_enemy_roster_fire_preset --max=10`; quote killed/(killed+survived).

## Binding
`export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/foes` and
`export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'` before every
run; Godot only through the repo tools (runGodot). One Godot per lane: the lane lock `build/n31/godot.lock`
(content `<tag> <pid>`); builder b4p (a play take) may hold it: wait for it, write `b4q <pid>` while you run Godot
yourself, delete only your own. `mem-budget: waiting` = machine full, not a hang.
Owned (allowlist): `project/features/combat/ai/enemy_roster.gd`, `project/data/tables/enemies.json`,
`project/data/schemas/enemies.schema.json`, the new test file + `.uid`, `project/dev/foes_n31/**`,
`tools/gauntlet/**`, the one `KNOWN_FLAGS` line in `project/boot/launch_args.gd`, `tools/debt/baseline.json`
(through the debt tool only), `evidence/n31/foes/hot-flag-proof.md`. Any other path: stop and report a NEED.
Forbidden: `project/boot/prologue/**`, `project/features/souls/**`, kills/melee/weapon files, `combat.json`,
`weapons.json`, other worktrees, JOURNAL.md, REPORT.md, `docs/decisions.md`. Stage per path, no
amend/rebase/stash/--no-verify, no `git add -A/./-u`. If the pre-commit hook fails on
`tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit again. Commit messages end with
`Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
Report: commits, files, the command result lines (check, lint, unit, proof), what you could not do.
