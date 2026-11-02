# features/city/art/decals: D4 ground decals (night lane d4-production)

Flat marks on the charcoal street, seen straight down, 80 px/m, aspect kept and letterboxed (transparent) into the
city table footprint. Ink, wash and paper only (no vermilion, no teal). Import lossless, mipmaps on.
Master: `art_src/d4.manifest.json#d4n_decals`.

| File | Table id | Notes |
|---|---|---|
| `cracks`, `manhole`, `oil_stain`, `drain_grate`, `puddle`, `oil_slick`, `stop_line`, `road_arrow`, `skid_marks`, `glass_shards`, `tank_tracks` | 54-64 | baked by the generator; `road_arrow` points to **+x** (rot 0 = along the lane); `tank_tracks` is the tread IMPRINT (ink grooves), not the tread |
| `blood_s` (0.8 m), `blood_m` (1.6 m), `blood_l` (3 m) | (dynamic) | ink blood splats, black ink (never red), 64 / 128 / 240 px square |
| `scorch`, `scorch_b` | (dynamic) | blast scorch marks, 3 m (240 px square) |
| `bullet_holes_s` (1.2 m), `bullet_holes_m` (1.6 m) | (dynamic) | gunfire impact clusters (3 / 5 holes), ink dots with cream rims; master `#d4n_dmg` |
| `gouge` (1.6 m), `oil_splash` (1.2 m) | (dynamic) | four ink gouges (crash / blade), an ink oil splash with drops; master `#d4n_dmg` |

The dynamic decals are not in the table (adding rows would not move the golden chunk hashes, but they are spawned
by gameplay, not baked): a decal system should draw them at their metre size. In-engine board of every decal:
`res://dev/showcase/asset_board.gd -- --page=decals` (evidence `masters:night/d4-production/after_dd/`).
