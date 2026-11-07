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
   `servo_bay3_mark_over_van_combo_64ppm_f120_before_left_after_right.png`). Bay 3's number reads
   over the cream van at 32 px/m since view's ink stroke (c3deecd3, merged it21 at 81762e2e):
   `servo_bay3_ink_over_cream_van_combo_32ppm_seed2_f60_before_left_after_right_crop3x.png`.
5. **Kerb-parked cars** as cards through city's ChunkLift hand-off (`VehicleParked.live`), in the
   city drive and, since it21 (dd288959, 7a993845), in quest 1 and the arena's city block too, where
   no VehicleView exists: the stage view claims the registry before the street is drawn, the cards
   stand in the vehicles band (Dock 9's kerb sedans were flat top-down prints at tilt70; filmed on a
   trial merge with n8-city: `quest1_dock9_kerb_cars_tilt70_32ppm_t13700_before_left_after_right_crop2x.png`,
   48 px/m `..._48ppm_..._crop.png`). Shows only once n8-city is merged (the hand-off is city code).
6. **Colour law:** no red lamps (red lens segments amber in the cutter; lit lenses LAMP_DEG; the
   unlit rear lenses, which printed rust-red under the city grade, DARK_LAMP_DEG in it18:
   `sedan_unlit_rear_lenses_before_left_after_right_city_tilt70_32ppm_seed13_f180_crop4x.png`); the
   taxi turned off vermilion (TAXI_HUE); police blue only on the police car.
7. **Cost (brief item 5):** on the real drive the traffic cards cost ~0.06 ms of script per frame
   over `top` after two fixes (reach-bounded sim query, no hidden overlays), GPU and draw calls
   within noise, 0 hitches (`evidence/n8-vehicles/bench-it17/`). `bench-it16` measured the view's
   drive WITHOUT the cards (city_bench builds no VehicleView); read it as the view's cost only.
8. **The soul's teal on a hijacked card** (it20, 80926b7c): the flat print marks a soul-hijacked
   car with a teal plate; under the card views that cue was gone (a plain sedan: 11 136 teal px in
   `top` at f320, 143 at tilt70). The card shader now paints the light paint teal (colour sampled
   from the plate; ink, glass, tyres and the amber lamp kept): the traffic car in the drive and
   Dent's seized van in the Servo depot read as the soul's, with the tether
   (`soul_seized_van_servo_depot_combo_64ppm_seed2_f120_before_left_after_right.png`,
   `soul_hijacked_traffic_top_left_tilt70_before_mid_after_right_f320_crop3x.png`).
9. **The delivery truck and the depot van (it22, 4c16951c):** library A sheets at 70 and 55 cut as
   five-view cards into their own showcase atlas (`art/p<pitch>/service_cards.png`; the shared
   traffic atlas is uncompressed and would grow 14 MB for art no scene draws yet). The truck's cab
   turned from amber-orange to mustard (vermilion-gate px 1463 -> 0). Filmed turning at 32 and 64
   px/m, 0 SCRIPT ERROR: `service_truck_depot_van_turn360_64ppm_tilt70_left_tilt55_right.mp4`,
   `service_truck_depot_van_turn_strip_tilt70_64ppm.png`. Run it from the editor build:
   `"$GODOT_BIN" --path project res://dev/showcase/vehicle_turn.tscn -- --view=tilt70 --ppm=64 --set=service`.
10. **Side views from the library's redraws (it22, 299d849f):** the taxi, pickup and ambulance sides
   at 70 now share the 3/4 views' steep camera (the old sides popped to a tall door band); the taxi's
   cab-yellow redraw is graded to its mustard neighbours.
   `street_side_redraws_turn360_tilt70_64ppm_before_top_after_bottom.mp4`.
11. **Gates (it21, 7a993845, after the n8-view merge):** unit 1563/0 no FLAKY; director reel 19/19
   all down in `top` and `tilt70`, 0 SCRIPT ERROR; lint 15/15; `top` framemd5 identical to it20;
   scenarios 52/0 (`evidence/n8-vehicles/iteration21.json`). `tools/evidence/run.mjs --no-bench`
   all PASS on aa086daa (it20; parity bit-exact, selftest goldens, release-compile 566/0); the
   freeze re-runs everything on its HEAD.

