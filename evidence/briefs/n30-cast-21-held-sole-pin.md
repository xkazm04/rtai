# n30-cast-21: a held walk cell pins the planted SOLE, not the pivot (tag `c21`, model opus)

Read `evidence/briefs/_common.md` first: it binds. Then `build/look/n30-c20/NOTES.md` (c20's measurement: the gap 0, the
line that stays still inside a held drawing is the cell pivot y 168, not the sole 188.5, in all 8 takes) and
`docs/art/cast-audit.md` "## Door eight, p55 drawing 8, n30" (c19's law: in-hold slide = lean change x 20.5 / 2).
Launch time T. Door table by T+25. First commit by T+35. Hard stop T+50 and no later than 17:12 (report and END).

## The fault (c20, read the code yourself)
`project/features/combat/squad/foe_shield_card_view.gd` `update_fighter` (~line 59-69): `last_ground = position` before
`draw_pose`, then `position = last_ground` while the same walk cell is held. `StreetPatrolPose.pose()` leans a held drawing by
a shear about the REGISTERED sole (`- roll * ink.y` in the origin); resetting `position` throws that correction away, so the
drawing leans about its pivot and the planted sole slides. `foe_war_card_view.gd` (~line 79-82, `hold_foot`) has the same pin.

## Do
1. Door (part 1): on a held walk cell, keep the planted SOLE's screen point fixed instead of the node position: e.g. take the
   sole's global point before `draw_pose` (from the drawn cell's anchor `ink.x, ink.y` through the current transform) and
   after, and shift `position` by the difference. Smallest change; keep functions <= 40 lines, file size near today's.
   Lane lock; `node tools/film/cast_door_films.mjs build/look/n30-c21/feet feet`. Table four / eight before (6ee306fd8:
   p70 R four 2.42/4.34 eight 1.96/6.61, p70 DR four U/10.50 eight 1.39/12.00, p55 R four 2.03/5.09 eight 2.05/6.98, p55 DR
   four U/10.43 eight 2.08/11.78) / after, sole and jump. Measure BEFORE committing.
2. Commit the door fix only if neither the four nor the eight gets worse on any bar it fails or newly fails one (jump
   included). `run_unit --select=test_cast_door_walk,test_cast_foe_walks` green; `node tools/gate/quick.mjs`; a 64 px/m
   still of the four (it is what ships) before | after (film tool `stills`) to masters `door_sole_pin_64.png` and LOOK at it.
   Commit: `cast: door card pins the planted sole on a held walk drawing (not the pivot)`. Then, in a SEPARATE commit, only if
   the eight now passes both bars in every facing or beats the four everywhere: `CastDoorAnchors.WALK = EIGHT` (generator `--walk`).
3. Pile-driver (part 2, only if part 1 is committed by T+35): the same fix in `foe_war_card_view.gd`; measure with
   `node tools/film/cast_war_films.mjs build/look/n30-c21/war feet four,eight` against the cast-audit "Pile-driver, n30" Part A
   numbers (eight sole 18.16 / 27.45 / 20.91 / 23.86, jump 10.73 / 10.37 / 10.74 / 9.93). Same commit rule.
4. Mutate the changed lines (`--max=6 --lines=<changed> --tests=test_cast_door_walk,test_cast_foe_walks`), quote the score.
5. Append "## Held walk cell pins the sole, n30" (the fault, the table, the verdict) to `docs/art/cast-audit.md`; commit.
   Do NOT write decisions.md (the director does). frames.json is at its cap 15: replace `door8_edits_64.png`'s entry with
   `door_sole_pin_64.png`.

## Allowlist
`project/features/combat/squad/foe_shield_card_view.gd`, `project/features/combat/squad/foe_war_card_view.gd`,
`project/features/characters/cast_door_anchors.gd` (generated, only for WALK), `tools/art/cast_door_soles.py` (only `--walk`),
`project/tests/unit/test_cast_door*.gd`, `test_cast_foe_walks.gd`, `test_cast_war*.gd` (only to pin the new behaviour),
`docs/art/cast-audit.md` (append), `build/look/n30-c21/**`, masters files. NOT `street_patrol_pose.gd`. Anything else: NEED.

## Report
The fix (diff summary), the tables, the verdicts, commits, mutate score, every command's result line.
