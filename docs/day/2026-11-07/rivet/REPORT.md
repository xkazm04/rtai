# d9 rivet REPORT (final, 18:40, it30; branch d9-rivet at the freeze)

The same text is also at the lane root as `REPORT.md`. Path check at 18:42: all 35 `gtai-masters/d9/rivet/` files
and all 16 `evidence/d9/` paths cited below exist (each `<view>` name stands for its top, tilt70 and combo logs).
`build/export/windows/RTAI.exe` and `gtai-masters/d9/rivet/frames.json` (15 entries) exist too. No code changed after
the 18:00 export: `git diff 261f9fac..HEAD -- project tools` is empty, so the exe is HEAD's code.

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
- **The combined clip** (it19, 31 s: the city at 32 px/m x1 and x2, the gatling, katana, v4 plasma sword and
  rocket launcher in his hands at 64, the King engage's p70 -> p55 swap and Servo at 48; 0 SCRIPT ERROR in all 8
  films): `gtai-masters\d9\rivet\rivet_d9_set_it19_city32_gatling_katana_sword_rocket64_king_servo48_combined_31s.mp4`
  (replaces it10's 35 s clip, which predated the left-strip cleanup, the v4 sword and the flamer fixes).
- **Rivet's dialogue face** (`e978f01f`, it16): the library's concept-matched portrait_rivet_55_v2 (A), neutral +
  mood bust at the cast's 320 px; the mood bust on rivet-feels-good and rivet-sorry-not-sorry. Before (it10's sheet
  cut) / after, live in quest 1 at 1080p:
  `gtai-masters\d9\rivet\rivet_dialogue_face_before_after_portrait_v2_quest1_payphone_tilt70_32ppm_1080p_t3350.png`.
  Live in quest 1 at Dock 9 (it19, `--stills` t13660-13900 and t13000-18750, 0 SCRIPT ERROR): the mood bust
  (eye bars narrowed, head lowered) on "Sorry! Sorry. Not sorry?", the neutral on "Everybody screamed" and "I have
  a job": `gtai-masters\d9\rivet\rivet_dialogue_face_live_quest1_mood_t13680_vs_neutral_t17250_t18750_tilt70_1080p.png`.
- **The electro baton redraw** (`6443bc82`, it19, the it16 REQUEST served): the library's v3 (p55 A, p70 B, both
  left A): a dark steel rod with a copper coil, 1.3x longer; p55 cut by component (a tip spark crossed a column
  cut). The rod now reads in the strikes at both pitches and in the p55 facings. Before/after in the pit, 64 px/m:
  `gtai-masters\d9\rivet\rivet_electro_baton_v3_before_after_pit_tilt70_p70_and_tilt_p55_64ppm_x2_seed3_f60_150_300_310_330_350.png`.
- **The flamer's drawn flame follows the aim** (`90c46dfc`, it16): the it13 "red jet" was a drawn flame pointing
  left (the head's octant) beside the game's jet at ~124 deg (the aim); the drawn flame now needs the aim within
  22.5 deg. Before/after: `gtai-masters\d9\rivet\rivet_flamer_drawn_flame_needs_aim_before_after_gunplay_tilt70_64ppm_seed3_t359_380.png`.
  And a burst that went off its drawn flame keeps the facing cell to its end (`e6a74d74`): the fire latch drew a
  phantom flame with no jet for 3 frames after the stream stopped. Before/after:
  `gtai-masters\d9\rivet\rivet_flamer_phantom_flame_before_after_tilt70_64ppm_x1.5_seed3_t362_373.png`.
- **Before/after in a boss fight at 48 px/m (it25):** today's main under combo (the head card over parts, the
  held pistol part) against the drawn p55 figure, the King fight, same seed, camera and frames (40, 120, 200 firing
  at the barge, 300): `gtai-masters/d9/rivet/rivet_before_after_main_vs_drawn_king_combo_p55_48ppm_x1.5_seed1_f40_120_200_300.png`
  (frames.json entry 6). Seen: one drawn figure with the gun in his hands, firing from it; he reads smaller and
  darker on the asphalt than the cream head card (Call 1). 0 SCRIPT ERROR in both runs.
