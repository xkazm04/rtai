# JOURNAL: d7-calls (day run 2026-11-05)

## Iteration 2 (BUILD, 15:12-16:12)
- 15:12 Started. No JOURNAL from iteration 1 and no commits past main 1028c15d: starting fresh. Worktree was not
  imported; first `--import` run (evidence/import-it2.log).
- Registry rules applied (generated-asset-world-scale): sprites draw at true scale (size_m = px / 120); a size change
  re-captures the quest 1 sprites rather than a draw_k fudge.
- 15:14 MILESTONE cast-1 16272697: `RivetPlan.FORMS[FORM_BASE].x` 0.97 -> 0.89 (1.1x the crowd span). The old size is
  the new row `FORM_WIDE` (0.97, same arms and legs); back = FORM_BASE.x 0.89 -> 0.97. Ghost plans that hang off
  FORM_BASE (DentPlan, HaulerLook's base) follow; the Hauler tank keeps its absolute size (BODY_SIZE_K 1.2).
- REQUEST held: cast-1 landed at 16272697 (`project/features/characters/rivet_plan.gd` only). Held guns follow
  plan.size_k (`rivet_arsenal.json held_size_ref` 1.2), so guns now draw 0.74x the class held_scale (was 0.81x).
  File split for look-8 (my item 4): I touch `print_part.gdshader`, `part_materials.gd` (the ink / print) and
  `look_d5_part.gdshader`; you own the poses, the held parts, `rivet_arsenal.json` sizes and the cut_rig hold code.
  Tell me in your JOURNAL if you need any of mine.
- 15:21 DECISION cast-8 + cast-9 together: the plain head keeps the core tan (HEAD fill 2 = the core sticker with
  `core_tan`), exactly n5-cast's Call 9 A state (torso, pelvis and helmet at tan 0.6). The owner's "plain cream head"
  reads as "no visor"; a cream head on a tan torso would be a third look nobody judged.
- 15:22 MILESTONE 66bf4fbe cast-8 (HEAD_LOD_FILL 4 -> 2) + cast-9 (CORE_TAN 1.0 -> 0.6), quest 1 sprites re-captured
  at the new size (peek r 50 -> 46 px with the body), CastFlags `--rivet-form=wide --rivet-visor --rivet-tan=1` =
  the old defaults in every rig path (unit test_cast_flags). Evidence `M/frames/cast-1-8-9-city-ab-32-48ppm.png`
  (same tick 420, city block, flags vs none): 32 px/m shows all three; 48 px/m only the size (art tier above
  ~42 px/m, so the head and tone calls do not show there; the brief's "48 px/m for the head and tone" cannot show them).
- FINDING: with cast-1 the pistol in Rivet's claw looks long against his smaller body at 32 px/m (held guns follow
  size_k: 0.74x). The held lane owns held sizes; noted for them.
- FRICTION: `node tools/evidence/run.mjs` refuses a dirty tree (untracked JOURNAL) -> `--allow-dirty`.
