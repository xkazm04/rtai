# n30-cast-06b: the warden's size at death, measured in delivered frames ONLY (tag `c06b`, model opus)

Read `evidence/briefs/_common.md` first: it binds (TAKE THE LANE LOCK before every Godot-launching command: c06 did not).
Hard stop: launch + 40 min. One point: MEASURE. No art change in this call.

## What is known
- Combat (READ ONLY `C:\Users\kazda\kiro\gtai-wt\n23-street\evidence\n30\kills\card_fall.md` lines 78-99): in the KILL path
  (`KillCardFall` routes `sheets.fall`, first drawn row 0 "buckle") the warden's cap reads ~22 px on the walk, ~33 on fall row 0, 64 px/m.
- c06 (`build/look/n30-c06/`, probe patch `warden_probe.patch`, rows `m/before{70,55}_row.png`): in cast's LIVING death
  (`project/dev/cast/cast_warden_fight.gd`) he goes walk -> hit/0 (4 ticks) -> fall row 1; row 0 never shows. Delivered:
  p70 cap walk ~35 / hit ~20, p55 30 / 21 (by eye). The walk is drawn from a steeper angle (big cap, short body) than hit/fall.
  The two readings disagree on the walk cap (22 vs 35): one of them measured wrong.

## Do
1. Apply the probe as a NEW dev script `project/dev/cast/cast_warden_probe.gd` (+ `.uid`) rather than growing
   `cast_warden_fight.gd` (debt ratchet), or keep it uncommitted under build/ if a run without commit suffices.
2. Get delivered frames at 64 px/m, both pitches, of: last walk frame, hit/0, fall row 0 (force the kill path's first row:
   hold the row through a whole frame; c06 found a one-tick set is reset before the draw), fall row 1.
3. Measure each with ONE method for all (alpha mask of the card drawn vs hidden; cap = the widest run of cap-coloured px in
   the top 20 % of the head blob, pole masked by its thin-ness): cap width, head blob height, figure height, feet y. Table.
4. Verdict: which sheet is off against the walk and by what factor per pitch (k = walk / sheet on the cap), or "angle, not
   scale" if cap matches but body differs. Save `C:\Users\kazda\kiro\gtai-masters\n30\cast\warden_switch_64.png` (the four
   frames side by side per pitch). LOOK at it. Commit the probe script only if lint passes (pathspec).

## Allowlist
`project/dev/cast/cast_warden_probe.gd` (+uid), `build/look/n30-c06b/**`, the masters still. Anything else: NEED.

## Report
The table, the verdict with k per pitch and per sheet, still path and what you saw, commit (if any).
