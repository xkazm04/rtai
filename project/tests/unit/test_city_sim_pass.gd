extends GutTest
## CitySimCarPass on the GDScript reference sim (the native twin is held to it by tests/parity): a
## traffic car standing behind a service car's obstacle point pulls out into the oncoming lane,
## gets past and returns to its own lane; it stays put while the oncoming lane is blocked.

const ROAD_Y: float = 64.0 * 4 + 12.0
const CAM: Vector2 = Vector2(64.0 * 4 + 40.0, 64.0 * 4 + 12.0)
const LANE: float = ROAD_Y + 2.0
const START: Vector2 = Vector2(CAM.x - 20.0, LANE)
const OBST_X: float = CAM.x - 6.0
## Where the returned car is checked: the pass ends 7 m past, the lane change takes a few more.
const PAST_M: float = 24.0

var _gen: CityGen


func before_all() -> void:
	_gen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)


func test_a_car_passes_a_parked_obstacle_and_returns_to_its_lane() -> void:
	var sim: CitySimRef = _world(PackedFloat64Array([OBST_X, LANE]))
	var min_y: float = LANE
	var t_out: int = -1
	var y_past: float = INF
	for i: int in 900:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
		var snap: PackedFloat64Array = sim.snapshot()
		if snap[5] < LANE - 1.0 and t_out < 0:
			t_out = i
		min_y = minf(min_y, snap[5])
		if snap[4] > OBST_X + PAST_M and y_past == INF:
			y_past = snap[5]
	assert_gt(t_out, int(CitySimCarPass.PASS_WAIT_S * SimClock.TICK_RATE), "waited first")
	assert_lt(min_y, LANE - 3.0, "pulled out into the oncoming lane")
	assert_almost_eq(y_past, LANE, 0.6, "%d m past it: back in its own lane" % int(PAST_M))


func test_a_blocked_oncoming_lane_keeps_it_waiting() -> void:
	var sim: CitySimRef = _world(PackedFloat64Array([OBST_X, LANE, OBST_X + 4.0, LANE - 4.0]))
	for i: int in 600:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	var snap: PackedFloat64Array = sim.snapshot()
	assert_lt(snap[4], OBST_X - 4.0, "still behind the obstacle")
	assert_almost_eq(snap[5], LANE, 0.5, "never pulled out")


func _world(obstacles: PackedFloat64Array) -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	sim.init(7)
	sim.set_radii(80.0, 160.0, 14.0)
	for cy: int in range(1, 4):
		for cx: int in range(1, 4):
			var c: CityChunk = _gen.gen_chunk(cx, cy)
			sim.stamp_chunk(cx, cy, c.tiles, c.cells)
	sim.set_obstacles(obstacles)
	var spec: Array = [SimConst.K_CAR, START.x, START.y, 1.0, 0.0, 0, 0, 12.0, LANE, 0]
	assert_gte(sim.spawn(PackedFloat64Array(spec)), 0)
	return sim
