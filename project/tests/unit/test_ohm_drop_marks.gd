extends GutTest
## n31 ghost 12: Ohm's drop ground (OhmDropMarks): the creep telegraph reaches radius_m exactly
## on the discharge tick, the arc ring runs out to radius_m, the scorch holds 2 s and fades 1 s.

const PRESS: int = 100
const DUMP: int = 118
const RADIUS: float = 5.0


func _marks() -> OhmDropMarks:
	return OhmDropMarks.new(Vector2(40, 80), PRESS, DUMP, RADIUS)


func test_the_creep_front_grows_from_his_feet_to_the_radius_on_the_discharge_tick() -> void:
	var m: OhmDropMarks = _marks()
	assert_eq(m.reach_m(PRESS), 0.0)
	var last: float = 0.0
	for tick: int in range(PRESS + 1, DUMP):
		var r: float = m.reach_m(tick)
		assert_gt(r, last, "tick %d" % tick)
		assert_lt(r, RADIUS, "tick %d: the front is short of the rim until D" % tick)
		last = r
	assert_eq(m.reach_m(DUMP), RADIUS)
	assert_eq(m.reach_m(DUMP + 50), RADIUS)


func test_the_arc_ring_runs_out_to_the_radius_and_stops_there() -> void:
	var m: OhmDropMarks = _marks()
	assert_gt(m.arc_m(DUMP), 0.0)
	assert_lt(m.arc_m(DUMP), RADIUS)
	assert_almost_eq(m.arc_m(DUMP + OhmDropMarks.ARC_REACH_TICKS - 1), RADIUS, 0.0001)
	assert_almost_eq(m.arc_m(DUMP + 30), RADIUS, 0.0001)


func test_the_scorch_shows_from_the_discharge_holds_two_seconds_and_fades_one() -> void:
	var m: OhmDropMarks = _marks()
	assert_eq(m.ground_alpha(DUMP - 1), 0.0, "nothing burnt during the charge")
	assert_gt(m.ground_alpha(DUMP), 0.0)
	assert_eq(m.ground_alpha(DUMP + OhmDropMarks.SCORCH_IN_TICKS), 1.0)
	assert_eq(m.ground_alpha(DUMP + 120), 1.0)
	assert_almost_eq(m.ground_alpha(DUMP + 150), 0.5, 0.0001)
	assert_true(m.live(DUMP + 179))
	assert_false(m.live(DUMP + 180))


func test_the_ground_art_is_amber_ink_and_soot_never_teal() -> void:
	for tex: Texture2D in [OhmDropMarks.CREEP, OhmDropMarks.ARC, OhmDropMarks.SCORCH]:
		var img: Image = tex.get_image()
		var teal: int = 0
		for y: int in range(0, img.get_height(), 8):
			for x: int in range(0, img.get_width(), 8):
				var c: Color = img.get_pixel(x, y)
				if c.a > 0.5 and c.g > c.r + 0.15 and c.b > c.r + 0.15:
					teal += 1
		assert_eq(teal, 0, tex.resource_path)
