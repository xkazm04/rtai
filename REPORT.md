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

Gates it2: director reel after the legs ON top/tilt70/combo 19/19 down, 0 SCRIPT ERROR
(`evidence/d9-seams/director-reel-it2-*.log`); evidence at e8c6ad01 (bikes 0.06): lint, unit
1705/0, scenarios 52/52, parity, release-compile 601/0 pass, selftest FAIL (top look goldens 2/11);
selftest alone at share 0: look goldens 11/11 (worst 0.27). Evidence at eac11147 (share 0): lint,
scenarios 52/52, parity, selftest (look goldens 11/11), release-compile 601/0 PASS; unit 1705 passed /
0 failed but marked FAIL by the tree-changed guard (I edited REPORT.md during the run; no test failed).
Logs `evidence/d9-seams/evidence-it2-*.log`.
Gates it1: lint 15/15; unit no-arg 1696 passed / 0 failed (at 966a2a79);
director reel (`--fixed-fps 60 --quit-after 14000`) top 19/19, tilt70 19/19, combo 19/19 down,
0 SCRIPT ERROR (`evidence/d9-seams/director-reel-it1-*.log`). Not yet run: `tools/evidence/run.mjs --no-bench`.

## What does not work yet
- The King's legs at 70 (king_legs_70 drawn ~40 % too tall; v2 asked of assets).
- The sim bike has no rider (REQUEST `bike_rider_55/70/top` to assets); it is off by default.
- Item 5 (armed city cops walk): both armed sheets cut cleanly at 70 (scratch); wiring next.
- After merge, rebuild native (`just native`): `project/native/bin` is git-ignored, and the old DLL
  would treat bikes as cars (no crash; parity would fail).

## Calls for the owner
1. **The King's legs meet the bust.** Built (it2, ON at 55): the bust and his arms rise half the legs'
   cell onto `king_legs_55` (the legs scaled with the bust: cell width = the bust's cell width), the
   hem over the legs' hips; he is a head taller than before. Still: `king_drawn_legs_before_after_combo_64ppm_seed2_f150_x2.png`.
   Options: (a) the built 0.5 lift; (b) a smaller lift (`KingLegsCard.LIFT`, e.g. 0.35: shorter legs
   showing, the hem lower); (c) legs hidden under a longer drawn robe (an asset ask); (d) off
   (`KingLegsCard.ON` false: the rim-stripped parts, it1).
2. **A corpse that fell "through" the barrier** reads as lying behind it (its boots show north of
   the barrier, the rest is hidden). Default built. Option (sim work, not built): stop a falling
   body at a wall.
3. **The sim bike in traffic.** Default built: share 0 (no bikes), because bikes in traffic move the
   `top` look goldens (selftest 2/11 at 6 %), and `top` must not move. Options: (a) bikes on at 6 %
   (`traffic.bike_share` 0.06) and rebaseline the top look goldens now; (b) on at the switch to combo
   (the goldens move then anyway); (c) a higher share. Riderless until assets serve `bike_rider_*`.
   See: `RTAI.exe` is the showcase (arena); the traffic is the main scene:
   `"$GODOT_BIN" --path project -- --view=tilt70 --seed=7 --rigs --bikes=0.25` (and without `--view` for top).

## Next steps
See JOURNAL `NEXT:`.
