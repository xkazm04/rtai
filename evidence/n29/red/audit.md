# Red audit re-run on the n29 tree (n28 rows 1-28, same counter, same thresholds)

Counter: reddish = R>170, G<110, B<90, alpha>0, the n28 gate (`evidence/n28/red/count_red.py`, copy `evidence/n29/red/count_red.py`).
Both sides are git blobs, nothing in the tree touched: `python -I evidence/n29/red/audit_count.py c649a15d6 HEAD`
(old blobs through `git show | git lfs smudge`; raw output kept in `build/audit_counts.txt`, 215 lines). Scope as n28: every PNG under
`project/features/combat/**` plus the 32 `fx_atlas.png` cells. Per-group notes: `evidence/n29/red/fire.md`, `evidence/n29/red/electric.md`,
`evidence/n29/red/muzzle.md`. The sword group has no note file; its commit is 85c6b0c53.

## Totals (reddish px, n28 `c649a15d6` -> n29 HEAD)

| scope | n28 | n29 |
|---|---:|---:|
| F/H rows 1-10 + molotov row 12 (fire, blast, flame, muzzle cores, rag; 45 files/cells) | 143584 | 18230 |
| of which rows 1-10 alone (fire + muzzle, 37 files/cells) | 125452 | 98 |
| every combat PNG except D (row 11), gore, d5 stills, spark (177 files) | 223432 | 96940 |
| every PNG counted (combat tree + atlas cells, 215 lines) | 460922 | 334430 |

