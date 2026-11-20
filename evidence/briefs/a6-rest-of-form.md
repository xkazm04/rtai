# Brief a6-rest (lane dent, n20): transformation, hit reaction and the HUD face for Ejected

(Draft written 02:55 by the iteration-2 director; the next director re-reads it against the state of
the branch before launching. Run it only after a4 strings and a5 films are delivered. Updated 03:45 by iteration 3: items 3 and 4 added.)

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

## 3. Spectral HUD chip face (no new drawing)
Flight's `GhostChipFace` (4362c8109, merged by a4) loads `res://features/hud/art/ghost_chips/<id>_spectral.png`
when the form draws spectral, else the old chip. Make `dent_spectral.png` exactly the way `dent.png`
was made (provenance line 1694 in `steam/ai-provenance/2026-11.jsonl`): run the existing
`tools/art/ghost_chip_cut.py` (do not edit it; if it cannot take this input, write
`tools/art/dent_chip_cut.py` beside it) on the p55 `dent_sp_fly` HOVER cell facing the camera,
84 x 84 RGBA, keeping his own silhouette (head roundel, shoulders, belt; the plume may run off the
foot). Commit the PNG + `.import`, one provenance line ("derived, no new drawing"), and a still of
the HUD chip in game under `--ghost-look=spectral` next to the old one (`scratch/a6/chip.png`).

## 4. Overload test strength
`node tools/mutate/mutate.mjs --file=features/souls/dent_overload.gd` scored 4/20 at a3b: the ring,
shock-disc and spoke geometry are barely asserted. Add assertions to the overload tests (ring
radius = blast_radius_m * ppm, shock radius reaches the ring exactly at +8 ticks and not before,
amber lerp with heat, spokes end at each struck body) until a re-run kills at least 10/20. Quote
killed/(killed+survived).

## 5. Drawn left facings (only if time)
Left facings are mirrors, so the belt diagonal flips. Judge it at 64 px/m: if it reads wrong, list it
as a Call with a still; do not generate new art in this package.

## Order and time (hard, re-cut 04:55 by iteration 4)
Only items **3 (chip)** and **4 (overload tests)** are in this package, in that order. Items 1, 2 and
5 are NOT to be built: if you have a still that bears on them already (flight's transformation stages
were filmed by a5), name it in the report and stop. Every change committed (quick gate green) by
**05:58 local time** whatever its state; after 05:58 make no commit at all (the director's final gate
starts 06:15 on HEAD), only finish the report. Check the clock (`date`) before every commit.

## Report
Files, shas, stills with ticks, mutate scores, what is not done.
