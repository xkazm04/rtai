extends GutTest
## The dodging boss bot and cover (servo's ask): a sidestep into a crate turns to the open side;
## walled on both sides it keeps its way and rolls (BossBot.walled). Planted: no flip.


func _walls(boxes: Array[Rect2]) -> ArenaWalls:
	var w: ArenaWalls = ArenaWalls.new()
	w.boxes = boxes
	return w


func test_sidestep_into_a_crate_turns_to_the_open_side() -> void:
	var w: ArenaWalls = _walls([Rect2(Vector2(0.5, -0.5), Vector2(1.0, 1.0))])
	assert_eq(BossBot.sidestep(w, Vector2.ZERO, Vector2.RIGHT), Vector2.LEFT)
	assert_eq(BossBot.sidestep(w, Vector2.ZERO, Vector2.LEFT), Vector2.LEFT, "open: kept")


func test_walled_on_both_sides_keeps_its_way_and_reads_walled() -> void:
	var w: ArenaWalls = _walls(
		[
			Rect2(Vector2(0.5, -0.5), Vector2(1.0, 1.0)),
			Rect2(Vector2(-1.5, -0.5), Vector2(1.0, 1.0))
		]
	)
	assert_eq(BossBot.sidestep(w, Vector2.ZERO, Vector2.RIGHT), Vector2.RIGHT)
	assert_true(BossBot.walled(w, Vector2.ZERO, Vector2.RIGHT))
	assert_true(BossBot.walled(w, Vector2.ZERO, Vector2.LEFT))
	assert_false(BossBot.walled(w, Vector2.ZERO, Vector2.UP))
	assert_false(BossBot.walled(null, Vector2.ZERO, Vector2.UP), "no walls: never walled")
