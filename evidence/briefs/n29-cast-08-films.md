# Brief n29-cast-08: owed films for items 1 and 2 (size beside the cop at 32 px/m, the flash in a street fight) + mutate

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 04:58 local** (check `date +%H:%M` often). **Start your first commit by 04:35, your last by 04:44**
(hook ~12 min). Never end with finished work uncommitted. Then report and END.

## Goal
The owner judges by films (1920x1080, 60 fps, 32 px/m, tilt 70, 15-40 s each, `ffprobe` every clip). Two are owed:
1. `C:\Users\kazda\kiro\gtai-masters\n29\cast\size_beside_32.mp4`: every enabled card foe beside the spawned rig patrol cop and
   Rivet, walking (not standing), 32 px/m tilt 70, 20-40 s. Use the existing scene `project/dev/cast/cast_size_beside.gd`
   (commits `f4bf378ea`, `51de13fb6`). **Show three patrol cops, not one** (the crowd keeps a +-16 % build jitter: the stills
   showed one cop at 0.86, 43 px at 32, which made the contractor look 1.14x a cop); label each cop's px height, and say in the
   note that card foes are matched to the unjittered cop (100.6 px at 64 = 50 at 32). If the scene needs a flag for walking or
   for three cops, add it there (a dev scene), not in product code.
2. `C:\Users\kazda\kiro\gtai-masters\n29\cast\flash_street_32.mp4`: Rivet fights a door carrier and a robot gunner in the street
   (or the arena), 32 px/m tilt 70, 15-40 s, the hit flash visible on at least three hits on each; extract the frames of three
   flashes per foe, look at them (Read tool), say what you see. A dev scene under `project/dev/cast/cast_flash_fight*` if
   nothing fits; model the take on `tools/film/cast_gunner_films.mjs` (the scratch-project path: Movie Maker ignores
   `--resolution`, so the tool copies the project with the viewport overridden; never edit `project/project.godot`).
3. Mutate: `node tools/mutate/mutate.mjs --file=project/features/characters/cast_far_card.gd --lines=<the sync_tint lines of
   commit 7ca036a93> --max=20 --tests=test_cast_far_card,test_cast_door,test_cast_gunner` (check the test basenames exist;
   at most 20 min, holding the lane lock); quote killed/(killed+survived). If the temp worktree import times out again, say
   so with the log line and the minutes.
Append both clips to `C:\Users\kazda\kiro\gtai-masters\n29\cast\frames.json` (valid JSON array of `{file,title,ppm,before,note}`;
keep the existing entries, size clip after the size stills, flash clip after the flash stills).

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, the film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock**: `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before any Godot launch, `rmdir
  build/lane-godot.lock` right after (also on failure); older than 25 min = stale, remove it.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`. New flags of a dev scene go in
  that scene's own `const KNOWN_FLAGS`, not `launch_args.gd`.
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). Debt ratchet red: `node tools/debt/debt.mjs
  --update` (with `--accept-regression="films for n29 cast"` if it rises), include `tools/debt/baseline.json`.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a frame or a number.
- `node tools/tests/run_unit.mjs --changed` before each commit: quote the summary line.
- Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/dev/cast/cast_size_beside*`, new `project/dev/cast/cast_flash_fight*`, `project/dev/cast/cast_impact_edge*`, new
`tools/film/cast_n29_*.mjs`, `tools/debt/baseline.json` (debt tool only), `evidence/n29-cast/**`, outputs in
`C:\Users\kazda\kiro\gtai-masters\n29\cast\`, scratch `build/look/n29-films/`.
Forbidden: every shipped PNG, `cast_cards.json`, `project/features/**`, `project/boot/**`, `docs/**`, root `JOURNAL.md`,
`REPORT.md`, `evidence/briefs/**`, other lanes' files.

## Report (then END)
Commits, clip paths + ffprobe (size, fps, duration), each cop's and foe's px height in the size clip, what you saw in the
flash frames, the mutate score, the `run_unit --changed` line, what you could not do.

## Added 04:05 (director)
- The door builder runs beside you until 04:50 in this worktree (it owns `foe_shield_card_view.gd`, `cast_door_*`,
  `tools/film/cast_door_films.mjs`, `test_cast_door.gd`, `docs/art/cast-audit.md`): never stage or revert them. The lane Godot
  lock is shared: one run at a time, release right after. The door card may switch to an eight-drawing walk while you film;
  that is fine, say which walk your flash clip shows (`CastDoorAnchors.WALK` at your take's commit).
- Order: the size clip first (commit its scene change by 04:35), then the flash clip, then mutate only if time is left.
