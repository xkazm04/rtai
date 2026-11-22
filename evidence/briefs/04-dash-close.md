# Brief 04 `dash-close`: decisions, the film scenes in the repo, the mutate survivors (lane motion, n24)

Hard stop: HARDSTOP wall clock (check `date`). Commit deadline: COMMITBY. Whatever is not committed by then,
describe in your final report. Fix lint and format findings in your own edit and go on. No amend, no rebase,
no `git stash`, no `git add -A/./-u`, no `commit -a`, no reset --hard, never push. Stage per path.
Every Godot run: `export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run. One Godot at a time.

## 1. Decision lines (append to `docs/decisions.md`, one line each, date 2026-11-22, format of AGENTS.md)
- `DECISION sprint`: `sprint` leaves Shift (keeps bit 5 and its pad button, keys []); on the keyboard the sprint is
  folded into the dash: holding Shift after the burst keeps the 9.3 m/s sprint (`rivet_motion.json` `dash.hold_sprints`
  true; false = burst only). Why: the owner's "dash ... to support speed" with one key. Rejected: a second keyboard
  sprint key; no keyboard sprint at all (loses the 9.3 m/s the chase needs).
- `DECISION dash numbers`: distance_m 4.5, ticks 10, cooldown_ticks 40, iframe_ticks 0, with the measured reason from
  `evidence/n24-motion/dash_dodge.md` (rocket at 5/8/12 m cleared by +1.3/+1.4/+1.4 m after a 15-tick reaction;
  stomp at 1.8-3.5 m cleared; chase 10.8 m/s repeated dash vs 6.75 run vs a 3.2 m/s fleeing cop). Rejected: a blast
  i-frame window (not needed: measured).
- `DECISION dash wire`: logical bit 18 / wire bit 31; `TickInput` mask 48 bits; schema maxima 19/32 as ghost; dash
  state enters `PlayerMotion.write_state` only once a dash was used, so tapes without a dash press keep their bytes.
- `DECISION rivet legs fallback`: a held weapon without its own walk/run grid walks on the bare-claw walk8/run8 legs
  with the weapon-art held part on the painted palm (`rivet_motion.json` `walk_grid`), so nothing slides; masking the
  donor grid's drawn weapon was rejected (floor showed through the wrist). Own grids replace it per weapon.
Skip a line that already exists in the file (grep first).

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
