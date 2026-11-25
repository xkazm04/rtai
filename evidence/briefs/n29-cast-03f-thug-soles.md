# Brief n29-cast-03f: robot thug A, the soles at the stop (70 deg), then 55 + walk feet re-checks

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 06:50 local** (check `date +%H:%M` often). **Commit 1 by 06:35, your last commit by 06:45** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.

## Read first
`evidence/n29/thug/fixes.md` (the plan, sections "Fix for the next call" and "Fail 2 ... (06:03)"), commit `839ce02d8`
(ring on the ground point: `FoeThugCardView.ground_local`), `project/features/combat/squad/foe_thug_card_view.gd`,
`project/features/characters/cast_thug_anchors.gd`, `project/dev/cast/cast_thug_beside.gd`,
`evidence/briefs/n29-cast-03d-thug-checklist.md` (its repo law binds you).

## The open point
Standing after a walk-in at 70 deg, facing down, the thug's soles sit about **4 px above the ground row at 64 px/m**
(lowest foot outline ~row 535 vs ring centre 540 in `build/look/n29-thug/shadow70/crop64.png`). **Bar: soles within 2 px of
the ground row at 64 px/m**, both pitches, facing down, down-right and right.
1. Measure first (one Godot run): sole row vs ground row for a standing 70 thug facing down / dr / right after a walk-in,
   and the same at 55. Write the numbers to `fixes.md`.
2. If > 2 px: the smallest fix in `_hold_stop` (or the stand placement): shift the held `_planted.origin.y` by the stand
   cell's sole gap derived from `CastThugAnchors` (never hard-coded px). Unit test in `test_cast_thug*.gd`: after a walk and
   a stop at 70, the stand cell's sole point in world space is within 1 px (64 px/m) of `h.pos * PX_PER_M`; it must fail
   without the fix. `run_unit --changed` (quote). Commit 1.
3. Re-measure after at both pitches, 64 and 32 px/m (delivered beside frames, `GTAI_CAST_SHADOW=1` if useful), and the walk
   feet: `GTAI_CAST_PREVIEW=robot_thug node tools/art/cast_feet.mjs build/look/n29-thug/feet32 32 robot_thug`
   (sole <= 2, jump <= 12 must hold). The ring must stay on the ground point (centroid within 2 px of the row).
   Save a 64 px/m stop crop to `C:\Users\kazda\kiro\gtai-masters\n29\cast\thug_stop_after_64.png` (soles + ring, ground row
   marked) and LOOK at it. Append numbers to `fixes.md`, commit 2.

The row stays `enabled: false`: the director orders the switch after your numbers.

## Repo law
runGodot only (`tools/dev/run.mjs`, the film tools); `export APPDATA=C:/Users/kazda/kiro/gtai-n29/appdata/cast` before every
Godot run; `GODOT_BIN=C:\Users\kazda\kiro\gtai-spike\tools\godot\Godot_v4.7.2-stable_win64_console.exe`; one Godot at a
time in this lane (the lane lock `build/lane-godot.lock`, wait for it, another builder shares it); a `mem-budget: waiting`
line means the machine is full, wait. Typed GDScript, files ~200 lines (hard 300), functions <= 40 lines, <= 5 params,
`Log` not print. Stage per path, commit with `git commit -- <your paths>` only (another builder works beside you).
Banned: `git add -A/./-u`, `commit -a`, stash, amend, rebase, reset. Pre-commit hook: if `step_guard.break.test.mjs` or a
`kill_reel_*.break.test.mjs` fails, run it alone / run a Godot `--import`, then commit again; never skip the hook. Debt red:
`node tools/debt/debt.mjs --update --accept-regression="thug stop for n29 cast"`. Fix lint and format findings in your own
edit and go on. No image generation. Never fake a number.
Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/features/combat/squad/foe_thug_card_view.gd`, `project/features/characters/cast_thug_anchors.gd` (only if needed),
`project/dev/cast/cast_thug_*` (+ `.uid`), `project/tests/unit/test_cast_thug*.gd` (+ `.uid`), `evidence/n29/thug/**`,
`tools/debt/baseline.json` (debt tool only), scratch `build/look/n29-thug/soles/`, the one still in
`C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: `cast_cards.json`, `robot_thug_*.png`, every `war_machine_*` / `cast_war_*` / `foe_war_card_view.gd` /
`cast_feet.gd` / `shield_robot_*` / `cast_door_*` file, `docs/**`, root `JOURNAL.md`, `REPORT.md`, `evidence/briefs/**`,
other lanes' files. The opus war builder works beside you until 07:10 on the war files: never stage or revert them.

## Report (then END)
Commits, sole-vs-row before/after (70 and 55, 64 and 32, three facings), the fix in two lines, the test (fails without),
ring centroid after, walk feet after, `run_unit --changed` line, NEEDs, what you could not do.
