# REPORT: d9 lane `seams` (final, freeze 18:30)

Branch `d9-seams`. Evidence: `C:\Users\kazda\kiro\gtai-masters\d9\seams\` (`frames.json`), logs in
`evidence/d9-seams/`. Journal: `JOURNAL.md`.

## The exe (freeze, it11)
`build/export/windows/RTAI.exe` (+ `gtai_sim.windows.template_release.x86_64.dll` beside it), exported at
b51247bb (code = b026010d) with
`"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
(exit 0, 28 s). Smoke: `RTAI.exe --headless --fixed-fps 60 --quit-after 600 -- --boss=king --phase=1 --bot=boss
--seed=2 --rigs --view=combo`: exit 0, 0 SCRIPT ERROR (the engine's known shader-sampler ERROR line only).
Try the King and his gang: `RTAI.exe -- --boss=king --phase=1 --view=combo` (and `--phase=3` for his stride).

## Merge note for the Director
vs d9-rivet e2400dc4: conflicts only `JOURNAL.md` (add/add: keep either lane's, they are lane journals) and
`tools/debt/baseline.json` dev_loc (both lanes accepted rises from 18799: keep both lines, chained: seams
18799 -> 18805, then rivet +69 -> 18874; total 18874), then `node tools/debt/debt.mjs --update`. Trial merge
it11 gates: MERGE_GATES.

## What works (with evidence)
1. **The dead behind the arena's kerb barrier** (item 1, commit 38a90b52). Measured cause: the two
   dead cops were still full rigs (hiding the dead rigs emptied the frame), fallen south onto the
   barrier; PropOcclusion boxed every body as standing. `PropLying` boxes a corpse from its ground
   point to its drawn head; the barrier is redrawn over it. Hidden body-frames 2 -> 95 / 901 frames,
   0 SCRIPT ERROR. City's agreed `CityOcclusion.extra` seam is landed and fed with the arena's tall
   props (`PropCrowdOccluders`) for the baked crowd. `kerb_corpse_before_after_tilt70_{32,48}ppm_*`.
2. **The King's legs, quick half** (item 2, 493d845c). The cream backing was RivetPlan's leg
   sticker rim inherited by KingPlan (the PNGs are ink-outlined); off under every card view, kept
   in `top`. `king_legs_rim_before_after_combo_{64,32}ppm_*`. Drawn legs: REQUEST to assets
   (`king_legs_55/70`, layout in JOURNAL).
3. **The 55 planter** (item 4, 3272969d): planter_v3 cut with city's tool (byte-identical to n8's
   checked cut), provenance line. `planter_p55_v2_vs_v3_and_p70_strips.png`. In-game frame owed.
4. **The King on drawn legs** (item 2b, 7f522e54, it2): `KingLegsCard` ON at 55 (the fight's pitch:
   combo eases to 55 at the engage). The whole torso (the 2.0x bust card AND the arm parts: the press
   plates at his sides) rises 0.5 of the legs cell onto `king_legs_55`; the legs card is pinned to the
   ground point, its column and flip follow the bust's facing, rows 1-4 step by the gait.
   `king_drawn_legs_before_after_combo_64ppm_seed2_f150_x2.png`, `king_drawn_legs_combo_64ppm_seed2.mp4`,
   the 4-beat grid and the 32 px/m pair. 70 keeps the rim-stripped parts until `king_legs_70` v2.
5. **A sim bike** (item 3, e8c6ad01 + 84a774a5, it2): art id 9 under K_CAR in the native core and
   its GDScript twin (hull 1.0 x 0.375 m, person footprint 1.25 x 0.625 m, contact reach 1.75 m, it
   takes 7/8 of a car overlap = mass 200 vs 1400; car vs car keeps its exact old path), a `bike`
   profile in vehicle_handling.json (a hijacked bike drives on it), the share drawn from its own rng
   stream (`city_bikes`), the 3 x 4 traffic atlases with its plan print for `top` (cream/ink duotone
   from the 70 card's tail facing, `tools/art/bike_top_print.py`); card views draw row 9. Parity:
   native == reference bit for bit over 1200 steps with a quarter of the parity traffic bikes.
   **Ships at share 0** (see Call 3): `--bikes=0.25` shows them.
   `sim_bike_top_vs_tilt70_32ppm_seed7_f420_x2.png`, `sim_bike_{tilt70,top}_traffic_seed7_bikes025.mp4`.
6. **release_compile per worktree/pid** (item 6, 6e49a298): two passes in parallel in one
   worktree, 599 loaded / 0 failed each, both scratch dirs removed (`evidence/d9-seams/`).
7. **Armed city cops walk as drawn figures** (item 5, 49ad9fd6, it3): `StreetCopWalk`: at 70 every
   living patrol cop (cap) and riot cop (helmet) draws its armed walk grid (pistol two-handed; baton +
   shield), 5 facings x 4 stride frames by the gait phase, the stand frame when still, instead of a head
   card gliding over parts. The grid holds through aim and fire (no swap per shot); a baton strike, a
   throw or a reload shows the parts. Art: cop_patrol_walk_armed_v2 (B) and cop_riot_walk_armed_v4 (A),
   toned to the cop cards' navy; the riot sheet's orange armband greyed (vermilion is reserved,
   `tools/art/street_armband.py`). `cop_armed_walk_before_after_tilt70_48ppm_seed5_f400_x1.5.png`,
   `cop_armed_walk_before_after_tilt70_32ppm_seed5_f400.png`, `cop_armed_walk_tilt70_48ppm_seed5_{before,after}.mp4`.
   Not yet: SWAT cops and every 55 cop (no armed sheets: REQUEST to assets).
8. **The sim bike has a rider** (item 3, f9f348b6, it3): card row 9 from bike_rider_70/55 (A), the
   `top` print from bike_rider_top_v1 (A, cream/ink duotone). Only row 9 / cell 9 landed (the other
   rows byte-identical). `sim_bike_rider_top_vs_tilt70_32ppm_seed7_f420_x2.png`, `..._crop3x.png`,
   `sim_bike_rider_{top,t70}_32_seed7_bikes025.mp4`.
   Close-up it9 at 64 px/m (a real 64 px/m render, not a crop): `sim_bike_rider_tilt70_vs_top_64ppm_seed7_bikes025_f380-500.mp4`
   + `sim_bike_rider_tilt70_vs_top_64ppm_seed7_f430-485_x12.png`.
9. **The King's drawn legs at 70** (item 2, 4aa2a0e0, it3): king_legs_70_v3 (A, no hip ring) under the
   70 bust with a per-pitch lift (`KingLegsCard.LIFT` {55: 0.5, 70: 0.74}: the hem over the thigh tops);
   55 now on king_legs_55_v2 (A, the profile strides). `king_legs70_before_after_tilt70_{64,32}ppm_seed2_f150_x{2,3}.png`,
   `king_legs70_tilt70_64ppm_seed2.mp4`, `king_legs55v2_combo_64ppm_seed2.mp4`. The pelvis part now
   hides with the leg parts (bb7077f5: it showed as a rimmed disc between the boots under the lifted
   bust): `king_pelvis_before_after_combo55_tilt70_64ppm_seed2_f150_x2.png`.

10. **Every armed city cop walks drawn, SWAT included and at 55** (item 5, ffbb9c44 + d6ffd600, it4):
   at 70 the SWAT walk on swat_walk_armed_70_v2 (B) with the asset lane's fresh profile row (round
   1315, A) spliced in, so all 5 facings alternate; at 55 the patrol, riot and SWAT cops walk on the
   round-1310 sheets (B) with the asset lane's fresh rows spliced in (e6ba3ec3: patrol r3, riot r3-r4,
   SWAT r2-r4, rounds 1320-1330), each toned to its own card's navy. `StreetCopWalk.FILL` is keyed per pitch. No living city cop draws a head card
   over parts at either pitch any more (a baton strike, a throw or a reload still shows the parts).
   `cop_armed_walk55_before_after_tilt_48ppm_seed5_f400_x1.5.png`, `..._32ppm_seed5_f400.png`,
   `swat_armed_walk70_before_after_tilt70_48ppm_seed5_f400_x1.5.png`, 6 s clips before/after.
