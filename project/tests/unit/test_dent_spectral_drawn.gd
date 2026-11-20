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
	assert_eq(DentSpectralDrawn.pose(h, jab, false, 0), DentSpectralDrawn.Pose.HIT)
	assert_eq(DentSpectralDrawn.pose(h, jab, false, 9), DentSpectralDrawn.Pose.HIT)
	assert_eq(DentSpectralDrawn.pose(h, jab, false, 10), DentSpectralDrawn.Pose.HOVER)
	assert_eq(DentSpectralDrawn.pose(h, jab, true, -1), DentSpectralDrawn.Pose.STEER)


func test_both_pitches_preserve_the_cell_aspect_and_body_height() -> void:
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
		assert_true(cards.sprite.is_visible_in_tree())
		assert_eq(cards.sprite.hframes, 4)
		assert_eq(cards.sprite.vframes, 5)
		assert_eq(
			cards.sprite.texture.resource_path,
			GhostDrawn.path_of(ViewMode.shared().art, "dent", "sp_fly")
		)
		assert_eq(cards.sprite.frame_coords, Vector2i(0, 2))
		assert_true(cards.sprite.flip_h)
		var screen: Vector2 = cards.sprite.scale * ViewMode.shared().zoom_of(1.0)
		assert_almost_eq(screen.x, screen.y, 0.0001)
		assert_almost_eq(screen.y * (212.0 if p55 else 223.0), 1.45 * SimConst.PX_PER_M, 0.001)
		cards.show_pose(drawn, 0.0, DentSpectralDrawn.Pose.STEER)
		assert_eq(
			cards.sprite.texture.resource_path,
			GhostDrawn.path_of(ViewMode.shared().art, "dent", "sp_act")
		)
		assert_eq(cards.sprite.frame_coords, Vector2i(2, 2))
		assert_false(cards.sprite.flip_h)
		cards.show_pose(drawn, 0.0, DentSpectralDrawn.Pose.COCK)
		assert_eq(cards.sprite.frame_coords, Vector2i(0, 2))
		assert_eq(cards.sprite.texture.resource_path.get_file(), "dent_sp_act.png")
	ViewMode.select(old_view)


func test_dive_tips_from_the_belt_and_carries_the_rim_with_the_card() -> void:
	var old_view: String = ViewMode.shared().id
	ViewMode.select("tilt70")
	var drawn: GhostDrawn = GhostDrawn.new("dent", 1.8, 163.0, 176.5)
	drawn.flight = GhostFlight.make(&"dent")
	add_child_autofree(drawn.flight)
	var cards: DentSpectralDrawn = DentSpectralDrawn.new()
	drawn.flight.mount(cards)
	drawn.flight.step(Vector2.ZERO, 0.0, 1)
	cards.show_pose(drawn, 0.0, DentSpectralDrawn.Pose.HOVER)
	var rest_scale: Vector2 = cards.sprite.scale
	var rest_height: float = 223.0 * rest_scale.y * ViewMode.shared().ground_k()
	assert_almost_eq(rest_height / SimConst.PX_PER_M, 1.45, 0.001)
	drawn.flight.step(Vector2.RIGHT * 7.0 * SimClock.TICK_DT * SimConst.PX_PER_M, 0.0, 1)
	for facing: float in [0.0, PI]:
		cards.show_pose(drawn, facing, DentSpectralDrawn.Pose.DIVE)
		var body: Sprite2D = cards.sprite
		var rim: Sprite2D = cards._rim
		assert_almost_eq(body.rotation, drawn.flight.hover.lean * cos(facing), 0.001)
		assert_lt(body.scale.y, rest_scale.y)
		assert_eq(body.frame_coords, Vector2i(1, 2))
		assert_eq(rim.texture, body.texture)
		assert_eq(rim.frame, body.frame)
		assert_eq(rim.flip_h, body.flip_h)
		assert_false(rim.centered)
		assert_eq(rim.offset, body.offset)
		var cell: Vector2 = body.texture.get_size() / Vector2(4, 5)
		var belt: Vector2 = body.offset + cell * Vector2(0.5, 0.82)
		assert_almost_eq(belt, Vector2.ZERO, Vector2.ONE * 0.001)
		var mid: Vector2 = body.offset + cell * 0.5
		assert_almost_eq(body.to_global(mid), rim.to_global(mid), Vector2.ONE * 0.01)
		assert_gt(rim.scale.x, body.scale.x)
	ViewMode.select(old_view)
