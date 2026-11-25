# n31 melee 01a - blade volume, before (tree 30e70f80c, no game rule changed)

Command: `node tools/melee/blade_volume.mjs --label=before` (headless, fixed 60 Hz, seed 20261109,
`--enemy-brain=squad --silent`). Files: `before/volumes.json`, `before/<weapon>.json`, `before/<weapon>.png`,
`before/sheet.png` (left to right: hands, chainsaw, electro_baton, katana, plasma_sword), `before/table.md`.
Setup: one standing patrol_cop dummy per swing (radius 0.45 m, pinned, gun cold) at 12 angles x 5 distances
(0.8 .. 3.2 m); Rivet swings once facing 0 deg (k 0 = the press). Mover: the same dummy crossing at 1.4 m/s
along x = 1.4 m, on the aim line `lag` ticks after the hit test (lags -10, 0, 10, 20, 30, 45, 60; both directions).
Hit = the swing's hit test landed (the dummy is the only hostile). Drawn = the blade segment or swipe crescent
the views carry that frame touches the body circle (ground metres: layer px / PX_PER_M less ShotLift's lift).

| weapon | drawn-no-hit /60 | of them drawn after the test | hit-not-drawn /60 | both | hit test k | cut drawn k | blade/crescent shown k | overlaps drawn k | mover hit / drawn / drawn-no-hit (of 14) | blade in strip pixels only k |
|---|---|---|---|---|---|---|---|---|---|---|
| hands (claw) | 0 | 0 | 2 | 6 | 4 | 1..6 | 2..12 | 2..12 | 12 / 13 / 1 | - |
| chainsaw | 0 | 0 | 6 | 0 | 11, 22, 30 | 8..15 | - | - | 11 / 0 / 0 | 0..48 |
| electro_baton | 14 | 10 | 1 | 6 | 3 | 0..5 | 0..19 | 0..19 | 13 / 12 / 1 | - |
| katana | 0 | 0 | 16 | 0 | 6 | 3..9 | - | - | 14 / 0 / 0 | 0..25 |
| plasma_sword | 0 | 0 | 25 | 0 | 7 | 4..13 | - | - | 14 / 0 / 0 | 0..31 |

## Read this before using the drawn columns

1. **Facing 0 deg, katana, plasma_sword and chainsaw are drawn only by Rivet's d9 strip cell**
   (`RivetFrames.owns_weapon` true, `RivetStrips.hides_held` true, `RivetSwipe.needs_arc` false, and
   `RivetMuzzle.point(rivet_eq_<weapon>.png, FIRE_SIDE)` is (-1, -1)): no view node carries the blade's
   geometry, so their "drawn" is 0 by construction, not by measurement. Their hit counts stand
   (katana 16, plasma 25, chainsaw 6 ring cells hit). Measuring them needs the cell's pixels (a rendered frame
   per tick, the blade's pixels thresholded), not node reads.
2. **The overlay check FAILS.** `overlay_check_electro_baton.png` (64 px/m, k = hit test + 1): the measured
   blade (magenta) starts on Rivet's chest and points down-right, while the drawn baton lies across his
   front to the left; `overlay_check_hands.png`: the measured crescent (green) is a small arc at his feet,
   not the drawn swipe. So the baton and hands drawn columns (14 / 10 / 1 and 0 / 2) are NOT validated; the
   baton's drawn reach out to 3.2 m in `before/electro_baton.png` points the same way. Suspects: the
   layer-to-world mapping (the rig layer is drawn under the tilt camera; px / PX_PER_M - lift is not the
   ground point) and the smear root.
3. The tick windows are sound (read from the combo and the strike clip, not from positions): the cut is drawn
   from k 1 (claw) / 0 (baton) / 3 (katana) / 4 (plasma) / 8 (saw), the hit is tested once at k 4 / 3 / 6 / 7
   (the saw at k 11, 22 and 30 while its bite holds), and the strip / held blade stays drawn to k 12 .. 48.
   The cut (MeleeSwing.cutting) keeps drawing 2 (claw, baton), 3 (katana), 4 (saw, past its first bite) and
   6 (plasma) ticks after the single test tick, and the blade stays on screen well past that: a body that
   enters the drawn cut after the test tick is never hit by that swing (the mover rows at lag 45-60).
