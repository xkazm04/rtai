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

## Fix (bar 0, n31-09) and what it moved

`StreetPatrolPose.LAND_MID_STANCE` (true; false = the old placement): every anchored walk (patrol
walk/run and the centre-stance kinds) gets `landing = travel * stance * 0.5` with no up clamp, added AFTER
`settle` (inside `pose` the body ease and the stance shift took it back: tried first, S moved only 3 px),
eased `LANDING_EASE` 0.06 ppm (1.9 px) per tick so a reversal does not jump the figure a whole stance
(stepping it at touchdowns instead failed the 12 px reversal tests at 15.5-16 px). Shadows unchanged (still
on the sim point). Probe after (`place_after.jsonl`), drawn planted sole minus ground point at mid-stance,
stances 2-4 (stance 1 starts with no travel in the probe; in play `plant` seeds it from the rig velocity):

| facing | before | after |
|---|---|---|
| S | (-3.6..3.8, -11.0 / -10.6 / -10.2) | (-3.6..3.8, 0.3 / 0.7 / 1.0) |
| N | (-2, 15.4 / 18.4 / 21.4) | (-2, 4.1 / 7.1 / 10.1): NOT MET, grows 3 px a stance (settle stance shift) |
| E (x; the drawing's own sole x is +6.0) | -3.3 / -5.1 / -2.5 | 8.0 / 6.2 / 8.8 |

W sole column in the probe uses the unflipped anchor x (probe bug), not read. Unit:
`test_mid_stance_sole_sits_on_the_ground_point_down_and_sideways` (S, W, E within 3 px of the drawing's own
first-sole offset). The gauntlet x4 crop main | HEAD was not made in this call (clock).

## The N residual over 10 stances (n31-10)

Probe with `--stances=11` (new flag; it now also logs `shift` = `stance_shift`, `eased` = the eased
landing, `body` = the settle's eased torso), patrol walk p70, 3.2 m/s, 32 px/m: `node tools/dev/run.mjs
res://dev/ground_n31/foe_place_probe.gd --keep-going --out=<abs>/place.jsonl --stances=11`. Drawn planted
sole minus ground point (px, y; x is the drawing's own sole column, -2.0 / -2.1 facing N) at mid-stance:

| N stance | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|
| before (`fe5712271`) | 3.2 | 7.9 | 11.0 | 13.9 | 14.4 | 15.6 | 15.2 | 14.8 | 14.4 |
| `stance_shift.y` before | 3.4 | 6.8 | 10.2 | 13.6 | 14.4 | 14.4 | 14.4 | 14.4 | 14.4 |
| after | -0.1 | 1.1 | 0.8 | 0.3 | 0.0 | 1.2 | 0.9 | 0.4 | 0.0 |

The growing term is the settle `stance_shift`, compounding across touchdowns: `touchdown` zeroes it, but
`previous_body` (the eased torso) still carries the last stance's shift, so at the next touchdown `body -
target` = old shift + the part of the torso jump the 0.30 ppm (9.6 px) ease cannot reach. Facing N that
jump is ~13 px, 3.4 px over the reach, so the shift grows 3.4 px a stance until its `ppm * 0.45` (14.4 px)
limit; the sole is the shift give or take 0.3 px. Facing S/E/W the jump is inside the reach: shift 0 on
every stance. The landing ease is caught up from stance 2 on (eased = 11.3 px = half a stance in every
facing); the "N second-stance registration" of term 3 above is this shift, not the drawing.

Fix: `StreetPatrolPose.SHIFT_ACROSS_TRAVEL` (true; false = the old shift): under `LAND_MID_STANCE` the
footfall shortening keeps only its component across the travel (the landing direction), so along the
travel nothing carries into the next stance. N after: within 1.2 px on stances 2-10, stance 10 minus
stance 2 = 0.1 px; S/E/W unchanged (their shift was 0). Unit: `test_mid_stance_sole_sits_on_the_ground_point_down_and_sideways`
now walks S, N, W, E over 10 stances (3 px, and stance 10 minus stance 2 <= 1 px); with the old constant
it fails facing N at 4.2 / 7.7 / 11.2 / 15.1 / 14.7 ... px. The 12 px reversal tests stay green.

## Glide on the no-step columns (n31-13): probe before | glide

Probe `project/dev/ground_n31/foe_place_probe.gd` now walks every facing twice (`glide` false = the
foot lock of HEAD `80b0ae0d2`, true = `StreetPatrolPose.GLIDE_NO_STEP`), adds SW/NW and logs `foot` =
the registered ground point of the planted boot (mark x, `foot_y(mark.y)`) through the placed transform.
`node tools/dev/run.mjs res://dev/ground_n31/foe_place_probe.gd --keep-going --out=<abs>/<kind>.jsonl
--stances=6 [--strip=swat_planted8_armed_walk.png | cop_riot_planted8_armed_walk.png]`, p70, 3.2 m/s,
32 px/m, stances 2-6 (the dev verdict lines say `SCRIPT ERROR 162 (first react_table.gd:49)`: the
headless probe without the autoloads; the jsonl is complete). Stats by `build/n31/n31-13/stats.py`.
Columns: **head** = range of (head top y - sim point y), px; **sway** = range of head x - sim x;
**foot-disc** = max distance planted boot ground point to the sim point (where the disc draws), every
frame; **slide** = max spread of that ground point inside one stance.

| kind / facing | head lock -> glide | foot-disc lock -> glide | slide lock -> glide |
|---|---|---|---|
| patrol S | 12.4 -> **2.0** | 12.2 -> 5.2 | 9.4 -> 22.1 |
| patrol N | 19.2 -> **2.8** | 11.6 -> 2.9 | 9.4 -> 22.1 |
| patrol SE | 10.1 -> **1.5** | 13.9 -> 6.7 | 9.3 -> 24.4 |
| patrol SW | 10.1 -> **1.5** | (x unflipped) | (x unflipped) |
| patrol NE | 13.3 -> **2.1** | 19.6 -> 6.5 | 9.3 -> 23.7 |
| patrol NW | 13.3 -> **2.1** | (x unflipped) | (x unflipped) |
| patrol E (side, unchanged) | 0.6 -> 0.6 | 19.0 -> 19.0 | 9.8 -> 9.8 |
| SWAT S | 35.9 -> **2.0** | 15.7 -> 4.7 | 13.7 -> 30.7 |
| SWAT SE | 12.2 -> **1.5** | 15.6 -> 3.0 | 13.6 -> 32.6 |
| SWAT N / NE | 35.1 / 17.6 -> **2.3 / 2.8** | 15.9 / 15.6 -> 4.2 / 2.4 | 13.7 -> 30.7 |
| riot S | 30.9 -> **2.0** | 14.9 -> 4.5 | 12.0 -> 27.4 |
| riot SE | 11.4 -> **1.4** | 14.1 -> 2.5 | 12.1 -> 29.0 |
| riot N / NE | 28.5 / 15.4 -> **2.9 / 2.4** | 14.2 / 14.1 -> 3.8 / 2.1 | 12.1 -> 27.4 |

SW/NW/W foot columns: the probe's mark x is the unflipped anchor (the old probe bug), not read; their
head column is valid (y only). Side columns E/W are bit-identical lock vs glide (HOLD_TOE_OFF holds).

Reading against the bars (32 px/m, walk): head travel <= 4 px **MET** on every glide column
(1.4-2.9 px, from 10-36 px). Disc: the probe has the planted boot only, not the boot midpoint; the
planted boot sits 2.1-6.7 px from the disc under glide (its own drawn column x), from 11.6-19.6 px
locked: the midpoint bar is unmeasured here. Sole slide <= 3 px per stance **NOT MET**: gliding, the
planted boot travels with the sim point, the whole stance (22-33 px per stance at 32 px/m; the
drawings make no forward step to cancel it), against 9-14 px locked (where the slide is the toe-off
heel registration dropping the figure). The glide trades the hold-then-jump for a skate of the
walking speed on these columns.
