# Robot thug A, 03e fixes (05:49 to 06:08)

## Fail 1, size at 55: fixed (commit d9bfe36a7)

`robot_thug.body_scale` 1.45 -> 1.42 in `project/data/tables/cast_cards.json` (row still `enabled: false`).
Delivered beside frames (`cast_thug_beside`, silhouette heights from `tools/art/cast_size_measure.py`,
spawned rig patrol cop and Rivet in the same frame):

| Pitch, px/m | thug before | thug after | Rivet | after / Rivet | bar 0.90-1.00 |
|---|---|---|---|---|---|
| 70, 64 | 144 | 141 | 154 | 0.916 | PASS |
| 70, 32 | 72 | 70 | 77 | 0.909 | PASS |
| 55, 64 | 151 | 147 | 150 | 0.980 | PASS (was 1.007) |
| 55, 32 | 75 | 73 | 75 | 0.973 | PASS (was 1.000) |

Frames: `build/look/n29-thug/size/` and `size55/` (the 55 thug band is flagged BAND-EDGE by the measure tool
at both ppm: his rows touch the band edge 393/467, so the 147/73 may be 1 px off; still under Rivet by 3 / 2 px).
1.40 was not needed. Drawings per second: the walk step scales with body_scale, so it is 8.44 observed at 1.45
and **about 8.6 at 1.42 (computed 8.45 x 1.45 / 1.42, NOT re-observed)**, bar 5-10. Unit tests
`test_cast_cards` + `test_cast_thug`: 13 passed (no test hard-codes 1.45).

## Fail 2, stop at 70: cause (read from the code, NOT yet verified by printing the three numbers)

Ring: `FoeThugCardView._init` adds `_shadow` (the contact rings) as a child of the card Sprite2D at local
`Vector2.ZERO`; `update_fighter` only cancels the card's scale. So the rings sit at the card's **transform origin**.

Origin is not the ground point. While moving, `CastFarCard._place` takes
`StreetCopWalk.Contact.place` -> `StreetPatrolPose.pose` / `settle` (`project/features/characters/street_patrol_pose.gd`
lines 60-123), which solves the transform so the **torso mark** `marks[face*count+row].zw` (the generated
`CastThugAnchors` Vector4 z,w; w about -130 to -139 at 70) lands on the body point, rolled about the load-bearing
sole. The origin then lies `torso * texel` away from the ground point (about 130 texel rows, scaled), i.e. well
below `h.pos` at 70, where the cell is tall and the torso mark sits high. At 55 the torso mark is
within a few px of the foot line, which is why 55 passes (shadow centroid 539.1 / 538.7 vs soles 539).
`_hold_stop` then stores that transform (`_planted`) and restores it on a halt, so the rings stay at
the planted origin, 12 px (32 px/m) / 25 px (64 px/m) below the ground row. The soles themselves are 4 px above
the row at 64 px/m, because the planted pose is solved on the torso/sole mark, not on the ground row.

## Fix for the next call (smallest, in `foe_thug_card_view.gd` only)

1. Ring on the ground point, not the origin: in `update_fighter`, after `draw_pose` and `_hold_stop`, set
   `_shadow.position = transform.affine_inverse() * (h.pos * SimConst.PX_PER_M)` (the card's `transform` is in
   its parent's space, the same space as `h.pos * PX_PER_M`; `_shadow.scale` stays `ONE / transform.get_scale()`;
   a flip_h card has a negative x scale, the inverse handles it, check the ring is not mirrored in y).
   This also keeps the rings under a walking thug.
