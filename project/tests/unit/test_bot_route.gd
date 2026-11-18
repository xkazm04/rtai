extends GutTest
## BotRoute (n18 districts item 5): the quest bot's walk round the city's buildings. From Dock 9's
## door (CityPlaces dock_9) to the far side of its long block, a straight line crosses the
## building; the route goes round it on open cells only, in steps no longer than a diagonal cell,
## longer than the straight line, and the same on a second search.

const BACK_M: float = 60.0

var _cells: StageCells = null
var _door: Vector2 = Vector2.ZERO
var _far: Vector2 = Vector2.ZERO


func before_all() -> void:
	var gen: CityGen = CityGen.from_tables(CitySystem.DISTRICT, CitySystem.TEXTURES)
	_cells = StageCells.new(gen)
	var p: Dictionary = CityPlaces.shipped(gen).place("dock_9")
	var facing: Vector2 = p["facing"]
	_door = p["door"]
	_door += facing * 2.0
	_far = _door - facing * BACK_M


func test_the_straight_line_is_blocked() -> void:
	var blocked: bool = false
	for i: int in 61:
		var q: Vector2 = _door.lerp(_far, i / 60.0)
		blocked = blocked or _cells.solid(floori(q.x), floori(q.y))
	assert_true(blocked, "the block stands between the door and its far side")


func test_the_route_goes_round_on_open_cells() -> void:
	var r: BotRoute = BotRoute.find(_cells, _door, _far)
	assert_not_null(r)
	if r == null:
		return
	var length: float = 0.0
	for i: int in range(1, r.size()):
		var step: float = r.waypoints[i - 1].distance_to(r.waypoints[i])
		length += step
		assert_lt(step, BotRoute.STEP_M * 1.5, "step %d" % i)
	for i: int in range(1, r.size() - 1):
		var c: Vector2i = Vector2i(r.waypoints[i]) / BotRoute.STEP_M
		assert_true(BotRoute.is_open(_cells, c.x, c.y), "waypoint %d open" % i)
	assert_gt(length, _door.distance_to(_far) * 1.2, "the route goes round the block")


func test_the_route_is_stable() -> void:
	var a: BotRoute = BotRoute.find(_cells, _door, _far)
	var b: BotRoute = BotRoute.find(_cells, _door, _far)
	assert_not_null(a)
	assert_not_null(b)
	if a != null and b != null:
		assert_eq(a.waypoints, b.waypoints)


func test_steer_moves_on_as_waypoints_pass() -> void:
	var r: BotRoute = BotRoute.new()
	r.goal = Vector2(20.0, 0.0)
	r.waypoints = PackedVector2Array([Vector2.ZERO, Vector2(10.0, 0.0), Vector2(20.0, 0.0)])
	assert_eq(r.steer(Vector2(0.5, 0.0)), Vector2(10.0, 0.0))
	assert_eq(r.steer(Vector2(9.0, 0.0)), Vector2(20.0, 0.0))
	assert_eq(r.steer(Vector2(19.5, 0.0)), Vector2(20.0, 0.0), "the last waypoint is the goal")
