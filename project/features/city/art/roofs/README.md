# features/city/art/roofs: D4 roofs

- `building_*.png`: the 10 district buildings (F-08, table ids 14-23), see `../README.md`.
- `roof_*.png` (night lane d4-production): 7 **generic block roofs**, 672 x 672 = 8.4 m at 80 px/m (the square
  building footprint), opaque, same inks and parapet coping as the district set: `roof_skylights`, `roof_garden`,
  `roof_sawtooth`, `roof_solar`, `roof_telecom`, `roof_tank`, `roof_charging` (robot charging depot).
  Masters `d4n_roofs_g1..g4` (1 roof of 8 rejected: laundry drawn in side view).
- **Not in the city yet:** the generator picks buildings from `ChunkBuild.FIRST_BUILDING..LAST_BUILDING` (14-23);
  using these needs new table rows (append, ids 65+) and a generator change, which moves the golden chunk hashes.
