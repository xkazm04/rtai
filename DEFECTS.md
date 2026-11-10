# DEFECTS (n15 combat): found -> fixed (commit) / open

Ranked within each film; newest film first.

## City street fight (`film.mjs city`), combo 32 px/m, t100-1150 (session 3)
1. Rows of ink range-target rings on the road, empty where a target was down: the largest marks on the asphalt, they read as debug -> fixed 54297457d (no target rings in the city).
2. The riot squad (4-5 cops with shields) stands pinned against the sidewalk barrier from t400 to t1000 and never comes round it -> open (nav/AI, not the view).
3. The street cops hold their spots on the road for the whole film; Rivet fights alone on the sidewalk below them -> open (the gunplay bot's reach; judge whether the shot shows a fight at all).
4. The camera (lock auto) does not follow Rivet: by t1000-1150 he is at the frame's bottom edge -> open (film kit: `--lock=off` follows).
5. Vehicle shadows: the only car is cut by the frame's bottom edge -> NOT JUDGED (needs a shot with traffic in frame).

## Sustained flame jet, director chapter flamethrower, combo 32 px/m, t48-192 (session 3)
1. The ground fire the jet lights stacks into a tall column of red starbursts (t96-192), taller than the cop, a red wall beside him -> open (fire patch spread / size; red is near the blood colour).
2. The stream is a chain of teardrop tongues -> kept: the owner's look-14 pick (flame_cone is one data value away).
3. The drawn flame cell at the nozzle is yellow, the stream red-orange: two colours of fire in one jet -> open, judge.

## Rocket lone kill, cop/head_cap, combo 48 px/m (session 3)
1. The gib flew as one whole tumbling body (the card in one group, the hidden rig parts empty) -> fixed 324927f99 (GibCardCut).
2. The pieces' cut edges are straight across the drawn art (paper-cut look) -> open (drawn gib pieces per kind: an asset-lane request).
3. Before the fix the whole body vanished under the smoke by t366; the pieces now draw over the smoke ring -> judge (z of the gib layer vs the smoke).

## Blades turned left, director chapters <blade>_left, combo 64 px/m (session 3)
1. Turned left, the katana, plasma sword and chainsaw drew the mirrored right strip: through the wind-up he turned his back and the hose arm away from the cop, then swung a large mirrored arc -> fixed 15c8abbcc (drawn left set).
2. At t62 (katana and plasma sword, before and after alike) a long thin white stick runs from the cop down-left to the floor -> open (likely the cut cop's dropped baton or a cut streak; look at the kill's FX at t62).
3. The plasma sword's left strike at 64 px/m is a little smaller than its left facing (k shared with the raised wind-up) -> open, minor.

## Boss fight, King + katana (blade boss bot), tilt p55 64 px/m (session 3)
1. t308: one upright frame (the standing p55 facing) between the follow-through and the next wind-up -> open (the strike clip's recovery ends a tick before the next wind-up starts).
2. Rivet stands over the throne car's body (drawn on top of the King's car): reach is to the body circle -> open, judge (render order vs the boss).

## Dev arena, pistol, feel on (--lock=off), 32 px/m (session 2)
1. Every shot's muzzle light stayed lit for good: white paper fans piled up beside Rivet -> fixed 5bdad7a0c.

## Machine pistol lone kills, 9 kinds, combo 64 px/m (session 2, c-2 films)
1. Thrown-back hit cells drawn from a shallower camera (whole body, upturned face, long legs) between the walk and the fall -> fixed 1ede2ce03 (c-2 redraws, 9 kinds).
2. The body-hit ink burst read as a black ball as wide as the head -> fixed 07bb047cf (body ink 0.12 m).
3. The body-hit burst lands about 0.5 m in front of the drawn thrown-back card, on the floor -> open.
4. Every lone victim (suit, punk, thug included) drops the brown rifle at t350, a patrol cop who held a pistol too -> open (the gunplay bot arms the victim; check which gun the drop draws).
5. The victim walks in at t338 as a blue armed card with the kind's head (the gunplay hostile's body) -> open, likely the dev shot only.

## Baton left swing, director chapter electro_baton_left, combo + tilt 32 px/m (session 2)
1. The left swing drew the hanging-baton left facing under a game smear: no swing pose -> fixed a76c26f9a + 6486e5e59 (drawn left strike, it334).
2. The game melee smear reads as a flat white hexagonal slab (a polygon wedge, no taper or ink) around Rivet at t60-70 and t84; the largest shape on screen in the swing -> fixed 9f966271e (unwrapped angles, 150 deg cap, 6 deg chords).
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
