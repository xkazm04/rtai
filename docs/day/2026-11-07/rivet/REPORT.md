# d9 rivet REPORT (in progress; the final at 18:40)

Lane `rivet`, branch `d9-rivet`: Rivet as whole-figure drawn frames per pitch, every weapon in his hands.

## What works (with evidence)
- **The frame set** (`f852d9b3`): the 36 owner-picked sheets cut into strips by
  `tools/art/rivet_frames.py --manifest=tools/art/rivet_frames.json` under
  `project/features/characters/art/view/<p70|p55>/` (`rivet_frames.png` 14 cells, `rivet_eq_<weapon>.png` 8 cells).
  Contact sheets: `C:\Users\kazda\kiro\gtai-masters\d9\rivet\rivet_strips_p70_contact_cut_fig110.jpg`, `..._p55_...`.
- **In the game** (`26aed6b4`, `19ddf549`): `RivetFrames` (features/characters/rivet_frames.gd) draws him as one
  figure under card views; the weapon's own strip while it is out; RivetHeldView's pasted part hidden then.
  Before/after: `gtai-masters\d9\rivet\rivet_before_after_city_tilt70_pistol_32ppm_x3_and_64ppm_x2_seed5_t120_300_400.png`.
- **Drawn left views for the one-handed holds at 70** (`1e00b083`, it6): the asset lane answered the REQUEST
  (`rivet_eq_<id>_70_left`, 6 A / 2 B); each is its own 3-cell strip `rivet_eq_<id>_left.png`, picked for the
  three left octants, weapon in his right claw, never mirrored. Still: `gtai-masters\d9\rivet\rivet_pistol_left_drawn_tilt70_64ppm_x3_t75_125_425_450.png`.
- **Plasma sword redraw** (`b2614b45`, it6; p55 `a2f9c77e`, it16): equipped 70_v2 (A) and 55_v4 (A: v3 was B, a
  claw on the emitter in view 1, fixed by the asset lane), both claws on the haft, blade about 2x. Stills:
  `gtai-masters\d9\rivet\rivet_plasma_sword_redraw_tilt70_64ppm_x3_t204_264_300.png`,
  `gtai-masters\d9\rivet\rivet_plasma_sword_55_v4_swings_tilt_p55_64ppm_seed3_t282_302_322.png`.
- **Left strips clean** (`ebacd1ab`, it16): 7 of 16 drawn left strips carried a neighbour figure's gun bell, flame or
  spark at a cell edge (a floating piece beside him on a left turn); all cut by component now; the p55 baton, homing
  shard and molotov left views are the library's A redos (tip spark; the gun in the far claw). Before/after:
  `gtai-masters\d9\rivet\rivet_left_strips_before_after_component_cut_p55_p70_16strips.png`.
- **Blade action rows sized** (it6): katana, plasma sword, chainsaw at both pitches (manifest `act_k`), the p55
  sword's overlapping swings cut by component (`--cc`). Contact: `gtai-masters\d9\rivet\rivet_blades_act_k_tuned_p70_p55_contact.jpg`.
- **Fire frames for streams and autos** (`657a4b28`, it6): a shot within 7 ticks draws the fire cell (the flamer
  stream holds it, no flicker). Still: `gtai-masters\d9\rivet\rivet_flamer_fire_cell_tilt70_64ppm_x2_t300_336_346_356.png`.
- **Drawn left views at 55 too** (it6): all 8 one-handed holds; no p55 fallback left. Contact:
  `gtai-masters\d9\rivet\rivet_left_views_p55_and_p70_v2_contact.jpg`.
- **Combo swap filmed at Servo's engage** (p55 at tick 32): `gtai-masters\d9\rivet\rivet_combo_swap_servo_engage_48ppm_x2_t26_30_32_40.png`.
- **No floating reload magazine** under the drawn figure (it6 fix): before/after in frames.json entries 5-6.
- **The muzzle from the drawn figure** (`f7334278`, `126b6a8c`, it7): with the held part hidden nothing
  published the muzzle, so the flash printed on the ground ~1.3 m off his gun and the tracer left from there.
  `tools/art/rivet_muzzle.py` measures each fire cell's drawn flash root (or the barrel's tip/centre where the
  sheet drew no hot flash) and each left strip's gun tip into `data/tables/rivet_muzzle.json` (84 points, both
  pitches); `RivetMuzzle` publishes the shown cell's point (mirrored with it) as HeldMuzzle. View only: the
  sim's shot origin does not move. Before/after: `gtai-masters\d9\rivet\rivet_muzzle_before_after_pistol_left_tilt70_64ppm_seed3_f290_297.png`;
  p55 gatling in the Servo fight: `gtai-masters\d9\rivet\rivet_muzzle_servo_gatling_combo_p55_48ppm_seed2_f340_402_x1.7.png`;
  the measured points: `gtai-masters\d9\rivet\rivet_muzzle_points_fire_cells_p55_p70_contact.png`.