11. **The 55 planter in the streamed city** (item 4, filmed it4, 6f28481c): `city_frame` focus 11 is
   a plaza with two planters; under `--view=tilt` the v3 box with its front face replaces v2's flat
   print. `planter55_before_after_tilt_64ppm_cityframe11.png`, `..._32ppm_cityframe11_crop2x.png`.
   Seen: at 32 px/m v3's plants read as a dark mass (v2's leaves were brighter); fixed it6 (14).

12. **Servo's bay number no longer prints over the fighters** (the rivet lane's REQUEST, 3f4732db, it5):
   under a card view each bay's apron mark still draws over the vehicles band (so the parked stage van
   shows bay 3, the n8 fix), except while a living fighter's body box meets the number's glyph: then
   that mark draws on the ground, under the bodies (`ServoDepotDraw.cover`). `top` unchanged.
   `servo_bay_number_under_bodies_before_after_combo_48ppm_x2_seed1_f480.png`, `..._f400_500.mp4`.
13. **No size pop on the SWAT and riot 55 turns** (item 5, ddef1441, it5): the round-1320 3/4-toward row was drawn
   small (helmet 52 px vs 57-61, head line 12 px low); scaled 1.06 about each sole with a new tool
   (`tools/art/walk_facing_scale.py`), FILL 1.08 -> 1.07; the riot 55 profile row (round 1330) the same way (head line 24 -> 13 px, FILL 1.09 -> 1.08).
   `swat55_facing2_scale106_before_after_grid.png`, `riot55_facing3_scale106_before_after_grid.png`.
   In play: `swat55_facing2_scale106_before_after_tilt_48ppm_seed5_f2_x3.png` (the crosswalk SWAT on that
   facing, frames 1-12), `riot55_facing3_scale106_before_after_tilt_48ppm_seed5_f62_x3.png`.

