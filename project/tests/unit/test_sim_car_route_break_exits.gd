extends GutTest
## Adversarial t-4 fixtures (exits, draws, turns; split from
## test_sim_car_route_break): no city assets or engine stepping required.

const CENTRE: Vector2 = Vector2(100.0, 156.0)
const HEADINGS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const NON_ROAD: Array[int] = [
	SimConst.T_VOID,
	SimConst.T_INTER,
	SimConst.T_CURB,
	SimConst.T_CORNER,
	SimConst.T_BLOCK,
	SimConst.T_PLAZA,
]
const EPS: float = 0.125
# LCG seeds producing 0, just below/at quarter boundaries, and the largest draw.
const DRAW_SEEDS: Array[int] = [
	634785765,
	2239580901,
	1708527589,
	3313322725,
	2782269413,
	92097253,
	3856011237,
	1165839077,
]

var _s: CitySimState
var _flow: ProbeFlow
var _route: CitySimCarRoute


func before_each() -> void:
	_s = CitySimState.new()
	_s.init(1)
	_s.kind[0] = SimConst.K_CAR
	_flow = ProbeFlow.new(_s)
	_route = CitySimCarRoute.new(_s, _flow)


func _road(direction: int) -> int:
	return SimConst.T_ROAD_H if direction % 2 == 0 else SimConst.T_ROAD_V


func _lane(centre: Vector2, direction: int) -> float:
	var axis: float = centre.y if direction % 2 == 0 else centre.x
	return axis + CitySimState.LANE_OFF[direction]


func _begin(direction: int, centre: Vector2 = CENTRE) -> void:
	_s.dir[0] = direction
	_s.lane[0] = _lane(centre, direction)
	_s.ndir[0] = -1
	_s.res[0] = -1
	_route.begin(0)


func _tile(point: Vector2, tile: int) -> void:
	var x: int = floori(point.x / SimConst.TILE_M)
	var y: int = floori(point.y / SimConst.TILE_M)
	_s.tiles[y * SimConst.TW + x] = tile


func _plan_probe(probe: Vector2, target: Vector2 = CENTRE) -> void:
	var at: Vector2 = probe - HEADINGS[_s.dir[0]] * SimConst.CAR_PLAN_AHEAD
	_route.plan(0, at.x, at.y, target.x, target.y)


func _junction(direction: int, mask: int) -> Array[int]:
	_s.tiles.fill(SimConst.T_VOID)
	_begin(direction)
	_tile(CENTRE, SimConst.T_INTER)
	var exits: Array[int] = [(direction + 1) % 4, direction, (direction + 3) % 4]
	for c: int in 3:
		if mask & (1 << c):
			_tile(CENTRE + HEADINGS[exits[c]] * SimConst.CAR_EXIT_PROBE, _road(exits[c]))
	return exits


func _assert_heading(direction: int, context: String) -> void:
	assert_eq(_s.dir[0], direction, context)
	assert_eq(_route.d, direction, context)
	assert_eq(Vector2(_route.ddx, _route.ddy), HEADINGS[direction], context)


func _weighted_exit(exits: Array[int], mask: int, draw: float, back: int) -> int:
	var total: float = 0.0
	for c: int in 3:
		if mask & (1 << c):
			total += CitySimCarRoute.WEIGHTS[c]
	var cumulative: float = 0.0
	for c: int in 3:
		if mask & (1 << c):
			cumulative += CitySimCarRoute.WEIGHTS[c]
			if draw < cumulative / total:
				return exits[c]
	return back