The 98 left in rows 1-10 are dark edge px of the `colour/` flash cells (3-16 each). What stays is row 12 (18132, molotov rag),
row 16 (77379 in 124 weapon item files), row 25 (229412, d5 stills not loaded), row 24 gore (6761, blood), row 11 (1304, Rivet's rounds), row 15 (1331 of 2469).
Outside the counter: `project/features/fx/art/fx_fire.png` (quest 1's fire loop, in no n28 row) went 61253 -> 1 (`fire.md` After3, ddd15787f).

## What reaches the screen

Stills: `C:/Users/kazda/kiro/gtai-masters/n29/combat/stills/` (pairs = before | after, `pair2` adds the FX amber ink, `pair3` the fire loop).
- Fire: the PNG repaint alone showed nothing in the shipped look (the item print snaps amber to vermilion); it reads amber since the FX view's amber ink
  (12b7c141b, `look_profiles.json` `fx_amber_ink`, false = off). `red_fire_blast_pair2_64.png`: amber star, cream core, ink rim; `red_fire_explosion_pair2_64.png` the cloud star;
  `red_fire_flame_pair3_64.png` and `red_fire_ground_fire_pair3_64.png` the bursts and burning ground amber with cream hearts.
  Crop reddish px: blast 53046 -> 953, explosion 18217 -> 1127, flame 38143 -> 3379, burning ground 22026 -> 2819 (the rest in each crop is blood).
- Electric: `red_elec_tazer_pair2_64.png`, `red_elec_burst_pair2_64.png`: prongs and burst arc are a cream core in an amber body, the barrel stripe prints amber; tazer crop 2370 -> 1366 (what is left is Mertz's gloves).
- Muzzle: the d4 `muzzle` star reads amber in the FX view (`red_muzzle_d4_muzzle_pair_64.png`). In the arena the 22 tick-exact gun-flash stills are pixel-identical before/after
  (`red_muzzle_pistol_pair_64.png`, `red_muzzle_nuke_pair_64.png`): the in-game flash is not drawn from the `flash_*` cells, so rows 5-8 are FIXED at the source with no on-screen delta.
- Sword: no in-game still yet (see row 15).

## Owner calls

1. Mertz's vermilion gloves (the red left in the tazer crop) = cast art, `NEED cast`: the Mertz sprite PNG, not in this lane's files.
2. Molotov rag (row 12: `held`, `pickup`, `held_55/molotov`, 18132 px): `NEED keys`.
3. The FX-view amber ink scope: `fx_amber_ink` in `look_profiles.json` switches both the FX view and `PrintStage.cast_material()` (cast = Rivet, cops, allies, Mertz, pickups).
   Pixel diff against a forced-off control: 5-58 px outside the electric boxes, amber-ward re-prints of ember speckle; collar, cops, gloves did not move (`electric.md`). Owner may veto per view.
4. Row 11 Rivet's rocket / nuke shell paint: KEPT as drawn (amber would read as a pickup).
5. New: `rivet_eq_plasma_sword*.png` sheets (`project/features/characters/art/view/p55/` plus p70) carry the red hilt rings of the old sword art: `NEED keys` (outside the n28 counter).
6. New: the in-flight electro bolt now draws as live current (3e2fde824 `WeaponFxBolt`; `--electro-cells` keeps the old cells): not an n28 row, listed so the next audit counts it.
7. New: `StageView._bolt_robot` (row 19) is dead code; delete it or wire it (owner of stage_view).
8. Not re-checked: the `lights.json` explosion light has a vermilion rim (n28 said so); `fx.json:101` is a doc string only.

## Rows

| # | source | n28 px | n29 px | status | evidence |
|--:|---|---:|---:|---|---|
| 1 | `weapons/art/fx/blast_0,1.png` | 6105 / 34363 | 0 / 0 | FIXED 3a7fcfed0 (on screen via 12b7c141b) | `fire.md` px table; `red_fire_blast_pair2_64.png` |
| 2 | `weapons/art/fx/flame_0,1,2.png` | 6926 / 7949 / 7940 | 0 / 0 / 0 | FIXED 3a7fcfed0 (on screen via 12b7c141b, bursts ddd15787f) | `fire.md`; `red_fire_flame_pair3_64.png` |
| 3 | `fx/colour/flame_cone_0-2`, `colour/flame_0-2`, `colour/ground_fire.png` | 5676-5805 / 3057-3455 / 3093 | 0 (all 7) | FIXED 3a7fcfed0; the burning ground the player sees is `fx_fire.png`, FIXED ddd15787f | `fire.md` After3; `red_fire_ground_fire_pair3_64.png` |
| 4 | `fx_atlas.png` cells 9-12 | 2032 / 4676 / 1966 / 965 | 0 | FIXED 3a7fcfed0 | `fire.md`; `red_fire_explosion_pair2_64.png` |
| 5 | `flash_nuke_0,1` (+ `colour/` 1217, 847, 741) | 3761 / 2181 | 0 / 0 (colour/ 9, 6, 16) | FIXED 2a1069f77 (source; arena flash not drawn from these cells) | `muzzle.md`; `red_muzzle_nuke_pair_64.png` |
| 6 | `flash_tube_0,1,2` (+ `colour/` 797, 634, 426) | 1633 / 1058 / 634 | 0 / 0 / 0 (colour/ 9, 3, few) | FIXED 2a1069f77 (source) | `muzzle.md`; `red_muzzle_rocket_pair_64.png` |
| 7 | `flash_pistol_0,1,2` (+ `colour/` 675, 547, 361) | 1019 / 659 | 0 / 0 (colour/ 10, few) | FIXED 2a1069f77 (source) | `muzzle.md`; `red_muzzle_pistol_pair_64.png` |
| 8 | `flash_smg_0,1,2` (+ `colour/` 494, 423, 261) | 473 / 298 | 0 / 0 | FIXED 2a1069f77 (source) | `muzzle.md` |
| 9 | `fx_atlas.png` cells 0, 1, 2 | 576 / 485 / 1880 | 0 / 0 / 0 | FIXED 2a1069f77 (reads amber in the FX view) | `muzzle.md`; `red_muzzle_d4_muzzle_pair_64.png` |
| 10 | `fx_atlas.png` cells 8, 13, 14 | 630 / 257 / 1 | 0 / 0 / 0 | FIXED 2a1069f77 (source; not seen on screen in any take) | `muzzle.md` |
| 11 | `weapons/art/fx/rocket.png`, `nuke_shell.png` | 336 / 968 | 336 / 968 | KEPT Rivet's own round, paint on the body (owner call: amber would read as a pickup) | `muzzle.md` row 11 note |
| 12 | `molotov/held.png`, `pickup.png`, `held_55/molotov.png` | 5860 / 5457 / 6815 | 5860 / 5457 / 6815 | NEED keys (the three files; the lit rag flame is still red) | `build/audit_counts.txt` |
| 13 | `features/player/rag_light.gd:29` | #E8502A | draws `Ink.AMBER` with ink rim and cream core | FIXED 3a7fcfed0 (code only, no take shows it) | `project/features/player/rag_light.gd:29` |
| 14 | `weapons/fight_nuke_art.gd:32` | #E8502A | draws `Ink.AMBER` (`draw_circle(..., 9.0, Ink.AMBER)`) | FIXED 3a7fcfed0 (code only) | `project/features/combat/weapons/fight_nuke_art.gd:32` |
| 15 | `plasma_sword/held_long` (+ `held`, `pickup`, `held_55/plasma_sword`) | 378 / 287 / 296 / 224 | 15 / 3 / 16 / 13 | FIXED (source) 85c6b0c53, in-game still owed. Left: `showcase/{icon,p55,p70}/plasma_sword` 331 / 421 / 483 and `held_55/plasma_sword_small` 49 (another design, no rings) = NEED keys; the `rivet_eq_plasma_sword*` sheets in view/p55 + p70 = NEED keys | `build/audit_counts.txt` |
| 16 | `held_55/*`, `showcase/{icon,p55,p70,crate}/*`, `<weapon>/held,pickup,mag` (124 files, minus rows 12, 15) | 77379 | 77379 | NEED keys (item/held art; pickups are vermilion-allowed, held art to audit by eye; biggest: mini_nuke 6304, rocket_launcher 4534, crate p70 4400, homing_shard 2177, electro_gun icon 2028, ray_gun p70 2019) | `build/audit_counts.txt` |
| 17 | `cast_view.gd` tazer barrel stripe, prong sparks | #E8502A | `CurrentLook.STRIPE` = `Ink.AMBER`; prongs `CurrentLook.draw` (cream core, amber body) | FIXED 330ad6592, 3bf74f0c7; Mertz's gloves stay vermilion = NEED cast | `project/boot/collect_call/view/current_look.gd:8`; `red_elec_tazer_pair2_64.png` |
| 18 | `fx_view.gd` burst-arc zigzag (now line 131) | #E8502A | `CurrentLook.draw(self, a, b, ...)`: cream core in amber body | FIXED 330ad6592, 3bf74f0c7 | `project/boot/collect_call/view/fx_view.gd:131`; `red_elec_burst_pair2_64.png` |
| 19 | `stage_view.gd` TUCK-IN bolt glyph | #E8502A | `CurrentLook.BOLT` = `Ink.AMBER` | NOT ON SCREEN dead code `StageView._bolt_robot` (no caller; the crate on screen is the `tuckin_crate` PNG); code FIXED 330ad6592 | `project/boot/collect_call/view/stage_view.gd:201`; `electric.md` |
| 20 | `cast_view.gd:93` Rivet struck `_impact` rim | #E8502A | `_impact(r, Ink.VERMILION)` unchanged | KEPT danger cue (hit flash) | `project/boot/collect_call/view/cast_view.gd:93` |
| 21 | `fx_view.gd:101,104` aim tells; `foe_shield_view.gd:58-65`; `foe_walker_view.gd:70` | #E8502A | all `Ink.VERMILION`, unchanged | KEPT danger cues | `project/boot/collect_call/view/fx_view.gd:101`; `project/features/combat/squad/foe_shield_view.gd:58`; `project/features/combat/squad/foe_walker_view.gd:70` |
| 22 | `stage_view.gd:172` ringing phone; `objective_view.gd:83,100` | #E8502A | `Ink.VERMILION`, unchanged | KEPT objective | `project/boot/collect_call/view/stage_view.gd:172`; `project/boot/collect_call/view/objective_view.gd:83` |
| 23 | kill art `MIST`/`RAW`/`BLOOD`, `corpse_stains`, `blood_stains` | blood tints | unchanged | KEPT blood | n28 audit row 23 |
| 24 | `weapons/art/gore/*.png` (28 files) | 6761 | 6761 | KEPT blood | `build/audit_counts.txt` |
| 25 | `combat/art/d5/{boss_intro_king, finisher_lightbar, finisher_drone, finisher_k9}.png` | 122182 / 60222 / 28999 / 18009 | same | NOT ON SCREEN no `.gd`, table or scene under `project/` names them (grep at HEAD); the lightbar must be cop blue before it ships | `build/audit_counts.txt` |
| 26 | `data/tables/flame_embers.json:11` rim `#EE6A1C` | #EE6A1C | #EE6A1C | KEPT amber-orange (n28 call; ember rim, not vermilion) | `project/data/tables/flame_embers.json:11` |
| 27 | `palette.json` `E8502A` / `A30509` tokens | - | unchanged | KEPT the tokens themselves; vermilion stays for danger, objectives, collar, blood for blood | `project/data/tables/palette.json` |
| 28 | `weapons/art/fx/colour/spark_0,1,2.png` | 2 / 5 / 6 | 2 / 5 / 6 | NOT ON SCREEN negligible (13 px total, not a repaint target) | `build/audit_counts.txt` |

Status count: FIXED 15 (1-10, 13, 14, 15 source, 17, 18); KEPT 8 (11, 20-24, 26, 27); NEED keys 2 (12, 16) plus sub-needs inside 15 (showcase and rivet_eq sheets) and
NEED cast inside 17 (Mertz's gloves); NOT ON SCREEN 3 (19, 25, 28).
