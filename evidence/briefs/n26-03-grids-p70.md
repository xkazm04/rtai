# Brief n26-03-grids-p70: drawn walk and run grids for the six weapons still on stop-gap legs (tilt 70)

Lane `keys`, branch `n26-keys`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-controls` (your cwd).

**Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY; the first weapon committed by FIRSTBY even if alone.**
Small commits, staged per path, `git commit -- <paths>`. No amend, no rebase, no stash, no `add -A/./-u`, no `commit -a`,
no `reset --hard`, never push. Fix lint and format findings in your own edit and go on. mutate: `--max=20`, changed lines only.

Before every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n26/appdata/keys` and
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; anything that renders
`--rendering-driver d3d12`; windowed runs `--position 0,1440`. One Godot process at a time in this lane; free your own by PID.

## Why
Last run (n24-motion) drew p70 walk + run grids for seven weapons (gloria, rocket_launcher, chainsaw, electro_baton,
assault_rifle, hand_cannon, machine_pistol; see `evidence/n24-motion/grid_*.md`). Six weapons still walk on the fallback
(bare-claw legs with the thin held part on the painted palm, lighter and redder than their armed cards, so the tone jumps on
start and stop): **electro_gun, homing_shard, mini_nuke, molotov, plasma_sword, ray_gun**, in that order. Draw each its own
p70 grid to the standard of last run's seven. p70 only (p55 is the next brief). One weapon fully done beats three half-done.

## The pipeline (the one last run's seven came from; reuse, do not reinvent)
- Read first: `evidence/briefs/03-grids.md` (n24 brief: pipeline, method per row, accept rule), the n24 grid reports
  `evidence/n24-motion/grid_machine_pistol.md` and `grid_electro_baton.md`, the delivery notes under
  `C:/Users/kazda/kiro/gtai-art/library/deliveries/rivet_armed_run_*` and `rivet_walk_armed_it99.md`, and last run's round
  scripts under `C:/Users/kazda/kiro/gtai-art/library/rounds/*-n24motion/` (cut_rows.py, stride.py, pack_candidate.py,
  tone pass): copy them into the new round dir, do not rewrite them.
- Per row: image 1 = the same row of a SHIPPED grid of the nearest hold family (one-hand: pistol / machine_pistol / hand_cannon;
  long two-hand: plasma_rifle / assault_rifle; heavy shoulder: rocket_launcher / gatling; blade: katana / electro_baton; thrown:
  pick the one-hand walk with the off hand free), image 2 = the weapon as Rivet holds it in that facing, cropped from
  `project/features/characters/art/view/p70/rivet_eq_<weapon>.png` (`_left`, `_diag`). Keep image 1's legs, body, pose and frame
  order exactly; replace the drawn weapon with image 2's, same hand, side and layer. Last run's lesson: include a clean free-arm
  example in the first sprint requests for asymmetric weapons (the stray donor claw cost corrective jobs).
- Image generation: `node C:/Users/kazda/kiro/gtai-art/gen.mjs <roundDir>` (authorised; rounds under
  `C:/Users/kazda/kiro/gtai-art/library/rounds/<yyyymmdd-hhmm>-n26keys/`). Known fault: a job can stall on the copy to `./out`
  after the image exists under `~/.codex/generated_images/`: copy it by hand. Never draw a sheet or a fix with script-made shapes;
  cutting, keying, masking and tone matching by script are fine.
- Colour law: the plasma sword and ray gun keep their own drawn colours from their eq strips; red is blood only, teal only for
  souls, vermilion only for danger and Rivet's collar. Rivet's striped neck band is a rigid hazard collar, never cloth.
- Cells to `C:/Users/kazda/kiro/gtai-art/library/keyed/rivet/rivet_walk_armed_<weapon>_70_cells/` (+ `_left_cells`) and
  `rivet_run8_armed_<weapon>_70_cells/` (+ `_left_cells`); pack with `tools/art/rivet_walk.py` (`--tone=rivet_eq_<weapon>.png`) to
  `project/features/characters/art/view/p70/rivet_walk_eq_<weapon>.png` and `rivet_run8_eq_<weapon>.png`; a Godot `--import`;
  commit the `.import` files with the png.
- Provenance: one line per shipped png appended to `steam/ai-provenance/2026-11.jsonl` (same fields as last run's lines,
  accepted_by `agent:n26-keys lane`, date 2026-11-23).
- Stride numbers go into `project/data/tables/rivet_motion.json` `grid_stride` if brief 02 moved them there (check
  `git log`), else into `rivet_walk.gd` / `rivet_stride.gd` as last run.

## Accept a grid only when
- you looked at every row yourself at 32 and 64 px/m in the game (arena, real walk 6.75 m/s and sprint 9.3 m/s): clean cut,
  no halo, no clipped limb, no second weapon, no stray free-arm spike, the weapon matching its eq strip, row tones even with the
  eq card (mean RGB within a few units), feet that plant (`tools/film/foot_slide.py` on profile rows: walk drift <= 2 cm,
  run <= 7 cm mean at 32 px/m).
- the stride is measured per row and written to data + `evidence/n26-keys/grid_<weapon>.md` (per row: travel, family's, k;
  grades; fixes asked; image-gen job count and minutes).
- a before (fallback) | after (own grid) still at the same tick, 32 and 64 px/m, to
  `C:/Users/kazda/kiro/gtai-masters/n26/keys/grid_<weapon>_<32|64>.png`.
- `node tools/tests/run_unit.mjs --changed` green (the every-weapon test included), lint green.
One commit per weapon (pngs + .import + provenance + numbers + evidence md).
A weapon that fails your own look after two corrective rounds stays on the fallback: say so in its md and go to the next.

## At the end (if at least 15 minutes are left before the hard stop)
A game-speed film of the weapons that landed: arena with the wheel, walk and sprint, fallback beside own grid,
32 px/m tilt 70 1080p60, 15-40 s (`ffprobe` it) to `C:/Users/kazda/kiro/gtai-masters/n26/keys/legs_six_32.mp4`.
Delete scratch renders you do not reference; report the scratch GB freed.

## Allowlist (anything else: stop and report a NEED line)
`project/features/characters/art/view/p70/rivet_walk_eq_*`, `rivet_run8_eq_*` (+ `.import`), `tools/art/rivet_walk*.py`,
`project/features/characters/rivet_walk.gd`, `rivet_stride.gd`, `rivet_grid_stride.gd`, `rivet_frames*.gd` (calibration only),
`project/data/tables/rivet_motion.json` (+ schema, stride data only), `project/tests/unit/test_rivet_walk_*.gd`,
`project/dev/motion/**`, `evidence/n26-keys/**`, `steam/ai-provenance/2026-11.jsonl` (append only), new dirs/files under
`C:/Users/kazda/kiro/gtai-art/library/rounds/*-n26keys/` and `.../keyed/rivet/` (never overwrite an existing library file),
`C:/Users/kazda/kiro/gtai-masters/n26/keys/`.
Forbidden: every other character's art; Rivet's `rivet_eq_*` equipped strips and strike / windup art; enemy tables; melee,
combat, gauntlet and souls code; `ghost_*.json`; prologue files; `native/`.

## Report
Per weapon: done / partial / fallback kept, row grades and fixes asked, stride numbers, stills, commit sha; image_gen count
and minutes; film path + ffprobe line; what you would do differently.
