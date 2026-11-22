# Brief 04 `dash-close`: the film scenes in the repo, the mutate survivors (lane motion, n24)

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on. No amend, no rebase,
no `git stash`, no `git add -A/./-u`, no `commit -a`, no reset --hard, never push. Stage per path.
Every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run. One Godot at a time.

## 0. Stride numbers out of code (first, one commit)
`project/features/characters/rivet_walk.gd` is at ~200 lines and every drawn weapon adds rows to `RUN_ROW_K`,
`ARMED_CYCLE_CELL` (and `rivet_stride.gd` `WALK_PROFILE_TRAVEL`), so doc comments were squeezed out to fit
(`is_run`'s doc, the p55 stance-travel note moved into `rivet_stride.gd` above `OCT_RAD`). Move the per-weapon stride numbers
into a new `grid_stride` block of `project/data/tables/rivet_motion.json` (+ its schema), read once and cached the
way the file already reads `walk_grid`; keep the family defaults (pistol/plasma_rifle/katana/gatling/flamethrower)
where they are if moving them would change their numbers. Restore the dropped doc comments. Proof: the five
pre-existing drawn grids and gloria/rocket_launcher/chainsaw (and any newer) pick the identical cell on every tick
(the byte-identical check from brief 01 over 1440 frames), `run_unit --changed` green. Add `project/features/characters/rivet_walk.gd`,
`rivet_stride.gd`, `project/tests/unit/test_rivet_walk*.gd`, `test_rivet_stride*.gd` to the allowlist for this item.

## 1. (done in c32c08b31: the four decision lines landed; skip)

## 2. The film scenes into the repo
The scenes behind the owner's films live only at `C:/Users/kazda/kiro/gtai-masters/n24/motion/capture-source/`
(`dash_take.*`, `dash_take_view.*`, `legs_film.*`, `legs_tile.*`). Commit them under `project/dev/motion/` (each with
its `.uid`), each declaring `const KNOWN_FLAGS`, runnable through `node tools/dev/run.mjs <name> ...` (quote the
`dev_verdict` line of one short run of each). If the debt ratchet objects, accept with
`node tools/debt/debt.mjs --update --accept-regression="dash and legs film scenes for n24 motion"` and commit the
baseline in the same commit. Lint must pass (layers: nothing in boot/core/features may name these classes).

## 3. Mutate survivors
`node tools/mutate/mutate.mjs --file=project/features/player/player_motion_dash.gd --max=20 --json` scored 15/20.
Read the five survivors; for each, kill it with a test in `project/tests/unit/test_player_motion_dash*.gd` or say in
the report why it is equivalent. Re-run and quote the new score.

## 4. If time is left: the trail read
`dash_afterimage_64.png` shows warm posed-card copies that read but are faint. Try a stronger first copy (higher
alpha on the newest exposure, same colours, no teal, no tint outside Rivet's own palette) behind a table value in
`rivet_motion.json` `dash` (e.g. `trail_alpha`); render a before | after still at 64 px/m, same tick, to
`C:/Users/kazda/kiro/gtai-masters/n24/motion/dash_trail_64.png` and add a `frames.json` entry (keep the others).

## Checks
`node tools/tests/run_unit.mjs --changed`, `node tools/gate/quick.mjs` before each commit.

## Allowlist
`docs/decisions.md` (append only), `project/dev/motion/**`, `project/features/player/player_motion*.gd`,
`project/data/tables/rivet_motion.json` + `project/data/schemas/rivet_motion.schema.json`,
`project/tests/unit/test_player_motion_dash*.gd`, `tools/debt/baseline.json` (through the debt tool only),
`evidence/n24-motion/**`, `C:/Users/kazda/kiro/gtai-masters/n24/motion/`. Any other path: stop and report a NEED.
Forbidden: other lanes' files (melee_*, player_deflect, guard, enemies.json, weapons.json, souls/**, ghost_*.json,
gauntlet/**, characters/art except Rivet's walk/run).

Final report: commits (sha + one line), decision lines added, dev_verdict lines, mutate before/after, anything not done.
