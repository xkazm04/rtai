# Brief n27-pressure-03-films: honest rocket counts, the films re-cut, frames.json to 8+ entries

Launched 05:12. **Hard stop 06:12** (launch + 60 min: report and END by then). Commit each finished part as soon as
it passes, the first commit within 25 minutes of launch. No product behaviour changes in this call (dev takes, tools
and evidence only; no `project/data/**`, no `project/features/**`).

## Context

Your calls 1 and 2 built the four takes and measured them over seeds 1 to 10 (`evidence/n27-pressure/takes/seeds.md`).
The director read the numbers and found the pair takes' "hits" misleading: `PressurePair.observe` counts every tick on
which Rivet's HP drops. In `pair_circle` 7 "hits" kill him (direct rockets); in `pair_dash` 4 "hits" leave him at 95 to
99 HP, so they are splash grazes or something smaller, not rockets on target. The film caption ("Rockets 26  Hits 4")
tells the owner the dash still eats one rocket in six, which the HP bar contradicts. Also: 13 dashes for 26 rockets
in every seed, unexplained; and `deflect_6m_32.mp4` is 108 MB at 21.9 Mb/s (trooper_pair is 14 MB).

## Godot is held until `evidence/n27-pressure/medians/melee/DONE` exists

The director's after-melee median batch runs in a scratch worktree until about 05:25. Write code first; start
Godot only after that file exists. One Godot process at a time. When your last Godot run ends, write
`evidence/n27-pressure/godot-free-3.txt` with the time.

## Tasks, in order

1. **Split the pair takes' damage** in `project/dev/gauntlet/pressure_pair.gd`: per HP drop, attribute it to a direct
   rocket hit, a splash graze, or another source (read how `FoeRocketFlight` deals direct vs splash damage; attribute
   from the sim's own events or the damage amount, whichever the code supports without touching `features/`), and
   keep `hp_lost` (sum). Summary keys: `launches`, `direct`, `splash`, `other`, `hp_lost`, `death_tick`, `hp_at_10s`,
   `dashes`. Caption in the film: `Rockets %d    Direct %d    Splash %d    HP lost %.0f` (plus the end line). Find out
   from the code why `pair_dash` dashes 13 times for ~25 rockets (dash cooldown? two rockets in the same window?) and
   state it in one sentence in `seeds.md` and in the film note. Update `test_pressure_takes.gd` for the new keys, and
   add the two cheap kills call 2's mutate named (`evidence/n27-pressure/mutate/scores.md` section 3): assert
   `hp_at_10s` (line 72 survivor) and a start off the circle that exercises the radius pull (line 46).
2. **Re-run the seed table** for `pair_circle` and `pair_dash` (seeds 1 to 10) with the new columns; replace those two
   sections of `evidence/n27-pressure/takes/seeds.md` / `seeds.json` (keep the 6 m sections; pooled direct/launches
   with a Wilson interval, HP lost median).
3. **Re-film `trooper_pair`** (same seed 1, 1500 ticks, side by side) with the new caption, and **re-encode both
   masters** (`trooper_pair_32.mp4`, `deflect_6m_32.mp4`) to H.264 crf 23 or so, 1920x1080, 60/1, keeping duration
   (15 to 40 s). Check each with `ffprobe` (size, fps, duration) and quote it. The film tool is
   `tools/gauntlet/pressure_films.mjs --out=C:/Users/kazda/kiro/gtai-masters/n27/pressure`; add `--only=` use as
   before. If the encoder settings live in the tool, change them there so a re-run gives the small file.
4. **frames.json to 8 to 15 entries, best first** (`C:/Users/kazda/kiro/gtai-masters/n27/pressure/frames.json`,
   `[{file,title,ppm,before,note}]`). Add 64 px/m stills, each picked at a tick where the thing named is on screen
   (verify by looking at the PNG: read it with your image viewer tool, describe what you see in the report):
   (a) `pair_dash` mid-dash across a rocket's line, the rocket visible;
   (b) `pair_circle` the rocket that downs him, just before impact;
   (c) `guard6` a returned round in flight back toward a shooter;
   (d) `blade6` a rifle round striking Rivet during a swing (the cause of the half-catch, from call 2's finding);
   and 32 px/m single-take stills of `pair_dash` and `blade6` if the list is still short. Each note: what is on
   screen, the take, seed, tick, and the pooled 10-seed number from `seeds.md` that the still illustrates. Delete
   scratch renders the list does not reference. Notes are plain English for the owner: no class names.

## Files (allowlist; any other path: stop and write NEED in your report)

`project/dev/gauntlet/**` (with `.uid`), `project/tests/unit/test_pressure_takes.gd`, `tools/gauntlet/pressure_films.mjs`,
`evidence/n27-pressure/takes/**`, `evidence/n27-pressure/mutate/scores.md` (append), `evidence/n27-pressure/godot-free-3.txt`,
`C:/Users/kazda/kiro/gtai-masters/n27/pressure/**`, `tools/debt/baseline.json` only through
`node tools/debt/debt.mjs --update --accept-regression="<reason> for n27 pressure"`.
**Forbidden**: `project/data/**`, `project/features/**`, `project/boot/**`, `JOURNAL.md`, `REPORT.md`,
`evidence/n27-pressure/medians/**`, every other lane's worktree and files.

## Machine rules

- Before any Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n27/appdata/pressure` and
  `export GODOT_BIN='C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe'`; rendering runs
  add `--rendering-driver d3d12`; any windowed run `--position 0,1440` (never the main display). Free your own
  processes by PID; never kill by name.
- After new scripts land, one Godot `--import` before committing. Fix lint and format findings in your own edit and
  go on. If the pre-commit hook fails on `tools/film/kill_reel_*.break.test.mjs`, run a Godot `--import` and commit
  again; never `--no-verify`.
- After the code commit: `node tools/mutate/mutate.mjs --file=dev/gauntlet/pressure_pair.gd --max=12 --tests=test_pressure_takes`
  and quote killed/(killed+survived) beside call 2's 6/12; append both scores to
  `evidence/n27-pressure/mutate/scores.md` (section 3b).

## Repo law

AGENTS.md and STANDARDS.md: typed GDScript, ~200 lines a file (hard 300), functions <= 40 lines, <= 5 params, `Log`
not `print`, deterministic (fixed tick, RNG registry). Stage per path; `git commit -- <paths>`. Banned: `git stash`,
`git add -A/./-u`, `commit -a`, `reset --hard`, amend, rebase, push.

## Report

Commits; the new pair table pooled numbers (direct/launches with interval, splash, HP lost) and the dash-count reason;
ffprobe lines of both masters; the frames.json list with one line each of what you saw in every still; mutate score;
anything undone and why.
