# JOURNAL - night lane d4-production (branch n-d4)

## 2026-11-02 21:09 iteration 1, BUILD
- Read: AGENTS, manifest, shaders README, city_textures.json. State: vehicles 44-53, decals 54-64 and the
  kerb corner (10) are `art: null` (flat placeholder). Moving traffic uses the procedural `_body()` steel
  quad in `features/city/view/crowd_layers.gd` (rendering code, not my scope): parked vehicles take the
  table art; traffic needs a visual-engine change (request below once the atlas exists).
- Session stops 22:39 at the latest: plan = vehicles sheet (Codex) -> slice -> table -> before/after selftest.

## 21:30 MILESTONE vehicles (work order 1)
- 3 Codex sheets (d4n_veh_a/b/c), 31 cells, **0 rejected** (all straight down, nose +x). Build:
  `masters:night/d4-production/tools/build_vehicles.py` (key, fill enclosed key holes, one scale per vehicle across
  its damage states, letterbox to the table footprint, re-ink, vermilion only on the cruiser light bar,
  wrecks burnt darker), `build_traffic.py` (atlas), procedural teal hijack overlays.
- Wired ids 44-53 in `city_textures.json` (ids/footprints unchanged). Placeholders 22 -> 12.
- Evidence: `gtai-masters/night/d4-production/before_v|after_v/table-{32,48,64}ppm.png`, `extras-*` (damage
  states, wrecks), `selftest-*` (unchanged: the junction shows only moving traffic).
- Dev evidence rig added: `project/dev/showcase/asset_board.gd` (+ `_run`), `--page=table|extras`.
- **REQUEST visual-engine:** moving traffic still draws `crowd_layers.gd _body()` (steel quad). Wire
  `features/city/art/vehicles/traffic_atlas.png` (2x4 cells of 6.4x3.2 m, order in that README) as the RL_CARS
  texture with `variant -> cell` UVs; `traffic_atlas_hijack.png` for the hijacked state; damage states need a
  state hook. Car shadows can keep the blob or use the atlas alpha.

## 21:45 MILESTONE decals, kerb corner, FX atlas (work order 2 part, 3)
- Decals: 1 Codex sheet (d4n_decals), 16 cells, 0 rejected. 11 table decals (54-64) wired; dynamic: blood_s/m/l,
  scorch, scorch_b (not in the table, README in `features/city/art/decals/`). Puddle interior = translucent ink.
- Kerb corner (id 10): code only (`build_corner.py`: the curb() bands of build_ground along a rounded distance
  field). **City table placeholders now 0** (was 22). Evidence: `after_d/corner-{32,48,64}ppm.png` (joins both
  straights seamlessly), `after_d/table-*`.
- FX: 1 Codex sheet (d4n_fx), 32 cells, **1 rejected** (the casing: a cylinder with a side face). Atlas
  `features/fx/art/fx_atlas.png` 8x4 x 256 px, layout in that README. Ink splat burst got a cream sticker rim
  (ink on charcoal disappears otherwise).
- Running count: 5 Codex images, 1 cell rejected of 79.
- **REQUEST visual-engine / FX owner:** no FX system draws `fx_atlas.png` yet; no decal system spawns blood/scorch.

## 21:50 MILESTONE cream-coat ped (work order 4, part 1)
- Finding: at 32/48 px/m print_part's mid band is only d 0.36..0.40 (else cream / ink); the coat-hat look printed as
  one cream blob because the hat BRIM (not the coat) covers the figure. Re-toned the cream fill of `ped/torso.png`
  and `ped/head_hat.png` to a flat warm grey at d = 0.39 (`coat_value.py`); parts layout, pivots, alpha unchanged.
  Probes: d 0.38 (too subtle), d 0.60 (prints solid ink = same as the jacket, rejected for variety), 0.39 kept.
- Evidence: `before_c|after_c2/rig-{32,48}ppm*.png`, crowd atlas rows 0/2/3 (`work/peek_atlas3.png`).
- Affects looks 0 coat-hat, 2 coat-hood, 3 jacket-hat (hat brim), 7 coat-hair. Cops unchanged.
