# Red audit, combat effects (n28 combat, call 2) - LIST ONLY, nothing fixed

Law (owner 2026-11-24): red is blood only; vermilion only for danger, objectives, Rivet's collar; amber for fire, heat and
electric current; teal souls; cops blue. Counter: `evidence/n28/red/count_red.py` (reddish = R>170, G<110, B<90, alpha>0;
run `python -I evidence/n28/red/count_red.py`). Contact sheet of the flagged cells (reddish repainted green):
`evidence/n28/red/cells.png`. Scope: every PNG under `project/features/combat/**` (214 files carry reddish pixels), the 32
cells of `project/features/fx/art/fx_atlas.png` (cells 0-2, 8-14 carry some), and the Color/Ink.VERMILION draws in
combat, player, collect_call view code. Tables: `fx.json`, `gun_fx.json`, `fx_triggers.json` name no red colour (fx.json
line 101 only says "vermilion light rim"); the `lights.json` explosion light has a vermilion rim. Kill art `BLOOD` /
`MIST` / `RAW` / `corpse_stains` / `blood_stains` are blood: fine. Class: F = fire (should be amber), E = electric
(should be amber), D = danger (vermilion allowed), H = hit/muzzle flash core, B = blood (fine), A = art-only (not loaded).

The three worst (by what the player sees: reddish area on a live effect that is not blood or danger):
1. `blast_1.png` (34363 px): the rocket/nuke blast fireball, the biggest red shape in a fight. F.
2. `flame_0-2.png` (6926-7949 px each) + `fx/colour/flame_cone_*` (5.7k) + `ground_fire.png` (3093): the flamethrower and molotov fire. F.
3. The muzzle-flash star cores (`flash_pistol/smg/tube/nuke_*`, atlas cells 0-2, 8-9): a vermilion core in every gun flash, 500-3761 px each, in every fight. H.

