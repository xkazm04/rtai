# REPORT: d9 lane `seams` (running; final at 18:40)

Branch `d9-seams`. Evidence: `C:\Users\kazda\kiro\gtai-masters\d9\seams\` (`frames.json`), logs in
`evidence/d9-seams/`. Journal: `JOURNAL.md`.

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
   step, so it would flick to the standing card. Now 4 frames with no step stand (unit-tested). Honest
   note: the quest 1 clip tool cannot show it (it steps between every frame: before and after are
   pixel-identical), and my it7 "flip" was the walk's passing frame; the fix is unfilmed in play.

**The set in one clip:** `seams_d9_set_combined_52s.mp4` (52 s, captioned per item).

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
Gates it8: evidence at 90e9a69c all PASS (lint 15/15, unit 1718/0, scenarios 52, parity, goldens 11/11, release-compile 602/0) (`evidence/d9-seams/evidence-it8-90e9a69c.log`); director reel it8 below.
Gates it7: evidence at a8940e1b all PASS (unit 1717/0, scenarios 52, parity, goldens 11/11, release-compile 602/0); director reel it7 19/19 x3, 0 SCRIPT ERROR.
Gates it1: lint 15/15; unit no-arg 1696 passed / 0 failed (at 966a2a79);
director reel (`--fixed-fps 60 --quit-after 14000`) top 19/19, tilt70 19/19, combo 19/19 down,
0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it1-*.log`). Not yet run: `tools/evidence/run.mjs --no-bench`.

## What does not work yet
- The SWAT back rows (55 and 70, the library's mirror-fixed row 5) let the head move 3-5 px over the
  stride (drawn, not a splice; left). The riot 55 repeat is fixed (it7, item 18).
- The elder's 3/4-away walk row alternates weakly (the asset lane's named weak row; 4 fix asks failed).
- The sim bike is off by default (Call 3).
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

## Next steps
See JOURNAL `NEXT:`.
