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

## Edits (n30-12)
Round `C:/Users/kazda/kiro/gtai-art/rivet-n30/eq_collar/` (`STATE.md`; scripts copied from `collar_cells` and adapted to a 3-cell strip:
`strip_job.py`, `cell_comp.py` with a required per-cell `CELL_BAND` box (the only px that may change; the collar hull is taken inside it,
because the mini-nuke and gatling carry orange/yellow hazard paint), `strip_proof.py`). 8 images (the cap), one per cell, reference =
`rivet_eq_gloria_left.png` same cell at 2x + its collar crop at 4x. Per cell: alpha identical, 0 px changed outside the band box,
other cells bit-identical, teal 0; "weapon px" = px changed inside the declared weapon boxes (cell coords, `WEAPON_BOX` in the proof json).
Judge stills (shipped | candidate | reference, 4x): `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/n30-12_<weapon>_c<i>_judge4x.png`.

| Cell | Ref | IoU | Band box | Mask px | Changed | Weapon px changed | Verdict |
|---|---|---|---|---|---|---|---|
| `rocket_launcher_left` c1 | gloria c1 | 0.988 | 101,70,170,96 | 578 | 578 | 0 | RIGID: flat ring, straight parallel stripes, outlined |
| `mini_nuke_left` c1 | gloria c1 | 0.993 | 112,108,180,150 | 845 | 845 | 0 | RIGID: chevrons gone, flat outlined ring |
| `gatling_left` c1 | gloria c1 | 0.993 | 117,86,179,117 | 652 | 652 | 0 | RIGID |
| `rocket_launcher_left` c2 | gloria c2 | 0.992 | 100,68,166,99 | 529 | 529 | 0 | RIGID |
| `mini_nuke_left` c2 | gloria c2 | 0.988 | 108,106,180,150 | 589 | 589 | 0 | RIGID (right end keeps the shipped side face) |
| `gatling_left` c2 | gloria c2 | 0.992 | 118,90,176,118 | 494 | 494 | 0 | RIGID |
| `rocket_launcher_left` c0 | gloria c0 | 0.986 | 92,74,162,98 | 258 | 258 | 0 | RIGID below the visor (left end by the sight keeps shipped px) |
| `mini_nuke_left` c0 | gloria c0 | 0.993 | 98,114,172,142 | 285 | 285 (not shipped) | 0 | REJECTED by eye: band stays torn under the visor and at the right end; KEPT SHIPPED |

