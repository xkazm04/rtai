extends GutTest


func test_shipped_top_casts_no_shadow() -> void:
	assert_eq(ViewMode.of("top").cast_k, 0.0)


func test_top_lift_casts_down_right() -> void:
	var v: ViewMode = ViewMode.of("top_lift")
	assert_gt(v.cast_k, 0.0)
	assert_gt(v.cast_dir().x, 0.0)
	assert_gt(v.cast_dir().y, 0.0)
	assert_almost_eq(v.cast_dir().length(), 1.0, 0.0001)


func test_figure_runs_along_the_sun_as_long_as_the_body() -> void:
	var dir: Vector2 = Vector2.RIGHT
	var fig: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, dir, 10.0)
	var far: float = 0.0
	for p: Vector2 in fig:
		far = maxf(far, p.x)
	assert_almost_eq(far, 10.0 * RigCastShadows.BODY_IN_HIPS, 0.001)
	assert_eq(fig.size(), 8)


func test_a_downed_body_casts_a_shorter_figure() -> void:
	var tall: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, Vector2.DOWN, 20.0)
	var low: PackedVector2Array = RigCastShadows.figure(Vector2.ZERO, Vector2.DOWN, 5.0)
	assert_gt(tall[4].y, low[4].y)


func test_sweep_of_a_box_is_its_footprint_and_top() -> void:
	var sq: PackedVector2Array = PackedVector2Array(
		[Vector2(0, 0), Vector2(10, 0), Vector2(10, 10), Vector2(0, 10)]
	)
	var hull: PackedVector2Array = RigCastShadows.sweep_hull(sq, Vector2(5, 5))
	assert_eq(hull.size(), 6)  # a diagonal sweep drops the two hidden corners
	assert_true(hull.has(Vector2(15, 15)))
	assert_true(hull.has(Vector2(0, 0)))


## n11 (owner note "no long cast shadows"): the play views draw a contact shadow under the feet.
func test_the_play_views_cast_short_and_contact() -> void:
	for id: String in ["combo", "tilt70"]:
		assert_lt(ViewMode.of(id).cast_k, RigCastShadows.CONTACT_BELOW_K, id)


func test_a_contact_shadow_lies_flat_round_the_feet() -> void:
	var at: Vector2 = Vector2(10.0, 20.0)
	var e: PackedVector2Array = RigCastShadows.contact_ellipse(at, 10.0)
	assert_eq(e.size(), RigCastShadows.CONTACT_POINTS)
	var box: Rect2 = Rect2(e[0], Vector2.ZERO)
	for p: Vector2 in e:
		box = box.expand(p)
	assert_almost_eq(box.get_center().x, at.x, 0.01, "centred")
	assert_lt(box.size.y, box.size.x, "flattened on the ground")
