extends GutTest


func test_pursuit_follows_body_clear_bend_then_heads_for_goal() -> void:
	var boxes: Array[Rect2] = [Rect2(4, -2, 2, 4)]
	var map: GuardRouteMap = GuardRouteMap.new(Rect2(-4, -7, 18, 14), boxes, null, 0.45)
	var path: BotStreetPath = BotStreetPath.new()
	var at: Vector2 = Vector2.ZERO
	var goal: Vector2 = Vector2(10, 0)
	for tick: int in 300:
		var step: Vector2 = path.toward(map, at, goal, tick)
		var next: Vector2 = at + step * 0.08
		assert_true(map.clear_line(at, next))
		at = next
		if at.distance_to(goal) < 0.1:
			break
	assert_lt(at.distance_to(goal), 0.1)
	assert_gt(map.searches, 0)


func test_no_progress_for_two_seconds_commits_a_sidestep() -> void:
	var map: GuardRouteMap = GuardRouteMap.new(Rect2(-5, -5, 20, 10), [], null, 0.45)
	var path: BotStreetPath = BotStreetPath.new()
	var goal: Vector2 = Vector2(8, 0)
	for tick: int in BotStreetPath.STUCK_TICKS:
		assert_eq(path.toward(map, Vector2.ZERO, goal, tick), Vector2.RIGHT)
	var tick: int = BotStreetPath.STUCK_TICKS
	var side: Vector2 = path.toward(map, Vector2.ZERO, goal, tick)
	assert_lt(absf(side.x), 0.1)
	assert_gt(absf(side.y), 0.9)
	assert_eq(path.toward(map, side * 0.1, goal, tick + 1), side)
	assert_eq(path.toward(map, Vector2.ZERO, goal, tick + 60), Vector2.RIGHT)
