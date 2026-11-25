# Builder n31-melee-04c (sonnet, ~25 min): the blade marks must read at 32 px/m

Read `evidence/briefs/n31-common.md` (binding). Tag `04c`. Launched 00:36: commit by 00:52 (session dies 00:57), END 00:54. If the stills are not done by 00:50, commit the data change with the stills you have and say so. Files:
`project/data/tables/melee_marks.json` (katana, plasma_sword, chainsaw rows), `project/features/combat/react/
blade_marks.gd`/`claw_marks.gd` (only if a torso lift is needed), `project/dev/melee_n31/marks_still*`, tests.
State (04b, commits ca7009066 adb92f40b c75b4b3bc): marks draw at `f.pos + ShotLift.up_m()` (gun height); widths
`edge_px`/`core_px` are effect-layer px at 48 px/m (x zoom/48 on screen): katana 5/2, plasma 6/3.5, saw 5/2,
`cut_m` 0.75. Director looked at the 64 px/m stills: a thin line across the shield, reads as a scratch, not a cut.
Do: edge/core ~9/4 (plasma 10/5 with a visibly hot core), `cut_m` 1.0 for katana/plasma, saw starburst x1.5;
lift to the torso only if the gun-height line misses his body in the still. Bar: >= 4 px of ink at 32 px/m, the mark
visibly crosses the victim's body. Stills at 32 AND 64 px/m (marks_still) to
`evidence/n31-melee/04-impacts/after/` BEFORE the commit; Read them and say what you see. Run
`--select=test_blade_marks,test_claw_marks`. View only (no digest moves). One decisions line with before/after widths.
