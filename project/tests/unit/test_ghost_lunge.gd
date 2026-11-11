extends GutTest


func test_no_strike_no_lean() -> void:
	var l: GhostLunge = GhostLunge.new()
	assert_eq(l.lean(10, -1, false, 0.0, "kerf"), 0.0)
	var past: int = GhostDrawn.CUT_TICKS + GhostDrawn.FOLLOW_TICKS
	assert_eq(l.lean(10, past, false, 0.0, "kerf"), 0.0)


func test_strike_leans_toward_the_facing() -> void:
	var l: GhostLunge = GhostLunge.new()
	var full: float = deg_to_rad(GhostLunge.DEFAULT.x)
	assert_almost_eq(l.lean(10, 2, false, 0.0, "kerf"), full, 1e-5)  # facing right: clockwise
	assert_almost_eq(l.lean(10, 2, false, PI, "kerf"), -full, 1e-5)
	assert_almost_eq(l.lean(10, 2, false, PI / 2.0, "kerf"), 0.0, 1e-5)


func test_strike_eases_out_over_the_follow_through() -> void:
	var l: GhostLunge = GhostLunge.new()
	var cut: int = GhostDrawn.CUT_TICKS
	var a: float = l.lean(0, cut, false, 0.0, "dent")
	var b: float = l.lean(0, cut + 5, false, 0.0, "dent")
	assert_gt(a, b)
	assert_gt(b, 0.0)
	assert_lt(GhostLunge.strike_k(0), GhostLunge.strike_k(1))


func test_windup_leans_back_and_ramps() -> void:
	var l: GhostLunge = GhostLunge.new()
	var first: float = l.lean(100, -1, true, 0.0, "tonnage")
	var held: float = l.lean(100 + GhostLunge.WIND_RAMP, -1, true, 0.0, "tonnage")
	assert_lt(held, 0.0)  # facing right: counter-clockwise, away from the target
	assert_lt(held, first)
	assert_almost_eq(held, -deg_to_rad(GhostLunge.of("tonnage").y), 1e-5)


func test_windup_restarts_its_ramp_after_the_strike() -> void:
	var l: GhostLunge = GhostLunge.new()
	@warning_ignore("return_value_discarded")
	l.lean(0, -1, true, 0.0, "dent")
	@warning_ignore("return_value_discarded")
	l.lean(10, 0, false, 0.0, "dent")
	var again: float = l.lean(50, -1, true, 0.0, "dent")
	assert_almost_eq(again, -deg_to_rad(GhostLunge.DEFAULT.y) / float(GhostLunge.WIND_RAMP), 1e-5)


func test_ohm_leans_into_his_bolt_more_than_the_default() -> void:
	assert_gt(GhostLunge.of("ohm").x, GhostLunge.DEFAULT.x)
	assert_lt(GhostLunge.of("tonnage").x, GhostLunge.DEFAULT.x)


func test_reach_only_along_screen_y() -> void:
	assert_eq(GhostLunge.reach(2, 0.0, "kerf"), Vector2.ZERO)
	var down: Vector2 = GhostLunge.reach(2, PI / 2.0, "kerf")
	assert_almost_eq(down.y, GhostLunge.DEFAULT.z, 1e-5)
	assert_almost_eq(down.x, 0.0, 1e-5)
	assert_eq(GhostLunge.reach(-1, PI / 2.0, "kerf"), Vector2.ZERO)