14. **The planter's leaves read at the shipped zoom** (item 4, 36d9b37b, it6): the world print turned
   planter_v3's leaves (lum 0.46) and brown soil (0.20) into its mid and dark washes, so at 32 px/m the box
   printed as one dark block at both pitches (the n8 p70 strip too). `tools/art/planter_value_lift.py` lifts
   the leaves into the light wash and the soil (at half chroma: a guard keeps it off the vermilion plate) into
   the mid wash; ink, concrete and outline unchanged; `top` untouched (card views only).
   `planter_value_lift_before_after_p70_p55_32ppm_cityframe11_x3.png`, `..._64ppm_cityframe11.png`.

15. **The King's press plates lose their cream rim** (item 2, 2ef868fc, it6): his arm parts (the gold
   plates at his hips under the lifted bust) carried the same cream sticker rim the owner named on his
   legs; off under every card view (`BodyPlan.arm_rim`), `top` and Rivet unchanged.
   `king_arm_rim_before_after_combo_{64,32}ppm_seed2_f150_x3.png`.
16. **The two d9 lanes merge clean** (it6): a scratch merge of d9-seams (6fba6bcd) and d9-rivet's head
   conflicts only in JOURNAL.md (add/add: keep both); `prop_occlusion.gd` (touched by both) merges on
   disjoint hunks and the two changes are compatible. On the merge: lint 15/15, unit 1730/0,
   release-compile 605/0, scenarios 52/0, director reel top/tilt70/combo 19/19, 0 SCRIPT ERROR
   (`evidence/d9-seams/director-reel-merge-it6-*.log`, `mergetrial-it6-gates.txt`); still
   `merge_trial_seams_rivet_king_combo_64ppm_seed2_f150_f250.png`.
17. **Spliced walk rows keep a level head** (item 5, d84ad031, it7): the library draws every walk row with
   all four heads on one line (the passing frames' feet rise); my it4 splice stood the fresh rows on the
   foot line instead, so the head dipped 3-7 px at each passing frame (SWAT 55 3/4-toward 7, SWAT 70
   profile 5, riot 55 profile 3). `tools/art/walk_splice_rows.py` hangs them from the head line; every
   recipe was first reproduced byte-exact. The patrol 55 takes the library's fresh rows 2 and 5 (both now
   alternate). Board clips `walk_headline_before_after_{swat_riot70,swat_riot55,patrol55}_board_*_64ppm.mp4`,
   grids `armed_walk_grids_headline_before_after_cells.png`.
