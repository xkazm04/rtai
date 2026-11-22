# Brief n24-melee P5: the owner's films and the live swing count

Lane `melee`, branch `n24-melee`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**Hard stop 23:35 wall clock** (check `date`). **Commit deadline 23:30** (no new product code after it; films
and frames only).

## What the owner judges by (verbatim from the run brief)
"each melee weapon's single swing and its kill on each human type, the electric finisher on a robot, and the screen
without a melee cursor". Owner's words on the feature: "Melee weapons double-attack on one click look horrible, we
need on unique swing per weapon, with unique brutal animation per human enemies as it should one-shot them. For
robot enemies we will need electric weapons to have similar effect" and "Remove cursors for melee weapons, as they
shapes are confusing".

## 1. Swings per click in a LIVE fight (telemetry, the judged number is 1.0)
P1 measured 1.0 on the six-tick film shot only (`n24/melee/compare/starts.json`). Measure it in a live arena fight
with the shipped input path: for each of hands, chainsaw, electro_baton, katana, plasma_sword, a scripted player
(dev-only, `project/dev/melee/`) that clicks at three cadences (single clicks 40 ticks apart, a fast mash every 6
ticks, fire held for 3 s) against a wave of humans. Count click edges and swing starts from the real swing state
(not from the input), and report swings/click per cadence and, for held fire, swings per second vs the
1 / (windup+active+recovery) the row promises. Write `C:/Users/kazda/kiro/gtai-masters/n24/melee/telemetry/swings.json`
and a 6-line `swings.md` table. Old behaviour for comparison: the same run with `single_swing: false` (one table
value), so the table shows before and after.

## 2. The films (32 px/m, tilt 70, 1920x1080 at 60 fps, 15 to 40 s each, check every one with ffprobe)
Use `tools/film/` (your P1/P2 tools: `melee_click.gd` shot, `kill_reel.mjs`, the live clips) where it fits. Godot's
movie writer has encoded 1280x800 before: build the mp4 from native 1080p frames if so. To
`C:/Users/kazda/kiro/gtai-masters/n24/melee/films/`:
- `<weapon>_kills.mp4`, one per weapon (hands, chainsaw, electro_baton, katana, plasma_sword): Rivet walks up to
  and kills, one swing each, a patrol cop, a riot cop (shield raised: shows what that weapon does to it), a SWAT, a
  contractor and a rocket trooper, in one live arena take (lay them out in a row, slow enough to read: about 3 s per
  kill). Hands: the claw's normal damage on the same row (it is not a one-shot: decision line).
- `electric_robots.mp4`: the baton shutting down a robot_thug and a robot_gunner in one swing, overloading a
  shield_robot and executing it with the second swing, a katana bouncing off a robot thug for comparison, and a
  war_machine only short-stunned.
- `cursor_before_after.mp4`: side by side (main `b3f4727c0` left, this branch right; build main in a temp worktree
  under `%TEMP%` and remove it afterwards), the same input: cycle the wheel pistol -> katana -> chainsaw -> hands ->
  pistol, showing the cursor shape at each. Use the method you used in P1 for `cursor/before.png`. A temp worktree
  has no native DLLs: copy `project/native/bin/*.dll` from this worktree (native is unchanged between the two revisions; nobody
  rebuilds native), run one `--import` there, and remove the worktree with `git worktree remove` afterwards.
  If the before side costs more than 15 minutes, film this branch only and put P1's `cursor/before.png` beside it.
- Priority if time runs short: the five `<weapon>_kills.mp4` and the telemetry first, then `electric_robots.mp4`,
  then the cursor film, then the close-ups.
- One 64 px/m close-up still per weapon of its kill tick and +20 (`closeups/<weapon>_64.png`).
- `frames.json` in `C:/Users/kazda/kiro/gtai-masters/n24/melee/` with 8 to 15 entries, best first:
  `[{ "file", "title", "ppm", "before", "note" }]` (paths relative to that folder; `before` = the before file or
  null). Delete scratch renders under `n24/melee/` that neither frames.json nor a REPORT will cite: list what you
  deleted.

Look at every film yourself (pull 6 stills per film with ffmpeg) and say in one line per film what reads and what
does not. Never fake a frame.

## Setup
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/melee` before EVERY Godot or gate run;
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- One Godot process at a time in this lane. Windowed: `--position 0,1440`, never on the main display. Rendering
  `--rendering-driver d3d12`. Free your own processes by PID, never by name.

## Files you may edit (allowlist; any other path: stop and report a NEED)
New files under `project/dev/melee/` and `tools/film/` (or your own P1/P2 film tools), tests for them, and a
`KNOWN_FLAGS` line in `project/boot/launch_args.gd` only if a new dev flag is unavoidable (then
`node tools/debt/debt.mjs --update --accept-regression="<flag> for n24 melee"`). Product code is closed: if a film
shows a bug, stop, film the bug and report it.
**Forbidden**: everything else, in particular `combat_arena.gd`, `enemies.json`, `weapons.json`, `combat.json`,
`input_actions.json`, `features/gauntlet/**`, `features/souls/**`, `features/characters/art/**`, `features/bosses/**`.

## Repo law
Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions 40 lines or fewer, 5 params max;
`Log` not `print`. Stage per path, one commit per change; no `git add -A/./-u`, no `commit -a`, no stash, no amend,
no rebase, no reset --hard, never push. Fix lint and format findings in your own edit and go on. Run
`node tools/gate/quick.mjs` before each commit.

## Report (final message)
The swings table; per film: path, duration, resolution (ffprobe), what reads / does not; frames.json path; commits.

## 3. Lowest priority, only after 1 and 2: the plasma kill's tests (tests only, no product change)
Your P4 mutate on `kill_plasma_art.gd` scored 1/19 (5.3%). Add unit tests (new file
`project/tests/unit/test_kill_plasma_art.gd`) that pin its rule-bearing parts: `drop(i, line, seed)` (deterministic,
within the fan's angle and length, radius range), `ground_print` (DROPS drops, blot, clipped by push_out),
`heat(age)` endpoints, and that `attach` collects only the two halves' `KillCutEdge` children. Then
`node tools/mutate/mutate.mjs --file=project/features/combat/kills/kill_plasma_art.gd --max=20` and quote the score.
Commit by 23:30.

## Note from P4 review
The final gate on `f6978fc2f` was green: keep it green (run `node tools/gate/quick.mjs` before each commit).
