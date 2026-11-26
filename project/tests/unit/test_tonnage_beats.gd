extends GutTest
## n31 ghost 03: Tonnage's drop ground. The telegraph's crack front reaches the deploy's radius
## exactly on the dump tick, the crater outlives the ghost by its hold and fade.

const P: int = 100
const D: int = 127


func _marks() -> TonnageDropMarks:
	return TonnageDropMarks.new(Vector2.ZERO, P, D, 6.5)


func test_front_starts_at_the_feet_after_the_landing() -> void:
	var m: TonnageDropMarks = _marks()
	assert_eq(m.reach_m(P), 0.0)
	assert_eq(m.reach_m(P + TonnageDropMarks.LAND_TICKS), 0.0)


func test_front_reaches_the_radius_exactly_on_the_dump_tick() -> void:
	var m: TonnageDropMarks = _marks()
	assert_lt(m.reach_m(D - 1), 6.5)
	assert_almost_eq(m.reach_m(D), 6.5, 0.0001)
	assert_almost_eq(m.reach_m(D + 90), 6.5, 0.0001)


func test_front_only_grows_over_the_charge() -> void:
	var m: TonnageDropMarks = _marks()
	var last: float = -1.0
	for t: int in range(P, D + 1):
		assert_true(m.reach_m(t) >= last, "tick %d" % t)
		last = m.reach_m(t)


func test_crater_holds_two_seconds_then_fades_one() -> void:
	var m: TonnageDropMarks = _marks()
	assert_eq(m.ground_alpha(D + 120), 1.0)
	assert_almost_eq(m.ground_alpha(D + 150), 0.5, 0.0001)
	assert_true(m.live(D + 179))
	assert_false(m.live(D + 180))


func test_the_crack_art_rim_meets_the_radius() -> void:
	# The art's tips sit on CRACK_RIM_PX; drawn at radius_m * ppm / CRACK_RIM_PX the rim is radius_m.
	var tex_r: float = TonnageDropMarks.CRACK.get_width() * 0.5
	assert_between(TonnageDropMarks.CRACK_RIM_PX, tex_r * 0.85, tex_r)


func test_body_beats_follow_the_brief_windows() -> void:
	var c: int = D - P
	var want: Dictionary[int, int] = {
		0: -1,
		5: -1,
		6: TonnageDropBeats.Col.SQUASH,
		9: TonnageDropBeats.Col.SQUASH,
		10: TonnageDropBeats.Col.GATHER,
		18: TonnageDropBeats.Col.GATHER,
		19: TonnageDropBeats.Col.PEAK,
		26: TonnageDropBeats.Col.PEAK,
	}
	for since: int in want:
		assert_eq(TonnageDropBeats.col(since, c, -1), want[since], "P+%d" % since)
	assert_eq(TonnageDropBeats.col(c, c, 0), TonnageDropBeats.Col.SLAM)
	assert_eq(TonnageDropBeats.col(c + 4, c, 4), TonnageDropBeats.Col.SLAM)
	assert_eq(TonnageDropBeats.col(c + 5, c, 5), -1)
	assert_eq(TonnageDropBeats.col(c + 14, c, 14), -1)
	assert_eq(TonnageDropBeats.col(c + 15, c, 15), TonnageDropBeats.Col.AWAY)


func test_he_falls_onto_the_spot_and_rises_after_the_lift() -> void:
	assert_eq(TonnageDropBeats.lift_m(0, -27), TonnageDropBeats.DROP_FROM_M)
	assert_eq(TonnageDropBeats.lift_m(6, -21), 0.0)
	assert_eq(TonnageDropBeats.lift_m(40, 13), 0.0)
	assert_eq(TonnageDropBeats.lift_m(80, 53), TonnageDropBeats.AWAY_RISE_M)


func test_charge_winds_up_to_full_on_the_dump() -> void:
	assert_eq(TonnageDropBeats.windup(9, 27, -18), 0.0)
	assert_gt(TonnageDropBeats.windup(10, 27, -17), 0.0)
	assert_eq(TonnageDropBeats.windup(26, 27, -1), 1.0)
	assert_eq(TonnageDropBeats.windup(27, 27, 0), 0.0)