## What does not work / not done
- The delivery truck and the dedicated depot van have no sim archetype and no top-down print: since
  it22 they are cut as cards (both pitches) but draw only in the turn showcase. The truck is fitted
  into the shared 7 m card cell (~5.3 m long, not its drawn 6.4 m). Servo's stage van and the city's
  vans draw the van row (cream). See Call 9.
- The bike has no sim archetype: it draws only in `dev/showcase/vehicle_turn.tscn`.
- The driven car's hijack enter/exit keeps Rivet's current rig (Rivet frozen tonight).
- The main scene ignores `--ppm`: city stills at 48/64 px/m come from the showcases, not the drive.
- Quest 1 / arena-city kerb cards: a corpse lying on a kerb card's own footprint is covered by the
  card (the front grid counts living fighters; counting corpses was filmed and changed nothing).

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
   library's ochre `depot_van`, cut since it22 (`service_cards.png` row 1), for the stage only (needs
   a top-down print too, or `top` and the card disagree again). See the ochre van turning:
   `service_truck_depot_van_turn360_64ppm_tilt70_left_tilt55_right.mp4`; `van_cream_servo_depot_combo_64ppm_seed2_f120_olive_left_cream_right.png`.
10. **The soul-hijacked card:** (a) its light paint goes the soul's teal, like the print's plate
   (built: `soul_k = 0.85`, `soul_lo = 0.18` in `vehicle_cards.gdshader`); (b) no paint, the seize
   read by Dent's halo and tether only (`soul_k = 0.0`); (c) roof and hood only, sides kept
   (`soul_lo = 0.3`). See `soul_hijacked_traffic_tilt70_drive_before_left_after_right.mp4`,
   `soul_seized_van_servo_depot_combo_64ppm_seed2_f120_before_left_after_right.png`; in the exe:
   `RTAI.exe -- --boss=servo --view=combo --rigs` (Dent seizes the bay 3 van).

11. **The delivery truck's length:** (a) fitted into the shared 7 m card cell, ~5.3 m (built); (b) a
   per-atlas cell size in VehicleCards, the drawn 6.4 m (a runtime change; worth it once the sim has
   a truck). See `service_truck_depot_van_turn_strip_tilt70_64ppm.png`.

## Exe
`build/export/windows/RTAI.exe` (preset `windows-showcase`: boots the arena; embedded pck + the sim DLL
beside it). Export (10 s; dry run at 05:18 on e8a597e8, the freeze re-exports HEAD):
`"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
See the vehicles (`top` stays the default; add `--view=<top|tilt70|combo>`):
- Servo depot (the cream stage van, combo): `RTAI.exe -- --boss=servo --view=combo --rigs`
- King boulevard (parked cars at 55): `RTAI.exe -- --boss=king --view=combo --rigs`
- the city traffic at 70 is the main scene, which the showcase exe does not boot (its `--arena=city`
  is the arena hub, no traffic): `"$GODOT_BIN" --path project -- --view=tilt70 --seed=7 --rigs`,
  or export `windows-slice` (main scene, same path; the last export wins)
- the director reel: `RTAI.exe -- --bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`
Smoke-tested: `RTAI.exe --fixed-fps 60 --quit-after 200 -- --boss=servo --bot=boss --servo-ghost=dent
--view=combo --rigs --seed=2`, exit 0, 0 SCRIPT ERROR, the cream van seized at f130 (looked).
The turn showcase (`dev/showcase/vehicle_turn.tscn`) is a dev scene: run it from the editor build
(`"$GODOT_BIN" --path project res://dev/showcase/vehicle_turn.tscn -- --view=tilt70 --ppm=64`).

## Next steps
- A sim bike; the 55 van in-betweens (`VAN_BETWEEN_55`, sheets exist) and other p55 in-betweens if bosses
  park turning cars.
