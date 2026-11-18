# REPORT - night n18, lane districts (DRAFT, session 4; final at 07:40)

Branch `n18-districts` (worktree `C:\Users\kazda\kiro\gtai-wt\n18-districts`), cut from `int-n17` at `36dd26ba6`.
Evidence: `evidence/n18-districts/` (in the branch) and `C:\Users\kazda\kiro\gtai-masters\n18\districts\frames.json`.

## What works (with its evidence)

| Item | What | Evidence |
|---|---|---|
| 1 zones as data | layout consts -> `city_district.json` zone rows (`gtai.city-district/2`), zone map of chunk rects; step one byte-identical at v14 (`bake --check`), planted share change caught | commits 634b2f552, 6ca059905; `evidence/n18-districts/zone_map_v15.{png,json}` |
| 2 zone layouts + lint | docks east band (48 chunks, 18.75 %): long warehouse blocks over dropped streets, yard rows, quay + water; downtown centre (25 chunks): denser towers, plazas, crowds; mixed elsewhere. test_city_zone_lint: roads one network, sidewalks + zebras one network, every zone has road and sidewalk | e8ecb61c9 |
| 3 art | v16 warehouse/shed/tower roofs + water; dock + glass facades (+ brick dock and stone office alternates); v17 water bug fix; v18 quay edge autotile; v19 container yards; v20 downtown plazas (one fountain per plaza), cold store, sawtooth, square tall roofs; v21 one lettered name a block; v22 it471 roofs (clocktower, terrace, billboard tall roof, bank dome + crown 2x2, shed b, warehouse c kept upright by `upright_roofs`), sculpture v3; v23 zone grounds (downtown plaza granite bond `plaza_ground`, docks apron v3t `apron_ground`); v24 plaza singles (one coffee kiosk + one food cart a downtown plaza, `plaza_singles`); v25 docks yard ground (`yard_ground`, REQUEST 11); v26 docks dressing (`DockDresser`: tarps + fuel tanks on the quay apron, a lifebuoy by each basin's coping); v27 downtown's own street furniture (`kerb_props` + `wall_props`: street clocks, bollards, litter bins, planters; no dumpsters downtown); v28 Dock 9's harbour office roof on the dock_9 block (`office_roof`); v29 the asset lane's ochre twins (rope net, oil drums on the apron; news boxes downtown) and a bow-north tug moored in half the basins (`basin_boat`) | `evidence/n18-districts/ab_*` (v22: `ab_it471_roofs_*_v21_v22_combo.jpg`; v23: `ab_it471_ground_*_v22_v23_combo.jpg`; v24: `ab_it471_plaza_singles_*_v23_v24_combo.jpg`; v25: `ab_it472_yard_ground_v24_v25_combo_{32,48}ppm.jpg`; v26: `ab_it473_apron_dressing_v25_v26_combo_{32,48}ppm.jpg`; v27: `ab_it472_downtown_{kerbs,kerbbs}_v26_v27_combo_{32,48}ppm.jpg`; v28: `ab_it471_dock9_office_v27_v28_combo_{32,48}ppm.jpg`; v29: `ab_it474_basin_tug_ochre_v28_v29_combo_32ppm.jpg`) |
| 4 places | `data/tables/places.json` + CityPlaces.place(id) -> {zone, block, chunk, cell, door, facing}; test_city_places | ca6b1fcc2 |
| 5 Dock 9 | v28: Dock 9 has a landmark in the city, the harbour office at the quay end of its block (test_dock_office pins it to places.json's dock_9 rule). `--quest1-places`: Dock 9's own stage points sit before the dock_9 door; off by default; scenarios flag off 55/55. Flag ON: quest1_input pays (921 s, 0 deaths, replay identical) after the bot fix (BotRoute A* walk + `StageLayout.w_dock`) | b0314350c, 0511d8629; `evidence/n18-districts/quest1_places_on_scenarios_v2.txt` |
| 6 film | docks -> downtown drive, 37 s at 32 px/m, along the north sidewalk (pass 2, v22); one 48 px/m still per zone | `evidence/n18-districts/drive2_docks_downtown_v22_combo_32ppm.mp4`, `zones_v22_combo_48ppm.jpg`; masters frames.json (15) |

Generator numbers (v21, `evidence/n18-districts/zone_map_v21.{png,json}`): docks 48 chunks (18.75 %), 3832 block
tiles + 2408 plaza/yard/quay tiles; downtown 25 chunks (9.77 %), 2000 block + 500 plaza tiles; mixed 183 chunks
(71.48 %), 16125 block + 2175 plaza tiles. Generating all 256 chunks: 5.0 s in the zone-map run; a full bake 6.1 s
wall (CONTENDED: not under the bench lock).
Gates: evidence gate PASS on 8894e90aa (v29): unit 2892/0, scenarios 55/55, parity bit-exact, look goldens 11/11 (reels not yet
run on v29). Full gate (`tools/gate/run.mjs --reels`, snapshot) PASS on dee06ed7b (v28): lint 19/19, unit 2891/0, scenarios 55/55,
parity bit-exact, look goldens 11/11, release-compile 727/0, reels exit 0. PASS on b32980b92 (v27): lint 19/19, unit 2889/0, scenarios 55/55,
parity bit-exact (planted caught at 629), look goldens 11/11 (worst 0.31), release-compile 727/0, reels exit 0. Earlier: PASS on 70ca0c1e7 (v23): lint 19/19, unit 2879/0, scenarios 55/55,
parity bit-exact (planted caught at 629), look goldens 11/11, release-compile 726/0, reels exit 0. Evidence gate PASS on
93f37b1d7 (v24): unit 2882/0, scenarios 55/55, parity bit-exact, look goldens 11/11 (reels not yet re-run on v24).
Mutate `dev/bots/bot_route.gd`: 7/8 killed (87.5 %), the survivor near-equivalent. Mutate dock_painter.gd: 4/12 killed (33.3 %); the
survivors are look-only, pinned by the golden hash list; the one real gap (:126) got a test (bc29c8a7e).

## What does not work
- `--quest1-places` ON: quest1_input FAILED in session 2 ("not paid ... b4-dock, tick 90000"). Cause: the dev bot held the fight
  at the street mapping and walked straight into buildings. Fixed in 0511d8629 (dev bot only): it now pays. What the flag still
  costs a player: the walk Harbor Road -> Dock 9 takes 348 s on foot and the walk back 343 s (quest 921 s vs 317 s).
- Docks yards put walkers right against a warehouse's north wall, so the rigs' "behind a roof" ink silhouettes
  (CityOcclusion, n8 design) show often there as black wedges on the roof edge (`zones_v22_combo_48ppm.jpg`, yard panel).
  Not changed.

## Calls for the owner
- The harbour office stands at the quay end of Dock 9's block, ~30 m east of the door (the door is the block middle). Move the
  door to the office (a frontage rule `door_at: office`), or keep the door mid-block? Recommendation: move it next session, so
  the landmark and the quest marker coincide (`ab_it471_dock9_office_v27_v28_combo_32ppm.jpg`).
- Hazard stripes (orange/black) on the tug and the rope net, like the 2x2 tower roofs: danger marking (allowed vermilion) or
  off-law? Tonight both ship as the asset lane's `_ochre` twins (v29); the original striped files are not used.
- Dock 9 into the docks by default? (today: behind `--quest1-places`). Recommendation: not yet. It plays (quest1_input pays with
  the flag on), but the walk Harbor Road -> Dock 9 is 348 s each way on foot, and the quest has no car leg yet.
- Docks on the east edge (vs another edge); downtown size (25 chunks) and landmark density (0.35).
- The 2x2 tower roofs' orange hazard stripes vs the colour law (the asset lane's `_ochre` twins are ready).
- Each zone's look, before/after stills: see masters frames.json; one still per zone at 48 px/m: `evidence/n18-districts/zones_v22_combo_48ppm.jpg`.
- Downtown's granite plaza ground (v23) is darker and busier than the mixed zone's slabs: it separates the zones, the walkers
  still read on it; keep, or ask the asset lane for a lighter granite? (`ab_it471_ground_plaza-32ppm_v22_v23_combo.jpg`)
- Art not taken and why (session 4): oil drums v2 (rust-red drums: red is blood only), rope net (vermilion hazard stripes on
  the hook block), news boxes v2 (its sheet has fewer than five facings in the top row, the cutter cannot cut it).
- Art not taken yet and why: the coaster ship (drawn east-west, the docks basins run north-south), the silos (needs a
  landmark placement rule), `warehouse_70_c_v2` (no grade yet), the street/dock cards (next: plaza/yard/apron dressing).

## Merge notes
- Re-blessed: `project/data/generated/city_chunks.sha256` (GENERATOR_VERSION 14 -> 29; last full gate on v28). No replay or parity digest moved.
- `tools/debt/baseline.json`: dev_loc 21992 -> 22089 accepted (dev/bots BotRoute; reason stored).
- Shared files touched: `project/boot/launch_args.gd` (one flag line `--quest1-places`; the `--perf-hud` comment moved
  onto its flag's line to keep 200 lines).

## Next steps
(see JOURNAL NEXT)
