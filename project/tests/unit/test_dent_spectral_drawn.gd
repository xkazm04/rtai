extends GutTest


func test_flight_and_turn_cells() -> void:
	var h: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	h.reset(Vector2.ZERO, 0.0)
	assert_eq(DentSpectralDrawn.pose(h, null, false, -1), DentSpectralDrawn.Pose.HOVER)
	h.step(Vector2.RIGHT * 7.0 * SimClock.TICK_DT * SimConst.PX_PER_M, 0.0, 1)
	assert_eq(DentSpectralDrawn.pose(h, null, false, -1), DentSpectralDrawn.Pose.DIVE)
	for side: float in [1.0, -1.0]:
		h.reset(Vector2.ZERO, 0.0)
		h.step(Vector2.ZERO, side * PI / 4.0, 1)
		assert_eq(DentSpectralDrawn.pose(h, null, false, -1), DentSpectralDrawn.Pose.SWING)
		assert_eq(DentSpectralDrawn.swing_flip(0, h.yaw_rate_dps), side < 0.0)
		assert_eq(DentSpectralDrawn.swing_flip(4, h.yaw_rate_dps), side > 0.0)


func test_attack_and_hurt_windows() -> void:
	var h: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	var jab: DentJab = DentJab.new()
	jab.due_tick = 5
	assert_eq(DentSpectralDrawn.pose(h, jab, false, -1), DentSpectralDrawn.Pose.COCK)
	jab.due_tick = -1
	jab.swung_step = 5
	jab.steps = 5
	assert_eq(DentSpectralDrawn.pose(h, jab, false, -1), DentSpectralDrawn.Pose.JAB)
	jab.steps += GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS - 1
	assert_eq(DentSpectralDrawn.pose(h, jab, false, -1), DentSpectralDrawn.Pose.JAB)
	jab.steps += 1
	assert_eq(DentSpectralDrawn.pose(h, jab, false, 9), DentSpectralDrawn.Pose.HIT)
	assert_eq(DentSpectralDrawn.pose(h, jab, false, 10), DentSpectralDrawn.Pose.HOVER)
	assert_eq(DentSpectralDrawn.pose(h, jab, true, -1), DentSpectralDrawn.Pose.STEER)


func test_both_pitches_show_the_four_column_sheets_at_head_scale() -> void:
	var old_view: String = ViewMode.shared().id
	var drawn: GhostDrawn = GhostDrawn.new("dent", 1.8, 163.0, 176.5)
	drawn.flight = GhostFlight.make(&"dent")
	add_child_autofree(drawn.flight)
	var cards: DentSpectralDrawn = DentSpectralDrawn.new()
	drawn.flight.mount(cards)
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		var p55: bool = view == "tilt"
		cards.show_pose(drawn, PI, DentSpectralDrawn.Pose.HOVER)
		assert_eq(
			cards.sprite.texture.resource_path,
			GhostDrawn.path_of(ViewMode.shared().art, "dent", "sp_fly")
		)
		assert_eq(cards.sprite.frame_coords, Vector2i(0, 2))
		assert_true(cards.sprite.flip_h)
		var width: float = cards.sprite.scale.x * (77.0 if p55 else 90.0)
		assert_almost_eq(width, (70.0 if p55 else 77.0) * 1.8 * SimConst.PX_PER_M / 176.5, 0.01)
		cards.show_pose(drawn, 0.0, DentSpectralDrawn.Pose.STEER)
		assert_eq(
			cards.sprite.texture.resource_path,
			GhostDrawn.path_of(ViewMode.shared().art, "dent", "sp_act")
		)
		assert_eq(cards.sprite.frame_coords, Vector2i(2, 2))
		assert_false(cards.sprite.flip_h)
	ViewMode.select(old_view)
