# DEFECTS - n17 rivet-strike (strikes, shots, Rivet's movement)

`found -> fixed (commit) / open`. Numbers at the film's ppm; the source film is named.

## Melee

1. **Katana thrust lands mid-lunge and slides on after contact.** `lunge_m` spread evenly over windup + active
   (`melee_combo.gd` before 3abb72f83): 1.25 m of 2.5 travelled at the contact test, 1.04 m slid after it, and
   tick 0's share lost (2.29 m in all). -> fixed 3abb72f83 (`lunge_ticks` 4: 2.5 m by contact, 0 after;
   `test_melee_lunge_contact`). Same for the chainsaw rev-in (0.6 m).
2. **The claw's lunges (0.4 / 0.5 m) still spread evenly.** Its rows feed the replay golden. -> open (owner Call:
   set `lunge_ticks` on rivet_melee.json's rows and re-bless the replay).
3. **Weapon strikes stand bolt upright** (no weight into the blow; the ghosts lean since n15). -> fixing (RivetLean).
4. **Boot line pops at the katana slash cells.** `film.mjs chapter:katana` (48 px/m, HEAD 3abb72f83): Rivet's
   `feet_y` 400.0 walking -> 395.7 (t59-61, wind-up/strike cells) -> 401.9 (t62-68) -> back: a 4.3 px rise then
   a 1.9 px drop while his sim y is constant. -> open (next: per-strip foot line, as RivetStrike.FOOT_PX does
   for the claw grid).
5. **During a lunge the drawn figure holds one strike cell** (no stride), so a 2.5 m dash is a whole-figure
   slide. -> open: REQUEST assets for a thrust-lunge cell (front foot forward, back foot pushing) per facing.

## Ranged

(not yet filmed this session)
