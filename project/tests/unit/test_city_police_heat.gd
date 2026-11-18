extends GutTest
## n18 police item 3 (heat 1: investigate). With heat on (set_heat level >= 0) a free cop walks his
## sidewalk and holds fire; at heat 1 the PT_FOOT1 cops nearest the last-seen point are engaged,
## path there, search PT_SEARCH_S and go back to walking; a new last-seen point re-engages them.
## Map: CityWallMap (all sidewalk, wall x 300..302); Rivet (the step target) stands east of the
## wall, out of every cop's sight, so the cops answer the last-seen point alone.

const CAM: Vector2 = Vector2(290.0, 300.0)
const RIVET: Vector2 = Vector2(320.5, 290.5)
const POINT: Vector2 = Vector2(288.5, 330.5)
const COPS: Array[float] = [262.5, 268.5, 274.5, 280.5, 286.5, 292.5]
const TUNE: PackedFloat64Array = [0.0, 3.0, 4.0, 6.0, 10.0, 3.0, 1.4]


func test_at_heat_0_cops_walk_their_sidewalk_and_hold_fire() -> void:
	var sim: CitySimRef = _map()
	var slots: Array[int] = _spawn(sim)
	sim.set_heat(0, POINT.x, POINT.y)
	var shots: int = _run(sim, 300, Vector2(RIVET.x, 300.5))
	var walked: float = CityWallMap.pos(sim, slots[0]).y - 290.5
	assert_almost_eq(walked, 1.4 * 5.0, 0.2, "a free cop walks south at PT_WALK_V")
	assert_eq(shots, 0, "no cop fires at heat 0")
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 0)


func test_at_heat_1_the_three_nearest_go_to_the_last_seen_point() -> void:
	var sim: CitySimRef = _map()
	var slots: Array[int] = _spawn(sim)
	sim.set_heat(1, POINT.x, POINT.y)
	var t: int = _ticks_until_near(sim, slots.slice(3), 4.0, 1200)
	gut.p("heat 1: the three nearest cops within 4 m of the point at tick %d" % t)
	assert_gt(t, 0, "they reached the last-seen point")
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 3, "PT_FOOT1 cops engaged")
	for s: int in slots.slice(0, 3):
		var far: float = CityWallMap.pos(sim, s).distance_to(POINT)
		assert_gt(far, 10.0, "cop %d (not among the nearest) kept walking" % s)


func test_after_the_search_they_go_back_to_walking() -> void:
	var sim: CitySimRef = _map()
	var slots: Array[int] = _spawn(sim)
	sim.set_heat(1, POINT.x, POINT.y)
	var t: int = _ticks_until_near(sim, slots.slice(3), 4.0, 1200)
	assert_gt(t, 0)
	var search_ticks: int = int(TUNE[SimConst.PT_SEARCH_S] * SimClock.TICK_RATE)
	_go(sim, search_ticks + 30, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 0, "searched PT_SEARCH_S: released")
	var p0: Vector2 = CityWallMap.pos(sim, slots[5])
	_go(sim, 120, RIVET)
	var moved: float = CityWallMap.pos(sim, slots[5]).distance_to(p0)
	assert_almost_eq(moved, 1.4 * 2.0, 0.3, "walking at PT_WALK_V again")


func test_a_new_last_seen_point_engages_them_again() -> void:
	var sim: CitySimRef = _map()
	var slots: Array[int] = _spawn(sim)
	sim.set_heat(1, POINT.x, POINT.y)
	assert_gt(_ticks_until_near(sim, slots.slice(3), 4.0, 1200), 0)
	_go(sim, int(TUNE[SimConst.PT_SEARCH_S] * SimClock.TICK_RATE) + 30, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 0)
	sim.set_heat(1, 270.5, 330.5)
	_go(sim, 1, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 3, "Rivet seen again: a new point")


func test_an_engaged_cop_fires_only_with_rivet_in_sight() -> void:
	var sim: CitySimRef = _map()
	assert_eq(_spawn(sim).size(), COPS.size())
	sim.set_heat(1, 290.5, 291.5)
	var shots: int = _run(sim, 240, Vector2(305.5, 291.5))
	assert_eq(shots, 0, "Rivet 15 m away behind the wall: no shot")
	shots = _run(sim, 240, Vector2(290.5, 296.5))
	assert_gt(shots, 0, "Rivet in the open within 20 m: they fire")


func test_heat_3_engages_pt_foot3_and_dropping_to_0_releases_all() -> void:
	var sim: CitySimRef = _map()
	assert_eq(_spawn(sim).size(), COPS.size())
	sim.set_heat(3, POINT.x, POINT.y)
	_go(sim, 1, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 6)
	sim.set_heat(2, POINT.x, POINT.y)
	_go(sim, 1, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 4, "a level down releases the farthest")
	sim.set_heat(0, POINT.x, POINT.y)
	_go(sim, 1, RIVET)
	assert_eq(sim.flow_stats()[SimConst.FS_ENGAGED], 0)


func _map() -> CitySimRef:
	var sim: CitySimRef = CityWallMap.walled(true)
	sim.set_police(TUNE)
	return sim


func _spawn(sim: CitySimBackend) -> Array[int]:
	var out: Array[int] = []
	for x: float in COPS:
		out.append(CityWallMap.spawn_cop(sim, Vector2(x, 290.5)))
	return out


## Steps n ticks with Rivet at `at`; returns the projectiles seen spawned (new records).
func _run(sim: CitySimBackend, n: int, at: Vector2) -> int:
	var shots: int = 0
	for t: int in n:
		var before: int = sim.get_counters()[SimConst.CN_PROJ]
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, at.x, at.y)
		shots += maxi(0, sim.get_counters()[SimConst.CN_PROJ] - before)
	return shots


func _go(sim: CitySimBackend, n: int, at: Vector2) -> void:
	@warning_ignore("return_value_discarded")
	_run(sim, n, at)


func _ticks_until_near(sim: CitySimBackend, slots: Array[int], r: float, cap: int) -> int:
	for t: int in cap:
		sim.step(SimClock.TICK_DT, CAM.x, CAM.y, RIVET.x, RIVET.y)
		var all: bool = true
		for s: int in slots:
			all = all and CityWallMap.pos(sim, s).distance_to(POINT) <= r
		if all:
			return t + 1
	return -1
