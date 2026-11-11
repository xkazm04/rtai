# DEFECTS - n17 rivet-strike (strikes, shots, Rivet's movement)

`found -> fixed (commit) / open`. Numbers at the film's ppm; the source film is named.

## Melee

1. **Katana thrust lands mid-lunge and slides on after contact.** `lunge_m` spread evenly over windup + active
   (`melee_combo.gd` before 3abb72f83): 1.25 m of 2.5 travelled at the contact test, 1.04 m slid after it, and
   tick 0's share lost (2.29 m in all). -> fixed 3abb72f83 (`lunge_ticks` 4: 2.5 m by contact, 0 after;
   `test_melee_lunge_contact`). Same for the chainsaw rev-in (0.6 m).
2. **The claw's lunges (0.4 / 0.5 m) still spread evenly.** Its rows feed the replay golden. -> open (owner Call:
   set `lunge_ticks` on rivet_melee.json's rows and re-bless the replay).
3. **Weapon strikes stand bolt upright** (no weight into the blow; the ghosts lean since n15). -> fixed 415dc9ad1
   (RivetLean: katana/plasma 5 back / 9 in, baton 4/7, saw 3/6; films katana t61/t64, baton_left t64 at 64 and 32 px/m).
4. **Boot line pops at the katana slash cells.** `film.mjs chapter:katana` (48 px/m, HEAD 3abb72f83): Rivet's
   `feet_y` 400.0 walking -> 395.7 (t59-61, wind-up/strike cells) -> 401.9 (t62-68) -> back: a 4.3 px rise then
   a 1.9 px drop while his sim y is constant. Cause: the strike cell's swing arc hangs below his boots and the
   strip is cut with its lowest pixel (the arc) on the foot line: boots 31 strip px up (~15 px at 64 px/m).
   -> fixed 0e01165a3 (RivetCellFeet, katana side cell; after ~4 px, part of it the lean). The rig's own screen
   point also rose 1.5-2.6 px through the strike (probe `screen` y, sim y constant): the gait's bob (1.4 world px)
   ran on the strike cell while he moved. -> fixed fcd603180 (RivetLean.held: screen y 400.0 every tick t55-71).
6. **Camera-facing blade strikes drew Rivet a body height above his ground point** (p70 cell 6: the blade reaches
   down the cell, its tip on the foot line; boots 57-120 strip px up: katana 120, plasma 78, saw 75, baton 57).
   `chapter:katana_cam` t66 at 64 px/m: before, only the blade on screen, Rivet off frame above. -> fixed 7b1f03b7c.
7. **p55 (boss view) camera strike cells** float too (boots 18-46 strip px up; the side cells stand on their boots). -> fixed (RivetCellFeet p55 rows, band + ruler reads +-6 px); not yet filmed in a boss arena: open.
5. **During a lunge the drawn figure holds one strike cell** (no stride), so a 2.5 m dash is a whole-figure
   slide. -> open: REQUEST assets for a thrust-lunge cell (front foot forward, back foot pushing) per facing.

## Ranged

`film.mjs weapon:pistol --ppm=64` (HEAD da3c12437), fire at 333, kill at 337:
8. **The flash and the round's tail leave the drawn muzzle** (t333-334: the ink flare and the drawn cell both on the
   pistol's bore). OK, no defect.
9. **One pistol round shows 8 ticks of flash** (t333-340, 133 ms): the drawn fire cell carries a painted flash and is
   held FIRE_TICKS 7 (+ the latch tick), while the ink flare holds muzzle_ticks 3. A shot's flash should read 1-3
   frames; the cell's pose (the recoil) may hold longer. -> open: REQUEST assets (flashless fire cells), then show the
   painted cell for muzzle_ticks and the flashless one for the rest of the latch.
10. **The fire latch survives a facing change**: after the kill (t337) Rivet turns to the camera octant at t339 and
    the camera fire cell shows a flash with no shot (t339-340): the recoil's decaying kick (> FIRE_RECOIL ~11 ticks)
    and the FIRE_TICKS latch both held across the turn. -> fixed 6ae388e38 + 6822e1036 (RivetFireTurn: the latch holds in
    the octant the round left in; only the kick's rise re-seats it). Film t339-340 differ, t336/t342 identical.
11. **Arm vs round direction**: at t333 the drawn arm points 0 deg (screen right, side cell) while the round leaves at
    -29 deg on screen toward the cop (942,224) from (638,395); probe facing_off 2.6 deg says the rig's facing is the
    sim's, so the shot's aim and Rivet's facing differ by ~30 deg at the fire tick (the bot turns him after it
    aims?). -> open: measure aim vs facing per shot over a street fight.
12. **No visible recoil kick** on the pistol fire cells t333-338 (the arm and body hold one pose). -> open.
13. **Size pop at the fire cell -> armed walk handover** (weapon:pistol t339 at 64 px/m, after 6822e1036): the camera
    fire cell's figure is ~10 % smaller than the armed walk grid's next to it. -> open (item 5: measure every
    strip's figure height against the walk grid, as RivetFrames.FIG_PX assumes one median).
