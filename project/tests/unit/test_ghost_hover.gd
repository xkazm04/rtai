extends GutTest

var _saved_view: ViewMode


func before_each() -> void:
	_saved_view = ViewMode._shared


func after_each() -> void:
	ViewMode._shared = _saved_view


func test_every_form_has_one_typed_hover_row() -> void:
	var table: DataTable = DataTable.open(GhostHoverRow.PATH, GhostHoverRow.SCHEMA)
	var forms: GhostFormTable = GhostFormTable.load_default()
	assert_true(table.ok(), str(table.errors()))
	assert_eq(table.array(table.raw, "rows").size(), forms.order.size())
	for id: StringName in forms.order:
		var row: GhostHoverRow = GhostHoverRow.of(id)
		assert_not_null(row, str(id))
		assert_eq(row.id, id)
		assert_gt(row.bob_ticks, 0)
		assert_gt(row.tail.segments, 1)
		assert_gt(row.shadow.radius_m, 0.0)


func test_zero_ticks_preserve_every_output_and_next_step() -> void:
	var a: GhostHover = GhostHover.new(GhostHoverRow.of(&"ohm"))
	var b: GhostHover = GhostHover.new(GhostHoverRow.of(&"ohm"))
	for h: GhostHover in [a, b]:
		h.step(Vector2.ONE, 0.3, 1)
	a.step(Vector2(400.0, 15.0), -2.0, 0)
	_same(a, b)
	for h: GhostHover in [a, b]:
		h.step(Vector2(4.0, 6.0), 0.7, 1)
	_same(a, b)


func test_straight_motion_has_speed_lean_and_lag_without_roll() -> void:
	var row: GhostHoverRow = GhostHoverRow.of(&"kerf")
	var h: GhostHover = GhostHover.new(row)
	h.step(Vector2.ZERO, 0.0, 1)
	h.step(Vector2.RIGHT * row.top_mps * SimConst.PX_PER_M, 0.0, 60)
	assert_almost_eq(h.speed_mps, row.top_mps, 0.001)
	assert_almost_eq(h.lean, deg_to_rad(row.lean_deg), 0.0001)
	assert_lt(h.lag_px.x, 0.0)
	assert_eq(h.bank, 0.0)


func test_constant_left_turn_banks_left_within_form_limit() -> void:
	var row: GhostHoverRow = GhostHoverRow.of(&"kerf")
	var h: GhostHover = GhostHover.new(row)
	for tick: int in 60:
		h.step(Vector2.ZERO, wrapf(-0.1 * tick, -PI, PI), 1)
	assert_almost_eq(h.yaw_rate_dps, -rad_to_deg(0.1) / SimClock.TICK_DT, 0.01)
	assert_lt(h.bank, 0.0)
	assert_lte(absf(h.bank), deg_to_rad(row.bank_deg))


func test_bob_repeats_after_a_period_at_rest() -> void:
	for id: StringName in GhostFormTable.load_default().order:
		var row: GhostHoverRow = GhostHoverRow.of(id)
		var h: GhostHover = GhostHover.new(row)
		h.step(Vector2.ONE, 0.7, 7)
		var before: float = h.lift_m
		assert_ne(before, row.height_m)
		h.step(Vector2.ONE, 0.7, row.bob_ticks)
		assert_almost_eq(h.lift_m, before, 0.00001, str(id))


func test_batch_matches_three_intermediate_tick_poses() -> void:
	var a: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	var b: GhostHover = GhostHover.new(GhostHoverRow.of(&"dent"))
	for h: GhostHover in [a, b]:
		h.step(Vector2.ZERO, 3.0, 1)
	a.step(Vector2(9.0, -6.0), wrapf(3.3, -PI, PI), 3)
	for tick: int in range(1, 4):
		b.step(Vector2(3.0, -2.0) * tick, 3.0 + 0.1 * tick, 1)
	_same(a, b)


func test_reentering_on_a_paused_frame_places_the_whole_form_at_its_new_mark() -> void:
	var row: GhostHoverRow = GhostHoverRow.of(&"kerf")
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(row.id))
	var body: Node2D = Node2D.new()
	flight.mount(body)
	flight.step(Vector2.ZERO, 0.0, 1)
	flight.step(Vector2(12.0, 0.0), 0.3, 3)
	assert_gt(flight.hover.speed_mps, 0.0)
	var lift: float = flight.hover.lift_m
	var mark: Vector2 = Vector2(800.0, -1200.0)
	flight.hide()
	flight.step(mark, PI, 15)
	assert_false(body.is_visible_in_tree())
	assert_eq(flight.hover.lift_m, lift, "a hidden form does no flight work")
	flight.show()
	flight.step(mark, PI, 0)
	assert_true(body.is_visible_in_tree())
	assert_eq(flight.shadow.position, mark)
	assert_eq(flight.hover.lag_px, Vector2.ZERO)
	assert_eq(flight.hover.speed_mps, 0.0)
	assert_eq(body.global_position, mark + ViewMode.shared().lift_px(row.height_m))
	var local: Vector2 = row.tail.anchor_m * SimConst.PX_PER_M * flight.body_scale()
	var anchor: Vector2 = mark + local.rotated(PI)
	assert_eq(flight.tail._chain[0], anchor)
	var length_px: float = row.tail.length_m * SimConst.PX_PER_M
	assert_almost_eq(flight.tail._chain[-1].distance_to(anchor), length_px, 0.001)


