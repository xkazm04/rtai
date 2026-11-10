extends GutTest

const CENTRE: Vector2 = Vector2(100.0, 100.0)
const HEADINGS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]

var _s: RouteState
var _flow: RouteFlow
var _route: CitySimCarRoute


func before_each() -> void:
	_s = RouteState.new()
	_s.init(1)
	_s.kind[0] = SimConst.K_CAR
	_flow = RouteFlow.new(_s)
	_route = CitySimCarRoute.new(_s, _flow)


func _begin(direction: int) -> void:
	_s.dir[0] = direction
	_s.lane[0] = 100.0 + CitySimState.LANE_OFF[direction]
	_route.begin(0)


func _tile(point: Vector2, tile: int) -> void:
	_s.tiles[floori(point.y / 8.0) * SimConst.TW + floori(point.x / 8.0)] = tile


func _junction(direction: int, mask: int) -> Array[int]:
	_s.tiles.fill(0)
	_begin(direction)
	_tile(CENTRE, SimConst.T_INTER)
	var candidates: Array[int] = [(direction + 1) % 4, direction, (direction + 3) % 4]
	for c: int in 3:
		if (mask & (1 << c)) != 0:
			var nd: int = candidates[c]
			_tile(CENTRE + HEADINGS[nd] * 16.0, _road(nd))
	return candidates


func _road(direction: int) -> int:
	return SimConst.T_ROAD_H if direction % 2 == 0 else SimConst.T_ROAD_V


func _plan(tg: Vector2 = CENTRE, dist: float = 18.0, offset: Vector2 = Vector2.ZERO) -> void:
	var approach: Vector2 = CENTRE + offset - HEADINGS[_route.d] * dist
	_route.plan(0, approach.x, approach.y, tg.x, tg.y)


func _turn(point: Vector2) -> void:
	_route.turn(0, point.x, point.y)


func _assert_direction(d: int) -> void:
	assert_eq([_s.dir[0], _route.d, Vector2(_route.ddx, _route.ddy)], [d, d, HEADINGS[d]])


func test_traffic_weights_are_renormalised_over_only_the_open_exits() -> void:
	for direction: int in 4:
		for mask: int in 8:
			var candidates: Array[int] = _junction(direction, mask)
			var total: float = 0.0
			for c: int in 3:
				total += CitySimCarRoute.WEIGHTS[c] if (mask & (1 << c)) != 0 else 0.0
			if mask == 0:
				_plan()
				assert_eq(_s.ndir[0], (direction + 2) % 4, "no exits means a U-turn")
				continue
			var lower: float = 0.0
			for c: int in 3:
				if (mask & (1 << c)) == 0:
					continue
				var width: float = CitySimCarRoute.WEIGHTS[c]
				_s.draw = (lower + width * 0.5) / total
				var calls: int = _s.draws
				_plan(CENTRE, 18.0, Vector2.ONE)
				assert_eq(_s.ndir[0], candidates[c], "each open exit owns its weighted interval")
				assert_eq(_s.draws, calls + 1)
				var lane: float = 100.0 + CitySimState.LANE_OFF[candidates[c]]
				assert_eq([_s.jx[0], _s.jy[0], _s.nlane[0]], [CENTRE.x, CENTRE.y, lane])
				_assert_direction(direction)
				lower += width
		_tile(CENTRE - HEADINGS[direction] * 8.0, _road(direction))
		_s.ndir[0] = -1
		_plan(CENTRE, 22.25)
		assert_eq(_s.ndir[0], -1, "junction is beyond the 18 metre lookahead")
		_plan(CENTRE, 21.75)
		assert_gte(_s.ndir[0], 0, "plan when the 18 metre probe enters the junction")


func test_road_ahead_preserves_course_but_missing_road_uturns_to_opposite_lane() -> void:
	for direction: int in 4:
		for tile: int in [_road(direction), 0]:
			_s.tiles.fill(tile)
			_begin(direction)
			_s.ndir[0] = -1
			_plan()
			var expected: int = direction if tile != 0 else (direction + 2) % 4
			_assert_direction(expected)
			assert_eq(_s.lane[0], 100.0 + CitySimState.LANE_OFF[expected])
			assert_eq(_s.ndir[0], -1)


