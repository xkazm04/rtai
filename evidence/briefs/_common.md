# Common law for every n30 cast builder (read with your brief)

- Worktree (your cwd): `C:\Users\kazda\kiro\gtai-wt\n23-prologue`, branch `n30-cast`. Read `AGENTS.md` (short) first.
- Before EVERY Godot or tool run: `export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/cast` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`.
- Never start Godot raw: only through `tools/dev/run.mjs`, `tools/godot/check.mjs`, the film tools (`tools/film/*`),
  `tools/tests/run_unit.mjs`, `tools/gate/quick.mjs`, mutate. Windowed runs: `--position 0,1440` (secondary screen).
- ONE Godot per lane (you share the lane with one other builder). Before any command that launches Godot, take the lane lock:
  `( set -o noclobber; echo "<your tag> $(date +%H:%M) $$" > C:/Users/kazda/kiro/gtai-n30/appdata/cast/godot.lock )`
  If it fails, read the file: wait (poll every 60 s) until it is gone; only if its time is older than 45 min delete it.
  Delete the lock as soon as your Godot command returns. Never delete a lock with another tag unless stale.
- `mem-budget: waiting` = the machine is full, not a hang: wait, and say how many minutes in your report.
- Repo law: typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, data JSON
  with schema. Stage per path (`git add <path>`); banned: `git add -A/./-u`, `git commit -a`, `git stash`, `reset --hard`,
  amend, rebase, push. Commit `.uid` / `.import` with new files. After new art or new scripts, run an import before committing
  (`node tools/tests/run_unit.mjs --select=<one test>` imports first through runGodot).
- Fix lint and format findings in your own edit and go on (`node tools/lint/lint.mjs`; `gdformat` on your files).
  Run `node tools/gate/quick.mjs` before each commit. The pre-commit hook can take ~12 minutes on this shared machine;
  never skip it. If it fails on `tools/film/kill_reel_*.break.test.mjs`, the class cache is stale: `--import`, commit again.
- Two builders share one index: ALWAYS commit with a pathspec, `git commit -m "..." -- <your paths>`, never a bare `git commit`.
- Commit each finished part as soon as its checks pass, by 25 minutes into the call at the latest for the first part.
  Message ends with the line `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
- Forbidden paths (other lanes): `project/features/combat/kills/**`, `project/boot/prologue/**`, `project/features/player/**`,
  `input_actions.json`, `rivet_motion.json`, `lights.json`, `combat.json`, `enemies.json`, `weapons.json`,
  `ghost_*.json`, `project/features/souls/**`, `project/dev/gauntlet/**`, `tools/film/kill_reel*`, `tools/gauntlet/**`,
  `prologue_*.json`, Rivet's art. Any path outside your brief's allowlist: STOP that part and write `NEED <lane|director>: ...` in your report.
- Do NOT write `docs/decisions.md` unless your brief says so. Do NOT write `JOURNAL.md` / `REPORT.md` (the director's).
- Evidence: measure in the delivered frames (the rendered film or still), never nominal labels or config values.
  Films/stills for the owner go to `C:\Users\kazda\kiro\gtai-masters\n30\cast\` (1920x1080, 32 px/m tilt 70, 15-40 s, check with ffprobe).
  Scratch to `build/look/n30-<tag>/`. Look at every still you make (Read the png) before you quote it.
- Mutate (only if your brief asks): `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed> --tests=<basenames>`.
- End with a report: files, commits (hash + subject), every command you ran with its result line, numbers, what you could
  not do and why. Hard stop: your brief's wall clock. Never end with uncommitted finished work.
