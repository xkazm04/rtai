# Brief 02c `dash-review`: the director's review of the dash commits (lane motion, n24)

Resume of your dash session. Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY.
Fix lint and format findings in your own edit and go on. No amend, no rebase, no `git add -A/./-u`, no stash.
Environment for every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run. One Godot at a time.

## 1. Commit what is still untracked (first, before anything else)
`project/dev/motion/` (dash_take), `tests/unit/test_player_motion_dash_chase.gd`, `test_player_motion_dash_dodge.gd`
(+ `.uid`), `evidence/n24-motion/dash_dodge.md`. If the dash film is not finished, commit the tests and the note now,
the film scene when it renders.

## 2. Cooldown counted twice on one tick (bug)
`PlayerMotion.drive` calls `dash.rest_tick()` in its else branch (cover owned the tick). But `PlayerCover.drive`
returns true on the tick a roll breaks cover AFTER calling `motion.step` (`player_cover.gd:96-98`), and `step` already
called `rest_tick()`. That tick decrements the dash cooldown twice (and resets `frame`). Make the rest tick happen
exactly once per sim tick on every path (e.g. a tick stamp in `PlayerMotionDash`, or `drive` only resting when `step`
did not run). Unit test: cooldown falls by exactly 1 per tick across (a) free ground, (b) sitting in cover,
(c) the roll-out-of-cover tick, (d) a vault. Check whether the fix moves any recorded digest: it must not for tapes
without a dash press (`dashes == 0` writes nothing); say so in the report.

## 3. Restore the doc comments your commit 9f4ce27a9 stripped from `player_motion.gd`
The class header (sprint above the 5.0 m/s tackle line and its slower turn; the roll as a press with i-frames, recovery
and cooldown; the vault; station cover), the `step` doc line, the `face_aim` n11 owner-call history ("direction of
player should follow cursor"), the `heading` doc. Add one line for the dash. If the file passes the size cap, move the
dash state (`dash`, `dashes`) or a helper into `player_motion_dash.gd` rather than dropping comments.

## 4. The dash film, if not done
`C:/Users/kazda/kiro/gtai-masters/n24/motion/dash_<rocket|chase>_32.mp4`: 32 px/m, tilt 70, 1080p60, 15-40 s each
(check with `ffprobe`): Rivet dashing out of a hostile rocket's path (a standing take beside it, the same spawn,
taking the hit), and Rivet closing on a fleeing cop with dashes vs a plain run. Plus one 64 px/m still of the trail
mid-dash. Add entries to `C:/Users/kazda/kiro/gtai-masters/n24/motion/frames.json` (keep existing entries; format
`[{ "file", "title", "ppm", "before", "note" }]`). Look at the trail yourself: no teal anywhere (teal is souls).

## 5. Checks before each commit
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs`. After the code commit:
`node tools/mutate/mutate.mjs --file=project/features/player/player_motion_dash.gd --max=20` and quote the score.

## Allowlist
`project/features/player/player_motion*.gd`, `top_down_mover.gd`, `live_input.gd`, `player_command.gd`,
`project/data/tables/rivet_motion.json` + its schema, `project/dev/motion/**`, tests named `test_player_motion_dash*`
/ `test_tick_input_wide*`, `evidence/n24-motion/**`, the masters folder above, one `docs/decisions.md` line if a
decision changes. `player_cover.gd`/`player_vault.gd`: one-line call site only, named in the report. Any other path:
stop and report a NEED. Forbidden: other lanes' files (melee_*, player_deflect, guard, enemies.json, weapons.json,
souls/**, ghost_*.json, gauntlet/** beyond what you already committed, characters/art except rivet_walk*/rivet_run8*).

Final report: commits (sha + one line), test counts, mutate score, film paths with ffprobe durations, anything not done.
