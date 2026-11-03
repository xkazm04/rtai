# features/city/art/roofs: D4 roofs

- `building_*.png`: the 10 district buildings (F-08, table ids 14-23), see `../README.md`.
- `roof_*.png` (night lane d4-production): 7 **generic block roofs**, 672 x 672 = 8.4 m at 80 px/m (the square
  building footprint), opaque, same inks and parapet coping as the district set: `roof_skylights`, `roof_garden`,
  `roof_sawtooth`, `roof_solar`, `roof_telecom`, `roof_tank`, `roof_charging` (robot charging depot).
  Masters `d4n_roofs_g1..g4` (1 roof of 8 rejected: laundry drawn in side view).
- **Table rows 65-71** (night iteration 8): `roof_skylights`, `roof_garden`, `roof_sawtooth`, `roof_solar`,
  `roof_telecom`, `roof_tank`, `roof_charging`, class `building`, 8.4 x 8.4 m. The generator does not pick them yet: a
  ready patch is in the lane masters, `night/d4-production/roof_pick_generic.patch` (`tile_painter.gd` +
  `chunk_build.gd` + the new golden `city_chunks.sha256`): the 8 district buildings become landmarks on 30 % of the
  square blocks, the rest take a generic roof; a pick that repeats its left or upper neighbour steps to the next generic
  roof; **lettered roofs (bar, HQ, OSHA, pension, union hall) stay upright** (random 90-degree turns printed "HQ" upside
  down and sideways). Evidence `before_rf|after_rf/city-*`, sheets `work/rf_ab_{32,48}.png`.
