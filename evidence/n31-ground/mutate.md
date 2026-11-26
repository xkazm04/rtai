# n31-20 mutate scores (HEAD e7939560, tests only, no game code changed)

## rivet_bob.gd (72703154f lines, 20 of 39 mutants sampled)
`node tools/mutate/mutate.mjs --file=features/characters/rivet_bob.gd --max=20 --tests=test_rivet_bob --lines=4-10,19-52,56,60,67,70-71,73-74,77-84,93-95`

score 52.6% = killed 10 / (killed 10 + survived 9); timeout 0, invalid 1; 728 s

Survivors: :19 `_stretch_min` default 1.0->0.0, :21 `_lift_max_cell` default 0.0->1.0 (static defaults overwritten by `_load`,
equivalent unless the table is missing), :35 literal 1.0->0.0, :36 `*`->`/`, :42 literal 0.0->1.0, :50 `>`->`>=`
(boundary, equivalent at lo == hi), :52 `/`->`*`, :73 `not` removed, :79 `/`->`*`. Invalid: :81 `+`->`-`.
Not pinned by a new test this call (out of time): the :35/:36/:52 aim and damping arithmetic is the candidate for a pinning assertion.

## rig_cast_shadows.gd (2f143d1e1, 12 of 125 mutants sampled, whole file, no --lines)
`node tools/mutate/mutate.mjs --file=features/characters/rig_cast_shadows.gd --max=12 --tests=test_rig_cast_shadows`

score 50.0% = killed 6 / (killed 6 + survived 6); timeout 0, invalid 0; 276 s

Survivors: :51 `<=`->`<`, :83 `*`->`/`, :120 `*`->`/`, :128 `*`->`/`, :186 `<`->`<=`, :196 `or`->`and`.
No pinning test added (out of time); the :120/:128 scale products are the candidates for the shadow-lift assertions.

## n31-33 owed scores (HEAD d75fbfc35, tests only)

All three runs `--max=12`, one at a time under lane lock `n31-33`; tests are the unit files that reach the class (no unit test names `PropBase`, so the paint/footprint/dressing tests that draw it were used).

### prop_base.gd (`project/features/gauntlet/prop_base.gd`, whole file, 12 of 17 mutants)
`node tools/mutate/mutate.mjs --file=features/gauntlet/prop_base.gd --max=12 --tests=test_prologue_yard_paint,test_prologue_yard_footprints,test_gauntlet_dressing`

score 0.0% = killed 0 / (killed 0 + survived 12); timeout 0, invalid 0; 297 s

Survivors (all 12): :18 `*`->`/`, :18 `0.5`->`1.5` (half-rim), :20 `<=`->`>` (twice), :20 `<=`->`<`, :20 `0.0`->`1.0` (twice), :20 `or`->`and`
(degenerate-inner guard), :22 `*`->`/` (north alpha), :31 `4`->`5`, :32 `4`->`5` (corner loop), :36 `0.0`->`1.0` (rim fade alpha).
Cause: `draw` only issues `RenderingServer.canvas_item_add_polygon` commands; no test inspects them or reads pixels.
Candidate for a pinning assertion: a recording CanvasItem / pixel read of one footprint checking south-edge alpha == TINT.a, north == TINT.a * NORTH_SHARE, outer rim alpha 0, and the degenerate (tiny box) path.

### street_patrol_pose.gd (`project/features/characters/street_patrol_pose.gd`, tonight's hunks, 12 of 43 mutants)
`node tools/mutate/mutate.mjs --file=features/characters/street_patrol_pose.gd --max=12 --tests=test_cast_door_walk,test_cast_foe_walks,test_cast_patrol_feet,test_street_cop_walk --lines=7-36,45,54-55,86-88,102,133,137,141-163,177-179,185-189`

score 75.0% = killed 9 / (killed 9 + survived 3); timeout 0, invalid 0; 256 s

Survivors: :137 `+`->`-`, :155 `*`->`/`, :177 `and`->`or` (settle gate).
Candidate for a pinning assertion: the :155 glide-blend product (GLIDE_SHARE at 0.5 vs 1.0 stand point) and the :177 settle `continuous` gate.

### print_stage.gd (`project/core/render/print_stage.gd`, tonight's hunks, 12 of 15 mutants)
`node tools/mutate/mutate.mjs --file=core/render/print_stage.gd --max=12 --tests=test_print_stage,test_print_stage_light_tick,test_view_mode --lines=58,89,98-100,105-107,112,147-159,178`

score 75.0% = killed 9 / (killed 9 + survived 3); timeout 0, invalid 0; 301 s

Survivors: :99 `+`->`-`, :152 `*`->`/` (one of two on the line), :159 `*`->`/` (one of two on the line).
Candidate for a pinning assertion: the render-px lock at a stretch other than 1 and a non-zero origin (:152/:159 scale terms; :99 offset sign).

Temp: `ls $LOCALAPPDATA/Temp | grep gtai-mutate` showed 4 dirs before and after (49b1f428, 612737eb, 7c7d36ab, dc83624c); the tool reused dc83624c (not mine). This lane created none.
