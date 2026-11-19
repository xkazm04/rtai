extends GutTest
## n11: a dropped rifle is a drawn gun, turned by where it fell, not a black bar at one angle.


func test_two_drops_lie_differently() -> void:
	var a: float = GroundRifle.turn(Vector2(10.0, 4.0))
	var b: float = GroundRifle.turn(Vector2(12.5, 7.25))
	assert_gt(absf(a - b), 0.2, "neighbouring drops do not point one way")


func test_the_same_drop_keeps_its_angle() -> void:
	assert_eq(GroundRifle.turn(Vector2(3.0, 9.0)), GroundRifle.turn(Vector2(3.0, 9.0)))


func test_the_original_radial_offset_is_available() -> void:
	var at: Vector2 = Vector2(6.0, 2.0)
	assert_almost_eq(GroundRifle.lies_at(at).distance_to(at), GroundRifle.BESIDE_M, 0.001)


func test_the_original_shooter_offset_is_available() -> void:
	# n11 it19: the body falls away from the shot, so the gun beside its feet lay under its legs.
	GroundRifle.forget()
	var at: Vector2 = Vector2(6.0, 2.0)
	var p: Vector2 = GroundRifle.lies_at_from(at, Vector2(0.0, 2.0))
	assert_lt(p.x - at.x, -0.3, "toward the shooter on the left, the body lies to the right")
	GroundRifle.forget()


func test_visible_rifle_edge_lands_half_a_metre_beside_the_lying_segment_from_each_side() -> void:
	var at: Vector2 = Vector2(6.0, 2.0)
	var gun: PackedVector2Array = [
		Vector2(-0.53, -0.09), Vector2(0.52, -0.09), Vector2(0.52, 0.09), Vector2(-0.53, 0.09)
	]
	assert_true(GroundRifle.BODY_GAP)
	for dir: Vector2 in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		var body: PackedVector2Array = [at + dir, at + dir * 2.5]
		var point: Vector2 = GroundRifle.beside(body, PackedVector2Array([Vector2.ZERO]), dir)
		var nearest: Vector2 = Geometry2D.get_closest_point_to_segment(point, body[0], body[1])
		assert_almost_eq(point.distance_to(nearest), 0.5, 0.001)
		var lie: Vector2 = GroundRifle.beside(body, gun, dir)
		var gap: float = INF
		for i: int in gun.size():
			var near: PackedVector2Array = Geometry2D.get_closest_points_between_segments(
				body[0], body[1], lie + gun[i - 1], lie + gun[i]
			)
			gap = minf(gap, near[0].distance_to(near[1]))
		assert_almost_eq(gap, 0.5, 0.001, "nearest rifle edge to the resting segment, %s" % dir)
		assert_lt((lie - body[0]).dot(dir), 0.0, "on the shooter's side")
		assert_gt(absf((lie - body[0]).cross(dir)), 0.4, "beside the body")


func test_it_keeps_its_place_when_rivet_walks_round_it() -> void:
	GroundRifle.forget()
	var at: Vector2 = Vector2(-3.0, 8.0)
	var first: Vector2 = GroundRifle.lies_at_from(at, Vector2(-3.0, 0.0))
	assert_eq(GroundRifle.lies_at_from(at, Vector2(-3.0, 16.0)), first)
	GroundRifle.forget()


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


func test_a_drop_lands_with_the_body_not_while_he_holds_the_gun() -> void:
	GroundRifle.forget()
	var at: Vector2 = Vector2(4.0, 7.0)
	assert_false(GroundRifle.landed(at, 100), "the kill tick: still in his hands")
	assert_false(GroundRifle.landed(at, 100 + GroundRifle.LAND_TICKS - 1), "falling")
	assert_true(GroundRifle.landed(at, 100 + GroundRifle.LAND_TICKS), "down with the body")
	assert_true(GroundRifle.landed(at, 900), "and it stays")
	GroundRifle.forget()
	assert_false(GroundRifle.landed(at, 900), "a new fight starts the drop again")
