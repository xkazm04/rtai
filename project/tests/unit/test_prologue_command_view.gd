extends GutTest
## What the commander's marker, the card switch, the cues and the glyphs do, read through
## the pure helpers PrologueCommandView draws from.

const PP: float = PrologueCommandView.PP
const R: float = PrologueCommandView.MARK_RADIUS


func test_marker_scale_keeps_the_close_up_and_holds_the_play_camera_disc_at_1_6_m() -> void:
	assert_eq(PrologueCommandView.marker_scale(2.0), 1.0, "64 px/m keeps the authored disc")
	assert_eq(PrologueCommandView.marker_scale(8.0), 1.0)
	var last: float = INF
	for zoom: float in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0]:
		var k: float = PrologueCommandView.marker_scale(zoom)
		assert_gte(k, 1.0)
		assert_lte(k, last, "the disc never grows as the camera comes closer")
		assert_gte(2.0 * R * k * zoom / PP, 1.6 - 0.0001, "%.2f zoom: disc under 1.6 m" % zoom)
		last = k
	assert_gt(PrologueCommandView.marker_scale(1.0), 1.0, "the 32 px/m play camera enlarges it")


func test_the_dress_shows_only_with_the_bar_and_without_a_mulroney_card() -> void:
	assert_true(PrologueCommandView.dress_shown(true, false))
	assert_false(PrologueCommandView.dress_shown(true, true), "the card replaces the figure")
	assert_false(PrologueCommandView.dress_shown(false, false), "no bar, no figure")
	assert_false(PrologueCommandView.dress_shown(false, true))


func test_one_report_per_discharge_and_one_rack_per_stroke() -> void:
	assert_eq(PrologueCommandView.sound_cues(-1.0, 100, -1, -1), [], "no cycle, no cue")
	assert_eq(PrologueCommandView.sound_cues(-0.5, 100, 7, 7), [])
	assert_eq(PrologueCommandView.sound_cues(0.0, 100, -1, -1), [&"shotgun"], "the discharge tick")
	assert_eq(PrologueCommandView.sound_cues(0.2, 100, 100, -1), [], "the report is not repeated")
	assert_eq(
		PrologueCommandView.sound_cues(0.49, 100, 100, -1), [], "the slide has not racked yet"
	)
	assert_eq(
		PrologueCommandView.sound_cues(0.5, 100, 100, -1), [&"shotgun_pump"], "half way racks once"
	)
	assert_eq(PrologueCommandView.sound_cues(0.9, 100, 100, 100), [], "and only once")
	assert_eq(
		PrologueCommandView.sound_cues(0.6, 100, -1, -1),
		[&"shotgun", &"shotgun_pump"],
		"a late first look"
	)
	assert_eq(
		PrologueCommandView.sound_cues(0.0, 200, 100, 100),
		[&"shotgun"],
		"the next discharge sounds again"
	)
	assert_eq(
		PrologueCommandView.sound_cues(0.7, 200, 200, 100), [&"shotgun_pump"], "and racks again"
	)


func test_the_slide_rides_back_to_mid_cycle_and_returns_inside_the_rail() -> void:
	var front: Rect2 = PrologueCommandView.slide_rect(0.0)
	var back: Rect2 = PrologueCommandView.slide_rect(0.5)
	assert_gt(front.position.x, back.position.x, "pull 0 is forward, pull 1 is back")
	assert_almost_eq(PrologueCommandView.slide_rect(1.0).position.x, front.position.x, 0.0001)
	assert_almost_eq(
		PrologueCommandView.slide_rect(0.25).position.x,
		PrologueCommandView.slide_rect(0.75).position.x,
		0.0001
	)
	var x: float = front.position.x
	for step: int in range(1, 11):
		var next: float = PrologueCommandView.slide_rect(step * 0.05).position.x
		assert_lte(next, x + 0.0001, "the slide only moves back until mid cycle")
		x = next
	for pump: float in [0.0, 0.3, 0.5, 0.8, 1.0]:
		var slide: Rect2 = PrologueCommandView.slide_rect(pump)
		assert_gte(slide.position.x, -11.0, "inside the 22 px rail")
		assert_lte(slide.end.x, 11.0)
		assert_eq(slide.size, front.size, "the slide keeps its size")
		assert_eq(slide.position.y, front.position.y)


