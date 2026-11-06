# REPORT: lane `view` (n7x-view), night 2026-11-06 (final, freeze iteration 18)

## The question

Can a slight change of camera angle, plus character art drawn for that angle, lift RTAI's visual
impression to another level, staying 2D / 2.5D at a cost the whole cast can afford?

**My answer: yes, for the characters and the King's car, at 55 degrees.** The same seeded
King fight reads as people and a car seen from a raised angle (King's crowned bust, Rivet's
visor face from the logo, the car's side wall, wheels and raised cannon) instead of discs and
rectangles. The cost is one image round per head variant plus code. The owner judges this, not me.

Every view sits behind `--view=<id>` (`project/data/tables/view.json`). The default `top` is
today's game, bit-identical: `top` frames are md5-identical with the King lane's own files
(seed 2, ticks 900 and 2040, 32 px/m), and the depth sort, cards and stacks never run straight down.

## Watch these first (gtai-masters/n7/view/; frames.json lists all 15)

1. `king_top_toplift_tilt_32ppm_it12.mp4`: the same seed-2 King fight, 45 s, top | top_lift |
   tilt at 32 px/m, on King's latest art (n7-king b2e71b83 merged), with the it12 cast shadows.
2. `king_p3_top_vs_tilt_48ppm_it12.mp4`: phase 3, King on foot vs Rivet, 48 px/m close-up (it12).
3. `king_p2_top_vs_tilt_32ppm_x2_it12_t34s.png`: phase 2 still, top vs tilt, 32 px/m shown x2.
   `king_tilt_noshadow_vs_cast_32ppm_x2_it12.png`: the cast shadows under tilt, off vs on.
   `city_block_top_vs_tilt_32ppm_it12.png`: the city block (`--arena=city`), top vs tilt.
4. `king_views_grid_32ppm_it12_t12s.png`: every view at one tick (top / top_lift / tilt65 / tilt /
   tilt45_cards), 32 px/m unscaled crops.
5. `king_depth_sort_before_after_48ppm_x2_it9.png`: draw order under tilt, before | after.
6. `city_occlusion_tilt_noocclude_vs_tilt_32ppm_x4_it15.png`: occlusion under tilt, a cop behind
   the city block's barrier, standing (tick 649) and downed (tick 1060), off | on.
7. `concept_three_quarter_per_facing_king_rivet.png`: CONCEPT, not a game frame (one Codex
   image round). The optional stronger three-quarter view with every character redrawn per
   facing, shown only for what the most expensive option buys over `tilt` (cost table, last column).

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
- Occlusion under tilt (it15, `PropOcclusion`, view.json `occlude`; `tilt_noocclude` = before): a
  body behind a standing arena prop (barrier, dumpster, crate row) is hidden by the prop redrawn
  over it (pixel-identical to the floor's) and shown as an ink silhouette with a cream rim, cut to
  the prop; a body in front of it is lifted over it. MEASURED: the city block (seed 2, 60 s) has
  176 body-frames behind a prop, the King fight (seed 2, 90 s) 8 (`evidence/view/it15/`).
- Mouse aim unprojected through the tilt (`ViewMode.ground_of`, unit-tested; NOT checked live
  with a mouse: unattended run).
- Exe: `build/export/windows/RTAI.exe` (`windows-showcase`, re-exported at the freeze on 78d652d7,
  0 errors, `build/export-it18.log`; it now packs the baked city chunks; the main scene is the arena,
  so `--boss=king` and `--arena=city` both work). Smoke headless on that exe
  (`evidence/view/it18/exe_*.log`, identical to the it15 export's counts): `--view=tilt` King
  fight: King defeated, 8 body-frames hidden, 0 SCRIPT ERROR; `--view=tilt` city block: 176 hidden,
  0 SCRIPT ERROR; `--view=top` King fight: King defeated, 0 SCRIPT ERROR.

## What does not work yet

- The city's parked sedans are flat under tilt and cast no shadow; the city's baked crowd casts no
  figure shadow. Occlusion covers the arena's station props only: the city chunks' own props and
  buildings are still flat under tilt, so nothing there can hide a body yet. King's accents and the ghost/kill overlays sit at one
  fixed z over the rigs.
- `top_lift` is still a modest gain: the cast shadows now give Rivet and the car a height cue, but
  no face or body side ever shows straight down.
- Heads without a card (SWAT, the 6 ped heads, the robot thug, the other bosses) still read top-down.

## Cost table

Numbers are from the it4-it18 builds (`docs/view-lab/PLAN.md` has the derivations). Every Godot
timing tonight is CONTENDED (five lanes on one machine; during the A/B below the King lane ran
9 headless fights at once).

**Frame cost of `tilt` vs `top` (it18, MEASURED, CONTENDED, under the bench lock).** The exported
release bench (`windows-bench`, windowed, vsync off), city `drive_dense` at 32 px/m, 30 s, two
passes each, alternating (`evidence/view/it18/bench/`):

| | `top` (2 passes) | `tilt` (2 passes) | change |
|---|---|---|---|
| avg frame | 0.86 / 0.89 ms | 1.01 / 1.00 ms | about +0.13 ms (+15 %) |
| p99 CPU frame | 2.02 / 2.00 ms | 2.26 / 2.24 ms | +12 % |
| render CPU avg | 0.31 / 0.32 ms | 0.41 / 0.40 ms | +0.09 ms |
| draw calls avg | 370 / 370 | 572 / 574 | +55 % |
| visible actors avg (max) | 23.3 (42) / 23.4 (42) | 28.6 (51) / 28.5 (51) | +22 % (the 1.22x ground) |
| chunk failures, >25 ms hitches | 0, 0 / 0, 0 | 0, 0 / 0, 1 | |

So the tilt sees 22 % more people (as computed: 1/sin 55 = 1.22) and costs 55 % more draw calls
(the cards, the depth-sorted parts, the cast shadows), but its frame stays near 1 ms, far under
section 20's limits. What this does NOT measure: the city's buildings and parked cars under tilt
(still flat, so their future walls and roofs are not in this cost), and an uncontended machine.

| | `top` (shipped) | `top_lift` (90, perspective eye 25 m, cast shadows) | `tilt` (55 + facing cards + cast shadows) | three-quarter per facing (not built) |
|---|---|---|---|---|
| Art per character | 0 | 0 | 1 card strip per head variant: 1 image round (56-78 s), 5 of 5 usable first try; still owed: SWAT, 6 ped heads, robot thug, other bosses (about 10 rounds) | every part x 8 facings x every clip: a redraw of the cast |
| Art per vehicle | 0 | 0 (the stack leans; cast shadow swept from code) | sprite stack from code (King's car: 18 slices, round wheels, raised cannon: 0 art); parked sedans still flat | per-facing sprites |
| Art per building / prop | 0 | 0 | south faces in code (arena props, city barriers); city buildings not done | per-facing |
| Aim | ok | ok (uniform zoom) | fixed it7 (`ground_of`), unit-tested, not mouse-tested live | same as tilt |
| Draw order | n/a | small (heights lean outward; unmeasured: the probe reads no lean straight down) | MEASURED + FIXED in the arena (it9): reversed 16 % -> 2 %, interleaved 71 % -> 4 %, car 0.5 %; owed: King accents, ghost/kill overlays, the city's baked crowd | same, harder |
| Occlusion | n/a | n/a | BUILT it15 for the arena's station props (`PropOcclusion`: the prop redrawn over a body behind it, an ink silhouette with a cream rim, a body in front lifted over it; 0 art). MEASURED: 176 body-frames in 60 s on the city block, 8 in 90 s of the King fight. Owed: the city chunks' own props and buildings (still flat under tilt), the baked crowd (not rigs) | same, more often (taller lift) |
| Streaming bubble | 1.0 | 1.0 | 0 extra chunks (it12, computed from code): residency is sim-driven, R_SIM 190 m around the focus; visible ground at 32 px/m grows 60 x 33.75 m -> 60 x 41.2 m (1/sin 55 = 1.22x) plus a 40 m roof's lift from south of the screen (cot 55 x 40 = 28 m), all inside 190 m. draw cost MEASURED it18: +15 % frame, +55 % draw calls (CONTENDED, table above) | 0 chunks; 1.41x ground at 45 |
| Cast shadows (it12) | none | 0 art: a figure per body, the car and props swept (`RigCastShadows`); city sedans, buildings' own and the baked crowd not yet | same code, foreshortened on the ground; `tilt_noshadow` = without |  |
| What breaks if shipped today | nothing | nothing visible (city sedans and the baked crowd cast no figure shadow) | interleaved people in crowds, overlays over the wrong rig, flat city buildings (no occlusion there yet), uncarded heads read top-down | everything until redrawn |

Image rounds so far: 5 card strips (Rivet, King, gang, patrol cop, riot cop), 5 of 5 usable on the
first try, 56-78 s each. The rest of the current roster under `tilt` is about 10 more rounds (one
per head variant), plus code for the city's buildings, chunk props and parked cars.

**The default I would pick: `tilt` (55 degrees, facing cards, cast shadows, occlusion).** It is the
only option where the King's face and crown, the car's body and Rivet's logo visor read at the
shipped 32 px/m; its art cost scales with head variants, not with clips, so the whole cast can
afford it. `top_lift` is the fallback if the owner keeps straight down: free, but a modest gain.

## Calls for the owner

1. **The view**: `top` (shipped) / `top_lift` / `tilt`. My default: `tilt` (55 + cards). It is the
   only option that shows the faces and the car's body; its cost is per head variant, not per clip.
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=top`
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=top_lift`
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt`
   - To watch the same seeded fight played by the bot (as filmed), append
     `--bot=boss --bot-human --seed=2` to any line above.
   - Side by side: `gtai-masters/n7/view/king_top_toplift_tilt_32ppm_it12.mp4` (45 s, 32 px/m).
   - Frame cost (it18, CONTENDED): tilt +15 % frame, +55 % draw calls vs top; frame near 1 ms.
2. **The pitch**: 55 (default) vs 65 vs 45, one data value each in `view.json`. Still:
   `gtai-masters/n7/view/king_views_grid_32ppm_it12_t12s.png`.
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt_cards` (65, with cards, no cast shadows)
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt45_cards` (45, with cards, no cast shadows)
   - (`--view=tilt65` / `tilt45` / `tilt75` are the same pitches without cards and shadows)
3. **Cast shadows by height** (a low evening sun, down-right): on (default, `--view=tilt`) or off
   (`--view=tilt_noshadow`). My pick: on; they ground the car and the bodies on the foreshortened
   road at 0 art cost. Still: `gtai-masters/n7/view/king_tilt_noshadow_vs_cast_32ppm_x2_it12.png`
   (in-repo copy: `evidence/view/it12/tilt_noshadow_vs_cast_32_x2_t900.png`).
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt`
   - `build/export/windows/RTAI.exe -- --rigs --boss=king --view=tilt_noshadow`
4. **Occlusion under tilt** (it15): a body behind a barrier, dumpster or crate row is hidden by it
   and shown as an ink silhouette with a cream rim (default, `--view=tilt`), or drawn over the
   prop as in it12 (`--view=tilt_noocclude`). My pick: on. Without it a cop behind the city
   barrier stands on its lid; with it the barrier reads as a solid wall and the cop as hidden
   behind it. It fires mostly on the city block (176 body-frames in 60 s, seed 2); the King fight
   barely shows it (8 frames in 90 s). Still: `gtai-masters/n7/view/city_occlusion_tilt_noocclude_vs_tilt_32ppm_x4_it15.png`.
   - `build/export/windows/RTAI.exe -- --rigs --arena=city --bot=rivet --seed=2 --view=tilt`
   - `build/export/windows/RTAI.exe -- --rigs --arena=city --bot=rivet --seed=2 --view=tilt_noocclude`
   (the showcase export's main scene is the arena; watch the south barrier from about 11 s to 19 s)

## Gates (switch off)

- **Final, it18 on 8b7a5982** (the last code commit eb09836f is dev-only: the city bench takes
  `--view`): `node tools/evidence/run.mjs --no-bench` all PASS: lint 13/13, unit 1190/0, scenarios
  52, parity bit-exact (mutation caught at step 629), look goldens 11/11 + block 5/5
  (`evidence/view/it18/evidence-run-8b7a5982.log`). Also all PASS on 02af876a (code = 08e56ab6).
  Director reel (`--bot=reel --reel=director --loadout=pistol --rigs`, headless) on ae9b1502:
  19/19 chapters fully down, 0 SCRIPT ERROR (`evidence/view/it18/director-reel-19of19-ae9b1502.log`).
- it15 on 08e56ab6 (occlusion in): `node tools/evidence/run.mjs --no-bench` all PASS (lint 13/13,
  unit 1190/0, scenarios 52, parity bit-exact, look goldens 11/11 + block 5/5;
  `evidence/view/it15/evidence-run-08e56ab6.log`); director reel 19/19 fully down, 0 SCRIPT ERROR
  on a56fc835 (`evidence/view/it15/director-reel-19of19.log`); `top` md5 b5ed2b94 (seed 2 tick 900)
  unchanged.

- it12 (cast shadows in): `node tools/evidence/run.mjs --no-bench` on 52e72590 all PASS (lint,
  unit 1181, scenarios 52, parity bit-exact, look goldens 11/11 + block 5/5;
  `evidence/view/it12/evidence-run.log`), and on 3059b7b1 all PASS (unit 1186); scenarios on
  abc9c37a 52 ran / 0 failed; director reel on 16d83cbd 19/19 fully down, 0 SCRIPT ERROR. One
  earlier run at 06:02 (no commit) hit the known `scenario_city_chase` nav-budget flake; the
  re-run passed.
- it9 on the n7-king merge (6cb9e9ef): lint 13/13, unit 1181/0, scenarios 52/0, director reel
  19/19 fully down, 0 SCRIPT ERROR.

## What blocked or slowed me

- The contended machine: five lanes on one box. Every film took 2-4x real time, the director reel
  about 15 min headless; the one bench (it18, the tilt A/B) is labelled CONTENDED.
- Godot 2D clipping: `clip_children` on the actor layer drew nothing, and a pooled `clip_contents`
  Control drew one row (it15, about 45 min). Occlusion was built another way, with polygon
  intersection (`Geometry2D.intersect_polygons`) and the prop redrawn over the body.
- Warnings-as-errors traps (`bool(Variant)`, `Dictionary.get` typing) and the evidence runner's
  clean-tree rule (logs must go outside the tree) each cost a re-run.
- Not blocked: the image route. 5 of 5 card strips came back usable on the first try.

## Next steps (if the owner picks `tilt`)

1. Cards for the rest of the cast: SWAT, the 6 ped heads, the robot thug, the other bosses (about
   10 image rounds, one per head variant; `RigHeadCard.key_of`).
2. City under tilt: south faces and roofs at height for the chunk buildings and props, the parked
   sedans as code sprite stacks like the King's car, and occlusion over them (`PropOcclusion`
   extended from the arena's station props to the chunk props).
3. Draw order still owed: King's accents and the ghost/kill overlays at one fixed z, and the
   baked crowd (not rigs) in the depth sort.
4. Re-take the tilt bench once the city's buildings and parked cars have walls (it18 measured
   today's tilt only: +15 % frame, +55 % draw calls, CONTENDED), and on a quiet machine.
5. A live mouse test of aim under tilt (`ViewMode.ground_of` is unit-tested, not played).
6. If `top` stays: keep `top_lift`'s cast shadows as the cheap upgrade (0 art).
