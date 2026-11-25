# Brief n29-cast-11: the door carrier's eight with the redrawn 70 right drawing 7, a one-value switch, a height test

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop HARDSTOP local** (check `date +%H:%M` often). **Commit 1 by COMMIT1, your last commit by LASTCOMMIT** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.

## Read first
`docs/art/cast-audit.md` sections "Door carrier on eight drawings, n29" and the re-plant after it (the feet table: four after
`61c383438` vs eight after; bars sole <= 2, jump <= 12, tool's 32 px/m unit), commits `073321ae7`, `fac845dd9`, `61c383438`
(`git show --stat`), `evidence/briefs/n29-cast-06-door8.md` and `n29-cast-09-door-replant.md` (their repo law binds you),
`tools/film/cast_door_films.mjs` (the `feet` mode), `tools/art/cast_door_eight.py`, `cast_door_soles.py`, `cast_door_feet.py`.

## New art (director, 04:56)
`C:\Users\kazda\kiro\gtai-art\foes-n29\door8b\out\door8_70_right_f7.png`: an image edit of `door8/out/door8_70_right.png` in
which ONLY drawing 7 (row 2, third) is redrawn: the support boot now sits ~30 px (source px) behind drawing 6's, the other boot
lifts and passes. Codex says drawings 1-6 and 8 kept their pixels; verify (per-drawing pixel diff against the old source,
quote it). The old eight's 70 right failed because drawing 7 stepped forward (sole 2.83, jump 6.47 after the re-plant).

## Scope
1. **Cut**: re-pack the p70 eight sheet `project/features/characters/art/view/p70/shield_robot_planted8_armed_walk.png` with
   the f7 source for the right facing (every other facing unchanged, byte-compare the other rows); body height of the four
   within 0.5 px; key-clean 0/0; strict red 0; provenance line appended (`steam/ai-provenance/2026-11.jsonl`). Regenerate the
   EIGHT70 table with `cast_door_soles.py`. One Godot `--import`. `run_unit --changed` (quote). Commit 1.
2. **One-value switch**: today switching needs four lines (`WALK`, `WALK70`, `WALK55`, `WALK_STEP_M`). Make the generator emit
   them derived from `WALK` (e.g. `const WALK70: Array[Vector4] = EIGHT70 if WALK == EIGHT else FOUR70` if GDScript const
   allows it, else a static func the view calls), so the switch is ONE value; a unit test pins that every derived table
   follows `WALK`. Add a door height test (the line-80 height formula in `foe_shield_card_view.gd`, mutate survivors in
   `61c383438`): the door's on-screen height at body_scale 1 equals today's value (111 px at 64 px/m in the size scene;
   pin the formula's number, not a frame).
3. **Feet**: `node tools/film/cast_door_films.mjs build/look/n29-door11 feet` for the eight with the f7 drawing: the table
   row 70 right (and every other facing, both pitches) after; before = the audit's "eight after" and "four after". Append a
   section "Door eight with the redrawn drawing 7, n29" to `docs/art/cast-audit.md`.
   **Ship `WALK = EIGHT` if the eight is no worse than the four in every measured facing** (sole and jump, both pitches;
   the down-right sole is unmeasurable behind the slab in the four: compare jumps there). Else keep FOUR and name the
   facing and drawing that still fails, so the director can order the next one-row edit.
4. Commit 2 (switch + tests + audit). If time remains: film `C:\Users\kazda\kiro\gtai-masters\n29\cast\door8_walk_32.mp4`
   again with what ships (1920x1080, 60 fps, 15-40 s, 32 px/m, tilt 70, ffprobe) and the still
   `door8_feet_before_after_64.png` (four left, eight right), update their `frames.json` notes; mutate
   `foe_shield_card_view.gd --lines=<height formula lines> --max=10 --tests=test_cast_door` in 15 min, quote the score.

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock** (shared with another builder): `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before
  any Godot launch, `rmdir build/lane-godot.lock` right after (also on failure); older than 25 min = stale, remove it.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`.
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). The quick gate's Godot parse step failed on
  untouched files: `node tools/gate/quick.mjs --no-godot` + GUT is accepted, say so. Debt red: `node tools/debt/debt.mjs
  --update` (`--accept-regression="door eight for n29 cast"` if it rises), include the baseline.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a frame or a number.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/shield_robot_planted8_*` (+ `.import`),
`project/features/characters/cast_door_anchors.gd`, `project/features/combat/squad/foe_shield_card_view.gd`,
`project/features/characters/cast_card_kinds.gd` (door lines only), `tools/art/cast_door_*.py`, `tools/film/cast_door_films.mjs`,
`project/tests/unit/test_cast_door*.gd` (+ `.uid`), `docs/art/cast-audit.md` (append), `steam/ai-provenance/2026-11.jsonl`
(append), `C:\Users\kazda\kiro\gtai-art\foes-n29\door8b\**`, scratch `build/look/n29-door11/`, outputs in
`C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: every `robot_thug_*`, `war_machine_*`, `cast_thug_*`, `cast_war_*` file, `tools/art/cast_foe_*.py`,
`cast_cards.json`, `arena_robot_rigs.gd`, `rig_clips.gd`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`, other lanes' files.

## Report (then END)
Commits, the per-drawing pixel diff of the source, heights, key-clean / red, the feet table before/after, WALK shipped and
why, the one-value switch diff in two lines, tests added, `run_unit --changed` line, film + ffprobe if made, mutate score,
NEEDs, what you could not do.
