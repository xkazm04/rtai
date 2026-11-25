# n30-cast-20: door anchors, the sole y on the boot bottom (tag `c20`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `docs/art/cast-audit.md` "## Door eight, p55 drawing 8, n30" (c19's
computation) and `C:\Users\kazda\kiro\gtai-art\foes-n30\door8f\STATE.md`. No images in this call.
Launch time T. Measurement table by T+25. Commit by T+40. Hard stop T+50 and no later than 17:12 (report and END).

## The hypothesis (the director's, NOT measured)
`StreetPatrolPose.pose()` (`project/features/characters/street_patrol_pose.gd`, ~line 78) leans a held drawing by a shear
(`basis_y + roll`, origin `- roll * ink.y`): the point at the REGISTERED sole height `ink.y` (`CastDoorAnchors` `Vector4(sole x,
sole y, body x, body y)`) stays put while the lean changes. c19 found the remaining in-hold slide = lean change x the boot's
depth below that height / 2 (p55 right drawing 8: 0.200 x 20.5 / 2 = 2.05, measured 2.04). So if `cast_door_soles.py` wrote
the sole y where the feet reader (`tools/art/cast_door_feet.py`) takes the boot's contact, the in-hold slide should vanish
in every facing, for the four and the eight alike.

## Do
1. Read both tools: what y each takes for the sole (centroid of the lowest band? bottom row?). Write the gap per drawing for
   p55 right and down-right into `build/look/n30-c20/NOTES.md`. If they already agree (gap < 2 sheet px), the hypothesis is
   wrong: write the audit section saying so, commit it, report, END.
2. Change `cast_door_soles.py` (a named option, e.g. `--sole-y=contact`, default unchanged first) so the anchors' sole y
   is the reader's contact y. Regenerate to a SCRATCH copy, stage it in the film tool's staged copy if the tool allows, or
   regenerate in the tree and be ready to `git checkout -- project/features/characters/cast_door_anchors.gd`.
   Lane lock; `node tools/film/cast_door_films.mjs build/look/n30-c20/feet feet` (four and eight, all four facings).
   Table: four now / four contact-y / eight now (6ee306fd8) / eight contact-y, sole and jump.
3. Commit rules: ship the contact-y anchors (generator default switched, anchors regenerated) only if the FOUR gets no
   worse in any facing (it is what ships) and at least one number improves; `run_unit --select=test_cast_door_walk` and
   `test_cast_foe_walks` green first; `node tools/gate/quick.mjs`. `WALK = EIGHT` in a separate commit only if the eight
   then beats the four in every facing (sole and jump <= the four's, or both within sole <= 2, jump <= 12), with a 64 px/m
   still `door8_eight_64.png` (film tool `stills`) and a 32 px/m clip if time remains (masters frames.json is at its cap 15:
   replace `door8_edits_64.png`'s entry). If the four gets worse anywhere: revert the anchors, commit nothing but the audit.
   Mutate (if the generator default changed): not needed for a Python tool; say so.
4. Append "## Door anchors, sole y on the boot contact, n30" (the gap, the table, the verdict) to `docs/art/cast-audit.md`,
   commit (pathspec).

## Allowlist
`tools/art/cast_door_soles.py`, `project/features/characters/cast_door_anchors.gd` (generated), `project/tests/unit/test_cast_door*.gd`
(only values that follow the anchors), `tools/film/cast_door_films.mjs` (staging only), `docs/art/cast-audit.md` (append),
`build/look/n30-c20/**`, masters files. NOT `street_patrol_pose.gd` (shared by every foe walk). Anything else: NEED.

## Report
The gap per drawing, the table, the verdict, commits, every command's result line.
