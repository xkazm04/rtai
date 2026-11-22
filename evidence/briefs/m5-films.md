# Brief m5 (lane moves, n23): one film clip per move, close-ups and before/after stills

Wall clock: start 06:00. **Commit deadline 07:25. Hard stop 07:40** (report and exit even if unfinished).

## Setup for every shell and every Godot run
- `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/moves`
- `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`
- Rendering runs need `--rendering-driver d3d12` and, windowed, `--position 0,1440` (the secondary monitor, never the main display). One Godot process at a time. Kill only your own PIDs.

## Goal
The owner judges the four moves by films. For each move, one clip **at 32 px/m, tilt 70, 1080p60, 15 to 40 s** showing the move doing its job on its enemy, plus a **64 px/m close-up still** of the cue and a **before/after pair at the same tick and zoom** (move `enabled: false` vs `true`, everything else identical). Output to `C:\Users\kazda\kiro\gtai-masters\n23\moves\` (create it). Never fake a frame: every image comes from the real game.

1. `ohm_short_circuit`: Ohm's bolt hits a sentry turret (sweep stops, arcs over the body, head drops) and a shield robot (shield lowered, arcs) while SWAT stand behind it; Rivet uses the 2 s.
2. `tonnage_armour_crack`: the war machine stomps, sags with plates lifted (the window), Tonnage hits, the glowing split opens, a pistol from the front lands at full damage, the split closes after 4 s.
3. `kerf_blink_behind`: Kerf blinks onto a shield robot facing him, lands behind it facing its back, the slice lands on the rear. Pair: the same tick with the move off (slice into the shield).
4. `overkill_carry`: a hand-cannon kill on a cop in a cluster, the arc jumps to the next one; rank 2 chains twice.

## What m4/m4b measured (use it when staging)
- The probe pilots and fixtures are in `project/dev/moves/move_ttk*.gd` (commits b3d996956, a8a060feb): reuse them for staging, do not rebuild them.
- Ohm: the ordinary bolt already stuns every body 1.2 s; the short circuit now adds the 2 s machine stun (arcs, head drop, shield lowered) on top. Film the shield robot first (that is where it pays: 13.2 s -> 1.9 s), the turret second.
- Kerf: one slice kills each target at shipped HP either way (99-damage row), so the clip must show the LANDING: Rivet ends behind the shield robot, facing its back. For the before/after pair, take the frame just before the slice resolves (Rivet's position off = in front, on = behind).
- Order of work: the four 32 px/m clips first (one per move), then the 64 px/m stills, then the before/after pairs, then frames.json. If time runs short, a finished clip beats a half-made pair.

## How
- Read `tools/README.md` (the film section) and `tools/film/film.mjs`. If a `film.mjs` shot fits, use it (`--rev=HEAD` so edits cannot break a queued film). Otherwise make a dev scene `project/dev/moves/move_film.gd` (+ `.tscn` if needed) that stages each encounter with the scripted pilots of `project/dev/moves/move_ttk*.gd` (from m4) and records with Godot's `--write-movie` at 1920x1080, `--fixed-fps 60`, camera 32 px/m, tilt 70; flags in its own `KNOWN_FLAGS` (`--move=<id>`, `--off`, `--ppm=<32|64>`, `--stills=<ticks>`), run through `node tools/dev/run.mjs`. Encode to mp4 with ffmpeg if it is on PATH (`-c:v libx264 -crf 18 -pix_fmt yuv420p`); else keep the avi and say so.
- Look at your own stills before you keep them: the move must be readable at 32 px/m. If a cue is invisible, report it (do not change view code tonight: name the file and what is wrong).
- Write `C:\Users\kazda\kiro\gtai-masters\n23\moves\frames.json`: 8 to 15 entries, best first, `[{ "file", "title", "ppm", "before", "note" }]` (`before` = the file of the matching off frame, or null). Delete scratch renders it does not reference.

## Files you may edit (allowlist; any other path: stop and report a NEED)
- new or existing `project/dev/moves/**` (+ `.uid`, `.tscn`), `evidence/moves/**`, the masters folder above
- **Forbidden:** every product file (moves code, combat, squad, souls, gauntlet, player, tables, schemas, views), `tools/film/**` (report a NEED if the film tool needs a shot), `project/dev/enemy_ai/**`, tapes, goldens, other worktrees.

## Checks
1. `node tools/lint/lint.mjs` green (fix lint and format findings in your own edit and go on); `node tools/godot/check.mjs` on new scripts; `node tools/gate/quick.mjs` before each commit.
2. Commit the dev scene (staged per path, with `.uid`); films are not committed (they live in gtai-masters). No `add -A/./-u`, `commit -a`, stash, amend, rebase, reset --hard, push.

## Report at the end
Each clip: path, length, ppm, what happens at which second; each still and its pair; anything unreadable and which view file it is in.
