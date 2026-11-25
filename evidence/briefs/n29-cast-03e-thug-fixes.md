# Brief n29-cast-03e: robot thug A, the two failing checklist points (size at 55, the stop at 70), then the switch call

Lane `cast`, worktree `C:\Users\kazda\kiro\gtai-wt\n23-prologue` (your cwd), branch `n29-cast`. You are a builder sub-agent.
**Hard stop 06:15 local** (check `date +%H:%M` often). **Commit 1 by 06:02, your last commit by 06:08** (hook ~12 min).
Never end with finished work uncommitted. Then report and END.

## Read first
`evidence/n29/thug/feet_size.md`, `footline.md`, `checklist_b.md` (commit `c8b794054`), `evidence/briefs/n29-cast-03d-thug-checklist.md`
(its repo law binds you), `project/features/combat/squad/foe_thug_card_view.gd`, `project/dev/cast/cast_thug_beside.gd`.

## The two fails (03d-B, 05:47)
1. **Size at 55, 64 px/m**: thug 151, Rivet 150 (1.007; bar 0.90-1.00 of Rivet, never taller). At 70 he is 144/154 = 0.935.
   Director's call: `robot_thug.body_scale` 1.45 -> **1.42** in `project/data/tables/cast_cards.json` (one value; expected
   70: ~141/154 = 0.92, 55: ~148/150 = 0.99). Re-measure both pitches at 64 and 32 px/m in the beside scene (delivered frames),
   and the drawings/s (the walk step scales with body_scale: say the new value, bar 5-10). If 55 is still > 1.00, take 1.40.
2. **Stop placement at 70**: standing after a walk-in, facing down, his soles sit 10-11 px (32 px/m) above the shadow centre;
   the shadow centre is 12 px (32) / 25 px (64) below the ground row, soles 4 px above the row at 64 px/m (bar: soles within
   2 px of the ground row at 64 px/m). 55 passes. Suspected: the contact ring `FoeThugCardView._shadow` sits at the card's
   origin, which at 70 is not under the soles. Find the cause first (print the ground row, the ring centre and the sole row
   for a standing 70 down / down-right / right thug), then the smallest fix in `foe_thug_card_view.gd` (ring offset and/or the
   standing cell's anchor). Re-measure the stop at both pitches, walk feet re-run (`GTAI_CAST_PREVIEW=robot_thug node
   tools/art/cast_feet.mjs build/look/n29-thug/feet32 32 robot_thug`: sole <= 2, jump <= 12 must still hold).
Unit test for the fix (ring/sole offset at 70), `run_unit --changed` (quote). Commit 1 = size, commit 2 = stop.

The row stays `enabled: false`: the director switches it on after reading your numbers (PART A ink/rim runs beside you).

## Repo law
As in `evidence/briefs/n29-cast-03d-thug-checklist.md` (runGodot, APPDATA, GODOT_BIN, lane Godot lock, mem-budget, typed
GDScript, pathspec commits, banned git commands, hook flakes, debt tool, no image generation, never fake a number).
Commit messages end with `Co-Authored-By: Claude Sonnet 5.5 <noreply@anthropic.com>`.

## Allowlist (any other path: stop and report a NEED)
`project/data/tables/cast_cards.json` (the `robot_thug` row's `body_scale` only), `project/features/combat/squad/foe_thug_card_view.gd`,
`project/features/characters/cast_thug_anchors.gd` (only if the stop fix needs it), `project/dev/cast/cast_thug_*`,
`project/tests/unit/test_cast_thug*.gd` (+ `.uid`), `evidence/n29/thug/**` (new `fixes.md`), `tools/debt/baseline.json`
(debt tool only), scratch `build/look/n29-thug/fix/`, outputs in `C:\Users\kazda\kiro\gtai-masters\n29\cast\`.
Forbidden: every other row of `cast_cards.json`, `robot_thug_*.png`, `tools/art/**` (PART A's), every `shield_robot_*` /
`war_machine_*` / `cast_war_*` / `cast_door_*` file, `foe_war_card_view.gd`, `docs/**`, root `JOURNAL.md`, `REPORT.md`,
`evidence/briefs/**`, other lanes' files.

## Report (then END)
Commits, sizes before/after (both pitches, 64 and 32), drawings/s, the stop cause and the fix in two lines, stop numbers
before/after, walk feet after, the test, `run_unit --changed` line, NEEDs, what you could not do.

## Added 05:51 (director): this call is short
Do fail 1 (size) and commit it by 06:02. Then start fail 2: find and write down the cause in `evidence/n29/thug/fixes.md`
(commit that file by 06:08 even if the fix is not done); a later call makes the fix from your notes. The opus war builder
runs beside you until 06:14 (`foe_war_card_view.gd`, `cast_war_*`, `test_cast_war_machine.gd`): never stage or revert them.
