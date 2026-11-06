extends GutTest
## View lab (core/render/view_mode.gd): the default view is the shipped one, bit-identical.


func test_default_is_top_and_flat() -> void:
	var v: ViewMode = ViewMode.of("")
	assert_eq(v.id, &"top")
	assert_true(v.is_flat())
	assert_eq(v.zoom_of(1.5), Vector2.ONE * 1.5)
	assert_eq(v.lift_px(1.7), Vector2.ZERO)
	assert_eq(v.ground_k(), 1.0)


func test_top_lift_keeps_the_projection() -> void:
	var v: ViewMode = ViewMode.of("top_lift")
	assert_eq(v.id, &"top_lift")
	assert_true(v.is_flat())
	assert_eq(v.zoom_of(2.0), Vector2.ONE * 2.0)


func test_tilt_foreshortens_the_ground() -> void:
	var v: ViewMode = ViewMode.of("tilt")
	assert_false(v.is_flat())
	assert_almost_eq(v.ground_k(), sin(deg_to_rad(v.pitch_deg)), 1e-6)
	var z: Vector2 = v.zoom_of(1.0)
	assert_eq(z.x, 1.0)
	assert_lt(z.y, 1.0)
	assert_lt(v.lift_px(1.0).y, 0.0, "a height draws up the screen")


func test_unknown_falls_back_to_the_default() -> void:
	var v: ViewMode = ViewMode.of("nope")
	assert_eq(v.id, &"top")
	assert_true(v.is_flat())


func test_top_lift_leans_heights_out_from_the_eye() -> void:
	var v: ViewMode = ViewMode.of("top_lift")
	assert_true(v.is_flat(), "no angle change: the camera zoom stays uniform")
	assert_true(v.has_lift())
	var was: Vector2 = ViewMode.eye
	ViewMode.eye = Vector2(100.0, 100.0)
	assert_eq(v.up_at(Vector2(100.0, 100.0)), Vector2.ZERO, "under the eye nothing leans")
	var right: Vector2 = v.lift_at(Vector2(100.0 + 10.0 * SimConst.PX_PER_M, 100.0), 1.0)
	assert_gt(right.x, 0.0, "a height right of the eye leans right")
	assert_almost_eq(right.y, 0.0, 1e-6)
	ViewMode.eye = was


func test_the_shipped_view_has_no_lift() -> void:
	var v: ViewMode = ViewMode.of("top")
	assert_false(v.has_lift())
	assert_eq(v.lift_at(Vector2(500.0, 0.0), 2.0), Vector2.ZERO)
