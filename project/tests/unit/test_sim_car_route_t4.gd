extends GutTest
## t-4 (n11 Call 4, owner 2026-11-10): a car U-turns only at the city edge or an unloaded tile, a
## junction exit is open only onto a road of its own orientation, and the tuned distances come
## from SimConst (tools/gen_constants/sim_constants.json, group car_route), not inline literals.

const CENTRE: Vector2 = Vector2(100.0, 100.0)
const HEADINGS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const NOT_ROAD: Array[int] = [
	SimConst.T_CURB, SimConst.T_CORNER, SimConst.T_BLOCK, SimConst.T_PLAZA
]

var _s: CitySimState
var _route: CitySimCarRoute


func before_each() -> void:
	_s = CitySimState.new()
	_s.init(1)
	_s.kind[0] = SimConst.K_CAR
	_route = CitySimCarRoute.new(_s, CitySimFlow.new(_s))


func _begin(direction: int) -> void:
	_s.dir[0] = direction
	_s.lane[0] = 100.0 + CitySimState.LANE_OFF[direction]
	_s.ndir[0] = -1
	_route.begin(0)


func _tile(point: Vector2, tile: int) -> void:
	_s.tiles[floori(point.y / 8.0) * SimConst.TW + floori(point.x / 8.0)] = tile


func _plan_from(direction: int, dist: float) -> void:
	var at: Vector2 = CENTRE - HEADINGS[direction] * dist
	_route.plan(0, at.x, at.y, CENTRE.x, CENTRE.y)


func test_a_kerb_plaza_or_building_ahead_is_not_a_dead_end() -> void:
	for direction: int in 4:
		for tile: int in NOT_ROAD:
			_s.tiles.fill(CitySimCarRoute.road_of(direction))
			_tile(CENTRE, tile)
			_begin(direction)
			_plan_from(direction, SimConst.CAR_PLAN_AHEAD)
			assert_eq(_s.dir[0], direction, "tile %d ahead: no U-turn" % tile)
			assert_eq(_s.lane[0], 100.0 + CitySimState.LANE_OFF[direction])


func test_the_city_edge_and_an_unloaded_tile_still_turn_the_car_back() -> void:
	for direction: int in 4:
		_s.tiles.fill(CitySimCarRoute.road_of(direction))
		_tile(CENTRE, SimConst.T_VOID)
		_begin(direction)
		_plan_from(direction, SimConst.CAR_PLAN_AHEAD)
		var back: int = (direction + 2) % 4
		assert_eq(_s.dir[0], back, "unloaded tile ahead")
		assert_eq(_s.lane[0], 100.0 + CitySimState.LANE_OFF[back])
	_s.tiles.fill(SimConst.T_ROAD_H)
	_s.ndir[0] = -1
	_s.dir[0] = 2
	_s.lane[0] = 100.0 + CitySimState.LANE_OFF[2]
	_route.begin(0)
	_route.plan(0, SimConst.CAR_PLAN_AHEAD - 1.0, 100.0, 0.0, 0.0)
	assert_eq(_s.dir[0], 0, "past the west edge of the city is void: back east")


func test_an_exit_onto_a_crossing_road_of_the_other_orientation_is_closed() -> void:
	for direction: int in 4:
		for c: int in 3:
			_s.tiles.fill(0)
			_tile(CENTRE, SimConst.T_INTER)
			var nd: int = [(direction + 1) % 4, direction, (direction + 3) % 4][c]
			var wrong: int = CitySimCarRoute.road_of((nd + 1) % 4)
			_tile(CENTRE + HEADINGS[nd] * SimConst.CAR_EXIT_PROBE, wrong)
			_begin(direction)
			_plan_from(direction, SimConst.CAR_PLAN_AHEAD)
			assert_eq(_s.ndir[0], (direction + 2) % 4, "a sideways road is no exit: back")
			_tile(CENTRE + HEADINGS[nd] * SimConst.CAR_EXIT_PROBE, CitySimCarRoute.road_of(nd))
			_begin(direction)
			_plan_from(direction, SimConst.CAR_PLAN_AHEAD)
			assert_eq(_s.ndir[0], nd, "the same exit on its own road is taken")


func test_the_table_distances_gate_planning_and_release() -> void:
	_s.tiles.fill(SimConst.T_ROAD_H)
	_tile(CENTRE, SimConst.T_INTER)
	_tile(CENTRE + HEADINGS[0] * SimConst.CAR_EXIT_PROBE, SimConst.T_ROAD_H)
	_begin(0)
	_plan_from(0, SimConst.CAR_PLAN_AHEAD + 4.5)
	assert_eq(_s.ndir[0], -1, "the junction is past the planning probe")
	_plan_from(0, SimConst.CAR_PLAN_AHEAD + 3.5)
	assert_eq(_s.ndir[0], 0, "the probe reaches the junction tile")
	_route.turn(0, CENTRE.x + SimConst.CAR_JUNCTION_CLEAR, CENTRE.y)
	assert_eq(_s.ndir[0], 0, "still inside the junction's clearance")
	_route.turn(0, CENTRE.x + SimConst.CAR_JUNCTION_CLEAR + 0.5, CENTRE.y)
	assert_eq(_s.ndir[0], -1, "released past the clearance")


func test_a_turn_swings_the_lead_distance_before_the_new_lane() -> void:
	_s.jx[0] = CENTRE.x
	_s.jy[0] = CENTRE.y
	_begin(0)
	_s.ndir[0] = 1
	_s.nlane[0] = CENTRE.x + CitySimState.LANE_OFF[1]
	var line: float = _s.nlane[0] - SimConst.CAR_TURN_LEAD
	_route.turn(0, line - 0.25, CENTRE.y)
	assert_eq(_s.dir[0], 0, "not yet at the turn line")
	_route.turn(0, line, CENTRE.y)
	assert_eq(_s.dir[0], 1, "turns at the new lane minus the lead")
