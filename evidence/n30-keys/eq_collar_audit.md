# eq collar audit: which weapon strips still wear the collar as rope (n30-10, analysis only, 0 images)

Brief `evidence/briefs/n30-10-eq-collar-audit.md`. Contact sheets (4x NEAREST crop on the neck band, labelled strip + cell):
`C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/` (`p70_left_*`, `p70_eq_*`, `p70_diag_*`, `p70_left_suspects`,
`p70_diag_fire_suspects`, `p70_eq_mini_gat`, `p70_reload_suspects`, `p70_grid_a..f`, `p55_*`).
Method: cut cells (eq 8, `_left` 3, `_diag` 4, `_left_fire`/windup/strike 1, walk_eq 4 x 8 rows, run8_eq 8 x 8, reload 8 / left 3),
centre the crop on the vermilion pixels, **class by eye** on the sheets. A colour-component metric (`build/n30-10/metric.py`,
band perimeter per orange px; rigid refs gloria/pistol/katana/molotov left 0.75-0.95, rope 1.3-1.6) only sorted what to
look at: it over-fires on occluded bands (baton walk 4.7 was rigid on sight). Walk/run grids were **sampled** (12 cells per
sheet, 12 sheets, every 3rd-5th cell across rows), not every cell; sheets I did not sample had metric <= 1.0 (rigid by metric only).

## When shown (p70 is the combo default in play; p55 only while a boss is engaged: `data/tables/view.json`, ViewMode)
| Strip family | Shown when (`RivetFrames.step`, `RivetWalk`, `RivetStrips`) | Weight |
|---|---|---|
| `rivet_walk_eq_*` / `rivet_run8_eq_*` (grid) | any weapon in hand while moving (run8 above 2.5 m/s), not firing | highest |
| `rivet_eq_<w>` 8 cells | standing, aim any octant (not left for left-drawn weapons), fire, idle | high |
| `rivet_eq_<w>_left` 3 cells | standing, aim octants 3-5 for ONE_HAND + LEFT_LONG_GUNS weapons (cell 1 = pure side, most seen) | high |
| `_diag` 4 cells | a shot latched at a diagonal octant (1,3,5,7) | medium (while firing) |
| `_left_fire` | firing left, one cell | medium |
| `rivet_reload_*` | during reload | low-medium |
| `_windup`/`_strike`/`_thrust` (melee) | strike frames only | low (about 0.3 s per swing) |
| p55 of any of these | boss engaged only | low |

## Counts per strip (p70; cells seen by eye)
| Strip | ROPE | UNSURE | RIGID | Notes |
|---|---|---|---|---|
| `rocket_launcher_left` (3) | 3 (c0,c1,c2) | 0 | 0 | frayed edges, wavy outline, torn stripes; the director's cells |
| `mini_nuke_left` (3) | 3 (c0,c1,c2) | 0 | 0 | chevron / knit stripes, broken outline |
| `gatling_left` (3) | 3 (c0,c1,c2) | 0 | 0 | frayed, twisting |
| `gatling_left_fire` (1), `mini_nuke_left_fire` (1) | 2 | 0 | 0 | frayed |
| `gatling` eq (8) | 0 | 5 (c0,c1,c3,c5,c7) | 1 | notched, stair-stepped edges; c2,c4,c6 band mostly hidden |
| `mini_nuke` eq (8) | 0 | 4 (c1,c3,c5,c7) | 3 | slightly lumpy, not frayed |
| `gatling_diag` (4) | 2 (c0,c2) | 0 | 0 | twisted, frayed; c1,c3 band hidden |
| `electro_gun_diag` (4) | 0 | 2 (c0,c2) | 0 | torn stripes, partly hidden by the gun |
| `flamethrower_left` (3) | 0 | 1 (c2) | 0 | band hidden by the tank in c0,c1 |
| `mini_nuke_diag`, `homing_shard_diag`, `ray_gun_diag`, `rocket_launcher` eq/diag | 0 | 0 | rest | rigid |
| `reload_gatling` (8) | 0 | 8 | 0 | soft wavy edges (second tier, not ranked) |
| `run8_eq_plasma_sword` | 0 | 3 sampled (r2c4, r3c1, r5c5) | rest | stripes soft/curved |
| `run8_eq_assault_rifle` | 0 | 1 sampled (r2c4) | rest | |
| `walk_eq_electro_baton` | 0 | thin stripes, cells r0-r5 | rest | thin but straight |
| all other `_left` (assault_rifle, chainsaw, baton, electro_gun, gloria, hand_cannon, homing_shard, katana, machine_pistol, molotov, pistol, plasma_rifle, plasma_sword, ray_gun) | 0 | 0 | all | flat band |
| other 8-cell eq (assault, chainsaw, baton, gloria, hand_cannon, molotov, pistol, plasma_rifle, ray_gun, rocket_launcher, homing_shard, katana) | 0 | 0 | seen cells | rigid where the band is visible |
| walk_eq / run8_eq (sampled sheets: baton, rocket, chainsaw, electro_gun, flamethrower, plasma_sword, assault, gatling, machine_pistol) | 0 | the 4 above | rest | grids are the rigid majority |
| melee windup/strike | not judged | | | band mostly hidden, low weight |

