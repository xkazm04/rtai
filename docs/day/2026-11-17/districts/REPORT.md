# REPORT - night n18, lane districts (final, 2026-11-18 07:2x)

Branch `n18-districts` (worktree `C:\Users\kazda\kiro\gtai-wt\n18-districts`), cut from `int-n17` at `36dd26ba6`.
Evidence: `evidence/n18-districts/` (in the branch) and `C:\Users\kazda\kiro\gtai-masters\n18\districts\frames.json`.

## What works (with its evidence)

| Item | What | Evidence |
|---|---|---|
| 1 zones as data | layout consts -> `city_district.json` zone rows (`gtai.city-district/2`), zone map of chunk rects; step one byte-identical at v14 (`bake --check`), planted share change caught. `CityZones.of_chunk(cx, cy)` / `id_of_chunk` expose the zone per chunk (police may read). Session 6: zone rows take `car_art` (the traffic mix, read game side by the police lane's spawner after the merge) | commits 634b2f552, 6ca059905; `evidence/n18-districts/zone_map_v15.{png,json}`; test_city_zones |
| 2 zone layouts + lint | docks east band (48 chunks, 18.75 %): long warehouse blocks over dropped streets, yard rows, quay + water; downtown centre (25 chunks): denser towers, plazas, crowds; mixed elsewhere. test_city_zone_lint: roads one network, sidewalks + zebras one network, every zone has road and sidewalk | e8ecb61c9 |
| 3 art | v16 warehouse/shed/tower roofs + water; dock + glass facades (+ brick dock and stone office alternates); v17 water bug fix; v18 quay edge autotile; v19 container yards; v20 downtown plazas (one fountain per plaza), cold store, sawtooth, square tall roofs; v21 one lettered name a block; v22 it471 roofs (clocktower, terrace, billboard tall roof, bank dome + crown 2x2, shed b, warehouse c kept upright by `upright_roofs`), sculpture v3; v23 zone grounds (downtown plaza granite `plaza_ground`, docks apron `apron_ground`); v24 plaza singles (coffee kiosk, food cart); v25 docks yard ground (`yard_ground`); v26 docks dressing (`DockDresser`: tarps + fuel tanks on the quay apron, a lifebuoy by each basin's coping); v27 downtown's own street furniture (`kerb_props` + `wall_props`); v28 Dock 9's harbour office roof (`office_roof`); v29 the asset lane's ochre twins and a bow-north tug moored in half the basins (`basin_boat`); v30 downtown plaza singles (planter bed, stone ledges, chess tables, flower crates); v31 the docks apron mix (propeller, crab pots, dinghy); v32 nav buoys and scrap skip. Session 6: it477 crab pots + rope net v2 (values lifted); v33 fish tanks + gutting tables on the apron, plaza steps + tree bench as downtown plaza singles, and texture rows' `shadow` key (false on the rope net and crab pots: their dark shadow copy showed through the mesh cards; the value lift alone did not lift them). test_city_zone_cards: every standing prop a zone names has a card row | `evidence/n18-districts/ab_*` (one pair per version, named `ab_<offer>_<what>_v<N-1>_v<N>_combo_{32,48}ppm.jpg`); v33: `ab_it476_apron_fish_v32_v33_combo_{32,48}ppm.jpg`, `ab_it476_plaza_steps_bench_v32_v33_combo_{32,48}ppm.jpg`, `ab_shadowless_{rope_net,crab_pots}_v33_combo_48ppm.jpg`, `ab_it477_crab_rope_v1_v2_v32_combo_{32,48}ppm.jpg` |
| 4 places | `data/tables/places.json` + CityPlaces.place(id) -> {zone, block, chunk, cell, door, facing}; a row's optional `door` (`middle` or `office`) says where on the frontage the door stands; test_city_places, test_dock_office | ca6b1fcc2, bf5857f6f |
| 5 Dock 9 | v28: Dock 9 has a landmark in the city, the harbour office at the quay end of its block (test_dock_office pins it to places.json's dock_9 rule). `--quest1-places`: Dock 9's own stage points sit before the dock_9 door; off by default; scenarios flag off 55/55. Flag ON: quest1_input pays (930 s, 0 deaths, 49 kills, replay identical) with the door before the harbour office | b0314350c, 0511d8629, bf5857f6f; `evidence/n18-districts/quest1_places_on_office_door.txt`, `ab_dock9_door_middle_office_v30_combo_{32,48}ppm.jpg`, `dock9_door_office_rivet_v32_combo_{32,48}ppm.jpg` |
| 6 film | docks -> downtown drive, 37 s at 32 px/m (pass 3 on v32); a 37 s drive along the docks quay apron (v32); each zone before tonight vs v33 at 48 px/m, same points (before = a bake with only the mixed row, i.e. the v14 rules) | `evidence/n18-districts/drive3_docks_downtown_v32_combo_32ppm.mp4`, `drive4_docks_apron_v32_combo_32ppm.mp4` (+ `_sheet.jpg`), `zones_v14_v33_combo_48ppm.jpg`; masters frames.json (15) |

Generator numbers (tile counts measured on v32, `evidence/n18-districts/zone_map_v32.{png,json}`; v33 changed props only and was not re-measured): docks 48 chunks (18.75 %), 3832 block
tiles + 2408 plaza/yard/quay tiles; downtown 25 chunks (9.77 %), 2000 block + 500 plaza tiles; mixed 183 chunks
(71.48 %), 16125 block + 2175 plaza tiles. Generating all 256 chunks: 3.6 s in the zone-map run; a full bake 4.9 s
wall on v32, 4.8 s on v33 (both CONTENDED: not under the bench lock). v33's new props over all 256 chunks: fish tanks 11, gutting tables 6, plaza steps 16, tree benches 13.

Gates: full gate (`tools/gate/run.mjs --rev=HEAD --reels`, snapshot) PASS on 4c4afb209 (v33, the final code commit 99f8b3071 + JOURNAL): lint 19/19, unit 2898/0 (2 skipped), scenarios 55/55, parity bit-exact (planted caught at 629), look goldens 11/11 (worst 0.31), 141 art textures 0 placeholders, release-compile 727/0, reels exit 0 (`build/gate/4c4afb2099b4/gate.json`). Before it: PASS on e597460ec (v32), same numbers (unit 2896/0, 137 textures), reels exit 0. After it: 771ae3ba9 adds one unit test (test_city_kerb_parked); full unit on it 2900/0 (2 skipped), lint at commit 18/18 staged-scope, full lint on 82b3a05b0 19/19 (07:3x, stabilize); the rest is JOURNAL/REPORT.

Mutate `features/city/gen/dock_dresser.gd`: 6/12 (50 %), then 10/12 (83.3 %) after 73e02f64b; the two survivors are near-equivalent. Mutate `features/city/gen/kerb_dresser.gd` with its mapped unit tests (kerb_props, dock_dressing, plaza_singles, chunks, zone_lint, lane_grid): 0/10 (0 %): the sampled lines are the n14 parked cars, cut lists and offsets, which no unit test asserts; their guard is the AST-12 golden list: two survivors planted by hand (:63 parked car shadow true -> false, :104 0.12 -> 1.12) both fail `bake_city.gd -- --check` (chunks differ from the golden list). Then test_city_kerb_parked (771ae3ba9: lamps every other kerb tile, parked cars / lamps 0.6-1.0, one shadow copy each): 2/10 (20 %); the 8 survivors are rnd salts, offsets, the cut list and decal ranges, still guarded only by the golden list. Mutate `dev/bots/bot_route.gd`: 7/8 (87.5 %). Mutate dock_painter.gd: 4/12 (33.3 %); the survivors are look-only, pinned by the golden hash list; the one real gap (:126) got a test (bc29c8a7e).

## What does not work
- `--quest1-places` ON costs a player a long walk: Harbor Road -> Dock 9 takes 348 s on foot and back 343 s (quest 930 s vs
  317 s). The quest has no car leg.
- Docks yards put walkers right against a warehouse's north wall, so the rigs' "behind a roof" ink silhouettes
  (CityOcclusion, n8 design) show often there as black wedges on the roof edge (`zones_v22_combo_48ppm.jpg`, yard panel).
  Not changed.
- The zone `car_art` rows are data only on this branch: the spawner that reads them is the police lane's file (NEED police in
  JOURNAL); until then every zone draws `CitySpawner.CAR_ART`.

## What blocked or slowed the lane (no hard block)
- Nothing blocked an item outright; the asset lane delivered through the night (it471-it477), so no item waited on art.
- 02:33, about 15 min lost: an evidence run on the live tree came back INVALID because I edited files while it ran. Fix: gates
  go through `tools/gate/run.mjs` (snapshot) from then on (JOURNAL 02:33).
- `tools/gate/quick.mjs` reports FAIL on tests that reach CitySystem: a check-only compile cascade from
  `core/events/events.gd`, while GUT passes them. Worked around with full unit runs; `REQUEST tools:` in JOURNAL.
- Lint tool-tests fail 6 kill_reel break tests while new PNGs are not yet imported (they read the real tree); clears after
  `--import`. `REQUEST tools:` in JOURNAL.
- `git show <rev>:<png>` returns the LFS pointer; importing it rewrote tracked `.import` files with `valid=false`, about
  10 min to restore (smudge + checkout of the `.import`). Before/after renders now smudge first.

## Calls for the owner
- Dock 9 into the docks by default? (today: behind `--quest1-places`). Recommendation: not yet. It plays (quest1_input pays
  with the flag on), but the walk is 348 s each way on foot, and the quest has no car leg yet.
- Dock 9's door: built before the harbour office (places.json `door: "office"`), so the landmark and the quest marker
  coincide (`ab_dock9_door_middle_office_v30_combo_32ppm.jpg`, before = mid-block). Revert: delete the key; the bake does not move.
- Hazard stripes (orange/black) on the tug, the rope net and the 2x2 tower roofs: danger marking (allowed vermilion) or
  off-law? Tonight all ship as the asset lane's `_ochre` twins; the striped files are not used.
- Each zone's look, before tonight vs v33 at the same points (48 px/m): `zones_v14_v33_combo_48ppm.jpg` (Dock 9's harbour
  office, the fish quay, the Toner Room's downtown street, a granite plaza with steps + tree bench).
- Docks on the east edge (vs another edge); downtown size (25 chunks) and landmark density (0.35).
- Downtown's granite plaza ground (v23) is darker and busier than the mixed zone's slabs: keep, or a lighter granite?
  (`ab_it471_ground_plaza-32ppm_v22_v23_combo.jpg`)
- Art taken late and why: crab pots and rope net v1 read as dark heaps (median L 53-85); the asset lane's it477 v2 lifted the
  values (182-206), but in game the read barely moved (`ab_it477_crab_rope_v1_v2_v32_combo_48ppm.jpg`): our offset shadow
  copy showed through the mesh. v33 turns their shadow off (`ab_shadowless_rope_net_v33_combo_48ppm.jpg`). Call: keep
  shadowless mesh props (they sit lighter on the ground, a touch less anchored), or a softer shadow for see-through art?
- Taken in v33 (it476, A): fish tanks, gutting tables (apron), plaza steps, round tree bench (downtown singles). The fish
  tanks' grey water is the darkest object on the apron at 48 px/m (`ab_it476_apron_fish_v32_v33_combo_48ppm.jpg`).
- Art not taken and why: oil drums v2 rust-red (red is blood only) -> ochre twin taken; nav buoys v1 (magenta key spill) and
  scrap skip v1 (fewer than five facings) -> v2 taken; the plan twins of propeller / nav buoys / scrap skip (the combo view
  draws the cards, so no visible change; the skip's plan cast a longer shadow than its card); the coaster ship (drawn
  east-west, the basins run north-south); the silos (need a landmark rule). Flower crates ship as a once-a-block single,
  not a slot prop (six in one frame as a slot prop).

## Merge notes
- Re-blessed: `project/data/generated/city_chunks.sha256` (GENERATOR_VERSION 14 -> 33).
- Schema keys added (optional, defaults keep the old output): `city_district` zone rows `car_art` (not a generator input);
  `city_textures` rows `shadow` (default true). No replay or parity digest moved
  (the city replay digests move when the police lane's spawner reads `car_art`: one re-bless after the merge).
- `tools/debt/baseline.json`: dev_loc 21992 -> 22089 accepted (dev/bots BotRoute; reason stored).
- Tools touched (no tools lane tonight): `tools/godot/check.mjs` (shutdown report is not a cause; 1ce6ece2f),
  `tools/film/film2.break.test.mjs` (hang timer 2 s -> 15 s; 81c409665).
- Shared files touched: `project/boot/launch_args.gd` (one flag line `--quest1-places`).

## Next steps
1. Police lane (after the merge): `city_spawner.gd` reads `CityZones.of_chunk(cx, cy).car_art`; re-bless the city replay digests once.
2. Dock 9 as the default (if the owner says yes): a car leg Harbor Road -> Dock 9, or a closer `near` for the dock_9 row.
3. The yard silhouettes (CityOcclusion wedges on warehouse roofs when walkers hug a north wall): a docks-only yard gap.
4. Unused offers: the coaster ship (needs an east-west basin or a bow-north drawing), silos (a landmark rule), the plan
   twins of propeller / nav buoys (judge in the top view, not combo).
5. More unit pins for kerb_dresser (the cut list at :86, the plaza-facing share at :104, the road decal ranges) so mutate scores them, not only the golden list.
