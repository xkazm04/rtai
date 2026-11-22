# Brief 03 `grids`: drawn walk and run grids for the weapons that borrow one (lane motion, n24)

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on.

## Why
Owner: "Rivet is now flying instead of using his legs for movement, looking buggy". Brief 01 shipped a rule that
gives every weapon legs by borrowing a hold family's grid (see `project/data/tables/rivet_motion.json` block
`walk_grid` and `evidence/n24-motion/slide_after.md`). Now draw each weapon's own grid so the weapon in his hands
is drawn in the walk, in the owner's order: gloria, rocket_launcher, assault_rifle (arsenal id `assault-rifle`),
chainsaw, electro_baton, hand_cannon, machine_pistol, then the rest. p70 (tilt 70, the game's default) first for
each weapon, then p55. One weapon fully done (walk + run at p70, cut, packed, measured, wired, looked at) beats
three half-done. A grid that fails your own look stays on the fallback and is listed in the report.

What brief 01 actually shipped (commit 8b5f4d96e): option (b), the bare-claw walk8/run8 legs with weapon-art's held
part placed on the painted palm (`rivet_frames_grip.gd`, `walk_grid.palm_percent`). The director's look at
`C:/Users/kazda/kiro/gtai-masters/n24/motion/legs_<w>_64.png`: the legs step, but (1) the held part reads much
thinner than the equipped card's drawn weapon (gloria becomes a thin grey stick; the rocket tube hangs down at his
side in the 3/4 toward view; the chainsaw dangles blade down), (2) the bare body is lighter and redder than the
armed cards, so the tone jumps on start and stop. Your own grids must fix both: the weapon drawn as on
`rivet_eq_<w>.png`, the grid tone-matched to it (`--tone`).
Films for the owner are the real game, not a lab board: Rivet in the arena or gauntlet with the wheel, at his
real walk (6.75 m/s) and sprint, 32 px/m tilt 70 1080p60, 15 to 40 s, before (fallback) beside after (own grid).
A one-line or two-number edit in a schema your own new data needs is allowed: name it in the report, do not stop.

## The pipeline the five shipped grids came from (use it, do not invent another)
- Read first: `C:/Users/kazda/kiro/gtai-art/library/deliveries/rivet_armed_run_onehand_it128.md` (the method:
  one generated sheet per row, combining two examples; the hand rule; the layer rule; fixes by example),
  `rivet_armed_run_twohand_it129.md`, `rivet_armed_run_blade_heavy_it131.md`, `rivet_armed_run_55_it132.md`,
  the walk deliveries named in `steam/ai-provenance/2026-11.jsonl` for `rivet_walk_eq_pistol.png`
  (`deliveries/rivet_walk_armed_it99.md`), `C:/Users/kazda/kiro/gtai-art/gen.mjs` (the Codex image_gen runner:
  a round dir with `jobs.json` + `refs/`), the library's own cutting tools under
  `C:/Users/kazda/kiro/gtai-art/library/tools/` (`grid_cells.py`, `run8_assemble.py`, keying), and the repo
  packer `tools/art/rivet_walk.py` (its header: cells dir layout, `--cols=8`, `--tone=<rivet_eq_<w>.png>`,
  `--k` for runs).
- Method for a new weapon: per row, image 1 = the same row of the SHIPPED grid of its hold family (the legs and
  the body: e.g. gloria's rows from the one-hand pistol walk cells / run cells, the rocket launcher from the
  heavy or two-hand), image 2 = the weapon as Rivet holds it in that facing, cropped from his equipped strip
  `project/features/characters/art/view/p70/rivet_eq_<weapon>.png` (and `_left`, `_diag`). Prompt: keep image 1's
  legs, body, pose and frame order exactly; replace the drawn weapon with image 2's weapon, same hand, same side,
  same layer (in front of / behind the body) as image 2. This keeps the stride, so the stance foot plants on the
  family's measured cycle; still measure it.
