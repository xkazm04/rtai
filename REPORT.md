# REPORT: lane `view` (n7x-view), night 2026-11-06. DRAFT (iteration 12, 06:30; final at 08:40)

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

1. `king_top_toplift_tilt_32ppm_it12.mp4`: the same seed-2 King fight, 45 s, top | top_lift |
   tilt at 32 px/m, on King's latest art (n7-king b2e71b83 merged), with the it12 cast shadows.
2. `king_p3_top_vs_tilt_48ppm_it12.mp4`: phase 3, King on foot vs Rivet, 48 px/m close-up (it12).
3. `king_p2_top_vs_tilt_32ppm_x2_it12_t34s.png`: phase 2 still, top vs tilt, 32 px/m shown x2.
   `king_tilt_noshadow_vs_cast_32ppm_x2_it12.png`: the cast shadows under tilt, off vs on.
   `city_block_top_vs_tilt_32ppm_it12.png`: the city block (`--arena=city`), top vs tilt.
4. `king_views_grid_32ppm_it12_t12s.png`: every view at one tick (top / top_lift / tilt65 / tilt /
   tilt45_cards), 32 px/m unscaled crops.
5. `king_depth_sort_before_after_48ppm_x2_it9.png`: draw order under tilt, before | after.

## What works (evidence)

- `--view` switch + `view.json` rows: `top`, `top_lift` (straight down, perspective eye 25 m),
  `top_lift15`, `tilt` (55 + facing cards), `tilt65`, `tilt45` and the card-less study rows.
- 2.5D cutout rigs (`RigTilt`): every part keeps its top-down art, lifted by its height, so free
  rotation is kept. Upright facing cards (5 drawn + 3 mirrored) for Rivet, King, the gang, the
  patrol cop and the riot cop.
- King's car as a sprite stack from code (18 slices, round wheels, raised cannon, standing throne
  back, bumpers at bumper height), King's cloth cape draped.
- Cast shadows by height (it12, `RigCastShadows`, view.json `cast_k` 1.2, down-right as the city's
  building shadows) in `top_lift` and `tilt`: a tapered figure per body, the King's car and the
  arena props swept footprint to roof. 0 art. `top` unchanged (md5 b5ed2b94 / c66f823d).
  Stills: `evidence/view/it12/toplift_cast_before_after_32_t900.png`,
  `evidence/view/it12/tilt_noshadow_vs_cast_32_x2_t900.png`.
- Draw order MEASURED and FIXED in the arena (`RigDepthSort`): reversed pairs 16 % -> 2 %,
  interleaved parts 71 % -> 4 % (seed 2, 60 s; `evidence/view/it9/order_tilt_sort.log`).
- Mouse aim unprojected through the tilt (`ViewMode.ground_of`, unit-tested; NOT checked live
  with a mouse: unattended run).
- Exe: `build/export/windows/RTAI.exe` (windows-showcase, re-exported it12 on eba837e4 with the cast
  shadows, 0 errors; re-exported again at the freeze). Smoke headless `--view=tilt` and
  `--view=top`: King defeated, 0 SCRIPT ERROR, the two logs identical but for prewarm timing
  (`evidence/view/it12/exe_*.log`).

## What does not work yet

- The city's parked sedans are flat under tilt and cast no shadow; the city's baked crowd casts no
  figure shadow. No occlusion silhouettes behind tall walls. King's accents and the ghost/kill overlays sit at one
  fixed z over the rigs.
- `top_lift` is still a modest gain: the cast shadows now give Rivet and the car a height cue, but
  no face or body side ever shows straight down.
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
3. **Cast shadows by height** (a low evening sun, down-right): on (default, `--view=tilt`) or off
   (`--view=tilt_noshadow`). My pick: on; they ground the car and the bodies on the foreshortened
   road at 0 art cost. Still: `evidence/view/it12/tilt_noshadow_vs_cast_32_x2_t900.png`.

## Gates (switch off)

Iteration 9 on the merge (6cb9e9ef): lint 13/13, unit 1181/0, scenarios 52/0, director reel 19/19
fully down, 0 SCRIPT ERROR. Iteration 12: `node tools/evidence/run.mjs --no-bench` on 52e72590 all
PASS (lint, unit 1181, scenarios 52, parity bit-exact, selftest look goldens 11/11 + block 5/5;
`evidence/view/it12/evidence-run.log`); unit 1186/0 after the cast shadows. An earlier run at
06:02 (no commit) hit the known `scenario_city_chase` nav-budget flake; the re-run passed.
Director reel on 16d83cbd (it12, cast shadows in): 19/19 fully down, 0 SCRIPT ERROR; scenarios on abc9c37a: 52 ran / 0 failed; evidence/run.mjs --no-bench on 3059b7b1: all PASS (unit 1186, scenarios 52, parity, look goldens 11/11). Bench: not run.
