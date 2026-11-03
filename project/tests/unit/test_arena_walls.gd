extends GutTest


func _walls() -> ArenaWalls:
	var w: ArenaWalls = ArenaWalls.new()
	w.boxes.append(Rect2(Vector2(0.0, 0.0), Vector2(4.0, 1.0)))
	return w


func test_a_body_outside_is_left_alone() -> void:
	assert_eq(_walls().push_out(Vector2(2.0, -2.0), 0.4), Vector2(2.0, -2.0))


func test_a_body_touching_the_edge_is_pushed_to_its_radius() -> void:
	var p: Vector2 = _walls().push_out(Vector2(2.0, -0.2), 0.4)
	assert_almost_eq(p.y, -0.4, 0.0001)
	assert_almost_eq(p.x, 2.0, 0.0001)


func test_a_body_inside_leaves_by_the_shallowest_side() -> void:
	var p: Vector2 = _walls().push_out(Vector2(2.0, 0.9), 0.4)
	assert_almost_eq(p.y, 1.4, 0.0001)


func test_a_shot_through_the_box_is_blocked_and_one_past_it_is_not() -> void:
	var w: ArenaWalls = _walls()
	assert_true(w.blocks(Vector2(2.0, -1.0), Vector2(2.0, 2.0)))
	assert_false(w.blocks(Vector2(5.0, -1.0), Vector2(5.0, 2.0)))


func test_the_shipped_pit_has_solid_cover_and_doors_that_are_not() -> void:
	var stations: ArenaStations = ArenaStations.shipped()
	var w: ArenaWalls = ArenaWalls.from_stations(stations, Vector2.ZERO)
	assert_gt(w.boxes.size(), 10)
	assert_false(w.blocks(Vector2(3.0, 5.0), Vector2(3.0, 9.0)), "the west door is open")
	assert_true(w.blocks(Vector2(12.0, 5.0), Vector2(12.0, 9.0)), "the north wall is shut")


func test_the_pit_reads_its_wave_rule_and_spawn_points() -> void:
	var pit: ArenaPit = ArenaPit.from_plan(ArenaPlan.shipped(), ArenaStations.shipped())
	assert_eq(pit.points.size(), 5)
	assert_eq(pit.first_wave, 2)
	assert_eq(pit.gap_ticks, roundi(2.5 / SimClock.TICK_DT))
	assert_true(pit.zone.has_point(Vector2(7.0, 17.0)))
	assert_false(pit.zone.has_point(Vector2.ZERO))