- **The flamer's one flame** (`5f3c583d`, it10): the drawn flame cell only along the side and camera octants;
  off them the facing cell fires and the game's jet leaves the drawn nozzle (the flamer's 5 facing cells
  measured, `RivetFrames.fires_drawn`, `RivetStrips.CONE`). Before/after at 64 px/m:
  `gtai-masters\d9\rivet\rivet_flamer_one_flame_before_after_tilt70_64ppm_x1.1_seed3_f344_364.png`; the nozzle
  points: `gtai-masters\d9\rivet\rivet_muzzle_flamer_facing_points_p70_p55_contact.png`.
- **Ghost form swap back and the roll** (it10, King, Kerf, combo p55, 48 px/m): the drawn figure comes back inside
  the exit ring (f434-442) with the pistol strip, firing by f464; the roll ball spins over the roll (f606-624):
  `gtai-masters\d9\rivet\rivet_ghost_kerf_swap_back_and_roll_king_combo_p55_48ppm_x1.5_seed1_f404_632.png`.
- **The shadow from the drawing** (`61fbbdf8`, it10): his cast shadow and occlusion silhouette take the drawn
  height (1.1 m p70, 1.3 m p55), the roll ball casts a ball's shadow; before, the hidden parts' 1.8 m plan.
  Before/after: `gtai-masters\d9\rivet\rivet_shadow_drawn_height_and_roll_before_after_king_combo_48ppm_x1.5_seed1.png`; beside a
  cop at 32 px/m: `gtai-masters\d9\rivet\rivet_shadow_drawn_height_beside_cop_city_tilt70_32ppm_x4_seed5_f60.png`.
- **The combined clip** (35 s, city 32, flamer 64, King + Kerf + roll 48, Servo 48):
  `gtai-masters\d9\rivet\rivet_d9_set_city32_flamer64_king_servo48_combined_35s.mp4`.
- **Rivet's dialogue face** (`e978f01f`, it16): the library's concept-matched portrait_rivet_55_v2 (A), neutral +
  mood bust at the cast's 320 px; the mood bust on rivet-feels-good and rivet-sorry-not-sorry. Before (it10's sheet
  cut) / after, live in quest 1 at 1080p:
  `gtai-masters\d9\rivet\rivet_dialogue_face_before_after_portrait_v2_quest1_payphone_tilt70_32ppm_1080p_t3350.png`.
