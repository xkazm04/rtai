# DEFECTS (n16 kills-polish, newest first; n15 combat's list below): found -> fixed (commit) / open

## Drawn death art in game, electro / plasma rifle / chainsaw chapters, 64 and 32 px/m (iteration 3, 13:55-14:35)
1. Electro: every kind flashed one plain skeleton -> fixed b037d283f (A3 per kind). At 32 px/m on dark asphalt the drawn
   set (ink silhouette, frame 1) is darker and busier than the plain cream sticker -> open, owner Call.
2. Plasma hole: the procedural rings read as a bullseye, not a hole -> fixed 0dce9f3b6 (A4 drawn ring). The impact pop at
   32 px/m is weaker than the old cream bloom -> open, owner Call (not tried: a short bloom under the drawn ring).
3. Chainsaw: the grind threw only red dots and sparks -> fixed af3f9af1c (A5 drawn chunks). First try at 0.36 m: the meat
   sank into the blood pool at 64 px/m -> 0.46 m, thrown 1.3-2.6 m (same commit).
4. Ray gun (ranking #3, rank64 film t50-89): the "falling cop" is the HAT piece: GibCut.cut(whole) copies every sprite
   under the head into the hat, and the whole-figure walker card hangs under the head, so the kicked, spinning "cap"
   was the whole man, unclipped, over his own dissolving body -> fixed (commit after 49c7c0be9; the figure stays in the
   BODY only; test test_gib_cut_figure_hat; `evidence/n16-kills-polish/ray_gun_no_figure_hat_ab_64ppm_t50-89.png`).
5. Ray gun, after 4: the disc mask holds only the legs from t50 (head and torso clipped at once) -> open (NEXT 1).

## Reel gate, top pass, rocket chapter (gate d3e25fc4a, iteration 2)
1. SCRIPT ERROR `has_meta on a null value`: GibCardPieces.dress_rig asked a top-view rig (no head card) for its card row
   -> fixed 9d3d821f6 (no head card = the rig's own parts; test). Reel gate re-run owed.

## Blade kills, katana / plasma sword / chainsaw chapters, combo 64 and 32 px/m (iteration 2, 13:00)
1. The split's "halves" were the whole cop, standing and aiming as he slid off (t64-t130), plus his feet: the cut ran
   through the body's ground point, below the drawn figure -> fixed 7d3ba705a (row cut_up_m 0.8,
   `evidence/n16-kills-polish/katana_cut_up_ab_*`, `plasma_sword_cut_up_*`, `chainsaw_cut_up_*`).
2. The halves slide off upright (a head-and-shoulder half floats standing) -> fixed e69fd5359 (split_topple_deg 80,
   `evidence/n16-kills-polish/katana_topple_ab_*`, `plasma_sword_topple_*`).
4. Chainsaw, e69fd5359: the level cut stacks the halves, and the torso fell back under Rivet -> fixed 0dcdf95c1
   (stacked halves fall along the blow, `evidence/n16-kills-polish/chainsaw_cut_face_stacked_fall_ab_*`).
5. The cut edge was a plain red band (cream for the plasma sword): no ribs, no spine -> fixed 794f27f80 (A2 drawn cut
   faces). The drawn strip is straight and overhangs a narrow legs half -> open, minor.
3. The plasma sword leaves nothing on the street (no blood by design, the halves only) -> open (char on the halves' edges?).

## Rocket lone kill, patrol cop, bone pieces, combo 64 and 32 px/m t350-371 (iteration 2)
1. The torn ends were sooty cloth (no bone) -> fixed fdb3a0d2d (it410 bone sets, 7 kinds; 4 more in 76f023a08).
2. At 32 px/m the bone does not read: the pieces are ~10-15 px and fly over the smoke ring -> open.

## Ranking films, chapters at 32 and 64 px/m, rev 1b823dbf7 (iteration 1, 11:40-11:47)
1. Plasma hole: the hole at the hips and cream smoke washing the standing cop pale -> fixed bb9314a83 (hole_up_m 0.4,
   ink-grey smoke). The hole's cream halo (1.55 x radius, alpha 0.55) is still large at 32 px/m -> open.
2. Electro shock: the X-ray skeleton is drawn LYING (turned along the shot, `KillShockFx._draw` rotation dir + 90 deg)
   beside the standing, convulsing card: reads as a sticker, not his X-ray -> fixed 455148cb5 (upright on the body's
   feet, `evidence/n16-kills-polish/electro_xray_upright_ab_*`; Ohm's shock too); per-kind skeletons (A3) -> open.
3. Ray gun: at k+10..k+30 the cop falls back over as a plain death while a grey disc stays; the dissolve does not read
   -> open. Hypothesis (iteration 2, code read, not filmed): as the blades' cut was, KillDissolveFx's disc mask and
   rings centre on the body's ground point with BODY_R_M 0.62, so the upright figure is not wrapped by the eating disc.
4. Flamethrower: the jet's floor-fire column covers the death beat (k+0..k+10) -> open (n15 #1 of the flame jet).

## Rocket lone kill, thug / hooded ped as rigs, combo 64 and 32 px/m t347-371 (iteration 1)
1. Before: a thug or hooded ped gibbed as a rig flew the shared blue cop-suit rig parts (a box head on a blue body,
   blue legs for the hood) -> fixed 917d75a5e (drawn it363 pieces per kind).
2. At 32 px/m the drawn pieces are small (torso 0.56 m) and the thug's grey metal reads weakly on the grey smoke ring
   (t362-371); the old rig parts were bigger -> in part 1b823dbf7 (torso 0.7 m, `evidence/n16-kills-polish/rocket_gib_thug_torso_056_vs_070_32ppm_x2_t349-371.png`); the thug's grey on the grey smoke -> open.

## Blade kills, katana, combo 64 and 32 px/m t61-70 (iteration 1)
1. The slash streak read as a white stick through the cop -> fixed de9f68f8a (1 m x 0.06 m). It now reads as a short
   red-lipped line over the cut; the cut's direction still differs from the level drawn swing -> open, minor.

## Boss fight, King + katana, tilt 64 px/m t305-310 (iteration 1)
1. Two upright back-turned frames (t307-308) between the follow-through and the next wind-up -> fixed e4d81df1b
   (6-tick strike hold).

---

## n15 combat (kept for reference)

Ranked within each film; newest film first.

## City street fight (`film.mjs city --ppm=32 --ticks=1200`, stills every 50), combo 32 px/m t100-1150 (session 6, build/film/s6city32)
1. Four riot/patrol cops stand clumped, cards overlapping, on top of the sidewalk wall from t250 to t1150 and never come down to the fight -> open. Session 7 reading of the still: their feet are at the wall's NORTH foot (the road side), not on it: they are pressed against the wall, their way to Rivet (south) blocked (sim/AI path, not this lane), and the wall's cap does not hide them (their cards draw over the prop), so they read as standing on top. Two owners: nav (they never path round the wall's end) and occlusion (a body behind a waist-high wall). Still `evidence/n15-combat/city_fight_cops_on_wall_32ppm_t650.png`.
2. At t650 a cop's card draws over Rivet's head where they meet (depth order at contact) -> fixed ac7991f58 (session 7: filmed 64 px/m t634-660, the cop stood 1.75 m NORTH of Rivet, behind him, but RigDepthSort's one 0.9 x 1.8 m box called it no overlap; now each box is as tall as the drawn card and Rivet's x1.5 wide, `evidence/n15-combat/city_depth_rivet_over_cop_behind_ab_64ppm_t634-660.png`).

## Flamethrower lone kills, swat / ped_cap / ped_punk / ped_jogger, combo 64 px/m t542-620 (session 6)
1. Each burned man stood as the black char print -> fixed c11391625 (it363 drawn char cells).
2. The charred SWAT man holds his charred carbine while the dropped carbine lies at his feet -> fixed 406fb812e (it371 char_v2, empty hands).

## Machine pistol lone kill, cop/head_cap, combo 64 and 32 px/m t336-345 (session 6)
1. Ink dots on the floor 0.5-0.75 m short of the cop at t337-338 and t341-344 -> fixed 273bb2232 (see c-2 #3).
2. At t339 one dot stays on the floor beside the thrown-back card -> fixed in part 61a2d3baa (session 8: the burst rides the card's push; it moves ~0.2 m onto his shadow's edge, `evidence/n15-combat/burst_rides_push_ab_64ppm_x2_t338-344.png`); still a floor print at his feet front while the drawn figure leans back off it -> open, minor.

## Flamethrower lone kill, cop/head_cap, combo 64 px/m t542-620 (session 4)
1. The burned cop stood as a black char-shaded silhouette of his burning pose -> fixed 8eb67bc62 (drawn charred cells, it272, patrol cop only).
2. Other kinds keep the black silhouette -> fixed for the thug, hood and riot cop (63811e09c, it359) and for swat, ped_cap, ped_punk and ped_jogger (c11391625, it363): every kind with a burning figure now ends drawn.
3. The charred SWAT man holds his charred carbine while his dropped carbine lies at his feet (two guns, t560-620; the patrol's drawn char cell holds nothing) -> fixed 406fb812e (it371 char_v2, empty hands; `evidence/n15-combat/swat_char_empty_hands_ab_64ppm_t545-620.png`).

## Machine pistol lone kill, rounds in the ground, combo 48 px/m t352-363 (session 4)
1. A round that stopped in the ground drew four faint grey dots that drifted off: no read of a hit -> fixed 19e7768ff (drawn concrete dust, it317).
2. Metal impacts (crates) still draw the cream strokes: no round on metal filmed -> open, not shipped tonight (session 6: GunFx.shield_test is wired only in tests, so a round on a riot shield is ShieldSparks' white sparks, never a GunFx METAL; a round on a metal dummy is a BODY hit; METAL is only a missed round within 0.9 m of one).

## City street fight, a cop's round on Rivet, combo 48 px/m t363 (session 4)
1. A drawn impact cell on Rivet's plating hides under his rig (the FX print lies under the rigs; only its dark rim shows round his hip) -> kept the cream strokes (not shipped).

## Quest 1 Dock 9, combo 48 px/m t13600-13838 (session 4)
1. A shot contractor stood on as his standing card, then popped to the lying pose -> fixed 302a0d670 (drawn stagger, it321).
2. The stagger cell holds a short gun while his dropped carbine lies beside him (the it321 cells are drawn with a pistol-length gun) -> fixed in part (session 5, v3: he holds the card's long carbine); on a death the dropped carbine still lies beside the held one for 10 ticks -> open, minor (session 6 reading: the drop is `CombatArena.rifle_drops`, a position with no tick, drawn by fx_ground.gd, a file hero may touch; holding it back needs the drop's tick).
3. Every hit in the window was a kill: the living hold (20 ticks) is not filmed -> open.

## Sustained flame jet (session 4 reading of the session-3 film)
- The red starburst column's colour is the owner's look-3 pick (fx_colour_dir "", the ink fire cell, measured ~224,64,32 in the frame), not a drift; the column's SHAPE (patches stacked in a line) stays open.

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
2. The pieces' cut edges are straight across the drawn art (paper-cut look) -> fixed (session 5, drawn pieces it359/it363, patrol + riot cop; owner Call). The pieces are small at 48 px/m and lighter blue than the card's navy -> judge.
3. Before the fix the whole body vanished under the smoke by t366; the pieces now draw over the smoke ring -> judge (z of the gib layer vs the smoke).

## Blades turned left, director chapters <blade>_left, combo 64 px/m (session 3)
1. Turned left, the katana, plasma sword and chainsaw drew the mirrored right strip: through the wind-up he turned his back and the hose arm away from the cop, then swung a large mirrored arc -> fixed 15c8abbcc (drawn left set).
2. At t62 (katana and plasma sword, before and after alike) a long thin white stick runs from the cop down-left to the floor -> open, diagnosed (session 8, build/film/kl64_after t58-69): it is KillSplitFx's designed slash streak (`_draw_streak`: a cream bar edged in ink, STREAK_M 1.7 m along the cut line, ~10 px wide at 64 px/m, thinning over STREAK_TICKS 12). The cut line runs diagonally down-right while Rivet's drawn left swing sweeps level, so the streak reads as a stick through the cop, not as the blade's path. A look call (lane brutality's split style): align the cut to the drawn swing, or shorten/thin the streak (STREAK_M, the width 0.11 m are one value each).
3. The plasma sword's left strike at 64 px/m is a little smaller than its left facing (k shared with the raised wind-up) -> kept (session 8: measured in build/film/plasma_sword64_after, the dome ~80 px wide in the facing t52 vs ~75 px in the strike t62-66, ~6 %; it reads as the strike's crouch; `evidence/n15-combat/plasma_sword_left_strike_size_64ppm_t52-66.png`).

## Boss fight, King + katana, p55 left swings, before --rivet-blade-left=off, 64 px/m t306-326 (session 3, after the gate)
1. Swinging left at King, the mirror swapped his arms and drew the wind-up and strike about 1.4x his facing -> fixed 15c8abbcc (drawn p55 left set, at the facing's size; `evidence/n15-combat/boss_katana_left_set_p55_ab_64ppm_t306-326.png`).
2. The p55 katana's RIGHT wind-up and strike cells draw about 1.4x his facing (the size pop the baton had before 42c826289) -> open, owner Call (session 4: the strip cells measure ~1.1-1.3x by eye, n13/n14 kept as built).
3. The drawn left strike's swing reads smaller than the mirrored one (it is at his size, the mirror was oversized) -> judge with 2.

## Boss fight, King + katana (blade boss bot), tilt p55 64 px/m (session 3)
1. t308: one upright frame (the standing p55 facing) between the follow-through and the next wind-up -> open (the strike clip's recovery ends a tick before the next wind-up starts).
2. Rivet stands over the throne car's body (drawn on top of the King's car): reach is to the body circle -> open, judge (render order vs the boss).

## Dev arena, pistol, feel on (--lock=off), 32 px/m (session 2)
1. Every shot's muzzle light stayed lit for good: white paper fans piled up beside Rivet -> fixed 5bdad7a0c.

## Machine pistol lone kills, 9 kinds, combo 64 px/m (session 2, c-2 films)
1. Thrown-back hit cells drawn from a shallower camera (whole body, upturned face, long legs) between the walk and the fall -> fixed 1ede2ce03 (c-2 redraws, 9 kinds).
2. The body-hit ink burst read as a black ball as wide as the head -> fixed 07bb047cf (body ink 0.12 m).
3. The body-hit burst lands about 0.5 m in front of the drawn thrown-back card, on the floor -> fixed in large part 273bb2232 (session 6). Cause found: a round is "on a body" when its last step passes within radius + 0.3 m of the centre, and the burst was drawn at that step's closest point, up to 0.75 m short (the knock-back was the lesser part). Now on the body's front (GunFxFollow.on_body), riding the knock-back and the death's carry. Left open: at t339-340 one dot still shows near his old spot while the thrown-back CELL draws him ~0.5 m on (the drawing's own offset); on the body the burst draws under his card (FX layer under the rigs). Session 7: the thrown-back man floated ~0.5 m beside his own contact shadow (the card pushed by StreetWalkerHit.shove, the shadow on the feet) -> fixed b9544422e (the shadow rides the push, `evidence/n15-combat/hit_shadow_rides_push_ab_64ppm_x2_t338-344.png`); the t339 dot still sits where the round met him.
4. Every lone victim (suit, punk, thug included) drops the brown rifle at t350, a patrol cop who held a pistol too -> open, likely the dev shot only: `CombatArena._drop` leaves a rifle pickup (a gameplay item, the guards' rifle) for every non-boss fighter, and the lone-victim shot dresses a gunplay hostile as a street kind; a per-kind drop would be a sim change (session 3 reading).
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

## Vehicle shadows, dev/showcase/city_frame --view=combo, 64 and 32 px/m (session 3, n11 "never judged")
- JUDGED, no defect ranked: a parked car casts a hatched ink shadow down-right, the same direction and hatch as the
  planter, bench and bollard beside it, so it stands on the street (`evidence/n15-combat/vehicle_shadows_combo_64_32ppm.png`).
  Minor: on the dark asphalt the hatch is low contrast; the people's soft contact shadows are another shadow language
  than the props' and cars' hatched casts (owner-judged in n11 for figures).
