extends GutTest
## Adversarial t-4 fixtures: no city assets or engine stepping required.

const CENTRE: Vector2 = Vector2(100.0, 156.0)
const HEADINGS: Array[Vector2] = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
const EPS: float = 0.125

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


func _assert_heading(direction: int, context: String) -> void:
	assert_eq(_s.dir[0], direction, context)
	assert_eq(_route.d, direction, context)
	assert_eq(Vector2(_route.ddx, _route.ddy), HEADINGS[direction], context)


## Mask-relative (Call c-2): a tile kind CAR_DEAD_END_TILES names turns the car back on the same
## road centre; every other one (and a road, always) keeps its direction and lane.
func test_every_nonvoid_nonintersection_tile_follows_the_dead_end_mask() -> void:
	var tiles: Array[int] = [
		SimConst.T_CURB,
		SimConst.T_CORNER,
		SimConst.T_BLOCK,
		SimConst.T_PLAZA,
		SimConst.T_ROAD_H,
		SimConst.T_ROAD_V,
	]
	_s.cells.fill(SimConst.C_WALK)  # Sidewalk is a cell kind, not a separate tile kind.
	for direction: int in 4:
		for tile: int in tiles:
			_s.tiles.fill(SimConst.T_VOID)
			_tile(CENTRE, tile)
			_begin(direction)
			_plan_probe(CENTRE)
			var context: String = "dir %d tile %d" % [direction, tile]
			var want: int = direction
			if CitySimCarRoute.dead_end(tile):
				want = (direction + 2) % 4
			_assert_heading(want, context)
			assert_eq(_s.lane[0], _lane(CENTRE, want), context)
			assert_eq(_s.ndir[0], -1, context)


func test_void_probe_uturns_on_same_road_centre_even_with_sidewalk_cells() -> void:
	_s.cells.fill(SimConst.C_WALK)
	for direction: int in 4:
		_s.tiles.fill(_road(direction))
		_tile(CENTRE, SimConst.T_VOID)
		_begin(direction)
		_plan_probe(CENTRE)
		var back: int = (direction + 2) % 4
		_assert_heading(back, "unloaded lookahead dir %d" % direction)
		assert_eq(_s.lane[0], _lane(CENTRE, back))
		assert_eq(_s.ndir[0], -1, "edge reversal does not invent a junction plan")


func test_lookahead_samples_exact_tile_boundary_in_every_direction() -> void:
	for direction: int in 4:
		var entry: Vector2 = CENTRE - HEADINGS[direction] * SimConst.TILE_M * 0.5
		for offset: float in [-EPS, 0.0, EPS]:
			_s.tiles.fill(_road(direction))
			_tile(CENTRE, SimConst.T_INTER)
			_begin(direction)
			_plan_probe(entry + HEADINGS[direction] * offset)
			# Tile coordinates are half-open: west/north edges belong to the junction.
			var inside: bool = offset >= 0.0 if direction < 2 else offset > 0.0
			assert_eq(
				_s.ndir[0],
				direction if inside else -1,
				"dir %d offset %s at lookahead tile entry" % [direction, offset]
			)


func test_junction_reservation_releases_strictly_past_clearance_for_every_exit() -> void:
	for direction: int in 4:
		for owner: int in [1, 2]:
			_begin(direction)
			_s.ndir[0] = direction
			_s.jx[0] = CENTRE.x
			_s.jy[0] = CENTRE.y
			assert_false(_route.reserve(0))
			var reservation: int = _s.res[0]
			_s.owner[reservation] = owner
			for offset: float in [-EPS, 0.0, EPS]:
				var point: Vector2 = (
					CENTRE + HEADINGS[direction] * (SimConst.CAR_JUNCTION_CLEAR + offset)
				)
				_route.turn(0, point.x, point.y)
				assert_eq(_s.ndir[0], direction if offset <= 0.0 else -1)
				assert_eq(_s.res[0], reservation if offset <= 0.0 else -1)
				assert_eq(_s.owner[reservation], 0 if offset > 0.0 and owner == 1 else owner)


func test_last_map_tile_uturns_at_each_edge_without_wrapping_to_loaded_tiles() -> void:
	var extent: float = SimConst.TW * SimConst.TILE_M
	for direction: int in 4:
		var centre: Vector2 = Vector2.ONE * (extent - SimConst.TILE_M * 0.5)
		if direction == 2:
			centre.x = SimConst.TILE_M * 0.5
		elif direction == 3:
			centre.y = SimConst.TILE_M * 0.5
		_s.tiles.fill(_road(direction))
		_begin(direction, centre)
		_route.plan(0, centre.x, centre.y, centre.x, centre.y)
		_assert_heading((direction + 2) % 4, "map boundary dir %d" % direction)
		assert_eq(_s.lane[0], _lane(centre, (direction + 2) % 4))


func test_edge_junction_rejects_offmap_exit_and_keeps_the_only_inbounds_exit() -> void:
	for direction: int in 4:
		var extent: float = SimConst.TW * SimConst.TILE_M
		var centre: Vector2 = CENTRE
		var edge: float = SimConst.TILE_M * 0.5
		if direction < 2:
			edge = extent - edge
		if direction % 2 == 0:
			centre.x = edge
		else:
			centre.y = edge
		for kind: int in [SimConst.K_CAR, SimConst.K_PCAR]:
			_s.kind[0] = kind
			_s.tiles.fill(SimConst.T_VOID)
			_tile(centre, SimConst.T_INTER)
			_begin(direction, centre)
			_plan_probe(centre)
			assert_eq(_s.ndir[0], (direction + 2) % 4, "edge junction with no exits")
			var nd: int = (direction + 1) % 4
			_tile(centre + HEADINGS[nd] * SimConst.CAR_EXIT_PROBE, _road(nd))
			_plan_probe(centre, centre + HEADINGS[direction] * SimConst.CAR_EXIT_PROBE)
			assert_eq(_s.ndir[0], nd, "offmap straight exit loses to the only road")
			assert_eq(Vector2(_s.jx[0], _s.jy[0]), centre)
			assert_eq(_s.nlane[0], _lane(centre, nd))


class ProbeFlow:
	extends CitySimFlow

	var distances: Dictionary[Vector2, int] = {}

	func dist(x: float, y: float) -> int:
		return distances.get(Vector2(x, y), -1)
