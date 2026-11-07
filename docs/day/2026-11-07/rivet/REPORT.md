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
- **Plasma sword redraw** (`b2614b45`, it6): equipped 70_v2 (A) and 55_v3 (B), both hands on the hilt, blade
  about 2x. Still: `gtai-masters\d9\rivet\rivet_plasma_sword_redraw_tilt70_64ppm_x3_t204_264_300.png`.
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
- **Gates (it7):** `node tools/evidence/run.mjs --no-bench` green on feb56ca2 (lint 15/15, unit 1695/0, scenarios 52
  incl. the replay, parity exact + planted caught, look goldens 11/11 + block 5/5, release-compile 599/0; run with a
  lane-private TEMP); on f7334278 unit 1698/0 and the director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR
  (`evidence/d9/gates-it7.md`).
- **Gates (it6):** unit 1695 / 0; director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR (`evidence/d9/gates-it6.md`).
- **Gates (it3):** unit 1691 passed / 0 failed; director reel 19/19 chapters down in `tilt70`, `combo`, `top`,
  0 SCRIPT ERROR (`evidence/d9/reel-director-it3-*.log`).

## What does not (yet)
- The cast shadow is the shared rig-height shadow (long for a 1.1 m robot).
- The flamer firing between octants: the drawn side cell's flame points sideways while the game's jet follows
  the true aim (e.g. down-left), so two flames show for one stream. Candidate: streams keep the facing cell (no
  drawn flame) + the game jet from a measured facing muzzle.
- A facing cell (no fire drawn) has no measured muzzle: a flash outside the fire cell's 7 ticks keeps the old spot.
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

## Next steps
See JOURNAL `NEXT:`.
