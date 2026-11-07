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
   The arenas' cover cards give view's PropOcclusion their real outline (`PropCards.stand_polys`,
   iteration 26, view's REQUEST): a body behind a crate stack is inked only where the crates are,
   no black kite over the card's see-through corner. The crate stack also keeps its cream under
   PropOcclusion's redraw (it went vermilion-orange: a colour-law breach). Filmed on a trial merge
   with n8-view: `it26_card_outline_cut_king_combo_64ppm_before_after_x3.png`,
   `it26_crate_print_twin_king_combo_64ppm_before_after_x3.png`.
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
   `it19_quest1_tuckin_crates_tilt70_32ppm_before_after_x2.png`, `it25_street_sign_cast_tilt70_32ppm_before_after_x3.png`
   (the sign, lamp and traffic light cast a hatched pole stroke from the foot, down-right like every
   other shadow: `cast_m` in their props rows; `it25_lamp_cast_...`, `it25_traffic_light_cast_...`;
   the lamp's and signal's end in a globe / head blob, `it26_lamp_globe_blob_...`).
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

## Gates (iteration 26, head 55ede50c)

- `top` bit-identical, two recipes, 301 frames each, framemd5, 0 SCRIPT ERROR:
  - the city arena (`res://dev/arena/arena.tscn -- --arena=city --bot=rivet --seed=2 --rigs`):
    HEAD 55ede50c identical to the branch base 0bea8b93 (iteration 26);
  - the boot scene (`-- --arena=city --bot=rivet --seed=2 --rigs` without the arena scene: the boot
    ignores `--arena`, so this is the game's own start; the it19-it25 gate was this one) identical
    to the it19 baseline at 55ede50c.
- unit (full no-arg) 1526 passed, 0 failed, no FLAKY (55ede50c).
- lint 15/15 every commit.
- Director reel at tilt70 (`--bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`, 7600
  frames headless): 19/19 chapters down, 0 SCRIPT ERROR (`evidence/director-reel-it26-tilt70.log`, bf579226).
- Scenarios: 52 ran, 0 failed, exit 0 at bf579226 (vehicle drive timing CONTENDED, labelled by the runner).
- Last `evidence/run.mjs --no-bench`: PASS at 492f14f1 (iteration 25: lint, unit 1524/0, scenarios 52, parity, selftest goldens, export-audit 563/0). FREEZE: re-run.

## What does not work / gaps

- The baked crowd (multimesh peds) is not occluded, only rigs.
- The squat kerb props keep their flat art's hatched silhouette as the ground shadow (it reads as
  one); the three poles (street sign, lamp, traffic light) cast a drawn stroke since iteration 25, and
  since iteration 26 the lamp's and the traffic light's end in a round blob for the globe / signal
  head (`cast_blob_m`; `it26_lamp_globe_blob_tilt70_48ppm_before_after_x3.png`). The traffic light's
  blob was looked at under 55 only (no before/after pair).
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
- Occlude the baked crowd.
