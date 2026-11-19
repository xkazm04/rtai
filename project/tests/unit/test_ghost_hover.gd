extends GutTest


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
	var anchor: Vector2 = mark + (row.tail.anchor_m * SimConst.PX_PER_M).rotated(PI)
	assert_eq(flight.tail._chain[0], anchor)
	var length_px: float = row.tail.length_m * SimConst.PX_PER_M
	assert_almost_eq(flight.tail._chain[-1].distance_to(anchor), length_px, 0.001)


func _same(a: GhostHover, b: GhostHover) -> void:
	assert_almost_eq(a.lift_m, b.lift_m, 0.00001)
	assert_almost_eq(a.bank, b.bank, 0.00001)
	assert_almost_eq(a.lean, b.lean, 0.00001)
	assert_almost_eq(a.lag_px, b.lag_px, Vector2.ONE * 0.00001)
	assert_almost_eq(a.speed_mps, b.speed_mps, 0.00001)
	assert_almost_eq(a.yaw_rate_dps, b.yaw_rate_dps, 0.001)
