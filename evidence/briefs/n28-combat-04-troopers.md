# Brief n28-combat-04-troopers: two rocket troopers against the shorter dash, seeds 1 to 10, before beside after

Lane `combat`, branch `n28-combat`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-street` (your cwd).
**HARD STOP and commit deadline: see the end of this brief (wall clock). At the hard stop write your report and END, even
mid-task.** Never stop to ask: at a fork pick what best serves the owner's words, write it in your report, go on. Fix lint
and format findings in your own edit and go on. No amend, no rebase.

## Why
Owner's answer to "two troopers against the dash": a shorter dash cooldown. Last run (`docs/day/2026-11-24/n27-pressure/REPORT.md`
section 2, `evidence/n27-pressure/takes/seeds.md`, `dash_late.md`): the `pair_dash` take (Rivet circles at 10 m and
dashes across each rocket line) lost a median 4.6 HP in 25 s, but in seeds 3 and 5 the troopers drift, the second rocket
leaves 36 to 49 ticks after the first, the dash (10 ticks + 40 cooldown) is refused, and Rivet loses 40.6 and 50.9 HP.
The keys lane has now shortened `rivet_motion.json` `dash.cooldown_ticks` (MILESTONE keys-dash `64004a59d`, value
`24`; the director merged `n28-keys` at that sha into this branch: `97b49b194`).

## What
A. **Before** = n27 numbers (main `d0ab9d03a`): re-run them, do not quote: `node tools/dev/run.mjs pressure_seeds -- --out=<dir>`
   and `node tools/dev/run.mjs pressure_dash_trace -- --out=<abs file> --seeds=1,2,3,4,5,6,7,8,9,10` in a temp worktree
   at `d0ab9d03a` (`git worktree add <%TEMP%/gtai-combat-before> d0ab9d03a`; copy the native DLLs from this worktree's
   `project/bin` or the paths `AGENTS.md` names; one `--import` there; remove the worktree at the end with
   `git worktree remove`). Write `evidence/n28/troopers/before/`.
B. **After** on this branch (HEAD, keys' dash merged): the same two runs -> `evidence/n28/troopers/after/`.
   If the dash take's press timing is tied to the old 50-tick cycle (`project/dev/gauntlet/pressure_pair.gd`, its dash
   cadence), DO NOT retune it silently: first run it unchanged; then, if the take presses only once per volley by
   construction, add a take variant `pair_dash2` that presses for each rocket when the dash is ready (dev only), and
   report both. Every change to a take: a `docs/decisions.md` line (one appended line) and the `test_pressure_takes`
   pins updated.
C. **Table** `evidence/n28/troopers/seeds.md`: per seed 1..10, before / after: rockets, direct, splash, HP lost (whole
   25 s and after 10 s), dashes pressed, dashes refused, down or not; seeds 3 and 5 called out; Wilson 95 % on the shares
   as n27 did. One paragraph: did the shorter cooldown cover the second rocket.
D. **Film**: `trooper_pair_32.mp4` before (main) beside after (this branch), same seed (3 or 5, whichever lost more
   before), 32 px/m, side-by-side 1920x1080 (each half 960 wide, captioned "n27 dash 40" / "n28 dash 24"), 60 fps,
   20-30 s, through `tools/gauntlet/pressure_films.mjs` or `tools/film/compare.mjs` (say which), plus a 64 px/m still pair
   at the tick the second rocket lands (`pair_dash_late_{before,after}_64.png`). ffprobe each. To
   `C:/Users/kazda/kiro/gtai-masters/n28/combat/{films,stills}/`, entries in `frames.json` (keep existing).
E. **Mutate** if a take file changed: `node tools/mutate/mutate.mjs --file=project/dev/gauntlet/pressure_pair.gd --max=12
   --lines=<changed lines> --tests=test_pressure_takes` (budget 10 min).

## Checks
`node tools/tests/run_unit.mjs --select=test_pressure_takes` and `--changed` green; `node tools/gate/quick.mjs` before
every commit; about 12 min for the pre-commit hook; on a `tools/film/kill_reel_*.break.test.mjs` failure run a Godot
`--import` and commit again (never skip the hook).

## Repo law (binding)
- Memory budget: the lane sessions hold the 8 GB cap near 6.2 GB, so the default 1200 MB estimate waits up to 30 min a run. Export `GTAI_GODOT_EST_MB=600` for headless runs and `GTAI_GODOT_EST_MB=1000` for rendered runs (measured in call 01b, `evidence/n28/bond/memory.txt`). A `mem-budget: waiting` line is still not a hang: wait; never bypass the cap.
- Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n28/appdata/combat GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
  `--rendering-driver d3d12` for renders; any windowed run at `--position 0,1440`, never the main display. One Godot
  process at a time (the temp worktree counts); kill only your own PIDs, never by name. 8 GB cap: `mem-budget: waiting` is not a hang.
- Typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log` not print, `.uid` with every
  new `.gd`. Stage per path; banned: `git stash`, `add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push.

## Allowlist (any other path: stop that part and report `NEED <what>`)
`project/dev/gauntlet/**`, `project/tests/unit/test_pressure_takes.gd`, `tools/gauntlet/**`, `tools/debt/baseline.json`
(debt tool only), `docs/decisions.md` (one appended line), `evidence/n28/**`, `C:/Users/kazda/kiro/gtai-masters/n28/combat/`,
your temp worktree under `%TEMP%`.
Forbidden: `rivet_motion.json` (keys'), `input_actions.json`, `project/features/player/**`, `enemies.json` and every balance
value, other worktrees, root `JOURNAL.md` / `REPORT.md`.

## Report and END (short)
Commits; the before/after table's headline (HP lost seeds 3 and 5, median, downs); film/still paths + ffprobe; tests;
what was left.
