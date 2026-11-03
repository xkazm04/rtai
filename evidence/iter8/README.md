# n-d4 iteration 8 evidence (night lane d4-production)

- `night_iter8_summary.png`: before | after, same deterministic scenes (seed 91), through look_d4, real CityView +
  native sim. Row 3's after frame has the roof patch only (the grey box there is the unwired traffic); row 4 is the
  merged tree (n-visual + n-d4 + both patches).
- `traffic_atlas_wiring.patch`: moving traffic draws `features/city/art/vehicles/traffic_atlas.png` (cell = sim car art
  id) - for main / n-d4 without n-visual (crowd_layers + city_view + `traffic_atlas.gdshader`).
- `traffic_atlas_wiring_after_n-visual.patch`: the same after n-visual is merged (crowd_layers + shader only).
- `generator_art_pick.patch`: the generator picks the generic roofs (table rows 65-71) for 70 % of square blocks,
  landmarks for 30 %, no neighbour repeats, lettered roofs and the warehouse (its painted 7) upright; plaza paving gets a quarter turn per tile (breaks
  the 8 m repeat of its cracks and stains; `work/pl_crop.png`); includes the new AST-12 golden hash list. Applies on
  main and on n-visual + n-d4 (the roof-only version's golden matched `bake_city --check` there).
- `gates-eceb6b3.txt`, `gates-42ee60f.txt`, `gates-9be0221.txt` (final): `node tools/evidence/run.mjs --no-bench`, all PASS; `bench-38136e8.txt`: bench PASS.
- Full frame sets: `gtai-masters/night/d4-production/{before,after}_tr`, `after_tr_dense`, `probe_tr78`,
  `{before,after}_rf`, `merged_tr`, `merged_all`; ladder rows "i8 ...".
