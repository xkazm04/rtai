# Brief n29-cast-03c: robot thug A, the shoe foot line in the cutter + the attack, hit and fall on the ground

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop HARDSTOP local** (check `date +%H:%M` often). **Start commit 1 by COMMIT1, your last commit by LASTCOMMIT** (hook
~12 min). Never end with finished work uncommitted. Then report and END.

## Read first
`evidence/briefs/n28-cast-04-thug.md` (the checklist's exact bars and the "Added 20:45" lessons bind you; read n29 for n28:
APPDATA `C:/Users/kazda/kiro/gtai-n29/appdata/cast`, films to `C:\Users\kazda\kiro\gtai-masters\n29\cast\`), then
`evidence/n29/thug/feet_size.md`, `C:\Users\kazda\kiro\gtai-art\foes-n29\thug\STATE.md`, commits `75b0374d0`, `19c72dfdb`,
`d49ce6eb5` (`git show --stat`). The card row `robot_thug` stays `enabled: false` in this call.

## The fault (found by the 03b builder, 04:00)
In the 70 degree down and down-right cells the cutter `tools/art/cast_thug_pack.py` put the **claw tip** on the cell's foot
line, so the shoes sit 10-30 texels above it. The walk is safe (its anchors plant the measured shoe), but the attack, hit and
fall sheets stand on that foot line, so in those poses he may float above his shadow.

## Scope
1. **Measure first** (commit nothing yet): for every cell of `robot_thug_{armed_walk,attack,hit,fall}.png` at p70 and p55,
   the lowest shoe-sole row (claw cut out the way `tools/art/cast_thug_soles.py` does) against the cell's foot line; table
   it (sheet, pitch, facing, column, gap in texels). Bar: gap <= 2 texels on every standing cell (walk, attack, hit); the
   fall's resting cells lie on the ground (body bottom within 2 texels of the line).
2. **Fix the cutter**: a shoe-based foot line (claw excluded) for every sheet and pitch where a cell fails; re-pack only the
   failing sheets; key-clean 0/0 (alpha >= 128, 50-level green/magenta lead); strict red 0 outside the lens; stripe median
   unchanged within 1 degree; re-run `tools/art/cast_thug_provenance.py` lines for re-packed PNGs (append new lines, keep the old).
   If the walk sheets move, regenerate `cast_thug_anchors.gd` with `tools/art/cast_thug_soles.py` and re-run the feet audit
   (sole <= 2 px, body jump <= 12 px; quote before/after). One Godot `--import`, `node tools/tests/run_unit.mjs --changed`
   (quote the line), commit 1.
3. **Look in the game**: a 64 px/m still `thug_poses_64ppm_tilt70.png` (wind-up, lunge, snap, hit, fall rest, down-right,
   beside the rig patrol cop and Rivet, the card forced on only inside a dev scene `project/dev/cast/cast_thug_*`), and a
   32 px/m clip `thug_fight_32.mp4` (Rivet against three thugs, card forced on in the dev scene, 1920x1080, 60 fps, 15-40 s,
   tilt 70, `ffprobe`; the scratch-project path of `tools/film/cast_gunner_films.mjs`). Look at the still and at 10 frames of
   the clip (Read tool) and say per pose whether the shoes touch the shadow. The tell must show before the first harmful tick
   (`telegraph_s` 0.8), the hit holds 0.20 s, the fall reaches rest: quote the frame numbers. Append both to `frames.json`
   there (valid JSON array). Commit 2.

## Repo law (binding)
- Godot only through runGodot (`tools/dev/run.mjs`, film tools, gate, mutate); before it
  `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` and
  `export GODOT_BIN=C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe`; rendering gets
  `--rendering-driver d3d12`, windowed runs `--position 0,1440`.
- **Lane Godot lock** (shared): `until mkdir build/lane-godot.lock 2>/dev/null; do sleep 15; done` before any Godot launch,
  `rmdir build/lane-godot.lock` right after (also on failure); older than 25 min = stale, remove it.
- `mem-budget: waiting` = machine full: wait, do not kill. Kill only your own PIDs. Never delete anything you did not create.
- Typed GDScript, ~200 lines (hard 300), functions <= 40 lines, <= 5 params, `Log` not `print`.
- Stage per path, `git commit -- <your paths>`. Banned: `git add -A/./-u`, `commit -a`, `stash`, `reset --hard`, amend,
  rebase, branch switches, push. Never skip the hook (`kill_reel_*.break.test.mjs` red: import, commit again; only
  `step_guard.break.test.mjs` red: run it alone, if it passes commit again). Debt red: `node tools/debt/debt.mjs --update`
  (with `--accept-regression="robot_thug for n29 cast"` if it rises), include `tools/debt/baseline.json`.
- Fix lint and format findings in your own edit and go on. No image generation. Never fake a frame or a number.
- Commit messages end with `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/characters/art/view/{p70,p55}/robot_thug_*` (+ `.import`), `project/features/characters/cast_thug_anchors.gd`,
`tools/art/cast_thug_*.py`, new or existing `project/dev/cast/cast_thug_*`, new `tools/film/cast_thug_*.mjs`,
`steam/ai-provenance/2026-11.jsonl` (append), `evidence/n29/thug/**`, `tools/debt/baseline.json` (debt tool only),
`C:\Users\kazda\kiro\gtai-art\foes-n29\thug\**`, scratch `build/look/n29-thug/`, outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: `cast_cards.json` (the row stays off), `cast_card_kinds.gd`, `cast_cards.gd`, `foe_thug_card_view.gd` (report a NEED
if a fix needs them), `tools/art/cast_foe_*.py`, every `shield_robot_*`/`war_machine_*` file, `docs/**`, other lanes' files,
root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`.

## Report (then END)
Commits, the gap table before/after, key-clean / red / stripe numbers, feet audit before/after if the walk moved, the still
and clip paths + ffprobe, what you saw per pose, the tell/hit/fall frame numbers, the `run_unit --changed` line, NEEDs, what
you could not do.
