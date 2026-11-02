# features/city/art/vehicles: D4 vehicles (night lane d4-production)

Every vehicle seen straight down, **nose to +x** (bonnet at the right end), at 80 px/m, on the city table
footprint (`data/tables/city_textures.json` `size_m`, never changed: it is the collision size). The drawing keeps
its aspect: one scale per vehicle for all its states, letterboxed (transparent) into the footprint.
Import: lossless, mipmaps on (AST-01/03). Masters + prompts: `art_src/d4.manifest.json#d4n_veh_a|b|c`.

| File | Table id | What |
|---|---|---|
| `sedan`, `sedan_b`, `sedan_c`, `taxi`, `police_cruiser`, `van`, `pickup`, `ambulance`, `bus` | 44-49, 51-53 | intact |
| `car_wreck` | 50 | the burnt sedan wreck |
| `<vehicle>_d1`, `<vehicle>_d2` | (not in the table yet) | damage states: d1 = crumpled front corner + cracked glass, d2 = bonnet buckled, glass shattered |
| `van_wreck`, `cruiser_wreck`, `pickup_wreck` | (not in the table yet) | burnt wrecks of those bodies |
| `hijack_<vehicle>` | (overlay) | the Gearbox hijacked state: a teal plate (dashed rim + glass), drawn **on top of** the same-name vehicle at the same transform. Civilian bodies only (sedans, taxi, van, pickup). |
| `traffic_atlas.png` | (moving traffic) | 1024 x 1024, 2 x 4 cells of 512 x 256 = **6.4 x 3.2 m** (the `sim_render` `CAR_L x CAR_W` quad), car centred: cell `i` at `(i % 2, i / 2)`, order `sedan, sedan_b, sedan_c, taxi, police_cruiser, van, pickup, ambulance` |
| `traffic_atlas_hijack.png` | (moving traffic) | the same cells with the teal hijack plate composited (cruiser and ambulance stay plain) |

- **Colour doctrine:** ink, wash and paper only. Vermilion only on the police light bar (tail lights neutralised).
  Teal only in the hijack overlays (the soul's colour). Damage is ink, never red.
- **Not wired yet** (rendering code, the visual-engine lane): the traffic MultiMesh still draws the steel placeholder
  quad of `crowd_layers.gd` `_body()`; the atlas above is laid out for it (`variant -> cell`). Damage states and
  hijack overlays need a state hook in the car draw.
