extends GutTest


func test_hand_and_roof_endpoints_at_both_camera_pitches() -> void:
	var strap: DentStrap = DentStrap.new()
	var car: VehicleBody = VehicleBody.new(1, null, Vector2(3, 2), Vector2.DOWN)
	var hand: Vector2 = Vector2(11, 25)
	var old_view: ViewMode = ViewMode.shared()
	var ppm: float = 32.0
	strap.advance(car, 40, 0.0, -1)
	for view: String in ["top", "tilt70", "tilt"]:
		ViewMode.select(view)
		var vm: ViewMode = ViewMode.shared()
		strap.place(hand, ppm, false, vm)
		assert_eq(strap.point(0.0), hand)
		assert_eq(strap.point(1.0), car.pos * ppm + vm.lift_px(1.4))
		assert_almost_eq(strap.width_px(), 10.24, 0.001)
		assert_almost_eq(strap.heading, PI / 2.0, 0.0001)
	ViewMode._shared = old_view


func test_belt_motion_is_tick_based_and_reduced_motion_is_straight() -> void:
	var s: DentStrap = DentStrap.new()
	var car: VehicleBody = VehicleBody.new(1, null, Vector2.RIGHT * 3.0, Vector2.RIGHT)
	s.advance(car, 5, 3.0, -1)
	assert_eq(s.travel_m, 0.0)
	s.advance(car, 7, 3.0, -1)
	assert_almost_eq(s.travel_m, 0.1, 0.0001)
	s.advance(car, 7, 3.0, -1)
	assert_almost_eq(s.travel_m, 0.1, 0.0001)
	s.advance(car, 13, 3.0, -1)
	assert_almost_eq(s.travel_m, 0.07, 0.0001)
	s.place(Vector2.ONE, 32.0, true, ViewMode.shared())
	assert_almost_eq(s.point(0.5), s.hand_px.lerp(s.roof_px, 0.5), Vector2.ONE * 0.0001)
	s.reduced = false
	assert_gt(s.point(0.5).distance_to(s.hand_px.lerp(s.roof_px, 0.5)), 0.01)


func test_slack_holds_last_roof_for_21_ticks_then_frays_back() -> void:
	var s: DentStrap = DentStrap.new()
	var car: VehicleBody = VehicleBody.new(1, null, Vector2(4, 2), Vector2.RIGHT)
	s.advance(car, 10, 0.0, -1)
	s.advance(null, 11, 0.0, -1)
	car.pos = Vector2.ZERO
	s.place(Vector2.ZERO, 32.0, false, ViewMode.shared())
	assert_eq(s.ground_m, Vector2(4, 2))
	assert_eq(s.fray(), 0.0)
	assert_eq(s.point(0.5), s.roof_px * 0.5)
	s.advance(null, 32, 0.0, -1)
	assert_eq(s.fray(), 0.0)
	assert_almost_eq(s.point(0.5).y, s.roof_px.y * 0.5 + 0.65 * 32, 0.001)
	s.advance(null, 35, 0.0, -1)
	assert_almost_eq(s.fray(), 1.0 / 3.0, 0.0001)
	s.advance(null, 40, 0.0, -1)
	assert_true(s.showing())
	s.advance(null, 41, 0.0, -1)
	assert_false(s.showing())
	assert_eq(s.fray(), 1.0)


func test_blast_cuts_the_strap_and_next_seize_starts_fresh() -> void:
	var s: DentStrap = DentStrap.new()
	var car: VehicleBody = VehicleBody.new(1, null, Vector2.ZERO, Vector2.RIGHT)
	assert_false(s.showing())
	s.advance(car, 12, 12.0, -1)
	s.advance(null, 15, 0.0, 14)
	assert_false(s.showing())
	s.advance(car, 20, 3.0, 14)
	assert_true(s.showing())
	assert_eq(s.travel_m, 0.0)
	s.advance(null, 21, 0.0, 14)
	assert_true(s.showing())


func test_heat_colours() -> void:
	var amber: Color = Color("#E9A23B")
	assert_eq(DentStrap.fill_at(0.0), HaulerLook.TEAL)
	assert_eq(DentStrap.fill_at(0.5), HaulerLook.TEAL.lerp(amber, 0.5))
	assert_true(DentStrap.fill_at(1.0).is_equal_approx(amber))