18. **The riot 55 turn toward the camera alternates its stride** (item 5, a1580b10, it7): row 2 from the
   library's copy-by-example v3b (A); the old row drew frame 3 as frame 1 (a named fault since it4).
   `riot55_row2_before_after_cells.png`. Every living city cop's walk now alternates in all five facings
   at 55.
19. **The jogger and the shopper walk the library's fixed sheets** (beyond the brief, a3ff1c51, it7): the
   jogger's walk was at a shallower camera than her still card (long legs, small head: she changed shape
   on starting to jog); v3 matches the card. The shopper's every facing now alternates its stride.
   `peds_jogger_shopper_before_after_board_tilt70_64ppm_f150_x2.png` + clip,
   `jogger_still_vs_walk_v1_vs_v3_cells.png`. Owner eye: the shopper's new profile row sits at a slightly
   shallower camera than her other facings.
20. **Quest 1's patrol walks alternate its stride** (item 5 kin, a95de60e, it7): the walking patrol cops of
   quest 1 take the library's cop_patrol_walk v4 (A, both pitches); v1 repeated two rows and copied a
   frame on the 3/4-away row. `quest_patrol_walk_v1_vs_v4_p55_p70_cells.png`.

21. **The city crowd walks the library's fixed walk rows** (item 5 kin, c159e9d5 + 324dac8a, it8): the asset
   lane served my REQUEST with one game-ready cells folder per 70 ped walk; cap, elder, hat, hood, punk,
   suit, worker and jogger take their fresh rows (hung from the head line), so every facing alternates
   its stride (several old rows repeated frame 1 as frame 3). The crowd board got `--spin` (16 walkers,
   16 headings) so every facing is filmed, not just the profile:
   `crowd_walk_cells_it85_before_after_spin_tilt70_64ppm.mp4` (left before, right after), grids
   `crowd_walk_cells_it85_old_vs_new_grids_p70.png`. Weak row named by assets: elder 3/4 away (a small
   alternation; kept).
22. **Quest 1's patrol cop keeps its stride between sim ticks** (90e9a69c, it8): it stood only when its
   point did not move since the previous render frame; on a display over 60 Hz most frames have no sim
   step, so it flicked to the standing card. Now 4 frames with no step stand (unit-tested). Filmed in
   quest 1 at `--fixed-fps 240` (4 render frames per tick): before, the standing card on 3 frames of 4
   (a hard flicker on any 120/144/240 Hz monitor); after, a steady walk:
   `quest1_patrol_hold_before_after_240hz_tilt70_48ppm_quarter_speed.mp4` (+ `_16frames.png`). The
   quest 1 clip tool cannot show it (it steps between every frame: pixel-identical).

