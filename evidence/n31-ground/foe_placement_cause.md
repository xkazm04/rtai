# Foe placement cause (n31-09, 32 px/m, p70): why the contact disc leaves the boots

Probe: `project/dev/ground_n31/foe_place_probe.gd` (the shipped `StreetCopWalk.Contact.place`, i.e.
`touchdown` + `StreetPatrolPose.pose` + `settle`, no render; texel = the gauntlet card scale 0.3173 for
`p70/cop_patrol_planted8_armed_walk.png` at 1.7 m, 32 px/m, fill 1.12 x 256/192). The patrol cop walks
3.2 m/s for two strides (54 ticks) facing S, N, W, E. Per tick it logs the sim ground point `at` (where
`RigCastShadows._draw` and `CardContactShadow.follow` put the disc), the stance origin, the placed
drawing's sole and torso (the drawing's anchor through the placed transform). Run:
`node tools/dev/run.mjs res://dev/ground_n31/foe_place_probe.gd --keep-going --out=<abs>/place.jsonl`
-> 216 rows (the SCRIPT ERRORs in the log are autoloads missing under `-s`: `Log`, `LaunchArgs` in
react_table/view_mode, not on the Contact path). Gunner not run in this call.

## Numbers (drawn sole minus ground point, px; + = right/down)

One stance = `half` (4) drawings x `WALK_M` 0.1765 m = 0.706 m = **22.6 px**. Every 3rd tick:

| facing | stance start | +6 ticks | +12 ticks (stance end) | next stance start |
|---|---|---|---|---|
| S (walks down) | (3.8, 0.5) | (3.8, -9.7) | (3.8, -20.0) | (-3.6, -2.5) |
| N (walks up)   | (-1.9, 0.5) | (-1.9, 10.7) | (-1.9, 21.0) | (-2.1, 6.9); 2nd stride ends at (-2.0, 29.9) |
| W              | origin +0.0 .. +20.5 px east of `at` over the stance (sole column of the held drawing 6..11 px) |
| E              | origin -0.0 .. -21.4 px west of `at` |

The stance origin minus `at` runs 0 -> -21.4 px along the travel (a sawtooth, reset at each touchdown)
in every facing, in step with the sole.

## Cause

1. **The foot lock holds the drawing back, the disc runs ahead.** `Contact._advance` sets `origin = at -
   travel * fmod(walked, half * step)` at each touchdown and `pose` keeps the stance's planted sole on
   `origin` (`_ground`: `first.sole - ink.sole + ink.torso`), so the drawn planted boot stays put while the
   sim point moves one stance (22.6 px) ahead before the next touchdown. The disc is drawn on the sim point,
   so it slides 0 -> 21 px AHEAD of the planted boot every stance and snaps back: facing S the disc is up to
   20 px below the boots, facing N the boots are up to 21 px (30 px with term 2) below the disc, sideways it
   is up to 21 px ahead. This is the "sole 24-39 px below the ground point facing N" and the detached disc in
   play: it is not roll, stretch or settle (those move the sole < 1 px here: the sole column is constant
   within a stance to 0.1 px).
2. **Patrol has no centre-stance landing.** `touchdown` only adds `landing = travel * distance * 0.5`
   when `centre_stance` (foe marks, warden, Mulroney); the patrol walk/run keeps `landing = 0`, so its
   whole stance trails the sim point. For the centre-stance kinds the N direction is cut by
   `landing.y = maxf(landing.y, -distance * 0.25)` (only the up direction is clamped), so walking N they keep
   a quarter stance (5.6 px at this step) of the trail; S/E/W get the full half.
3. **N second-stance registration**: facing N the second stance's first drawing sits 3.9 -> 10.7 px below
   the first stance's (sole minus origin 3.9..10.7 vs 0.5); an anchor/first-drawing registration term, not
   fixed in this call.

Play direction note: n31-06 saw the disc right of and below W walking cops in the take (p3_sheet, frames
300-345). With this model a W walker's disc leads to the LEFT; right-and-below fits a cop whose travel is
E/SE (backing or strafing while aiming W) or the N case. Not re-measured in the take in this call.

## Choice for bar 0

The mid-point between the soles over a stance (planted at `origin`, swing foot from `origin - S` to
`origin + S`) is `origin + travel * (w - S/2)` = `at - travel * S/2`: it trails the sim point by half a
stance, smoothly. So place the drawing half a stance forward (the centre-stance landing, unclamped) for
every anchored walker, which puts the mid-stance point on the sim point where both shadows already draw;
the shadows stay on the sim point (no jump). `DECISION` with the fix.
