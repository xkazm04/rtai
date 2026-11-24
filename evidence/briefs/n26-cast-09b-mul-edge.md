# Brief n26-cast-09b-mul-edge (follow-up to mul-fix): clean the cut edge of Mulroney's hit (and any other ragged sheet)

Same lane, branch, worktree, env and law as your mul-fix brief.
**Hard stop 15:58 local** (check `date`). **Commit deadline 15:45.** Keep it small: one fix, one still, your report.

## The fault (director's look at your `gtai-masters/n26/cast/mulroney_hit_shadow_64.png`)
The wound contact is fixed: thank you. But the HIT cells, before and after, both pitches, have a ragged, spiky BLACK outline at
64 px/m: dark fringe teeth around the whole silhouette. His walk cut is clean. The owner's rule is "clean cut", so the card
cannot ship with it.

## Fault 0 first (yours, from your report): the 30.49 px torso jump on the backward step
In `mulroney_fight_32.mp4` frames 290 -> 291 his torso jumps 30.49 px at 32 px/m (limit 12). The card is committed ON with an
audit that says PASS: that is a half character in the game. Diagnose it (anchored placement re-phasing on a direction reversal?
a drawing-index jump when the gait flips? a hit/pump/walk host switch?) and fix it in the placement, not by changing behaviour,
speed or timing. Check whether the patrol cop (cop8, same mechanism) has the same reversal jump; if yes fix it there the same way.
Add a unit test that drives a reversal and asserts the body jump <= 12 px. Re-measure the fight film's worst body jump.
**Rule: if by 15:45 the jump is not measured <= 12 px, commit `sergeant_mulroney` `enabled: false` in `cast_cards.json` and
correct his audit row to Feet FAIL (reversal 30.49 px) instead.** Either way the audit row must say what is true.

## Then the edge
1. Find the cause in the cut of `project/features/characters/art/view/{p70,p55}/sergeant_mulroney_hit.png` (likely a dark
   outline/halo left by the green key, or no defringe/erode step that the walk cut had). Re-cut the hit sheets with the SAME edge
   treatment as `sergeant_mulroney_planted8_armed_walk.png` (key spill removed, alpha edge eroded/defringed, no dark teeth),
   keeping scale, anchors and cell layout identical so the grounded wound you just fixed does not move.
2. Check his other sheets for the same teeth (attack/pump, fall, shotgun) at 64 px/m, both pitches; re-cut only those that show
   them, same way. Name each sheet you checked and the verdict.
3. A measurable check: count edge pixels whose luminance is far below the interior's neighbours (or whatever you used); quote it
   before/after per re-cut sheet. If the cast checklist's cut row has a tool, run it; else add the measure to `tools/art/`.
4. `--import`, provenance line per re-cut PNG (append), `node tools/gate/quick.mjs`, one commit
   (`cast: clean Mulroney's hit cut edge`).
5. Still: `C:\Users\kazda\kiro\gtai-masters\n26\cast\mulroney_hit_edge_64.png` (before left / after right, hit cells, 70 and 55,
   64 px/m, on the street ground). Look at it yourself.

Owned: `project/features/characters/street_*.gd`, `cast_*.gd`, `project/features/combat/squad/foe_*.gd` (placement only), `project/data/tables/cast_cards.json`, `project/dev/cast/**`, `project/tests/unit/test_cast_*.gd` (+ `.uid`), Mulroney.s sheets `project/features/characters/art/view/{p70,p55}/sergeant_mulroney_*`, `tools/art/**`,
`C:\Users\kazda\kiro\gtai-art\foes-n26\mulroney*\**`, `docs/art/cast-audit.md` (his row), `steam/ai-provenance/2026-11.jsonl`
(append). Anything else: stop and report a NEED. No amend, no rebase. Fix lint and format findings in your own edit and go on.

Report: the reversal cause + fix + worst body jump before/after, commit shas, sheets checked + verdicts, the edge numbers, the still path.
