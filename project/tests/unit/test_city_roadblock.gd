extends GutTest
## n18 police item 5 (heat 3 roadblock): CityRoadblock parks cruisers across the road past the
## first junction ahead of Rivet's heading; the sim keeps them at 0 m/s (F_PARKED) and traffic
## brakes behind them. Map: CityRoadMap.paint_cross (an east-west road on y 320..327 crossing a
## north-south road on x 288..295; the junction tile x 288..295, y 320..327).

const CAM: Vector2 = Vector2(320.0, 320.0)
const POINT: Vector2 = Vector2(262.5, 324.0)
const TUNE: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4, 2.0, 12.0, 4.0, 4.0, 6.0, 8.0]


func test_find_puts_the_block_past_the_junction_ahead() -> void:
	var sim: CitySimRef = _map()
	var spot: Vector3 = CityRoadblock.find(sim, Vector2(260.0, 322.0), 0, Vector2(10.0, 90.0), 6.0)
	assert_eq(int(spot.z), 0, "a block heading east")
	assert_almost_eq(spot.x, 302.0, 0.01, "6 m past the junction's east edge (x 296)")
	assert_almost_eq(spot.y, 324.0, 0.01, "on the road's centre line")
	var none: Vector3 = CityRoadblock.find(sim, Vector2(300.0, 322.0), 0, Vector2(10.0, 60.0), 6.0)
	assert_lt(none.z, 0.0, "no junction ahead: nothing")


func test_heat_3_parks_two_cruisers_across_the_road_ahead_of_rivet() -> void:
	var sim: CitySimRef = _map()
	var rb: CityRoadblock = _roadblock()
	sim.set_heat(3, POINT.x, POINT.y)
	var rivet: Vector2 = Vector2(250.0, 322.0)
	var t: int = 0
	while t < 200 and rb.placed == 0:
		rivet.x += 0.1  # Rivet runs east, 6 m/s
		@warning_ignore("return_value_discarded")
		rb.step(sim, t, 3, rivet)
		_step(sim, rivet)
		t += 1
	gut.p("heat 3: %d cruisers parked at %s, tick %d" % [rb.placed, rb.at, t])
	assert_eq(rb.placed, 2, "two cruisers")
	assert_eq(CityRoadMap.count(sim, SimConst.K_PCAR), 2)
	var parked: Array[Vector2] = _cars(sim)
	for t2: int in 600:
		_step(sim, rivet)
	var later: Array[Vector2] = _cars(sim)
	for k: int in parked.size():
		assert_almost_eq(later[k].distance_to(parked[k]), 0.0, 0.01, "the cruisers stay parked")
		assert_almost_eq(parked[k].x, 302.0, 0.01, "across the road past the junction")
	assert_almost_eq(absf(parked[0].y - parked[1].y), 4.0, 0.01, "one per lane (8 m / 2)")


func test_traffic_brakes_behind_the_roadblock() -> void:
	var sim: CitySimRef = _map()
	sim.set_heat(3, POINT.x, POINT.y)
	var rb: CityRoadblock = _roadblock()
	rb.delay_ticks = 0
	@warning_ignore("return_value_discarded")
	rb.step(sim, 0, 3, Vector2(250.0, 322.0))
	@warning_ignore("return_value_discarded")
	rb.step(sim, 1, 3, Vector2(254.0, 322.0))
	assert_eq(rb.placed, 2)
	var spec: Array = [SimConst.K_CAR, 320.0, CityRoadMap.LANE_W, -1.0, 0.0, 0, 0, 12.0]
	var car: int = sim.spawn(PackedFloat64Array(spec + [CityRoadMap.LANE_W, 2]))
	for t: int in 600:
		_step(sim, CAM)
	var x: float = CityWallMap.pos(sim, car).x
	gut.p("a westbound car behind the block stopped at x %.2f (block at x 302)" % x)
	assert_gt(x, 303.0, "it stopped short of the block")
	assert_lt(x, 312.0, "it drove up to the block")


func test_no_roadblock_below_heat_3() -> void:
	var sim: CitySimRef = _map()
	var rb: CityRoadblock = _roadblock()
	rb.delay_ticks = 0
	for t: int in 120:
		@warning_ignore("return_value_discarded")
		rb.step(sim, t, 2, Vector2(250.0 + 0.1 * t, 322.0))
	assert_eq(rb.placed, 0)
	assert_eq(CityRoadMap.count(sim, SimConst.K_PCAR), 0)


func _map() -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	CityRoadMap.paint_cross(sim)
	sim.set_police(TUNE)
	return sim


func _roadblock() -> CityRoadblock:
	var rb: CityRoadblock = CityRoadblock.new()
	rb.cars = PackedInt32Array([0, 0, 0, 2])
	rb.delay_ticks = 60
	rb.ahead_m = Vector2(10.0, 90.0)
	rb.past_m = 6.0
	return rb


func _step(sim: CitySimBackend, at: Vector2) -> void:
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, at.x, at.y)


func _cars(sim: CitySimBackend) -> Array[Vector2]:
	var out: Array[Vector2] = []
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[r] < SimConst.SNAP_PROJ_BASE and int(snap[r + 1]) == SimConst.K_PCAR:
			out.append(Vector2(snap[r + 4], snap[r + 5]))
	return out
