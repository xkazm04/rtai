# n31 melee 02p3 part 1 - sweep geometry from the clean pixels (flag on only)

Inputs: 01e's body-free judged cells `evidence/n31-melee/02-sweep/volumes/<weapon>.json` (per ring cell: drawn,
drawn_ks; the drawn side does not depend on the hit rules) and `volumes/drawn_ticks.json` (`deg_p5_p95`,
`reach_p95` over the cutting ticks, facing 0 = the bar's ring). Choice made with a replica of
`MeleeSweep.crosses` over the cut window (`build/n31/02p3/geo.py`, scratch): it reproduces the probe's hit
column of the 01e after to 0-4 cells of 60 (claw 0, chainsaw 3, baton 2, katana 4, plasma 1; lunge timing).

Field semantics (checked in `MeleeSweep.crosses`): `d > reach_m + f.radius_m` -> `sweep_reach_m` is to the
victim's EDGE (the sweep adds its 0.45 m radius); the pixels' reach is the blade point's ground distance from
Rivet's START, so the chosen reach = drawn reach minus the lunge that has arrived at the cut (katana 0.55 m,
`sweep_lunge_ticks` 4; chainsaw 0.6 m). No 0.45 m subtraction.

Arc: the sim's sector (`MeleeSwing.angle` default shape, half-arc acos(cone_dot)) runs about -1.35 .. +1.3 x
the half-arc in the swing's side frame. New optional `sweep_arc_deg` [lo, hi] (side frame, deg) on a swing
row clamps each sweep tick's drawn angles (`MeleeSweep.span`), read only with `--melee-sweep`
(`MeleeHit.adopt_sweep`); off = unclamped, no digest moves.

| weapon | before reach (edge) / sim arc | drawn (facing 0, cut ticks, p95) | chosen | why (one row) |
|---|---|---|---|---|
| claw (claw_rake) | 1.40 / -81 .. +78 (cone 0.5) | reach 1.68-1.73 / -62 .. +30 | reach 1.40 (kept), arc [-62, 34] | sideways hits at 60-90 deg 1.4 m and -90/1.4 with nothing drawn: clamp to the drawn range; longer reach would hit 0/+-30 at 2.0 m (not drawn) |
| chainsaw (chainsaw_drive) | 1.65 / -50 .. +48 (cone 0.8) | reach 2.50 - lunge 0.6 = 1.90 / -44 .. +24 (cut), windup at -124 .. -36 | reach 1.65, arc unchanged; sweep ends at the first bite (part 2) | hit-not-drawn already 0; narrowing loses 60/0.8 (drawn+hit); longer reach or wider arc only raises its +19 % guard |
| electro_baton (electro_baton_crack) | 1.50 / -72 .. +69 (cone 0.6) | reach 2.15-2.16 / -139 .. +39.5 (lo = body/arm leak behind) | reach 2.20, arc [-50, 45] | tip drawn ahead at 2.0 m (-60..30) and 0/2.6 m: reach to the tip; sideways 60/2.0 and +-90/0.8-1.4 hits with nothing drawn: clamp |
| katana (katana_cut) | 1.80 / -96 .. +93 (cone 0.32) | reach 3.14-3.34 from start (2.6-2.8 from the lunged body) at k5-7, 2.73 at k8+ / -148 .. +16 (-99 at k8+) | reach 2.25, arc [-100, 20] | tip drawn at 0/3.2 m: 2.25 is the shortest reach that reaches it from the lunged body (3.2 - 0.55 - 0.45 = 2.2); 2.5-2.8 adds undrawn hits at -30..-90 / 2.6-3.2 m (the drawn far blade is a narrow tip, a sector cannot fit it); hi 20 keeps 30/1.4 (drawn) and drops 30-90 deg at 1.4-2.6 m (not drawn) |
| plasma_sword (plasma_sword_sweep) | 1.90 / -137 .. +132 (cone -0.2) | reach 2.53 / -60 .. +41 | reach 2.20, arc [-48, 41] | tip drawn at 0/2.6 and 30/2.6: reach 2.2 (2.6 - 0.45 = 2.15, rounded up); the hit cone reached +-90..120 deg where nothing is drawn: clamp; lo -48 keeps -60/2.0 (drawn) and drops -60/2.6 (not) |

Replica, front of him (-90..+90 deg), facing 0: in-cut drawn-no-hit / hit-not-drawn

| weapon | 01e after (provisional rules) | chosen |
|---|---|---|
| claw | 1 (-60/2.0) / 5 | 1 (-60/2.0) / 1 (-90/0.8) |
| chainsaw | 5 / 0 | 5 / 0 (geometry unchanged; windup-to-cut swing-in drawn at -60..-90 deg) |
| electro_baton | 5 / 3 | 1 (60/1.4, model edge) / 2 (+-30/2.6) |
| katana | 2 / 5 | 2 (-90/0.8 lunge edge, 30/1.4) / ~4 (-30..-90/2.6) |
| plasma_sword | 1 / 8 | 1 (60/1.4) / 2 (-30/2.0, -30/2.6) |

The measured after (part 3, a real render + hit model with the flag) replaces this replica.

Open risk (not a bar): the drawn reach is facing-dependent. Cut-tick reach p95 from start, facing 0 / 90 /
315: claw 1.68 / 1.57 / 1.89, chainsaw 2.50 / 2.12 / 1.96, baton 2.15 / 1.54 / 1.66, katana 3.14 / 1.91 / 2.00,
plasma 2.53 / 1.98 / 1.89. One `sweep_reach_m` per weapon cannot match all three; the choice follows facing 0
(the ring the bars judge). At 90 and 315 the baton, katana and plasma reach past their drawn blade.