| # | source | what it shows in the game | reddish px / colour | class | suggestion |
|--:|---|---|---:|---|---|
| 1 | `weapons/art/fx/blast_1.png` (+ `blast_0` 6105) | rocket blast fireball ring around a cream core (`WeaponFxArt` BLAST_FRAMES) | 34363 / 6105 | F | repaint the ring amber (blast keeps cream core, ink rim) |
| 2 | `weapons/art/fx/flame_0,1,2.png` | flamethrower puffs and flame trail | 6926 / 7949 / 7940 | F | amber, not orange-vermilion |
| 3 | `weapons/art/fx/colour/flame_cone_0-2.png`, `flame_0-2`, `ground_fire.png` | the colour-variant flame cone, puffs, burning ground | 5676-5805 / 3057-3455 / 3093 | F | amber |
| 4 | `fx_atlas.png` cell 10 (and 9, 11, 12) | `explosion` kind smoke cloud with a vermilion star centre | 4676 / 2032 / 1966 / 965 | F | amber star in the cloud |
| 5 | `weapons/art/fx/flash_nuke_0,1.png` (+ `colour/` 1217, 847, 741) | mini-nuke muzzle flash star, core | 3761 / 2181 | H | core amber or cream |
| 6 | `weapons/art/fx/flash_tube_0,1,2.png` (+ `colour/` 797, 634, 426) | rocket-tube muzzle flash | 1633 / 1058 / 634 | H | core amber or cream |
| 7 | `weapons/art/fx/flash_pistol_0,1,2.png` (+ `colour/` 675, 547, 361) | pistol / machine-pistol flash and the stand-in muzzle flash `BareGunFx.shot` (`boot/collect_call/view/bare_gun_fx.gd:34`; it drew the deflect fleck before 7e95d96fb) | 1019 / 659 | H | core amber or cream; `flash_energy_*` is already cream-only |
| 8 | `weapons/art/fx/flash_smg_0,1,2.png` (+ `colour/` 494, 423, 261) | SMG flash | 473 / 298 | H | as 7 |
| 9 | `fx_atlas.png` cells 0, 1, 2 (kind `muzzle`) | the d4 muzzle stars used by `fx.json` kind `muzzle` | 576 / 485 / 1880 | H | amber core |
| 10 | `fx_atlas.png` cells 8, 13, 14 | small burst, ricochet-size stars | 630 / 257 / 1 | H | amber core |
| 11 | `weapons/art/fx/rocket.png`, `nuke_shell.png` | Rivet's rocket body with a red nose band; the nuke shell | 336 / 968 | D | Rivet's own round: keep or make amber; enemy rounds are danger (vermilion allowed) |
| 12 | `weapons/art/molotov/held.png`, `pickup.png`, `held_55/molotov.png` | the rag flame on the bottle (lit rag) | 5860 / 5457 / 6815 | F | amber rag flame |
| 13 | `features/player/rag_light.gd:29` | the molotov rag lighting star while drawing: `draw_colored_polygon(..., Ink.VERMILION)` | #E8502A | F | amber `Ink` token |
| 14 | `weapons/fight_nuke_art.gd:32` | the mini-nuke's glowing tip, `draw_circle(..., Ink.VERMILION)` | #E8502A | F | amber |
| 15 | `weapons/art/plasma_sword/held_long.png` (also `held` 287, `pickup` 296, `held_55/plasma_sword` 224, showcase 421-483) | the plasma sword's red-ringed hilt: two orange-red rings on the grip, seen in `deflect_blade_after_64_crop.png` (92 px there) | 378 | other | grip rings to steel/amber; plasma is not danger |
| 16 | `held_55/*.png`, `showcase/{icon,p55,p70}/*.png`, `<weapon>/held,pickup,mag.png` (about 120 files, 1-1000 px: rocket launcher 2324/4534, mini-nuke 2562/6304, chainsaw, machine pistol 1128, electro gun 759-2028, ray gun 1567-2019, homing shard 1310-2177, gatling tank 496) | weapon item and held art with orange-red details (labels, warheads, stripes, tank caps) | see `count_red.py` | other | pickups are vermilion-allowed (palette `pickup`); held art: audit by eye later |
| 17 | `boot/collect_call/view/cast_view.gd:157,176` | Mertz's tazer barrel stripe and the charging prong sparks (`Ink.zigzag(..., Ink.VERMILION)`) | #E8502A | E | amber (electric current) |
| 18 | `boot/collect_call/view/fx_view.gd:132` | the burst-arc zigzag (arena `burst_arcs`), vermilion + cream | #E8502A | E | amber |
| 19 | `boot/collect_call/view/stage_view.gd:201` | the TUCK-IN lightning bolt glyph | #E8502A | E | amber |
| 20 | `boot/collect_call/view/cast_view.gd:93` | Rivet struck: `_impact` star rim vermilion | #E8502A | D (hit_flash is a palette vermilion use) | keep |
| 21 | `boot/collect_call/view/fx_view.gd:101,104`; `squad/foe_shield_view.gd:58-65`; `squad/foe_walker_view.gd:70` | aim tell lines, shield lane, walker ring | #E8502A | D | keep (danger cues) |
| 22 | `boot/collect_call/view/stage_view.gd:172`; `objective_view.gd:83,100` | ringing payphone, objective ring and arrow | #E8502A | D (objective) | keep |
| 23 | `kills/kill_burst_fx.gd:13` MIST, `kills/kill_split_fx.gd:10` RAW, `kills/kill_mark_art.gd:8` BLOOD, `fx/corpse_stains.gd`, `fx/noir/blood_stains.gd` | blood mist, raw cut, stains | (0.72,0.06,0.08) etc | B | fine |
| 24 | `weapons/art/gore/*.png` (chunks, stump, saw_chunks, plasma_hole, splash, cut_face, exit_wound, char_collapse_*, xray_*) | gore decals | 1-926 | B | fine |
| 25 | `combat/art/d5/{boss_intro_king 122182, finisher_lightbar 60222, finisher_drone 28999, finisher_k9 18009}.png` | 1920x1081 finisher / boss intro stills; no `.gd` or table loads them (only `art_src/d5.manifest.json` and night-d5 docs name them) | 18k-122k | A | not in game; check before they ship, the lightbar must be cop blue |
| 26 | `data/tables/flame_embers.json:11` | ember rim `#EE6A1C` (orange, not vermilion) | #EE6A1C | F | amber-orange: keep |
| 27 | `data/tables/palette.json:126` `E8502A` = vermilion, `:138` `A30509` = blood | the tokens themselves | - | - | the source of rows 13-22 |
| 28 | `weapons/art/fx/colour/spark_0,1,2.png` | the colour spark cells | 2 / 5 / 6 | - | negligible |

Notes. The deflect path itself is clean after `7e95d96fb` (`PlayerDeflect.TURNED` skips the stand-in flash): the spark
is cream and ink. Row 7 is the only row that was on screen at a deflect. Rows 5-10 matter wherever Rivet or a cop fires;
the muzzle star core is the vermilion "flash" of the d4 sheet, so one repaint (core to amber or cream) clears rows 5-10 at
once. Nothing here was changed; art PNGs are forbidden in this call.
