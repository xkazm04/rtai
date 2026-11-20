extends GutTest

const POSE = KerfRoninDrawn.Pose


func after_each() -> void:
	GhostLook.reset_for_test()


func test_plain_blink_and_slice_use_half_open_tick_windows() -> void:
	for age: int in [-1, 0, 7, 8, 15, 16]:
		var slice: int = POSE.HOVER
		if age in [0, 7]:
			slice = POSE.CUT
		elif age in [8, 15]:
			slice = POSE.RECOVER
		assert_eq(KerfSpectral.blink_pose(age, true), slice)
		assert_eq(KerfSpectral.blink_pose(age, false), POSE.BLINK if age in [0, 7] else POSE.HOVER)


func test_hurt_then_blink_then_lock_then_turn_then_speed() -> void:
	for blink: KerfRoninDrawn.Pose in [POSE.BLINK, POSE.CUT, POSE.RECOVER]:
		assert_eq(KerfRoninDrawn.pose(0.0, 720.0, blink, true, true), POSE.HIT)
		assert_eq(KerfRoninDrawn.pose(0.0, 720.0, blink, true, false), blink)
	assert_eq(KerfRoninDrawn.pose(3.0, 720.0, POSE.HOVER, true, false), POSE.COCK)
	for side: float in [-1.0, 1.0]:
		var edge: float = KerfRoninDrawn.TURN_DPS
		assert_eq(KerfRoninDrawn.pose(3.0, side * edge, POSE.HOVER, false, false), POSE.HOVER)
		assert_eq(KerfRoninDrawn.pose(3.01, side * edge, POSE.HOVER, true, false), POSE.CRUISE)
		assert_eq(KerfRoninDrawn.pose(3.01, side * (edge + 1), POSE.HOVER, true, false), POSE.TURN)


func test_legacy_and_spectral_build_only_their_own_bodies() -> void:
	GhostLook.override_for_test(&"legacy")
	var legacy: KerfRig = add_child_autofree(KerfRig.new())
	assert_eq(legacy._limbs.size(), 8)
	assert_not_null(legacy._hull)
	assert_null(legacy._spectral)
	GhostLook.override_for_test(&"spectral")
	var spectral: KerfRig = add_child_autofree(KerfRig.new())
	assert_not_null(spectral._spectral)
	assert_true(spectral.drawn.own_body)
	assert_eq(spectral._limbs.size(), 0)
	assert_null(spectral._body)
	assert_null(spectral._card)
	assert_null(spectral._hull)
	assert_null(spectral._cables)


func test_each_pitch_uses_both_sheets_and_matches_dents_profile_head() -> void:
	var previous: String = ViewMode.shared().id
	var card: KerfRoninDrawn = add_child_autofree(KerfRoninDrawn.new())
	for view: String in ["tilt70", "tilt"]:
		ViewMode.select(view)
		for i: int in 8:
			var current: KerfRoninDrawn.Pose = i as KerfRoninDrawn.Pose
			card.show_pose(0, current, 450.0, 0.0, false)
			var file: String = "kerf_sp_fly.png" if i < 4 else "kerf_sp_act.png"
			assert_eq(card.texture.resource_path.get_file(), file)
			assert_eq(card.frame_coords, Vector2i(i % 4, 2))
			assert_eq(card.vframes, 5)
			assert_eq(card.hframes, 4)
			var head_px: float = 77 if view == "tilt" else 90
			var dent_px: float = (70 if view == "tilt" else 77) * 1.8 * SimConst.PX_PER_M / 176.5
			assert_almost_eq(card.scale.x * head_px, dent_px, 0.001)
			var anchor: Vector2 = card.offset
			card.show_pose(4, current, 450.0, 0.0, false)
			assert_true(card.flip_h)
			assert_almost_eq(card.offset.x + anchor.x, -card.get_rect().size.x, 0.001)
			assert_eq(card.offset.y, anchor.y)
		card.show_pose(4, POSE.TURN, -450.0, 0.0, false)
		assert_false(card.flip_h)
		card.show_pose(0, POSE.TURN, -450.0, 0.0, false)
		assert_true(card.flip_h)
	ViewMode.select(previous)


func test_hard_turn_holds_its_direction_through_a_snap_then_releases() -> void:
	var body: KerfSpectral = add_child_autofree(KerfSpectral.new())
	assert_eq(body._turn(-2700.0, 88), -2700.0)
	for tick: int in range(88, 93):
		assert_eq(body._turn(0.0, tick), -2700.0)
	assert_eq(body._turn(10.0, 93), 10.0)
	assert_eq(body._turn(720.0, 94), 720.0)
	assert_eq(body._turn(-720.0, 95), -720.0)


func test_wisp_meets_the_overhead_ribbon_tip_and_hides_at_both_play_tilts() -> void:
	var previous: String = ViewMode.shared().id
	GhostLook.override_for_test(&"spectral")
	var flight: GhostFlight = add_child_autofree(GhostFlight.make(&"kerf"))
	var rig: KerfRig = KerfRig.new()
	PlayerScale.fit([rig])
	rig.drawn.flight = flight
	flight.mount(rig)
	for view: String in ["tilt70", "tilt", "top"]:
		ViewMode.select(view)
		flight.step(Vector2.ZERO, 0.0, 1)
		rig.pose()
		assert_eq(flight.tail.visible, view == "top")
	var top: KerfRoninTop = rig._spectral._top
	var tip: Vector2 = top._curled.to_global(
		top._parts.pivots_b["tail_curled"] + top._curled.offset
	)
	assert_lt(flight.tail.points()[0].distance_to(tip), 0.15 * SimConst.PX_PER_M)
	ViewMode.select(previous)