**The set in one clip:** `seams_d9_set_combined_63s.mp4` (63 s, captioned per item; it8 adds the crowd walk cells, it11 the gang's steel legs).

Gates it6: evidence at 2ef868fc (arm rim): all PASS, lint 15/15, unit 1717/0, scenarios 52/52, parity,
selftest 11/11, release-compile 602/0 (`evidence/d9-seams/evidence-it6b-2ef868fc.log`); director reel at
2ef868fc top/tilt70/combo 19/19 down, 0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it6-*.log`). Evidence at b2b5c9b9 (the planter lift): lint 15/15, unit 1717/0, scenarios 52/52, parity
bit-exact, selftest look goldens 11/11 (worst 0.27) + block 5/5, release-compile 602/0, all PASS
(`evidence/d9-seams/evidence-it6-b2b5c9b9.log`). Gameplay code unchanged since the it5 reels.
Gates it5: evidence at ddef1441 (Servo marks + SWAT 55 scale): lint 15/15, unit 1717/0, scenarios 52/52,
parity bit-exact, selftest look goldens 11/11 (worst 0.27), release-compile 602/0, all PASS
(`evidence/d9-seams/evidence-it5-ddef1441.log`); director reel at 3f4732db top/tilt70/combo 19/19 down,
0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it5-*.log`).
Gates it4: evidence at 16eb6d86 (55 patrol/riot + SWAT 70 v2): lint 15/15, unit 1713/0, scenarios
52/52, parity bit-exact, selftest look goldens 11/11 (worst 0.27), release-compile 602/0, all PASS
(`evidence/d9-seams/evidence-it4-16eb6d86.log`; again all PASS at 6110bbf9 with the 55 fresh rows:
`evidence/d9-seams/evidence-it4-6110bbf9.log`); director reel at 16eb6d86 top/tilt70/combo 19/19
down, 0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it4-*.log`).
Gates it3: director reel at 4aa2a0e0 top/tilt70/combo 19/19 down, 0 SCRIPT ERROR
(`evidence/d9-seams/director-reel-it3-*.log`); evidence at f74bb3ed (items 5 + the rider): lint 15/15, unit 1711/0, scenarios 52/52,
parity bit-exact (bikes in it), selftest look goldens 11/11 (worst 0.27), release-compile 602/0, all
PASS (`evidence/d9-seams/evidence-it3-f74bb3ed.log`); unit no-arg at cf2bae52 1713/0.
Gates it2: director reel after the legs ON top/tilt70/combo 19/19 down, 0 SCRIPT ERROR
(`evidence/d9-seams/director-reel-it2-*.log`); evidence at e8c6ad01 (bikes 0.06): lint, unit
1705/0, scenarios 52/52, parity, release-compile 601/0 pass, selftest FAIL (top look goldens 2/11);
selftest alone at share 0: look goldens 11/11 (worst 0.27). Evidence at eac11147 (share 0): lint,
scenarios 52/52, parity, selftest (look goldens 11/11), release-compile 601/0 PASS; unit 1705 passed /
0 failed but marked FAIL by the tree-changed guard (I edited REPORT.md during the run; no test failed).
Logs `evidence/d9-seams/evidence-it2-*.log`.
Trial merge it9 (d9-seams 67a7c264 + d9-rivet bd526bf9, scratch commit ab6b34f2, not a branch): lint 15/15, unit 1735/0, release-compile 605/0, director reel top/tilt70/combo 19/19 fully down, 0 SCRIPT ERROR (`evidence/d9-seams/mergetrial-it9-*.log`, `director-reel-merge-it9-*.log`). Conflicts: JOURNAL.md (add/add: keep both) and `tools/debt/baseline.json` (both lanes accepted a dev_loc rise from 18799: keep both lines, chain 18799 -> 18805 -> 18871, total 18871, then `node tools/debt/debt.mjs --update`). Still: `gtai-masters/d9/seams/merge_trial_it9_seams_rivet_bd526bf9_king_combo_64ppm_seed2_f250_city_tilt70_32ppm_seed5_f900.png`.
Gates it9: director reel at 5fa6baee top/tilt70/combo 19/19 fully down, 0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it9-*.log`); evidence at 0a950b56 all PASS (lint 15/15, unit 1722/0, scenarios 52, parity, goldens 11/11 + block 5/5, release-compile 602/0) (`evidence/d9-seams/evidence-it9-0a950b56.log`).
Gates it8: evidence at 90e9a69c all PASS (lint 15/15, unit 1718/0, scenarios 52, parity, goldens 11/11, release-compile 602/0) (`evidence/d9-seams/evidence-it8-90e9a69c.log`); director reel it8 at 90e5a006 top/tilt70/combo 19/19 down, 0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it8-*.log`).
Gates it7: evidence at a8940e1b all PASS (unit 1717/0, scenarios 52, parity, goldens 11/11, release-compile 602/0); director reel it7 19/19 x3, 0 SCRIPT ERROR.
Gates it1: lint 15/15; unit no-arg 1696 passed / 0 failed (at 966a2a79);
director reel (`--fixed-fps 60 --quit-after 14000`) top 19/19, tilt70 19/19, combo 19/19 down,
0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it1-*.log`). Not yet run: `tools/evidence/run.mjs --no-bench`.

