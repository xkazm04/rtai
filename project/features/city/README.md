# features/city

The streamed city and its activity bubble (F-06). Depends only on `core/` and WorldContext (LAY-05).

- `gen/`: the deterministic generator (`CityGen`, `TilePainter`, `KerbDresser`, `ChunkBuild`) and
  the bake (`CityBake`, run by `res://dev/bake_city.gd`). Inputs: `data/tables/city_district.json`
  and `data/tables/city_textures.json`.
- `city_chunk.gd`, `chunk_codec.gd`: one chunk's data and the GTCH file format (AST-11).
- `sim/`: the bubble sim. `CitySimBackend` is the interface; `CitySimNative` wraps the
  GDExtension (`native/`); `CitySimRef` is the permanent GDScript reference (NAT-06), split into
  state, hash, people, solid, car route, cars, shots, clips and render. `SimConst` is generated.
- `stream/`: `ChunkSource` (worker reads, in-memory generation when unbaked) and
  `CityResidency` (which chunks the sim holds: a pure function of the focus, per tick).
- `city_spawner.gd`, `city_spawn_plan.gd`, `city_targets.gd`: spawn rules on one RNG stream.
- `city_system.gd`: the `WorldSystem` the composition root registers.
- `view/`: drawing only (`CityView`, `ChunkView` time-sliced, `CrowdLayers` MultiMesh,
  `CityTextures` placeholders until the art lane lands).
