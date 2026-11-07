# REPORT: night lane `vehicles` (n8, 2026-11-06 20:00 to 2026-11-07 09:00)

DRAFT written in iteration 18 (04:50); the freeze session completes it (exe, final gates).
Branch `n8-vehicles`. Evidence: `evidence/n8-vehicles/` (gate logs, bench, identity md5s) and the
masters in `C:\Users\kazda\kiro\gtai-masters\n8\vehicles\` (`frames.json`, 15 entries, best first).
The view lane's REPORT.md came in with the n8-view merge; this file replaces it on this branch
(take view's from `n8-view`).

## What works (with its evidence)

1. **The technique: a rotation set, not a slice stack** (decision 2026-11-06). Every car is one
   MultiMesh card from the library's drawn turntable views: at 70, nine drawn views a half turn
   (five sheet views + the asset lane's four 22.5-degree in-betweens) + mirrors, so a card turns at
   most 11.25 deg off its drawing with a hard swap (no cross-fade ghosting). At 55, five views +
   three mirrors (boss arenas park few cars). Wheels, glass, lamps and a ground shadow are in the
   art; the flat ink shadow stays under the card. 360-degree turns filmed at 32 and 64 px/m:
   `turn360_tilt70_64ppm_between_before_after.mp4`, `turn360_tilt70_64ppm_street_between_before_after.mp4`.
2. **The set:** sedan (three variants + grey), taxi, van (also the depot van; cream since it19, the
   top print's paint, one cream through its 64 px/m turn), parked pickup,
   ambulance, police car (police-blue light bar that flashes above 1 m/s), and the bike (atlas row
   9, both pitches, showcase only: the sim has no bike). All keyed by the view row's art key
   (`p70` / `p55`): `top` draws today's flat atlas, bit-identical (framemd5 seed 2, it18).
3. **Damage, fire, skids at height:** wear in the card shader (dents D1, spread D2, burnt wreck);
   the wreck fire on the vehicles band; skids on the ground under the shadows
   (`damage_tilt70_64ppm_ba_f500.png`, `fire_tilt70_64ppm_closeup_before_top_after_bottom.png`).
4. **Depth:** a card with someone just in front draws under the actors, else over
   (`depth_tilt70_48ppm_ba_still.png`); stage cars (Servo depot, powers pad) stand over the actors
   with the seize cues and bay 3's number drawn over them (view's 1dd745b8 + 73a78455 merged:
   `servo_bay3_mark_over_van_combo_64ppm_f120_before_left_after_right.png`).
5. **Kerb-parked cars** as cards through city's ChunkLift hand-off (`VehicleParked.live`).
6. **Colour law:** no red lamps (red lens segments amber in the cutter; lit lenses LAMP_DEG; the
   unlit rear lenses, which printed rust-red under the city grade, DARK_LAMP_DEG in it18:
   `sedan_unlit_rear_lenses_before_left_after_right_city_tilt70_32ppm_seed13_f180_crop4x.png`); the
   taxi turned off vermilion (TAXI_HUE); police blue only on the police car.
7. **Cost (brief item 5):** on the real drive the traffic cards cost ~0.06 ms of script per frame
   over `top` after two fixes (reach-bounded sim query, no hidden overlays), GPU and draw calls
   within noise, 0 hitches (`evidence/n8-vehicles/bench-it17/`). `bench-it16` measured the view's
   drive WITHOUT the cards (city_bench builds no VehicleView); read it as the view's cost only.
8. **Gates (it18, 2bcfdc56):** unit 1549/0 no FLAKY; director reel 19/19 all down in `top` and
   `tilt70`, 0 SCRIPT ERROR; lint 15/15; `top` framemd5 identical; scenarios: see JOURNAL.

## What does not work / not done
- The delivery truck and the dedicated depot van (library `delivery_truck_70` A, `depot_van_70` A,
  an ochre courier van with hazard bumpers) have no sim archetype and no top-down print: they are
  not cut. Servo's stage van and the city's vans draw the van row (cream). See Call 9.
- The bike has no sim archetype: it draws only in `dev/showcase/vehicle_turn.tscn`.
- The driven car's hijack enter/exit keeps Rivet's current rig (Rivet frozen tonight).
- The main scene ignores `--ppm`: city stills at 48/64 px/m come from the showcases, not the drive.
- Bay 3's pale number fades over the cream van roof at 32 px/m in the Servo depot (REQUEST to view:
  an ink stroke on the bay numbers; `van_cream_servo_depot_combo_32ppm_seed2_f130_olive_left_cream_right_crop.png`).

## Calls for the owner
Each: options, the default built, how to see it.
1. **Taxi paint:** (a) the 2021 sheet turned +12 deg (built); (b) +16; (c) the asset lane's
   taxi_70_v3 sheet, a native cab yellow (`TAXI_SHEET = True` in `tools/art/vehicle_cards.py`, then
   re-cut). (c) reads better by eye but the palette's vermilion gate counts 538 px of its gold
   shading vs 195. See `taxi_sheet_v3_built_left_v3_right_city_tilt70_32ppm_seed13_f180_crop3x.png`,
   `taxi_sheet_v3_turn_tilt70_64ppm_built_left_v3_right.mp4`.
2. **Lit amber lamps vs the vermilion gate:** the lit lens prints (233,140,0), amber to the eye,
   but the gate counts it. (a) the gate learns lit amber (built: lamps LAMP_DEG 10); (b) the lamps
   go yellow (LAMP_DEG 14 barely helps: 351 -> 333 px). See
   `taxi_lamps_lampdeg10_left_14_right_city_tilt70_32ppm_seed13_f180_crop3x.png`.
3. **The bike:** (a) showcase only (built); (b) a sim archetype with art id 9 (sim work). See
   `bike_turn_strip_tilt70_64ppm.png`.
4. **Wreck fire:** size as built; its vermilion cores kept as a danger cue (decision 2026-11-07).
5. **Rotation density:** nine views on every p70 row (built) vs five.
6. **Van / depot van colour:** (a) olive cards (`VAN_SHEET = False` in `tools/art/vehicle_cards.py`,
   then re-cut); (b) a paint gain; (c) the cream repaints, matching the top-down print (built since
   iteration 19: van_cream_70 + its in-betweens, van_cream_55). The cream reads as a van on the depot
   floor where the olive printed a brown block; it costs bay 3's number contrast at 32 px/m. See
   `van_cream_servo_depot_combo_64ppm_seed2_f120_olive_left_cream_right.png`,
   `van_cream_turn_tilt70_64ppm_olive_left_cream_right.mp4`.
7. **Pickup's C in-between:** row C (built) vs the better-turned `_c` redraw (`PICKUP_C_REDO`).
8. **Stage cars over the actors:** ON (built) vs under.

9. **Servo's stage van:** (a) the city van row, cream, matching its top-down print (built); (b) the
   library's ochre `depot_van` as a new atlas row for the stage only (needs a top-down print too, or
   `top` and the card disagree again). See `van_cream_servo_depot_combo_64ppm_seed2_f120_olive_left_cream_right.png`.

## Exe
(at the freeze) `build/export/windows/RTAI.exe`, with the command lines.

## Next steps
- A sim bike; the 55 van in-betweens (`VAN_BETWEEN_55`, sheets exist) and other p55 in-betweens if bosses
  park turning cars.