p55 (boss fights only): `mini_nuke_left` (3) frayed / unsure, `gatling_left` (3) unsure, `mini_nuke` eq and `_diag` unsure; `rivet_run8_eq_*` and
walk sheets mostly rigid at the p55 bust scale. Not ranked: p55 weights are small and the bands are 2x smaller.

## Ranked 8 cells for a per-cell 2x edit (most seen first)
Left strip cells 0/1/2 = octants 3/4/5; the reference is the same cell index of a rigid left strip (same facing, same hand), file
`project/features/characters/art/view/p70/`.
| # | Cell | Reference (rigid, same facing) | Why |
|---|---|---|---|
| 1 | `rivet_eq_rocket_launcher_left.png` cell 1 | `rivet_eq_gloria_left.png` cell 1 (also `pistol_left` cell 1) | director's flag; pure side aim with a standing rocket launcher |
| 2 | `rivet_eq_mini_nuke_left.png` cell 1 | `rivet_eq_gloria_left.png` cell 1 | director's flag; same pose, tank/nuke prop |
| 3 | `rivet_eq_gatling_left.png` cell 1 | `rivet_eq_gloria_left.png` cell 1 (fallback `hand_cannon_left` cell 1) | frayed, side aim |
| 4 | `rivet_eq_rocket_launcher_left.png` cell 2 | `rivet_eq_gloria_left.png` cell 2 | director's flag |
| 5 | `rivet_eq_mini_nuke_left.png` cell 2 | `rivet_eq_gloria_left.png` cell 2 | director's flag |
| 6 | `rivet_eq_gatling_left.png` cell 2 | `rivet_eq_gloria_left.png` cell 2 | |
| 7 | `rivet_eq_gatling_diag.png` cell 0 | `rivet_eq_hand_cannon_diag.png` cell 0 (toward right, the same octant) | shown while firing diagonal: seen as much as the left cells for the gatling |
| 8 | `rivet_eq_rocket_launcher_left.png` cell 0 | `rivet_eq_gloria_left.png` cell 0 | down-left aim, wavy outline |

Next wave if edits remain: `mini_nuke_left` c0, `gatling_diag` c2, `gatling_left_fire`, `mini_nuke_left_fire`, `gatling` eq c0/c1/c3/c5/c7
(8-cell strip, notched edges: judge at 2x before spending an edit), `electro_gun_diag` c0/c2.
Note: the edits do not need `noflash` twins redone separately unless a twin copies the band (`gatling_*_noflash`, `electro_gun_*_noflash`
share the figure; check with a pixel diff outside the muzzle).
