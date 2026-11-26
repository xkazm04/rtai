# n31 melee lane - common law for every builder (read fully before working)

Repo: worktree `C:\Users\kazda\kiro\gtai-wt\n23-street`, branch `n31-melee` (never switch branch, never push,
never touch `main` or another worktree). Read `AGENTS.md` (commands) and skim `STANDARDS.md`.

Environment for EVERY Godot / gate / test run (Git Bash):
```
export APPDATA=C:/Users/kazda/kiro/gtai-n31/appdata/melee
export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe
```
- ONE Godot at a time for the whole lane (you and the other builder share it). Lane lock:
  `build/n31/godot.lock`. Before any Godot launch (tests, dev/run, film, check, mutate):
  `(set -o noclobber; echo "<your tag> $$ $(date +%H:%M:%S)" > build/n31/godot.lock)` - if it fails,
  the other builder holds it: wait (poll every 30 s, do Godot-free work meanwhile). Remove the lock
  right after your Godot run ends. A lock older than 30 min is stale: delete it. Never delete a lock
  younger than that which is not yours.
- Launch Godot only through repo tools (`tools/dev/run.mjs`, `tools/tests/run_unit.mjs`, `tools/film/*`,
  `tools/godot/check.mjs`, mutate) - they go through runGodot and the memory budget. A line
  `mem-budget: waiting` means the machine is full: wait, it is not a hang. Windowed runs: `--position 0,1440`
  (secondary monitor), never the main display. Renders: `--rendering-driver d3d12`.
- Kill only processes you started, by PID. Never by name.
- Scratch output under `build/n31/<your tag>/`. Evidence (json, png, md) under `evidence/n31-melee/<item>/`.
  Films for the owner: `C:\Users\kazda\kiro\gtai-masters\n31\melee\` (films and stills only, no scripts there).

Repo law: typed GDScript (warnings are errors), files ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
`Log` not `print`, no global randf/randi, sim steps on `SimClock.TICK_DT`, data JSON with schema.
New `.gd` -> commit its `.uid` (run a Godot `--import` via `"$GODOT_BIN" --headless --path project --import`
under the lock after adding scripts/art). New dev launch flags: declare in the scene's own `const KNOWN_FLAGS`.
Commits: stage per path (`git add <path>`), NEVER `git add -A/./-u`, `git commit -a`, `git stash`,
`reset --hard`, amend or rebase. One commit per finished part. Before each commit run
`node tools/gate/quick.mjs` (if it exists for your change) and the tests that name your classes
(`node tools/tests/run_unit.mjs --changed`). Fix lint and format findings in your own edit and go on
(`node tools/lint/lint.mjs`; gdformat). The pre-commit hook can take ~12 min on this shared machine: never skip it
(no `--no-verify`); if it fails on `tools/film/kill_reel_*.break.test.mjs` the class cache is stale - run the
Godot `--import` and commit again.
Commit end message with: `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`

Lane-owned paths (melee): melee and finisher code (`project/features/player/player_melee*.gd`, `melee_*.gd`,
`rivet_swipe_view.gd`, `melee_weapon_view.gd`, `melee_contact.gd`, `melee_lethal.gd`), hit and hurt volumes,
`project/features/combat/kills/**`, kill style tables, weapon and impact effect files and atlas cells,
`project/data/tables/combat.json`, existing rows of `weapons.json`, `melee_weapons.json`, `rivet_melee.json`,
`hit_feel.json`, `melee_marks.json`, `signature_kills.json`, `project/dev/kill_lab/**`, `project/dev/melee_n31/**`,
`tools/film/kill_reel*.mjs`, new tools under `tools/melee/`, tests for these under `project/tests/**` and `tools/**`.
FORBIDDEN (other lanes): `project/features/combat/ai/**`, `project/features/combat/squad/**` (READ only - enemy
brains, `foe_attacks.gd` is foes' file: changes there are a NEED, report it), `enemies.json`, `cast_cards.json`,
Rivet motion/draw/shadows, prologue, `project/features/souls/**`, `ghost_*.json`, `tools/gauntlet/**`,
`project/features/gauntlet/bot/**` (read only), `project/dev/gauntlet/**` (read only). Any other path: stop and
report a NEED line in your final report. Never change gauntlet wave composition.
Shared append-only: `docs/decisions.md` (one line, `- [2026-11-25] DECISION melee n31 ...`), `KNOWN_FLAGS` in
`project/boot/launch_args.gd`.

Determinism: replay/scenario digests may move only in the items that change hit rules (item 2+), each with a dated
decisions line. Quest 1 script and the native city parity must never move.

End: a final report (files, commits with sha, commands run with their result lines, numbers, what you could not do,
NEED lines). Never end with uncommitted finished work.
