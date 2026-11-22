# b8-guard-film (lane controls, n23) - refilm the guard pose at 1080p, 15 to 40 s

Hard stop: 08:50 wall clock. Commit by 08:45. If it is not done by then, commit nothing half-done and report what is left.
Do not amend, do not rebase, no `git stash`, no `git add -A/./-u`, no `git commit -a`, no `reset --hard`. Commit with `git commit -m "..." -- <exact paths>`.
Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n23/appdata/controls` and `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a time. Windowed runs: `--position 0,1440` (secondary monitor), never the main display, `--rendering-driver d3d12`. Fix lint and format findings in your own edit and go on.

## Why
`C:\Users\kazda\kiro\gtai-masters\n23\controls\guard_pose.mp4` is 640x360 and 12 s. The night's film rule is 1920x1080 at 60 fps, 15 to 40 s, at 32 px/m tilt 70, plus a 64 px/m close-up where the change is visible. The driver `project/dev/controls/guard_pose_film.gd` hardcodes `SIZE` (640x360) and `END` (12 s). The game code is frozen and gated; this is a dev-only film change.

## Work
1. `project/dev/controls/guard_pose_film.gd` (dev only): add two optional flags to its own `KNOWN_FLAGS`, `--size=<W>x<H>` (default 640x360, unchanged) and `--seconds=<n>` (default 12, unchanged). With `--seconds` larger than 12 the take simply runs longer after the existing beats (raise, eight-facing turn, lower, re-raise, the volley that breaks the meter at about tick 646): the stagger and whatever the sim does next (recovery and re-raise if the pilot already holds guard) stay on screen. Do not change any beat tick, the stills mode, or anything outside `project/dev/controls/`. Keep the file under 200 lines and functions under 40 lines (it is 126 lines now). If the dev-line debt ratchet refuses, use `node tools/debt/debt.mjs --update --accept-regression="guard film size flags for n23 controls"` and commit `tools/debt/baseline.json` with it.
2. Film two takes with the movie mode (see how `--movie` is used now; the stills command is in `evidence/controls-flip/guard-scale.md` line 74):
   - `guard_pose.mp4`: 1920x1080, 60 fps, 32 px/m, tilt70, 20 s. Replace the old file in the masters folder after checking the new one.
   - `guard_pose_64.mp4`: 1920x1080, 60 fps, 64 px/m, tilt70, 20 s.
   Encode H.264 (yuv420p) as the earlier films were. Check each with `ffprobe` (size, fps, duration) and extract 3 frames (raise, held, stagger) to `build/dev/b8/` and look at them: Rivet visible and centred, no HUD hidden behind the dialog, guard pose readable.
3. `C:\Users\kazda\kiro\gtai-masters\n23\controls\frames.json`: keep exactly 15 entries. Update the `guard_pose.mp4` entry's note (1080p, 20 s, what happens when). Do not add the 64 take to frames.json; name it in the evidence file instead.
4. Append a short `## Guard film (1080p)` section to `evidence/controls-flip/films.md`: the two commands, ffprobe lines, frame ticks of raise / held / break.
5. Run `node tools/gate/quick.mjs` (or at least `node tools/lint/lint.mjs`) before the commit, and `node tools/godot/check.mjs res://dev/controls/guard_pose_film.gd`.

## Allowlist
`project/dev/controls/guard_pose_film.gd` (+ its `.uid` if it changes, it should not), `tools/debt/baseline.json` (through the debt tool only), `evidence/controls-flip/films.md`, files under `build/dev/b8/` (not committed), and `C:\Users\kazda\kiro\gtai-masters\n23\controls\guard_pose.mp4`, `guard_pose_64.mp4`, `frames.json`. Any other path: stop and report a NEED. Forbidden: every product file outside `project/dev/controls/`, and every file of the other lanes (prologue, street, moves, loop). No mutate run needed (dev film driver, no tests target it).

## Final message
Commit sha(s), the ffprobe line of each film, the three frame ticks, lint/check result, and anything left.
