# REPORT - night n18, lane districts (DRAFT, session 2; final at 07:40)

Branch `n18-districts` (worktree `C:\Users\kazda\kiro\gtai-wt\n18-districts`), cut from `int-n17` at `36dd26ba6`.
Evidence: `evidence/n18-districts/` (in the branch) and `C:\Users\kazda\kiro\gtai-masters\n18\districts\frames.json`.

## What works (with its evidence)

| Item | What | Evidence |
|---|---|---|
| 1 zones as data | layout consts -> `city_district.json` zone rows (`gtai.city-district/2`), zone map of chunk rects; step one byte-identical at v14 (`bake --check`), planted share change caught | commits 634b2f552, 6ca059905; `evidence/n18-districts/zone_map_v15.{png,json}` |
| 2 zone layouts + lint | docks east band (48 chunks, 18.75 %): long warehouse blocks over dropped streets, yard rows, quay + water; downtown centre (25 chunks): denser towers, plazas, crowds; mixed elsewhere. test_city_zone_lint: roads one network, sidewalks + zebras one network, every zone has road and sidewalk | e8ecb61c9 |
| 3 art | v16 warehouse/shed/tower roofs + water; dock + glass facades (+ brick dock and stone office alternates); v17 water bug fix; v18 quay edge autotile; v19 container yards; v20 downtown plazas (one fountain per plaza), cold store, sawtooth, square tall roofs | `evidence/n18-districts/ab_*` |
| 4 places | `data/tables/places.json` + CityPlaces.place(id) -> {zone, block, chunk, cell, door, facing}; test_city_places | ca6b1fcc2 |
| 5 Dock 9 | `--quest1-places`: Dock 9's own stage points sit before the dock_9 door; off by default; scenarios flag off 55/55 | b0314350c; `evidence/n18-districts/quest1_places_on_scenarios.txt` |
| 6 film | docks -> downtown drive, 32 px/m | (session 2, see masters) |

## What does not work
- `--quest1-places` ON: quest1_input fails "not paid: state active at beat b4-dock, tick 90000" (Dock 9 is ~1.6 km east
  of Harbor Road; the input bot never finishes the dock fight there). 8/9 quest scenarios pass with it on.

## Calls for the owner
- Dock 9 into the docks by default? (today: behind `--quest1-places`; the walk from Harbor Road is ~1.6 km)
- Docks on the east edge (vs another edge); downtown size (25 chunks) and landmark density (0.35).
- The 2x2 tower roofs' orange hazard stripes vs the colour law (the asset lane's `_ochre` twins are ready).
- Each zone's look, before/after stills: see masters frames.json.

## Merge notes
- Re-blessed: `project/data/generated/city_chunks.sha256` (GENERATOR_VERSION 14 -> 20). No replay or parity digest moved.
- Shared files touched: `project/boot/launch_args.gd` (one flag line `--quest1-places`; the `--perf-hud` comment moved
  onto its flag's line to keep 200 lines).

## Next steps
(see JOURNAL NEXT)
