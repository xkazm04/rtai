# n30-16 sprint-tour (keys lane, run n30) - opus, 35 min

Launched 14:22. **Commit the recorder by 14:45, the film by 14:57. Report and END by 15:00** (hard stop, wall clock: the
session that started you dies at 15:06 and takes you with it; an uncommitted part is lost).
cwd `C:\Users\kazda\kiro\gtai-wt\n23-controls` (branch `n30-keys`). Before every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n30/appdata/keys GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
You are the lane's only Godot user (lane lock `build/n30-godot.lock`: write `n30-16 <pid>`, delete it when you end).
Windows on the secondary monitor: `--position 0,1440`. Run Godot only through `runGodot` (`tools/dev/run.mjs`, `tools/film/*`, or a
scratch node script under `build/n30-16/` that imports `tools/lib/godot.mjs`), never raw `$GODOT_BIN`.

## Goal
The p55 sprint collar rows 3, 6, 7 of `project/features/characters/art/view/p55/rivet_run8.png` were made rigid this run (rope ->
flat striped ring). The real-game 32 px/m clip (`tools/film/compare.mjs` arena bot) shows only row 7. Film Rivet sprinting once
through all 8 octants in game, before (`5114a4441`) beside after (HEAD), same ticks, at the p55 view.

## Do
1. Sprint tour in the arsenal recorder (our dev code): a flag, e.g. `--sprint-tour=on`, read where the recorder's other flags are
   parsed (`project/dev/rivet_arsenal/arsenal_turn.gd` `configure`, its KNOWN list if it has one). With it on, the recorder skips the
   firing turn and drives `TurnPad` with a move vector (`TickInput.new(bits, move_x, move_y)`, see `project/core/**/tick_input.gd` for the
   scale) plus the `sprint` action bit, about 90 ticks per octant in the order E, SE, S, SW, W, NW, N, NE (enough to reach the run8
   sheet: above 2.5 m/s), saving a frame every 2 ticks (`clip_%04d.png`, full window, not the Rivet crop) and, per octant, one still
   at its tick 60 cropped like the turn stills (`sprint_oct<i>.png`). Keep `arsenal_turn_rec.gd` under 200 lines: put the tour in a new
   `project/dev/rivet_arsenal/arsenal_sprint_rec.gd` (+ its `.uid`) if needed. Weapon: unarmed / hands if the recorder allows it (the
   bare run8 sheet is the one edited); otherwise say which weapon id shows `p55/rivet_run8.png` and use that.
2. One unit test in `project/tests/unit/test_arsenal_turn.gd`: the tour's pad presses `sprint` and the move vector of each octant
   (pure: test a static helper such as `tour_input(octant) -> Vector2i`). `node tools/tests/run_unit.mjs --select=test_arsenal_turn` green,
   `node tools/gate/quick.mjs` green (fix lint and format findings in your own edit and go on; debt: `node tools/debt/debt.mjs --update
   --accept-regression="sprint tour for n30 keys"`). Commit per path (`git add <path>`), message
   `dev(keys n30): arsenal recorder sprint tour (8 octants, p55 run8)` ending with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.
   After a new script: one Godot `--import` before the commit (the hook fails on missing .uid / stale class cache).
3. Film: after = this worktree; before = a snapshot at `5114a4441` made the way `tools/film/arsenal_turn.mjs` `sideAt()` does it
   (`resolveSide` + `ensureSnapshot` from `tools/film/side.mjs` / `tools/lib/snapshot.mjs`, then copy the current `project/dev/rivet_arsenal/*.gd`
   into `project/dev/film_turn_probe/` of the snapshot and run `res://dev/film_turn_probe/<entry>`), in a scratch node script under
   `build/n30-16/`. The snapshot carries the old sheet from git (LFS smudged): never take a sheet with `git show` (it writes the LFS pointer).
   Both runs `--resolution 1920x1080 --fixed-fps 60`, `--pitch=p55 --ppm=32`. Check the before frames show the rope band and the after the
   flat ring at 64 px/m too (one 64 px/m run per side for the stills is enough: `--ppm=64`).
4. Encode `C:/Users/kazda/kiro/gtai-masters/n30/keys/collar/collar_p55_sprint_tour_32.mp4`: before | after side by side (ffmpeg hstack,
   each half scaled to 960x1080 or crop each run to a 960-wide window centred on Rivet), labels "5114a4441 before" / "HEAD after",
   1920x1080, 60 fps (frames every 2 ticks -> `-framerate 30` then `-r 60`), 15-40 s; check with
   `ffprobe -v error -show_entries stream=width,height,r_frame_rate,nb_frames -of csv=p=0 <file>` and quote it. Still:
   `collar/collar_p55_sprint_tour_64.png` (8 octants, before row above after row, labelled). Look at both yourself; say which octants
   show the run8 rows 3, 6, 7 (the sheet row per octant comes from the code that picks the run8 row: name the file:line).
5. Add both to the front of `C:/Users/kazda/kiro/gtai-masters/n30/keys/frames.json` (keep 8-15 entries: drop the weakest old ones,
   e.g. `row3_4x.png` duplicates; fields `file`, `title`, `ppm`, `before`, `note`). Append a `## n30-16 sprint tour` section to
   `evidence/n30-keys/films.md` (commands, ffprobe line, octant -> row) and commit it per path.

## Allowlist (any other path: stop and report a NEED)
`project/dev/rivet_arsenal/**`, `project/tests/unit/test_arsenal_turn.gd`, `evidence/n30-keys/films.md`, `tools/debt/baseline.json` (debt tool
only), scratch under `build/n30-16/`, the masters dir above. Forbidden: `tools/film/**` edits, `project/boot/launch_args.gd` (if the flag
must go into KNOWN_FLAGS there, append ONE line and say so), other lanes' files, `docs/decisions.md`, the art sheets. Never amend, rebase,
stash, `add -A/./-u`, `commit -a`, `reset --hard`. Never delete in Temp what you did not create. No mutate this call.

## Report (last message)
Files, commits (sha), commands with their result lines, ffprobe line, octant -> sheet row, what you could not do.
