extends GutTest
## The police flow field (WLD-09) in the GDScript reference (the native core has the same tests in
## native/sim_core/tests and is held to this by the parity gate): routes around a wall, handles
## unreachable targets, is deterministic.

const WALL_X: int = 300
const GAP_Y0: int = 320
const GAP_Y1: int = 328
const COP: Vector2 = Vector2(290.5, 290.5)
const GOAL: Vector2 = Vector2(315.5, 290.5)
const CAM: Vector2 = Vector2(305.0, 300.0)


func test_a_cop_routes_through_the_gap() -> void:
	var sim: CitySimRef = _walled(true)
	var cop: int = _spawn_cop(sim, COP)
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	assert_gt(sim.flow_dist(COP.x, COP.y), 40, "the route around the wall is a detour")
	assert_lt(COP.distance_to(GOAL), 26.0, "the straight line is short but blocked")
	for t: int in 3000:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	assert_lt(_pos(sim, cop).distance_to(GOAL), 9.0, "the cop got through the gap")
	assert_gte(sim.flow_stats()[SimConst.FS_COMPUTES], 1)


func test_an_unreachable_target_falls_back_to_straight_line() -> void:
	var sim: CitySimRef = _walled(false)
	var cop: int = _spawn_cop(sim, COP)
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	assert_eq(sim.flow_dist(COP.x, COP.y), -1, "no route: the wall has no gap")
	for t: int in 120:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	var p: Vector2 = _pos(sim, cop)
	assert_gt(p.x, COP.x + 2.0, "it still heads for the target")
	assert_lt(p.x, float(WALL_X), "and the wall stops it")


func test_the_field_is_deterministic() -> void:
	var a: CitySimRef = _walled(true)
	var b: CitySimRef = _walled(true)
	for sim: CitySimRef in [a, b]:
		for k: int in 6:
			assert_gte(_spawn_cop(sim, COP + Vector2(0, k * 2.0)), 0)
		for t: int in 240:
			sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	assert_eq(a.snapshot(), b.snapshot())
	assert_eq(a.flow_dist(COP.x, COP.y), b.flow_dist(COP.x, COP.y))


func test_no_police_no_field() -> void:
	var sim: CitySimRef = _walled(true)
	for t: int in 60:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, GOAL.x, GOAL.y)
	assert_eq(sim.flow_stats()[SimConst.FS_COMPUTES], 0)
	assert_eq(sim.flow_dist(COP.x, COP.y), -1)


## Chunk (2, 2) all sidewalk, a 3 m wall at x 300..302, with or without the gap at y 320..327.
static func _walled(gap: bool) -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
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
	return sim


static func _spawn_cop(sim: CitySimRef, at: Vector2) -> int:
	return sim.spawn(PackedFloat64Array([SimConst.K_COP, at.x, at.y, 0.0, 1.0, 7, 0, 3.4, 0.0, 0]))


static func _pos(sim: CitySimRef, slot: int) -> Vector2:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return Vector2(snap[r + 4], snap[r + 5])
	return Vector2(-1, -1)
