class_name CityWallMap
extends RefCounted
## A hand-made reference-sim map for police nav tests: chunk (2, 2) all sidewalk, a 3 m building
## wall at x 300..302 over the whole chunk, with or without an 8 m gap at y 320..327 (the same map
## as test_city_flow_field and native/sim_core/tests chase()).

const WALL_X: int = 300
const GAP_Y0: int = 320
const GAP_Y1: int = 328


static func walled(gap: bool) -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	paint(sim, gap)
	return sim


## The same map on any backend (the native one for a heat parity run).
static func paint(sim: CitySimBackend, gap: bool) -> void:
	sim.init(7)
	var n: int = SimConst.CHUNK_CELLS
	var tiles: PackedByteArray = CityChunk.zeros(CityChunk.TILES)
	tiles.fill(SimConst.T_PLAZA)
	var cells: PackedByteArray = CityChunk.zeros(CityChunk.CELLS)
	cells.fill(SimConst.C_WALK)
	for ly: int in n:
		var y: int = 2 * n + ly
		if gap and y >= GAP_Y0 and y < GAP_Y1:
			continue
		for x: int in range(WALL_X, WALL_X + 3):
			cells[ly * n + (x - 2 * n)] = SimConst.C_BUILD
	sim.stamp_chunk(2, 2, tiles, cells)


static func spawn_cop(sim: CitySimBackend, at: Vector2) -> int:
	return sim.spawn(PackedFloat64Array([SimConst.K_COP, at.x, at.y, 0.0, 1.0, 7, 0, 3.4, 0.0, 0]))


static func pos(sim: CitySimBackend, slot: int) -> Vector2:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return Vector2(snap[r + 4], snap[r + 5])
	return Vector2(-1, -1)