func test_police_rank_covered_exits_before_uncovered_then_minimise_distance() -> void:
	_s.kind[0] = SimConst.K_PCAR
	var candidates: Array[int] = _junction(0, 7)
	var south: Vector2 = CENTRE + HEADINGS[candidates[0]] * 16.0
	var east: Vector2 = CENTRE + HEADINGS[candidates[1]] * 16.0
	# South/east flow distances, target direction (-1 = centre), expected exit.
	var cases: Array[Vector4i] = [
		Vector4i(9, 0, 3, 0),
		Vector4i(9, -1, 3, 1),
		Vector4i(-1, -1, 3, 3),
		Vector4i(-1, -1, -1, 1),
		Vector4i(5, 5, 0, 1),
	]
	for sample: Vector4i in cases:
		_flow.distances.assign({south: sample.x, east: sample.y})
		_plan(CENTRE if sample.z < 0 else CENTRE + HEADINGS[sample.z] * 16.0)
		assert_eq(_s.ndir[0], sample.w, str(sample))
	candidates = _junction(0, 0)
	_plan()
	assert_eq(_s.ndir[0], 2, "police U-turn when no road exit is open")
	assert_eq(_s.draws, 0, "police never use traffic randomness")


func test_turn_at_crossing_then_release_only_after_clearing_the_junction() -> void:
	for direction: int in 4:
		_s.jx[0] = CENTRE.x
		_s.jy[0] = CENTRE.y
		for offset: int in [1, 2, 3]:
			_begin(direction)
			var nd: int = (direction + offset) % 4
			_s.ndir[0] = nd
			_s.nlane[0] = 100.0 + CitySimState.LANE_OFF[nd]
			var cross: float = CENTRE.dot(HEADINGS[direction])
			if offset != 2:
				cross = _s.nlane[0] * HEADINGS[direction].dot(Vector2.ONE)
			_turn(HEADINGS[direction] * (cross - 8.0))
			assert_eq(_s.dir[0], direction, "do not turn before reaching the crossing")
			assert_eq(_s.lane[0], 100.0 + CitySimState.LANE_OFF[direction])
			_turn(HEADINGS[direction] * cross)
			_assert_direction(nd)
			assert_eq(_s.lane[0], _s.nlane[0])
			assert_eq(_s.ndir[0], nd, "the route remains active through the junction")
		for owner: int in [0, 1, 2]:
			_begin(direction)
			_s.ndir[0] = direction
			_s.res[0] = 0
			_s.owner[0] = owner
			var edge: Vector2 = CENTRE + HEADINGS[direction] * 4.0
			_turn(edge)
			assert_eq([_s.ndir[0], _s.res[0], _s.owner[0]], [direction, 0, owner])
			_turn(edge + HEADINGS[direction] * 16.0)
			assert_eq([_s.ndir[0], _s.res[0], _s.owner[0]], [-1, -1, 0 if owner == 1 else owner])
			_s.ndir[0] = direction
			_turn(edge + HEADINGS[direction] * 16.0)
			assert_eq(_s.ndir[0], -1, "clearing an unreserved route is safe too")


func test_reservation_waits_only_for_a_live_car_still_holding_that_junction() -> void:
	_s.jx[0] = CENTRE.x + 1.0
	_s.jy[0] = CENTRE.y - 1.0
	var jt: int = 12 * SimConst.TW + 12
	# owner (slot + 1), owner's alive flag, owner's reservation, must wait
	var cases: Array[Vector4i] = [
		Vector4i(0, 0, -1, 0),
		Vector4i(1, 0, -1, 0),
		Vector4i(2, 1, jt, 1),
		Vector4i(2, 0, jt, 0),
		Vector4i(2, 1, jt + 1, 0),
	]
	for sample: Vector4i in cases:
		_s.owner[jt] = sample.x
		_s.alive[1] = sample.y
		_s.res[1] = sample.z
		_s.res[0] = -1
		assert_eq(_route.reserve(0), sample.w != 0, str(sample))
		assert_eq(_s.owner[jt], 2 if sample.w != 0 else 1)
		assert_eq(_s.res[0], -1 if sample.w != 0 else jt)


class RouteState:
	extends CitySimState

	var draw: float = 0.5
	var draws: int = 0

	func rnd() -> float:
		draws += 1
		return draw


class RouteFlow:
	extends CitySimFlow

	var distances: Dictionary[Vector2, int] = {}

	func dist(x: float, y: float) -> int:
		return distances.get(Vector2(x, y), -1)