23. **Traffic can stop for Rivet on foot** (Call 4 option b, 0a950b56, it9, OFF by default): his ground point
   goes first into the obstacle feed both sim twins already brake for, from the boot adapter; no native
   change, parity bit-exact. On, the van stops ~3 m short of him and the bike queues behind it (filmed
   before/after, tilt70 64 px/m, seed 7). Unit 4 tests, 4/4 hand-planted faults caught (one by a compile
   error). Evidence it9 at 0a950b56 all PASS.
   Scenario `traffic_yields_rivet` (real World, a car at 12 m/s at a standing Rivet): off 0.10 m (through him),
   on 2.44 m closest (stops, then pulls round him); scenarios 53 passed.

24. **The King's drawn boots keep pace with the ground** (item 2, f99bf5d6, it10): the legs card's walk row
   follows the distance walked over the sheet's drawn cycle (`KingLegsCard.CYCLE_CELL`: 55 two profile steps of
   116 cell px, 70 two of 40), not the old parts' gait phase. Probe in the real fight: the gait cycle is 64 world
   px against the 55 sheet's ~125 at his scale, so his boots ran at twice the ground speed. Same 349 walking
   frames (782 px): a new pose every 17.4 px (7.7/s) before, 26.1 px (5.2/s) after. A heavier, planted stride.
   `king_legs_stride_before_after_combo_64ppm_seed2_phase3_f200-420_x2.mp4`. 2 tests, 2 planted faults caught.
25. **The King's bodyguards on drawn legs, by decision** (item 2, d561498d + 6220e46f, it10): found filming
   phase 1 (every earlier King take was phase 3, after the gang falls): since it2 the four bodyguards stood
   on small copies of the King's drawn legs (`KingArt.dress` runs for every court rig). Fixed to their own
   parts first, then judged: on their gang_parts legs they sprawl grey top-down limbs with a pale rim under the
   upright bust; on drawn legs they read as upright figures. Kept the drawn legs (`KingLegsCard.SHEETS`),
   the parts one value away; `gang_legs_55/70` asked of assets. Call 5.
   `king_gang_own_legs_before_after_combo_{64ppm_seed2_phase1_f200,32ppm_seed2_phase1_f200_x3}.png`.
26. **The King's bodyguards on their own steel legs** (item 2, b026010d, it11): assets served `gang_legs_55/70`
   (grade A, round 20261107-1820) to the it10 REQUEST, a copy by example of the King's sheet (same canvas, cells,
   hip and sole lines): gunmetal steel, black joints, a thin gold ring at knee and ankle, ink outline only, no
   rim. `KingLegsCard.SHEETS["gang"] = "gang_legs"`. Filmed phase 1, combo, seed 2, 64 and 32 px/m: before, royal
   purple-and-gold legs under steel bodies; after, the legs carry the torsos' steel and the royal dress is the
   King's alone. Gates at b026010d: reels 19/19 x3 fully down, 0 SCRIPT ERROR; evidence at b026010d all PASS (lint 15/15, unit 1727/0, scenarios 53, parity bit-exact, look goldens 11/11 + block 5/5, release-compile 602/0).
   `king_gang_steel_legs_before_after_combo_64ppm_seed2_phase1_f150-420.mp4` (+ `_f200.png`, `_32ppm_..._x3.png`);
   at 70 (tilt70, play): `king_gang_steel_legs70_before_after_tilt70_64ppm_seed2_phase1_f200.png`. The King's 70
   stride after f99bf5d6 is filmed too: `king_legs_stride70_before_after_tilt70_64ppm_seed2_phase3_f120-480.mp4`.

## What does not work yet
- (closed it9, measured) The SWAT back rows (55 and 70, row 5) move the head 3 px (1.6 % of the figure) at 55
  and 5 px (2.8 %) at 70, a regular two-per-stride bob (2/7/3/7 px from the cell top), about a walking
  head's own rise and fall; ~1.6 px at 32 px/m. Kept: not a fault. The riot 55 repeat is fixed (it7, item 18).
- (measured it9) The planter's world print is not an outlier among the 70 props: mean print density 0.67
  against 0.42-0.86 (bench 0.57, trash can 0.65, traffic cone 0.73, dumpster 0.86); lifting it alone would
  break the set. Left as is.