func test_every_nonroad_and_wrong_orientation_probe_is_closed_for_both_car_kinds() -> void:
	for kind: int in [SimConst.K_CAR, SimConst.K_PCAR]:
		_s.kind[0] = kind
		for direction: int in 4:
			for c: int in 3:
				var exits: Array[int] = _junction(direction, 0)
				var nd: int = exits[c]
				var rejected: Array[int] = NON_ROAD.duplicate()
				rejected.append(_road((nd + 1) % 4))
				for tile: int in rejected:
					_tile(CENTRE + HEADINGS[nd] * SimConst.CAR_EXIT_PROBE, tile)
					_plan_probe(CENTRE)
					assert_eq(
						_s.ndir[0],
						(direction + 2) % 4,
						"kind %d dir %d exit %d tile %d" % [kind, direction, nd, tile]
					)
				_tile(CENTRE + HEADINGS[nd] * SimConst.CAR_EXIT_PROBE, _road(nd))
				_plan_probe(CENTRE)
				assert_eq(_s.ndir[0], nd, "only the correctly oriented exit opens")


func test_traffic_draws_match_weight_intervals_for_every_open_exit_subset() -> void:
	for direction: int in 4:
		for mask: int in 8:
			var exits: Array[int] = _junction(direction, mask)
			for seed_value: int in DRAW_SEEDS:
				_s.rs = seed_value
				var next: int = (seed_value * SimConst.LCG_MUL + SimConst.LCG_ADD) & 0xFFFFFFFF
				var draw: float = float(next >> 8) / 16777216.0
				var expected: int = _weighted_exit(exits, mask, draw, (direction + 2) % 4)
				_plan_probe(CENTRE)
				assert_eq(
					_s.ndir[0], expected, "dir %d mask %d seed %d" % [direction, mask, seed_value]
				)
				assert_eq(_s.rs, seed_value if mask == 0 else next, "one draw only with exits")


func test_police_choose_flow_nearest_open_exit_even_when_closed_exit_is_closer() -> void:
	_s.kind[0] = SimConst.K_PCAR
	for direction: int in 4:
		for winner: int in 3:
			var exits: Array[int] = _junction(direction, 7)
			_flow.distances.clear()
			for c: int in 3:
				_flow.distances[CENTRE + HEADINGS[exits[c]] * SimConst.CAR_EXIT_PROBE] = 20
			var probe: Vector2 = CENTRE + HEADINGS[exits[winner]] * SimConst.CAR_EXIT_PROBE
			_flow.distances[probe] = 0
			var seed_before: int = _s.rs
			_plan_probe(CENTRE, CENTRE - HEADINGS[exits[winner]] * SimConst.CAR_EXIT_PROBE)
			assert_eq(_s.ndir[0], exits[winner], "flow beats Euclidean target distance")
			_tile(probe, _road((exits[winner] + 1) % 4))
			_plan_probe(CENTRE, probe)
			assert_ne(_s.ndir[0], exits[winner], "best flow cannot open a sideways road")
			assert_eq(_s.rs, seed_before, "police must not draw traffic randomness")


func test_turn_lead_and_uturn_centre_boundaries_hold_in_all_directions() -> void:
	for direction: int in 4:
		for offset: int in [1, 2, 3]:
			_begin(direction)
			var nd: int = (direction + offset) % 4
			_s.ndir[0] = nd
			_s.jx[0] = CENTRE.x
			_s.jy[0] = CENTRE.y
			_s.nlane[0] = _lane(CENTRE, nd)
			var crossing: float = CENTRE.dot(HEADINGS[direction])
			if offset != 2:
				crossing = _s.nlane[0] * HEADINGS[direction].dot(Vector2.ONE)
				crossing -= SimConst.CAR_TURN_LEAD
			for step: float in [-EPS, 0.0, EPS]:
				var point: Vector2 = (
					CENTRE
					+ HEADINGS[direction] * (crossing - CENTRE.dot(HEADINGS[direction]) + step)
				)
				_route.turn(0, point.x, point.y)
				var expected: int = direction if step < 0.0 else nd
				_assert_heading(expected, "incoming %d outgoing %d step %s" % [direction, nd, step])
				assert_eq(_s.lane[0], _lane(CENTRE, expected))
				assert_eq(_s.ndir[0], nd, "turn retains the junction plan")


class ProbeFlow:
	extends CitySimFlow

	var distances: Dictionary[Vector2, int] = {}

	func dist(x: float, y: float) -> int:
		return distances.get(Vector2(x, y), -1)
