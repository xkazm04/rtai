# Brief 04b `dash-close` (short, pre-freeze): mutate survivors, then the film scenes (lane motion, n24)

Hard stop: HARDSTOP wall clock (check `date` often). Commit deadline: COMMITBY, hard: the lane freezes new code then.
Whatever is not committed by then: leave it uncommitted, describe it in your final report, do not commit late.
Fix lint and format findings in your own edit and go on. No amend, no rebase, no `git stash`, no `git add -A/./-u`,
no `commit -a`, no reset --hard, never push. Stage per path. Every Godot run:
`export APPDATA=C:/Users/kazda/kiro/gtai-n24/appdata/motion`,
`export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`,
`--rendering-driver d3d12` for anything that renders, `--position 0,1440` on any windowed run. One Godot at a time.
`tools/gate/quick.mjs` is red on every file for an unrelated reason (`--check-only -s` registers no autoloads);
use `node tools/tests/run_unit.mjs --changed` and the pre-commit lint instead.

Do NOT touch `rivet_walk.gd` / `rivet_stride.gd` / any art tonight (brief 04 item 0 is moved to tomorrow).

## 1. Mutate survivors (first, tests only)
`node tools/mutate/mutate.mjs --file=project/features/player/player_motion_dash.gd --max=20 --json` scored 15/20.
Read the five survivors; for each, kill it with a test in `project/tests/unit/test_player_motion_dash*.gd` (existing
or new file with that prefix, with its `.uid`) or say in the report why it is equivalent. Commit the tests, then
re-run mutate with `--max=20` and quote the new score.

## 2. The film scenes into the repo (only if 25+ minutes remain before COMMITBY)
The scenes behind the owner's films live only at `C:/Users/kazda/kiro/gtai-masters/n24/motion/capture-source/`
(`dash_take.*`, `dash_take_view.*`, `legs_film.*`, `legs_tile.*`). Commit them under `project/dev/motion/` (each with
its `.uid`; run one `--import`), each declaring `const KNOWN_FLAGS`, runnable through `node tools/dev/run.mjs <name> ...`
(quote the `dev_verdict` line of one short headless or `--quit-after` run of each). If the debt ratchet objects, accept
with `node tools/debt/debt.mjs --update --accept-regression="dash and legs film scenes for n24 motion"` and commit the
baseline in the same commit. Lint must pass (layers: nothing in boot/core/features may name these classes). If it
does not go green by COMMITBY, leave it uncommitted and say so.

## Allowlist
`project/dev/motion/**`, `project/tests/unit/test_player_motion_dash*.gd` (+ `.uid`), `tools/debt/baseline.json`
(through the debt tool only), `evidence/n24-motion/**`, `C:/Users/kazda/kiro/gtai-masters/n24/motion/`.
Any other path: stop and report a NEED. Forbidden: other lanes' files (melee_*, player_deflect, guard, enemies.json,
weapons.json, souls/**, ghost_*.json, gauntlet/**, characters/art), and product code of this lane tonight.

Final report: commits (sha + one line), mutate before/after with each survivor's fate, dev_verdict lines, anything not done.
