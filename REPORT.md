# REPORT: lane `view` (n7x-view), night 2026-11-06. DRAFT (iteration 9, 05:35; final at 08:40)

## The question

Can a slight change of camera angle, plus character art drawn for that angle, lift RTAI's visual
impression to another level, staying 2D / 2.5D at a cost the whole cast can afford?

**My answer so far: yes, for the characters and the King's car, at 55 degrees.** The same seeded
King fight reads as people and a car seen from a raised angle (King's crowned bust, Rivet's
visor face from the logo, the car's side wall, wheels and raised cannon) instead of discs and
rectangles. The cost is one image round per head variant plus code. The owner judges this, not me.

Every view sits behind `--view=<id>` (`project/data/tables/view.json`). The default `top` is
today's game, bit-identical: `top` frames are md5-identical with the King lane's own files
(seed 2, ticks 900 and 2040, 32 px/m), and the depth sort, cards and stacks never run straight down.

## Watch these first (gtai-masters/n7/view/, frames.json order)

1. `king_top_toplift_tilt_32ppm_it9.mp4`: the same seed-2 King fight, 45 s, top | top_lift |
   tilt at 32 px/m, on King's latest art (n7-king b2e71b83 merged).
2. `king_p3_top_vs_tilt_48ppm_it9.mp4`: phase 3, King on foot vs Rivet, 48 px/m close-up.
3. `king_p2_top_vs_tilt_32ppm_x2_it9_t34s.png`: phase 2 still, top vs tilt, 32 px/m shown x2.
4. `king_depth_sort_before_after_48ppm_x2_it9.png`: draw order under tilt, before | after.

## What works (evidence)

- `--view` switch + `view.json` rows: `top`, `top_lift` (straight down, perspective eye 25 m),
  `top_lift15`, `tilt` (55 + facing cards), `tilt65`, `tilt45` and the card-less study rows.
- 2.5D cutout rigs (`RigTilt`): every part keeps its top-down art, lifted by its height, so free
  rotation is kept. Upright facing cards (5 drawn + 3 mirrored) for Rivet, King, the gang, the
  patrol cop and the riot cop.
- King's car as a sprite stack from code (18 slices, round wheels, raised cannon, standing throne
  back), King's cloth cape draped.
- Draw order MEASURED and FIXED in the arena (`RigDepthSort`): reversed pairs 16 % -> 2 %,
  interleaved parts 71 % -> 4 % (seed 2, 60 s; `evidence/view/it9/order_tilt_sort.log`).
- Mouse aim unprojected through the tilt (`ViewMode.ground_of`, unit-tested; NOT checked live
  with a mouse: unattended run).
- Exe: `build/export/windows/RTAI.exe` (windows-showcase, exported it9 on 3625f68a, re-exported at
  the freeze). Smoke `--view=tilt` headless: King down at tick 4933, 0 SCRIPT ERROR.

## What does not work yet

- The car's bumpers float at roof height under tilt. The city's parked sedans are flat. No
  occlusion silhouettes behind tall walls. King's accents and the ghost/kill overlays sit at one
  fixed z over the rigs.
- `top_lift` is a modest gain (the heights lean out from the centre; nothing changes near Rivet).
- Heads without a card (SWAT, the 6 ped heads, the robot thug, the other bosses) still read top-down.

## Cost table

See `docs/view-lab/PLAN.md` "Cost table draft" (finalized here at the freeze).

## Calls for the owner (draft)

1. **The view**: `top` (shipped) / `top_lift` / `tilt`. My default: `tilt` (55 + cards). It is the
   only option that shows the faces and the car's body; its cost is per head variant, not per clip.
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=top`
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=top_lift`
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt`
2. **The pitch**: 55 (default) vs 65 vs 45, one data value each (`--view=tilt65`, `--view=tilt45`).

## Gates (switch off)

Iteration 9 on the merge: lint 13/13, unit 1181/1181 0 SCRIPT ERROR; scenarios, the director reel
and evidence/run.mjs: to be run on the final HEAD.
