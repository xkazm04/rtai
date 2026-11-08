# n9 rivet: REPORT (FINAL; finished by the Director at 10:00 because every billing path ran out at 09:08)

Lane `rivet`, branch `n9-rivet`, 2026-11-08 00:55-11:00. The owner's note: "he is smaller than before - 50% size
increase will be needed, flying instead of walking. As the animation degraded and don't fit now".
Evidence: `C:\Users\kazda\kiro\gtai-masters\n9\rivet\` (`frames.json`, 15 stills, best first; the combined clip
`rivet_n9_set_combined.mp4`, 64.6 s: the size at 32 px/m, the planted runs, the 55 runs, the knock-down, the gun fired
up, the reload, each captioned with view, zoom and speed, before | after where one exists) and `evidence/n9/` (gate logs, sheet metadata). Every still was looked at; the befores come from the same build with a flag.

## What works (with its evidence)

1. **The new size** (`c0b0bea0`): `RivetFrames.HEIGHT_M` 1.1 -> **1.65 m** at p70, p55 1.3 -> **1.95 m** in proportion;
   `--rivet-height=<m>` stays. Everything that reads his height reads it from one place: the card scale (the measured
   muzzles, the smear and the fire latch scale with it), the cast shadow and occlusion hip, the roll ball. The sim
   body is untouched. Under `top` there is no drawn strip, so the top goldens did not move (selftest 11/11 every run).
   Stills: `rivet_size_before_after_1p1_1p65_city_tilt70_32ppm_x1.5_seed5_f300.png` (city, beside cops / peds / a
   car), `rivet_size_before_after_p55_1p3_1p95_king_combo_48ppm_seed1_f200_300.png`, `..._servo_combo_48ppm_...`.
   No scene's framing broke at 32 (city) or 48 px/m (King, Servo).
2. **The flamer, drawn flame in every direction** (`dbef2e17`, `6d0b1a29`, `b7c515cc`): `RivetStrips.cone` empty (the
   owner's r-7 B) plus drawn diagonal fire cells; the drawn flame shows only while it lies within 30 deg of the aim,
   so one flame always draws (firing straight up: the facing cell and the game jet). Still:
   `rivet_flamer_up_burst_one_flame_before_after_king_combo_48ppm_x1.5_seed2_f250_302.png`.
3. **The walk that plants** (`b06c962f`, `567c1128`, `f727612d`, `8fc2314a`): why he glided, measured: his on-foot
   speed is 6.75 m/s (a run, `combat.json`), and no walk cycle can plant there (the walk8 cycle covers 0.9 m at 1.65 m:
   7.5 cycles/s needed). Built: the stride phase tied to the distance walked (the King's-boots method), the library's
   8-frame walk (walk8) for walking speeds, and **a drawn 8-frame run (run8, 3.87 m per cycle)** above 2.5 m/s, at
   70 and 55. Foot lock measured per held cell against the asphalt at 64 px/m: planted within +-4 px (8 cm); before,
   ~25 px of slide every held cell. Quest 1's sprint (13.6 m/s) is near-planted on the same cycle (Call 1). Stills:
   `rivet_run_footlock_world_before_after_quest1_tilt70_64ppm_t383_398.png`,
   `rivet_gatling_run_left_profile_footlock_king_tilt70_64ppm_x2_seed1_f40_80.png`.
4. **Weapon-out walks and runs** (`2c46aeb4`, `f2e05223`, `e4e150ec`, `b31577a4` ... `4594b19d`): drawn armed walks for
   the five weapons the library drew, one per hold family (pistol, plasma rifle, katana, gatling, flamer; the other 12
   keep the facing card, Call 3) with the plated claw, each on its own measured cycle, tone-matched to the equipped
   strips; **drawn armed runs for the same five at both pitches**, short-stride rows stepped by `RUN_ROW_K` so they
   plant too. Stills: `rivet_armed_run_pistol_before_after_arena_gunplay_tilt70_64ppm_seed3_f20_176.png`,
   `rivet_armed_run_katana_before_after_reel_katana_tilt70_64ppm_f46_62.png`, `rivet_armed_run_flamer_before_after_king_tilt70_64ppm_seed1_f36_76.png`,
   `rivet_armed_runs_p55_rifle_katana_gatling_before_after_king_combo_48ppm_x1.5_seed1_f16_56.png`,
   `rivet_armed_run_flamer_p55_before_after_king_combo_48ppm_x1.5_seed1_f16_56.png`; the armed walks under "Further evidence".
5. **Cars knock Rivet down, drawn** (`a4656a3e`, `f28589e8`, `4e4a0bf3`, `425ad75d`; world's REQUEST): the library's
   knock-down strip (4 throw axes, impact / tumble / slide / down) + the get-up kneel, read from world's knock field.
   Stills: `rivet_knockdown_before_after_city_car_tilt70_64ppm_t198_294.png` and the 32 px/m twin.
6. **The drawn claw reload** (`76175aaa`, `a4026117`): the reload pose per facing + magazine out / in / ready, at 70 and
   55, for the pistol, plasma rifle and gatling families; standing only (a walk wins). Before: the at-rest cell was
   the side fire cell, its drawn flash pointing sideways mid-reload (Call 9). Still:
   `rivet_reload_pistol_before_after_king_combo_48ppm_x2_seed1_f333_572.png`.
7. **One shot origin for guns fired up the screen** (`5c77021f`, it12): the side fire cell drew the gun and its flash
   pointing right under an up tracer, and the game's flash burst beside him. Now the fire cell only within 45 deg of
   the aim, else the facing cell (the back view) and the flash on the tracer's line. Still (32 + 48 px/m):
   `rivet_gun_fire_up_one_origin_before_after_king_32ppm_tilt70_48ppm_combo_seed1_f302_309.png`.

Gates (last full set, it12, on 788700a6 = the gun fire change 5c77021f + JOURNAL): lint 15/15; evidence `--no-bench`
PASS: unit **1840/0**, scenarios 54 (city_chase's nav budget missed beside other runs, re-judged alone on a quiet
machine: within budget), parity (bit for bit over 1200 steps, mutation caught at step 629), selftest (look goldens
11/11 worst 0.27, block goldens 5/5: nothing moved), release-compile 616/0. Director reel 19/19 fully down with 0
SCRIPT ERROR in top, tilt70 and combo on every code commit (`evidence/n9/reel-director-<it>-<view>.log`; it12b the
latest).

## What does not work (yet)

- Firing up the screen there is **no drawn up-fire cell** for the flamer or the guns: the back view shows with the game
  jet / flash alone (Calls 8, 10). The asset REQUEST for the flamer up-fire is queued at the library, past its freeze.
- The 55 rows "3/4 toward right" of every armed run stride short (0.68-0.84 of run8): planted, but a quicker cadence
  on that one facing (Call 5). The flamer 55's 0.68 row was never caught on film.
- The drawn reload shows only while he stands: in the bot scenes that is a ~7-frame flash in the strafe gaps (Call 9).
- Twelve weapons without a drawn armed run keep the armed walk at run speed (a glide at 6.75 m/s; Call 4).
- The left get-up kneel is the right profile mirrored (Call 7).

## What blocked, and for how long

- it1 and it2 exited in 5-7 s on billing; it3 (from 00:54) was the first iteration that ran.
- Waiting on art: every drawn item above waited on a library round (30-60 min each); the wiring was built ahead so no
  session idled. ~10 min total FRICTION on scene flags and a GDScript typed-dictionary read (JOURNAL it3, it10).
- The three-in-parallel director reel can starve tilt70's last chapter (16000 frames headless): re-run alone (it10).

## Calls for the owner

Each Call names what is built (the default) and the flag or data value that gives the alternative. JOURNAL numbers
in brackets.

1. **Frames per stride, and walk vs run** [1, 6, 8]. His on-foot speed is 6.75 m/s (`combat.json` walk_mps, the
   2026-11-04 baseline): a runner's speed. No walk cycle plants there (walk8 covers 0.9 m per cycle at 1.65 m; it
   would need 60 drawn frames/s). Built: walk8 (8 frames) by the distance walked under 2.5 m/s (`RivetWalk.RUN_FROM_MPS`),
   the drawn run8 (8 frames, 3.87 m per cycle at p70) above it, cadence capped at 2.0 / 3.5 cycles/s
   (`MAX_CYCLES_S`, `MAX_RUN_CYCLES_S`). Quest 1's sprint (13.6 m/s) is near-planted on run8, but a held pose slides
   ~0.23 m for its ~2 ticks (the 8-frame sawtooth). Options: a 12-16-frame sprint (an asset ask); a slower walk or
   sprint (sim: not this lane's); `--rivet-walk=4` / `=bob` are d9's befores.
2. **1.65 m and the camera** [3]. No scene's framing broke at 32 px/m (city) or 48 px/m (King, Servo combo). Built:
   no camera change. Stills in frames.json (size entries).
3. **Weapon-out walk: replace, not blend** [4]. Built: the drawn armed walk / run replaces the facing card while he
   moves (until a shot). `--rivet-walk-armed=off` = d9 (the card with a bob, the glide).
4. **Armed runs: 5 of 17 weapons** [10, 13]. Drawn armed runs ship for pistol, plasma rifle, katana, gatling and flamer
   at 70 and 55; the other 12 keep their armed walk / card at run speed (a glide at 6.75 m/s). Rejected: borrowing a
   family's run (the wrong gun would be drawn in his claw). Option: library runs per weapon (~8 jobs each).
5. **Short-stride rows** [14, 15]. Every 55 armed run's "3/4 toward right" row strides 0.68-0.84 of run8;
   `RivetWalk.RUN_ROW_K` steps that row on a shorter cycle (planted, a slightly quicker cadence on that facing).
   Option: an empty table (every row on run8's cycle: that row slides), or v2 rows by example (asset ask).
6. **One arm or two** [16]. Bare Rivet's free arm is the cable with the spike (the approved base strip, walk8, run8);
   with a weapon out it is the plated claw (every equipped / armed strip). Built: as drawn. Option: a claw bare set
   (base + walk8 + run8 at 70 / 55, ~40 library jobs).
7. **The knock-down** [11, 12]. Built: the drawn knock strip (4 throw axes) + the get-up kneel; the left kneel is the
   right profile mirrored (claw and cable swap sides for ~12 ticks). The lying body reads ~1.3x his standing height
   (dome matched to the walk). `--rivet-knock=off` = the d9 DOWN sprawl.
8. **The flamer's flame vs the aim** [2, 7, 17]. Built: the drawn flame in every direction (r-7 B) where a drawn
   flame lies within 30 deg of the aim (side, camera, the drawn diagonals); firing straight up, the back view with the
   game jet alone (no up flame is drawn). `--rivet-flame=all` = a fire cell at any aim (two flames up the screen),
   `=cone` = d9. Option: the asset ask for an up-fire cell and steeper away diagonals (REQUESTed at it10; the library
   froze first).
9. **The drawn reload only standing** [18]. Built: the claw reload (pistol, plasma rifle, gatling families) while he
   stands; a walk wins while he moves, so in bot play it shows in ~7-frame strafe gaps. Option: the reload cell over
   the walk (standing legs carried across the ground: the glide). `--rivet-reload=off` = d9.
10. **A gun fired up the screen** [19]. Built: the gun's side / camera fire cell only within 45 deg of the aim
    (`RivetStrips.GUN_TOL`), else the facing cell (the back view, the flash on the tracer's line). `--rivet-flame=all`
    = the side cell at any aim (the gun and its flash sideways, the flash beside him: two origins). Option: drawn away
    and away-diagonal gun fire cells per hold family (an asset ask).

## Further evidence in the folder (not in frames.json; each looked at when made)

- Weapon-out walks (item 4): `rivet_armed_walk_pistol_before_after_arena_tilt70_{32ppm_seed3_f60_102,64ppm_seed3_f60_81}.png`,
  `rivet_armed_walk_claw_pistol_before_after_arena_tilt70_{32ppm_x2,64ppm}_seed3_f60_102.png`,
  `rivet_armed_walk_claw_pistol_p55_king_combo_48ppm_x1.5_seed1_f100_220.png`,
  `rivet_armed_walk_plasma_rifle_arena_tilt70_64ppm_seed3_f60_102.png`, `rivet_armed_walk_gatling_flamer_arena_tilt70_64ppm_seed3_f60_144.png`.
- Armed runs at 55 (item 4): `rivet_armed_run_{katana,rifle}_p55_before_after_king_combo_48ppm_x1.5_seed1_f16_56.png`.
- The flamer's diagonal cells at 32 px/m (item 2): `rivet_flamer_diagonal_cells_before_after_arena_tilt70_32ppm_x2_seed3_f351_366.png`.
- The combined clip's sources (half-speed before / after pairs at 64 and 48 px/m): `rivet_armed_run_*_halfspeed.mp4`,
  `rivet_armed_run_pistol_arena_gunplay_tilt70_64ppm_seed3_f0_200.mp4`, `rivet_knockdown{,_BEFORE_sprawl}_city_car_tilt70_64ppm_t150_350.mp4`.

## Next steps

- The exe (exported 09:03 on fe8f95a0, the code of 5c77021f; re-exported at the freeze if code changes):
  `export APPDATA=C:/Users/kazda/kiro/gtai-n9/appdata/rivet; "$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`
  -> `C:\Users\kazda\kiro\gtai-wt\n9-rivet\build\export\windows\RTAI.exe` (347 MB + the release sim DLL beside it).
  Smoke: `RTAI.exe --rendering-driver d3d12 --quit-after 600 --log-file <log>`: boots, exit 0, 0 errors.
  The owner's befores in the exe: `--rivet-height=1.1`, `--rivet-walk=4`, `--rivet-walk-armed=off`, `--rivet-flame=all|cone`,
  `--rivet-reload=off`, `--rivet-knock=off` (after `--`).
- The combined clip is built (64.6 s); it has no bare-walk (walk8) segment yet.
