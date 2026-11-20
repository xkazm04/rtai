# Brief a6-rest (lane dent, n20): transformation, hit reaction and the HUD face for Ejected

(Draft written 02:55 by the iteration-2 director; the next director re-reads it against the state of
the branch before launching. Run it only after a4 strings and a5 films are delivered.)

Context: RTAI (`gtai`), ghost form **Dent**, rebuilt tonight as "Ejected" (plate
`C:\Users\kazda\kiro\gtai-masters\n20\concepts\dent_a.png`). Body, flight, strap, strings, overload
and films are in (read `git log --oneline -30`). VISUAL night: no sim/replay/parity digest moves,
no timing moves. Same machine rules and repo law as the earlier briefs (APPDATA=.../appdata/dent,
d3d12, `--position 0,1440`, one Godot at a time, PID kills only, stage per path, never push,
`node tools/gate/quick.mjs` before each commit). Edit only `dent_*` files, new `dent_*` files,
`test_dent_*`, Dent's rows. `project/features/hud/ghost_chip_face.gd` is flight's: if the HUD chip
must change, write what is needed in your report (the director sends a NEED to flight).

## 1. Transformation in and out (spectral look)
Film the current morph into and out of Dent under `--ghost-look=spectral` (review driver, move take,
first 70 ticks, tilt 70 and top, 64 px/m) and LOOK at it. If it still shows the old standing body,
legs or a walk at any frame, replace Dent's part of it: Rivet's body thrown upward, the crash
roundels lighting one by one (head, then shoulders), the comet tail igniting from the belt down. Out:
the tail gutters and the glass falls to the road. Use the existing transformation timing exactly
(read where the morph's length comes from; do not change it). Stills of 4 phases each way.

## 2. Hit reaction
When Dent is hit (the shared hit lean is `GhostRecoil.LEAN_BY_FORM`, 12 degrees for Dent: do not
change it), his spectral cell must be the HIT column of `dent_sp_fly` (a2 packed it) and the tail
must flicker; check it is drawn, both tilts and the top view. Stills at the hit tick and +6.

## 3. Drawn left facings (only if time)
Left facings are mirrors, so the belt diagonal flips. Judge it at 64 px/m: if it reads wrong, list it
as a Call with a still; do not generate new art in this package.

## Report
Files, shas, stills with ticks, what is not done. Stop at 50 minutes.