- **The same before/after at Servo** (it25, combo, 48 px/m, seed 1, frames 60/200/300/400):
  `gtai-masters/d9/rivet/rivet_before_after_main_vs_drawn_servo_combo_p55_48ppm_x1.5_seed1_f60_200_300_400.png`
  (frames.json entry 7). He sorts over the van's bumper in bay 3; 0 SCRIPT ERROR both runs.
- **The muzzle at 144 Hz** (it25, the seams NOTE on HeldMuzzle being per render frame): King, combo, 48 px/m,
  `--fixed-fps 144`, frames 470-505 every 3rd: the flash prints at the drawn pistol's muzzle in his hands, not
  at the fallback spot on the ground (`evidence/d9/rivet_muzzle_144hz_king_combo_48ppm_seed1_f470_505_step3.png`).
  By code the drawn muzzle is republished every process frame (`rivet_held_view.gd:79`). 0 SCRIPT ERROR.
- **The frame cost** (it16, under the bench lock; 3 before / 3 after interleaved): rig_bench `--view=tilt70`, the
  drawn figure vs the head card over parts, median p50: 50 people 0.943 -> 0.776 ms, 200 people 1.319 -> 1.179 ms.
  No added cost (`evidence/d9/rivet-frame-cost-it16.md`; it10's contended runs agreed).
  Re-checked at the freeze (it25, bench lock held, 3 runs on 0f8bc386, every strip swap through the walk in):
  median p50 50 people 0.811 ms, 200 people 1.079 ms, inside the it16 after band (`evidence/d9/rivet-frame-cost-it25.md`).
  The bench arms Rivet, so the drawn bare-claw walk grid is not exercised there: its cost is unmeasured.
- **Gates (it16):** director reel 19/19 in `tilt70`, `combo`, `top`, 0 SCRIPT ERROR on 90c46dfc and e6a74d74;
  unit 1705/0; evidence run all PASS (look goldens 11/11 + block 5/5: `top` did not move; parity exact;
  release-compile 600/0) (`evidence/d9/gates-it16.md`).
- **Gates (it19, the baton v3 strips, 6443bc82):** director reel 19/19 in `top`, `tilt70`, `combo` (the baton
  chapter 1/1 down), 0 SCRIPT ERROR, 0 p_frame; unit 1706/0; lint 15/15 (`evidence/d9/gates-it19.md`).
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

- **The baton's swing arc under the drawn figure (it20, a6d6ea6e):** the baton's drawn strike (v3 at both pitches)
  has no arc and the game smear was off under the drawn figure, so a strike read as a still pose. A strip in
  `RivetStrips.NO_ARC` (data: the electro baton at p55 and p70) now feeds the game's crescent, rooted on his body
  axis at the strike cell's measured tip height (`rivet_muzzle.py` STRIKE_TIP) and ending at the drawn tip, drawn
  just under his figure so the baton reads over it; the katana, chainsaw and sword keep only their drawn arcs. If
  the 70 v4 brings a drawn arc back, the p70 entry leaves the list. Before/after, pit, 64 px/m, seed 3:
  `gtai-masters/d9/rivet/rivet_electro_baton_smear_under_drawn_figure_before_after_pit_tilt70_p70_tilt_p55_64ppm_x2_seed3_f324_345.png`.
  Gates it20: director reel 19/19 in top, tilt70, combo (the baton chapter 1/1), 0 SCRIPT ERROR
  (`evidence/d9/reel-director-it20-<view>.log`); unit 1692/0 (--changed: full suite); lint 15/15.
  Evidence run on 3c588ddb (code a6d6ea6e): all PASS, look goldens 11/11 + block 5/5 (top did not move), parity
  exact, scenarios 52, unit 1708/0, release-compile 600/0. The baton 70 v5 (A, drawn arcs) is served; it goes in
  next (then p70 leaves NO_ARC).

- **The electro baton at 70 = v5 (it21, 613490f1; the it19 REQUEST served A):** the rod is drawn clear of the
  forearm in all five facings (an L hold: the arm down, the rod out from the claw), and the side strike and
  follow-through draw their own pale arc again, so p70 left `RivetStrips.NO_ARC` (no game crescent over a drawn
  arc; p55 v3 keeps the game smear). Accepted: the toward-camera strike has no arc now, and in the right-facing
  views the rod trails behind him, carried low (the asset lane offers a one-copy redraw if the owner wants it
  ahead). Before/after, pit, tilt70, 64 px/m, seed 3:
  `gtai-masters/d9/rivet/rivet_electro_baton_70_v5_before_after_pit_tilt70_64ppm_x2_seed3_f60_150_300_324_345.png`.
  Gates it21 (`evidence/d9/gates-it21.md`): director reel 19/19 fully down in top, tilt70, combo (the baton 1/1),
  0 SCRIPT ERROR; evidence run on 64953f9b (+ the `--rivet-height` flag): ALL PASS, look goldens 11/11 (top did
  not move), parity exact, scenarios 52, unit 1709/0, release-compile 600/0.
- **The drawn walk (it22, `c36631bc` p70, `e2400dc4` p55; the owner's Call 2):** bare-claw Rivet walks on a drawn
  4-frame stride per facing (5 facings + the 3 drawn left views, never a mirror), picked by the stride phase, no
  built bob over drawn legs; the asset lane's walk cells (p70: rivet_walk_b B / rivet_walk B / rivet_walk_left A;
  p55: rivet_walk_v4 A / rivet_walk_left_v2 B) packed by `tools/art/rivet_walk.py` (one scale per grid, a common
  foot line), the hand side checked per row (`evidence/d9/rivet_walk_70_contact_x2.png`, `..._55_...`).
  Before = `--rivet-walk=bob`. Clip (quest 1, tilt70, 64 px/m x2 then 32 px/m x3):
  `gtai-masters/d9/rivet/rivet_walk_70_bob_vs_drawn_quest1_tilt70_64ppm_x2_32ppm_x3_t748_920_15fps.mp4`.
  Fresh reel still (tilt70, 48 px/m, eight chapters):
  `gtai-masters/d9/rivet/rivet_reel_director_tilt70_48ppm_claw_pistol_mp_rocket_flamer_electro_molotov_katana_it22.png`.
  Gates it22 (`evidence/d9/gates-it22.md`): director reel 19/19 fully down in top, tilt70, combo, 0 SCRIPT ERROR;
  evidence run on e2400dc4 ALL PASS (look goldens 11/11: top did not move; parity exact; scenarios 52; unit
  1712/0; release-compile 601/0).

## What does not (yet)
- A facing cell (no fire drawn) has no measured muzzle except the flamer's: a flash outside the fire cell's 7
  ticks keeps the old spot (the other holds are drawn every which way in their facings; no generic rule held).
- The Servo bay number printed over Rivet under combo: REQUEST to seams (it10), served on `d9-seams` at 3f4732db
  (ServoDepotDraw.cover); not on this branch until the Director merges both.
- The p70 electro baton (v5): its toward-camera strike draws no arc, and the right-facing views
  trail the rod behind him (it21; judged acceptable, a one-copy redraw is on offer).
- Walk: drawn bare-claw only (it22, p70 and p55); every weapon-out walk keeps the equipped facing with the bob.
  The arenas always arm him, so the drawn walk is seen in quest 1 (and the hub/city with no gun out), not in the
  director reel or the boss arenas. The p55 left walk rows are darker and stockier than the right rows (REQUEST to
  assets for a tone match, it22). He also "walks" on the stride while climbing out of quest 1's dumpster.
- Reload: no drawn reload frame; he keeps the equipped strip through it (it7 check: the "bare figure" seen in it6
  was the equipped back views, which show the small guns barely; no change made).

## Exe for the owner
- **Final export at the freeze** (18:00, on `261f9fac`; every later commit is docs only): 13 s, exit 0, 0 SCRIPT
  ERROR. Smokes: `RTAI.exe --headless --quit-after 300 -- --rigs --view=tilt70` exit 0, and
  `RTAI.exe --headless --quit-after 300 -- --rigs --view=combo --boss=king` exit 0, 0 SCRIPT ERROR (the engine's
  known custom_samplers and "resources still in use" ^ERROR lines only).
  Command lines (Git Bash, from the worktree root, `APPDATA=C:/Users/kazda/kiro/gtai-d9/appdata/rivet`):
  `GODOT_BIN="C:/Users/kazda/kiro/gtai-spike/tools/godot/Godot_v4.7.2-stable_win64_console.exe"`,
  `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
  -> `C:/Users/kazda/kiro/gtai-wt/d9-rivet/build/export/windows/RTAI.exe` (+ `gtai_sim.windows.template_release.x86_64.dll` beside it).
- See Rivet: `RTAI.exe -- --rigs --view=tilt70` (play, p70), `RTAI.exe -- --rigs --view=combo` (boss fights, p55),
  `RTAI.exe -- --rigs --view=combo --boss=king` / `--boss=servo` (the hard swap at the engage);
  befores: `--rivet-walk=bob`, `--rivet-height=<m>` (Call 1: try `--rivet-height=1.25`).

## What blocked (and for how long)
- Iterations 1-2 (morning): exited in 5 s on billing (API credit); iteration 3 was the first that ran.
- release-compile in the evidence run refused a `%TEMP%/gtai-release-compile` dir another run had made (it3-it6,
  about 7 min of my time, the gate owed for three iterations); fixed by running with a lane-private TEMP.
- Every weapon fired at each pitch: a 17 x 2 batch of arena films (~25 min lost, too slow); solved with a dev
  `FireStills` stills mode (it13).
- Finding a bare-claw walk to film (~12 min, it22): the arenas always arm Rivet; filmed in quest 1 stills mode.
- The bench lock was held by another run at 17:56 (it22); taken free at 17:58 (it25).
- Small: backslash paths written as CR by heredocs (~8 min over the day), check.mjs "depended scripts" false
  failures (~2 min), the brief's `--quit-after 14000` ends headless top before chapter 19 (ran longer).

## Calls for the owner
1. **Rivet's size.** Built 1.1 m standing (~35 px at 32 px/m, the asset lane's mock), p55 1.3 m.
   Options: 1.25 m / 1.4 m, each one launch flag in the exe since it21: `RTAI.exe -- --rigs --rivet-height=1.25`
   (p55 scales in proportion; view only). At 1.1 m he reads smaller than a cop and the pedestrians (seams saw the
   same at its merge trial); 1.25 m is a pedestrian's height, 1.4 m the cop's. Still, same seed and frame:
   `gtai-masters/d9/rivet/rivet_size_options_1p1_1p25_1p4_beside_cop_and_peds_city_tilt70_32ppm_x2_seed5_f300.png`.
   My recommendation: 1.25 m (the hero at least as tall as a passer-by, still a compact robot).
2. **The walk.** Built (it22, the default): a drawn 4-frame stride per facing, 5 facings + the 3 drawn left
   views (the asset lane's it94 walk cells: rivet_walk_b B rows 1,2,3,5, rivet_walk B row 4, rivet_walk_left A),
   picked by the stride phase (one cycle = two steps) while he walks bare-claw; no built bob over drawn legs.
   With a weapon out he keeps the equipped facings (no walk drawn per weapon). The before is one flag:
   `RTAI.exe -- --rigs --rivet-walk=bob` (the facing card with a bob and sway). Still, quest 1 t812-856, tilt70,
   bob over drawn at 64 and 32 px/m:
   `gtai-masters/d9/rivet/rivet_walk_70_bob_vs_drawn_quest1_tilt70_64ppm_x1_32ppm_x2_t812_856.png`.
   p55 (boss fights) too: the asset lane's 55 offer (rivet_walk_v4 A, rivet_walk_left_v2 B), packed the same way;
   its three left rows are a shade darker and leaner than the right rows (seen on the contact,
   `evidence/d9/rivet_walk_55_contact_x2.png`). The arenas always give Rivet a gun, so the bare-claw walk was
   filmed in quest 1 only; in the boss fights it shows only with no gun out.
   Options: the bob (the before); drawn (built).
   Known: the 3/4-toward rows (right row 2, left row 1) keep the lowest foot on one side (the arms alternate).
3. **Left facings with a one-handed weapon.** Built (it6): the asset lane's drawn left views at 70 and 55 (weapon
   in his right claw); two-handed holds mirror. Option: mirror everything (swaps the gun hand: against the hand rule).
4. **Rivet's dialogue face.** Built (it16): the concept-matched portrait_rivet_55_v2; the mood bust (eye bars
   narrowed, head lowered) on his two "other voice" lines (still:
   `gtai-masters\d9\rivet\rivet_dialogue_face_before_after_portrait_v2_quest1_payphone_tilt70_32ppm_1080p_t3350.png`).
   Options: more mood lines (rivet-everybody-screamed, rivet-my-hands; one value, `mood_lines`), or none.
5. **The flamer's flame off the side/camera octants.** Built (it10): the facing cell + the game jet from the drawn
   nozzle (one flame). Option: the drawn flame cell in every octant (`RivetStrips.CONE` empty): a bigger drawn
   flame, but two flames when he fires diagonally (before/after still in frames.json).
6. **The armory showing him holding each weapon** (brief item 6). Not built: under a card view the hub's weapon
   wall would get a row of 17 drawn Rivets above the board, each in his REST pose with that weapon (the equipped
   strips' cell 7). In the world it reads as a lineup of clones, so it is your pick. Today the every-weapon contacts
   show him holding each one: `gtai-masters\d9\rivet\rivet_every_weapon_fires_drawn_p70_tilt70_64ppm_seed3_firestills.png`
   and the `_p55_tilt_` one. Options: the wall row (about an hour), a figure only beside the weapon he stands over, or
   none (the default).

## Next steps
1. Owner Calls 1 (size: 1.25 m recommended) and 2 (walk: drawn built): one flag each; land the picks as defaults.
2. Merge with d9-seams (its trial merge on e2400dc4 conflicted only JOURNAL.md and the debt baseline); then the
   Servo bay number sits under Rivet in combo (seams' ServoDepotDraw.cover).
3. Main's switch to combo (the owner's call n-2): Rivet's whole-figure frames are in at p70 and p55; the reels
   go 19/19 in top, tilt70 and combo with 0 SCRIPT ERROR.
4. A drawn walk per weapon (today a weapon-out walk keeps the equipped facing with the bob): a REQUEST to assets
   per hold family (one-handed gun, two-handed gun, blade) rather than 17 sheets.
5. Swap in the tone-matched p55 left walk cells (served 18:16 by assets as
   `library/keyed/rivet/rivet_walk_55_left_tone_cells/`, tone-matched from v2 so the poses are the same; the drawn
   `rivet_walk_55_left_v3` came out too light and was not delivered); they came after the freeze cut-off, so they are not in the exe; a drawn reload frame; a measured muzzle for
   the facing cells of the remaining weapons; the armory row (Call 6) if the owner picks it.
