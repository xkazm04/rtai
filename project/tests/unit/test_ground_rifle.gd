extends GutTest
## n11: a dropped rifle is a drawn gun, turned by where it fell, not a black bar at one angle.


func test_two_drops_lie_differently() -> void:
	var a: float = GroundRifle.turn(Vector2(10.0, 4.0))
	var b: float = GroundRifle.turn(Vector2(12.5, 7.25))
	assert_gt(absf(a - b), 0.2, "neighbouring drops do not point one way")


func test_the_same_drop_keeps_its_angle() -> void:
	assert_eq(GroundRifle.turn(Vector2(3.0, 9.0)), GroundRifle.turn(Vector2(3.0, 9.0)))


func test_it_lies_beside_the_body_not_under_it() -> void:
	var at: Vector2 = Vector2(6.0, 2.0)
	assert_almost_eq(GroundRifle.lies_at(at).distance_to(at), GroundRifle.BESIDE_M, 0.001)


func test_a_drop_far_off_screen_is_not_drawn() -> void:
	assert_true(GroundRifle.visible_from(Vector2(5.0, 0.0), Vector2.ZERO))
	assert_false(GroundRifle.visible_from(Vector2(GroundRifle.DRAW_M + 1.0, 0.0), Vector2.ZERO))


func test_the_mesh_is_as_long_as_the_gun() -> void:
	var box: AABB = GroundRifle.mesh().get_aabb()
	var want: float = GroundRifle.LENGTH_M * Ink.PX_PER_M
	assert_almost_eq(box.size.x, want, GroundRifle.INK_PX * 2.0 + 0.5, "butt to muzzle")


func test_the_drawn_heading_is_the_nearest_of_eight() -> void:
	assert_eq(GroundRifle.heading(0.0), 0)
	assert_eq(GroundRifle.heading(PI * 0.5), 2, "muzzle down the screen")
	assert_eq(GroundRifle.heading(PI), 4)
	assert_eq(GroundRifle.heading(TAU - 0.1), 0, "just short of a full turn wraps to 0")
	assert_eq(GroundRifle.heading(-PI * 0.25), 7)


func test_the_drawn_sheet_has_eight_square_cells() -> void:
	var tex: Texture2D = GroundRifle.sheet()
	assert_not_null(tex, "the drawn rifle ships")
	if tex != null:
		assert_eq(tex.get_width(), tex.get_height() * GroundRifle.HEADINGS)
