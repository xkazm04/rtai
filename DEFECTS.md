# DEFECTS (n15 combat): found -> fixed (commit) / open

Ranked within each film; newest film first.

## Baton left swing, director chapter electro_baton_left, combo + tilt 32 px/m (session 2)
1. The left swing drew the hanging-baton left facing under a game smear: no swing pose -> fixed a76c26f9a + 6486e5e59 (drawn left strike, it334).
2. The game melee smear reads as a flat white hexagonal slab (a polygon wedge, no taper or ink) around Rivet at t60-70 and t84; the largest shape on screen in the swing -> open (the top one to fix next in item 5's loop).
3. Under a hidden held part the RivetSwipe arc lingered as a full wedge through the recovery (t90-104) -> fixed 6486e5e59 (not shipped: found in the first cut).
4. At p55 the stunned cop's dropped pistol (CELL_SPAN_M 0.48 m) reads about as long as the cop's forearm-plus-hand, large next to him -> open (n13 size; judge against the held gun).

## Boss view (p55) baton, director chapter electro_baton, 32 px/m (session 2)
1. Rivet shrank to about 0.72 as he wound up and struck (the cutter's act_k fallback) -> fixed 42c826289.

## Electro gun lone stun, cop/head_cap, 64 and 32 px/m (session 2)
1. The stunned cop dropped Rivet's pale salvaged pistol, not his own navy gun; on cream pavement at 32 px/m it melted into the floor -> fixed b8da0a47f.
2. While stunned (t360-375) his gun hand still shows a dark gun-like shape at the hand as the dropped gun lies beside him -> open, look at the rig's hand cell.

## Flamethrower lone burn, cop/head_cap and cop/head_swat, 64 px/m (session 2)
1. A burning figure held one pose for the whole burn (no flail) -> fixed 261669f02 (FLAIL_FRAMES on).

## Street kills, lone victim, machine pistol, combo 64 px/m (session 1)
1. SWAT hit cell held a pistol-length gun, his fall a long carbine: the gun changes at the fall frame (t347) -> fixed 13a74d4dd (hit v4).
2. Elder's thrown-back cell read as a mild stumble -> fixed 13a74d4dd (hit v3).
3. A long dark tracer/streak sweeps across the victim at t345-348 (the round streak across the body after the kill) -> open, not yet looked into.
4. The elder's head reads a little larger in the hit cell than in the kneeling fall frame at t347 (card height matches, 53.6 vs 39.5 px drawn) -> open, judge on a clip.