- The elder's 3/4-away walk row alternates weakly (the asset lane's named weak row; 4 fix asks failed).
- The sim bike is off by default (Call 3).
- Traffic drives through Rivet on foot by default (filmed it9 with the bike, 64 px/m, tilt70 and top): the city
  sim has no vehicle-vs-player contact (`CitySimBody` resolves people only). Pre-existing for every car (by code
  reading), not the bike's. A yield is built behind a flag (Call 4 b); a knock-down is not.
- After merge, rebuild native (`just native`): `project/native/bin` is git-ignored, and the old DLL
  would treat bikes as cars (no crash; parity would fail).

## Calls for the owner
1. **The King's legs meet the bust.** Built (it2, ON at 55): the bust and his arms rise half the legs'
   cell onto `king_legs_55` (the legs scaled with the bust: cell width = the bust's cell width), the
   hem over the legs' hips; he is a head taller than before. Still: `king_drawn_legs_before_after_combo_64ppm_seed2_f150_x2.png`.
   it3: at 70 (play, before the ease) he stands on king_legs_70_v3, the bust raised 0.74 of the
   foreshortened 70 cell so the hem covers the thigh tops (`king_legs70_before_after_tilt70_64ppm_seed2_f150_x2.png`).
   Options: (a) the built lifts (55: 0.5, 70: 0.74); (b) a smaller lift (`KingLegsCard.LIFT`, e.g. 0.35: shorter legs
   showing, the hem lower); (c) legs hidden under a longer drawn robe (an asset ask); (d) off
   (`KingLegsCard.ON` false: the rim-stripped parts, it1).
2. **A corpse that fell "through" the barrier** reads as lying behind it (its boots show north of
   the barrier, the rest is hidden). Default built. Option (sim work, not built): stop a falling
   body at a wall.
3. **The sim bike in traffic.** Default built: share 0 (no bikes), because bikes in traffic move the
   `top` look goldens (selftest 2/11 at 6 %), and `top` must not move. Options: (a) bikes on at 6 %
   (`traffic.bike_share` 0.06) and rebaseline the top look goldens now; (b) on at the switch to combo
   (the goldens move then anyway); (c) a higher share. It now carries a rider at every pitch (it3).
   See: `RTAI.exe` is the showcase (arena); the traffic is the main scene:
   `"$GODOT_BIN" --path project -- --view=tilt70 --seed=7 --rigs --bikes=0.25` (and without `--view` for top).

4. **Traffic and Rivet on foot** (found it9 filming the bike close up): every vehicle passes through
   him, and while they overlap the depth sort flips between bike-over-Rivet and Rivet-over-bike. Default
   built: (a) as is, the n8 traffic (top, goldens, scenarios untouched). (b) is BUILT behind a flag (it9,
   0a950b56): `CityVehicleWorld.yield_to_rivet` (`--traffic-yields` to try it): cars brake for him as for a
   parked car and overtake mid-block; standing in a junction he holds traffic up (no overtaking there).
   Turning it on is one value, but it moves the city traffic, so scenarios/goldens get re-checked then.
   (c) cars knock him down (sim work in both twins, not built). Before/after:
   `traffic_yields_to_rivet_before_after_tilt70_64ppm_seed7_bikes025_f300-720.mp4` (+ `_f300-660_strip.png`).
   Try: `"$GODOT_BIN" --path project -- --view=tilt70 --seed=7 --rigs --bikes=0.25 --traffic-yields`.
5. **The King's bodyguards' legs** (it10, it11). Default built: (c) their own drawn steel legs (assets
   `gang_legs_55/70`, landed it11): gunmetal with a thin gold ring at knee and ankle, ink only. Options:
   (a) the King's drawn legs (purple and gold, `KingLegsCard.SHEETS["gang"] = "king_legs"`); (b) their n8 parts
   legs (drop "gang"): grey top-down limbs that sprawl under the upright bust, with a pale rim. Clip (left a,
   right c): `king_gang_steel_legs_before_after_combo_64ppm_seed2_phase1_f150-420.mp4`; (b):
   `king_gang_own_legs_before_after_combo_64ppm_seed2_phase1_f200.png`. Try: `RTAI.exe -- --boss=king --phase=1
   --view=combo` (or `"$GODOT_BIN" --path project res://dev/arena/arena.tscn -- --boss=king --phase=1 --view=combo`).

## Next steps
See JOURNAL `NEXT:`.
