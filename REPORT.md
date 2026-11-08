# n9 rivet: REPORT (DRAFT written in it12 at 08:45; finished at the freeze)

Lane `rivet`, branch `n9-rivet`, 2026-11-08 00:55-11:00. The owner's note: "he is smaller than before - 50% size
increase will be needed, flying instead of walking. As the animation degraded and don't fit now".
Evidence: `C:\Users\kazda\kiro\gtai-masters\n9\rivet\` (`frames.json`, 15 stills, best first) and `evidence/n9/`
(gate logs, sheet metadata). Every still was looked at; the befores come from the same build with a flag.

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
   ~25 px of slide every held cell. Quest 1's sprint (13.6 m/s) is near-planted on the same cycle (Call 8). Stills:
   `rivet_run_footlock_world_before_after_quest1_tilt70_64ppm_t383_398.png`,
   `rivet_gatling_run_left_profile_footlock_king_tilt70_64ppm_x2_seed1_f40_80.png`.
4. **Weapon-out walks and runs** (`2c46aeb4`, `f2e05223`, `e4e150ec`, `b31577a4` ... `4594b19d`): drawn armed walks per
   hold family (one-hand gun, two-hand gun, blade, heavy, flamer) with the plated claw, each on its own measured
   cycle, tone-matched to the equipped strips; **drawn armed runs for pistol, plasma rifle, katana, gatling and
   flamer at both pitches**, short-stride rows stepped by `RUN_ROW_K` so they plant too. Stills: the armed-run
   before/afters at 64 px/m (tilt70) and 48 px/m (King combo, p55).
5. **Cars knock Rivet down, drawn** (`a4656a3e`, `f28589e8`, `4e4a0bf3`, `425ad75d`; world's REQUEST): the library's
   knock-down strip (4 throw axes, impact / tumble / slide / down) + the get-up kneel, read from world's knock field.
   Stills: `rivet_knockdown_before_after_city_car_tilt70_64ppm_t198_294.png` and the 32 px/m twin.
6. **The drawn claw reload** (`76175aaa`, `a4026117`): the reload pose per facing + magazine out / in / ready, at 70 and
   55, for the pistol, plasma rifle and gatling families; standing only (a walk wins). Before: the at-rest cell was
   the side fire cell, its drawn flash pointing sideways mid-reload. Still:
   `rivet_reload_pistol_before_after_king_combo_48ppm_x2_seed1_f333_572.png`.
7. **One shot origin for guns fired up the screen** (`5c77021f`, it12): the side fire cell drew the gun and its flash
   pointing right under an up tracer, and the game's flash burst beside him. Now the fire cell only within 45 deg of
   the aim, else the facing cell (the back view) and the flash on the tracer's line. Still (32 + 48 px/m):
   `rivet_gun_fire_up_one_origin_before_after_king_32ppm_tilt70_48ppm_combo_seed1_f302_309.png`.

Gates (last full set; refreshed at the freeze): lint 15/15; unit full 1839/0 (491e206f); director reel 19/19 fully down
with 0 SCRIPT ERROR in top, tilt70 and combo on every code commit (logs `evidence/n9/reel-director-<it>-<view>.log`,
the latest it12 / it12b); evidence `--no-bench`: lint, unit, parity (mutation caught), selftest (look goldens 11/11),
release-compile 616/0 PASS; scenarios ran PASS but city_chase's nav budget was CONTENDED (not judged).

## What does not work (yet)

- Firing up the screen there is **no drawn up-fire cell** for the flamer or the guns: the back view shows with the game
  jet / flash alone (Calls 17, 19). The asset REQUEST for the flamer up-fire is queued at the library, past its freeze.
- The 55 rows "3/4 toward right" of every armed run stride short (0.68-0.84 of run8): planted, but a quicker cadence
  on that one facing (Call 15). The flamer 55's 0.68 row was never caught on film.
- The drawn reload shows only while he stands: in the bot scenes that is a ~7-frame flash in the strafe gaps (Call 18).
- Twelve weapons without a drawn armed run keep the armed walk at run speed (a glide at 6.75 m/s; Call 13).
- The left get-up kneel is the right profile mirrored (Call 11).

## What blocked, and for how long

- it1 and it2 exited in 5-7 s on billing (00:55-00:54 lost to the late start; the first working iteration was it3).
- Waiting on art: every drawn item above waited on a library round (30-60 min each); the wiring was built ahead so no
  session idled. ~10 min total FRICTION on scene flags and a GDScript typed-dictionary read (JOURNAL it3, it10).
- The three-in-parallel director reel can starve tilt70's last chapter (16000 frames headless): re-run alone (it10).

## Calls for the owner

(Calls 1-18 as drafted in JOURNAL; the freeze pass trims them to the open ones.)

19. **A gun fired up the screen** (it12): built: the back view with the flash on the tracer (GUN_TOL 45 deg). Option A
    `--rivet-flame=all`: the side fire cell at any aim (the gun and flash sideways, two origins). Option B: an asset ask
    for drawn away / away-diagonal gun fire cells per hold family. Still above (item 7).

## Next steps

- The exe: `"$GODOT_BIN" --headless --path project --export-release windows-showcase ../build/export/windows/RTAI.exe`.
- The combined 30-90 s clip of the set.
