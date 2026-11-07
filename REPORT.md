# n8 lane `city`: buildings, roofs and props under the angled view

FINAL (iteration 30, the freeze session, 07:55; re-checked at iteration 38, 08:42: every evidence
path cited below exists, and since the exe's commit 7a43f001 `project/` differs only by one
`tests/unit` file, which the export does not ship). Later commits touch only JOURNAL/REPORT/docs and
that test. Branch `n8-city`. Evidence: `C:\Users\kazda\kiro\gtai-masters\n8\city\` (`frames.json`,
15 entries, best first). Memory: `JOURNAL.md`.

## What works (with evidence)

1. **Facades** (brief item 1). Under any angled view every building's roof is lifted by its height and
   its south face is drawn under it, tiled bay by bay from a style's wall strip (tenement, shop, and
   a six-storey `tall` style for the 17-21 m landmarks), ink-edged, in the print grain. Corners come
   from two straight runs (no oblique side face). Art per pitch (`p55` / `p70`) from the library's
   facade kits; data in `data/tables/city_facades.json`. `top` builds none of it.
   Evidence: `it1_facades_32ppm_top_vs_tilt70.jpg`, `it16_facade_tall_48ppm_before_after.png`,
   `it22_facade_tall_v3_tilt70_32ppm_before_after_x2.png`, the set clip `it30_city_set_tilt70_combo_51s.mp4` (facade drive, the riot's crowd behind the roofs, the 55 traffic light at 48 px/m, the King fight under combo, the city block with rigs; labelled).
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

## Gates (freeze, iteration 30)

- `node tools/evidence/run.mjs --no-bench --no-release` at 7d73de04: PASS (lint 15/15, unit 1530/0,
  scenarios 52, parity bit-exact over 1200 steps + planted mutation caught at 629, selftest: look
  goldens 11/11 + block 5/5, world lock 0.00 %, no new off-doctrine accents).
- export-audit: `node tools/tests/release_compile.mjs` at 7d73de04, run alone: 565 loaded, 0 failed.
  (Two full runs died in this stage with EPERM on `%TEMP%/gtai-release-compile`, a fixed temp path
  every worktree shares, while another lane's release-compile held it; see Next steps.)
- `top` bit-identical, two recipes, 301 frames, framemd5, 0 SCRIPT ERROR, at 7a43f001 (same
  project tree): the boot scene (`-- --arena=city --bot=rivet --seed=2 --rigs`) identical to the
  it19 baseline; the city arena (`res://dev/arena/arena.tscn -- --arena=city --bot=rivet --seed=2
  --rigs`) identical to the branch base 0bea8b93.
- Director reel at tilt70 (`--bot=reel --reel=director --loadout=pistol --rigs --view=tilt70`) at
  7d40e58d (same project tree): 19/19 chapters down, 0 SCRIPT ERROR (`evidence/director-reel-it27-tilt70.log`).
- Bench: not re-run at the freeze (no bench.lock taken); the last cost numbers are item 5's, iteration 25.

## What does not work / gaps

- The baked crowd is hidden behind the lifted roofs since iteration 27 (`CityCrowdOcclusion`,
  `it27_crowd_occlusion_riot_drive_tilt70_32ppm_before_after.png`; cost 110-205 us/frame CONTENDED);
  riot bodies the sim leaves inside a footprint still draw over it.
- (Closed, iteration 30: not a game defect.) The dark band at the riot's top edge (f389, f569) is
  the bench's own churn: `BenchDriver` evicts a chunk next to the riot every 180 ticks so swaps keep
  happening, and an evicted chunk on screen goes and is redrawn. In play a chunk drops only beyond
  330 m (`CityResidency.R_DROP`), off screen. A hide-until-whole swap was built and filmed: it made
  the bench gap longer (2 -> 3-4 frames) and moved no pixel of the King's combo engage, so it was not
  landed. `it30_riot_bench_churn_f568_f569_tilt70_32ppm.png`.
- The squat kerb props keep their flat art's hatched silhouette as the ground shadow (it reads as
  one); the three poles (street sign, lamp, traffic light) cast a drawn stroke since iteration 25, and
  since iteration 26 the lamp's and the traffic light's end in a round blob for the globe / signal
  head (`cast_blob_m`; `it26_lamp_globe_blob_tilt70_48ppm_before_after_x3.png`,
  `it26_traffic_light_head_blob_tilt70_48ppm_before_after_x2.png`).
- The 55 street sign and lamp are B sheets (a little steep); accepted for the matched design. The
  55 traffic light is the library's A `traffic_light_55_v6` since iteration 27 (short pole, ~55
  camera; `it27_traffic_light_v6_55_tilt_48ppm_before_after_x2.png`).
- Roof dressing cards (`roof_dressing_v3`) not integrated: the baked roofs already paint them.

## What blocked me (and for how long)

Nothing was a hard block (no `BLOCKED` entry in JOURNAL). The frictions that cost time:

- **The shared release-compile staging dir** (07:26-07:55, ~30 min): two full evidence runs died at
  export-audit with EPERM on `%TEMP%/gtai-release-compile` while another lane's run held it. Worked
  around with `--no-release` plus `release_compile.mjs` run alone (JOURNAL l.1226, l.1257).
- **The `top` bit-identity baseline drifted with the machine** (23:33, ~45 min to bisect): every
  commit, the base included, re-recorded to new hashes, so the drift came from the driver or audio,
  not the code; the base was re-recorded (JOURNAL l.367).
- **A wrong `top` recipe** (found 05:59): with no scene path the gate ran the boot scene, not the
  city block; both recipes are gated since (JOURNAL l.1082).
- **Film time on a shared machine**: a 720-frame film at 32 px/m took 3-9 min while other lanes ran
  Godot; one 48 px/m close-up was stopped unfinished (JOURNAL l.193).
- **Waiting on 70 twins and 55 raises from `assets`**: REQUESTs at JOURNAL l.72-78, 323, 794-799;
  meanwhile the 55 drawings were stretched to 70. Most were served overnight. The last, `planter_v3`
  55, came after the freeze (see Next steps).

## Calls for the owner

1. **Facade height.** Options: true height (`height_k` 1) or a shortened cut (0.5). Built: **0.5**
   (the north sidewalk stays visible; Rivet is not lost behind a roof lift). See
   `it1_height_k_1_vs_05_tilt70_32ppm.jpg`; exe:
   `RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`
   (change `height_k` in `data/tables/city_facades.json` to see 1.0).
2. **Occlusion style.** Options: fade the building, cut it away, or an ink silhouette of the body.
   Built: **ink silhouette with a rim** (the arena's PropOcclusion look, so the city and the arenas
   agree); `occlude: false` = none. See `it4_occlusion_32ppm_before_after_x3.png`.
3. **Quest 1's TUCK-IN crates**: a two-layer box built from the flat art (built) vs a drawn sheet
   (REQUEST to assets). See `it19_quest1_tuckin_crates_tilt70_32ppm_before_after_x2.png`.
4. **The lamp's 70 width** (1.45 m cell: 1.3x a walker would be squat at 1.15). See
   `it16_lamp_busstop_v4_48ppm_before_after.png`.

## Exe

`C:/Users/kazda/kiro/gtai-wt/n8-city/build/export/windows/RTAI.exe` (282 MB, + the sim DLL beside
it), exported 07:21 at 7a43f001 (the project tree of the final head: later commits touch only
JOURNAL/REPORT/docs). Export: `"$GODOT_BIN" --headless --path project --export-release windows-showcase
../build/export/windows/RTAI.exe` (exit 0). The showcase preset's main scene is the arena, so no scene
path goes on the command line (a release template refuses one). Smoke-run: the first line below,
600 frames, exit 0, 0 SCRIPT ERROR.

- The city block at 70 (play): `RTAI.exe -- --arena=city --bot=course --seed=2 --rigs --clean --view=tilt70`
- The same at 48 px/m: add `--ppm=48`; the shipped `top` look: drop `--view=tilt70`.
- Walk it yourself: `RTAI.exe -- --arena=city --rigs --view=tilt70`
- The King's district (combo, 70 easing to 55 on engage): `RTAI.exe -- --boss=king --rigs --view=combo`
- Servo's depot: `RTAI.exe -- --boss=servo --rigs --view=combo`

## Next steps

- `planter_v3` 55 A landed in the library at 07:37 (the 70's design at 55, superseding the in-game
  planter_v2 55 set): cut it into the p55 prop set (d9; the p70 planter is already that design).
  Cut and looked at in scratch at iteration 32 (`gtai-n8/scratch/city/it32/out/p55/prop_planter.png`,
  side by side with v2 in `it32/planter_v2_top_v3_bottom.png`): a drop-in, `cell_w_m` 2 holds.
- The arena city block's kerb barriers (ArenaStation `wall_high`) do not hide the crowd atlas's lying
  dead behind them at tilt70 (view's NOTE, repro `--arena=city --seed=5`, tick 900, 32 px/m; still in
  view's masters `FOUND_corpse_head_over_barrier_merged_it17_tilt70_32ppm_seed5_t900_crop3x.png`):
  `CityCrowdOcclusion.patches` only takes streamed buildings; feed the arena's tall props in as
  `Bld`-shaped occluders (d9). Agreed split with `view`: an `extra` occluder list on CityOcclusion,
  filled by view's `ArenaFloorView` (ground rect + the 3.0 m lift at the live pitch), merged into
  `_scan_crowd`. The premise is unit-proven at ea4d38c0 (`test_a_kerb_barrier_shaped_occluder_hides_
  a_lying_body_behind_it`: a 6 x 0.6 m wall hides a body lying behind it, not one in front; test-only).
  City's half is a verified drop-in: `gtai-n8/scratch/city/it33/d9_city_occlusion_extra_v2.patch`
  (`git apply` clean at 108d740e; a public `extra` list + a static `CityOcclusion.merge_extra` with
  its own unit case; lint 15/15 and `--select=test_city_occlusion,test_city_crowd_occlusion` 9/0
  with it applied). View's handle: the node is a child of `view.actor_layer()` (`attach` adds it
  there), so view finds it by type; returning it from `attach` and storing it on CityView was tried
  and fails the debt ratchet (city_view.gd 259 -> 261, past the soft cap).
- Tooling (not city's): give `release_compile.mjs`'s staging dir a per-worktree/pid name, so
  parallel lanes' evidence runs stop colliding (EPERM).
- 70 twins and raises as the library serves them (the traffic light 55 short pole: served and cut at iteration 27).
- If a streamed-city scene ever eases its pitch live (combo outside the boss arenas), ChunkView
  releases every chunk at the 12-frame settle: keep the old chunk on screen until its redraw is whole
  (the iteration 30 `ChunkSwap` draft, JOURNAL).