func test_the_ring_left_to_run_shrinks_from_a_full_turn_to_nothing() -> void:
	var start: float = PrologueCommandView.arc_angle(0.0)
	assert_almost_eq(start, -PI / 2.0, 0.0001, "twelve o'clock")
	assert_almost_eq(PrologueCommandView.arc_end(0.0) - start, TAU, 0.0001, "a full ring at pump 0")
	assert_almost_eq(PrologueCommandView.arc_end(0.5) - start, PI, 0.0001, "half left at half")
	assert_almost_eq(PrologueCommandView.arc_end(1.0) - start, 0.0, 0.0001, "gone at pump 1")
	assert_almost_eq(
		PrologueCommandView.arc_angle(0.25), 0.0, 0.0001, "a quarter turn is three o'clock"
	)


func test_ordering_beats_pumping_and_an_open_window_alone_shows_the_chevrons() -> void:
	assert_eq(PrologueCommandView.marker_kind(false, false, false), &"none")
	assert_eq(PrologueCommandView.marker_kind(false, true, false), &"open")
	assert_eq(PrologueCommandView.marker_kind(false, false, true), &"pump")
	assert_eq(
		PrologueCommandView.marker_kind(false, true, true),
		&"pump",
		"pumping outranks the open window"
	)
	assert_eq(PrologueCommandView.marker_kind(true, false, false), &"order")
	assert_eq(PrologueCommandView.marker_kind(true, true, false), &"order")
	assert_eq(
		PrologueCommandView.marker_kind(true, false, true), &"order", "ordering outranks pumping"
	)
	assert_eq(PrologueCommandView.marker_kind(true, true, true), &"order")


func test_the_disc_grows_upward_off_a_neck_two_metres_over_the_commander() -> void:
	var boss: Vector2 = Vector2(5.0, 7.0)
	var neck: Vector2 = PrologueCommandView.neck_of(boss)
	assert_almost_eq(neck.x, boss.x * PP, 0.0001, "straight over him")
	assert_almost_eq((boss.y * PP) - neck.y, 2.1 * PP, 0.0001, "2.1 m up")
	assert_eq(PrologueCommandView.disc_center(neck, 1.0), neck, "close up: the disc is on the neck")
	for k: float in [1.0, 1.4, 2.0]:
		var at: Vector2 = PrologueCommandView.disc_center(neck, k)
		assert_almost_eq(at.x, neck.x, 0.0001)
		assert_almost_eq(
			at.y + R * k, neck.y + R, 0.0001, "the bottom edge stays put at k %.1f" % k
		)
	var stem: PackedVector2Array = PrologueCommandView.stem_ends(neck)
	assert_eq(stem[0].x, neck.x)
	assert_eq(stem[1].x, neck.x)
	assert_gt(stem[0].y, neck.y, "the tail points down at him")
	assert_gt(stem[1].y, stem[0].y)
	assert_between(R - (stem[0].y - neck.y), 1.5, 2.5, "it laps the rim by about 2 px")
	assert_between(stem[1].y - stem[0].y, 11.0, 13.0, "a 12 px tail")
	assert_gt(stem[1].y - neck.y, R, "and ends outside it")


func test_a_braced_shield_stands_ahead_and_a_lowered_one_hangs_at_the_side() -> void:
	var at: Vector2 = Vector2(100.0, 50.0)
	for facing: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2(1, -1).normalized()]:
		var up: Transform2D = PrologueCommandView.shield_pose(at, facing, true)
		var down: Transform2D = PrologueCommandView.shield_pose(at, facing, false)
		var ahead: Vector2 = up.origin - at
		var aside: Vector2 = down.origin - at
		assert_almost_eq(ahead.dot(facing), ahead.length(), 0.001, "braced: straight ahead")
		assert_between(ahead.length() / PP, 0.3, 0.6)
		assert_almost_eq(aside.dot(facing), 0.0, 0.001, "lowered: square to the facing")
		assert_between(aside.length() / PP, 0.3, 0.5)
		assert_gt(aside.dot(facing.orthogonal()), 0.0, "on the holder's right-hand side")
	var lean_right: float = PrologueCommandView.shield_pose(at, Vector2.RIGHT, true).get_rotation()
	var lean_left: float = PrologueCommandView.shield_pose(at, Vector2.LEFT, true).get_rotation()
	assert_gt(lean_right, 0.0)
	assert_almost_eq(lean_left, -lean_right, 0.0001, "the lean mirrors with the facing")
	var tilt_right: float = PrologueCommandView.shield_pose(at, Vector2.RIGHT, false).get_rotation()
	assert_gt(tilt_right, lean_right, "a lowered shield tilts further")