func test_a_banked_body_squashes_in_its_facing_frame_and_keeps_its_tail_attached() -> void:
	var row: GhostHoverRow = GhostHoverRow.of(&"kerf")
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(row.id))
	var body: Node2D = Node2D.new()
	flight.mount(body)
	for view: String in ["top", "tilt55", "tilt70"]:
		ViewMode.select(view)
		flight.step(Vector2.ZERO, 0.0, 1)
		for i: int in range(1, 31):
			body.rotation = i * PI / 60.0
			flight.step(Vector2(i, i), body.rotation, 1)
		var pose: Transform2D = body.global_transform
		var scale_k: Vector2 = flight.body_scale()
		assert_gt(flight.hover.bank, 0.1, view)
		assert_almost_eq(pose.x.length(), scale_k.x, 0.0001, view)
		assert_almost_eq(pose.y.length(), scale_k.y, 0.0001, view)
		assert_almost_eq(pose.x.angle(), body.rotation + flight.body_rotation(), 0.0001, view)
		var lifted: Vector2 = ViewMode.shared().lift_px(flight.hover.lift_m)
		var root: Vector2 = pose * (row.tail.anchor_m * SimConst.PX_PER_M) - lifted
		assert_almost_eq(flight.tail._chain[0], root, Vector2.ONE * 0.0001, view)


func _same(a: GhostHover, b: GhostHover) -> void:
	assert_almost_eq(a.lift_m, b.lift_m, 0.00001)
	assert_almost_eq(a.bank, b.bank, 0.00001)
	assert_almost_eq(a.lean, b.lean, 0.00001)
	assert_almost_eq(a.lag_px, b.lag_px, Vector2.ONE * 0.00001)
	assert_almost_eq(a.speed_mps, b.speed_mps, 0.00001)
	assert_almost_eq(a.yaw_rate_dps, b.yaw_rate_dps, 0.001)


func test_hover_impulse_settles_above_and_below_the_rest_height() -> void:
	var data: DataTable = DataTable.open(GhostHoverRow.PATH, GhostHoverRow.SCHEMA)
	var first: Dictionary = data.array(data.raw, "rows")[0]
	var row: GhostHoverRow = GhostHoverRow.new(data, first)
	row.bob_m = 0.0
	row.start_lift_m = 0.3
	row.sway_m = 0.0
	var motion: GhostHover = GhostHover.new(row)
	motion.reset(Vector2.ZERO, 0.0)
	var dx: Vector2 = Vector2.RIGHT * row.top_mps * SimConst.PX_PER_M * SimClock.TICK_DT
	motion.step(dx, 0.0, 1)
	assert_almost_eq(motion.lift_m, row.height_m + 0.3, 0.00001)
	motion.step(dx * 61.0, 0.0, 60)
	assert_almost_eq(motion.lift_m, row.height_m + 0.3 * pow(0.92, 60), 0.00001)
	motion.step(dx * 61.0, 0.0, 1)
	assert_lt(motion.lift_m, row.height_m)
	assert_eq(motion.tick, 62)
	motion.reset(dx, PI)
	assert_eq(motion.tick, 0)
	assert_eq(motion.lift_m, row.height_m)
	assert_eq(motion.lag_px, Vector2.ZERO)


func test_low_curl_stops_at_ground_and_height_never_moves_the_overhead_centreline() -> void:
	var data: DataTable = DataTable.open(GhostHoverRow.PATH, GhostHoverRow.SCHEMA)
	var source: Dictionary = data.array(data.raw, "rows")[0]
	var row: GhostHoverRow = GhostHoverRow.new(data, source)
	row.tail.curl_m = 0.0
	var tail: GhostTail = add_child_autofree(GhostTail.new(row.tail))
	for rise: float in [0.0, -2.0]:
		row.tail.rise_m = rise
		for view: String in ["top", "tilt70"]:
			ViewMode.select(view)
			tail.reset(Vector2.ZERO, 0.0, 0.6)
			var points: PackedVector2Array = tail.points()
			for i: int in points.size():
				var k: float = float(i) / row.tail.segments
				var h: float = maxf(0.0, 0.6 * (1.0 - k) + rise * sin(k * PI))
				var projected: Vector2 = tail._chain[i] + ViewMode.shared().lift_px(h)
				assert_almost_eq(points[i], projected, Vector2.ONE * 0.001)
			assert_almost_eq(points[-1], tail._chain[-1], Vector2.ONE * 0.001)


func test_stretched_kerf_wake_bends_either_side_of_its_axis_at_cruise() -> void:
	ViewMode.select("top")
	var row: GhostHoverRow = GhostHoverRow.of(&"kerf")
	var tail: GhostTail = add_child_autofree(GhostTail.new(row.tail))
	tail.reset(Vector2.ZERO, 0.0, 0.5)
	tail.step(Vector2.ZERO, 0.0, row.top_mps, 1.0, 1)
	var left: float = 0.0
	var right: float = 0.0
	for point: Vector2 in tail.points():
		left = minf(left, point.y)
		right = maxf(right, point.y)
	assert_lt(left, -2.0)
	assert_gt(right, 2.0)