2. Soles: after (1) the soles are still about 4 px (64 px/m) above the row at 70 (bar: within 2). If it is
   still more than 2, in `_hold_stop` shift the held `_planted.origin.y` by the measured gap
   (about `4 / 64 m`, derive it from the stand cell's lowest sole row via `CastThugAnchors`, do not hard-code px).
3. Verify first: print `h.pos * PX_PER_M`, `to_global(_shadow.position)` and the sole row for a standing 70 thug
   facing down, down-right, right (expect the ring 25 px below the row at 64 now); re-measure with
   `GTAI_CAST_SHADOW=1` beside run (shadow centroid vs soles) at 32 and 64; re-run
   `GTAI_CAST_PREVIEW=robot_thug node tools/art/cast_feet.mjs build/look/n29-thug/feet32 32 robot_thug`
   (sole <= 2, jump <= 12 must hold, the walk's jump measure includes the planted-row hold).
4. Unit test (`test_cast_thug.gd`): drive `update_fighter` with a standing fighter after a walk at 70, assert
   `to_global(_shadow.position)` within 1 px of `h.pos * PX_PER_M`.

## Fail 2, stop at 70: cause confirmed, ring fixed (06:03)

Confirmed by a unit test run without the fix: after a walk and a halt at 70, the ring child sat
**17.3 px** (world px, the test's walk of 0.1 m steps, facing down) from `h.pos * PX_PER_M`
(`test_thug_rings_sit_on_the_ground_point_after_a_walk_and_a_stop` failed with that number, passes with the fix).
So the cause is the ring child at the card's transform origin, not the ground point. (The three-direction print
was not done: one direction only, facing down.)

Fix (`project/features/combat/squad/foe_thug_card_view.gd`): `ground_local(h)` =
`transform.affine_inverse() * (h.pos * PX_PER_M)`, assigned to `_shadow.position` in `update_fighter` after
`draw_pose` and `_hold_stop` (the stop's restored `_planted` transform is inverted too).

Stop numbers after, `GTAI_CAST_SHADOW=1` beside at 70 (`build/look/n29-thug/shadow70/`, thug band only, shadow =
pixels that change when the rings are hidden): 64 px/m rows 522-558, centroid y 542.0; 32 px/m rows 531-548,
centroid y 540.7. The ground point is screen row about 540 (camera centre); before the fix the ring was
about 25 px (64) / 12 px (32) below it. Ring now on the ground point: PASS.

NOT done / still open: (a) soles about 4 px above the ground row at 64 px/m in the crop (`crop64.png`, lowest foot
outline about row 535 vs ring centre 540); bar is within 2. Fix plan unchanged (shift `_planted.origin.y` in
`_hold_stop` by the stand cell's sole gap from `CastThugAnchors`), not attempted for time. (b) 55 deg numbers
after the change not re-measured (the fix is pitch-independent; 55 passed before because origin ~ ground).
(c) walk feet (`cast_feet.mjs`) not re-run; the ring change does not touch the body transform.

## Soles at the stop (06:21)

Measured by the unit test (registered sole mark `CastThugAnchors` x,y through the held card transform, facing down,
70 deg, after a 6-step walk and a halt, world px at 64 px/m): sole row **2.82 px above** `h.pos.y * PX_PER_M` without the fix
(the crop outline read about 4 px, anti-aliased edge). Fix in `FoeThugCardView._hold_stop`: on a halt the held `_planted`
origin.y shifts by `sole_gap(h)`, the distance from that registered sole to the ground row (read from the anchors, no
px constant). Test `test_thug_soles_sit_on_the_ground_row_after_a_walk_and_a_stop` fails without it (2.816 >= 1.0), passes with.
Visual re-measure (both pitches, 64 and 32) follows in the next section.

## Soles at the stop, after (06:25)

Beside frames `GTAI_CAST_SHADOW=1` (`build/look/n29-thug/shadow70`, `shadow55`; the thug standing, facing down-right). Ground row =
ring centre (rows 522-558, centre 540.0 at 70/64). Lowest dark foot outline row (pixel scan of the `_body` frame, foot columns):

| Pitch / px/m | before | after | ground row | gap after | bar 2 px |
|---|---|---|---|---|---|
| 70 / 64 | 536 | 539 | 540 | 1 | PASS |
| 55 / 64 | n/a (not measured before) | 539 | 541 (ring 527-555) | 2 | PASS (edge) |
| 70 / 32 | 538 | 539 | 539.5 | 0.5 | PASS |
| 55 / 32 | n/a | 539 | 540 | 1 | PASS |

The scan is crude (a claw arm hangs near the foot columns at 64; the 64 figure was cross-checked by eye on an 8x crop,
before foot bottom about row 535, after about 538.5). Facings: unit test covers down, down-right, right (registered sole within 1 px
of the ground row after a walk and halt); frames measured only at the beside pose. Ring centroid after: 542.4 (70/64),
540.9 (70/32), 542.9 (55/64), 541.2 (55/32); ring rows centre on the ground row, within 2 px (centroid sits about 2 px low
because the rings are a stack of ellipses, unchanged by this fix).
Walk feet (`cast_feet.mjs` 32 px/m, `build/look/n29-thug/feet32`): sole 0.00 px on all four tracks, jump 9.60 / 9.30 / 9.60 / 8.68 (bar 12): PASS.
Crop: `C:\Users\kazda\kiro\gtai-masters\n29\cast\thug_stop_after_64.png` (red = ground row 540; soles about 1 px above).