func test_a_lowered_shield_is_smaller_and_the_height_follows_the_ground_squash() -> void:
	var braced: Vector2 = PrologueCommandView.shield_size_m(true, 1.0)
	var lowered: Vector2 = PrologueCommandView.shield_size_m(false, 1.0)
	assert_between(braced.x, 0.5, 1.5, "about a metre wide")
	assert_lt(lowered.x, braced.x)
	assert_lt(lowered.y, braced.y)
	var squashed: Vector2 = PrologueCommandView.shield_size_m(true, 2.0)
	assert_eq(squashed.x, braced.x, "width is untouched by the ground squash")
	assert_almost_eq(squashed.y, braced.y * 0.5, 0.0001, "height divides by the ground factor")


func test_the_slung_rifle_lies_a_metre_along_the_facing_axis() -> void:
	var rifle: Rect2 = PrologueCommandView.rifle_rect()
	assert_eq(rifle.position.x, 0.0, "from the holder outward")
	assert_almost_eq(rifle.size.x, PP, 0.0001, "a metre long")
	assert_almost_eq(rifle.get_center().y, 0.0, 0.0001, "centred on the axis")
	assert_lt(rifle.size.y, rifle.size.x * 0.5, "a thin slung gun, not a block")
	assert_gt(rifle.size.y, 0.0)


func test_the_order_ring_fills_from_the_issuing_tick_to_the_due_tick() -> void:
	assert_almost_eq(
		PrologueCommandView.order_progress(100, 100, 130),
		1.0 / 30.0,
		0.0001,
		"the issuing tick counts"
	)
	assert_almost_eq(PrologueCommandView.order_progress(114, 100, 130), 0.5, 0.0001)
	assert_almost_eq(
		PrologueCommandView.order_progress(129, 100, 130), 1.0, 0.0001, "full the tick before due"
	)
	assert_eq(PrologueCommandView.order_progress(130, 100, 130), 1.0, "it never overfills")
	assert_eq(PrologueCommandView.order_progress(500, 100, 130), 1.0)
	var last: float = 0.0
	for tick: int in range(100, 131):
		var now: float = PrologueCommandView.order_progress(tick, 100, 130)
		assert_gte(now, last)
		last = now


func test_the_name_plate_sits_on_the_edge_and_wraps_its_text() -> void:
	var edge: Vector2 = Vector2(40.0, 60.0)
	var plate: Rect2 = PrologueCommandView.plate_rect(edge, 50.0)
	assert_lte(plate.position.x, edge.x, "starts at the disc edge")
	assert_gte(plate.position.x, edge.x - 3.0)
	assert_gt(plate.size.x, 50.0, "padded around the text")
	assert_lt(plate.size.x, 50.0 + 30.0)
	assert_lt(plate.position.y, edge.y, "straddles the disc's mid line")
	assert_gt(plate.end.y, edge.y)
	assert_almost_eq(plate.get_center().y, edge.y, 1.5)
	assert_gt(PrologueCommandView.plate_rect(edge, 80.0).size.x, plate.size.x)


func test_the_chevrons_mirror_and_point_outward_inside_the_disc() -> void:
	var right: PackedVector2Array = PrologueCommandView.chevron(1)
	var left: PackedVector2Array = PrologueCommandView.chevron(-1)
	for i: int in 3:
		assert_eq(left[i], Vector2(-right[i].x, right[i].y), "the left one mirrors the right")
	assert_gt(right[1].x, 0.0)
	assert_lt(right[1].x, R, "the tip sits inside the disc")
	assert_lt(right[0].x, right[1].x, "the arms trail inward of the tip")
	assert_eq(right[0].x, right[2].x)
	assert_eq(right[0].y, -right[2].y, "the arms spread equally above and below")
	assert_eq(right[1].y, 0.0, "on the centre line")
	assert_between(right[0].distance_to(right[1]), 5.0, 10.0, "short arms")


func test_the_name_plate_hangs_off_the_scaled_disc_rim() -> void:
	var at: Vector2 = Vector2(30.0, 40.0)
	for k: float in [1.0, 1.6, 2.4]:
		var edge: Vector2 = PrologueCommandView.plate_edge(at, k)
		assert_almost_eq(edge.y, at.y, 0.0001, "level with the disc centre")
		assert_almost_eq(edge.x - at.x, R * k, 0.0001, "on the right rim at k %.1f" % k)
