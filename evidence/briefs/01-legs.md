# Brief 01 `legs`: see the slide, then stop it for every weapon (lane motion, n24)

Hard stop: 18:50 wall clock (check `date`). Commit deadline: 18:40. Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on.

## Why
The owner played main today: "Rivet is now flying instead of using his legs for movement, looking buggy".
Reading so far (the director's, verify it): only five weapons have drawn walk and run grids
(`project/features/characters/art/view/<p55|p70>/rivet_walk_eq_<w>.png`, `rivet_run8_eq_<w>.png` for
pistol, plasma_rifle, katana, gatling, flamethrower: one per hold family, packed by `tools/art/rivet_walk.py`
from the library's onehand / twohand / blade / heavy / flamer armed walk cells, see
`steam/ai-provenance/2026-11.jsonl`). `RivetWalk.path_of` (`project/features/characters/rivet_walk.gd:99`)
returns "" for every other held weapon (gloria, rocket_launcher, assault-rifle, chainsaw, electro_baton,
hand_cannon, machine_pistol, ...), so he slides on the still equipped card (`rivet_eq_<w>.png`) with a bob.
Not yet confirmed on screen. Also check bare hands under the wheel (wheel slot 0 `hands`, the default since
n23): the held weapon id may not be `&""` there, or something else may stop the walk grid. Look for a second
cause.

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- First run ONE `"$GODOT_BIN" --headless --path project --import` (main moved since the cache was made).
- Anything that renders: `--rendering-driver d3d12`; any windowed run `--position 0,1440` (secondary monitor).
- One Godot process at a time in this lane. Free your own processes by PID; never kill by name.
- Kit: `tools/README.md` (`tools/film/film.mjs`, `tools/film/compare.mjs`, `tools/film/foot_slide.py`,
  `tools/dev/run.mjs`, `tools/godot/check.mjs`, `tools/gate/quick.mjs` before each commit).

## Work, in order, one commit each

### 1. See it (no code change, or a dev-only film helper under `project/dev/motion/`)
Film Rivet walking (~3 m/s) and running (> 2.5 m/s, his run speed) at 32 and 64 px/m, tilt 70, with: bare
hands under the wheel (slot 0), the pistol, gloria, rocket_launcher, assault-rifle, chainsaw, electro_baton.
Use `tools/film/film.mjs` if a shot fits (read its doc; `weapon:<id>` shots exist); else a small dev scene
under `project/dev/motion/` driven by `tools/dev/run.mjs`. Rivet must walk in at least two directions
(a profile and a 3/4). Output: `C:/Users/kazda/kiro/gtai-masters/n24/motion/before/` (a still or a strip
per weapon per zoom, and one 32 px/m mp4 of 15 to 40 s cycling the weapons; 1080p60, check `ffprobe`).
Write a table into `evidence/n24-motion/slide_before.md`: weapon, walk grid path or "", run grid path or "",
slides yes/no (from the frames), the cause. Measure the slide with `tools/film/foot_slide.py` where it applies.

### 2. The no-slide rule (ships first; the drawing of real grids is a later brief)
No held weapon may fall back to the still card while he moves. Build:
- a table (new block in `project/data/tables/rivet_motion.json`, e.g. `"walk_grid": {"<weapon id>": "<grid weapon id>", ...}`,
  with a `doc` and schema update in `project/data/schemas/` if that table has a schema) saying which drawn grid
  each weapon walks and runs on. Default by grip class (`rivet_arsenal.json` `weapons` -> class): one_hand ->
  pistol, two_hand_long -> plasma_rifle (katana keeps its own), heavy_two_hand / hip_belt -> gatling,
  backpack_hose -> flamethrower, shoulder (rocket_launcher, mini_nuke) and thrown (molotov): pick what reads.
  A weapon with its own grid uses its own.
- what the borrowed grid shows in the claw: the borrowed grid has the OTHER weapon drawn in. Try, in this order,
  and keep the first that reads correctly on a 64 px/m still: (a) the borrowed grid with the held part drawn by
  `RivetHeldView` (`project/features/player/rivet_held_view.gd`) over it, the drawn weapon hidden (e.g. the
  family grid's weapon region masked; or the bare-claw grid `rivet_walk8.png` / `rivet_run8.png` legs and the
  held part on the claw); (b) bare-claw legs (walk8 / run8) with the held part from `RivetHeldView` on the
  claw. A wrong weapon in his hands is NOT acceptable (e.g. walking with a drawn pistol while holding gloria).
  Make the choice one table value, record it as a `DECISION` line in `docs/decisions.md` (one line, append).
- keep `--rivet-walk-armed=off` and the other existing flags working. The five weapons with drawn grids must
  render byte-identically to before (prove with `tools/film/compare.mjs` at one tick).
- a unit test `project/tests/unit/test_rivet_walk_every_weapon.gd`: for every weapon id in `rivet_arsenal.json`
  `weapons`, and for bare hands / wheel slot 0, at a walk speed and at a run speed, at both art pitches (p55, p70),
  `RivetWalk.path_of` (or your new entry point) returns a non-empty path while moving. Also a test that the
  table names only grids that exist on disk.
- after: the same films as step 1 into `C:/Users/kazda/kiro/gtai-masters/n24/motion/after/`, and a side-by-side
  per weapon (before | after, same tick, same zoom) with `tools/film/compare.mjs` where it works, into
  `C:/Users/kazda/kiro/gtai-masters/n24/motion/` named `legs_<weapon>_<ppm>.png`. Look at them yourself:
  feet that plant, the held weapon in the claw (not a second weapon), no halo. Write what you see per weapon
  into `evidence/n24-motion/slide_after.md`.
- after committing: `node tools/mutate/mutate.mjs --file=project/features/characters/rivet_walk.gd --max=20 --lines=<your changed lines>` and quote the score in your report.

## Files you may touch (allowlist)
`project/features/characters/rivet_walk.gd`, `rivet_frames*.gd`, `rivet_strips.gd`, `rivet_stride.gd`,
Rivet's walk/run art under `project/features/characters/art/view/**/rivet_walk*`, `rivet_run8*`,
`tools/art/rivet_walk*.py`, `project/features/player/player_motion*.gd`, `top_down_mover.gd`, `stride_match.gd`,
`project/data/tables/rivet_motion.json` (+ its schema), `rivet_bob.json`, new files under `project/dev/motion/`,
new tests `project/tests/unit/test_rivet_walk_*.gd`, `evidence/n24-motion/**`, the masters folder above,
one appended line in `docs/decisions.md`, one appended line per new flag in `project/boot/launch_args.gd`
`KNOWN_FLAGS` (then `node tools/debt/debt.mjs --update --accept-regression="<flag> for n24 motion"`).
`project/features/player/rivet_held_view.gd` is not on the lane's list: if you must change it, a one-line call
site only, and name it in your report. Any other path: stop and report a NEED with the file and why.

## Forbidden
Other lanes' files: `melee_*.gd`, `player_melee.gd`, `player_shock.gd`, `rivet_swipe_view.gd`, `weapon_cursor.gd`,
`melee_weapons.json`, `signature_kills.json`, `enemies.json`, `weapons.json`, `player_deflect.gd`, `player_guard*.gd`,
`combat.json`, `project/features/gauntlet/**`, `project/features/souls/**`, `ghost_*.json`, `powers.json`,
enemy art, Rivet's strike/windup art, `combat_arena.gd` beyond a one-line call site. No `git stash`, no
`git add -A/./-u`, no `commit -a`, no amend, no rebase, no reset --hard, never push. Stage per path; commit
`.uid`/`.import` files with new sources (run a Godot `--import` after adding art or scripts). No sim, parity or
bake digest may move; recorded tapes replay identical (run `node tools/tests/run_unit.mjs --changed` and the
scenarios if you touch anything on the tick; this work should be render-only).

## Report
Files changed, commits (sha + subject), what you ran and its result, the slide table, which option (a/b)
you chose and why, the mutate score, anything not done and why.
