extends GutTest

const POSE = KerfRoninDrawn.Pose


func test_both_drawn_tips_remain_aft_of_their_shoulders_in_flight() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	for current: KerfRoninDrawn.Pose in [POSE.HOVER, POSE.CRUISE, POSE.BLINK]:
		rig.pose(current, 12.0, 0.0, 60)
		for i: int in 2:
			var arm: Sprite2D = rig._upper[i]
			var blade: Sprite2D = rig._blade[i]
			var elbow: Vector2 = _far_joint(rig, arm, "upperarm")
			var tip: Vector2 = _far_joint(rig, blade, "blade")
			assert_almost_eq(elbow, blade.position, Vector2.ONE * 0.001)
			assert_lt(tip.x, arm.position.x)
			assert_lt(tip.x, elbow.x)
			var axis: Vector2 = (tip - elbow).normalized()
			var angle: float = rad_to_deg(absf(Vector2.LEFT.angle_to(axis)))
			var degrees: float = 50.0 if current == POSE.HOVER else 20.0
			assert_almost_eq(angle, 0.0 if current == POSE.BLINK else degrees, 0.01)
			assert_eq(signf(tip.y), -1.0 if i == 0 else 1.0)


func test_cock_crosses_the_chest_cut_follows_facing_and_recovery_eases_back() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	var blade: Sprite2D = rig._blade[1]
	rig.pose(POSE.COCK, 0.0, 0.0, 60)
	var cock: Vector2 = _far_joint(rig, blade, "blade")
	assert_lt(cock.y, 0.0)
	assert_gt(cock.x, rig._upper[1].position.x)
	rig.pose(POSE.CUT, 12.0, 0.0, 1)
	var in_between: Vector2 = _far_joint(rig, blade, "blade")
	rig.pose(POSE.CUT, 12.0, 0.0, 0)
	assert_eq(_far_joint(rig, blade, "blade"), in_between)
	rig.pose(POSE.CUT, 12.0, 0.0, 30)
	var cut: Vector2 = _far_joint(rig, blade, "blade")
	assert_lt(cock.x, in_between.x)
	assert_lt(in_between.x, cut.x)
	assert_almost_eq((cut - blade.position).angle(), 0.0, 0.001)
	rig.pose(POSE.RECOVER, 0.0, 0.0, 30)
	var recover: Vector2 = _far_joint(rig, blade, "blade")
	rig.pose(POSE.HOVER, 0.0, 0.0, 30)
	assert_lt(recover.x, cut.x)
	assert_gt(recover.x, _far_joint(rig, blade, "blade").x)


func test_tail_parts_share_a_root_and_crossfade_across_twelve_metres_per_second() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	assert_eq(rig._curled.position, rig._straight.position)
	assert_lt(rig._curled.position.x, 0.0)
	assert_lt(_far_joint(rig, rig._straight, "tail_straight").x, rig._straight.position.x)
	for speed: float in [0.0, 3.0, 6.0, 12.0, 16.0]:
		rig.pose(POSE.CRUISE, speed, 0.0, 1)
		var straight: float = minf(speed / 12, 1)
		assert_almost_eq(rig._straight.self_modulate.a, straight, 0.0001)
		assert_almost_eq(rig._curled.self_modulate.a, 1.0 - straight, 0.0001)


func test_echo_keeps_both_tail_weights_and_the_departing_blade_transforms() -> void:
	var rig: KerfRoninTop = add_child_autofree(KerfRoninTop.new())
	var snapshot: KerfEcho.Pose = add_child_autofree(KerfEcho.Pose.new())
	var sources: Array[Sprite2D] = []
	for part: Sprite2D in rig.get_children():
		sources.append(part)
	rig.position = Vector2(83, 105)
	rig.rotation = 0.71
	rig.pose(POSE.CRUISE, 9.0, 0.0, 20)
	snapshot.capture(sources, rig.position)
	for part: Sprite2D in sources:
		var copy: Sprite2D = snapshot.sprites[part.get_index()]
		assert_same(copy.texture, part.texture)
		assert_eq(copy.centered, part.centered)
		assert_eq(copy.offset, part.offset)
		assert_true(copy.transform.x.is_equal_approx(part.global_transform.x))
		assert_true(copy.transform.y.is_equal_approx(part.global_transform.y))
		assert_true(copy.position.is_equal_approx(part.global_position - rig.position))
	rig.pose(POSE.BLINK, 12.0, 0.0, 6)
	assert_eq(snapshot.sprites[rig._curled.get_index()].self_modulate.a, 0.25)
	assert_eq(snapshot.sprites[rig._straight.get_index()].self_modulate.a, 0.75)


func _far_joint(rig: KerfRoninTop, sprite: Sprite2D, id: String) -> Vector2:
	return sprite.transform * (rig._parts.pivots_b[id] + sprite.offset)
