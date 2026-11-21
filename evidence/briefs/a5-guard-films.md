# Brief a5-films: the guard lane's films for the owner (lane `guard`, run n22)

Wall-clock HARD STOP: 04:10 local. Commit the film scene by 03:55. If short of time, commit what is green and report what is left.

Before every Godot or gate run: `export APPDATA=C:/Users/kazda/kiro/gtai-n22/appdata/guard` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`. One Godot process at a
time. Every rendered run is windowed on the SECONDARY screen: `--rendering-driver d3d12 --position 0,1440` (never the main
display). Never kill by name, only your own PIDs. ffmpeg is at `C:/ffmpeg/bin/ffmpeg`.

## Part 0 (15 minutes max, tests only, its own commit `guard: wheel mutation survivors`)
Your a4 mutate run on `features/player/rivet_wheel.gd` left 6 survivors (14/20). Read them (the mutate log/json in build/), add
tests in `project/tests/unit/test_rivet_wheel*.gd` for each one that shows a real missing check (say which are equivalent and
why), re-run only those mutants if the tool allows (`--lines=`), quote the new score. Product code stays frozen.

## What the owner wants to SEE (the owner's words, the lane's film list)
"the guard deflecting pistol fire, a rocket passing it, a blast stopped by a wall, the wheel with hands first". The owner judges by
films at 32 px/m, the p70 (tilt 70) rig art, 1920x1080, 60 fps, 15 to 40 s each. Never fake a frame: every frame is the real
game drawing the real sim; scripted inputs and placed foes are fine (say so), drawn-on overlays are not (captions excepted).

## Build: one committed dev film scene, `project/dev/guard/guard_film.gd` (+ `.tscn` if needed, + `.uid`)
A standalone dev entry (not the arena's bot list, not `dev/showcase`: those files are shared) that builds the arena stage the way
your a2 scratch tableau did (`ArenaStage` + `CollectCallView` + `ArenaRigs`, Rivet's p70 rig, cops from the existing rigs), under
`--controls=wheel`, fixed 60 Hz (`--fixed-fps 60`), drives Rivet with scripted `TickInput`s (actions, never raw keys), and saves
every frame (or every 2nd tick for a 30 fps proxy, then the mp4 at 60 via ffmpeg `-r 60` from every tick) to `--out=<abs dir>`.
Declare `const KNOWN_FLAGS` (`--out`, `--beat`, `--ppm`) so `node tools/dev/run.mjs guard_film --windowed ...` launches it, and a
`--beat=<id>` to film one beat alone. Camera: 32 px/m (64 for `--ppm=64`), the tilt/art the arena uses for p70; find how
`tools/film/film.mjs --ppm` / `--view=combo` set it and use the same path. Keep every file under 200 lines (split by beat).
Hostile rockets for beats 2 and 3 use the `EnemyRounds` test seam from your a3 call (a placed hostile firing a `large` round with a
splash row), since tonight's enemy rocket rows are on the foes lane's branch. Say so in the report.

Beats (one continuous film is best; separate films per beat are acceptable, each >= 10 s):
1. **guard** (about 10 s): three cops in a 60 deg arc in front of Rivet fire pistols on their own AI (or scripted fire if the AI
   is too slow to start); Rivet holds the guard (RMB action), rounds spark and fly back at their shooters, the meter bar drains
   visibly, it breaks (amber flash), Rivet staggers, takes the next hits, then the meter refills after he lowers it.
2. **rocket** (about 6 s): Rivet guarding faces a hostile rocket: it passes the guard, bursts on him (blast ring, hp drops).
3. **wall** (about 8 s): Rivet behind a `wall_high`; a rocket bursts on the wall face: hp unchanged. Then the same rocket with
   Rivet in the open beside the wall: hp drops. (Show both in one beat if the geometry allows: two rockets, one each side.)
4. **wheel** (about 8 s): fresh wheel `hands`; scroll next -> the blade (katana or the first melee weapon the carry takes),
   LMB swings it at a dummy or cop; scroll next -> pistol, LMB fires; the readout list visible after each scroll.
Also: **before/after** stills at the same tick of beat 1: `--controls=legacy` (no guard: the cops' rounds hit) and wheel
(guarded); and a **64 px/m close-up** still of the guard pose with a deflect spark.

Outputs to `C:/Users/kazda/kiro/gtai-masters/n22/guard/`: `guard-film-32ppm.mp4` (all beats, or `guard-<beat>-32ppm.mp4`
each), the before/after pair `before-legacy-t<N>.png` / `after-wheel-t<N>.png`, `guard-closeup-64ppm.png`, 6 to 10 stills
from the film at telling ticks, and `frames.json`: 8 to 15 entries, best first,
`[{ "file", "title", "ppm", "before", "note" }]` (`before`: the matching before file or null; `note`: what the frame proves,
with the tick and the hp / meter numbers read from the sim). Delete scratch frames the json does not reference (keep the mp4s).
LOOK at every still you list (open it), and say in the note what is visible. If a beat does not read (the spark too small, the
meter hidden behind a rig, the rocket too fast to see at 60 fps), fix the staging, not the game.

Then `node tools/gate/quick.mjs`; commit `guard: dev film scene for the guard, blasts and the wheel` (only the new dev files).
`tools/dev/run.mjs` verdict line in the report.

## Allowlist (any other path: stop, report a NEED)
`project/dev/guard/**` (new), new tests `project/tests/unit/test_guard_film*.gd` if any, `C:/Users/kazda/kiro/gtai-masters/n22/guard/**`,
`build/**` (git-ignored scratch), `project/tests/unit/test_rivet_wheel*.gd` (Part 0). Read anything. Forbidden to edit: everything else (product code is frozen for this call: if a
beat shows a product bug, report it precisely with the tick, do not fix it), `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Law
A debt-ratchet rise (e.g. `dev_loc`) goes through `node tools/debt/debt.mjs --update --accept-regression="guard film dev scene (n22 guard)"`
and `tools/debt/baseline.json` is then allowed (debt tool only). Never stop the whole call for a NEED that only blocks one part.
Never delete or reword an existing comment. Typed GDScript, warnings are errors; files about 200 lines (hard 300), functions
<= 40 lines, <= 5 params; `Log` not `print`; no global RNG. Dev code may not be named by boot/core/features (lint `layers`).
`.uid` with new scripts (`--import` once). One commit, staged per path. Banned: `git stash`, `git add -A/./-u`, `git commit -a`,
`--amend`, rebase, `reset --hard`, push. Fix lint and format findings in your own edit and go on.

## Report
Commit SHA + files, the dev run verdict line, every output file with its duration / size, which beats are scripted vs AI,
what you could not film and why.