- **The flamer's drawn flame follows the aim** (`90c46dfc`, it16): the it13 "red jet" was a drawn flame pointing
  left (the head's octant) beside the game's jet at ~124 deg (the aim); the drawn flame now needs the aim within
  22.5 deg. Before/after: `gtai-masters\d9\rivet\rivet_flamer_drawn_flame_needs_aim_before_after_gunplay_tilt70_64ppm_seed3_t359_380.png`.
  And a burst that went off its drawn flame keeps the facing cell to its end (`e6a74d74`): the fire latch drew a
  phantom flame with no jet for 3 frames after the stream stopped. Before/after:
  `gtai-masters\d9\rivet\rivet_flamer_phantom_flame_before_after_tilt70_64ppm_x1.5_seed3_t362_373.png`.
- **The frame cost** (it16, under the bench lock; 3 before / 3 after interleaved): rig_bench `--view=tilt70`, the
  drawn figure vs the head card over parts, median p50: 50 people 0.943 -> 0.776 ms, 200 people 1.319 -> 1.179 ms.
  No added cost (`evidence/d9/rivet-frame-cost-it16.md`; it10's contended runs agreed).
- **Gates (it16):** director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR on 90c46dfc; unit 1705/0
  (`evidence/d9/gates-it16.md`).
- **Gates (it10):** director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR on 61fbbdf8; evidence run on
  dfb7a4de: lint, scenarios 52, parity, look goldens 11/11 + block 5/5 (top did not move), release-compile 600/0
  PASS; unit 1700/0 (the stage flagged "tree changed during run": a tool file written mid-run) (`evidence/d9/gates-it10.md`).
- **He stands up after the respawn** (it13, `988c0329`): the rig latched the death clip from the DEAD flag and
  nothing ended it, so after the cut he lay in his drawn sprawl at the hub while he walked, gun out, and the
  top-down held part drew beside the base figure (the "grey splat" of it6/it10, one root cause).
  `RigInput.revive` (Rivet's row only) ends it; test_rig_revive. Before/after, King combo 48 px/m:
  `gtai-masters\d9\rivet\rivet_respawn_stands_before_after_king_combo_48ppm_x3_seed1_f1290_1338_1416.png`.
- **No parts on a rig's first frame** (it13, `6438394e`): a rig acquired on a frame with no tick due drew its hidden
  top-down parts once (f0 of the King film: a cream rim under him; at 144 Hz most frames have no tick due, so every
  newly selected cop and walker too). CharacterRigs poses it before it draws under card views; top unchanged.
- **Every weapon fired once at each pitch** (it13, `c80d3107`): `FireStills` (dev, `--fire-stills=<prefix>`) saves
  Rivet's drawn fire/swing cell from the game's state; 13 guns by `--bot=gunplay`, the 4 melee by `--bot=pit
  --loadout=<id>`, 64 px/m, 0 SCRIPT ERROR. All 17 draw their fire/swing cell at p70 and p55, flash or smear at
  the drawn weapon: `gtai-masters\d9\rivet\rivet_every_weapon_fires_drawn_p70_tilt70_64ppm_seed3_firestills.png`,
  `gtai-masters\d9\rivet\rivet_every_weapon_fires_drawn_p55_tilt_64ppm_seed3_firestills.png`.
- **Gates (it13):** `node tools/evidence/run.mjs --no-bench` on cc7f418b (both fixes in): lint 15/15, unit 1704/0,
  scenarios 52, parity exact + planted caught, look goldens 11/11 + block 5/5 (top did not move), release-compile
  600/0, all PASS. Director reels: `evidence/d9/reel-director-it13-<view>.log`.
- **Gates (it7):** `node tools/evidence/run.mjs --no-bench` green on feb56ca2 (lint 15/15, unit 1695/0, scenarios 52
  incl. the replay, parity exact + planted caught, look goldens 11/11 + block 5/5, release-compile 599/0; run with a
  lane-private TEMP); on f7334278 unit 1698/0 and the director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR
  (`evidence/d9/gates-it7.md`).
- **Gates (it6):** unit 1695 / 0; director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR (`evidence/d9/gates-it6.md`).
- **Gates (it3):** unit 1691 passed / 0 failed; director reel 19/19 chapters down in `tilt70`, `combo`, `top`,
  0 SCRIPT ERROR (`evidence/d9/reel-director-it3-*.log`).

## What does not (yet)
- A facing cell (no fire drawn) has no measured muzzle except the flamer's: a flash outside the fire cell's 7
  ticks keeps the old spot (the other holds are drawn every which way in their facings; no generic rule held).
- The Servo bay number printed over Rivet under combo: REQUEST to seams (it10), served on `d9-seams` at 3f4732db
  (ServoDepotDraw.cover); not on this branch until the Director merges both.
- The electro baton reads as part of his forearm at 32-64 px/m (the rod is his arm's rust-brown; only the tip spark
  reads): an art fault, REQUESTed from assets (it16: a dark steel rod angled out of the claw, 1.3x longer).
- Walk: one drawn walk and one sprint pose per sheet; built bob + sway on the facing.
- Reload: no drawn reload frame; he keeps the equipped strip through it (it7 check: the "bare figure" seen in it6
  was the equipped back views, which show the small guns barely; no change made).

## Calls for the owner
1. **Rivet's size.** Built 1.1 m standing (~35 px at 32 px/m, the asset lane's mock), p55 1.3 m.
   Options: 1.25 m / 1.4 m (`RivetFrames.HEIGHT_M`). He reads smaller than the parts rig did (before/after still).
2. **The walk.** The sheets carry one walk and one sprint drawing. Built: the facing with a bob and sway
   (the street walkers' no-grid path, no pops). Options: alternate facing / walk drawing (a 2-frame step),
   or a REQUEST to assets for a 4-frame stride grid per facing (street's `ped_*_walk` shape).
3. **Left facings with a one-handed weapon.** Built (it6): the asset lane's drawn left views at 70 and 55 (weapon
   in his right claw); two-handed holds mirror. Option: mirror everything (swaps the gun hand: against the hand rule).
4. **Rivet's dialogue face.** Built (it16): the concept-matched portrait_rivet_55_v2; the mood bust (eye bars
   narrowed, head lowered) on his two "other voice" lines (still:
   `gtai-masters\d9\rivet\rivet_dialogue_face_before_after_portrait_v2_quest1_payphone_tilt70_32ppm_1080p_t3350.png`).
   Options: more mood lines (rivet-everybody-screamed, rivet-my-hands; one value, `mood_lines`), or none.
5. **The flamer's flame off the side/camera octants.** Built (it10): the facing cell + the game jet from the drawn
   nozzle (one flame). Option: the drawn flame cell in every octant (`RivetStrips.CONE` empty): a bigger drawn
   flame, but two flames when he fires diagonally (before/after still in frames.json).

## Next steps
See JOURNAL `NEXT:`.
