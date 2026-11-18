extends GutTest
## n18 police item 4 (heat 2: cars). A police car the game dispatched (F_ENGAGED) routes to the
## last-seen point, stops within PT_CAR_STOP_M of it and parks; its PT_CREW cops get out on the
## kerb side as engaged foot cops and go to the point; heat 0 cancels it all (the car drives on,
## the crew walks). An undispatched police car under heat drives as traffic. Map: CityRoadMap.

const CAM: Vector2 = Vector2(320.0, 320.0)
const POINT: Vector2 = Vector2(340.5, 317.5)
const RIVET: Vector2 = Vector2(270.5, 290.5)
const TUNE: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4, 2.0, 12.0]


func test_a_dispatched_car_stops_near_the_point_and_its_crew_gets_out() -> void:
	var sim: CitySimRef = _map()
	var car: int = CityRoadMap.dispatch_car(sim, 262.0)
	sim.set_heat(2, POINT.x, POINT.y)
	var stop_tick: int = -1
	for t: int in 600:
		_step(sim, RIVET)
		if CityRoadMap.count(sim, SimConst.K_COP) > 0:
			stop_tick = t + 1
			break
	gut.p("heat 2: the dispatched car parked and unloaded at tick %d" % stop_tick)
	assert_gt(stop_tick, 0, "the car reached the point and its crew got out")
	var p: Vector2 = CityWallMap.pos(sim, car)
	assert_lte(p.distance_to(POINT), TUNE[SimConst.PT_CAR_STOP_M], "parked within car_stop_m")
	assert_eq(CityRoadMap.count(sim, SimConst.K_COP), 2, "PT_CREW cops out")
	for t: int in 60:
		_step(sim, RIVET)
	assert_almost_eq(CityWallMap.pos(sim, car).distance_to(p), 0.0, 0.01, "the car stays parked")


func test_the_crew_goes_to_the_point_and_heat_0_sends_everyone_on() -> void:
	var sim: CitySimRef = _map()
	var car: int = CityRoadMap.dispatch_car(sim, 262.0)
	sim.set_heat(2, POINT.x, POINT.y)
	var near: int = 0
	for t: int in 900:
		_step(sim, RIVET)
		near = _cops_near(sim, 4.0)
		if near == 2:
			break
	assert_eq(near, 2, "both crew cops reached the point")
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 0, "crew are outside the foot count")
	sim.set_heat(0, POINT.x, POINT.y)
	for t: int in 120:
		_step(sim, RIVET)
	assert_gt(sim.snapshot()[_row(sim, car) + 8], 1.0, "heat 0: the car drives on")


func test_an_undispatched_police_car_under_heat_is_traffic() -> void:
	var sim: CitySimRef = _map()
	var fl: int = SimConst.F_PROMOTED
	var spec: Array = [SimConst.K_PCAR, 262.0, CityRoadMap.LANE_E, 1.0, 0.0, 8, fl, 17.0]
	var car: int = sim.spawn(PackedFloat64Array(spec + [CityRoadMap.LANE_E, 0]))
	sim.set_heat(2, POINT.x, POINT.y)
	for t: int in 300:
		_step(sim, RIVET)
	assert_eq(CityRoadMap.count(sim, SimConst.K_COP), 0, "no crew: it was never dispatched")
	assert_gt(CityWallMap.pos(sim, car).distance_to(Vector2(262.0, CityRoadMap.LANE_E)), 20.0)


func _map() -> CitySimRef:
	var sim: CitySimRef = CitySimRef.new()
	CityRoadMap.paint(sim)
	sim.set_police(TUNE)
	return sim


func _step(sim: CitySimBackend, at: Vector2) -> void:
	sim.step(SimClock.TICK_DT, CAM.x, CAM.y, at.x, at.y)


func _cops_near(sim: CitySimBackend, r: float) -> int:
	var n: int = 0
	var snap: PackedFloat64Array = sim.snapshot()
	for k: int in range(0, snap.size() - SimConst.SNAP_STRIDE + 1, SimConst.SNAP_STRIDE):
		if snap[k] >= SimConst.SNAP_PROJ_BASE:
			break
		var p: Vector2 = Vector2(snap[k + 4], snap[k + 5])
		if int(snap[k + 1]) == SimConst.K_COP and p.distance_to(POINT) <= r:
			n += 1
	return n


func _row(sim: CitySimBackend, slot: int) -> int:
	var snap: PackedFloat64Array = sim.snapshot()
	for r: int in range(0, snap.size(), SimConst.SNAP_STRIDE):
		if int(snap[r]) == slot:
			return r
	return -1


## The search at the point waits for a dispatched car still on its way (before: a foot cop already
## there searched search_s, the search ended and released the car en route, so no crew came).
func test_the_search_waits_for_a_dispatched_car_en_route() -> void:
	var sim: CitySimRef = CitySimRef.new()
	CityRoadMap.paint(sim)
	var tune: PackedFloat64Array = TUNE.duplicate()
	tune[SimConst.PT_SEARCH_S] = 2.0
	sim.set_police(tune)
	assert_gte(CityWallMap.spawn_cop(sim, POINT), 0)
	assert_gte(CityRoadMap.dispatch_car(sim, 262.0), 0)
	sim.set_heat(2, POINT.x, POINT.y)
	for t: int in 300:
		_step(sim, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_SEARCH_TICKS], 0, "no search clock while the car drives")
	for t: int in 300:
		_step(sim, RIVET)
	assert_eq(CityRoadMap.count(sim, SimConst.K_COP), 3, "the car arrived and its crew got out")
