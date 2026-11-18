extends GutTest
## n18 police item 4: CityDispatch sends heat.json city.cars[level] police cars per episode,
## car_delay_s after the level rises, on a road tile of the ring round the last-seen point, in the
## lane heading toward it, dispatched (F_ENGAGED); heat 0 ends the episode. Map: CityRoadMap.

const POINT: Vector2 = Vector2(340.5, 317.5)
const CAM: Vector2 = Vector2(320.0, 320.0)


func test_heat_2_sends_its_cars_after_the_delay_on_the_road_toward_the_point() -> void:
	var sim: CitySimRef = CitySimRef.new()
	CityRoadMap.paint(sim)
	var d: CityDispatch = _dispatcher()
	for t: int in d.delay_ticks:
		assert_eq(d.step(sim, t, 2, POINT, CAM), 0, "nothing before car_delay_s (tick %d)" % t)
	var t2: int = d.delay_ticks
	while d.sent < 2 and t2 < d.delay_ticks + 600:
		@warning_ignore("return_value_discarded")
		d.step(sim, t2, 2, POINT, CAM)
		t2 += 1
	gut.p("heat 2: %d cars sent by tick %d" % [d.sent, t2])
	assert_eq(d.sent, 2, "city.cars[2]")
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, CAM.x, CAM.y)
	assert_eq(sim.get_counters()[SimConst.CN_PCARS], 2)
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		var p: Vector2 = Vector2(snap[r + 4], snap[r + 5])
		assert_eq(sim.tile_at(p.x, p.y), SimConst.T_ROAD_H, "on the road")
		assert_gt(snap[r + 6] * (POINT.x - p.x), 0.0, "heading toward the point")
	for t: int in 300:
		assert_eq(d.step(sim, t2 + t, 2, POINT, CAM), 0, "the episode's cars are all out")


func test_heat_3_tops_up_and_heat_0_ends_the_episode() -> void:
	var sim: CitySimRef = CitySimRef.new()
	CityRoadMap.paint(sim)
	var d: CityDispatch = _dispatcher()
	d.sent = 2
	var t: int = 0
	while d.sent < 3 and t < 900:
		@warning_ignore("return_value_discarded")
		d.step(sim, t, 3, POINT, CAM)
		t += 1
	assert_eq(d.sent, 3, "heat 3 tops the episode up to city.cars[3]")
	@warning_ignore("return_value_discarded")
	d.step(sim, t, 0, POINT, CAM)
	assert_eq(d.sent, 0, "heat 0 ends the episode")


func _dispatcher() -> CityDispatch:
	var d: CityDispatch = CityDispatch.new(RngRegistry.new(3).stream(CityDispatch.STREAM))
	var tune: CityHeatTune = CityHeatTune.load_table()
	d.cars = tune.cars
	d.delay_ticks = tune.car_delay_ticks
	d.ring_m = tune.car_ring_m
	return d
