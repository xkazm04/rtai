# Brief 06 (lane loop, n22): the film of the test player and the report page image

Wall-clock: you start about 04:05. **Commit deadline 05:00, hard stop 05:08**. Small commits, one per change; never amend, never rebase. Fix lint and format findings in your own edit and go on.

## Context (read, do not re-derive)
- The test player (`project/features/gauntlet/bot/`, `GauntletTestPlayer` at `gauntlet_bot.gd`, brain `bot_brain.gd`, `BotDefence`, `BotForms`, `BotCover`) plays street's gauntlet scene `project/dev/gauntlet/gauntlet.tscn` (flags: `--seed --bot --pick --waves --result --controls --pick-view`; `--pick-view` holds the three offer cards on screen 90 ticks before the bot picks and highlights its choice; `camera_ppm` export 32, `gauntlet_closeup.tscn` is the same scene at 64 px/m; the view is tilt 70).
- Street filmed its own walker through five waves with `--write-movie` (see `evidence/street/film.json` on this branch if merged, else `git show n22-street:evidence/street/film.json`). Their masters are in `C:\Users\kazda\kiro\gtai-masters\n22\street\`. Yours go to `C:\Users\kazda\kiro\gtai-masters\n22\loop\`.
- The owner judges by this film: "the test player clearing waves while guarding, rolling, hiding and transforming, plus the report as a readable page or image".

## Goal, in order (commit each)
1. **A caption of what the bot does**, dev only: a scene `project/dev/test_player/gauntlet_bot_film.tscn` (+ script) that instances `res://dev/gauntlet/gauntlet.tscn` and adds a CanvasLayer label at the bottom-left (ink on cream, the colours street's HUD uses: `Ink.CREAM`, `HudArt.INK`; never teal, never red) reading the bot's current act each tick: `GUARD`, `ROLL`, `COVER`, `TONNAGE` (or the form name), `ATTACK <slot>`, `ADVANCE`, `REST`, `RETREAT`. Read it from a getter you add on `GauntletTestPlayer` / the brain (`act() -> StringName`), no new sim state; the caption must not change the result file (same seed with and without the caption scene: `cmp` identical result JSON; say how you checked). A 64 px/m twin `gauntlet_bot_film_closeup.tscn`.
2. **Find the seed**: run headless `average` + `--pick=greedy --controls=wheel` over seeds 1..12 and choose the seed whose first five or more waves show, in the result's per-wave counters and your act log, all of: guard deflects (or guard ticks), at least one roll, cover against a large round or blast, Tonnage time > 0. Write the table you chose from (`evidence/loop/film-seed-scan.json`).
3. **The film** at 32 px/m, tilt 70, 1920x1080, 60 fps, windowed with `--position 0,1440` (never the main display), `--rendering-driver d3d12 --fixed-fps 60 --write-movie <avi>`, through five or more waves with `--pick-view`; cut to mp4 h264 (ffmpeg, crf 18) clips of 15-40 s each (two or three clips is fine) to `C:\Users\kazda\kiro\gtai-masters\n22\loop\`. Then one 64 px/m close-up (still or 10 s clip) where a guard deflect or a Tonnage transform is visible. Extract stills (`ffmpeg -ss <t> -i <mp4> -frames:v 1`) at the moments of guard, roll, cover, Tonnage and the pick, **open each still and describe what is actually in it**; do not claim an act the frame does not show.
4. **The report page image**: render `evidence/loop/batch-street-2/report.html` (or the newest batch report under `evidence/loop/`) to PNG with Chrome headless (`"/c/Program Files/Google/Chrome/Application/chrome.exe" --headless=new --window-size=1400,2400 --screenshot=<png> file:///<abs html>`) into the masters folder; look at it.
5. `C:\Users\kazda\kiro\gtai-masters\n22\loop\frames.json`: 8 to 15 entries, best first, `[{ "file", "title", "ppm", "before", "note" }]` (`before` null when there is no before), each note says what is visible. Delete scratch renders it does not reference (avi files included). `evidence/loop/film.json` with seed, profile, flags, clips, wave start frames, the stills and what each shows.

## Files you may create or edit (allowlist; any other path: stop and report a NEED)
`project/features/gauntlet/bot/**`, `project/dev/test_player/**`, `project/tests/unit/test_bot_*.gd` (+ `.uid`), `evidence/loop/**`, `C:\Users\kazda\kiro\gtai-masters\n22\loop\**`.
Forbidden: every other path under `project/` (street owns `dev/gauntlet/**` and `features/gauntlet/` outside `bot/`; guard owns `features/player/**`; foes owns `features/combat/ai/**`, `squad/**`, `enemies.json`), `tools/**` (another call may edit it), every other worktree and masters folder.

## Machine rules
- `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/loop` and `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe` before any Godot run. One Godot at a time (the director runs none while you work).
- After new scripts: a Godot `--import` before committing (the `.uid` files). `node tools/godot/check.mjs <file>` for a parse check. `node tools/tests/run_unit.mjs --changed` green before each code commit.
- Mutate (if you change bot code): `node tools/mutate/mutate.mjs --file=<file> --max=20 --lines=<changed lines>`; quote killed/(killed+survived).
- Stage per path; no `git add -A/./-u`, no stash, no `reset --hard`, no `commit -a`, no amend, no rebase, never push, do not merge or switch branches. Before each commit `git status --short` and stage only your own files.

## Report at the end
Files, commits, the chosen seed and why, each clip with its length, each still with what it shows, the determinism check, what you could not show (say it plainly: e.g. "no roll in the first five waves of any seed").
