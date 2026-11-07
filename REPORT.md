# n8 lane `city`: buildings, roofs and props under the angled view

DRAFT written in iteration 22 (04:30); the freeze session updates the gates, the exe and the
head commit. Branch `n8-city`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\city\` (`frames.json`,
15 entries, best first). Memory: `JOURNAL.md`.

## What works (with evidence)

1. **Facades** (brief item 1). Under any angled view every building's roof is lifted by its height and
   its south face is drawn under it, tiled bay by bay from a style's wall strip (tenement, shop, and
   a six-storey `tall` style for the 17-21 m landmarks), ink-edged, in the print grain. Corners come
   from two straight runs (no oblique side face). Art per pitch (`p55` / `p70`) from the library's
   facade kits; data in `data/tables/city_facades.json`. `top` builds none of it.
   Evidence: `it1_facades_32ppm_top_vs_tilt70.jpg`, `it16_facade_tall_48ppm_before_after.png`,
   `it22_facade_tall_v3_tilt70_32ppm_before_after_x2.png`, the set clip `it25_city_set_tilt70_combo_55s.mp4`.
   All facade strips are from the library's latest raw sheets (0510/0525: muted brick and rust).
2. **Occlusion** (item 2). A body behind a building draws as an ink silhouette with a rim over the
   exact world pixels (a back-buffer copy, no second print). `occlude: false` puts the old look back.
   Evidence: `it4_occlusion_32ppm_before_after_x3.png`.
3. **Props stand up** (item 3). 19 street props stand as five-facing cards in the depth sort, with
   their ground shadow: payphone (quest 1's start), hydrant, trash can, mailbox, bench, newsstand,
   bus stop, vending machine, planter, dumpster, barrel cluster, crate stack, cone, police barrier,
   barricade, lamp, traffic light, and (iteration 22) the street sign and bollard. Every strip has a
   55 and a 70 drawing of **one design**, so combo's hard swap no longer changes any prop's design.
   The arenas' cover and quest 1's payphone, dumpsters and TUCK-IN crates use the same cards (the
   crates as a two-layer box: the flat art as the top over a cut front face).
   Evidence: `it12_quest1_payphone_48ppm_top_vs_tilt70.png`, `it16_bench_v2_48ppm_before_after_x2.png`,
   `it16_lamp_busstop_v4_48ppm_before_after.png`, `it22_busstop_lamp_v55_tilt48_before_after_x2.png`,
   `it22_kerb_bollard_sign_tilt70_32ppm_before_after_x3.png` (+ the 48 px/m close-up),
   `it19_quest1_tuckin_crates_tilt70_32ppm_before_after_x2.png`.
4. **Boss arena dressing** (item 4). Servo's depot (shutter bays, conveyors, cartons, pallets, roll
   cages) and the King's district stand as cards around the arena at 55 and 70, swapping with combo.
   Evidence: `it7_depot_dressing_tilt55_before_after.jpg`, `it7_king_district_dressing_tilt55_before_after.jpg`,
   `it7_king_dressing_combo_70_to_55.jpg`, `it22_depot_bays_v3_combo48_frame880.png`.
5. **Cost** (item 5), bench.lock held: the city drive at tilt70 vs top costs ~0.5 ms per frame
   (occlusion 0.15-0.21 ms after the building index cache, draw calls +16 %); an angled chunk costs
   ~3.3x to record but the time slice spreads it over ~3 frames (per-frame streaming p99 2.27 ->
   2.62 ms). `evidence/drive-cost-it11.json`, `evidence/chunk-cost-it10.json`.
   Refreshed at 0a630cfe (iteration 25, tonight's facade strips and kerb cards, bench.lock held,
   other lanes' Godot work running): the drive averages 1.04 ms (top) vs 1.28 ms (tilt70) per frame,
   p99 CPU 2.05 vs 3.15 ms, draw calls 823 vs 961 (+17 %); a chunk records in 0.80 ms (top) vs 3.48 ms
   p50 (tilt70) but over 39 frames, so no streaming frame passes 1.72 ms (0 frames over 2 ms either
   view). tilt70 had 6 frames over 25 ms (top 0, worst 39 ms, none over 50): not attributed, and the
   chunk slice is not it. `evidence/drive-cost-it25.json`.

## Gates (iteration 22, head f07b348e)

- `top` bit-identical: `--arena=city --bot=rivet --seed=2 --rigs --quit-after 301` framemd5 identical
  to the it19 baseline (617 lines), 0 SCRIPT ERROR.
- lint 15/15; unit (full no-arg) 1523 passed, 0 failed.
- Director reel at tilt70 (`--bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`, 7600
  frames headless): 19/19 chapters down, 0 SCRIPT ERROR (`evidence/director-reel-it22-tilt70.log`).
- Scenarios: 52 ran, 0 failed (vehicle drive timing CONTENDED, labelled by the runner).
- Last `evidence/run.mjs --no-bench`: PASS at 7b63bcb1 (iteration 19). FREEZE: re-run.

## What does not work / gaps

- The baked crowd (multimesh peds) is not occluded, only rigs.
- The kerb props keep their flat art's hatched shadow as the ground shadow (a diagonal stroke beside
  the street sign).
- The 55 street sign and lamp are B sheets (a little steep); accepted for the matched design.
- Roof dressing cards (`roof_dressing_v3`) not integrated: the baked roofs already paint them.

## Calls for the owner

1. **Facade height.** Options: true height (`height_k` 1) or a shortened cut (0.5). Built: **0.5**
   (the north sidewalk stays visible; Rivet is not lost behind a roof lift). See
   `it1_height_k_1_vs_05_tilt70_32ppm.jpg`; exe:
   `RTAI.exe res://dev/arena/arena.tscn -- --arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`
   (change `height_k` in `data/tables/city_facades.json` to see 1.0).
2. **Occlusion style.** Options: fade the building, cut it away, or an ink silhouette of the body.
   Built: **ink silhouette with a rim** (the arena's PropOcclusion look, so the city and the arenas
   agree); `occlude: false` = none. See `it4_occlusion_32ppm_before_after_x3.png`.
3. **Quest 1's TUCK-IN crates**: a two-layer box built from the flat art (built) vs a drawn sheet
   (REQUEST to assets). See `it19_quest1_tuckin_crates_tilt70_32ppm_before_after_x2.png`.
4. **The lamp's 70 width** (1.45 m cell: 1.3x a walker would be squat at 1.15). See
   `it16_lamp_busstop_v4_48ppm_before_after.png`.

## Exe

FREEZE: export to `build/export/windows/RTAI.exe` (the int-day recipe in `docs/decisions.md`) and
put the exact command lines here.

## Next steps

- 70 twins and raises as the library serves them (traffic light 55 with a shorter pole).
- Occlude the baked crowd; a drawn shadow for the kerb sign.
