# n11 hero JOURNAL

Iterations 1-3 of the runner died in 2-3 s (billing: "Credit balance is too low"), nothing was done. Iteration 4 is the first working session (19:26).

## it4 (19:26-)

- MILESTONE 19:40 item 1 reproduced in the real arena, combo, 64 px/m, pistol: `dev/hero/cursor_sweep.tscn` drives the cursor through LiveInput's own projection and logs drawn octant against the cursor. BEFORE (`gtai-n11/tmp/hero/s/sweep_before_pistol.{png,tsv}`), error between the drawn octant and the cursor's ground angle: stand mean 11.6 / worst 25.9 deg; walk 11.7 / 30.7; **sprint 55.6 / 96.4**; melee 3.9 / 88.4 (88 is the flick between held octants).
- Causes read from the code, item 1: (a) `PlayerMotion._free_step` passes `Vector2.ZERO` as the aim while sprinting, by design of rivet-motion ("the facing then follows the walk"), so a sprint ignores the cursor; (b) `RivetFrames.oct_of` reads `rig.head.global_rotation`, which is the sim facing (turn cap 720 deg/s) through a spring (k 260) plus the stride's twist; (c) `roundi` has no hysteresis, so a cursor resting on a boundary can flip the card; (d) `origin_px` is the viewport centre, not Rivet (on foot the camera has no look-ahead, so this is only wrong under shake, but it is wrong); (e) the aim line starts at his feet while the drawn body and the tracers are at gun height.
- MILESTONE 19:40 item 2 reproduced: in the MELEE leg (8 cursor octants, one swing each) every claw swing shows `rivet_frames` cell 11 (the one drawn side view), mirrored on the left. Sim facing follows the cursor (133.6 at a 135 deg cursor), so the hit area is not stuck: **the art is**. Melee weapons draw `FIRE_SIDE`/`FIRE_CAM` only (`RivetFrames.cell_of`), so up the screen a blade swing is the same side cell.

### Ghost inventory against Rivet (item 5)

| | Rivet | Tonnage | Dent | Kerf | Ohm |
|---|---|---|---|---|---|
| Facing art at combo | 8 cells (5 drawn + left drawn), p70 + p55 | card, 5 facings mirrored | bust card over the cutout | card, 5 facings mirrored | card, 5 facings mirrored |
| Walk | 8 x 8 drawn grid, p70 + p55, stepped by ground walked | cutout legs under a card | Rivet's cycle (lurch) | cutout legs under a card (glide) | cutout legs under a card |
| Run | 8 x 8 drawn grid | none | none | none | none |
| Attack cells | claw, side + camera fire cells | none (press/stomp is FX) | none | none in game (library `kerf_70` has 2 action poses) | none |
| Hit / death cells | HIT, DEATH | none | none | none | none |
| Library source | hundreds of cells | **no sheet** | `dent_70_v2` A (tan), 36 keyed | `kerf_70` A, 36 keyed | `ohm_70` A, 36 keyed |

DECISION ghost order: Kerf first (A art, thin legs that show a cutout walk worst), then Ohm, Dent, Tonnage (no source sheet at all yet).

REQUEST assets: **Kerf at 70**, 8-frame walk cycle in Rivet's house layout (`deliveries/rivet_walk8_it112.md`): rows = toward, 3/4 toward right, right profile, 3/4 away right, away; columns = CONTACT, DOWN, PASSING, UP, CONTACT (other foot), DOWN, PASSING, UP; tight transparent cells `{r}_{c}.png` under `keyed/ghosts/kerf_walk8_70_cells/`, copied by example from `keyed/street/kerf_70.png`'s five standing facings at the same scale. Feet on one baseline in every cell: a hover-free walk, the blades hanging, soul wisps kept. Left facings may be mirrored (Kerf has no weapon hand). Same grid at 55 after 70 is A.
REQUEST assets: **Kerf at 70, attack and hit cells**, one row per facing (5 rows as above), columns = WIND-UP, CUT (blade extended, arc drawn), FOLLOW-THROUGH, HIT (recoiling), under `keyed/ghosts/kerf_act_70_cells/`.
REQUEST assets: **Ohm at 70**, same two requests from `keyed/street/ohm_70.png`: `keyed/ghosts/ohm_walk8_70_cells/`, `keyed/ghosts/ohm_act_70_cells/` (cane cast as the attack).
REQUEST assets: **Dent at 70**, same two from `keyed/street/dent_70_v2.png` (tan, cyan wisps only): `keyed/ghosts/dent_walk8_70_cells/`, `keyed/ghosts/dent_act_70_cells/` (the two-hand seize as the attack).
REQUEST assets: **Tonnage at 70**, first a 5-facing + 2-action sheet like `kerf_70` (the game's `features/souls/art/view/p70/tonnage_card.png` is the identity reference, about 3x Rivet's bulk), then walk8 and act cells as above: `keyed/ghosts/tonnage_*`.
REQUEST assets: **Rivet bare-claw strike at 70 and 55 in five directions** (owner: "melee attack follows always only one direction"; the game has one side cell, cell 11 of `rivet_frames.png`). Rows = toward, 3/4 toward right, right profile, 3/4 away right, away; columns = WIND-UP, STRIKE (claw at full reach along that direction), FOLLOW-THROUGH; tight transparent cells under `keyed/rivet/rivet_claw_strike_70_cells/` and `..._55_cells/`, the figure's size and foot line matching `rivet_walk8_70_cells`. Left facings drawn, never mirrored (the claw stays the near arm), as the walk's left rows are.