Commits: `8776d8711` gatling, `f371eddb6` rocket launcher, `f3aefd0a2` mini-nuke (one provenance line each).
Strips vs HEAD `57c72c41a`: `gatling_left` 1146 px (c0 0), sha256 `76faf66c...`; `rocket_launcher_left` 1365 px, `445964a4...`;
`mini_nuke_left` 1434 px (c0 0), `a8a196bb...`; all alpha identical, 0 px outside the band boxes, 0 weapon-box px.
In game (arsenal turn, p70, 64 px/m, before = HEAD run `build/n30-12/before/`): stills `<weapon>_left_64_ingame.png` in the masters dir
(octants 3/4/5 = cells 0/1/2, before | after).
Owed: `mini_nuke_left` c0 (retry with a weapon-arch sentence, or the chainsaw c0 as image two), the next-wave cells above
(`gatling_diag` c0/c2, `gatling_left_fire`, `mini_nuke_left_fire`, `gatling_left` c0 not in this call's list).

## UNSURE settled (n30-20)
Analysis only, 0 images. Script `evidence/n30-keys/eq_collar_unsure.py` (python -I, from the worktree root) cuts each cell (cols x rows from the
strip size) and writes cell | reference, 4x NEAREST neck crops, to `C:/Users/kazda/kiro/gtai-masters/n30/keys/eq_collar/unsure_<strip>_4x.png`
(`walk_eq_electro_baton` in 3 sheets `_0.._2`). Reference = same cell index of a rigid strip of the same facing (`rivet_eq_pistol`,
`rivet_eq_hand_cannon_diag`, `rivet_eq_gloria_left`, `rivet_reload_pistol`, `rivet_run8`, `rivet_walk_eq_gloria`). Every crop was looked at.
Weak ROPE = a visible defect, but milder than the director's cells (rocket/mini_nuke/gatling left).

| Cell | Verdict | Reference | Why |
|---|---|---|---|
| `gatling` eq c0 | RIGID | `pistol` eq c0 | narrower stripes, but outline smooth and stripes parallel |
| `gatling` eq c1 | RIGID | `pistol` eq c1 | thin, straight, constant thickness |
| `gatling` eq c3 | ROPE (weak) | `pistol` eq c3 | lower edge stair-stepped, band thickness lumpy, stripes tilt unevenly |
| `gatling` eq c5 | RIGID | `pistol` eq c7 (c5 of the pistol is the back view, no band) | thin but flat, outlined |
| `gatling` eq c7 | RIGID | `pistol` eq c7 | thin, edges clean |
| `mini_nuke` eq c1 | RIGID | `pistol` eq c1 | flat outlined ring |
| `mini_nuke` eq c3 | RIGID | `pistol` eq c3 | smooth, parallel stripes |
| `mini_nuke` eq c5 | RIGID | `pistol` eq c7 | slightly soft stripe ends, outline clean |
| `mini_nuke` eq c7 | RIGID | `pistol` eq c7 | slight lump at the right end only |
| `electro_gun_diag` c0 | ROPE | `hand_cannon_diag` c0 | thin, stripes twist and break where the gun crosses; reads as a cord |
| `electro_gun_diag` c2 | ROPE | `hand_cannon_diag` c2 | chevron-wavy stripes, ragged outline |
| `flamethrower_left` c2 | ROPE (weak) | `gloria_left` c2 | small band, ragged lower edge, stripes torn into blobs (band mostly hidden by the tank) |
| `reload_gatling` c0 | RIGID | `reload_pistol` c0 | clean |
| `reload_gatling` c1 | RIGID | `reload_pistol` c1 | thin, straight |
| `reload_gatling` c2 | RIGID | `reload_pistol` c2 | clean |
| `reload_gatling` c3 | ROPE (weak) | `reload_pistol` c3 | stripes broken, wavy lower edge |
| `reload_gatling` c4 | RIGID | `reload_pistol` c4 | clean |
| `reload_gatling` c5 | ROPE (weak) | `reload_pistol` c5 | wavy, lumpy band, rope-like curve |
| `reload_gatling` c6 | ROPE (weak) | `reload_pistol` c6 | wavy, stripes uneven |
| `reload_gatling` c7 | RIGID | `reload_pistol` c7 | thin, straight |
| `run8_eq_plasma_sword` r2c4 | ROPE | `rivet_run8` r2c4 | round tube with a sheen line, stripes curve around it like a twisted cord (the run8 ref is also a little tubular; compare against `run8_eq_gloria` r2c4 before editing) |
| `run8_eq_plasma_sword` r3c1 | RIGID | `rivet_run8` r3c1 | matches the ref |
| `run8_eq_plasma_sword` r5c5 | RIGID | `rivet_run8` r5c5 | softness is the blade glow laid over the band, stripes straight |
| `run8_eq_assault_rifle` r2c4 | ROPE (weak) | `rivet_run8` r2c4 | same pose as the plasma cell: tube, sheen, stripes wrap like a cord |
| `walk_eq_electro_baton` r0-r5 (all 24 cells) | RIGID | `walk_eq_gloria` same cell | thin band with a grey sheen line, but straight parallel stripes, clean outline, constant thickness |

Counts: gatling eq 1 ROPE / 4 RIGID; mini_nuke eq 0 / 4; electro_gun_diag 2 / 0; flamethrower_left 1 / 0; reload_gatling 3 / 5; run8 plasma_sword 1 / 2;
run8 assault_rifle 1 / 0; walk baton 0 / 24. Total 9 ROPE, 41 RIGID. Could not judge: baton walk rows 6-7 and the run8 cells outside the
sampled ones were not in the UNSURE list and were not looked at; the run8 `r2c4` ref is itself tubular, so those two verdicts are the least certain.

### Next run edit list (ROPE cells by how often seen; one image per cell, 2x per-cell route)
| # | Cell | Reference cell | Seen |
|---|---|---|---|
| 1 | `rivet_run8_eq_plasma_sword.png` r2c4 | `rivet_run8_eq_gloria.png` r2c4 (not `rivet_run8`, tubular) | highest (grid, moving with the weapon) |
| 2 | `rivet_run8_eq_assault_rifle.png` r2c4 | `rivet_run8_eq_gloria.png` r2c4 | highest (weak) |
| 3 | `rivet_eq_gatling.png` c3 | `rivet_eq_pistol.png` c3 | high (standing, octant 3) |
| 4 | `rivet_eq_electro_gun_diag.png` c0 | `rivet_eq_hand_cannon_diag.png` c0 | medium (diagonal fire) |
| 5 | `rivet_eq_electro_gun_diag.png` c2 | `rivet_eq_hand_cannon_diag.png` c2 | medium |
| 6 | `rivet_eq_flamethrower_left.png` c2 | `rivet_eq_gloria_left.png` c2 | high if flamethrower uses the left strip, band small |
| 7 | `rivet_reload_gatling.png` c3 | `rivet_reload_pistol.png` c3 | low-medium |
| 8 | `rivet_reload_gatling.png` c5 | `rivet_reload_pistol.png` c5 | low-medium |
| 9 | `rivet_reload_gatling.png` c6 | `rivet_reload_pistol.png` c6 | low-medium (drop first if capped at 8) |

Image count: 9 (8 if the cap holds). Check `_noflash` twins of `gatling` and `electro_gun` for shared band px. All other UNSURE cells need no edit.
