extends GutTest
## Patrol routes include authored props and the city's solid metre cells. All five bodies in
## EnemyPit have separate coverage in test_enemy_motor_wall.

const BOUNDS: Rect2 = Rect2(-20, -20, 40, 40)
const WALL: Rect2 = Rect2(-6, -0.3, 12, 0.6)


class CityWall:
	extends StageCells

	func solid(x: int, y: int) -> bool:
		return y == 0 and x >= -6 and x < 6


func test_body_width_blocks_a_grazing_line_but_leaves_the_door_open() -> void:
	var map: GuardRouteMap = GuardRouteMap.new(BOUNDS, [WALL], null, 0.45)
	assert_false(map.clear_line(Vector2(6.4, -2), Vector2(6.4, 2)))
	assert_true(map.clear_line(Vector2(6.5, -2), Vector2(6.5, 2)))
	assert_false(map.clear_line(Vector2(-6.4, 2), Vector2(-6.4, -2)))
	assert_true(map.clear_line(Vector2(-6.5, 2), Vector2(-6.5, -2)))


func test_city_cells_and_props_both_constrain_the_same_path() -> void:
	var cells: CityWall = CityWall.new(null)
	# The city's wall ends east at x=6. An authored leg closes the obvious right turn.
	var leg: Rect2 = Rect2(5.8, -6, 0.6, 6.5)
	var map: GuardRouteMap = GuardRouteMap.new(BOUNDS, [leg], cells, 0.45)
	var at: Vector2 = Vector2(4.5, -1.5)
	var goal: Vector2 = Vector2(4.5, 2.5)
	assert_false(map.clear_line(at, goal))
	var path: PackedVector2Array = map.route(at, goal)
	assert_gt(path.size(), 1)
	var farthest: float = 0.0
	for p: Vector2 in path:
		assert_true(cells.swept_clear(at, p, 0.45), "the whole body clears city cells")
		assert_false(ArenaWalls._crosses(leg.grow(0.44), at, p), "the leg blocks shortcuts")
		farthest = maxf(farthest, at.distance_to(p))
		at = p
	assert_eq(at, goal)
	assert_gt(farthest, 3.0, "follow bends instead of pausing at every metre")


func test_a_body_pushed_against_a_rounded_corner_can_leave_it() -> void:
	var map: GuardRouteMap = GuardRouteMap.new(BOUNDS, [WALL], null, 0.45)
	var foot: Vector2 = Vector2(-6.32, -0.62)
	assert_true(map.clear_line(foot, Vector2(-7, -1)))
	assert_true(map.clear_line(Vector2(-7, -1), foot))
	assert_false(map.clear_line(foot, Vector2(1, 0)))


func test_guards_share_one_search_per_start_cell_for_the_current_target() -> void:
	var map: GuardRouteMap = GuardRouteMap.new(BOUNDS, [WALL], null, 0.45)
	for i: int in 20:
		var from: Vector2 = Vector2(1.1 + i * 0.03, -3.5)
		assert_false(map.route(from, Vector2(0.25, 2.25)).is_empty())
	assert_eq(map.searches, 1)
	assert_false(map.route(Vector2(1.5, -3.5), Vector2(-8.5, 3.5)).is_empty())
	assert_eq(map.searches, 2, "a new destination cannot reuse the old route")


func test_an_unreachable_target_is_cached_and_a_clear_new_approach_resumes() -> void:
	var fence: Rect2 = Rect2(-30, -0.5, 60, 1)
	var map: GuardRouteMap = GuardRouteMap.new(BOUNDS, [fence], null, 0.45)
	var g: Fighter = Fighter.make(Fighter.Kind.GUARD, 1, Vector2(0, -4), 1.0)
	g.pursuit = GuardPursuit.new(map)
	for t: int in 180:
		assert_true(g.pursuit.advance(g, Vector2(0, 4), 3.0))
	assert_eq(g.pos, Vector2(0, -4))
	assert_eq(map.searches, 1, "one failed search while both ends hold")
	var direct: bool = false
	for t: int in GuardPursuit.CHECK_TICKS:
		direct = not g.pursuit.advance(g, Vector2(3, -4), 3.0)
	assert_true(direct, "the ordinary rifle brain has control in sight")
	assert_eq(map.searches, 1)
