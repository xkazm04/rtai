# tools/gen_constants

NAT-08: `sim_constants.json` is the one source for numbers the GDScript reference sim and the
native C++ sim share (capacities, grid sizes, kind/mode/flag/tile/cell codes, counter and
spawn-spec indices, the LCG). `node tools/gen_constants/gen.mjs` writes
`project/features/city/sim/sim_constants.gd` (`SimConst`) and `native/sim_core/src/sim_constants.h`
(`gtai::sim`), both `DO NOT EDIT` with the source hash; lint (`sim-constants`) fails on drift.
Float constants must be exact in binary (NAT-07).