- Image generation: use your built-in image_gen tool (the tool `gen.mjs` drives), or run
  `node C:/Users/kazda/kiro/gtai-art/gen.mjs <roundDir>`: the director authorises that runner for this brief, it
  is the shipped art pipeline. Rounds go under `C:/Users/kazda/kiro/gtai-art/library/rounds/<yyyymmdd-hhmm>-n24motion/`.
  Known fault: a job can stall on the copy to `./out` after the image exists: the image is then under
  `~/.codex/generated_images/` and may be copied by hand. Never draw a sheet or a fix with script-made vector
  shapes; a cut, a key, a mask or a tone match by script is fine.
- Cells go to `C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/rivet_walk_armed_<weapon>_70_cells/` (+ `_left_cells`)
  and `rivet_run8_armed_<weapon>_70_cells/` (+ `_left_cells`); pack with `tools/art/rivet_walk.py` (the same
  arguments the family's shipped grid used: read the provenance line's `human_edits`) to
  `project/features/characters/art/view/p70/rivet_walk_eq_<weapon>.png` and `rivet_run8_eq_<weapon>.png`, then a
  Godot `--import` so the `.import` files exist, commit them with the png.
- Provenance: one line per shipped png in `steam/ai-provenance/2026-11.jsonl` (append; the same fields as the
  pistol's lines: accepted_by `agent:n24-motion lane`, date 2026-11-22, file, human_edits, model, prompt_ref,
  references, sha256, ships_in, tool).

## Accept a grid only when
- you looked at every row yourself at 32 and 64 px/m in the game (a still of each facing walking, from a film or
  a dev scene; `tools/film/film.mjs weapon:<id>` or the brief-01 film helper under `project/dev/motion/`): clean
  cut (no halo, no clipped limb, no second weapon, no stray free-arm spike), the cop's line weight and palette,
  the weapon matching his equipped strip, feet that plant (`tools/film/foot_slide.py` on a profile row).
- its stride is measured the way `RivetWalk` documents (`ARMED_CYCLE_CELL` "<art>/<weapon>" for the walk, a
  `RUN_ROW_K` entry per run row that is shorter than run8's), the numbers written into `rivet_walk.gd` and into
  `evidence/n24-motion/grid_<weapon>.md` (per row: travel cell px, the family's, the k).
- the `walk_grid` table entry for that weapon points at its own grid (or is removed, if the rule is "own grid first").
- a before (fallback) | after (own grid) still at the same tick, 32 and 64 px/m, into
  `C:/Users/kazda/kiro/gtai-masters/n24/motion/grid_<weapon>_<ppm>.png`.
- `node tools/tests/run_unit.mjs --changed` green, `tools/gate/quick.mjs` green; the every-weapon test still green.
One commit per weapon (its pngs + .import + provenance + numbers + evidence).

## Environment (every Godot run)
- `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`.
- Anything that renders: `--rendering-driver d3d12`; any windowed run `--position 0,1440`.
- One Godot process at a time in this lane. Free your own processes by PID; never kill by name.

## Files you may touch (allowlist)
Rivet's walk and run art `project/features/characters/art/view/**/rivet_walk*`, `rivet_run8*` (+ `.import`),
`tools/art/rivet_walk*.py`, `project/features/characters/rivet_walk.gd`, `rivet_frames*.gd`, `rivet_strips.gd`,
`rivet_stride.gd`, `project/data/tables/rivet_motion.json`, tests `project/tests/unit/test_rivet_walk_*.gd`,
`project/dev/motion/**`, `evidence/n24-motion/**`, `steam/ai-provenance/2026-11.jsonl` (append only),
new folders/files under `C:/Users/kazda/kiro/gtai-art/library/rounds/*-n24motion/` and
`C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/*_n24*` or the cell folder names above (never overwrite an
existing library file), `C:/Users/kazda/kiro/gtai-masters/n24/motion/`. Any other path: stop and report a NEED.

## Forbidden
Every other character's art, Rivet's `rivet_eq_*` equipped strips and strike / windup art (melee lane), enemy
tables, melee and gauntlet code, souls. No `git stash`, no `git add -A/./-u`, no `commit -a`, no amend, no rebase,
no reset --hard, never push. Stage per path.

## Report
Per weapon: done / partial / fallback kept, the rows' grades and the fixes asked, the stride numbers, the stills,
the commit sha; the image_gen count and minutes; what you would do differently.
