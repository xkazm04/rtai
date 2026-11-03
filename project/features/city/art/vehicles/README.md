# features/city/art/vehicles: D4 vehicles (night lane d4-production)

Every vehicle seen straight down, **nose to +x** (bonnet at the right end), at 80 px/m, on the city table
footprint (`data/tables/city_textures.json` `size_m`, never changed: it is the collision size). The drawing keeps
its aspect: one scale per vehicle for all its states, letterboxed (transparent) into the footprint.
Import: lossless, mipmaps on (AST-01/03). Masters + prompts: `art_src/d4.manifest.json#d4n_veh_a|b|c`.

| File | Table id | What |
|---|---|---|
| `sedan`, `sedan_b`, `sedan_c`, `taxi`, `police_cruiser`, `van`, `pickup`, `ambulance`, `bus` | 44-49, 51-53 | intact |
| `car_wreck` | 50 | the burnt sedan wreck |
| `<vehicle>_d1`, `<vehicle>_d2` | (not in the table yet) | damage states: d1 = crumpled front corner + cracked glass, d2 = bonnet buckled, glass shattered; plus bold ink marks (iteration 2, master `d4n_dmg`) so they read at 32-48 px/m: d1 star crack on the windscreen + 3 bullet holes, d2 shattered crack + 5 holes + a scorched nose |
| `van_wreck`, `cruiser_wreck`, `pickup_wreck` | (not in the table yet) | burnt wrecks of those bodies |
| `hijack_<vehicle>` | (overlay) | the Gearbox hijacked state: a teal plate (dashed rim + glass), drawn **on top of** the same-name vehicle at the same transform. Civilian bodies only (sedans, taxi, van, pickup). |
| `traffic_atlas.png` | (moving traffic) | 1536 x 768, 3 x 3 cells of 512 x 256 = **6.4 x 3.2 m** (the `sim_render` `CAR_L x CAR_W` quad) at 80 px/m, car centred, nose to +x. **Cell = the sim car art id** (`city_spawner` `CAR_ART` 0-7, `ART_POLICE_CAR` 8), cell `i` at `(i % 3, i / 3)`: 0 `sedan`, 1 `sedan_b`, 2 `sedan_c`, 3 `taxi`, 4 `van`, 5 `pickup`, 6 `ambulance`, 7 `sedan_grey` (the sedan in a mid-wash paint with a cream sticker rim: value variety in traffic, atlas only), 8 `police_cruiser` |
| `traffic_atlas_hijack.png` | (moving traffic) | the same cells with the teal hijack plate composited (cruiser and ambulance stay plain) |
| `traffic_atlas_d1.png`, `traffic_atlas_d2.png` | (moving traffic) | the damage states in the same 3 x 3 layout (cell = art id; id 7 = the sedan damage sprite in the grey paint), registered to the intact cells (max diff 0), so a damage hook only swaps the texture per car |

- **Colour doctrine:** ink, wash and paper only. Vermilion only on the police light bar (tail lights neutralised).
  Teal only in the hijack overlays (the soul's colour). Damage is ink, never red.
- **Wiring** (rendering code, the visual-engine lane; not in this branch): the traffic MultiMesh still draws the steel
  placeholder quad of `crowd_layers.gd` `_body()`. A ready patch is in the lane masters,
  `night/d4-production/traffic_atlas_wiring.patch` (main / n-d4: `crowd_layers.gd` + `city_view.gd` + a 15-line
  cell shader, the same cell maths as `crowd_atlas.gdshader`) and `traffic_atlas_wiring_after_n-visual.patch` (after
  n-visual: `crowd_layers.gd` + the shader only, `set_look_enabled` already keeps a non-item material). The cars keep
  their atlas material, as the baked crowd does, so they skip the item pass. Before/after: `before_tr|after_tr`,
  dense traffic `after_tr_dense`, ids 7 + 8 forced `probe_tr78`, merged n-visual + n-d4 `merged_tr`. Damage states and
  hijack overlays still need a state hook in the car draw.
- **Wear (night iteration 4, D5 push up close):** the 9 intact cars, their 18 damage states (same seed per car, so the dirt registers across states) and both traffic atlases carry an ink-only grime
  pass (edge-weighted stipple in dirt patches + 3 thin scratches on the light paint; `veh_grime.py` in the lane
  masters). Invisible at 32 px/m, light wear at 48, reads as lived-in at 64. A re-run of `build_vehicles.py` drops
  it (re-apply `glass_ink.py` then `veh_grime.py`, then `build_traffic.py`).
